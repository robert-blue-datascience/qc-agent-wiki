---
title: "Tool Inventory and Tracking"
layout: default
parent: The 29 Checks
nav_order: 6
---

# Tool Inventory and Tracking
{: .text-purple-200}

**Category weight: 2** -- Tool inventory data tracks the equipment assigned to the rig. While important for asset management and logistics, tool inventory changes less frequently than operational drilling data, which is reflected in its weight.

---

## What This Category Covers

Drilling operations rely on a large inventory of specialized equipment: drill pipe, measurement-while-drilling tools, motors, stabilizers, and other components. The platform provides modules for tracking which tools are at the rig site (rig inventory) and what tools are available in the broader fleet (tool catalog).

This category contains 2 checks that verify whether inventory and catalog data has been populated.

---

## Check Details

### Check 16: Rig Inventory Data
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether rig inventory records exist for the well.

**Why it matters:** Rig inventory data documents what equipment is physically at the well site. This information supports logistics planning, tool tracking, and ensures the right equipment is available when needed. Without rig inventory data on the platform, tool tracking must be managed manually through spreadsheets or phone calls.

**Results:**
- **YES** -- Rig inventory data is present
- **NO** -- No rig inventory data found

---

### Check 17: Tool Catalog Data
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether tool catalog entries are present for the well.

**Why it matters:** The tool catalog provides a standardized reference for the equipment fleet, including specifications, serial numbers, and availability status. When populated, it allows the team to look up tool details, check availability across rigs, and plan equipment moves efficiently.

**Results:**
- **YES** -- Tool catalog data is present
- **NO** -- No tool catalog data found
