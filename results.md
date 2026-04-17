---
title: Results & Impact
layout: default
nav_order: 6
---

# Results & Impact

*Last updated: 2026-04-16*

This page compares the manual QC process to the automated agent, showing the concrete process improvements the automation delivers. For background on why the agent was built, see [Background](background). For how scores are calculated, see [Scoring](scoring). For what is coming next, see the [Roadmap](roadmap).

---

## The Manual Baseline

Before the agent, quality control was performed by a team member manually navigating the cloud platform. The numbers below reflect the actual manual workflow:

| Metric | Manual Process |
|---|---|
| **Wells checked per cycle** | ~115 |
| **Checks per well** | 29 |
| **Total inspections per cycle** | ~3,335 |
| **Time per cycle** | 6-7 hours |
| **Frequency** | Once per week |
| **Consistency** | Variable (human judgment, fatigue, session drift) |

At this pace, data quality issues could persist for up to a week before being identified. Growth in the well count would push the time requirement further, and increasing frequency beyond weekly was not practical.

---

## Agent Performance

### April 9, 2026 -- First Full Portfolio Run (API Path)

The first clean full-portfolio run through the direct API path completed on April 9, 2026. This replaced the earlier browser-based approach that had produced unreliable scores due to session degradation. Checks ran sequentially within each well.

| Metric | April 9 Run |
|---|---|
| **Operators** | 20 |
| **Wells checked** | 106 of 107 (1 unreachable) |
| **Total checks executed** | 3,045 |
| **Avg time per well** | ~1m 47s |
| **Total run time** | ~3h 9m |
| **Consistency** | Deterministic (same data = same result, every time) |

---

### April 13, 2026 -- First Concurrent Run (v0.8.0)

Version 0.8.0 introduced parallel check execution within each well. All 29 checks for a single well now run simultaneously rather than one at a time. The results from the first concurrent full-portfolio run:

| Metric | April 13 Run |
|---|---|
| **Operators** | 19 |
| **Wells checked** | 106 |
| **Total checks executed** | 3,074 |
| **Avg time per well** | ~1s |
| **Total run time** | 2m 53s |
| **Portfolio score** | 61.8% |
| **Unreachable wells** | 0 |
| **Consistency** | Deterministic (same data = same result, every time) |

The total run time dropped from approximately 3 hours 9 minutes to 2 minutes 53 seconds -- a roughly 65x improvement -- with no change to check logic or result correctness.

Selected operator scores from that run (operators anonymized):

| Operator | Score | Wells |
|---|---|---|
| Operator A | 87.1% | 3 |
| Operator B | 83.3% | 1 |
| Operator C | 75.4% | 2 |
| Operator D | 72.8% | 5 |
| Operator E | 71.8% | 7 |
| Operator F | 70.2% | 7 |
| Operator G | 66.4% | 13 |
| Operator H | 63.6% | 1 |
| Operator I | 62.2% | 10 |
| Operator J | 59.8% | 3 |
| Operator K | 59.2% | 15 |
| Operator L | 58.7% | 1 |
| Operator M | 56.8% | 2 |
| Operator N | 52.9% | 6 |
| Operator O | 51.9% | 2 |
| Operator P | 50.6% | 8 |
| Operator Q | 49.4% | 13 |
| Operator R | 49.1% | 3 |
| Operator S | 33.4% | 4 |

---

## Key Improvements

### Process Reliability

The most significant improvement is not speed -- it is reliability. The browser-based approach degraded silently after approximately 45 minutes of runtime. DOM elements went stale, scores were computed against corrupted data, and 111 incorrect scores were published on April 3, 2026 before the issue was diagnosed. The direct API path has no session state to degrade. Each API call is independent, and a failure on one check produces an INCONCLUSIVE result for that check only -- it does not contaminate any other check or well.

### Consistency

Every run of the agent produces identical results for identical data. There is no variability from reviewer fatigue, subjective interpretation, or software session drift. Operators receive fair, uniform assessment regardless of when the check runs or who initiates it.

### Frequency

With a full-portfolio run now completing in under 3 minutes, the constraint on frequency has effectively disappeared. The team can run QC checks multiple times per day with no meaningful overhead. Data quality issues that previously took a week to surface can now be identified within the hour.

### Coverage

The agent checks every well in the input file for every one of the 29 modules. There is no skipping, no shortcutting, and no "I'll check that one next time." If a well is in the list, it gets fully evaluated.

---

## v0.9.0 -- April 16, 2026

Version 0.9.0 delivered two capabilities that extend what the agent can do:

**Automated well discovery.** The manually maintained input spreadsheet has been replaced entirely. The agent now queries the platform directly to find active wells for each operator, removing the risk of missed rigs and the overhead of list maintenance.

**Historical well evaluation.** The agent can now run a separate historical mode against completed wells, using 13 checks tailored to data that remains relevant after drilling has finished. Results are written to the same database as active-well runs, enabling cross-operator comparison across both active and completed portfolios.

**Supabase as score of record.** Per-well results are now written to a persistent database immediately after each well is evaluated. The Monday.com board retains a summary row per operator, but the authoritative record lives in the database.

## What Comes Next for Scale

With automated discovery and a persistent database in place, the focus shifts to broadening coverage and deepening insight:

**Full historical inventory.** The platform contains thousands of wells spanning years of drilling history. The agent's execution speed and historical mode make it feasible to evaluate the full inventory -- a task that was previously impossible at any practical frequency.

**Trend analysis.** With per-well scores accumulating in the database over time, the foundation exists for tracking score trends by operator, basin, and check category across runs.

---

## Scaling Potential

**Increased check scope.** The current 29 checks cover the most important data modules. As the platform adds new features, additional checks can be added to the agent without increasing the time burden proportionally.

**Freed team capacity.** Time previously spent on manual checks can be redirected toward investigating root causes of data quality issues, working with operators on improvement, and developing new quality metrics -- higher-value work that manual data checking was displacing.

---

## Lessons Learned

The path from manual process to automated agent was iterative:

1. **Start with what works.** The first version mimicked the manual process using browser automation, proving that the 29 rules could be codified and applied consistently.

2. **Find the ceiling.** Running at scale revealed the practical limits of the browser approach -- not a failure, but a natural point of growth.

3. **Improve the foundation.** Migrating to direct API communication preserved everything that worked (the rules, the scoring, the reporting) while eliminating session degradation.

4. **Remove the bottleneck.** With a reliable foundation in place, concurrent execution reduced per-well time from ~107 seconds to ~1 second -- a change that transforms what is possible in terms of frequency and scope.

This cycle -- build, validate, identify limits, improve -- reflects the iterative approach that continues to guide the project's development.
