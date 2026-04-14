---
title: "Engineering"
layout: default
parent: The 29 Checks
nav_order: 5
---

# Engineering

*Last updated: 2026-04-07*

{: .text-purple-200}

**Category weight: 2** -- Engineering documents represent the pre-drill planning work that guides operations. While essential for well planning, these documents are typically established before drilling begins and change less frequently than operational data, which is reflected in the lower weight.

---

## What This Category Covers

Before a well is drilled, engineers create detailed designs and plans: wellbore geometries, casing programs, scenario analyses, and operational roadmaps. Loading these documents onto the platform ensures the drilling team has access to the engineering intent alongside the real-time operational data.

This category contains 3 checks covering engineering roadmaps, wellbore designs, and scenario data.

---

## Check Details

### Check 21: Roadmaps
{: .d-inline-block}
Bonus
{: .label .label-green}

**What it checks:** Whether engineering roadmaps are present for the well.

**Why it matters:** Roadmaps provide a high-level operational plan, outlining the sequence of activities and key milestones for the well. Their presence on the platform gives the broader team visibility into the planned progression of operations.

**This is an additive (bonus) check.** Having roadmaps improves the score, but their absence does not penalize the operator.

**Results:**
- **YES** -- Roadmaps are present
- **N/A** -- No roadmaps (not penalized)
- **INCONCLUSIVE** -- The agent could not retrieve enough information to determine roadmap status

---

### Check 22: Wellbore Diagrams (Wellbore Designs)
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether a definitive wellbore design is loaded for the well.

**Why it matters:** A wellbore design defines the physical geometry of the well -- casing sizes, setting depths, hole sizes, and the overall well architecture. It is the engineering blueprint that the drilling program is built around. Without a definitive design on the platform, there is no authoritative reference for the well's intended construction.

The agent specifically looks for a "definitive" (principal) design variant, distinguishing it from preliminary or conceptual designs that may also exist.

**Results:**
- **YES** -- A definitive wellbore design is loaded
- **NO** -- No definitive design found

---

### Check 23: Engineering Scenarios
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether engineering scenario data is present for the well.

**Why it matters:** Engineering scenarios model different operational possibilities -- what-if analyses for different approaches to drilling a section, contingency plans for potential problems, or alternative casing designs. Their presence on the platform indicates that pre-drill planning included scenario analysis.

**Results:**
- **YES** -- Engineering scenarios are present
- **NO** -- No engineering scenario data found
