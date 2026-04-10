---
title: "Drilling Reports"
layout: default
parent: The 29 Checks
nav_order: 4
---

# Drilling Reports
{: .text-purple-200}

**Category weight: 3** -- Drilling reports are the daily operational record of what happened at the well. Timely, complete reporting keeps the entire team informed and provides the documentation needed for post-well analysis.

---

## What This Category Covers

During active drilling, field personnel submit daily reports documenting operations, mud properties, formation encounters, and program updates. These reports are the primary communication channel between the rig and the office, and they form the permanent record of day-to-day operations.

This category contains 5 checks covering mud reports, mud programs, formation data, drilling programs, and cost curves.

---

## Check Details

### Check 18: Mud Report Distribution
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether the most recent mud report was submitted within the past 24 hours.

**Why it matters:** Mud reports document the properties of the drilling fluid, which is critical for wellbore stability, pressure control, and cuttings removal. A mud report older than 24 hours on an actively drilling well suggests that reporting has lapsed, meaning the office may not have current information about downhole conditions.

**Results:**
- **YES** -- A mud report was submitted within the past 24 hours
- **NO** -- The most recent mud report is older than 24 hours, or no reports exist
- **INCONCLUSIVE** -- Report timestamps could not be determined

---

### Check 19: Mud Program
{: .d-inline-block}
Bonus
{: .label .label-green}

**What it checks:** Whether a mud program has been defined for the well.

**Why it matters:** A mud program specifies the planned drilling fluid types, properties, and volumes for each section of the well. It provides the reference point for evaluating whether actual mud properties are within design parameters.

**This is an additive (bonus) check.** Having a mud program improves the score, but its absence does not penalize the operator.

**Results:**
- **YES** -- A mud program is defined
- **N/A** -- No mud program (not penalized)
- **INCONCLUSIVE** -- The agent could not retrieve enough information to determine mud program status

---

### Check 20: Formation Tops
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether formation top markers have been entered for the well.

**Why it matters:** Formation tops identify the depths at which the drill bit transitions between geological layers. This data is essential for correlation with offset wells, geosteering decisions, and geological interpretation. Missing formation tops means the geological context of the wellbore is undocumented on the platform.

**Results:**
- **YES** -- Formation tops are present
- **NO** -- No formation tops found

---

### Check 24: Drilling Program (AI Drill Prog)
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether a drilling program is present on the platform.

**Why it matters:** The drilling program is the master plan for how the well will be drilled -- including casing points, mud weights, BHA designs, and operational parameters for each section. Its presence on the platform ensures the team has a shared reference for planned operations.

**Results:**
- **YES** -- A drilling program is present
- **NO** -- No drilling program found

**Dependency:** If this check returns YES, Check 28 (File Drive: Drilling Programs) returns N/A, because the program exists natively on the platform and does not need a separate document upload.

---

### Check 25: AFE Curves
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether Authorization for Expenditure (AFE) curves are loaded for the well.

**Why it matters:** AFE curves represent the budgeted cost and timeline for the well. When loaded on the platform alongside actual cost data, they enable real-time tracking of whether the well is on budget and on schedule. Without AFE curves, cost tracking lacks its reference baseline.

**Results:**
- **YES** -- AFE curves are present
- **NO** -- No AFE curves found
