# Understand Models, Records, and Vector Tables

## Introduction

Autonomous AI Vector Database supports two common workflows. You can let the database embed text, or you can bring vectors from another model.

Estimated Time: 10 minutes

### Objectives

- List available embedding models.
- Create a table that embeds text.
- Create a table that accepts your vectors.
- Describe the created tables.

### Prerequisites

- Successful Python SDK connection from Lab 2.

## Task 1: Inspect Loaded Models

1. Create a file named `setup_tables.py`.

2. Add the following imports and client setup.

    ```python
    import os

    from files.vector_client import make_client, print_items

    vecdb = make_client()
    embed_model = os.environ.get("VECDB_EMBED_MODEL", "all_MiniLM_L12_v1")
    ```

3. List the models that are already loaded.

    ```python
    print_items("Loaded models", vecdb.list_models())
    ```

4. If `VECDB_EMBED_MODEL` is not loaded, open the Vector Database Console and load it.

    The docs list `all_MiniLM_L12_v1`, `multilingual_e5_small`, and `clip_vit_base_patch32_txt` as starter model choices.

## Task 2: Create an Integrated Embedding Table

1. Add the following code to create a table for text records.

    ```python
    TEXT_TABLE = "parks_text"

    try:
        vecdb.drop_vector_table(TEXT_TABLE)
    except Exception:
        pass

    vecdb.create_vector_table(
        table_name=TEXT_TABLE,
        auto_generate_id=False,
        vector_type="dense",
        embed_params={
            "model": embed_model,
            "embed_metadata_jsonpath": "content"
        },
        index_params={
            "indexing": "manual"
        }
    )

    print_items("Text table", vecdb.describe_vector_table(TEXT_TABLE))
    ```

2. The `embed_metadata_jsonpath` value tells the service which metadata field contains text to embed.

## Task 3: Create a Bring-Your-Own-Vector Table

1. Add this code for records whose vectors come from another model.

    ```python
    IMAGE_TABLE = "park_image_vectors"

    try:
        vecdb.drop_vector_table(IMAGE_TABLE)
    except Exception:
        pass

    vecdb.create_vector_table(
        table_name=IMAGE_TABLE,
        auto_generate_id=False,
        vector_type="dense",
        index_params={
            "indexing": "manual"
        }
    )

    print_items("Image vector table", vecdb.describe_vector_table(IMAGE_TABLE))
    ```

2. Run the setup script.

    ```bash
    python setup_tables.py
    ```

## Learn More

- `OracleVecDB.create_vector_table`
- Autonomous AI Vector Database workflows in the product documentation

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
