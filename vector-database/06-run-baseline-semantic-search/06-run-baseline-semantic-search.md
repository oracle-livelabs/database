# Run Baseline Semantic Search

## Introduction

In this lab, you run semantic searches against the National Parks `parks` table and the bring-your-own-vector `weather` table. Text queries use the embedding model configured on `parks`; the `weather` search generates its query vector explicitly.

Estimated Time: X

### Objectives

- Run semantic searches with natural-language text.
- Search a bring-your-own-vector table with a precomputed query vector.
- Review formatted National Parks results.
- Understand how query text, `top_k`, and metadata filters affect results.
- Combine semantic search with metadata filters.

### Prerequisites

- Complete Lab 5: Create Embeddings and Load Text.
- Keep the `vecdb` client initialized in your OML Notebook.
- Load the National Parks records into the `parks` table, load the weather vectors into the `weather` table, and complete the `weather` vector index.

## Task 1: Search by Text

This task establishes the reusable query-and-display pattern used throughout the rest of the workshop.

1. Add a new Python paragraph and run the following code.

    `format_parks()` does not query the database. It formats `result.items` as a readable, numbered list of key-value fields used throughout this lab: `name`, `park_code`, `states`, and `description`. Set `include_weather=True` when displaying results from the BYO `weather` table to include the original weather information.

    ```python
    %python
    def format_parks(result, include_weather=False):
        formatted_items = []
        for i, r in enumerate(result.items or [], 1):
            metadata = r.metadata
            fields = [
                f"{i}. name: {metadata['name']}",
                f"park_code: {metadata['park_code']}",
                f"states: {metadata['states']}",
                f"description: {metadata['description']}",
            ]
            if include_weather:
                fields.append(f"weather_info: {metadata['weather_info']}")
            formatted_items.append("\n".join(fields))
        return "\n\n".join(formatted_items)
    ```

2. Add a new Python paragraph and run the following code.

    `table_name="parks"` selects the data to search. `query_by={"text": search_text}` tells the table to embed the natural-language text with its configured model. `top_k=5` returns the five most similar park records.

    ```python
    %python
    search_text = "historic battlefield from the civil war"

    result = vecdb.query(
        table_name="parks",
        query_by={"text": search_text},
        top_k=5,
    )

    print(format_parks(result))
    ```

3. Review the results. The table converts the query text into an embedding with its configured model, then returns the five closest park records. Notice that the query does not need to match a park description word-for-word; it searches for records semantically related to Civil War battlefields.

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
        top_k=5,
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
        top_k=5,
    )

    print(format_parks(result))
    ```

2. Review the results. Every returned record must satisfy the metadata conditions and be semantically relevant to the request. An empty result is also valid if no records meet both requirements.

## Task 4: Search the Bring-Your-Own-Vector Table

The `weather` table stores vectors generated and indexed in Lab 5 and does not have an integrated embedding configuration. To search it, generate an embedding for the query text with the same model, then pass that vector with `query_by={"vector": ...}`.

1. Add a new Python paragraph and run the following code.

    The metadata filter limits the weather search to parks in California or Arizona.

    ```python
    %python
    weather_query = "parks with snowfall"

    weather_embedding = vecdb.generate_embedding(
        model_name="all_MiniLM_L12_v2",
        inputs=[weather_query],
    )

    weather_result = vecdb.query(
        table_name="weather",
        query_by={"vector": weather_embedding.data[0].embedding},
        filters={"states": {"$in": ["CA", "AZ"]}},
        top_k=5,
    )

    print(format_parks(weather_result, include_weather=True))
    ```

2. Review the results. This query uses the same `format_parks()` helper, but the query vector is generated explicitly because `weather` is a bring-your-own-vector table. Every returned park must have `states` set to `CA` or `AZ` and be semantically relevant to snowfall. The output includes the original `weather_info` text, along with the other park metadata.

You now have a baseline semantic-search pattern for both integrated-embedding and bring-your-own-vector tables. Lab 7 reuses the integrated `parks` pattern and packages it as a read-only context-retrieval tool that an agent can call.


You may now **proceed to the next lab.**

## Learn More

- [Oracle VecDB Python SDK quick start](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/quickstart.html)
- [Oracle VecDB query response](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/response-objects/query-response.html)
- [Oracle VecDB generate embedding operation](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/generate-embedding.html)
- [Oracle VecDB record and metadata concepts](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/record.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - September 28, 2026
