# Build Connected Transportation Solutions with Oracle AI Database

## Introduction

Seer Transport operates regional passenger service across routes, stations, and scheduled trips. When a busy corridor is disrupted, dispatchers need to identify affected services and passengers, check available capacity, and decide where to respond first.

Jessica Chan, the database administrator, helps the team answer those questions from connected data in Oracle AI Database. Each colleague has a different task:

- Thomas Brune, application developer, needs booking data as JSON for a passenger application.
- Gilly Bourne, AI engineer, needs to find services related to a plain-language description of a disruption.
- Bob Green, graph specialist, needs to follow a disruption through connected trips, routes, stations, and vehicles.
- Moon Kai, spatial specialist, needs to match passengers in a service region with nearby stations.
- Otto Spencer, data scientist, needs to identify services likely to see a demand surge.
- Nina Patel, operations analyst, needs to ask questions about ridership and fare revenue using approved data.

Jessica's team shares one business goal: restore reliable service and give passengers clear options. Each specialist starts with a different operational question, then works with the same service, trip, booking, passenger, and station records in Oracle AI Database. The labs cover the initial disruption review, booking and passenger analysis, and an assistant that answers questions through an approved SQL tool.

### What the team builds

| Lab and team member | Transportation decision | Oracle capability |
| --- | --- | --- |
| 1. Jessica, operations dashboard | Rank services for disruption review using text similarity, booking activity, and nearby stations. | Converged SQL across relational, vector, JSON, and spatial data. |
| 2. Thomas, booking application | Serve and update a booking document while keeping relational records. | Native JSON, JSON collections, and JSON Relational Duality. |
| 3. Gilly, semantic search | Find services relevant to a disruption and identify passengers who may need help. | In-database embeddings and AI Vector Search. |
| 4. Bob, service network | Trace connected trips, routes, stations, vehicles, and disruption cases. | Property Graph and SQL/PGQ. |
| 5. Moon, station access | Identify passengers in a service region and the nearest active station. | Oracle Spatial and GeoJSON. |
| 6. Otto, demand watchlist | Rank services that may need more capacity and review the activity behind each score. | Oracle Machine Learning classification and scoring. |
| 7. Nina, ask the data | Inspect generated SQL before using an answer about service and fare activity. | Select AI. |
| 8. Nina and Jessica, govern an agent | Run an operations question through an approved SQL tool and review its history. | Select AI Agent and execution history. |

<details>
<summary><strong>What is a converged database?</strong></summary>

> Oracle AI Database supports multiple data types and workloads in one database. Here, booking rows, JSON documents, service descriptions, network relationships, station locations, model scores, and AI-assisted SQL stay connected to the same governed records.

</details>

### Objectives

- Use each database capability to answer a transportation operations question.
- Trace results back to the SQL and data behind them.
- Explain how the same service, trip, booking, and passenger records support different application and analysis needs.
- Review the scope of AI profiles and agent tools before trusting a generated answer.

Estimated Workshop Time: **90 minutes**

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Contributor** - Teodor Constantin Nechita
* **Last Updated By/Date** - Teodor Constantin Nechita, October 2026
