# Build Financial Intelligence with Oracle AI Database 26ai

## Introduction

Jessica Chan is the database administrator at Seer Bank. Her teams are building new customer applications, improving risk and fraud reviews, routing service work, and adding AI to finance dashboards.

The requests look different, but they share one problem. The data is already in Oracle AI Database, and each team wants to use it in a different way:

- Thomas needs customer transactions as JSON for a web and mobile application.
- Gilly needs semantic search that can find products by meaning, not only by matching words.
- Bob needs to follow relationships between accounts and other entities to investigate fraud.
- Moon needs to calculate distances between customers, service centers, and demand regions.
- Otto needs to train and score a product demand model.
- Nina needs to ask finance questions in plain language and turn the answers into a useful review.

Jessica's job is to help each team meet its requirement without creating a new data copy or a separate security model for every feature. She uses Oracle AI Database as the shared foundation: relational tables remain the source for finance records, while JSON, vectors, graphs, spatial data, machine learning, and AI services work with those same records.

This workshop follows Jessica and her colleagues as they solve these problems. Each lab focuses on one business requirement, but the database remains the common thread. You will see how the teams use different data types and database capabilities together, and how Jessica keeps access, SQL, and results visible.

### What the team builds

| Team member                   | Requirement                                                     | What you will see                                                                                                                          |
| -------------------------------| -----------------------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------------------------|
| Jessica, DBA                  | Build the query behind a risk and operations dashboard.         | One SQL result combines relational risk data, semantic product matching, JSON transaction data, and location data.                         |
| Thomas, application developer | Give the application flexible transaction documents.            | JSON columns, JSON collections, and JSON Relational Duality Views provide different ways to serve application data.                        |
| Gilly, AI engineer            | Find products related to a risk question.                       | Jessica loads an ONNX embedding model into the database, and Gilly creates vectors where the product data already lives.                   |
| Bob, graph specialist         | Find connected accounts and entities in a fraud investigation.  | A property graph uses the existing relational data to show paths that become difficult to manage with repeated SQL joins.                  |
| Moon, spatial expert          | Route work using service-center and region locations.           | The database calculates distance from geographic data that the application can also display.                                               |
| Otto, data scientist          | Identify products that may face a demand surge.                 | Oracle Machine Learning trains and scores a model inside the database, close to the product and activity data.                             |
| Nina, risk analyst            | Ask finance questions without writing every query from scratch. | Select AI generates SQL that Nina can inspect, run, and refine. Select AI Agent adds a restricted SQL tool and records the agent activity. |


The point is not to use every capability in every query. The point is that Jessica does not have to move the data into a separate database whenever a requirement changes. The same finance records can support an application payload, a vector search, a graph investigation, a spatial calculation, a model score, or a natural-language question.

<details>
<summary><strong>Learn more: What does "converged database" mean?</strong></summary>

> A converged database supports different data types and workloads on one database foundation. In this workshop, that includes relational rows, JSON documents, vectors, graphs, geographic data, machine learning models, and AI-assisted SQL.
>
> The advantage is practical. Teams can use the data in the form their application or analysis needs while keeping the records, privileges, and SQL access connected. They do not need to copy finance data into a document store, vector service, graph database, mapping system, or separate scoring service for each requirement.

</details>

### How AI fits into Jessica's work

Oracle AI Database also lets Jessica support AI without hiding the database operation from her team.

- Gilly uses an ONNX embedding model loaded into the database. Product text becomes a vector next to the product row, so the application does not have to send finance text to a separate embedding service.
- Nina uses a Select AI profile with an explicit list of finance tables. She can inspect the generated SQL before running it.
- Nina's Select AI Agent uses one approved, read-only SQL tool. The agent runs with the database user's privileges, and team and tool history show what happened.

These controls matter in finance. AI can help create a useful answer, but the team still needs to know which data was available, which SQL ran, and whether the result supports the business question.

This workshop is a guided look behind the Seer Bank Finance LiveStack demo. The demo presents the customer-facing application. The labs show how the database capabilities behind those pages work and how Jessica's team can build on them.

Throughout the workshop, expandable sections provide extra context about a term or database capability. They are closed by default so the main lab stays focused. Select the arrow when you want more detail.

### Objectives

- Follow Jessica and her team as they solve different finance application and analysis requirements.
- Use relational SQL, JSON, vectors, graphs, spatial data, Oracle Machine Learning, Select AI, and Select AI Agent in practical tasks.
- See how one Oracle AI Database can support different data types without separate copies of the finance records.
- Understand how database privileges, restricted AI profiles, approved tools, and execution history keep AI-assisted work visible and controlled.
- Connect the database work to the customer-facing Seer Bank Finance LiveStack demo.

Estimated Workshop Time: **90 minutes**

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano
* **Last Updated By/Date** - Oracle Database Product Management, August 2026
