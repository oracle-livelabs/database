# Introduction

## About This Workshop

Learn how to add keyword and semantic search to JSON movie data with Oracle Database API for MongoDB. Use SQL and `mongosh` with the same `MOVIES` collection. Load an in-database ONNX model. Generate summary embeddings and create text and vector indexes. Then compare keyword, fuzzy, semantic, filtered, and combined searches.

The workshop follows an incremental path. First, access a LiveLabs Sandbox or OCI tenancy and connect through SQL and the MongoDB API. Next, prepare the movie data and create search indexes. Finally, search movie summaries by meaning and combine keyword and vector results.

### **About Search**

Search helps users find useful information in a larger collection. A request may contain a known title, an incomplete phrase, a misspelling, or a description of an idea. The search system compares that request with indexed content and returns the most relevant results. Relevance describes how well each result answers the search request.

### **Why Search Matters**

Search is popular because users can reach useful content without learning the underlying data structure. Filters and navigation help when users already know that structure. Search helps when they know only a name, a phrase, or the idea they want to explore. Good search reduces the result set while preserving the items most useful to the request.

### **From Words to Meaning**

Keyword search matches the terms in a request with terms stored in the content. It works well for known titles, names, codes, and predictable filters. Fuzzy matching tolerates spelling differences, but it still searches for words rather than meaning.

Semantic search represents both content and the request as vectors. It compares those vectors to find content with similar meaning, even when the wording differs. This approach supports exploratory questions and natural-language requests.

Applications can combine keyword and vector results when users need both behaviors. Neither method is always best; the application requirement determines the right choice.

Estimated Workshop Time: 75 minutes

### Objectives

In this workshop, you will:

- Load a sample movie collection from a SQL worksheet
- Query the collection through both SQL and `mongosh`
- Load and verify an in-database ONNX embedding model
- Add summary embeddings to movie documents
- Create text and vector search indexes through the MongoDB API
- Compare exact, multi-term, and fuzzy keyword searches
- Run semantic searches with filters and sorting
- Combine keyword and vector result sets

### Prerequisites

- An Autonomous AI Database with Oracle Database API for MongoDB enabled
- The MongoDB API connection string and password for that database schema
- An embedding ONNX model stored in Oracle Object Storage or a pre-authenticated request (PAR) URL that the database can access

### **Workshop Flow**

1. Access the LiveLabs Sandbox or your OCI tenancy, install MongoDB Shell in Cloud Shell, and connect to the MongoDB API.
2. Load the movie collection and verify SQL, MongoDB API, and ONNX access.
3. Generate stored embeddings, create search indexes, and run a keyword query.
4. Run semantic searches against movie summaries and combine both approaches.

You are ready to start with the Get Started lab for your environment.

## Learn More

- [Oracle Database API for MongoDB Overview](https://docs.oracle.com/en/database/oracle/mongodb-api/mgapi/overview-oracle-database-api-mongodb.html)
- [Search on a Converged Data Platform](https://blogs.oracle.com/autonomous-ai-database/search-the-benefits-of-a-converged-data-platform)
- [Oracle AI Vector Search Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/index.html)

## Acknowledgements

- **Author** - Gael Palomino
- **Last Updated By/Date** - Gael Palomino, August 2026
- **Source** - [Search Examples using Oracle AI Database API for MongoDB](https://blogs.oracle.com/autonomous-ai-database/search-examples-using-oracle-ai-database-api-for-mongodb)
