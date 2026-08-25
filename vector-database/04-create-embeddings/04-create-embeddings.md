# Create Embeddings and Load Text

## Introduction

In this lab, you load sample text records into the integrated embedding table. Autonomous AI Vector Database generates the dense vector from the `content` metadata field that you configured in Lab 3.

Estimated Time: 10 minutes

### Objectives

- Load JSONL sample records.
- Upsert text records with automatic embedding.
- Generate a standalone embedding for inspection.
- List loaded records.

### Prerequisites

- `parks_text` vector table from Lab 3.

## Task 1: Load Sample Text Records

1. Create a file named `load_parks.py`.

2. Add the following code.

    ```python
    import json
    import os
    from pathlib import Path

    from files.vector_client import make_client, print_items

    vecdb = make_client()
    table_name = "parks_text"
    embed_model = os.environ.get("VECDB_EMBED_MODEL", "all_MiniLM_L12_v1")

    records = []
    for line in Path("files/national-parks.jsonl").read_text().splitlines():
        item = json.loads(line)
        records.append({
            "id": item["id"],
            "metadata": item
        })

    response = vecdb.upsert_vectors(
        table_name=table_name,
        vectors=records
    )

    print_items("Upsert response", response)
    print_items("Table description", vecdb.describe_vector_table(table_name))
    ```

3. Run the loader.

    ```bash
    python load_parks.py
    ```

## Task 2: Generate a Standalone Embedding

1. Add the following code to the end of `load_parks.py`.

    ```python
    embedding = vecdb.generate_embedding(
        model_name=embed_model,
        inputs=[{"text": "parks with waterfalls and granite cliffs"}]
    )

    print_items("Standalone embedding", embedding)
    ```

2. Run the file again.

    ```bash
    python load_parks.py
    ```

3. Confirm that the response includes an embedding array.

    The values are not meant to be read manually. They are dense numeric representations that make semantic search possible.

## Task 3: List Loaded Records

1. Create a file named `list_parks.py`.

    ```python
    from files.vector_client import make_client, print_items

    vecdb = make_client()

    results = vecdb.list_vectors(
        table_name="parks_text",
        limit=10
    )

    print_items("Loaded park records", results)
    ```

2. Run the script.

    ```bash
    python list_parks.py
    ```

## Learn More

- `OracleVecDB.upsert_vectors`
- `OracleVecDB.generate_embedding`

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
