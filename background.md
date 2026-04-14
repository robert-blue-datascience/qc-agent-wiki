---
title: Background
layout: default
nav_order: 2
---

# Background

*Last updated: 2026-04-07*

The QC Automation Agent grew out of a real operational need: the manual quality control process for drilling data could not keep pace with the size of the portfolio it was responsible for. This page describes how that process worked, what its limitations were, and how the agent evolved into its current form.

---

## The Manual QC Process

Quality control for drilling data is a recurring task performed against a cloud-based drilling platform. The platform hosts operational data for every active well -- sensor readings, bottom hole assembly records, directional surveys, engineering plans, daily reports, and supporting documents. Each of these data modules has an expected state: certain fields should be populated, certain documents should be uploaded, and time-sensitive data should be current.

A QC reviewer would open each well on the platform, navigate to each module, and visually verify whether the data met expectations. The reviewer would then record the results and move on to the next well. For a portfolio of roughly 115 active wells, each requiring 29 module checks, this amounted to over 3,300 individual inspections per weekly cycle.

The process typically took 6 to 7 hours per week and demanded sustained attention to detail across hundreds of repetitive visual checks.

## Limitations at Scale

Three factors made the manual process increasingly difficult as the portfolio grew:

**Time.** At 6 to 7 hours per cycle, the process consumed a significant portion of a team member's week. Any growth in the well count would push the time requirement further. Checking more frequently than once per week was not practical.

**Human variability.** Manual inspection is inherently subjective. Two reviewers checking the same well on the same day might reach different conclusions about whether a partially populated module qualified as complete. Fatigue over the course of a multi-hour session compounded this variability.

**Coverage gaps.** A once-per-week cadence meant that data quality issues introduced on Monday might not be identified until the following week. For time-sensitive operational data, this delay could affect decision-making.

## The Decision to Automate

The decision to build an automated QC agent was driven by the recognition that the inspection task was fundamentally rule-based. Each of the 29 checks could be expressed as a clear question with a deterministic answer: "Is there survey data below 300 feet?" "Was the last mud report submitted within the past 24 hours?" "Does each bottom hole assembly have its components fully listed?"

If the rules could be codified, a software agent could apply them consistently, rapidly, and at whatever frequency was needed.

## The First Approach: Browser-Based Automation

The initial version of the agent mimicked the manual process programmatically. It used browser automation software to open the cloud platform, navigate to each module page for each well, read the data displayed on screen, and evaluate it against the predefined rules.

This approach had two important advantages: it required no special access beyond a standard user login, and it validated the same visual interface that human reviewers used, providing high confidence that the automation was checking the same data.

The browser-based agent was validated across multiple operators and hundreds of wells, confirming that the 29 check rules produced accurate, consistent results.

## The Migration to Direct API Access

As the agent scaled to larger portfolios, the browser-based approach encountered a practical ceiling. Rendering web pages, waiting for data to load visually, and navigating between modules consumed significant time. A full portfolio run of 111 wells took approximately 172 minutes, and longer sessions introduced reliability issues as browser resources accumulated.

The team discovered that the cloud platform provided a comprehensive set of data APIs -- the same interfaces that the platform's own web application used to populate its pages. By communicating with these APIs directly, the agent could retrieve the same data without the overhead of rendering a web browser.

The migration preserved all existing evaluation logic. A translation layer was built to reshape the API responses into the same format the rule engine had always expected, meaning the 29 checks themselves did not need to change. The result was a dramatically faster and more reliable system, while the scoring logic remained identical.

## Where Things Stand Today

The agent is in the final stages of its transition from browser-based inspection to direct API communication. All 29 evaluation rules, the scoring system, and the Monday.com publishing pipeline are operational. The data retrieval layer has been largely migrated to the API, with final integration and wiring work in progress.

The current focus is completing this migration and executing the first clean full-portfolio run through the new API pathway. The browser automation layer remains available as a fallback during the transition.
