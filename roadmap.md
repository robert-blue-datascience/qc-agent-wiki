---
title: Roadmap
layout: default
nav_order: 8
---

# Roadmap

*Last updated: 2026-04-13*

This page outlines where the QC Automation Agent has been and where it is going. Milestones are listed in order of completion, followed by current and future work.

---

## Completed

### Foundation and Guardrails
The project began with the core safety infrastructure: a security gate that verifies system integrity at startup, a rate limiter that prevents overloading the cloud platform, an audit logger that records every action, and a credential sanitizer that ensures sensitive values never appear in logs or reports.

### Single-Well Automation and Validation
The agent was validated against individual wells using browser-based data extraction. All 29 QC checks were implemented, tested against live platform data, and confirmed to produce accurate, consistent results across multiple operators.

### Full Portfolio Scoring and Publishing
The agent was expanded from single-well operation to full-portfolio processing. A weighted scoring system was built to convert 29 individual check results into category averages and a single operator score. Score publishing to a Monday.com QC board was implemented, including delta detection (only updating scores that have changed) and per-check status columns.

### API Migration
The data extraction layer was migrated from browser-based automation to direct API communication. The browser approach degraded silently after approximately 45 minutes, producing incorrect scores at scale. The API path makes each check fully independent: a failed call returns INCONCLUSIVE for that check only and the run continues. The first full portfolio run through the API path completed April 9, 2026 -- 106 wells, 20 operators, 3,045 checks executed, all scores published.

### Concurrent Check Execution (v0.8.0 -- April 10, 2026)
All 29 checks for a single well now run in parallel rather than sequentially. A two-wave execution model (independent checks first, dependency-bound checks second) preserves correctness while allowing maximum parallelism. Per-well and run-level circuit breakers protect against cascading timeouts. Request coalescing ensures shared API endpoints are fetched once per well regardless of how many checks need them.

The first concurrent full-portfolio run completed April 13, 2026: 106 wells, 19 operators, 3,074 checks, total run time 2 minutes 53 seconds -- down from approximately 3 hours 9 minutes with sequential execution.

### Architectural Cleanup (v0.8.1 -- April 13, 2026)
Post-release cleanup ahead of the v0.9.0 graph restructure. Removed stale state fields and configuration entries that had no runtime consumers after the v0.8.0 concurrent refactor. Log event naming aligned to the two-phase fetch model introduced in v0.8.0. Lambda closure correctness fixed in the check execution loop.

---

## Current Focus

### v0.9.0 -- API-Driven Well Discovery and Supabase

The next release replaces the manually maintained CSV input file with automated well discovery and adds a persistent results database. Four phases:

**Phase A -- Well Discovery.** The agent will query the platform API directly to find all active wells for each configured operator. No more manual input file. Operators and their active/historical status filters are defined in a configuration file. Discovery runs at the start of each agent invocation.

**Phase B -- Supabase Integration.** Run results will be written to a Supabase database, providing a persistent, queryable record of every QC run, every well result, and every check result. This replaces the per-run JSON report as the primary results store and enables the trend board described below.

**Phase C -- Historical Run Mode.** A dedicated run mode for historical (completed) wells. Historical runs evaluate a reduced check set appropriate for wells that are no longer actively drilling and export results to a flat CSV for analysis.

**Phase D -- Simplified Monday.com Publishing.** The Monday.com integration will be simplified to a single per-operator summary write after each active run, removing the per-check status columns and stale-rig detection logic that depended on the CSV input.

---

## Upcoming

### QC Trend Board
A historical tracking system that shows how operator scores change over time, surfacing improvement patterns and persistent gaps. Requires the Supabase results database from v0.9.0. See the [QC Trend Board](trend-board) page for details on what this will look like.

### Historical Well Expansion
Extending QC checks beyond the actively drilling wells to cover the platform's full inventory of approximately 15,600 wells. This would provide a comprehensive data quality baseline across the entire well database, identifying gaps that were previously invisible. The agent's current execution speed -- approximately one second per well -- makes this feasible for the first time.

### Recovery Recommendation Engine
An extension that not only identifies what data is missing, but suggests specific actions to fix it. Instead of just reporting "BHA components are incomplete," the system would indicate which specific BHA runs need attention and what fields are missing.

### Continuous Data Quality Monitoring
Moving from scheduled runs to continuous monitoring with anomaly detection. Rather than checking all wells at a fixed interval, the system would watch for data changes in real time and flag quality issues as they arise.

---

{: .note }
This roadmap describes the project's direction, not a fixed timeline. Priorities may shift based on business needs, and items may be reordered or adjusted as the project evolves.
