---
title: Rule Engine
layout: default
parent: Technical Reference
nav_order: 3
---

# Rule Engine

*Last updated: 2026-04-07*

The rule engine is the decision layer of the QC Automation Agent. It receives structured data extracted from the AI Driller Cloud platform, applies deterministic rules to each of the [29 checks](../checks), and returns a typed result for every module evaluated. For a full description of what each check measures and why it matters, see the [Checks reference](../checks).

---

## Purpose

The rule engine evaluates whether a well's data quality meets the expected standard for each of the 29 QC modules. It is the only place in the agent where pass/fail decisions are made.

It is intentionally isolated from all other layers:

- No network calls. No browser interaction. No LLM inference.
- Receives extracted data as plain Python dicts. Returns `CheckResult` dataclasses.
- All rule logic is configuration-driven via YAML files in `config/modules/`.

This isolation means the rule engine can be tested end-to-end with mock data, without a browser, without API credentials, and without a live platform connection. It also means that changing a threshold or adding a new check does not require touching the orchestrator, the API layer, or the reporter.

---

## How It Fits

The diagram below shows where the rule engine sits in the four-layer architecture. Extracted data flows in from the orchestrator (sourced from the API layer). Results flow out to the reporter.

```mermaid
flowchart TD
    A["orchestrator/nodes.py\n_process_check_api()\nBuilds extracted_data dict"]:::primary
    B["rules/engine.py\nRuleEngine\nevaluate()"]:::processing
    C["rules/checks/*.py\n10 evaluation modules\nPure Python functions"]:::evaluation
    D["config/modules/*.yaml\n29 YAML configs\nFunction refs + params"]:::output
    E["rules/models.py\nCheckResult\nCheckStatus"]:::output
    F["reporter/score_calculator.py\nConsumes CheckResult list"]:::success
    G{Dependency\nresolved?}:::decision
    H{Additive\ncheck and\nresult = NO?}:::decision

    A --> B
    B --> G
    G -- "yes, short-circuit" --> E
    G -- "no, proceed" --> C
    D -- "function ref + params" --> B
    C --> H
    H -- "yes" --> |"override to N_A"| E
    H -- "no" --> E
    E --> F

    classDef primary fill:#4a90d9,color:#fff
    classDef processing fill:#e8a838,color:#fff
    classDef evaluation fill:#d96a4a,color:#fff
    classDef output fill:#7b68ae,color:#fff
    classDef success fill:#5ba585,color:#fff
    classDef decision fill:#f5f5f5,stroke:#999,color:#333
```

The orchestrator calls `engine.evaluate(check_name, extracted_data)` once per check, per well. The engine looks up the YAML config, resolves any dependency, calls the evaluation function, applies any additive override, accumulates the result, and logs to the audit trail. The reporter reads the accumulated results via `engine.get_well_results()` after all 29 checks have run.

---

## Design Decisions

### Pure functions with no I/O

Every evaluation function in `src/rules/checks/` is a pure function: `(dict, dict) -> CheckResult`. No file I/O, no network calls, no shared state. This is a deliberate constraint.

**Rationale:** Pure functions are trivially testable with `pytest`. Any input combination can be reproduced without infrastructure. Bugs are deterministic and reproducible. The only way a check function behaves differently on two runs with the same input is if the code itself changed.

**Alternative rejected:** Letting check functions read config files or make network calls directly. This would require mocking I/O in every test and would make the engine's behavior depend on the environment.

### YAML configs instead of hardcoded rules

Each of the 29 checks has a corresponding YAML file in `config/modules/`. The YAML defines the check name, category, additive flag, evaluation function reference, and any evaluation parameters (thresholds, timezone maps, etc.).

**Rationale:** Thresholds and parameters change without changing logic. A 90-minute WITSML staleness threshold might become 120 minutes for a specific basin; changing `threshold_minutes: 90` in the YAML does not require touching `witsml.py`, does not require re-running tests for the logic, and is visible in git diff without reading Python. The YAML is also the single source of truth for what function handles each check, making the dispatch table self-documenting.

**Alternative rejected:** Hardcoding thresholds as constants in the check files. This would scatter configuration across 10 files and make it harder to audit or change parameters without reading code.

### Deterministic only, no LLM inference

The rule engine never calls an LLM. Every evaluation function applies explicit conditional logic to its input dict and returns one of 7 predefined statuses. Ambiguous or missing data returns `INCONCLUSIVE`, never a guess.

**Rationale:** This is Non-Negotiable #3. QC scores are published to Monday.com and used by the operations team to identify data quality problems on active wells. A wrong score costs real investigation time. Deterministic rules mean the same input always produces the same result, and every result can be traced to a specific condition in the code.

**Alternative rejected:** Using an LLM to interpret ambiguous platform states (e.g., "does this button text mean connected?"). LLM output is non-deterministic and cannot be audited from a log.

### Dependency resolution mechanism

Some checks are logically redundant when another check passes. Check 9 (Well Plans) is not meaningful when Check 8 (EDM Files) passes because EDM is the preferred data source. The engine resolves this via a `dependencies` block in the YAML:

```yaml
dependencies:
  - check_name: "EDM Files"
    condition: "YES"
    result: "N_A"
```

When `evaluate()` is called for a check with dependencies, the engine looks up the dependency's result from the per-well accumulator. If the condition is met, the engine short-circuits and returns the configured result without calling the evaluation function. If the dependency has not been evaluated yet, the engine returns `INCONCLUSIVE` with a warning, which flags an ordering error in the orchestrator's check queue.

**Rationale:** The dependency condition is in the YAML, not in the evaluation function. This keeps the evaluation functions ignorant of each other. The engine is the only place that knows about inter-check relationships.

### Additive override pattern

Some checks are "bonus" items: data that improves quality but whose absence should not penalize the operator's score. These checks have `additive: true` in their YAML. When an additive check's evaluation function returns `NO`, the engine silently overrides it to `N_A` before accumulating the result. The original evidence string is preserved in the overridden `CheckResult`.

**Rationale:** Additive checks are scored differently from required checks. A well with no survey corrections applied is not worse than a well with corrections; corrections are an enhancement. Making the evaluation function return `N_A` directly would be misleading because the function genuinely found no data. The override separates the data observation (NO data found) from the scoring decision (absence is acceptable).

---

## Public Interface

### `src/rules/models.py`

#### `CheckStatus` (enum)

Seven possible outcomes for any QC check. Inherits from `str` so values serialize directly to JSON without additional conversion.

| Value | Meaning | Score |
|---|---|---|
| `YES` | Data present and valid | 1.0 |
| `YES_WITSML` | Data present, sourced from WITSML | 1.0 |
| `YES_EMAIL` | Data present, sourced via AI Support email | 0.5 |
| `NO` | Data absent or invalid | 0.0 |
| `PARTIAL` | Data partially present (e.g., missing required types) | 0.5 |
| `N_A` | Check not applicable, excluded from denominator | `None` |
| `INCONCLUSIVE` | Agent could not determine status, flagged for review | `None` |

`N_A` and `INCONCLUSIVE` both return `None` from `STATUS_SCORES`. The reporter excludes `None`-scored checks from the denominator entirely. The difference is intent: `N_A` is a known and acceptable exclusion; `INCONCLUSIVE` is an unknown state that should be reviewed.

#### `STATUS_SCORES`

```python
STATUS_SCORES: dict[CheckStatus, float | None]
```

Maps each `CheckStatus` to its numeric scoring impact. Consumed by `reporter/score_calculator.py`. Every `CheckStatus` value is guaranteed to have an entry (verified by `tests/rules/test_models.py`).

#### `CheckResult` (dataclass)

Standard return type for all evaluation functions.

| Field | Type | Description |
|---|---|---|
| `status` | `CheckStatus` | The check outcome |
| `evidence_type` | `str` | How the status was determined: `"element_check"`, `"value_match"`, `"presence"`, or `"grid_scan"` |
| `evidence_value` | `str` | Human-readable description of what was observed |
| `verify_flag` | `bool` | If `True`, result is valid but should be manually reviewed (default `False`) |
| `rule_version` | `str` | Semantic version of the rule definition (default `"1.0.0"`) |
| `checked_at` | `str` | UTC ISO-8601 timestamp, auto-populated at construction |

`verify_flag=True` does not change the status or score. It signals that an unusual condition was detected (e.g., unknown survey source type, fallback timezone threshold applied) that a human should confirm.

---

### `src/rules/engine.py`

#### `RuleEngine`

One instance per agent run. Holds the YAML config registry, the check function registry, and the per-well results accumulator. The orchestrator creates one instance in `graph.py` and reuses it across all wells in a run.

---

#### `__init__(config_dir: str, audit_logger: AuditLogger) -> None`

Loads all YAML configs from `config_dir` and builds the check function registry. Called once at agent startup.

- `config_dir`: Path to the directory containing YAML config files (one per check). Each file must have `check_name`, `check_number`, `category`, `additive`, and `evaluation.function` fields. Files missing required fields are skipped with a warning log.
- `audit_logger`: Used by `evaluate()` and `start_well()` to write to the audit trail. Every check result is logged as a `CHECK_RESULT` event.

Function references in YAML (e.g., `"witsml.evaluate_witsml_connected"`) are resolved via `importlib.import_module` from the `src.rules.checks` package. Registration failures are logged and skipped; they do not prevent the engine from loading.

**Raises:** `FileNotFoundError` if `config_dir` does not exist.

---

#### `start_well(well_name: str) -> None`

Clears the per-well results accumulator and logs a `WELL_EVALUATION_STARTED` event. Must be called before the first `evaluate()` call for each new well.

- `well_name`: Used for the audit log entry only.

If `start_well()` is not called between wells, results from the previous well will appear in `get_well_results()` alongside the current well's results. The orchestrator calls this at the start of `process_check_node` for each new well.

---

#### `evaluate(check_name: str, extracted_data: dict) -> CheckResult`

Main entry point. Evaluates one QC check for the current well.

Steps:
1. Look up YAML config by `check_name`. If not found, return `INCONCLUSIVE`.
2. Resolve dependencies. If a dependency condition is met, short-circuit and return the configured result.
3. Look up the evaluation function. If not registered, return `INCONCLUSIVE`.
4. Call the evaluation function inside a `try/except`. If it raises, log the exception and return `INCONCLUSIVE` (a bug in one check does not abort the run).
5. Apply additive override: if `additive: true` and result is `NO`, override to `N_A`.
6. Accumulate the result.
7. Log a `CHECK_RESULT` audit event with `check_name`, `status`, and `evidence`.

- `check_name`: Must match the `check_name` field in a YAML config exactly (e.g., `"BHA Distro"`, `"Surveys"`).
- `extracted_data`: Dict of data from the API adapter. Keys and structure vary per check; see the check function reference below.

**Returns:** `CheckResult`. Never raises. All failure modes return `INCONCLUSIVE` with an explanatory `evidence_value`.

---

#### `get_well_results() -> dict[str, CheckResult]`

Returns a copy of all accumulated results for the current well. Called by the orchestrator after all 29 checks have been evaluated.

**Returns:** `dict` mapping `check_name` (str) to `CheckResult`. Contains one entry per `evaluate()` call since the last `start_well()`.

---

## Check Function Reference

All evaluation functions share the same signature: `(extracted_data: dict, config: dict) -> CheckResult`. The `config` parameter is the full parsed YAML dict for that check, including `evaluation.params` when the function needs configurable thresholds.

### `src/rules/checks/universal.py`

**Checks:** 6 (NPT Tracking), 7 (Cost Analysis), 16 (Rig Inventory Data), 17 (Tool Catalog Data), 20 (Formation Tops), 21 (Roadmaps), 23 (Engineering Scenarios), 24 (AI Drill Prog), 25 (AFE Curves)

**Function:** `evaluate_universal(extracted_data, config)`

**What it evaluates:** Whether a platform grid is populated with data. The extractor resolves the UI state to a boolean before this function runs; the function only interprets that boolean.

**`extracted_data` fields:**
- `data_present` (bool or None): `True` if the grid has data (ag-root `aria-rowcount` > 1), `False` if the empty skeleton-image is visible, `None` if the element state could not be determined.

**Return conditions:**
- `data_present is True` -> `YES`
- `data_present is False` -> `NO`
- `data_present is None` -> `INCONCLUSIVE`

Nine separate YAML configs all reference this one function, each with their own `check_name` and `check_number`. The function ignores `config` entirely; the engine's calling convention requires it be present.

---

### `src/rules/checks/witsml.py`

**Checks:** 1 (WITSML Connected)

**Function:** `evaluate_witsml_connected(extracted_data, config)`

**What it evaluates:** Whether WITSML data is actively flowing to this well. Compares the platform's last data timestamp to the current system time. If the delta is within the configured threshold, WITSML is live.

**`extracted_data` fields:**
- `header_timestamp` (str or int/float or None): Either a display string from the browser (e.g., `"03/23/26, 06:30 PM"`, in the rig's local timezone) or an epoch milliseconds integer from the API adapter (already UTC).
- `system_time` (str): Current UTC time as ISO-8601.
- `basin` (str): Basin name from the input CSV, used to look up the rig's IANA timezone in `config.evaluation.params.basin_timezones`. Ignored when `header_timestamp` is an epoch int.

**Return conditions:**
- Missing `header_timestamp` or `system_time` -> `INCONCLUSIVE`
- Unparseable timestamp -> `INCONCLUSIVE`
- Delta within `threshold_minutes` (default 90) -> `YES_WITSML`
- Delta exceeds threshold -> `NO`
- Unknown basin (fallback threshold of 480 min used) -> result as above, `verify_flag=True`

The function handles four timestamp formats to accommodate operator-specific platform configurations: 2-digit or 4-digit year crossed with 12-hour or 24-hour clock. Epoch ms integers from the API adapter bypass all timezone conversion since they are already UTC.

---

### `src/rules/checks/surveys.py`

**Checks:** 2 (Surveys), 3 (Survey Program), 4 (Survey Corrections)

**Functions:**
- `evaluate_surveys(extracted_data, config)` -- Check 2
- `evaluate_survey_program(extracted_data, config)` -- Check 3
- `evaluate_survey_corrections(extracted_data, config)` -- Check 4 (additive)

**What they evaluate:**

Check 2 is the most complex decision tree in the engine. It verifies that: (a) survey data exists, (b) the last survey measurement depth is within 300 ft of current depth, and (c) the data source is known.

Check 3 confirms the survey program dialog grid has data (universal pattern).

Check 4 looks for manual corrections: any `point_source_desc` value that is not `"WITSML"` or `"AI Support"`. Because this is additive, a `NO` result is overridden to `N_A` by the engine. Check 4 also has a dependency on Check 2: if Surveys returns `NO`, there are no surveys to evaluate corrections against, so the engine short-circuits Check 4 to `N_A` without calling the evaluation function (defined in `config/modules/check_04_survey_corrections.yaml`).

**`extracted_data` fields (Check 2):**
- `data_present` (bool or None): Whether the survey grid has rows.
- `last_md` (str): Last row measured depth, e.g., `"26400ft"`. Parsed by `_parse_depth()` which strips non-numeric suffixes.
- `current_depth` (str): Header depth value, e.g., `"26659.1ft"`.
- `point_source_desc` (list[str]): Source values from the last 5 survey rows.

**`extracted_data` fields (Checks 3 and 4):**
- `data_present` (bool or None) -- Check 3
- `point_source_desc` (list[str]) -- Check 4

**Check 2 return conditions (6 branches):**
1. `data_present is None` -> `INCONCLUSIVE`
2. `data_present is False` -> `NO`
3. Depths unparseable -> `INCONCLUSIVE`
4. `current_depth - last_md > 300 ft` -> `NO` (surveys behind current depth)
5. All sources are `"WITSML"` -> `YES_WITSML`
6. Any `"AI Support"` present -> `YES_EMAIL`
7. Unknown source types found -> `YES` with `verify_flag=True`

---

### `src/rules/checks/geosteering.py`

**Checks:** 5 (Live Geosteering)

**Function:** `evaluate_geosteering(extracted_data, config)`

**What it evaluates:** Whether the StarSteer connection is active. The platform displays a button whose text indicates the connection state.

**`extracted_data` fields:**
- `button_text` (str or None): Text of the StarSteer connection button. In the API path, this is synthesized from `linked_interpretation` fields by `adapt_geosteering()` in `src/api/api_adapter.py`.

**Return conditions:**
- `button_text is None` -> `INCONCLUSIVE`
- Starts with `"Connected to"` -> `YES`
- Starts with `"Connect to"` -> `NO`
- Any other value -> `INCONCLUSIVE` (unexpected state, not a guess)

---

### `src/rules/checks/drilling.py`

**Checks:** 8 (EDM Files), 9 (Well Plans)

**Functions:**
- `evaluate_edm_files(extracted_data, config)` -- Check 8
- `evaluate_well_plans(extracted_data, config)` -- Check 9

**What they evaluate:**

Check 8 is a universal data presence check on the EDM files grid.

Check 9 adds a type filter: data must be present and at least one row must have `"Definitive"` in its variant type column. If Check 8 returns `YES`, the engine short-circuits Check 9 to `N_A` via the dependency mechanism (defined in `config/modules/check_09_well_plans.yaml`), because EDM is the authoritative source when it exists.

**`extracted_data` fields (Check 8):**
- `data_present` (bool or None)

**`extracted_data` fields (Check 9):**
- `data_present` (bool or None)
- `variant_types` (list[str] or None): Values from the plan type column. The API adapter maps `PRINCIPAL_*` enum values to `"Definitive"` variants before this function sees them.

**Return conditions (Check 9):**
- `data_present is None` -> `INCONCLUSIVE`
- `data_present is False` -> `NO`
- Data present, at least one `"Definitive"` in `variant_types` -> `YES`
- Data present, no `"Definitive"` found -> `PARTIAL`

---

### `src/rules/checks/bha.py`

**Checks:** 10 (BHA Distro), 11 (BHA Comments), 12 (BHA Uploads), 13 (BHA Failure Reports), 14 (BHA Full Components), 15 (Post Run BHAs)

**Functions:**
- `evaluate_bha_distro(extracted_data, config)` -- Check 10
- `evaluate_bha_comments(extracted_data, config)` -- Check 11
- `evaluate_bha_uploads(extracted_data, config)` -- Check 12
- `evaluate_bha_failure_reports(extracted_data, config)` -- Check 13 (additive)
- `evaluate_bha_full_components(extracted_data, config)` -- Check 14
- `evaluate_post_run_bhas(extracted_data, config)` -- Check 15

**What they evaluate:** Six different aspects of BHA data completeness. All operate on data from Actual-type BHAs only. Per-BHA iteration (opening each BHA drawer) is handled by the orchestrator's `_process_check_api()` before the evaluation functions are called.

**`extracted_data` fields by check:**
- Check 10: `data_present` (bool or None), `bha_types` (list[str])
- Check 11: `bha_comments` (list[dict] or None) -- each dict has `dd_comments`, `reason_pulled`, `bha_performance`, `additional_comments`
- Check 12: `bha_upload_counts` (list[int] or None) -- one count per Actual BHA
- Check 13: `has_failed_flags` (list[bool] or None) -- one flag per BHA row
- Check 14: `component_types` (list[str] or None) -- values from the component type column
- Check 15: `grade_out_fields` (list[dict] or None) -- one dict per Actual BHA, `None` entries indicate extraction failure for that BHA

**Return conditions by check:**
- Check 10: `YES` if `data_present` and any type is `"Actual"`; `NO` if no `"Actual"` type; `INCONCLUSIVE` if `data_present is None`
- Check 11: `YES` if any comment field is non-empty across all BHAs; `NO` if all fields empty; `INCONCLUSIVE` if `bha_comments is None`
- Check 12: `YES` if any upload count > 0; `NO` if all zero; `INCONCLUSIVE` if `counts is None`
- Check 13: `YES` if any failure flag is True (additive, NO becomes N_A); `INCONCLUSIVE` if `flags is None`
- Check 14: `YES` if Bit, Motor, and MWD all present; `PARTIAL` if some but not all found; `NO` if none found; `INCONCLUSIVE` if `component_types is None`
- Check 15: `YES` if any grade-out field is non-empty in any BHA; `INCONCLUSIVE` if any BHA entry is `None` and no data was found (partial extraction failure); `NO` if all fields empty and no `None` entries

The `evaluate_post_run_bhas` function performs a data scan before the `None` check: if data is found in any BHA, `YES` is returned even if other BHA entries failed extraction. This is intentional -- a partial extraction that finds data is a confirmed `YES`, not an `INCONCLUSIVE`.

---

### `src/rules/checks/mud.py`

**Checks:** 18 (Mud Report Distro), 19 (Mud Program)

**Functions:**
- `evaluate_mud_report_distro(extracted_data, config)` -- Check 18
- `evaluate_mud_program(extracted_data, config)` -- Check 19 (additive)

**What they evaluate:**

Check 18 combines a presence check with a recency check. The most recent mud report must have been updated within the configured window (default 24 hours).

Check 19 is a universal data presence check on the mud program tab. It is additive.

**`extracted_data` fields:**
- Check 18: `data_present` (bool or None), `last_modified` (str or int/float) -- either a platform display string or epoch milliseconds from the API adapter
- Check 19: `data_present` (bool or None)

**Return conditions (Check 18):**
- `data_present is None` -> `INCONCLUSIVE`
- `data_present is False` -> `NO`
- `last_modified` missing -> `INCONCLUSIVE`
- `last_modified` unparseable -> `INCONCLUSIVE`
- Within `recency_hours` (default 48) -> `YES`
- Outside `recency_hours` -> `NO` (data present but stale)

The `_parse_datetime()` helper handles four timestamp formats plus ISO-8601 plus epoch milliseconds from the API path. It normalizes non-breaking spaces (`\u00a0`) that some operators embed between date and time components.

The recency threshold was widened from 24h to 48h in v0.7.0 after a 40-hour-old report on an active well scored `NO` incorrectly. The 48h window reflects realistic mud report update cadence on active wells.

---

### `src/rules/checks/engineering.py`

**Checks:** 22 (Wellbore Diagrams)

**Function:** `evaluate_wellbore_designs(extracted_data, config)`

**What it evaluates:** Whether wellbore design data is present and includes at least one `"Definitive"` design type. Same pattern as Check 9 (Well Plans) but on the Wellbore Diagrams grid. The API adapter maps `*_PLAN` enum suffixes (e.g., `"PROTOTYPE_PLAN"`) to display strings containing `"Definitive"` before this function runs.

**`extracted_data` fields:**
- `data_present` (bool or None)
- `design_types` (list[str] or None): Values from the design type column.

**Return conditions:**
- `data_present is None` -> `INCONCLUSIVE`
- `data_present is False` -> `NO`
- Data present, any type contains `"Definitive"` -> `YES`
- Data present, no `"Definitive"` found -> `PARTIAL`

---

### `src/rules/checks/file_drive.py`

**Checks:** 26 (File Drive - BHAs), 27 (File Drive - Well Plans), 28 (File Drive - Drill Prog), 29 (File Drive - Mud Reports)

**Function:** `evaluate_file_drive_folder(extracted_data, config)`

**What it evaluates:** Whether a specific File Drive folder contains uploaded files. One function handles all four checks. The folder name is read from `config.extraction.params.folder_name` for use in the evidence string.

**`extracted_data` fields:**
- `folder_has_files` (bool or None): `True` if `.last-modified-at` text is non-empty (files present), `False` if empty, `None` if the element was not found.

**Return conditions:**
- `folder_has_files is True` -> `YES`
- `folder_has_files is False` -> `NO`
- `folder_has_files is None` -> `INCONCLUSIVE`

Note: Check 28 (File Drive - Drill Prog) has a dependency on Check 24 (AI Drill Prog). When Check 24 returns `YES`, the engine short-circuits Check 28 to `N_A`, defined in `config/modules/check_28_file_drive_drill_prog.yaml`.

---

## Internal Patterns

### YAML dispatch

The engine uses a string-to-callable registry built at startup. Each YAML config's `evaluation.function` field is a dotted reference like `"witsml.evaluate_witsml_connected"`. The engine splits on the last dot, imports `src.rules.checks.witsml`, and calls `getattr` to retrieve the function. The same dispatch pattern appears in the orchestrator's `TOOL_REGISTRY` for check routing.

This means adding a new check requires: (1) a new YAML file in `config/modules/`, (2) a new evaluation function in the appropriate `src/rules/checks/` file, and (3) no changes to the engine itself.

### Dependency chain

Dependencies are evaluated in the order the orchestrator calls `evaluate()`. The engine reads dependency results from the per-well accumulator (`_well_results`). This means the orchestrator's check execution order controls which dependency conditions can be evaluated. The YAML dependency block supports both a single condition string and a list of condition strings (via the `conditions = dep_condition if isinstance(dep_condition, list) else [dep_condition]` normalization in `_resolve_dependencies()`).

If a dependency check has not yet been evaluated when its dependent check runs, the engine returns `INCONCLUSIVE` and logs `"rule_engine.dependency_not_evaluated"`. This is a check ordering bug in the orchestrator, not a data problem.

### Per-well accumulator

`_well_results` is a `dict[str, CheckResult]` on the engine instance. It is reset to an empty dict by `start_well()` before each new well. The orchestrator calls `start_well()` before iterating the 29 checks for each well. The accumulator is the engine's only mutable state; all other state (configs, function registry) is set once at construction and never modified.

---

## Non-Negotiable Enforcement

| Non-Negotiable | How the rule engine enforces it |
|---|---|
| **#1 Client data safety** | The per-well accumulator is cleared by `start_well()` before each well. Results from one well never appear in another well's `get_well_results()` output. The orchestrator also clears `resource_cache` between wells at the API layer. |
| **#2 Platform safety** | The rule engine makes no network calls. It is read-only by construction. Rate limiting is enforced at the API layer, not here. |
| **#3 Accuracy** | All evaluation functions return `INCONCLUSIVE` for ambiguous or missing data. No fallback values are guessed. The `verify_flag` mechanism flags unusual-but-valid states without changing the score. |
| **#4 Completeness** | The engine logs a `CHECK_RESULT` audit event for every check evaluated, including `INCONCLUSIVE` results. Missing configs and unregistered functions also log before returning `INCONCLUSIVE`. Silent omissions are structurally prevented. |
| **#5 Transparency** | Every `evaluate()` call writes a `CHECK_RESULT` event to the audit logger with `check_name`, `status`, and `evidence`. The audit trail contains enough information to reconstruct what the engine decided for every check on every well. |

---

## Testing Strategy

### Test files

| File | What it covers |
|---|---|
| `tests/rules/test_models.py` | `CheckStatus` completeness, `STATUS_SCORES` mapping, `CheckResult` defaults and field preservation |
| `tests/rules/test_engine.py` | YAML routing, dependency short-circuit, dependency ordering errors, additive override, accumulator reset, error cases (missing config, exception in eval function) |
| `tests/rules/test_engine_integration.py` | All 29 checks through the real YAML configs with mock data, dependency resolution for Checks 4, 9, and 28, additive override for Checks 4/13/19/21, valid status types |
| `tests/rules/test_universal.py` | All three outcomes for `evaluate_universal` |
| `tests/rules/test_witsml.py` | Epoch path, string path (4 format variations), basin timezone lookup, fallback threshold, `verify_flag` behavior |
| `tests/rules/test_surveys.py` | 6-branch decision tree for Check 2, all outcomes for Checks 3 and 4 |
| `tests/rules/test_geosteering.py` | Connected/not-connected/unexpected button text |
| `tests/rules/test_drilling.py` | Check 8 (universal), Check 9 (Definitive type, PARTIAL, dependency) |
| `tests/rules/test_bha.py` | All 6 BHA checks with happy path, empty inputs, `None` inputs, and mixed data |
| `tests/rules/test_mud.py` | Recency check with recent and stale timestamps, epoch ms path, 4-format timestamp parsing, non-breaking space normalization |
| `tests/rules/test_engineering.py` | Definitive type present, absent (PARTIAL), no data |
| `tests/rules/test_file_drive.py` | All three `folder_has_files` states |

### What is mocked

The `AuditLogger` is replaced with a `MagicMock` in all unit tests. The engine tests write temporary YAML configs to `tmp_path`. The integration test loads the real YAML configs from `config/modules/` but uses mock `extracted_data` dicts in place of live API responses.

No browser, no network, no credentials are required to run the test suite.

### Known gaps

- The `_parse_depth()` helper in `surveys.py` is tested indirectly via `evaluate_surveys`. It does not have a dedicated unit test for edge cases like empty strings or non-numeric characters.
- The `verify_flag` on `evaluate_survey_corrections` is not currently set even for unknown sources (the function returns `NO` and relies on the engine's additive override). If unknown sources are found in practice and the additive override is removed, this gap would matter.

### How to run

```bash
# Full rules test suite
python -m pytest tests/rules/ -v

# Single file
python -m pytest tests/rules/test_engine.py -v

# Integration test only
python -m pytest tests/rules/test_engine_integration.py -v
```

---

*See also: [Architecture](architecture) | [The 29 Checks](../checks)*
