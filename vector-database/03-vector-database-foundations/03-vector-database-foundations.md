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

- Successful Python SDK connection from Lab 3.

## Task 1: Inspect Loaded Models

1. Create a file named `setup_tables.py`.

2. Add the following imports and client setup.

    <copy>
    ```python
    import os

    from files.vector_client import make_client, print_items

    vecdb = make_client()
    embed_model = os.environ.get("VECDB_EMBED_MODEL", "all_MiniLM_L12_v1")
    ```
    </copy>

3. List the models that are already loaded.

    <copy>
    ```python
    print_items("Loaded models", vecdb.list_models())
    ```
    </copy>

4. If `VECDB_EMBED_MODEL` is not loaded, open the Vector Database Console and load it.

    The docs list `all_MiniLM_L12_v1`, `multilingual_e5_small`, and `clip_vit_base_patch32_txt` as starter model choices.

## Task 2: Create an Integrated Embedding Table

An integrated table creates a dense vector when you insert metadata. `embed_metadata_jsonpath` identifies the metadata field that supplies text. `auto_generate_id=True` tells the database to assign each record ID.

1. Add a new Python paragraph. Copy the following code into it and run it to create the `parks` table.

    <copy>
    ```python
    %python
    vecdb.create_vector_table(
        name="parks",
        embed_params={
            "model": "all_MiniLM_L12_v2",
            "embed_metadata_jsonpath": "description",
        },
        table_params={"auto_generate_id": True},
    )
    ```
    </copy>

2. Confirm that the paragraph completes without an error.

    `create_vector_table()` supports additional options, including a table comment, annotations, index settings, and metadata-index settings. For the full set of options, see [Create a vector table](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/create-vector-table.html).


## Task 3: Create a Bring-Your-Own-Vector Table

A bring-your-own-vector table does not create embeddings automatically. In a later lab, you will call an OCI embedding endpoint and load its dense vectors into this table.

Unlike `parks`, `directions` has no `embed_params` setting. The `comment` is optional. Set `auto_index` to `False` to configure the vector index later.

1. Add a new Python paragraph. Copy the following code into it and run it to create the `directions` table.

    <copy>
    ```python
    %python
    vecdb.create_vector_table(
        name="directions",
        comment="Manually managed vector table",
        index_params={
            "vector_index_params": {
                "auto_index": False,
            }
        },
    )
    ```
    </copy>

2. Confirm that the paragraph completes without an error.


## Learn More

- `OracleVecDB.create_vector_table`
- Autonomous AI Vector Database workflows in the product documentation

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026


