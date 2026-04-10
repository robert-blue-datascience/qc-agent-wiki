---
title: Roadmap
layout: default
nav_order: 8
---

# Roadmap

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

### Concurrent Check Execution (v0.8.0)
All 29 checks for a single well now run in parallel rather than sequentially. A two-wave execution model (independent checks first, dependency-bound checks second) preserves correctness while allowing maximum parallelism. Per-well and run-level circuit breakers protect against cascading timeouts. Request coalescing ensures shared API endpoints are fetched once per well regardless of how many checks need them.

---

## Current Focus

### v0.8.1 -- Cleanup and Architectural Correctness
A set of backlog items identified during v0.8.0 development that improve architectural cleanliness before the v0.9.0 graph restructure:

- Refactor run-level circuit breaker drain out of `process_check_node` (check-execution nodes should not modify routing state)
- Remove stale `min_page_delay_seconds` field from the rate limiter config (unused since the PLATFORM bucket was removed)
- Remove stale `current_check` field from the orchestrator state (not written in the concurrent model)
- Disambiguate duplicate `API_REQUEST_SUCCESS` log events emitted from both the orchestrator and the API client
- Add test coverage for multi-fetch strategy lambda correctness

---

## Upcoming

### QC Trend Board
A historical tracking system that shows how operator scores change over time, surfacing improvement patterns and persistent gaps. See the [QC Trend Board](trend-board) page for details on what this will look like.

### Historical Well Expansion
Extending QC checks beyond the actively drilling wells to cover the platform's full inventory of approximately 15,600 wells. This would provide a comprehensive data quality baseline across the entire well database, identifying gaps that were previously invisible.

### Recovery Recommendation Engine
An extension that not only identifies what data is missing, but suggests specific actions to fix it. Instead of just reporting "BHA components are incomplete," the system would indicate which specific BHA runs need attention and what fields are missing.

### Continuous Data Quality Monitoring
Moving from scheduled runs to continuous monitoring with anomaly detection. Rather than checking all wells at a fixed interval, the system would watch for data changes in real time and flag quality issues as they arise.

---

{: .note }
This roadmap describes the project's direction, not a fixed timeline. Priorities may shift based on business needs, and items may be reordered or adjusted as the project evolves.
