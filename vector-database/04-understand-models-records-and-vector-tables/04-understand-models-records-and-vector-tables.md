# Understand Models, Records, and Vector Tables

## Introduction

Autonomous AI Vector Database can create embeddings from text stored in metadata. In this lab, you create an integrated embedding table and inspect the model and index settings that support semantic search.

Oracle VecDB also supports [bring-your-own-vector tables](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/vector-table.html), but this workshop focuses on the integrated-embedding path.

Estimated Time: X

### Objectives

- Confirm that the embedding model required for automatic embedding is available.
- Create an integrated embedding table that creates vectors from metadata.
- Understand the automatic IVF vector and metadata indexes created by the SDK's purpose-built table schema.

### Prerequisites

- Successful Python SDK connection from Lab 3.
- `all_MiniLM_L12_v2` loaded from the Vector Database Console in Lab 1.

## Task 1: Confirm Available Embedding Models

An integrated embedding vector table requires an embedding model that is already loaded in Autonomous AI Vector Database. This is a preflight check: `list_models()` confirms that the database can create embeddings automatically before you create the `parks` table.

1. Add a new Python paragraph and run the following code.

    ```python
    %python
    models = vecdb.list_models(limit=25, offset=0)
    print([item.model_name for item in models.items or []])
    ```

2. Confirm that `all_MiniLM_L12_v2` appears in the output. The `parks` table you create in Task 2 uses this model for automatic embeddings. If it is not listed, return to Lab 1 and load the model before continuing.

## Task 2: Create an Integrated Embedding Table

An integrated embedding table creates a dense vector when you insert metadata. `embed_metadata_jsonpath` establishes the embedding rule once by identifying the metadata field that supplies text. In Lab 5, you will upsert metadata-only park records because this table definition tells the database to embed `description` automatically.

By default, the SDK's purpose-built vector-table schema creates an IVF vector index and metadata indexes automatically. This gives the `parks` table a search-ready starting point without manual index configuration. `auto_generate_id=True` tells the database to assign each record ID; repeating an upsert with the same metadata creates new records because the submitted records do not have fixed IDs.

1. Add a new Python paragraph and run the following code to create the `parks` table.

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

2. Confirm that the paragraph completes without an error.

    `create_vector_table()` supports additional options, including a table comment, annotations, index settings, and metadata-index settings. For the full set of options, see [Create a vector table](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/create-vector-table.html).

You may now **proceed to the next lab.**

## Learn More

- [`OracleVecDB.create_vector_table`](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/create-vector-table.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - May 28, 2026
