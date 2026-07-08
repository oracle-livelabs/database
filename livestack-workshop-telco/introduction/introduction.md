# Build Telecom Operations Intelligence with Oracle Database 26ai

## Introduction

A telecommunications provider cannot manage a demand surge from one dashboard alone. Network operations, care, field dispatch, retention, data engineering, and AI teams all need the same trusted evidence. In many environments, those teams still work from separate systems and different versions of the truth.

In this workshop, you follow Seer Comms through a South Florida 5G demand-surge scenario. The business problem is simple: subscriber pressure is rising, and the provider needs to decide where to act before experience degrades. The technical lesson is that the evidence for that decision can stay in Oracle AI Database 26ai instead of being fragmented across separate search, graph, spatial, analytics, document, and AI stores.

You start with the governed data foundation, then move through the same decision loop an operator would use: observe service pressure, understand subscriber intent, investigate connected impact, locate field capacity, inspect service orders, review predictive signals, ask governed questions, and record auditable AI-assisted action.

The Seer Comms LiveStack Demo shows the application workflow. These labs show the Oracle AI Database evidence behind that workflow. Each lab asks a business question, runs SQL against the loaded workshop schema, and explains why the result matters to a telecom team.

Estimated Workshop Time: 2 hours

### Objectives

In this workshop, you will:

- Inspect the Seer Comms data foundation and semantic views.
- Query telecom KPIs that support a network experience command center.
- Use AI Vector Search to connect subscriber language to telecom services.
- Use Property Graph and SQL/PGQ to investigate subscriber and network impact.
- Use Oracle Spatial to connect demand pressure, network sites, and field capacity.
- Compare relational service orders with JSON Relational Duality documents.
- Review predictive assurance patterns that join model-style scores to operations data.
- Explain trusted natural-language answers and AI-assisted actions with visible database evidence.

![Seer Comms welcome overview](images/welcome-overview.png)

## Workshop Story

| Story Element | Description |
| --- | --- |
| Business Problem | A mobile demand surge can create subscriber pain before care, network, field, and retention teams share the same picture. |
| Technical Challenge | Telecom data often spans OSS, BSS, CRM, care, network, dispatch, AI, and analytics systems. |
| Persona Focus | Network operations leader, care operations lead, service assurance analyst, platform engineer, and telecom data developer. |
| What You Will Prove | Oracle AI Database can keep operational, AI-ready, graph, spatial, JSON, ML, and audit data close to one governed foundation. |
| Database Capability | Oracle AI Database 26ai converged data platform capabilities. |
| Outcome | The provider can move from signal detection to explainable, auditable service assurance action. |
{: title="Workshop story at a glance"}

![Seer Comms operating loop](images/operating-loop.svg)

## How to Use the Labs

Each lab follows the same pattern:

1. Read the operating story so you know the decision you are trying to support.
2. Review the screenshot or concept diagram to connect the database work to the LiveStack Demo.
3. Run the SQL block in Database Actions SQL Worksheet.
4. Compare your result with the expected output.
5. Read the interpretation before moving to the next lab.

The SQL is not just proof that objects exist. It shows how Oracle AI Database keeps data, search, graph, spatial analysis, prediction, document access, and audit evidence close enough for a real operator workflow. When a screenshot includes small interface details, use it as scene grounding; the SQL and explanation underneath tell you exactly what to verify.

![Seer Comms use case overview](images/welcome-use-cases.png)

## Acknowledgements

- **Author** - Oracle LiveLabs Team
- **Source material** - Oracle LiveStack source, Seer Comms runbook, and Oracle-owned build notes listed in `TRACEABILITY.md`.
