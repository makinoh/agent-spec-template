---
title: Concepts
description: An overview of how the core ideas relate — AI-Driven Development, Spec-Driven Development, ADR, Constitution, Governance, spec-kit, and quality gates.
---

# Concepts

This section explains **why the template has the shape it does**. It clicks best after you have tried the [Getting Started](../getting-started/index.md) hands-on steps.

## The big picture — how the concepts relate

Everything centers on one point: **let AI write fast, while always recording design rationale and approvals.**

```mermaid
flowchart TD
    AIDD["AI-Driven Development (AIDD)<br/>AI as a continuous team member"]
    AIDD --> SDD["Spec-Driven Development (SDD)<br/>what/why before code"]
    AIDD --> GOV["Governance<br/>classify changes -> permissions & approval"]

    SDD --> SPEC["spec (what)"]
    SDD --> PLAN["plan (how)"]
    PLAN --> ADR["ADR (why this design)"]

    GOV --> CONST["Constitution<br/>top-level rules"]
    GOV --> CLASS["Change classes A/B/C/D"]
    GOV --> GATE["Quality gates<br/>machine-enforced in CI"]

    SPECKIT["spec-kit"] -. "commands bridge" .-> SPEC
    AGENTS["AGENTS.md + tool configs"] -. "instructs the AI" .-> AIDD

    classDef core fill:#e8eaf6,stroke:#3949ab,color:#1a237e;
    class AIDD,SDD,GOV core;
```

## What each page covers

| Concept | In one line | Prerequisite |
| --- | --- | --- |
| [AI-Driven Development (AIDD)](ai-driven-development.md) | Treat AI as a continuous team member, with safety rails | none |
| [Spec-Driven Development (SDD)](spec-driven-development.md) | Write what/why before code; separate spec / plan / ADR | none |
| [ADR](adr.md) | A one-file record of "why this design" | SDD |
| [Constitution](constitution.md) | Top-level rules both humans and AI follow | none |
| [Governance & Change Classes](governance.md) | A/B/C/D weight decides AI autonomy and human approval | Constitution |
| [spec-kit](spec-kit.md) | Run the SDD flow via `/speckit.*` commands | SDD |
| [Quality Gates](quality-gates.md) | Local = AI = CI run the same machine-enforced checks | none |
| [Multi-Agent & Claude Code](multi-agent.md) | Run multiple AI tools under one rule set | AIDD |

> **Suggested order (least prerequisite first):** [AIDD](ai-driven-development.md) -> [SDD](spec-driven-development.md) -> [ADR](adr.md) -> [Constitution](constitution.md) -> [Governance](governance.md).
