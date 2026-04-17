---
title: Version History
layout: default
nav_order: 11
---

# Version History

*Last updated: 2026-04-16*

This page summarizes the major milestones for each release of the QC Automation Agent. Releases are listed in reverse chronological order. For a forward-looking view of what is coming next, see the [Roadmap](roadmap).

---

## v0.9.0 -- April 16, 2026

**Theme: API-driven well discovery, Supabase integration, and historical mode**

The largest release since the API migration. Replaced the manually maintained well list with fully automatic discovery: the agent now queries the platform directly to find active wells for each operator, with no spreadsheet required. Added Supabase as the score of record -- per-well check results, metadata, and scores are written to a persistent database after every well is processed.

Introduced historical run mode for evaluating completed wells. A separate set of 13 checks covers the data that remains relevant after a well has finished drilling, organized into three scoring categories (BHA, Trajectory and Anti-Collision, and Supporting Data). A new location check (Check 30) verifies surface coordinates and is included in historical runs only.

Simplified the Monday.com publishing pipeline. The QC tracking board now shows one summary row per operator (score, well count, last run date, dashboard link) rather than individual per-check columns. The summary board is updated after every active operator run.

Fixed two production bugs discovered during the first smoke test: an audit log that was silently dropped on single-operator runs, and a column value encoding error that caused Monday.com to reject date and link updates.

899 tests passing.

---

## v0.8.1 -- April 13, 2026

**Theme: Cleanup and correctness**

A focused cleanup release following v0.8.0. Removed two leftover fields that had no active purpose after the concurrent execution rewrite, preventing silent stale-value bugs in future updates. Renamed a log event to better reflect how the system actually fetches data. Fixed a subtle variable capture bug in the check execution loop.

No new features. 734 tests passing.

---

## v0.8.0 -- April 10, 2026

**Theme: Concurrent execution and fault tolerance**

The most significant performance release to date. Checks that do not depend on each other now run in parallel rather than one at a time, dramatically reducing the time spent waiting on data retrieval. Two independent circuit breakers were added: one per well (stops processing a well if too many checks time out) and one per run (halts the entire run if too many consecutive wells fail). A request coalescing mechanism ensures that when multiple checks need the same data, only one network call is made.

Several production bugs were fixed, including a stale rig detection issue that had been silently skipping every board item, and a score publishing mutation that failed silently on every retry.

735 tests passing.

---

## v0.7.0 -- April 8, 2026

**Theme: Full API migration -- browser layer retired**

All 29 checks now retrieve data directly from the platform API. The browser automation layer (Playwright) was deprecated and removed from the run path entirely. This completed a migration that began in v0.6.0 and eliminated the root cause of the session degradation issues discovered in v0.6.0. Six new data translation functions were added to cover the remaining checks. Several field name mismatches between the API response shape and the rule engine expectations were discovered and corrected.

615 tests passing.

---

## v0.6.0 -- April 3, 2026

**Theme: API authentication and client layer**

Introduced direct HTTP API access as an alternative to browser-based extraction. An authentication module handles login, token management, and automatic refresh. A central HTTP client handles retries, error handling, and connection pooling. Seven data translation functions were added to convert API responses into the format the rule engine expects. The first seven checks were migrated to the API path; the remaining checks continued to use browser extraction pending the v0.7.0 migration.

This release also added summary statistics to terminal output (total wells, total checks run, total time, average time per well) and introduced the run statistics block to written reports.

---

## v0.5.0 -- April 2, 2026

**Theme: Scoring and publishing**

Introduced the scoring engine that converts check results into weighted category scores and an overall QC score per well and per operator. Added the Monday.com publishing client that writes scores to the live board after each run, with delta detection to avoid unnecessary updates and stale rig flagging for wells no longer in the active CSV. Added the JSON run report that captures all check results, category breakdowns, and operator scores for every run.

486 tests passing.

---

## v0.4.0 -- April 1, 2026

**Theme: Targeted runs, timezone handling, and observability**

Added the `--checks` flag to run a specific subset of checks rather than all 29. The system automatically includes any checks that the selected checks depend on. Added basin-aware timezone correction so that timestamp comparisons use the correct local time for each well's geographic region. Introduced a three-layer safety guardrail for the BHA navigation step to prevent accidental clicks on the wrong drill assembly. Added 13 previously silent fallback paths that now emit a log event before returning a default value, improving the ability to diagnose unexpected results from the audit log alone.

408 tests passing.

---

## v0.3.0 -- March 29, 2026

**Theme: Orchestrator and browser extraction layer**

Built the LangGraph state machine that coordinates the full run: loading the well list, navigating to each module, extracting data, running rules, and writing the report. Added the browser extraction layer with 16 data extraction strategies covering the full range of page types and data formats across the platform. Added static security analysis to catch unsafe patterns before they reach the repository.

368 tests passing.

---

## v0.2.0 -- March 28, 2026

**Theme: Rule engine -- all 29 checks**

Implemented deterministic evaluation logic for all 29 QC checks. Each check has a YAML configuration that defines its inputs, dependencies, and scoring behavior. Check results use a seven-value status system (YES, NO, PARTIAL, N_A, INCONCLUSIVE, YES_EMAIL, YES_WITSML) with defined score weights. Added the browser navigator for page-level navigation, the audit logger for structured event logging, and the log sanitizer that scrubs credentials from all log output before it reaches disk.

For a description of what each check evaluates, see [The 29 Checks](checks).

---

## v0.1.1 -- March 28, 2026

**Theme: Security foundations**

Added the audit trail module (structured JSON event log with operator isolation) and the credential scrubbing layer (prevents API tokens and passwords from appearing in any log file). Both modules are active on every run.

---

## v0.1.0 -- March 21, 2026

**Theme: Project scaffolding**

Initial project structure, security gate (startup policy verification), token bucket rate limiter, CSV parser, and output schema definition. The security gate runs before every execution and blocks startup if any required policy is not met.

---

*For what is coming next, see the [Roadmap](roadmap). For definitions of terms used on this page, see the [Glossary](glossary).*
