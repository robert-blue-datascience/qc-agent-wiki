---
title: QC Trend Board
layout: default
nav_order: 7
---

# QC Trend Board

{: .coming_soon }
This feature is on the roadmap and is not yet built. This page describes the intended purpose and design direction.

---

## Purpose

The QC Trend Board will track how operator data quality scores change over time. While the current QC board shows a snapshot -- "here is your score right now" -- the Trend Board will show the trajectory: "here is how your score has changed over the past weeks and months."

## What It Will Show

The Trend Board is designed to surface patterns in data quality improvement:

- **Score trends by operator** -- Is an operator's data quality improving, declining, or holding steady?
- **Check-level transitions** -- Which specific checks have moved from NO to YES? Which remain persistently failed?
- **Category-level progress** -- Are improvements concentrated in one category, or are they broad-based?
- **Portfolio-wide patterns** -- Are all operators trending in the same direction, or are there outliers?

## Why It Matters

The current QC board answers the question "what is broken?" The Trend Board is designed to answer the more constructive question: **"how is it getting fixed?"**

This distinction matters for leadership conversations. When an operator's score is low, the natural question is whether anything is being done about it. The Trend Board provides the evidence: a rising score means data gaps are being closed, even if the absolute number has not yet reached the target.

For account managers, trend data supports more productive operator conversations. Rather than pointing out deficiencies, they can highlight improvement: "Your trajectory data completeness has improved from 60% to 85% over the past month."

## Timeline

The Trend Board depends on two prerequisites:

1. **Consistent, frequent scoring.** The API migration enables the daily run frequency needed to build meaningful trend data. A single weekly data point per operator limits the granularity of any trend analysis.

2. **Historical score storage.** The current system publishes the latest score to Monday.com but does not maintain a time series. The Trend Board will require a mechanism for storing and querying historical scores.

See the [Roadmap](roadmap) page for where this fits in the broader project plan.
