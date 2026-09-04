# Lab 7: Create a Query Memory Module

## Introduction

Create a lightweight query-history memory pattern for the National Parks application. It saves each query in an integrated embedding table. For each new request, it combines prior query text with the current text, generates one embedding, and searches `parks`.

This is not a complete conversational-memory system. It is a practical starting point that shows how durable query history can influence a later search and provides a foundation for more advanced semantic memory retrieval.

Estimated Time: X

### Objectives

- Create a memory table that automatically embeds saved queries.
- Store a user query with user and timestamp metadata.
- Understand the difference between saving query history and using that history to influence a later search.
- Combine prior queries with a new request.
- Search parks with a memory-aware query vector.

### Prerequisites

- Complete Lab 6: Run Baseline Semantic Search.
- Keep the `vecdb` client initialized in your OML Notebook.
- Keep the `format_parks` function from Lab 6 available.

## Task 1: Create the Query Memory Table

The memory table stores prior queries as metadata and automatically generates an embedding from `query_text`. This preserves both a readable query history and a vector representation that you can use for semantic memory retrieval in a more advanced application.

1. Add a new Python paragraph and run the following code to identify the current user and import timestamp utilities.

    Replace `Brian` with an appropriate user identifier for your test. This is a workshop identifier, not an authenticated user identity. The UTC timestamp records when a query is saved in a portable ISO 8601 format.

    ```python
    %python
    from datetime import datetime, timezone
    user = "Brian"
    ```

2. Add a new Python paragraph and run the following code to create the memory table.

    `embed_metadata_jsonpath: "query_text"` is the table's embedding rule. Each metadata-only upsert that contains `query_text` automatically creates and stores a dense vector. `auto_generate_id=True` assigns an ID to each saved query.

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

3. Confirm that the paragraph completes without an error. The table is now ready to save query metadata and automatically embed its `query_text` field.

## Task 2: Store an Initial Query

This task runs a normal semantic search, then saves the query text, user identifier, and UTC timestamp in the memory table. Saving the query does not affect the current search result; it creates memory for future requests.

1. Add a new Python paragraph and run the following code.

    `query_text` is the saved request and the field the memory table embeds. `current_user` identifies the memory owner, and `created_at_utc` records when the query was created. The upsert sends metadata only because `park_query_memory` is an integrated embedding table with auto-generated IDs.

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

2. Review the results. The printed parks come from the normal semantic search. The final upsert stores the query in `park_query_memory`, and the table automatically embeds its `query_text` field for future use.

## Task 3: Combine Memory with a New Query

The next query asks about picnics. This simple example retrieves saved query text for the current user, combines it with the new query, and generates one embedding. The resulting vector reflects both water-feature and picnic interests.

Although the memory table stores embeddings, this introductory pattern retrieves and combines saved **text** rather than performing semantic retrieval over the memory table. This keeps the flow easy to follow; a production system can use memory-table similarity search to select the most relevant history.

1. Add a new Python paragraph and run the following code to retrieve prior query text for the current user.

    `list_vectors()` retrieves the saved memory records. The user check prevents one user's history from influencing another user's search. `all_memory.items or []` also keeps the code safe when no records are returned.

    ```python
    %python
    all_memory = vecdb.list_vectors(
        table_name="park_query_memory",
    )

    all_query_text = " ".join(
        item.metadata["query_text"]
        for item in all_memory.items or []
        if item.metadata.get("current_user") == user
    )

    print(all_query_text)
    ```

2. Add a new Python paragraph and run the following code to create the combined query embedding.

    `inputs` is a list because `generate_embedding()` can process one or more text values. This example provides one combined text value, so `new_embedding.data[0].embedding` selects the single returned vector.

    ```python
    %python
    new_search_text = "We also like picnics, so are any parks good for picnics."

    new_embedding = vecdb.generate_embedding(
        model_name="all_MiniLM_L12_v2",
        inputs=[all_query_text + " " + new_search_text],
    )
    ```

3. For a production memory module with many saved queries, page through `list_vectors()` rather than relying on its default page size. Define a retrieval policy as well, such as filtering by user, recency, relevance, or a combination of those factors.

## Task 4: Search with Query Memory

Save the current query for future requests. Then use the combined embedding to search `parks`. The combined embedding was created in Task 3 before the picnic query is saved here, so the current request is not added twice to its own search context.

1. Add a new Python paragraph and run the following code to save the current query.

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

2. Add a new Python paragraph and run the following code to search with the combined vector.

    `query_by={"vector": ...}` bypasses automatic query-text embedding because the code already supplies a dense vector. The vector is compatible with `parks` because both use `all_MiniLM_L12_v2`.

    ```python
    %python
    result = vecdb.query(
        table_name="parks",
        query_by={"vector": new_embedding.data[0].embedding},
        top_k=10,
    )

    print(format_parks(result))
    ```

3. Add a new Python paragraph and run the following code to view the matching park descriptions.

    The descriptions help you inspect why the memory-aware results may be relevant, not merely compare park names.

    ```python
    %python
    for i, r in enumerate(result.items, 1):
        m = r.metadata
        print(f"{i}. {m['name']} – {m['states']}  {m['description']}")
    ```

4. Review the results. The memory-aware search may reflect both the new picnic interest and the earlier interest in natural water features. In a production application, use a defined retrieval policy to decide which saved queries should influence the current request.


You may now **proceed to the next lab.**

## Learn More

- [Oracle VecDB integrated embedding and bring-your-own-vector tables](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/vector-table.html)
- [Oracle VecDB Python SDK API reference](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/python-api-reference.html)
- [Oracle VecDB query response](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/response-objects/query-response.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026