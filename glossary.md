---
title: Glossary
layout: default
nav_order: 9
---

# Glossary

Terms used across the QC Automation Agent wiki, organized alphabetically. Domain terms are used freely throughout the documentation since the audience has oil and gas experience; this glossary provides definitions for readers who need a refresher or encounter unfamiliar project-specific and technical terms.

---

## A

**AFE (Authorization for Expenditure)**
The approved budget for drilling a well. AFE curves on the platform show planned cost and time versus actuals, enabling real-time budget tracking.

**Agent**
In this project, the software system that automatically performs QC checks. It follows a fixed sequence of steps (authenticate, inspect, score, publish) without human intervention during a run. It is not an AI that learns or makes subjective decisions -- it applies deterministic rules.

**Anti-Collision**
The process of ensuring a wellbore does not come dangerously close to nearby wells. Anti-collision analysis uses survey data and well plans to calculate separation distances.

**Audit Trail**
A structured log of every action the agent takes during a run. The audit trail records data requests, evaluation results, scores published, and any errors encountered, enabling full reconstruction of any run after the fact.

## B

**Basin**
A geological region where oil and gas deposits are found. Examples include the Permian Basin, Eagle Ford, and Bakken. The basin determines the local timezone and geomagnetic conditions relevant to survey corrections.

**BHA (Bottom Hole Assembly)**
The collection of tools attached to the bottom of the drill string, including the drill bit, motor, measurement tools, and stabilizers. BHAs are changed ("tripped") multiple times during a well's drilling life, and each configuration is recorded as a separate BHA run.

## C

**Casing**
Steel pipe cemented into the wellbore to maintain structural integrity and isolate different geological zones. Wells are typically drilled and cased in multiple stages (surface, intermediate, production).

**Category Weight**
A multiplier applied to a scoring category's average to reflect its relative importance. Higher weights mean that category has more influence on the overall score. See the [Scoring](scoring) page for the full weight table.

**Check Result**
The outcome of a single QC check. One of five values:
- **YES** (1.0) -- Data is present and meets criteria
- **NO** (0.0) -- Data is missing or fails criteria
- **PARTIAL** (0.5) -- Data is partially complete
- **N/A** (excluded) -- Check does not apply to this well
- **INCONCLUSIVE** (0.0) -- Agent could not determine the answer

## D

**Delta Detection**
The process of comparing current scores to previously published scores and only updating values that have changed. This reduces unnecessary writes to the QC board and makes it easy to see what changed between runs.

**Deterministic**
Producing the same output for the same input, every time. The agent's evaluation rules are deterministic -- there is no randomness, no machine learning inference, and no subjective judgment. If two runs see the same well data, they will always produce the same score.

**Deviation Survey**
See "Survey."

**Directional Drilling**
The practice of drilling a wellbore along a planned non-vertical path to reach a target location underground. Most modern wells are directionally drilled to access horizontal pay zones.

**Dull Grading**
A standardized assessment of drilling tool condition after a run. Dull grading records the wear, damage, and overall state of BHA components when they come out of the hole, using an industry-standard coding system.

## E

**EDM (Enhanced Directional Model)**
A geomagnetic reference file that provides the local magnetic field model for a specific location and time. EDM data is used to convert raw magnetic survey measurements into accurate wellbore positions.

## F

**File Drive**
The document management area of the cloud platform, organized into folders by document type. Operators upload supporting files (BHA reports, well plans, drilling programs, mud reports) to the appropriate folders.

**Formation Tops**
The measured depths at which the drill bit transitions between geological formations (rock layers). Recording formation tops on the platform supports geological correlation and geosteering decisions.

## G

**Geosteering**
The real-time adjustment of a well's trajectory based on geological data encountered while drilling. Geosteering helps keep the wellbore within the target formation for optimal production.

**Ground Truth**
The verified, correct answer against which the agent's results can be compared. During validation, agent results are compared against manually confirmed ground truth to ensure accuracy.

## I

**INCONCLUSIVE**
A check result meaning the agent could not retrieve enough information to make a determination. This is different from NO (data is definitively absent) -- INCONCLUSIVE means the agent could not check. Scored as 0.0.

## L

**LangGraph**
The orchestration framework used to manage the agent's execution flow. LangGraph provides a state machine that controls which steps run in what order, handles routing decisions, and maintains the state of a run. It is an open-source Python library built on LangChain.

## M

**Monday.com**
The project management platform where QC scores are published. The QC board on Monday.com displays one row per operator with their overall score and per-check results, providing a centralized dashboard for leadership and account managers.

**Mud Program**
A plan specifying the drilling fluid types, properties, and volumes to be used for each section of a well.

**Mud Report**
A daily report documenting the properties of the drilling fluid (mud) being used. Mud reports track fluid weight, viscosity, chemical additives, and other properties critical to wellbore stability and drilling efficiency.

## N

**Node**
In the context of the agent's orchestration, a node is a single step in the execution sequence (e.g., "select well," "process check," "publish results"). The agent's workflow is a graph of connected nodes.

**NPT (Non-Productive Time)**
Time during which drilling operations are halted due to equipment failure, weather, logistics, or other interruptions. Tracking NPT is essential for measuring operational efficiency.

## O

**Operator**
The company responsible for drilling and operating a well. In the context of this system, operators are the companies whose data quality is being assessed. Each operator may have many active wells.

**Orchestrator**
The component of the agent that controls the overall execution flow: reading the well list, selecting wells, dispatching checks, collecting results, and triggering scoring and publishing. Built on LangGraph.

## Q

**QC Check**
One of the 29 specific inspections the agent performs on each well. Each check asks a defined question about a data module (e.g., "Are surveys present below 300 feet?") and produces a deterministic result.

**QC Score**
The weighted quality score computed for an operator based on the results of all checks across all of their wells. Ranges from 0.0 (no data present) to 1.0 (all applicable checks passed). See [Scoring](scoring).

## R

**Rate Limiter**
A safety mechanism that spaces the agent's requests to the cloud platform, preventing it from sending too many requests too quickly. The rate limiter ensures the agent is a respectful consumer of platform resources.

**Rule Engine**
The component that applies deterministic evaluation logic to well data. The rule engine receives data, applies predefined rules, and outputs a check result. It does not know or care where the data came from -- only whether the data meets the criteria.

**Run Report**
A structured file generated after each agent run containing every well checked, every check result, category breakdowns, timing information, and scoring details. Serves as the permanent audit record of the run.

## S

**Spud**
The act of beginning to drill a well. "Spud date" is the date drilling commenced.

**State**
In the context of the agent's orchestration, state is the shared data structure that tracks everything about the current run: which well is being processed, what checks are queued, what results have been collected so far. The state is passed between nodes as the agent progresses through its workflow, and it is reset between wells to prevent data from one well affecting another.

**Survey**
A measurement of the wellbore's position underground, typically recording inclination (angle from vertical) and azimuth (compass direction) at a specific measured depth. Surveys are taken at regular intervals during drilling to track the well's actual path.

## T

**Tool Inventory**
A record of the drilling equipment assigned to a rig site, including drill pipe, measurement tools, motors, and other components.

**Trajectory**
The three-dimensional path of a wellbore through the earth, determined by survey measurements. The planned trajectory (well plan) and actual trajectory (survey data) are compared to ensure the well is on target.

**Trend Board**
A planned feature that will track QC score changes over time, showing whether operator data quality is improving, declining, or holding steady. See [QC Trend Board](trend-board).

## W

**Well Plan**
The designed trajectory for a wellbore, specifying the intended path from surface to target depth. The well plan serves as the reference against which actual survey data is compared.

**Well Program**
The comprehensive plan for drilling a well, including the well plan, casing design, mud program, BHA designs, and operational procedures for each section.

**WITSML (Wellsite Information Transfer Standard Markup Language)**
An industry-standard protocol for transmitting real-time drilling data from the rig site to remote locations. A WITSML connection on the platform means live operational data (depth, weight on bit, pump pressure, etc.) is being streamed from the rig.
