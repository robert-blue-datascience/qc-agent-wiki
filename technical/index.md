---
title: Technical Reference
layout: default
nav_order: 10
has_children: true
---

# Technical Reference

*Last updated: 2026-04-16*

This section is written for technical contributors who need to understand the agent's internals: how it is built, how the layers connect, and how to modify or extend it. It assumes familiarity with Python, async patterns, and REST APIs.

For a non-technical overview of what the agent does and why, start with the [Program Guide](../index).

---

## Available Pages

| Page | Covers |
|---|---|
| [Architecture](architecture) | Four-layer model, API migration strategy, security posture, resource cache |
| [API Layer](api-layer) | HTTP client, authentication lifecycle, adapter pattern, endpoint reference |
| [Rule Engine](rule-engine) | Check dispatch, YAML config structure, evaluation contracts |
| [Orchestrator](orchestrator) | LangGraph state machine, node functions, routing logic, historical mode |
| [Scoring Engine](scoring-engine) | Category weights, two-step calculation, active and historical scoring modes |
| [Monday.com Integration](monday-integration) | GraphQL mutations, operator summary board, board configuration |
| [Guardrails](guardrails) | Rate limiter, security gate, audit logger, log sanitizer |

---

## Related Resources

- [Architecture Decision Records](../../adr/) (project governance, not wiki content)
- [Check Map](../../reference/check_map.md) (cross-reference of all 29 checks)
- [Glossary](../glossary) (shared term definitions)
