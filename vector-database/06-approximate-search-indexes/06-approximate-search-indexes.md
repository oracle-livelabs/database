# Create Indexes for Approximate Search

## Introduction

Indexes accelerate similarity search over larger vector sets. In this lab, you create a vector index, monitor the job, and compare indexed search settings with the baseline search from the previous lab.

Estimated Time: 10 minutes

### Objectives

- Create an IVF vector index.
- Monitor index job status.
- Run an indexed semantic search.
- Try a high-accuracy search option.

### Prerequisites

- Loaded `parks_text` records from Lab 4.
- Baseline search script from Lab 5.

## Task 1: Create a Vector Index

1. Create a file named `create_index.py`.

2. Add this code.

    ```python
    from files.vector_client import make_client, print_items

    vecdb = make_client()

    response = vecdb.create_index(
        table_name="parks_text",
        index_params={
            "organization": "PARTITIONS",
            "distance_metric": "COSINE",
            "accuracy": 90
        }
    )

    print_items("Index create response", response)
    print_items("Index jobs", vecdb.list_index_jobs())
    ```

3. Run the script.

    ```bash
    python create_index.py
    ```

## Task 2: Inspect the Index

1. Create a file named `describe_index.py`.

    ```python
    from files.vector_client import make_client, print_items

    vecdb = make_client()

    print_items("Index description", vecdb.describe_index("parks_text"))
    ```

2. Run the script.

    ```bash
    python describe_index.py
    ```

3. If the index is still building, rerun the script after a short wait.

## Task 3: Run Indexed Searches

1. Create a file named `compare_indexed_search.py`.

    ```python
    from files.vector_client import make_client

    vecdb = make_client()

    for accuracy in [70, 90, 100]:
        results = vecdb.query(
            table_name="parks_text",
            query_by={"text": "western parks with water and mountain scenery"},
            top_k=5,
            advanced_options={
                "distance_metric": "COSINE",
                "accuracy": accuracy
            }
        )
        print(f"\nAccuracy target: {accuracy}")
        for item in results:
            metadata = item.get("metadata", {})
            print(item.get("id"), item.get("score"), metadata.get("park_name"))
    ```

2. Run the script.

    ```bash
    python compare_indexed_search.py
    ```

3. Compare the result order as the accuracy target changes.

    Higher accuracy targets usually favor recall. Lower accuracy targets can be useful when latency matters more than recall.

## Learn More

- `OracleVecDB.create_index`
- `OracleVecDB.describe_index`
- Autonomous AI Vector Database index management documentation

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
