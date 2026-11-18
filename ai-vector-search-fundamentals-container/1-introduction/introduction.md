# AI Vector Search with Private AI Services Container

## Introduction

Oracle AI Vector Search lets applications store, index, and search vector embeddings alongside relational business data in Oracle AI Database. This workshop adds Oracle Private AI Services Container as a private inference runtime next to Autonomous AI Database Serverless.

Estimated Workshop Time: 115 minutes

A vector embedding is a numerical representation of text, an image, or another unstructured object. Similar objects are placed near one another in the embedding space. Applications can therefore search by meaning or visual similarity instead of relying only on exact words and values.

Oracle AI Vector Search supplies the database capabilities needed for this workflow:

* **Vector data type** stores embeddings with relational data.
* **Vector distance functions** compare semantic similarity in SQL.
* **Vector indexes** accelerate nearest-neighbor searches.
* **Relational SQL** combines vector similarity with business filters, joins, security, and transactions.

Private AI Services Container supplies the inference runtime. It packages embedding and generative models behind local REST endpoints that can run on a separate Linux host. This architecture allows model inference to be scaled independently from the database. The runtime can use multiple CPU cores and supported GPU infrastructure, while the database remains focused on managing and searching data.

Keeping inference on privately managed infrastructure also provides more control over model selection and deployment. Models can be prepared in the image and used without downloading them at workshop runtime, which is useful for restricted or disconnected environments.

The workshop uses an open provider pattern. `DBMS_VECTOR.UTL_TO_EMBEDDING` receives the model provider, endpoint, and model name as JSON. Changing those values allows the same SQL interface to work with database-resident models, OCI services, or the Private AI Services Container. In these labs, the provider is `privateai`.

### Workshop Architecture

The workshop environment contains:

* Autonomous AI Database Serverless with a public Database Actions endpoint for the attendee
* A Private AI Services Container running on OCI Compute
* Private network connectivity from the database endpoint to the container
* Text, image, and generative models already available in the container image
* A National Parks relational dataset and a curated image BLOB dataset

The workshop uses HTTP on the private network so that the exercises remain focused on vector and AI operations. Production deployments should use HTTPS, certificate validation, narrower network rules, and the authentication controls appropriate for the environment.

You will first generate text embeddings through the container and store them in the database. You will then run exact and indexed similarity searches. The image lab uses the container's paired CLIP models to compare text and image BLOBs in the same vector space. The final exercises generate text with the container-hosted LLM, use the vector data in APEX, and build a retrieval-augmented generation flow.

### Objectives

In this workshop, you will:

* Connect Autonomous AI Database Serverless to Private AI Services Container
* Inspect the models exposed by the container
* Generate and store text embeddings through a private REST endpoint
* Perform exact similarity searches with SQL
* Create an HNSW vector index and perform approximate searches
* Generate compatible text and image vectors with CLIP
* Combine vector similarity with relational filters and joins
* Generate text from SQL and PL/SQL with a container-hosted LLM
* Explore an APEX application built on the same vector data
* Build a retrieval-augmented generation flow with a container-hosted LLM

### Prerequisites

This lab assumes you have:

* An Oracle account
* A provisioned workshop reservation
* Access to Database Actions SQL Worksheet

## Dataset

This workshop uses National Parks data derived from the [US National Park Service](https://www.nps.gov/subjects/science/science-data.htm).

* `PARKS` contains park descriptions and relational location data.
* `PARK_IMAGES_BLOB` contains approximately 2,000 curated image BLOBs, source attribution, descriptive metadata, and container-generated image vectors.
* `SUPPORT_INCIDENTS` contains synthetic support records used by the RAG exercise.

The image bytes are prepared before the workshop and stored in the database. The exercises do not depend on downloading images from public web servers at runtime.

## Tools

You will use Database Actions SQL Worksheet to run SQL and PL/SQL. Its public URL is provided in the workshop login information. The Private AI Services Container remains on the workshop network; you call it from the database rather than opening it directly in your browser.

The APEX exercises use application URLs listed in the workshop login information.

## Learn More

* [Oracle AI Vector Search User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/index.html)
* [Oracle Private AI Services Container User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/prvai/)
* [Getting Started with Private AI Services Container](https://blogs.oracle.com/database/getting-started-with-private-ai-services-container)
* [Use Private AI Services Container with HTTP in PL/SQL](https://blogs.oracle.com/coretec/how-to-use-the-oracle-private-ai-services-container-with-http-in-pl-sql)

## Acknowledgements

* **Author** - Andy Rivenes, Product Manager, AI Vector Search
* **Contributors** - Markus Kissling, David Start
* **Last Updated By/Date** - David Start, August 2026
