---
title: "File Drive"
layout: default
parent: The 29 Checks
nav_order: 7
---

# File Drive (Document Management)

*Last updated: 2026-04-07*

{: .text-purple-200}

**Category weight: 1 (lowest)** -- File Drive checks verify that supporting documents have been uploaded to the platform's document management area. These are supplementary to the structured data checked in other categories, which is why this category carries the lowest weight.

---

## What This Category Covers

The platform's File Drive is a document storage area organized into folders by document type. Operators are expected to upload supporting documents -- BHA reports from service companies, well plan PDFs, drilling program documents, and mud report files -- into the appropriate folders.

These uploads serve as backup documentation and as a way to share files that do not fit into the platform's structured data modules. While less critical than the operational data itself, document uploads support audit readiness and provide reference material for post-well reviews.

This category contains 4 checks, each verifying that a specific folder in the File Drive contains at least one uploaded file.

---

## Check Details

### Check 26: File Drive -- BHA Reports
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether the "BHA Reports" folder in the File Drive contains uploaded documents.

**Why it matters:** BHA reports from service companies provide detailed run data, tool performance summaries, and failure analyses. Uploading these to the File Drive ensures they are accessible alongside the platform's structured BHA data.

**Results:**
- **YES** -- Files are present in the BHA Reports folder
- **NO** -- The BHA Reports folder is empty or does not exist

---

### Check 27: File Drive -- Well Plans
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether the "Directional Plans" folder in the File Drive contains uploaded documents.

**Why it matters:** Well plan documents (directional plans, survey programs, anti-collision analyses) provide the detailed engineering context that supplements the structured well plan data on the platform. These documents are often the primary reference during directional drilling operations.

**Results:**
- **YES** -- Files are present in the Directional Plans folder
- **NO** -- The Directional Plans folder is empty or does not exist

---

### Check 28: File Drive -- Drilling Programs
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether the "Drilling Programs" folder in the File Drive contains uploaded documents.

**Why it matters:** The drilling program document is the comprehensive guide to how the well will be drilled. Having it uploaded to the File Drive ensures field personnel can access it from the platform.

**Results:**
- **YES** -- Files are present in the Drilling Programs folder
- **NO** -- The Drilling Programs folder is empty or does not exist
- **N/A** -- Skipped because Check 24 (Drilling Program) already returned YES, meaning the program exists natively on the platform

**Dependency:** This check depends on Check 24. If a drilling program is already present in the platform's structured data, a separate document upload is not required.

---

### Check 29: File Drive -- Mud Reports
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether the "Mud Reports" folder in the File Drive contains uploaded documents.

**Why it matters:** Mud report documents from the service company provide detailed fluid properties, treatment records, and recommendations that go beyond what is captured in the platform's structured mud reporting module.

**Results:**
- **YES** -- Files are present in the Mud Reports folder
- **NO** -- The Mud Reports folder is empty or does not exist
