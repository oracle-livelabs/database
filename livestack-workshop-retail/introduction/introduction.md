# Build Retail Intelligence with Oracle Database 26ai

## Introduction

Retail teams make better decisions when operational evidence stays close to the workflow. In this workshop, learners inspect the **Oracle Database 26ai** foundation behind the Seer Sporting Goods LiveStack and see how one governed database supports retail dashboards, customer signals, fulfillment decisions, order intelligence, analytics, Ask Retail Data, and auditable agent actions.

In this workshop, you use Database Actions SQL Worksheet to inspect the database objects behind the Seer Sporting Goods Retail LiveStack. The application shows the retail workflow; the labs show how **Oracle AI Database 26ai** supports it.

The same database stores the operational data, JSON documents, vectors, graph relationships, spatial locations, OML models, PL/SQL tools, and audit records used in the labs. This lets you follow the retail decision path without switching between disconnected systems.

### Prerequisites

- Access to the LiveLabs environment for this workshop.
- Access to Database Actions and SQL Worksheet for the provisioned Autonomous Database 26ai instance.
- The retail workshop schema created by the backend provisioning bundle. LiveLabs Sandbox reservations use the main workshop user, usually `LLUSER`. In SQL Worksheet, select that main user from the dropdown menu at the top of the page; do not select `RETAILDB`.
- Basic familiarity with SQL and retail operations concepts.

### Objectives

In this workshop, you will:

- Query the database foundation behind the Seer Sporting Goods Retail LiveStack.
- Connect common retail problems, such as fragmented data, fast-changing demand, inventory risk, fulfillment complexity, limited self-service analytics, and governed AI use, to database-backed evidence.
- Inspect Retail Command Center metrics that combine orders, revenue, social momentum, returns exposure, inventory, and agent activity.
- Use JSON Relational Duality and VPD to inspect governed order intelligence.
- Use `ALL_MINILM_L12_V2`, `VECTOR_EMBEDDING`, and `VECTOR_DISTANCE` for semantic product and signal matching.Embeddings let products and signals be compared by meaning, with `VECTOR_EMBEDDING` and `VECTOR_DISTANCE`being the database functions behind that search.
- Traverse creator, brand, product, and post relationships with Property Graph and `GRAPH_TABLE`.
- Use Oracle Spatial for fulfillment-center and demand-region decisions.
- Inspect OML feature views and in-database mining models.
- Ground Ask Retail Data and agent workflows in semantic views, PL/SQL tools, and audit records.

Estimated Workshop Time: **90 minutes**


## Application Screens

These screenshots come from the running Seer Sporting Goods Retail LiveStack. They show the application flow that the SQL labs explain.

![Seer Sporting Goods LiveStack welcome page](images/seer-sporting-goods-welcome.png " ")

*Figure 1: The welcome page frames the retail story and previews the application flow.*

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
