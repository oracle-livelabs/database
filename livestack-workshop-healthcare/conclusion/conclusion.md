# Conclusion

## Introduction

Jessica began with a dashboard warning that showed urgency without explanation. She ended with a planning decision supported by evidence. A database developer mapped the foundation, an application developer opened the request, and a quality analyst found related language. A care coordinator followed relationships, a logistics planner compared workable locations, and a capacity planner reviewed future demand. Each role added context without replacing the facts found earlier.

The same pattern applies far beyond healthcare. A retailer can trace a low-stock warning to an order and search supplier notes. The team can then follow product relationships, choose a warehouse, and forecast demand. A school or delivery company can follow a similar path under different names. Each organization moves from a summary signal to records, meaning, connections, physical options, and future risk.

With **Oracle AI Database 26ai**, Seer Health used relational SQL for operational facts and JSON Relational Duality for an application document. AI Vector Search handled meaning, Property Graph handled relationships, and Oracle Spatial handled location. Oracle Machine Learning supported prediction. These capabilities answered different questions while preserving the evidence path between results.

<details>
<summary><strong>Why this matters after the workshop</strong></summary>

> Real operations rarely fit inside one technology category. A single decision may involve transactions, documents, written notes, relationships, locations, and predictions. Seer Health’s capacity review used request rows, quality text, care relationships, locations, load measures, forecasts, and model scores.
>
> When each question depends on a separate system, teams must move data and repeat security rules. They must also synchronize copies and reconcile answers that may no longer agree. A converged database reduces those handoffs and keeps the evidence path closer to the source.

</details>

### Objectives

- Review the healthcare outcomes from Labs 1 through 7.
- Connect each business question to its database evidence.
- Explain why convergence matters for healthcare operations.
- Carry the evidence-first pattern into another healthcare use case.

Estimated Time: **5 minutes**

## Task 1: Review the healthcare decision path

1. Review the outcome map.

    | Healthcare question | What you can now explain |
    | --- | --- |
    | What data and capabilities are available? | Oracle catalog views show the healthcare views, duality view, vectors, graph, spatial layers, and OML model. |
    | Where should leaders look first? | Command-center KPIs lead to five named elevated signals and a category summary. |
    | How can an application read a complete request? | JSON Relational Duality presents request 170104 as a document while SQL keeps access to the source rows. |
    | How can analysts search related care language? | AI Vector Search ranks services and signals by semantic similarity. |
    | Which care facts connect to the patient journey? | Property Graph and SQL/PGQ follow one-hop and two-hop relationships. |
    | Which logistics site fits the Miami request? | Oracle Spatial combines distance with service, status, load, and estimated available capacity. |
    | Where may demand rise? | Forecast rows and an OML classification model provide reviewable planning evidence. |

2. Review how the people connect to those outcomes.

    | Person | Workshop value |
    | --- | --- |
    | Care operations leader | Moves from a KPI to the signal rows and categories behind it. |
    | Application developer | Serves a JSON request without storing another copy. |
    | Quality analyst | Finds related service and signal language even when words differ. |
    | Care coordinator | Explains the relationships around a journey and encounter. |
    | Logistics planner | Compares distance, service fit, status, and available capacity. |
    | Capacity planner | Reviews forecasts, model identity, model fit, input features, and prediction probability. |
    | Database developer | Connects relational, JSON, vector, graph, spatial, and OML evidence in one schema. |

3. Connect the healthcare pressure to convergence.

    | Healthcare pressure | Why a converged Oracle Database foundation matters |
    | --- | --- |
    | Quality and capacity signals | Teams can review structured service data and signal text together. |
    | Application delivery | JSON documents and relational analysis come from the same request model. |
    | Care-path review | Graph relationships remain close to the source healthcare rows. |
    | Care logistics | Location, service, status, load, and capacity can appear in one query. |
    | Predictive planning | Forecast and OML results stay close to the data and SQL used to explain them. |
    | Governance and review | Teams can point to database-backed evidence instead of reconciling copied results. |

## Task 2: Explain the main lesson

1. Start with the healthcare problem, not a feature list.

    Seer Health needs faster operating decisions without losing the facts behind them.

2. Connect each database capability to a job.

    - SQL explains the operating numbers.
    - JSON Relational Duality serves the application document.
    - AI Vector Search finds related meaning.
    - Property Graph follows connected care facts.
    - Oracle Spatial measures location and supports routing evidence.
    - Oracle Machine Learning scores a model near the governed input data.

3. Carry the pattern forward.

    Begin with one healthcare question. Identify the data and evidence needed to answer it. Use the best database capability for each part, but keep the results connected to the same governed facts.

    Keep people in the decision. The workshop uses synthetic data to teach database patterns. Its graph scores, forecasts, distances, capacity estimates, and model results support learning and operational review. They do not replace clinical judgment, medical records, or healthcare policy.

The lasting lesson is that **Oracle AI Database 26ai** lets these jobs reinforce each other. Teams can move from awareness to evidence and planning without losing the context behind the decision.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, July 2026
