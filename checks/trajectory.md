---
title: "Trajectory and Anti-Collision"
layout: default
parent: The 29 Checks
nav_order: 2
---

# Trajectory and Anti-Collision

*Last updated: 2026-04-07*

{: .text-purple-200}

**Category weight: 5 (highest)** -- Trajectory data tells the team where the wellbore is and where it is going. Accurate survey data and well plans are fundamental to safe, efficient directional drilling and collision avoidance.

---

## What This Category Covers

Directional drilling requires continuous knowledge of the wellbore's position underground. Survey measurements taken at intervals during drilling build a picture of the well's actual path. This data is compared against the planned trajectory to ensure the well stays on target and does not approach neighboring wellbores.

This category contains 5 checks that verify the presence and completeness of survey data, survey programs, correction parameters, geomagnetic reference files, and well plans.

---

## Check Details

### Check 2: Surveys
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether survey data exists for the well and extends below a minimum depth threshold (300 feet).

**Why it matters:** Surveys are the primary record of where the wellbore actually is. A well with no survey data -- or data that only covers the very top of the hole -- has a critical gap in its positional record. The 300-foot threshold ensures that surveys cover more than just the surface section.

**Results:**
- **YES** -- Survey data exists below the depth threshold
- **NO** -- No survey data, or data does not reach the threshold depth
- **INCONCLUSIVE** -- Survey data could not be retrieved

---

### Check 3: Survey Program
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether a survey program has been defined for the well.

**Why it matters:** A survey program specifies the type of survey tools to be used, the intervals at which surveys will be taken, and the accuracy requirements for each section of the well. Without a survey program, there is no documented plan for how the well's position will be tracked.

**Results:**
- **YES** -- A survey program is defined
- **NO** -- No survey program found

---

### Check 4: Survey Corrections
{: .d-inline-block}
Bonus
{: .label .label-green}

**What it checks:** Whether magnetic correction parameters have been applied to the survey data.

**Why it matters:** Raw magnetic survey measurements are affected by local magnetic interference, crustal anomalies, and solar activity. Applying correction models (such as IFR or MWD corrections) improves the accuracy of the calculated wellbore position. This is especially important in areas with high well density where collision risk is elevated.

**This is an additive (bonus) check.** Correction data improves the score, but its absence does not penalize the operator. Not all wells require corrections depending on their location and drilling method.

**Results:**
- **YES** -- Correction parameters are applied
- **N/A** -- Not applicable for this well

---

### Check 8: EDM Files
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether geomagnetic reference data (EDM -- Enhanced Directional Model) files have been uploaded for the well.

**Why it matters:** EDM files provide the local magnetic field model used to convert raw survey tool readings into accurate wellbore positions. Without the correct geomagnetic reference, survey calculations may contain systematic errors.

**Results:**
- **YES** -- EDM files are present
- **NO** -- No EDM files found

**Dependency:** If this check returns YES, Check 9 (Well Plans) returns N/A, because EDM data provides the geomagnetic context that would otherwise require a separately loaded well plan.

---

### Check 9: Well Plans
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether a definitive well plan is loaded for the well.

**Why it matters:** The well plan defines the intended trajectory -- the designed path the wellbore should follow. It is the reference against which actual survey data is compared. Without a well plan, there is no baseline to determine whether the well is on target.

**Results:**
- **YES** -- A definitive well plan is loaded
- **NO** -- No definitive well plan found
- **N/A** -- Skipped because Check 8 (EDM Files) already returned YES

**Dependency:** This check depends on Check 8. If EDM data is present, this check returns N/A.
