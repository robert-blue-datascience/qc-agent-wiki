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

---

## Current Focus

### API Migration and First Full-Portfolio Run
The data extraction layer is being migrated from browser-based automation to direct API communication. The evaluation rules, scoring system, and adapters are complete. The remaining work is final integration wiring, after which the first full-portfolio run through the new API pathway will validate end-to-end performance at scale and provide the concrete numbers referenced on the [Results & Impact](results) page.

---

## Upcoming

### QC Trend Board
A historical tracking system that shows how operator scores change over time, surfacing improvement patterns and persistent gaps. See the [QC Trend Board](trend-board) page for details on what this will look like.

### Historical Well Expansion
Extending QC checks beyond the ~115 actively drilling wells to cover the platform's full inventory of approximately 15,600 wells. This would provide a comprehensive data quality baseline across the entire well database, identifying gaps that were previously invisible.

### Recovery Recommendation Engine
An extension that not only identifies what data is missing, but suggests specific actions to fix it. Instead of just reporting "BHA components are incomplete," the system would indicate which specific BHA runs need attention and what fields are missing.

### Continuous Data Quality Monitoring
Moving from scheduled runs to continuous monitoring with anomaly detection. Rather than checking all wells at a fixed interval, the system would watch for data changes in real time and flag quality issues as they arise.

---

{: .note }
This roadmap describes the project's direction, not a fixed timeline. Priorities may shift based on business needs, and items may be reordered or adjusted as the project evolves.
