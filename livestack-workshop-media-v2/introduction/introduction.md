# Build Connected Media & Entertainment Solutions with Oracle AI Database

## Introduction

Jessica Chan is the database administrator at Seer Media. Her teams are building new viewer applications, improving creator and community analysis, planning launch-weekend capacity, and adding AI to media dashboards.

The requests look different, but they share one problem. The data is already in Oracle AI Database, and each team wants to use it in a different way:

- Thomas needs viewer viewing sessions as JSON for a web and mobile application.
- Gilly needs semantic search that can find titles by meaning, not only by matching words.
- Bob needs to follow relationships between creators, viewers, devices, and titles to understand community activity.
- Moon needs to calculate distances between viewers, live-event operations hubs, and audience regions.
- Otto needs to train and score a audience engagement demand model.
- Nina needs to ask media questions in plain language and turn the answers into a useful review.

![team](images/team.png)

Jessica's job is to help each team meet its requirement without creating a new data copy or a separate security model for every feature. She uses Oracle AI Database as the shared foundation: relational tables remain the source for media records, while JSON, vectors, graphs, spatial data, machine learning, and AI services work with those same records.

This workshop follows Jessica and her colleagues as they solve these problems and help Seer Media innovate for viewers. Each lab focuses on one business requirement, but the database remains the common thread. You will see how the teams use different data types and database capabilities together, and how Jessica keeps access, SQL, and results visible.

### What the team builds

| Team member                   | Requirement                                                     | What you will see                                                                                                                          |
| -------------------------------| -----------------------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------------------------|
| Jessica, DBA                  | Build the Midnight Harbor launch command-center query.         | One SQL result combines launch signals, semantic title matching, JSON viewing-session data, and location data.                         |
| Thomas, application developer | Give the application flexible viewing session documents.            | JSON columns, JSON collections, and JSON Relational Duality Views provide different ways to serve application data.                        |
| Gilly, AI engineer            | Find titles related to an audience-intent question.                       | Jessica loads an ONNX embedding model into the database, and Gilly creates vectors where the content catalog data already lives.                   |
| Bob, graph specialist         | Find connected creators, viewers, and community entities.  | A property graph uses the existing relational data to show paths that become difficult to manage with repeated SQL joins.                  |
| Moon, spatial expert          | Route work using live-event-operations-hub and region locations.           | The database calculates distance from geographic data that the application can also display.                                               |
| Otto, data scientist          | Identify titles that may face a demand surge.                 | Oracle Machine Learning trains and scores a model inside the database, close to the title and activity data.                             |
| Nina, audience analyst            | Ask media questions without writing every query from scratch. | Select AI generates SQL that Nina can inspect, run, and refine. Select AI Agent adds a restricted SQL tool and records the agent activity. |


The point is not to use every capability in every query. The point is that Jessica does not have to move the data into a separate database whenever a requirement changes. The same media records can support:

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
> The advantage is practical. Teams can use the data in the form their application or analysis needs while keeping the records, privileges, and SQL access connected. They do not need to copy media data into a document store, vector service, graph database, mapping system, or separate scoring service for each requirement.

</details>


### Objectives

- Follow Jessica and her team as they solve different media application and analysis requirements.
- Use relational SQL, JSON, vectors, graphs, spatial data, Oracle Machine Learning, Select AI, and Select AI Agent in practical tasks.
- See how one Oracle AI Database can support different data types without separate copies of the media records.
- Understand how database privileges, restricted AI profiles, approved tools, and execution history keep AI-assisted work visible and controlled.
- Connect the database work to the viewer-facing Seer Media Media & Entertainment LiveStack demo.

Estimated Workshop Time: **90 minutes**

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano, Pat Shepherd, Linda Foinding
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
