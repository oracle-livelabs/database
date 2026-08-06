# Build Network Experience Intelligence with Oracle AI Database 26ai

## Introduction

Seer Comms must decide where subscriber experience is deteriorating, which services and sites are affected, and how to respond before congestion becomes churn, an avoidable service-level breach, or a missed event window. The evidence arrives as operational rows, service-order documents, subscriber signals, relationships, and locations. When those data types live in separate systems, teams copy data, reconcile results, and repeat security work before they can act.

In this workshop, you investigate one escalating incident: `TEL-5G-2026-501`, a critical 5G congestion case near Hudson Yards during an event period. It affects 31,200 subscribers and puts $2.14M in service value at risk. You use **Oracle AI Database 26ai** to follow the evidence from the first capacity warning to a reviewable field response: the site, the affected service order, the subscriber signal, the connected case entities, nearby response locations, and the capacity-risk prediction.

![Seer Comms network-experience decision journey from capacity pressure to response](images/telco-workshop-intro-journey.svg " ")

*Figure 1: Each lab advances the `TEL-5G-2026-501` investigation, from Hudson Yards capacity pressure to a field-response decision.*

Throughout the workshop, you will see small arrows next to expandable **Key terms**, **Learn more**, and **Why this matters** sections. Select an arrow whenever you want the definition, how the term is used in this workshop, and the Telco reason it matters. These sections are closed by default so the main lab stays focused, but you can open them whenever you want more explanation.

The example below shows an expandable Telco section before and after it is opened.

![Expandable Telco details section changing from closed to open](images/details-accordion-expand-flow.svg " ")

<details>
<summary><strong>Learn more: What does converged database mean?</strong></summary>

> A **converged database** keeps relational rows, JSON documents, vectors, graphs, and spatial data in one governed database.
>
> For Seer Comms, a service-order document, its subscriber, a related signal, a network site, and a dispatch decision stay connected. Teams do not need to copy the same evidence among specialist systems before they can explain a decision.

</details>

<details>
<summary><strong>Why this matters: Autonomous Database and a connected evidence foundation</strong></summary>

> **Autonomous Database** is Oracle's managed cloud database service. It automates routine operations such as patching, backups, security maintenance, and scaling so database teams can spend more time on the network-experience decision instead of infrastructure upkeep.
>
> In this workshop, its converged database capabilities keep SQL rows, JSON documents, vectors, graph relationships, and spatial locations under one security and governance model. That reduces sensitive copies and gives Seer Comms a repeatable path from a capacity concern to the evidence that explains the response.

</details>

### Objectives

- Query the Seer Comms data foundation through SQL.
- Use JSON Relational Duality, AI Vector Search, Property Graph, Oracle Spatial, and Oracle Machine Learning (OML) for connected Telco evidence.
- Explain how a dashboard result can be traced to reviewable database rows.
- Describe the practical governance benefit of keeping evidence together.

Estimated Workshop Time: **80 minutes**

### Business Scenario

| Step | Telco focus |
| --- | --- |
| Business Problem | Network and service teams need a fast, reviewable way to understand a subscriber-experience issue. |
| Technical Challenge | Orders, signals, relationships, capacity, and geography can otherwise be separated across systems. |
| Persona Focus | You support network operations leaders, service-order developers, and field planners. |
| What You Will Do | Query the evidence behind the Seer Comms application decision journey. |
| Database Capability | SQL, JSON, vectors, graphs, and spatial data operate in one database. |
| Outcome | You can connect an operational observation to explainable, repeatable evidence. |

The labs follow one escalation: identify the evidence, prioritize loaded sites, inspect the affected order, understand the related signal, map the case impact, then use location evidence to plan a response.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Pat Shepherd, July 2026
