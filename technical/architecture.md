---
title: Architecture
layout: default
parent: Technical Reference
nav_order: 2
---

# System Architecture

This module documents the QC Automation Agent's four-layer architecture, the API migration strategy, and the security posture. For a non-technical overview of how the agent works, see the [How It Works](../how-it-works) guide.

Last updated: 2026-04-07

---

## The Four-Layer Model

The QC Agent operates on a highly decoupled four-layer architecture. This separation of concerns allows the agent to securely manage state, extract data at high speeds via direct API calls, and evaluate business rules deterministically.

### 1. The Orchestrator Layer (LangGraph)

The Orchestrator acts as the "Brain" of the application. Built on LangGraph, it manages the control flow and execution queue for the 29 QC checks.

* **State Management:** The orchestrator maintains the `QCAgentState`, a typed dictionary that holds the current well context, the queue of pending checks, and the accumulation of results.
* **Resource Caching:** To satisfy strict data isolation policies, the Orchestrator maintains a `resource_cache` (e.g., storing a fetched BHA list so subsequent BHA checks do not trigger redundant network calls). **Crucially, this cache is wiped clean between every well evaluation** to prevent cross-well data contamination.
* **Routing:** The Orchestrator evaluates the `API_STRATEGY_MAP` to dispatch each check to the correct API fetch function and adapter. All 29 checks are covered; a missing strategy entry returns `INCONCLUSIVE` for that check rather than aborting the run.

### 2. The API Extraction Layer (httpx)

The API Layer is the primary data harvesting engine, replacing legacy DOM scraping.

* **Connection Pooling:** The `APIClient` is instantiated and managed via an asynchronous context manager (`async with self._api_client:`). This keeps the underlying TCP connections open for the duration of a run, significantly reducing latency across hundreds of endpoint calls.
* **Rate Limiting:** All API requests pass through a centralized rate limiter. The system utilizes a `PLATFORM` bucket with a hard **300ms floor**. This ensures that even during rapid parent-child iterations (e.g., fetching 5 BHA details sequentially), the agent remains a "good citizen" and avoids triggering platform API throttling.

### 3. The Browser Layer (Removed -- v0.7.0)

The Browser Layer (Playwright) was removed in v0.7.0 after the API migration completed on 2026-04-07. Prior to v0.6.0, the agent relied entirely on DOM scraping via Playwright. A hybrid "API-First, Browser-Fallback" model was used during v0.6.x while adapters were being written. Once all 29 checks had API coverage, the browser nodes (`launch_browser_node`, `login_node`), browser state fields, and the `BrowserNavigator` / `BrowserExtractor` call paths were removed from the orchestrator entirely.

API failures are now handled per-check: a failed fetch returns `INCONCLUSIVE` for that check and the run continues. There is no run-aborting crash path equivalent to the old `browser_dead` flag.

### 4. The Rule Engine

The Rule Engine is immutable. It does not know (or care) whether data came from the API or the Browser. It receives a flat Python dictionary, applies strict business logic, and outputs a standard score (`YES`, `NO`, `N_A`, or `INCONCLUSIVE`).

---

## The Run-Level Callback Cache

One of the most significant performance optimizations in the Orchestrator is the **Run-Level Callback Cache**.

### The Problem

To evaluate a specific well, the agent must resolve its name to a UUID via the platform's `/api/wells/search` endpoint. This endpoint returns a massive payload of over 17,000 global wells. Fetching this for every single well in a 111-well manifest would result in severe bandwidth waste and unnecessary time penalties.

### The Callback Solution

We cannot store the global well list in the standard `QCAgentState` or the `resource_cache` because the orchestrator strictly wipes state between wells.

Instead, we use a **Callback Pattern**:
1. The `QCAgentGraph` instance initializes a persistent `self._well_search_cache` attribute.
2. When the wrapper function invokes the `select_well_node`, it passes this cache and a setter callback down into the node.
3. On the first well evaluation, the node hits the API, fetches the 17k+ wells, and triggers the callback to store the list on the Graph instance.
4. For the remaining 110 wells, the node detects the populated cache and resolves the UUID locally in milliseconds.

This pattern successfully prevents LangGraph state pollution while entirely eliminating redundant heavy network calls.

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
