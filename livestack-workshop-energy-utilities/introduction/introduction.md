# Build Connected Energy & Utilities Solutions with Oracle AI Database

## Introduction

Jessica Chen, the DBA at Seer Utility Network, starts the morning with a question from utility operations. A field team has reported a gas pipeline pressure concern. Which service requests involve the affected services, and what should the team check before arranging field follow-up?

<video controls width="100%">
  <source src="https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/livestack%2FVideos%2FUtilities%2FWorkshop%2FScene-00-Meet-the-Seer-Utility-Network-Team-Branded.mp4">
  Your browser does not support the video tag.
</video>

![Jessica and Thomas connect a pipeline pressure concern to service requests and field follow-up at Seer Utility Network.](images/seer-utility-network-introduction.png)

Jessica brings the team together around the records in Oracle AI Database. Follow each specialist as they build a dashboard, serve service-request documents, investigate operational signals, and plan a response. Before assigning field work, operations must still check asset condition, crew qualifications, site access, and available supplies. A database result supports that review; it does not authorize a dispatch.

### Seer Utility Network data model

Seer Utility Network is a fictional energy and utilities operator. This diagram shows the core service-request relationships used by the LiveStack: service points submit requests, field logistics sites support requests, and each request contains items for utility services or supplies.

![Seer Utility Network core ERD: service points and field logistics sites each connect to many service requests; service requests and utility services each connect to many request items.](images/seer-utility-network-erd.png)

The diagram connects service points (`CUSTOMERS`), service requests (`ORDERS`), and utility services and supplies (`PRODUCTS`). The workshop keeps these table names and relationships; Utilities views give them names that match the business. A service request does not need an assigned field site, although the diagram does not show this optional link.

[Open the full-size diagram](images/seer-utility-network-erd.png).

### What the team builds

| Team member | Your task |
| --- | --- |
| Jessica, DBA | Combine reliability signals, JSON service requests, semantic matches, and locations in one dashboard query. |
| Thomas, application developer | Compare JSON storage options and create and update service-request documents through a duality view. |
| Gilly, AI engineer | Search utility services by meaning and identify service points with related requests. |
| Bob, graph specialist | Trace operational events through assets, inspections, crews, and shared restoration records. |
| Moon, spatial specialist | Find service points in a territory and compare their nearest active field logistics sites. |
| Otto, data scientist | Train a service-demand model and build a service activity watchlist. |
| Nina, operations analyst | Ask questions with Select AI, then build an agent with an approved SQL tool. |

<details>
<summary><strong>What does "converged database" mean?</strong></summary>

> A **converged database** handles several data types and kinds of work in one database. Here, teams use relational rows, JSON documents, vectors, graphs, geographic data, machine learning models, and AI-assisted SQL.
>
> Teams use the form their application needs and keep the records and access controls together. They can query these data types without maintaining a separate store for each one.

</details>

### Objectives

- Run queries across relational, JSON, vector, graph, and spatial data.
- Train a service-demand model and use Select AI and Select AI Agent to query the Utilities schema.
- Interpret results, check database permissions and AI profile settings, and review the agent's tool history.
- Connect each database exercise to the Seer Utility Network application without maintaining separate copies of the operational records.

Estimated Workshop Time: **90 minutes**, with additional time for the optional AutoML experiment.

## Application example

Follow the [Energy & Utilities LiveStack runbook workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?wid=4429) to explore the demo application.

The application follows a Gulf Coast resilience event across electricity, gas, water and wastewater, and oil-and-gas operations. Its pages connect operational signals, restoration relationships, field logistics, service requests, analytics, and AI-assisted questions. The workshop begins with one pressure concern so you can follow the data and SQL step by step.

![LiveStack Energy & Utilities Demo: Welcome](images/demo-welcome.jpg)

*LiveStack Energy & Utilities Demo: Welcome*

## Acknowledgements

* **Authors** - Matt Kowalik
* **Contributors** - Teodor C. Nechita
* **Last Updated By/Date** - Teodor C. Nechita, October 2026
