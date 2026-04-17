---
title: Monday.com Integration
layout: default
parent: Technical Reference
nav_order: 6
---

# Monday.com Integration

*Last updated: 2026-04-16*

The Monday.com integration is the final step of every active QC run. After all checks have been evaluated and scores computed, the agent publishes an operator-level summary row to the summary board. Historical runs and ad-hoc single-well runs skip this step entirely.

---

## Purpose

`src/reporter/monday_client.py` owns all communication with Monday.com. It executes GraphQL mutations against `api.monday.com` to upsert one row per operator on the summary board.

The client is deliberately synchronous (`requests`, not `httpx`). Publishing happens after the async LangGraph run has completed and the event loop has closed, so there is no async context to integrate with. If the client is ever called from within a running event loop it will need a thread-based bridge.

---

## Design Decisions

### Payload logged before every mutation (Non-Negotiable #5)

**Decision:** `_graphql()` logs `MONDAY_API_REQUEST` with the query string (truncated to 200 chars) and a `has_variables` flag before executing the HTTP call. This happens on every call, including retries.

**Rationale:** Non-Negotiable #5 requires transparency: every action logged locally as structured JSON. If a mutation writes incorrect data to the board, the audit log must contain enough information to reconstruct exactly what was sent without re-running the agent.

**Alternative rejected:** Logging after the call completes. If the network call hangs or crashes, the post-call log entry is never written. Pre-call logging guarantees the intent is recorded even if execution fails.

---

### Rate limiter MONDAY bucket

**Decision:** Every call to `_graphql()` acquires a token from the MONDAY bucket of the rate limiter before executing.

**Rationale:** Non-Negotiable #2 (platform safety) requires rate control on all outbound API calls. Monday.com has its own rate limits separate from the AI Driller Cloud API. The MONDAY bucket is a separate token bucket with its own replenishment rate.

**Implementation note:** Because `publish_monday_node` runs synchronously after the async LangGraph run, `_graphql()` calls `asyncio.run()` to acquire the token. This works correctly only because the event loop is not running at publish time.

---

### Board configuration externalized to `config/monday_boards.yaml`

**Decision:** All board IDs and column IDs live in `config/monday_boards.yaml`. `MondayClient` receives the parsed config dict as a constructor argument; it never reads the file itself.

**Rationale:** Column IDs are Monday.com internal identifiers that could change if columns are renamed or the board is restructured. Externalizing them means a board change requires editing one YAML file, not hunting through source code. Injecting the config dict (rather than reading it in the constructor) keeps the client testable without a filesystem.

---

## Board Configuration Reference

Source of truth: `config/monday_boards.yaml`, `summary_board` section.

### Column IDs

| Purpose | Config key | Type |
|---|---|---|
| QC score | `score` | Numeric (float, or null for zero-well operators) |
| Well count | `well_count` | Numeric (int) |
| Last run date | `last_run` | Date (`{"date": "YYYY-MM-DD"}`) |
| Dashboard link | `dashboard_link` | Link (`{"url": "", "text": ""}`) |

Column IDs are Monday.com internal identifiers stored in `config/monday_boards.yaml`. They are not hardcoded in source files.

---

## Public Interface

### `MondayClient.__init__`

```python
def __init__(
    self,
    api_token: str,
    rate_limiter,
    audit_logger,
    board_config: dict,
) -> None:
```

Constructs a client for one operator run. `board_config` must be the parsed `summary_board` section from `monday_boards.yaml`. All board and column IDs are extracted at construction time. `api_token` is the raw Monday.com API token string (not prefixed).

**When to call:** `publish_monday_node` in `orchestrator/nodes.py` constructs one instance per operator per active run.

---

### `MondayClient.upsert_operator`

```python
def upsert_operator(
    self,
    operator_name: str,
    column_values: dict,
) -> dict:
```

Fetches all board items, looks for an existing row whose item name matches `operator_name` (exact match), then either updates it via `change_multiple_column_values` or creates it via `create_item`.

**Parameters:**
- `operator_name` -- used as the item name. Lookup is exact-match, case-sensitive.
- `column_values` -- dict mapping column IDs to their values. Numbers columns accept `int`/`float` or `None` (null clears the cell). Date columns accept a dict `{"date": "YYYY-MM-DD"}`. Link columns accept a dict `{"url": "...", "text": "..."}`. Pass dicts directly -- this method serializes the entire dict with a single `json.dumps()` call.

**Returns:** `{"action": "created"|"updated"|"error", "item_id": str|None, "error": None|str}`.

---

### `MondayClient.fetch_board_items`

```python
def fetch_board_items(self) -> list[dict]:
```

Fetches all items from the board using cursor-based pagination (500 items per page). Returns a flat list of `{id, name}` dicts.

---

### `MondayClient.find_item_by_name`

```python
def find_item_by_name(
    self,
    operator_name: str,
    items: list[dict],
) -> dict | None:
```

Linear scan of `items` looking for the first item whose `name` matches `operator_name` exactly. Returns the item dict or `None`.

---

## GraphQL Mutations

### Update existing item

```graphql
mutation ($boardId: ID!, $itemId: ID!, $columnValues: JSON!) {
    change_multiple_column_values(
        board_id: $boardId,
        item_id: $itemId,
        column_values: $columnValues
    ) {
        id
    }
}
```

`columnValues` is a JSON-encoded dict mapping column IDs to their value objects.

---

### Create new item

```graphql
mutation ($boardId: ID!, $itemName: String!, $columnValues: JSON!) {
    create_item(
        board_id: $boardId,
        item_name: $itemName,
        column_values: $columnValues
    ) {
        id
    }
}
```

Note: no `group_id` -- Monday.com places the item in the board's default group.

---

## Retry Logic

`_graphql` retries on 5xx responses with fixed backoffs of `[5, 10, 20]` seconds (up to 3 attempts). 4xx responses fail immediately. 401 specifically logs `MONDAY_AUTH_ERROR` before raising. GraphQL-level errors (HTTP 200 with `errors` in the response body) raise immediately without retry because they indicate a structural problem with the mutation (e.g., invalid column value format), not a transient server failure.

**Column value format note:** Monday.com returns HTTP 200 with a GraphQL error body when a column value is structurally invalid. The most common cause is double-encoded JSON: if date or link values are pre-serialized with `json.dumps()` before being inserted into `column_values`, and then `json.dumps(column_values)` is called again, the values become escaped strings that Monday.com rejects. Pass dicts directly to `upsert_operator` and let the client handle serialization.

---

## Non-Negotiable Enforcement

| Non-Negotiable | How Enforced |
|---|---|
| **#2 Platform safety (API rate limiting)** | `_graphql` acquires a MONDAY bucket token via `asyncio.run(self._rate_limiter.acquire(...))` before every outbound call. No call bypasses this. |
| **#4 Completeness** | Publishing errors are caught and logged; they never abort the run. The operator's local report is always written regardless of Monday.com outcome. |
| **#5 Transparency** | `_graphql` logs `MONDAY_API_REQUEST` before execution. Every action (created, updated, error) has a corresponding named audit log event. |

---

## Testing Strategy

**Test file:** `tests/reporter/test_monday_client.py`

### What is tested

| Area | Tests |
|---|---|
| Config column extraction | `board_config` fixture verifies column IDs loaded from `monday_boards.yaml` |
| `find_item_by_name` | Found, not found, empty list, case-sensitive |
| `upsert_operator` create path | `create_item` mutation called, new ID returned |
| `upsert_operator` update path | `change_multiple_column_values` called, existing ID returned |
| `upsert_operator` error path | Exception caught, `action: "error"` returned |
| GraphQL error body | HTTP 200 with `errors` key raises and is returned as error |
| All skip conditions | historical mode, ad-hoc run, no-publish flag, missing token, missing board config, missing report file |
| Happy path (node level) | `upsert_operator` called once, `MONDAY_PUBLISH_COMPLETED` logged |
| Score rounding | Float rounded to 1 decimal place |
| Zero-well operator | `score=None`, `well_count=0` |
| Exception in upsert | `MONDAY_PUBLISH_FAILED` logged, node returns `{}` |

### What is mocked

- `_graphql` is patched with `patch.object(client, "_graphql")` for all mutation tests.
- `fetch_board_items` is patched for `upsert_operator` tests to inject controlled item lists.
- `rate_limiter` is an `AsyncMock` with `acquire` mocked.
- `audit_logger` is a `MagicMock`. Tests inspect `log.call_args_list` to verify event names.
- `MondayClient` class itself is patched in node-level tests via `patch("src.reporter.monday_client.MondayClient")`.
- Real `config/monday_boards.yaml` is loaded by the `board_config` fixture so column ID tests verify against live config.

### How to run

```bash
python -m pytest tests/reporter/test_monday_client.py -v
```
