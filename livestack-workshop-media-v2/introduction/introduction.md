# Build Connected Media & Entertainment Solutions with Oracle AI Database

## Introduction

Jessica Chan is the database administrator at Seer Media. Her teams are building new campaign applications, improving creator and community analysis, planning launch-weekend capacity, and adding AI to media dashboards.

The requests look different, but they share one problem. The data is already in Oracle AI Database, and each team wants to use it in a different way:

- Thomas needs campaign orders as JSON for a web and mobile application.
- Gilly needs semantic search that can find content assets by meaning, not only by matching words.
- Bob needs to follow creator connections and studio partnerships to understand community reach.
- Moon needs to calculate distances between audience accounts, distribution hubs, and demand regions.
- Otto needs to train and score a content-demand surge model.
- Nina needs to ask media questions in plain language and turn the answers into a useful review.

![team](images/team.png)

Jessica helps each team work with the shared Media records and database privileges. Relational tables hold the source records. JSON, vectors, graphs, spatial data, machine learning, and AI services provide different ways to query and use them.

This workshop follows Jessica and her colleagues through these Media requirements. Each lab addresses one requirement using the shared database. You will combine database capabilities and inspect the SQL, access controls, and results behind each exercise.

### What the team builds

| Team member                   | Requirement                                                     | What you will see                                                                                                                          |
| -------------------------------| -----------------------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------------------------|
| Jessica, DBA                  | Build the Midnight Harbor launch command-center query.         | One SQL result combines launch signals, semantic content matching, JSON campaign-order data, and location data.                         |
| Thomas, application developer | Give the application flexible campaign-order documents.            | JSON columns, JSON collections, and JSON Relational Duality Views provide different ways to serve application data.                        |
| Gilly, AI engineer            | Find content assets related to an audience-intent question.                       | The platform provides an ONNX embedding model, and Gilly inspects vectors generated from the content catalog.                   |
| Bob, graph specialist         | Find connected creators and their studio partners.  | A property graph uses the existing relational data to show paths that become difficult to manage with repeated SQL joins.                  |
| Moon, spatial expert          | Route work using distribution-hub and demand-region locations.           | The database calculates distance from geographic data that the application can also display.                                               |
| Otto, data scientist          | Identify content assets that may face a demand surge.                 | Oracle Machine Learning trains a lab model with the loader data and scores a simulated activity snapshot.                             |
| Nina, audience analyst            | Ask media questions without writing every query from scratch. | Select AI generates SQL that Nina can inspect, run, and refine. Select AI Agent adds a configured SQL tool and records its activity. |


Jessica can choose the database capability that fits each requirement. The same media records can support:

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
> Teams choose the data format their application or analysis needs while managing records and privileges in the same database. These exercises use its built-in document, vector, graph, spatial, and scoring capabilities. Select AI calls an external model through the configured provider.

</details>


### Media data used in this workshop

The handoff loader supplies 187 content assets, 50 studios and labels, 2,000 audience accounts, 3,000 campaign orders, and 5,000 audience signals. `Midnight Harbor Premiere Window` is content asset 1. The seed snapshot is anchored to May 5, 2026.

The Media views provide domain labels over the shared LiveStack schema. For example, `MEDIA_CONTENT_ASSETS_V` exposes `PRODUCTS` as content assets, and `MEDIA_CAMPAIGN_ORDERS_V` exposes `ORDERS` as campaign orders. SQL and JSON examples retain the physical names required by the loader. This dataset supports campaign and capacity analysis; it does not contain viewing-session telemetry or measured retention outcomes.

### Objectives

- Follow Jessica and her team as they solve different media application and analysis requirements.
- Use relational SQL, JSON, vectors, graphs, spatial data, Oracle Machine Learning, Select AI, and Select AI Agent in practical tasks.
- See how one Oracle AI Database can support different data types without separate copies of the media records.
- Understand how database privileges, restricted AI profiles, approved tools, and execution history keep AI-assisted work visible and controlled.
- Connect the database work to the Seer Media launch-operations scenario.

Estimated Workshop Time: **90 minutes**

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano, Pat Shepherd, Linda Foinding
* **Last Updated By/Date** - Vahn Kessler, September 2026
