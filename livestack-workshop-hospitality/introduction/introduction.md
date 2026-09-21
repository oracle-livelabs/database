# Build Connected Hospitality Solutions with Oracle AI Database

## Introduction

Jessica Chan is the database administrator at Seer Hotels. Her teams are building new guest applications, improving guest-service and booking-abuse reviews, routing service work, and adding AI to hospitality dashboards.

The requests look different, but they share one problem. The data is already in Oracle AI Database, and each team wants to use it in a different way:

- Thomas needs guest reservations as JSON for a web and mobile application.
- Gilly needs semantic search that can find stay offers by meaning, not only by matching words.
- Bob needs to follow relationships between reservations and other entities to investigate booking abuse.
- Moon needs to calculate distances between guests, hotel properties, and demand regions.
- Otto needs to train and score a stay offer demand model.
- Nina needs to ask hospitality questions in plain language and turn the answers into a useful review.

### Seer Hotels data model

Seer Hotels is a fictional hotel group. This diagram shows how guests, hotels, room offers, reservations, and nightly charges connect.

![Seer Hotels core ERD: guests and hotel properties each have many reservations; hotel properties have many stay offers; reservations and stay offers each connect to many reservation-night lines.](images/seer-hotels-erd.png)

*One room per reservation. A stay offer combines a room type and a rate plan. Nightly-charge lines record room nights and rates.* [Open the full-size diagram](images/seer-hotels-erd.png) or see the [complete schema and supporting entities](../validation/schema-contract.md).

> **Phase 1 availability:** This edition defines the hospitality workshop and its required schema. Its provisioning package and hospitality dataset will be integrated in Phase 2. A running hospitality application and new database screenshots have not yet been produced. Continue with hands-on SQL only after the instructor confirms the prerequisites in Getting Started.

Jessica's job is to help each team meet its requirement without creating a new data copy or a separate security model for every feature. She uses Oracle AI Database as the shared foundation: relational tables remain the source for hospitality records, while JSON, vectors, graphs, spatial data, machine learning, and AI services work with those same records.

This workshop follows Jessica and her colleagues as they solve these problems and help the hotel group improve guest stays. Each lab focuses on one business requirement, but the database remains the common thread. You will see how the teams use different data types and database capabilities together, and how Jessica keeps access, SQL, and results visible.

### What the team builds

| Team member                   | Requirement                                                     | What you will see                                                                                                                          |
| -------------------------------| -----------------------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------------------------|
| Jessica, DBA                  | Build the query behind a guest service and operations dashboard.         | One SQL result combines relational service-alert data, semantic stay offer matching, JSON reservation data, and location data.                         |
| Thomas, application developer | Give the application flexible reservation documents.            | JSON columns, JSON collections, and JSON Relational Duality Views provide different ways to serve application data.                        |
| Gilly, AI engineer            | Find stay offers related to a guest-service question.                       | Jessica loads an ONNX embedding model into the database, and Gilly creates vectors where the stay offer data already lives.                   |
| Bob, graph specialist         | Find connected reservations and entities in a booking abuse investigation.  | A property graph uses the existing relational data to show paths that become difficult to manage with repeated SQL joins.                  |
| Moon, spatial expert          | Route work using hotel-property and region locations.           | The database calculates distance from geographic data that the application can also display.                                               |
| Otto, data scientist          | Identify stay offers that may face a demand surge.                 | Oracle Machine Learning trains and scores a model inside the database, close to the stay offer and activity data.                             |
| Nina, guest experience analyst            | Ask hospitality questions without writing every query from scratch. | Select AI generates SQL that Nina can inspect, run, and refine. Select AI Agent adds a restricted SQL tool and records the agent activity. |


The point is not to use every capability in every query. The point is that Jessica does not have to move the data into a separate database whenever a requirement changes. The same hospitality records can support:

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
> The advantage is practical. Teams can use the data in the form their application or analysis needs while keeping the records, privileges, and SQL access connected. They do not need to copy hospitality data into a document store, vector service, graph database, mapping system, or separate scoring service for each requirement.

</details>


### Objectives

- Follow Jessica and her team as they solve different hospitality application and analysis requirements.
- Use relational SQL, JSON, vectors, graphs, spatial data, Oracle Machine Learning, Select AI, and Select AI Agent in practical tasks.
- See how one Oracle AI Database can support different data types without separate copies of the hospitality records.
- Understand how database privileges, restricted AI profiles, approved tools, and execution history keep AI-assisted work visible and controlled.
- Connect the database exercises to the planned Seer Hotels application workflows.

Estimated Workshop Time: **90 minutes**

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano, Pat Shepherd, Linda Foinding
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
