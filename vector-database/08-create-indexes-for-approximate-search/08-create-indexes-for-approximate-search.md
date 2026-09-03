# Create Indexes for Approximate Search

## Introduction

This optional lab compares two approximate nearest-neighbor index organizations using the same National Parks data and the same query vector. The existing `parks` table uses the SDK's default IVF index organization. You will create `parks_HNSW` with an HNSW index, load the same records, and measure query time against both tables.

The goal is to understand the comparison method, not to guarantee that one table is always faster. With a small data set, network and service latency can outweigh index differences. In larger workloads, HNSW is often suited to high-throughput, low-latency search, while IVF can be more memory-efficient at scale.

Estimated Time: X

### Objectives

- Create an integrated embedding table with an HNSW vector index.
- Load the same National Parks records into `parks_HNSW`.
- Generate one query vector from text and reuse it for a fair timing comparison.
- Compare repeated query timing for the IVF-backed `parks` table and the HNSW-backed `parks_HNSW` table.

### Prerequisites

- Complete Lab 5: Create Embeddings and Load Text.
- Keep the `vecdb` client initialized in your OML Notebook.
- Keep `park_data_json` available from Lab 5.
- Keep the `parks` table created in Lab 4 and loaded in Lab 5.

## Task 1: Create an HNSW Vector Table

The `parks` table uses the SDK's default `PARTITIONS` organization, which creates an IVF index. In this task, you create a second integrated embedding table with `organization: "INMEMORY GRAPH"`, which creates an HNSW index. Both tables use the same embedding model and the same `description` metadata field, making them suitable for a controlled comparison.

1. Add a new Python paragraph and run the following code.

    `neighbors` controls the maximum number of graph connections for each vector, and `efConstruction` controls the candidate search breadth while building the graph. `distribute_method: "AUTO"` lets the database choose the appropriate HNSW distribution strategy. These values provide a practical HNSW starting point for this workshop.

    ```python
    %python
    vecdb.create_vector_table(
        name="parks_HNSW",
        comment="National Parks with an HNSW vector index",
        table_params={"auto_generate_id": True},
        embed_params={
            "model": "all_MiniLM_L12_v2",
            "embed_metadata_jsonpath": "description",
        },
        index_params={
            "vector_index_params": {
                "auto_index": True,
                "organization": "INMEMORY GRAPH",
                "distance_metric": "COSINE",
                "distribute_params": {
                    "distribute_method": "AUTO",
                },
                "advanced_params": {
                    "neighbors": 32,
                    "efConstruction": 200,
                },
            }
        },
    )
    ```

2. Confirm that the paragraph completes without an error. The table has the same integrated embedding behavior as `parks`, but its vector index organization is HNSW rather than IVF.

    Run this creation paragraph once. If `parks_HNSW` already exists from an earlier attempt, continue to Task 2 instead of creating it again.

## Task 2: Load National Parks Data into `parks_HNSW`

To compare index behavior, both tables must contain the same records. This task creates metadata-only records from the same `park_data_json` object used in Lab 5. Because `parks_HNSW` is an integrated embedding table, the database automatically embeds each record's `description` value during the upsert.

1. Add a new Python paragraph and run the following code.

    The record structure matches the `parks` load: each item contains `metadata`, records without a `description` are excluded, and the table generates IDs automatically.

    ```python
    %python
    parks_hnsw_data = [
        {"metadata": park}
        for park in park_data_json
        if park.get("description")
    ]

    print(f"Prepared {len(parks_hnsw_data):,} park records for parks_HNSW.")
    ```

2. Add a new Python paragraph and run the following code.

    The upsert stores the metadata, generates a vector from `description`, and maintains the HNSW index for the new record.

    ```python
    %python
    hnsw_upsert_result = vecdb.upsert_vectors(
        table_name="parks_HNSW",
        vectors=parks_hnsw_data,
    )

    print(hnsw_upsert_result)
    ```

3. Review the output. Confirm that the number of uploaded records matches the number of prepared records. As with `parks`, rerunning this upsert creates additional records because the table auto-generates IDs.

## Task 3: Compare IVF and HNSW Query Timing

Use the same text request for both tables. The code first generates one query vector from the text, outside the timed section. It then reuses that vector for repeated searches against `parks` and `parks_HNSW`. This avoids measuring text-embedding time as part of the index comparison.

1. Add a new Python paragraph and run the following code.

    The timings include the end-to-end SDK query call, including service and network latency. Running each query ten times and comparing the average and minimum duration reduces the effect of a single slow request.

    ```python
    %python
    from statistics import mean
    from time import perf_counter

    search_text = "historic battlefield with natural water features"

    query_embedding = vecdb.generate_embedding(
        model_name="all_MiniLM_L12_v2",
        inputs=[search_text],
    ).data[0].embedding

    def time_vector_query(table_name, runs=10):
        durations_ms = []
        last_result = None

        for _ in range(runs):
            start_time = perf_counter()
            last_result = vecdb.query(
                table_name=table_name,
                query_by={"vector": query_embedding},
                top_k=10,
            )
            durations_ms.append((perf_counter() - start_time) * 1000)

        return last_result, durations_ms

    for table_name in ["parks", "parks_HNSW"]:
        result, durations_ms = time_vector_query(table_name)
        print(f"\n{table_name}")
        print(f"Average: {mean(durations_ms):.2f} ms")
        print(f"Minimum: {min(durations_ms):.2f} ms")
        print(f"Maximum: {max(durations_ms):.2f} ms")
        print(f"Results returned: {len(result.items or [])}")
    ```

2. Compare the output. The two tables receive the same query vector and contain the same source records, so the timing difference reflects the two query paths more fairly than timing two separate text queries.

    Do not expect a fixed winner with this small workshop data set. Record the average and minimum times, then consider how data volume, memory capacity, query concurrency, index tuning, and network latency would affect an application-scale decision.

## Learn More

- [Create a vector table](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/create-vector-table.html)
- [Shared index parameter objects](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/shared-parameter-objects.html)
- [Oracle VecDB indexes](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/indexes.html)
- [Oracle VecDB quick start: Create an HNSW index](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/quickstart.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 31, 2026