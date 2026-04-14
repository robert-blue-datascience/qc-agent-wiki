---
title: The 29 Checks
layout: default
nav_order: 4
has_children: true
---

# The 29 Checks

*Last updated: 2026-04-07*

The QC Automation Agent evaluates 29 distinct checks for every well it processes. Each check asks a specific question about a well's data: Is a particular record present? Is it complete? Is it current? The answer to each question is always one of five results: YES, NO, PARTIAL, N/A, or INCONCLUSIVE.

The checks are organized into 7 scoring categories, each reflecting a different area of drilling data management. Categories that represent more operationally critical data carry greater weight in the overall score.

---

## Check Directory

### BHA (Bottom Hole Assembly) -- Weight: 5
{: .text-purple-200}

The most heavily weighted category. Covers the completeness and documentation of bottom hole assemblies, the physical tool strings used to drill each section of a well.

| # | Check | What It Looks For |
|---|---|---|
| 10 | BHA Distribution | At least one BHA record exists for the well |
| 11 | BHA Comments | Each BHA has operator comments describing its run |
| 12 | BHA Uploads | Each BHA has supporting documents attached |
| 13 | BHA Failure Reports | Failure reports are filed when applicable (bonus) |
| 14 | BHA Component Completeness | Each BHA has its full component list entered |
| 15 | Post-Run BHA Grading | Completed BHAs have dull grading recorded |

[View full details](checks/bha)

---

### Trajectory and Anti-Collision -- Weight: 5
{: .text-purple-200}

Equally weighted with BHA. Covers directional survey data, survey programs, and well planning -- essential for knowing where the wellbore is and where it is going.

| # | Check | What It Looks For |
|---|---|---|
| 2 | Surveys | Survey data exists and extends below a minimum depth |
| 3 | Survey Program | A survey program has been defined for the well |
| 4 | Survey Corrections | Correction parameters are applied to surveys (bonus) |
| 8 | EDM Files | Geomagnetic reference data is uploaded |
| 9 | Well Plans | A definitive well plan is loaded for the well |

[View full details](checks/trajectory)

---

### Live Data -- Weight: 4
{: .text-purple-200}

Covers real-time data connections that provide continuous visibility into drilling operations.

| # | Check | What It Looks For |
|---|---|---|
| 1 | WITSML Connected | The real-time data feed is active and transmitting current data |
| 5 | Live Geosteering | A geosteering interpretation is actively linked |
| 6 | NPT Tracking | Non-productive time events are being recorded |
| 7 | Cost Analysis | Cost tracking data is present |

[View full details](checks/live-data)

---

### Drilling Reports -- Weight: 3
{: .text-purple-200}

Covers daily operational reporting, mud reports, and related documentation.

| # | Check | What It Looks For |
|---|---|---|
| 18 | Mud Report Distribution | The most recent mud report was submitted within 24 hours |
| 19 | Mud Program | A mud program is defined for the well (bonus) |
| 20 | Formation Tops | Formation top markers have been entered |
| 24 | Drilling Program | An AI-generated drilling program is present |
| 25 | AFE Curves | Authorization for Expenditure curves are loaded |

[View full details](checks/drilling-reports)

---

### Engineering -- Weight: 2
{: .text-purple-200}

Covers planning and engineering documentation.

| # | Check | What It Looks For |
|---|---|---|
| 21 | Roadmaps | Engineering roadmaps are present (bonus) |
| 22 | Wellbore Diagrams | A definitive wellbore design is loaded |
| 23 | Engineering Scenarios | Engineering scenario data is present |

[View full details](checks/engineering)

---

### Tool Inventory and Tracking -- Weight: 2
{: .text-purple-200}

Covers equipment and tool records.

| # | Check | What It Looks For |
|---|---|---|
| 16 | Rig Inventory Data | Rig inventory records exist for the well |
| 17 | Tool Catalog Data | Tool catalog entries are present |

[View full details](checks/tool-inventory)

---

### File Drive -- Weight: 1
{: .text-purple-200}

Covers document uploads in the platform's file management area. The lowest-weighted category, reflecting that these are supporting documents rather than primary operational data.

| # | Check | What It Looks For |
|---|---|---|
| 26 | File Drive: BHA Reports | BHA report documents are uploaded |
| 27 | File Drive: Well Plans | Well plan documents are uploaded |
| 28 | File Drive: Drilling Programs | Drilling program documents are uploaded |
| 29 | File Drive: Mud Reports | Mud report documents are uploaded |

[View full details](checks/file-drive)

---

## Special Check Behaviors

**Bonus checks (additive).** Checks 4, 13, 19, and 21 are "bonus" checks. Their presence adds to the score, but their absence does not penalize the operator. These represent best practices that go beyond the baseline expectation.

**Dependencies.** Some checks have dependencies on others:
- If Check 8 (EDM Files) is YES, then Check 9 (Well Plans) returns N/A, because EDM data supersedes the need for a separate well plan in this context.
- If Check 24 (Drilling Program) is YES, then Check 28 (File Drive: Drilling Programs) returns N/A, because the program exists in the platform and does not need to be separately uploaded.
