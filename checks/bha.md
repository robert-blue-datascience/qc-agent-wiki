---
title: "BHA (Bottom Hole Assembly)"
layout: default
parent: The 29 Checks
nav_order: 1
---

# BHA (Bottom Hole Assembly)

*Last updated: 2026-04-07*

{: .text-purple-200}

**Category weight: 5 (highest)** -- BHA data is among the most operationally critical information on the platform. An accurate, complete BHA record is essential for drilling optimization, failure analysis, and regulatory compliance.

---

## What This Category Covers

A Bottom Hole Assembly (BHA) is the collection of tools and components attached to the bottom of the drill string -- the physical equipment that does the actual drilling. Each time the toolstring is changed (a "trip"), a new BHA run is recorded on the platform. A typical well may have anywhere from 3 to 15 BHA runs over its drilling life.

Complete BHA records allow engineers to understand what equipment was in the hole at any point during operations, analyze tool performance, investigate failures, and plan future runs. Missing or incomplete BHA data creates blind spots in the operational record.

This category contains 6 checks that collectively verify the completeness of BHA documentation from initial entry through post-run grading.

---

## Check Details

### Check 10: BHA Distribution
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether at least one BHA record exists for the well.

**Why it matters:** A well with no BHA records has no documentation of the equipment used to drill it. This is the most basic BHA completeness check -- everything else in this category depends on BHA records existing first.

**Results:**
- **YES** -- One or more BHA records exist
- **NO** -- No BHA records found

---

### Check 11: BHA Comments
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether each BHA run has operator comments describing what happened during that run.

**Why it matters:** Comments provide the narrative context that raw data cannot. They record why a trip was made, what issues were encountered, and what decisions were taken. Without comments, the BHA record is a list of equipment with no operational context.

**Results:**
- **YES** -- All BHA runs have comments
- **PARTIAL** -- Some BHA runs have comments, others do not
- **NO** -- No BHA runs have comments

---

### Check 12: BHA Uploads
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether each BHA run has supporting documents (files) attached.

**Why it matters:** BHA uploads typically include run sheets, service company reports, and other documentation that supplements the digital record. These attachments serve as primary-source evidence for audits and post-well reviews.

**Results:**
- **YES** -- All BHA runs have uploads
- **PARTIAL** -- Some BHA runs have uploads, others do not
- **NO** -- No BHA runs have uploads

---

### Check 13: BHA Failure Reports
{: .d-inline-block}
Bonus
{: .label .label-green}

**What it checks:** Whether failure reports have been filed for BHA runs where a failure occurred.

**Why it matters:** Tracking equipment failures is essential for reliability analysis and future well planning. When a tool fails downhole, documenting it helps the team avoid repeating the same failure.

**This is an additive (bonus) check.** The presence of failure reports improves the score, but their absence does not penalize the operator. Not every BHA run involves a failure, so this check rewards thorough documentation rather than requiring it universally.

**Results:**
- **YES** -- Failure flags are recorded where applicable
- **N/A** -- No failures flagged (nothing to report)
- **INCONCLUSIVE** -- The agent could not retrieve enough information to determine whether failure reports apply

---

### Check 14: BHA Component Completeness
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether each BHA run has its full component list entered -- the individual tools, subs, and equipment that make up the assembly.

**Why it matters:** A BHA record without its components is like a parts list with no parts. Engineers need to know exactly what was in the hole to analyze performance, plan offsets, and investigate incidents. Component-level detail is the foundation of BHA data quality.

**Results:**
- **YES** -- All BHA runs have components listed
- **PARTIAL** -- Some BHA runs have components, others do not
- **NO** -- No BHA runs have components listed

---

### Check 15: Post-Run BHA Grading
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether completed (non-active) BHA runs have dull grading recorded. Dull grading is the standardized assessment of tool condition after a run -- how worn or damaged the equipment was when it came out of the hole.

**Why it matters:** Dull grading is the industry-standard method for evaluating tool wear and performance. Without it, the team has no record of tool condition at the end of each run, making it difficult to predict tool life, optimize run lengths, or hold service companies accountable for equipment quality.

**Results:**
- **YES** -- All completed BHA runs have dull grading
- **PARTIAL** -- Some completed runs have grading, others do not
- **NO** -- No completed BHA runs have dull grading
- **INCONCLUSIVE** -- The agent could not determine grading status (e.g., data retrieval issue)
