# Build Media Intelligence with Oracle AI Database 26ai

## Introduction

Media companies need fast launch decisions, but speed is not enough. When a campaign order, audience signal, creator relationship, rights-capacity issue, or forecast is questioned later, teams must be able to explain the evidence behind it.

Seer Media programming, marketing, rights, distribution, analytics, application, and AI teams all need to work from the same facts instead of reconciling different copies of the truth.

In this workshop, **Seer Media** uses **Oracle AI Database 26ai** as a converged media-intelligence foundation. Relational campaign records, JSON documents, vector search, property graph relationships, spatial coverage data, and in-database machine learning all operate against connected media data.

Throughout the workshop, you will see small arrows next to expandable sections. Select the arrow when you want extra context about a term, concept, or Oracle Database capability. These sections are closed by default so the main lab stays focused, but you can expand them whenever you want more explanation.

The example below shows an expandable section before and after it is opened.

![Expandable details section changing from closed to open](images/details-accordion-expand-flow.png " ")

<details>
<summary><strong>Learn more: What does "converged database" mean?</strong></summary>

> A converged database lets you work with several kinds of data and workloads in one database: rows and columns, JSON documents, vectors for AI search, graphs for relationships, spatial data for location, and machine learning models.
>
> In a fractured environment, each capability often lives in a different store or service. That can force teams to copy data, rebuild security rules, reconcile conflicting results, and explain why two systems disagree. Oracle Database is well suited for this media scenario because the evidence, security model, SQL access, and application data stay connected.

</details>

The hands-on work follows one media decision flow. First, you orient yourself to the data foundation. Then you turn that foundation into dashboard evidence, inspect campaign order documents, search audience language by meaning, follow creator relationships, evaluate rights coverage, and review predictive model output.

Each lab starts with a practical media question and then shows the SQL evidence behind the answer.

As you move through the labs, treat every query as part of the same operating record. Dashboard numbers are not isolated metrics. They point to content assets, audience signals, campaign orders, creator relationships, distribution hubs, rights capacity, and predictions that all remain connected inside Oracle Database.

### Objectives

- Query the current Seer Media data foundation.
- Use SQL, JSON Relational Duality, AI Vector Search, Property Graph, Oracle Spatial, and Oracle Machine Learning (OML) to support one connected media decision workflow.
- Explain why a converged Oracle Database foundation is critical for content operations, rights planning, application development, audience intelligence, and analytics.
- Connect the application pages to repeatable database evidence.

Estimated Workshop Time: **95 minutes**

### Business Scenario

| Step | Media focus |
| --- | --- |
| Business Problem | Seer Media needs faster launch, campaign, audience, creator, rights, and predictive decisions without spreading evidence across disconnected systems. |
| Technical Challenge | Application, data, and AI teams otherwise stitch together separate stores, services, indexes, pipelines, and governance controls for each data type. |
| Persona Focus | Database developers, application developers, media operations leaders, rights planners, audience analysts, and AI engineers share one evidence path. |
| What You Will See | One Oracle Database 26ai foundation can support the media decision loop from awareness to action. |
| Database Capability | Relational SQL, JSON, vectors, graphs, spatial, OML, and semantic views work together under one governed data model. |
| Outcome | Media and engineering teams can observe, investigate, decide, act, and review from database-backed evidence instead of reconciling disconnected outputs. |

**Persona focus:** You support media business users who need timely, explainable decisions without fragmented integration work. Your job is to connect business decisions to governed database evidence that can be reviewed and repeated.


## Acknowledgements

* **Author** - Oracle LiveLabs Team
* **Contributor** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, July 2026
