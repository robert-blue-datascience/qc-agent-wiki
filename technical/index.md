---
title: Technical Reference
layout: default
nav_order: 10
has_children: true
---

# Technical Reference

This section is written for technical contributors who need to understand the agent's internals: how it is built, how the layers connect, and how to modify or extend it. It assumes familiarity with Python, async patterns, and REST APIs.

For a non-technical overview of what the agent does and why, start with the [Program Guide](../index).

---

## Available Pages

| Page | Covers |
|---|---|
| [Architecture](architecture) | Four-layer model, API migration strategy, security posture, callback cache |
| [API Layer](api-layer) | HTTP client, authentication lifecycle, adapter pattern, endpoint reference |
| Rule Engine | Check dispatch, YAML config structure, evaluation contracts *(to be generated)* |
| Orchestrator | LangGraph state machine, node functions, routing logic *(to be generated)* |
| Scoring Engine | Category weights, two-step calculation, score publishing *(to be generated)* |
| Monday.com Integration | GraphQL mutations, delta detection, board configuration *(to be generated)* |
| Guardrails | Rate limiter, security gate, audit logger, log sanitizer *(to be generated)* |

Pages marked "to be generated" will be created using the `/wiki-technical` command as modules are documented.

---

## Related Resources

- [Architecture Decision Records](../../adr/) (project governance, not wiki content)
- [Check Map](../../reference/check_map.md) (cross-reference of all 29 checks)
- [Glossary](../glossary) (shared term definitions)
