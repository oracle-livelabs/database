# From Search to AI Agents with JSON-Relational Duality Views

## Introduction

This workshop is Part 2 of a movie-search learning path. [Part 1: Search Using MongoDB API for Oracle AI Database](https://github.com/gpalominoc/database/tree/main/search-using-mongodb-api) explores keyword, semantic, and combined search from MongoDB Shell. Here, you will explore the database structures behind search with SQL. You will then build a JSON document interface with JSON-relational duality views.

Modernizing an application often means adding JSON interfaces and search to data already stored in a database. Duality Views let applications consume JSON documents while SQL continues to work with the underlying tables. You will build a movie-search data layer in Oracle AI Database. It combines document access, semantic search, and independent embedding models.

The movie catalog illustrates these needs. A user might know an exact title, describe a theme, or ask which movie fits a particular situation. Each request calls for a different way to find and present information. You will build these search capabilities over shared movie data, keeping one copy of the source documents.

The workshop progresses from SQL search to a JSON document interface and then an AI agent. Along the way, you will compare embedding models and inspect how the database retrieves results. You will see how these pieces work together and where each belongs in an application.

Estimated Workshop Time: 60–90 minutes

### Prerequisites

- Familiarity with the search concepts in Part 1 is recommended. This workshop includes its own data setup and does not require objects created in Part 1.
- Autonomous AI Database 26ai with AI Vector Search enabled.
- SQL worksheet or SQLcl access.
- Either an ONNX embedding model available to the database or access to an Oracle Cloud Infrastructure Object Storage bucket for uploading the provided models.
- **Lab 5 requires a paid OCI tenancy** with access to OCI Generative AI.

### Objectives

- Keep JSON movie data independent from its embedding columns.
- Run text and semantic searches with SQL.
- Compare embedding models and migrate search without rewriting the movie JSON.
- Use a duality view to expose movie data and search metadata as one JSON document.
- Verify vector index access when retrieving search results as documents.
- Build a Select AI agent grounded in movie search.

## About this workshop

Imagine adding a discovery assistant to a movie catalog. The catalog already supports reporting and maintenance through SQL. The assistant needs JSON responses and searches based on story themes. Duality Views let both applications use the same stored data. Teams can add a document interface without maintaining and synchronizing another catalog. The same approach suits a retailer adding product discovery or a support team building a knowledge portal over existing records.

Search also needs room to evolve. A model that works well for short movie descriptions might perform differently on multilingual content or specialized terminology. Separate embedding columns let teams compare models over the same records and migrate search at their own pace. Each model has its own vector column and index, while the Duality View presents the selected data as documents. Direct SQL lets you manage these structures and inspect search plans, extending the collection-oriented approach from Part 1.

The agent turns search results into a conversation. A user might ask, "Which movies feature a rescue mission, and what are they about?" A movie-search tool retrieves relevant documents. Select AI uses those documents to compose a response grounded in the catalog. This retrieval-augmented generation pattern also suits shopping assistants that explain product options and support assistants that answer questions from relevant articles. You will inspect the retrieved documents alongside the response to understand how the agent uses database content.

## Learn More

- [Part 1: Search Using MongoDB API for Oracle AI Database](https://livelabs.oracle.com/ords/dbpm/r/livelabs/view-workshop?wid=4518)
- [Oracle AI Vector Search Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/index.html)
- [JSON-Relational Duality Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/index.html)
- [Overview of JSON-Relational Duality Views](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/overview-json-relational-duality-views.html)
- [Generate Embeddings](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/generate-embeddings.html)

## Acknowledgements

* **Author** - Gael Palomino
* **Last Updated By/Date** - Gael Palomino, November 2026
