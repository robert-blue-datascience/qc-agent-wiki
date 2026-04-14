# CONTENT_MAP.md
<!-- Excluded from Jekyll build. This file is read by wiki-guide, wiki-technical, and wiki-sweep commands. -->

Single source of truth for the QC Automation Agent wiki. Every doc command reads this file before generating content.

---

## Tone Definitions

### guide
Third person, present tense, plain language, high-school reading level. Domain terms (BHA, WITSML, survey) used freely. No code, file paths, function names, or YAML references. Business impact framing. Fictitious examples only. No em-dashes.

### technical
Third person, present tense. Written for an engineer who knows Python but has never seen this codebase. Includes function signatures, file paths, and design rationale. References ADRs. Links back to Tier 1 for business context. No em-dashes.

---

## Diagram Standards

- **Tool:** Mermaid for process flows, architecture diagrams, and decision trees. Static images only where Mermaid cannot achieve required quality.
- **Color palette (consistent across all diagrams):**
  - Primary action: `fill:#4a90d9,stroke:#2c5aa0,color:#fff`
  - Success/auth: `fill:#5ba585,stroke:#3d7a5e,color:#fff`
  - Processing: `fill:#e8a838,stroke:#b8842c,color:#fff`
  - Evaluation: `fill:#d96a4a,stroke:#a84e35,color:#fff`
  - Output/publish: `fill:#7b68ae,stroke:#5a4d82,color:#fff`
  - Decision/neutral: `fill:#f5f5f5,stroke:#999,color:#333`
- **Accessibility:** Every Mermaid block must include a brief text summary above or below.

---

## Cross-Link Rules

1. Every Tier 1 category page (checks/*) links to its Tier 2 companion when one exists
2. Every Tier 2 technical doc opens with a bridge paragraph linking to the relevant Tier 1 page
3. Glossary terms are linked on first use per page (not every occurrence)
4. Roadmap items link to relevant completed milestone pages
5. The 29 Checks hub links to all 7 category sub-pages
6. Scoring page links to the checks hub and the glossary
7. Results page links to background (manual baseline) and scoring (how scores work)

---

## Page Registry

### Tier 1: Program Guide

| File | Title | Nav Order | Parent | Tone | Audience | Owner | Required Cross-Links |
|---|---|---|---|---|---|---|---|
| index.md | Home | 1 | -- | guide | All | wiki-guide | background, how-it-works, checks, scoring, results, roadmap, glossary |
| background.md | Background | 2 | -- | guide | COO, Account Managers | wiki-guide | how-it-works, results |
| how-it-works.md | How It Works | 3 | -- | guide | All | wiki-guide | scoring, checks, glossary |
| checks.md | The 29 Checks | 4 | -- (has_children) | guide | Performance Engineers, Account Managers | wiki-guide | checks/bha, checks/trajectory, checks/live-data, checks/drilling-reports, checks/engineering, checks/tool-inventory, checks/file-drive, scoring |
| scoring.md | Scoring | 5 | -- | guide | All | wiki-guide | checks, glossary, results |
| results.md | Results & Impact | 6 | -- | guide | COO, Account Managers | wiki-guide | background, scoring, roadmap |
| trend-board.md | QC Trend Board | 7 | -- | guide | COO, Account Managers | wiki-guide | roadmap |
| roadmap.md | Roadmap | 8 | -- | guide | All | wiki-guide | background, results, trend-board |
| guardrails.md | Guardrails | 9 | -- | guide | All | wiki-guide | how-it-works, technical/guardrails |
| glossary.md | Glossary | 10 | -- | guide | All | wiki-guide | scoring, checks |

### Tier 1: Category Sub-Pages

| File | Title | Nav Order | Parent | Tone | Audience | Owner | Required Cross-Links |
|---|---|---|---|---|---|---|---|
| checks/bha.md | BHA (Bottom Hole Assembly) | 1 | The 29 Checks | guide | Performance Engineers | wiki-guide | checks, scoring, glossary |
| checks/trajectory.md | Trajectory and Anti-Collision | 2 | The 29 Checks | guide | Performance Engineers | wiki-guide | checks, scoring, glossary |
| checks/live-data.md | Live Data | 3 | The 29 Checks | guide | Performance Engineers | wiki-guide | checks, scoring, glossary |
| checks/drilling-reports.md | Drilling Reports | 4 | The 29 Checks | guide | Performance Engineers | wiki-guide | checks, scoring, glossary |
| checks/engineering.md | Engineering | 5 | The 29 Checks | guide | Performance Engineers | wiki-guide | checks, scoring, glossary |
| checks/tool-inventory.md | Tool Inventory and Tracking | 6 | The 29 Checks | guide | Performance Engineers | wiki-guide | checks, scoring, glossary |
| checks/file-drive.md | File Drive | 7 | The 29 Checks | guide | Performance Engineers | wiki-guide | checks, scoring, glossary |

### Tier 2: Technical Reference

| File | Title | Nav Order | Parent | Tone | Audience | Owner | Required Cross-Links | Source Modules |
|---|---|---|---|---|---|---|---|---|
| technical/index.md | Technical Reference | 10 | -- (has_children) | technical | Engineers | wiki-technical | index (Tier 1), glossary | -- |
| technical/architecture.md | Architecture | 2 | Technical Reference | technical | Engineers | wiki-technical | how-it-works, technical/api-layer | src/orchestrator/, src/api/, src/rules/ |
| technical/api-layer.md | API Layer | 1 | Technical Reference | technical | Engineers | wiki-technical | background, how-it-works, technical/architecture | src/api/ |
| technical/rule-engine.md | Rule Engine | 3 | Technical Reference | technical | Engineers | wiki-technical | checks, technical/architecture | src/rules/ |
| technical/orchestrator.md | Orchestrator | 4 | Technical Reference | technical | Engineers | wiki-technical | how-it-works, technical/architecture | src/orchestrator/ |
| technical/scoring-engine.md | Scoring Engine | 5 | Technical Reference | technical | Engineers | wiki-technical | scoring, technical/architecture | src/reporter/score_calculator.py |
| technical/monday-integration.md | Monday.com Integration | 6 | Technical Reference | technical | Engineers | wiki-technical | results, technical/architecture | src/reporter/monday_client.py |
| technical/guardrails.md | Guardrails | 7 | Technical Reference | technical | Engineers | wiki-technical | how-it-works, technical/architecture | src/guardrails/ |

---

## Generation Status

Tracks which pages exist and are current. Updated by wiki-sweep.

| File | Status | Last Updated |
|---|---|---|
| index.md | Exists | 2026-04-07 |
| background.md | Exists | 2026-04-07 |
| how-it-works.md | Exists | 2026-04-07 |
| checks.md | Exists | 2026-04-07 |
| checks/bha.md | Exists | 2026-04-07 |
| checks/trajectory.md | Exists | 2026-04-07 |
| checks/live-data.md | Exists | 2026-04-07 |
| checks/drilling-reports.md | Exists | 2026-04-07 |
| checks/engineering.md | Exists | 2026-04-07 |
| checks/tool-inventory.md | Exists | 2026-04-07 |
| checks/file-drive.md | Exists | 2026-04-07 |
| scoring.md | Exists | 2026-04-07 |
| results.md | Exists | 2026-04-13 |
| trend-board.md | Exists (placeholder) | 2026-04-07 |
| roadmap.md | Exists | 2026-04-13 |
| glossary.md | Exists | 2026-04-10 |
| technical/index.md | Exists | 2026-04-07 |
| technical/architecture.md | Exists | 2026-04-07 |
| technical/api-layer.md | Exists | 2026-04-10 |
| technical/rule-engine.md | Exists | 2026-04-07 |
| technical/orchestrator.md | Exists | 2026-04-10 |
| technical/scoring-engine.md | Exists | 2026-04-07 |
| technical/monday-integration.md | Exists | 2026-04-10 |
| guardrails.md | Exists | 2026-04-12 |
| technical/guardrails.md | Exists | 2026-04-12 |
