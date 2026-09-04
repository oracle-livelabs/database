# Turn Financial Data into Connected Insight and Controlled Action with Oracle AI Database

## Introduction

Financial-services teams often investigate risk across separate transaction, customer, document, relationship, and operational systems. Each handoff slows the investigation and makes the evidence harder to trace.

In this hands-on workshop, **Seer Bank** uses **Oracle AI Database** to connect that information. You follow one finance decision flow from trusted data and risk prioritization through investigation, prediction, natural-language access, and controlled action.

![Workshop overview](images/finance-workshop-intro-journey.png " ")

This workshop takes you behind the companion Seer Bank Finance LiveStack demo. You will run the database work that supports its dashboard, investigation, service, prediction, Select AI, and agent-assisted workflow, then connect each result to the business decision it supports.

You will also step beyond observation. Several labs include 🎯 interactive challenges where you change an investigation question, compare evidence, or make a review recommendation using the same governed data. These moments let you test how Oracle's converged database brings relational, JSON, vector, graph, spatial, and machine-learning capabilities together for one finance decision flow.

This workshop gives you the connected decision flow across those capabilities. When you want to go deeper on a specific topic—such as JSON Relational Duality, AI Vector Search, Property Graph, Oracle Spatial, or Oracle Machine Learning—use the related deep-dive LiveLabs links in each lab's **Next Steps** section.

Throughout the workshop, you will see small arrows next to expandable sections. Select the arrow when you want extra context about a term, concept, or Oracle AI Database capability. These sections are closed by default so the main lab stays focused, but you can expand them whenever you want more explanation.

The example below shows an expandable section before and after it is opened.

![Expandable details section changing from closed to open](images/details-accordion-expand-flow.png " ")

<details>
<summary><strong>Learn more: What does "converged database" mean?</strong></summary>

> A converged database lets you work with several kinds of data and workloads in one database: rows and columns, JSON documents, vectors for AI search, graphs for relationships, spatial data for location, and machine learning models.
>
> In a fractured environment, each capability often lives in a different store or service. That can force teams to copy data, rebuild security rules, reconcile conflicting results, and explain why two systems disagree. Oracle AI Database is well suited for this finance scenario because the evidence, security model, SQL access, and application data stay connected.

</details>

The hands-on work follows one finance decision flow. First, you inspect the shared data foundation and use dashboard evidence to decide what needs attention. Then you work with transaction documents, search risk language by meaning, follow fraud relationships, evaluate service coverage, and score predictive models. Finally, you ask governed finance questions with Select AI and use a constrained agent workflow to move from insight to controlled action.

Each lab starts with a practical finance question and then shows the SQL evidence behind the answer.

As you move through the labs, treat every result as part of the same operating story. Dashboard metrics point to products, transactions, signals, relationships, service coverage, predictions, governed answers, and controlled actions that remain connected inside Oracle AI Database.

The image below is the Seer Bank Finance LiveStack welcome page. It introduces one connected financial-intelligence journey: monitor risk, investigate exposure, add service context, anticipate what may happen next, ask questions, and take a controlled action. The workshop exposes the database evidence behind those application pages.

![Seer Bank Finance LiveStack welcome page](images/seer-bank-welcome.png " ")

### Objectives

- Query the current Seer Bank finance data foundation.
- Use SQL, JSON Relational Duality, AI Vector Search, Property Graph, Oracle Spatial, Oracle Machine Learning (OML), Select AI, and Select AI Agents in one connected finance workflow.
- Connect each hands-on result to a practical risk, investigation, service, planning, or operational decision.
- Explain how Oracle AI Database helps teams move from connected data to insight and controlled action.
- Identify business measures that an organization could use to evaluate the pattern in its own environment.

Estimated Workshop Time: **180 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Seer Bank needs faster risk, fraud, compliance, service, and predictive decisions without spreading evidence across disconnected systems. |
| Technical Challenge | Application, data, and AI teams otherwise stitch together separate stores, services, indexes, pipelines, and governance controls for each data type. |
| Persona Focus | Database developers, application developers, risk analysts, operations leaders, and AI engineers share one evidence path. |
| What You Will See | One Oracle AI Database foundation supports the finance decision loop from trusted data to connected insight and controlled action. |
| Database Capability | Relational SQL, JSON, vectors, graphs, spatial, OML, Select AI, and agent tools work against connected finance data. |
| Outcome | Risk, operations, and engineering teams can investigate and act from connected database evidence instead of reconciling disconnected outputs. |

**Persona focus:** You support finance business users who need timely, explainable decisions without fragmented integration work. Your job is to connect business decisions to governed database evidence that can be reviewed and repeated.


## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle AI Database Product Management, September 2026
