# Run Baseline Semantic Search

## Introduction

In this lab, you run semantic searches against the National Parks `parks` table before creating a vector index. Each text query uses the embedding model configured on the table to generate its query vector.

Estimated Time: 10 minutes

### Objectives

- Run semantic searches with natural-language text.
- Review formatted National Parks results.
- Combine semantic search with metadata filters.

### Prerequisites

- Complete Lab 5: Create Embeddings and Load Text.
- Keep the `vecdb` client initialized in your OML Notebook.
- Load the National Parks records into the `parks` table.

## Task 1: Search by Text

1. Add a new Python paragraph. Copy the following function into it and run it.

    `format_parks` receives a query response and returns a readable, numbered list of park names, park codes, and states.

    <copy>
    ```python
    %python
    def format_parks(result):
        return "\n".join(
            f"{i}. {r.metadata['name']} ({r.metadata['park_code']}) – {r.metadata['states']}"
            for i, r in enumerate(result.items or [], 1)
        )
    ```
    </copy>

2. Add a new Python paragraph. Copy the following code into it and run it.

    <copy>
    ```python
    %python
    search_text = "historic battlefield from the civil war"

    result = vecdb.query(
        table_name="parks",
        query_by={"text": search_text},
        top_k=10,
    )

    print(format_parks(result))
    ```
    </copy>

3. Review the results. The table converts the query text into an embedding with its configured model, then returns the ten closest park records.

## Task 2: Search for Terms Not Present in the Text

1. Add a new Python paragraph. Copy the following code into it and run it.

    <copy>
    ```python
    %python
    search_text = "rock climbing near mountain lakes"

    result = vecdb.query(
        table_name="parks",
        query_by={"text": search_text},
        top_k=10,
    )

    print(format_parks(result))
    ```
    </copy>

2. Review the results. Semantic search can return parks related by meaning even when the exact query words do not appear in the park descriptions.

## Task 3: Add a Metadata Filter

1. Add a new Python paragraph. Copy the following code into it and run it.

    This query combines semantic similarity with metadata filters. It excludes the White House park record and limits results to parks in the District of Columbia or Maryland.

    <copy>
    ```python
    %python
    search_text = "We like waterfalls and other natural water features"

    result = vecdb.query(
        table_name="parks",
        query_by={"text": search_text},
        filters={
            "$and": [
                {"park_code": {"$ne": "whho"}},
                {"states": {"$in": ["DC", "MD"]}},
            ]
        },
        top_k=10,
    )

    print(format_parks(result))
    ```
    </copy>

2. Review the results. Every returned record meets the metadata conditions as well as the semantic-search request.

## Learn More

- [Oracle VecDB Python SDK quick start](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/quickstart.html)
- [Oracle VecDB query response](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/response-objects/query-response.html)
- [Oracle VecDB record and metadata concepts](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/record.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026
