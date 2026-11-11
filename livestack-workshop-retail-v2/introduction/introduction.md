# Build Connected Retail Solutions with Oracle AI Database

## Introduction

Jessica Chan is the database administrator at Seer Sporting Goods. Monday starts with a demand spike in trail-running products. Her colleagues need order documents for the shopping application, relevant product matches, creator relationships, fulfillment options, demand scores, and answers they can take into a review meeting.

The product and order records are already in Oracle AI Database. Each colleague needs a different way to work with them:

- Thomas needs orders and their items as JSON for a web and mobile application.
- Gilly needs semantic search that finds products related to a retail operations question.
- Bob needs to follow creator connections and the brands they promote.
- Moon needs to calculate distances between customers, fulfillment centers, and demand regions.
- Otto needs to train and score a product demand model.
- Nina needs to ask retail questions in ordinary language and check the answers against database results.

![The Seer Sporting Goods team](images/team.png)

<video controls width="100%">
  <source src="https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/livestack/Videos/Retail/Workshop/Retail-Scene-00-Opening.mp4">
  Your browser does not support the video tag.
</video>

Jessica helps each team use the existing records in the form its application needs. Relational tables remain the source for products and orders. JSON documents, vectors, graph relationships, spatial calculations, machine learning, and AI-assisted SQL work alongside those records.

Follow Jessica and her colleagues as they review product attention, inspect orders, find related products, trace creator relationships, compare fulfillment options, review model scores, and query retail data through an AI assistant. Each lab addresses one requirement and introduces the next colleague’s question.

### What the team builds

| Team member | Requirement | What you will see |
| --- | --- | --- |
| Jessica, DBA | Build the query behind a retail review dashboard. | One SQL result combines product signals, semantic matches, JSON order activity, and regional location context. |
| Thomas, application developer | Give the application flexible order documents. | JSON columns, JSON collections, and JSON Relational Duality Views provide three ways to serve application data. |
| Gilly, AI engineer | Find products related to an operations question. | An in-database ONNX model creates product vectors; search results connect to existing orders and customers. |
| Bob, graph specialist | Investigate creator and brand relationships. | Relational joins and a property graph expose direct connections, longer paths, and shared brands. |
| Moon, spatial expert | Compare fulfillment options for customers and regions. | Geographic calculations combine with recorded stock, while maps show the same locations. |
| Otto, data scientist | Build a product demand watchlist. | Oracle Machine Learning trains and scores a demonstration model beside product and activity data. |
| Nina, retail analyst | Ask retail questions without writing every query from scratch. | Select AI exposes generated SQL for review; Select AI Agent adds a defined SQL tool and execution history. |

Jessica's first query combines relational, JSON, vector, and spatial evidence. Later labs explore graph relationships, machine learning, and AI in their own tasks. A location is useful context, a vector score measures semantic proximity, and a model score supports review; none of these alone establishes future demand or a delivery promise.

<details>
<summary><strong>Learn more: What does “converged database” mean?</strong></summary>

> A converged database supports different data types and workloads on one database foundation. Here, relational rows, JSON documents, vectors, graphs, geographic data, machine learning models, and AI-assisted SQL support different requirements while keeping the business records and database privileges connected.
>
> Thomas can use an order as a document while Gilly joins its items to a search result. Bob, Moon, Otto, and Nina can add their analyses without making a separate operational copy for each capability. Where a lab creates a demonstration copy or scoring table, it explains that table's purpose.

</details>

### Objectives

- Follow Jessica's team through connected retail application and analysis requirements.
- Combine relational, JSON, vector, graph, spatial, machine-learning, and AI capabilities in practical tasks.
- Create and update an order document over the existing relational records.
- Connect product search, creator relationships, location, stock, and model scores to business questions.
- Inspect generated SQL and the actual tool history behind an AI-assisted answer.
- Relate the database results to the Seer Sporting Goods Retail LiveStack application.

Estimated Workshop Time: **130 minutes**, including Getting Started and the quiz, plus optional Studio and AutoML exploration.

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Contributor** - Teodor C. Nechita
* **Last Updated By/Date** - Teodor C. Nechita, October 2026
