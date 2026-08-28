# Lab 7: Create a Query Memory Module

## Introduction

Create a small query-memory module for the National Parks application. It saves each query in an integrated embedding table. For each new request, it combines prior queries with current text. It then generates one embedding and searches `parks`.

Estimated Time: 15 minutes

### Objectives

- Create a memory table that automatically embeds saved queries.
- Store a user query with user and timestamp metadata.
- Combine prior queries with a new request.
- Search parks with a memory-aware query vector.

### Prerequisites

- Complete Lab 6: Run Baseline Semantic Search.
- Keep the `vecdb` client initialized in your OML Notebook.
- Keep the `format_parks` function from Lab 6 available.

## Task 1: Create the Query Memory Table

The memory table stores prior queries as metadata. Its integrated embedding configuration uses `query_text`. The database creates an embedding whenever you save a query.

1. Add a new Python paragraph. Copy the following code into it and run it to identify the current user and import the timestamp utilities.

    Replace `Brian` with an appropriate user identifier for your test.

    <copy>
    ```python
    %python
    from datetime import datetime, timezone

    user = "Brian"
    ```
    </copy>

2. Add a new Python paragraph. Copy the following code into it and run it to create the memory table.

    <copy>
    ```python
    %python
    vecdb.create_vector_table(
        name="park_query_memory",
        comment="User query memory for the National Parks LiveLab",
        table_params={"auto_generate_id": True},
        embed_params={
            "model": "all_MiniLM_L12_v2",
            "embed_metadata_jsonpath": "query_text",
        },
    )
    ```
    </copy>

3. Confirm that the paragraph completes without an error. The table generates IDs and embeddings automatically when you save query metadata.

## Task 2: Store an Initial Query

This task runs a normal semantic search. It then saves the query text, user identifier, and UTC timestamp in the memory table. Future searches can use the saved query.

1. Add a new Python paragraph. Copy the following code into it and run it.

    <copy>
    ```python
    %python
    search_text = "We like waterfalls and other natural water features"

    result = vecdb.query(
        table_name="parks",
        query_by={"text": search_text},
        top_k=10,
    )

    metadata = {
        "query_text": search_text,
        "current_user": user,
        "created_at_utc": datetime.now(timezone.utc).isoformat(),
    }

    vecdb.upsert_vectors(
        table_name="park_query_memory",
        vectors=[{"metadata": metadata}],
    )

    print(format_parks(result))
    ```
    </copy>

2. Review the results. The final upsert stores the query in `park_query_memory`; its `query_text` field is embedded automatically by the table definition.

## Task 3: Combine Memory with a New Query

The next query asks about picnics. Retrieve saved query text from the memory table. Combine it with the current query and generate one embedding. The resulting vector reflects water-feature and picnic interests.

1. Add a new Python paragraph. Copy the following code into it and run it to retrieve prior query text.

    <copy>
    ```python
    %python
    all_memory = vecdb.list_vectors(
        table_name="park_query_memory",
    )

    all_query_text = " ".join(
        item.metadata["query_text"]
        for item in all_memory.items
    )

    print(all_query_text)
    ```
    </copy>

2. Add a new Python paragraph. Copy the following code into it and run it to create the combined query embedding.

    <copy>
    ```python
    %python
    new_search_text = "We also like picnics, so are any parks good for picnics."

    new_embedding = vecdb.generate_embedding(
        model_name="all_MiniLM_L12_v2",
        inputs=[all_query_text + " " + new_search_text],
    )
    ```
    </copy>

3. For a production memory module with many saved queries, page through `list_vectors()` rather than relying on its default page size.

## Task 4: Search with Query Memory

Save the current query for future requests. Then use the combined embedding to search `parks`. This time, `query_by` receives a dense vector instead of text.

1. Add a new Python paragraph. Copy the following code into it and run it to save the current query.

    <copy>
    ```python
    %python
    metadata = {
        "query_text": new_search_text,
        "current_user": user,
        "created_at_utc": datetime.now(timezone.utc).isoformat(),
    }

    vecdb.upsert_vectors(
        table_name="park_query_memory",
        vectors=[{"metadata": metadata}],
    )
    ```
    </copy>

2. Add a new Python paragraph. Copy the following code into it and run it to search with the combined vector.

    <copy>
    ```python
    %python
    result = vecdb.query(
        table_name="parks",
        query_by={"vector": new_embedding.data[0].embedding},
        top_k=10,
    )

    print(format_parks(result))
    ```
    </copy>

3. Add a new Python paragraph. Copy the following code into it and run it to view the matching park descriptions.

    <copy>
    ```python
    %python
    for i, r in enumerate(result.items, 1):
        m = r.metadata
        print(f"{i}. {m['name']} – {m['states']}  {m['description']}")
    ```
    </copy>

4. Compare these results with a picnic-only search. The memory-aware query also includes the earlier interest in natural water features.

## Learn More

- [Oracle VecDB integrated embedding and bring-your-own-vector tables](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/vector-table.html)
- [Oracle VecDB Python SDK API reference](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/python-api-reference.html)
- [Oracle VecDB query response](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/response-objects/query-response.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026

