---
title: "Live Data"
layout: default
parent: The 29 Checks
nav_order: 3
---

# Live Data
{: .text-purple-200}

**Category weight: 4** -- Live data connections provide real-time visibility into drilling operations. An active, current data feed means the team can monitor what is happening at the rig right now, rather than waiting for reports.

---

## What This Category Covers

Modern drilling platforms support real-time data streaming from rig-site sensors to the cloud. This data includes parameters like weight on bit, rate of penetration, pump pressure, and depth -- transmitted continuously as drilling progresses.

This category contains 4 checks that verify whether real-time connections are active and whether supporting real-time modules (geosteering, non-productive time tracking, and cost analysis) are being utilized.

---

## Check Details

### Check 1: WITSML Connected
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether the real-time data feed (WITSML connection) is active and transmitting current data.

**Why it matters:** WITSML (Wellsite Information Transfer Standard Markup Language) is the industry-standard protocol for transmitting real-time drilling data from the rig to the cloud. An active connection means the platform has up-to-the-minute operational data. A stale or disconnected feed means the team is working with outdated information.

The agent checks not just whether a WITSML connection exists, but whether the most recent data is current. If the last transmitted data point is not recent, the connection is considered stale. The agent accounts for timezone differences across basins, so a well in a different time zone is not incorrectly flagged simply because of the clock offset.

**Results:**
- **YES** -- WITSML connection is active and data is current
- **NO** -- No connection, or data is stale beyond the threshold
- **INCONCLUSIVE** -- Connection status could not be determined

---

### Check 5: Live Geosteering
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether a geosteering interpretation is actively linked to the well.

**Why it matters:** Geosteering is the practice of adjusting the well's trajectory in real time based on geological data encountered while drilling. An active geosteering link means the directional drilling team has access to real-time geological interpretation, enabling them to keep the wellbore in the target formation.

**Results:**
- **YES** -- A geosteering interpretation is linked
- **NO** -- No geosteering interpretation found

---

### Check 6: NPT Tracking
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether non-productive time (NPT) events are being recorded for the well.

**Why it matters:** NPT represents time during which drilling operations are halted due to equipment failures, weather, logistics delays, or other interruptions. Tracking NPT is essential for identifying efficiency problems, benchmarking performance, and controlling costs.

**Results:**
- **YES** -- NPT tracking data is present
- **NO** -- No NPT data found

---

### Check 7: Cost Analysis
{: .d-inline-block}
Required
{: .label .label-blue}

**What it checks:** Whether cost tracking data is present for the well.

**Why it matters:** Cost analysis data allows the team to track actual spending against budget (the AFE -- Authorization for Expenditure). Without cost data on the platform, budget tracking must be done manually outside the system, creating a gap in the integrated operational picture.

**Results:**
- **YES** -- Cost analysis data is present
- **NO** -- No cost data found
