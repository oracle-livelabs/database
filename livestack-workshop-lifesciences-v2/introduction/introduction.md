# Build Connected Life Sciences Solutions with Oracle AI Database

## Introduction

Before a clinical supply meeting, Seer Scientific receives a quality alert. The team needs to identify products and trial sites for review, check nearby cold-chain depots, and trace supply relationships. Each answer must show the records and calculations behind it.

Jessica Chan is the database administrator at Seer Scientific. Her teams are building clinical supply applications, reviewing product concerns, evaluating service coverage, and adding AI to quality and supply dashboards.



Each team uses the data in Oracle AI Database for a different task:

- Thomas needs clinical supply orders as JSON for a web and mobile application.
- Gilly needs semantic search that can find products by meaning, not only by matching words.
- Bob needs to follow supply orders to their required products and find alternative depots with enough recorded stock.
- Moon needs to calculate distances between trial sites, cold-chain supply centers, and demand regions.
- Otto needs to train and score a product demand model.
- Nina needs to ask quality and clinical-supply questions in plain language and turn the answers into a useful review.

![The Seer Scientific team: Jessica, Thomas, Gilly, Bob, Moon, Otto, and Nina, Clinical-Supply Analyst](images/ls-team.svg)

Jessica helps the teams use the existing database for these features. Relational tables hold the life sciences records; JSON, vectors, graphs, spatial functions, machine learning, and AI services provide different ways to work with them.

Follow Jessica and her colleagues as they investigate quality concerns and review clinical supply operations. Each lab addresses one business requirement and shows the SQL, source records, and results used to answer it.

### What the team builds

| Team member | Requirement | What you will see |
| --- | --- | --- |
| Jessica, DBA | Build the query behind a quality and supply operations dashboard. | One SQL result combines quality and supply data, semantic product matching, JSON order data, and location data. |
| Thomas, application developer | Give the application flexible clinical supply order documents. | JSON columns, JSON collections, and JSON Relational Duality Views provide different ways to serve application data. Practice writes use isolated exercise objects. |
| Gilly, AI engineer | Find products related to a sterility concern. | With the supplied in-database embedding model, Gilly creates vectors where the product data already lives. |
| Bob, graph specialist | Find alternative depots with enough recorded stock for every product in one supply order. | SQL/PGQ follows existing order and inventory relationships; Graph Studio shows the product branches and the candidate depots they share. |
| Moon, spatial expert | Evaluate cold-chain coverage using trial-site, supply-center, and region locations. | The database calculates distance from geographic data that the application can also display. Proximity alone does not establish cold-chain suitability. |
| Otto, data scientist | Identify regulated products that may face a supply-demand surge. | Oracle Machine Learning trains and scores a model inside the database, using the product and activity data. The exercise demonstrates scoring; it does not test accuracy on new data. |
| Nina, clinical-supply analyst | Ask Life Sciences questions without writing every query from scratch. | Select AI generates SQL that Nina can inspect, run, and refine. Select AI Agent adds a restricted SQL question-answering tool and records the agent activity. |

Jessica can support these requirements in the same database. The life sciences records support:

- An application payload.
- A vector search.
- A graph investigation.
- A spatial calculation.
- A model score.
- A natural-language question.

<details>
<summary><strong>Learn more: What does "converged database" mean?</strong></summary>

> A converged database supports different data types and workloads on one database foundation. In this workshop, that includes relational rows, JSON documents, vectors, graphs, geographic data, machine learning models, and AI-assisted SQL.
>
> The advantage is practical. Teams can use the data in the form their application or analysis needs while keeping the records, privileges, and SQL access connected. They do not need to copy Life Sciences data into a document store, vector service, graph database, mapping system, or separate scoring service for each requirement.

</details>


This workshop uses synthetic demonstration data. Some exercises create isolated practice objects or derived data such as embeddings and model scores; they do not require a separate production database for each capability.

### Objectives

- Follow Jessica and her team as they solve different Life Sciences application and analysis requirements.
- Use relational SQL, JSON, vectors, graphs, spatial data, Oracle Machine Learning, Select AI, and Select AI Agent in practical tasks.
- See how one Oracle AI Database can support different data types without separate production stores for the Life Sciences records.
- Understand how database privileges, restricted AI profiles, approved tools, and execution history keep AI-assisted work visible and controlled.
- Connect the database work to the Seer Scientific clinical-supply LiveStack demo.

Estimated Workshop Time: **90 minutes**

## Acknowledgements

* **Author** - Joshua Pasaribu
* **Contributor** - Nechita C. Teodor
* **Last Updated By/Date** - Nechita C. Teodor, October 2026
