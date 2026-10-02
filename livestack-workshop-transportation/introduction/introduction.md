# Build Connected Transportation Solutions with Oracle AI Database

## Introduction

Seer Transport operates regional passenger service across routes, stations, and scheduled trips. When a disruption affects a busy corridor, its team needs to see which services and passengers are affected, where capacity is available, and what to do next.

Jessica Chan, the database administrator, helps the team answer those questions from connected data in Oracle AI Database. Each colleague has a different task:

- Thomas Brune, application developer, needs booking data as JSON for a passenger application.
- Gilly Bourne, AI engineer, needs to find affected services from an ordinary language description of a disruption.
- Bob Green, graph specialist, needs to follow a disruption through connected trips, routes, stations, and vehicles.
- Moon Kai, spatial specialist, needs to match passengers in a service region with nearby stations.
- Otto Spencer, data scientist, needs to identify services likely to see a demand surge.
- Nina Patel, operations analyst, needs to ask questions about ridership and fare revenue using approved data.

These tasks share a business goal: restore reliable service and give passengers clear options. The workshop follows one governed database foundation through relational SQL, JSON, vectors, property graphs, spatial analysis, Oracle Machine Learning, Select AI, and Select AI Agent.

### What the team builds

| Lab | Transportation decision | Oracle capability |
| --- | --- | --- |
| 1. Operations dashboard | Rank disrupted services with booking activity, semantic matches, and nearby station context. | Converged SQL across relational, vector, JSON, and spatial data. |
| 2. Booking application | Serve and update one booking document while keeping relational records. | Native JSON, JSON collections, and JSON Relational Duality. |
| 3. Semantic search | Find services relevant to a disruption and identify affected passengers. | In-database embeddings and AI Vector Search. |
| 4. Service network | Trace connected trips, routes, stations, vehicles, and disruption cases. | Property Graph and SQL/PGQ. |
| 5. Station access | Identify passengers in a service region and the nearest active station. | Oracle Spatial and GeoJSON. |
| 6. Demand watchlist | Rank services that may need more capacity. | Oracle Machine Learning classification and scoring. |
| 7. Ask the data | Inspect generated SQL before using an answer about service and fare activity. | Select AI. |
| 8. Govern an agent | Run a read-only transportation question through an approved SQL tool. | Select AI Agent and execution history. |

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
* **Last Updated By/Date** - Oracle Database Product Management, October 2026
