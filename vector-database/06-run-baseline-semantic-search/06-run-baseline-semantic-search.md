# Run Baseline Semantic Search

## Introduction

In this lab, you run semantic searches against the National Parks `parks` table. Each text query uses the embedding model configured on the table to generate its query vector.

Estimated Time: X

### Objectives

- Run semantic searches with natural-language text.
- Review formatted National Parks results.
- Understand how query text, `top_k`, and metadata filters affect results.
- Combine semantic search with metadata filters.

### Prerequisites

- Complete Lab 5: Create Embeddings and Load Text.
- Keep the `vecdb` client initialized in your OML Notebook.
- Load the National Parks records into the `parks` table.

## Task 1: Search by Text

This task establishes the reusable query-and-display pattern used throughout the rest of the workshop.

1. Add a new Python paragraph and run the following code.

    `format_parks()` does not query the database. It formats `result.items` as a readable, numbered list of park names, park codes, and states. If a query returns no items, the function safely returns an empty string.

    ```python
    %python
    def format_parks(result):
        return "\n".join(
            f"{i}. {r.metadata['name']} ({r.metadata['park_code']}) – {r.metadata['states']}"
            for i, r in enumerate(result.items or [], 1)
        )
    ```

2. Add a new Python paragraph and run the following code.

    `table_name="parks"` selects the data to search. `query_by={"text": search_text}` tells the table to embed the natural-language text with its configured model. `top_k=10` returns the ten most similar park records.

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

3. Review the results. The table converts the query text into an embedding with its configured model, then returns the ten closest park records. Notice that the query does not need to match a park description word-for-word; it searches for records semantically related to Civil War battlefields.

## Task 2: Search for Terms Not Present in the Text

This task is a deliberate semantic-search test. The terms “rock climbing” and “mountain lakes” may not appear verbatim in every returned description, but parks with conceptually related activities or features can still rank highly.

1. Add a new Python paragraph and run the following code.

    Assigning new values to `search_text` and `result` replaces the prior notebook variables only. It does not change the `parks` table or its stored records.

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

2. Review the results. Semantic search can return parks related by meaning even when the exact query words do not appear in the park descriptions.

## Task 3: Add a Metadata Filter

Semantic relevance alone is often insufficient in a real application. Metadata filters let users apply business, geographic, or policy constraints while retaining meaning-based search.

1. Add a new Python paragraph and run the following code.

    `$and` requires both conditions. `$ne` excludes the `whho` White House record, and `$in` limits results to parks associated with the District of Columbia or Maryland.

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

2. Review the results. Every returned record must satisfy the metadata conditions and be semantically relevant to the request. An empty result is also valid if no records meet both requirements.

You now have a baseline semantic-search pattern. Lab 7 reuses this pattern and enriches it with prior user queries.


You may now **proceed to the next lab.**

## Learn More

- [Oracle VecDB Python SDK quick start](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/quickstart.html)
- [Oracle VecDB query response](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/response-objects/query-response.html)
- [Oracle VecDB record and metadata concepts](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/record.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026