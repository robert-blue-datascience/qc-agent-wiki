---
title: Architecture
layout: default
parent: Technical Reference
nav_order: 2
---

# System Architecture

*Last updated: 2026-04-16*

This module documents the QC Automation Agent's architecture, the API migration strategy, and the security posture. For a non-technical overview of how the agent works, see the [How It Works](../how-it-works) guide. For the full API layer reference (endpoint methods, adapter functions, auth lifecycle), see [API Layer](api-layer).

---

## The Four-Layer Model

The QC Agent operates on a highly decoupled four-layer architecture. This separation of concerns allows the agent to securely manage state, extract data at high speeds via direct API calls, and evaluate business rules deterministically. For a non-technical description of this flow, see [How It Works](../how-it-works).

### 1. The Orchestrator Layer (LangGraph)

The Orchestrator acts as the control center of the application. Built on LangGraph, it manages the control flow and execution queue for up to 29 QC checks per well.

* **Well Discovery:** In v0.9.0+, `discover_wells_node` queries the platform search API using an operator whitelist to build the well queue automatically. No CSV input file is required. A count pre-flight checks against a discovery ceiling before the full search runs.
* **State Management:** The orchestrator maintains `QCAgentState`, a typed dictionary that holds the current well context, the queue of pending checks, and the accumulation of results.
* **Resource Caching:** The Orchestrator maintains a `resource_cache` dict (e.g., storing a fetched BHA list so subsequent BHA checks do not trigger redundant network calls). **This cache is cleared between every well evaluation** to prevent cross-well data contamination (Non-Negotiable #1).
* **Routing:** The Orchestrator evaluates the `API_STRATEGY_MAP` to dispatch each check to the correct API fetch function and adapter. All 30 checks are covered; a missing strategy entry returns `INCONCLUSIVE` for that check rather than aborting the run.
* **Historical Mode:** `run_mode="historical"` switches the check queue to a 13-check set with `_historical.yaml` YAML variants for checks that evaluate completed wells differently. The scoring engine selects the corresponding historical weight block.

### 2. The API Extraction Layer (httpx)

The API Layer is the primary data harvesting engine.

* **Connection Pooling:** The `APIClient` is instantiated and managed via an asynchronous context manager (`async with self._api_client:`). This keeps the underlying TCP connections open for the duration of a run, significantly reducing latency across hundreds of endpoint calls.
* **Operator Discovery:** Two search methods (`search_wells`, `search_wells_count`) support operator-scoped discovery with status and geographic filters. These replace the legacy global well-search approach.
* **Concurrent Access:** The PLATFORM rate limit bucket was removed in v0.8.0. Concurrent API access is controlled by a semaphore (`semaphore_size`) in the orchestrator. The rate limiter's retry backoff (`backoff_seconds`) is still used for 5xx recovery.

### 3. The Browser Layer (Removed -- v0.7.0)

The Browser Layer (Playwright) was removed in v0.7.0 after the API migration completed. Prior to v0.6.0, the agent relied entirely on DOM scraping. A hybrid API-first, browser-fallback model was used during v0.6.x while adapters were being written. Once all 29 checks had API coverage, the browser nodes, browser state fields, and all Playwright call paths were removed.

API failures are now handled per-check: a failed fetch returns `INCONCLUSIVE` for that check and the run continues. There is no run-aborting crash path equivalent to the old `browser_dead` flag.

### 4. The Rule Engine

The Rule Engine is immutable. It does not know whether data came from the API or any other source. It receives a flat Python dictionary, applies strict business logic, and outputs a standard status (`YES`, `NO`, `PARTIAL`, `N_A`, or `INCONCLUSIVE`). Historical-mode checks reuse existing eval functions; variant behavior is controlled by `extracted_data` fields injected by the orchestrator before calling the engine.

### 5. The Reporter Layer (Supabase + Monday.com)

After all wells for an operator are processed, two publish nodes run:

* **`publish_supabase_node`:** Writes per-well results to the `well_results` table in Supabase (PostgREST HTTP client in `src/reporter/supabase_client.py`). This is the score-of-record. Epoch ms timestamps from the API are converted to ISO 8601 at the boundary via `_epoch_ms_to_iso()`. Runs on every operator invocation regardless of `--no-publish`; skipped only if credentials are absent.
* **`publish_monday_node`:** Upserts a single operator-level summary row (score, well count, last run date, dashboard link) to the Monday.com summary board. Skipped for historical runs, ad-hoc `--well` invocations, `--no-publish` flag, missing API token, or missing board config.

---

## Well Discovery and the resource_cache

### Well Discovery (v0.9.0+)

Well discovery is now handled by `discover_wells_node` using a targeted operator search rather than a global well list. The node calls `search_wells_count` (pre-flight) and then `search_wells` with the operator UUID, status ID list, and optional state IDs from `config/operator_whitelist.yaml`. This builds a `well_queue` containing only the wells relevant to the current operator run.

The legacy global well search (`get_well_search()`, which fetched the full ~17k well portfolio) is no longer used in the primary discovery path. It is retained in `APIClient` for ad-hoc `--well <uuid>` runs where only a single well UUID is known and no operator context is available.

### The resource_cache Pattern

Within a single well, many checks share API endpoints. `get_bha_list`, for example, is needed by checks 10, 11, 12, 13, 14, and 15. The `resource_cache` dict (held on `QCAgentGraph`, not in `QCAgentState`) stores responses for the current well so each endpoint is fetched only once regardless of how many checks request it.

**Critical:** `save_well_results_node` calls `resource_cache.clear()` at the end of every well. This enforces Non-Negotiable #1 (no cross-well data contamination). The `is not None` check pattern is used throughout (not `or {}`) to distinguish a cache miss from a cache hit on an empty response.

The `_FETCH_FAILED` sentinel (a module-level object, not `None`) is stored in the cache when an API fetch fails. This distinguishes "fetch failed" from "not yet fetched," preventing a failed fetch from triggering redundant retry calls in the same wave.

---

## API Migration Strategy: The Adapter Pattern ("Option A")

The QC Agent was originally built as a UI-driven automation tool relying entirely on browser-based DOM scraping via Playwright. While functional, this approach was susceptible to platform UI changes, slow rendering times, and network-induced timeouts (frequently taking 75+ seconds per well).

### Pure Translation

Rewriting the Rule Engine to natively understand complex, deeply nested JSON responses from the platform API would have introduced massive scope creep and regression risks.

Instead, we implemented the **Adapter Pattern** via `src/api/api_adapter.py`. The API layer fetches raw JSON payloads from the platform, which often include metadata envelopes (e.g., `{"data": {"components": [...]}}`, `headers`, `total_count`). The adapter functions serve as a pure translation layer (Dict in, Dict out). They unwrap these envelopes and reshape the data into the exact, flat dictionary structures the legacy `extractor.py` used to produce.

Because the output of the API adapters perfectly mimics the legacy browser extraction dictionaries, **100% of the rule engine logic remained untouched.** We successfully swapped a slow, unreliable data source for a high-speed, deterministic one while preserving the integrity of every QC rule.

### API-Only Execution (v0.7.0+)

The migration is complete. All 29 checks route exclusively through the `API_STRATEGY_MAP` registry in `nodes.py`. There is no browser fallback path.

Every QC check in the YAML configuration carries a `strategy` key (e.g., `bha_components`, `mud_distro`). The Orchestrator looks up that strategy in `API_STRATEGY_MAP` to get the fetch function(s) and adapter function for that check, calls the API, passes the JSON response through the adapter, and hands the resulting dict to the rule engine.

If a strategy is missing from the map or the API call fails, the orchestrator logs an `API_FETCH_FAILURE` and marks the check `INCONCLUSIVE`. The run continues to the next check.

### Performance Impact

* **Legacy Browser Execution:** ~75-90 seconds per well.
* **API-First Execution:** ~3-5 seconds per well (including safe rate-limiting floors).

This 95% reduction in execution time transformed the QC Agent from a single-well debugging tool into a large-scale, portfolio-level automation engine.

---

## Security Posture and Guardrails

Migrating from browser-based scraping to an API-First architecture fundamentally changed the security surface area. Instead of relying on manual UI authentication, the agent now handles raw JSON Web Tokens (JWTs) and executes rapid network requests.

### 1. The Authentication Lifecycle (JWT Management)

The `APIAuth` class (`src/api/auth.py`) manages the entire lifecycle of the platform credentials. It is designed to be completely autonomous and fault-tolerant.

* **Token Decoding:** Upon successful login, the agent decodes the returned JWT payload to determine the exact expiration time.
* **Auto-Refresh:** The `APIAuth` instance exposes a `get_headers()` method. Before any API request is made, the `APIClient` calls this method. If the token is expired (or nearing expiration), `APIAuth` automatically re-authenticates without interrupting the orchestrator's execution flow.
* **Header Injection:** The bearer token is injected strictly at the request execution layer, meaning the underlying business logic and adapters never handle or see the raw credentials.

### 2. Dynamic Log Scrubbing

A critical risk of API automation is the accidental leakage of bearer tokens or sensitive credentials into application logs. We mitigated this via the `LogSanitizer`.

* **Dynamic Secret Registration:** The `LogSanitizer` features an `add_secret(secret)` method. The moment `APIAuth` receives a new JWT from the platform, it immediately registers the token with the sanitizer.
* **Shared Instance:** The `APIAuth` module and the `AuditLogger` share the exact same `LogSanitizer` instance in memory.
* **The Intercept:** Before any log entry is written to disk, it passes through the sanitizer. If the raw JWT string is detected anywhere in the payload, URL, or error message, it is instantly replaced with a `[REDACTED]` placeholder.

### 3. Static Analysis and Network Choke Points

To ensure the agent cannot be hijacked or misconfigured to exfiltrate data to unauthorized servers, we rely on the Pre-Flight Gatekeeper: `src/guardrails/static_analysis.py`.

* **The Network Allowlist:** The static analyzer enforces an `ALLOWED_DOMAINS` array strictly limited to approved domains.
* **AST Inspection:** Before the orchestrator is allowed to boot, the static analyzer parses the Abstract Syntax Tree (AST) of the entire codebase. It inspects all HTTP requests and browser navigation calls. If any URL attempts to hit a domain outside the allowlist, the agent permanently halts with a `Zero Tolerance` violation.
* **Environment Integrity:** The static analyzer also verifies that all required environment variables exist and that `.gitignore` prevents secrets and output directories from being committed to version control.
