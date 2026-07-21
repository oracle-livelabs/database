# Build Retail Intelligence with Oracle Database 26ai

## Introduction

Retail teams make better decisions when operational evidence stays close to the workflow. In this workshop, you follow a retail decision path for Seer Sporting Goods: start with trusted data, inspect the command center, open the order record, interpret demand signals, understand creator influence, choose fulfillment options, and prioritize action with model output.

The business pressure is familiar: product demand changes quickly, customers expect fast service, and different teams need the same answer without reconciling separate systems. Oracle Database 26ai and Autonomous Database keep relational rows, JSON documents, vectors, graph relationships, spatial data, and in-database analytics connected in one governed environment. The application shows the retail experience; each lab shows the SQL evidence behind it.

![Workshop overview](images/retail-workshop-intro-journey.svg " ")

Throughout the workshop, you will see small arrows next to expandable sections. Select the arrow when you want extra context about a term, concept, or Oracle Database capability. These sections are closed by default so the main lab stays focused, but you can expand them whenever you want more explanation.

The example below shows an expandable section before and after it is opened.

![Expandable details section changing from closed to open](images/details-accordion-expand-flow.png " ")

<details>
<summary><strong>Learn more: What does "converged database" mean?</strong></summary>

> A converged database lets you work with several kinds of data and workloads in one database: rows and columns, JSON documents, vectors for AI search, graphs for relationships, spatial data for location, and machine learning models.
>
> In a fractured environment, each capability often lives in a different store or service. That can force teams to copy data, rebuild security rules, reconcile conflicting results, and explain why two systems disagree. Oracle Database is well suited for this retail scenario because the evidence, security model, SQL access, and application data stay connected.

</details>

### Objectives

In this workshop, you will:

- Inspect the retail schema objects that support the application workflow.
- Trace command-center metrics to orders, products, and categories.
- Query order data through JSON Relational Duality and relational SQL.
- Use AI Vector Search to match natural-language demand signals to products.
- Use Property Graph to follow creator and brand relationships.
- Use Oracle Spatial to combine location and inventory for fulfillment decisions.
- Use Oracle Machine Learning model outputs from SQL.

Estimated Workshop Time: **90 minutes**

### Business Scenario

| Step | Retail focus |
| --- | --- |
| Business Problem | Retail teams need faster decisions without spreading product, order, signal, fulfillment, and analytics evidence across disconnected systems. |
| Technical Challenge | Each workflow needs a different data shape, but the evidence must remain governed and traceable. |
| Persona Focus | A retail operations leader wants one trusted decision path, while the application and database team must make it explainable. |
| Database Capability | Relational SQL, JSON Relational Duality, vectors, property graph, spatial, and Oracle Machine Learning work together in Oracle Database 26ai. |
| Outcome | You can explain how one governed database foundation supports a retail decision loop from signal to action. |

![Seer retail LiveStack welcome page](images/seer-sporting-goods-welcome.png " ")

*Figure 1: The welcome page frames the retail workflow that the SQL labs explain.*

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, July 2026
