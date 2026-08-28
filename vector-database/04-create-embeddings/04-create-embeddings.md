# Create Embeddings and Load Text

## Introduction

Inspect the loaded embedding models, explore the National Parks data set, and load its records into the `parks` table.

Estimated Time: 15 minutes

### Objectives

- List the embedding models loaded in your vector database.
- Explore the National Parks JSON data set from Oracle Object Storage.
- Load National Parks records into the `parks` integrated embedding table.

### Prerequisites

- Complete Lab 3: Install oracle-vecdb package.
- Keep the `vecdb` client initialized in your OML Notebook.
- Have the National Parks Object Storage PAR URL provided for this workshop.

## Task 1: Confirm Available Embedding Models

An integrated table uses an embedding model already loaded in Autonomous AI Vector Database. `list_models()` returns the loaded embedding and reranking models in your schema.

1. Add a new Python paragraph to your OML Notebook. Copy the following code into it and run it.

    <copy>
    ```
    %python
    models = vecdb.list_models(limit=25, offset=0)
    print([item.model_name for item in models.items or []])
    ```
    </copy>

2. Confirm that `all_MiniLM_L12_v2` appears in the output. The `parks` table created in Lab 4 uses this model for automatic embeddings.

## Task 2: Explore National Parks data

The National Parks data set is in Oracle Object Storage. A pre-authenticated request (PAR) URL lets the notebook read the shared JSON file. Paste the workshop PAR URL into the code below. Do not commit a PAR URL to source control. Anyone with it can access the object during the PAR lifetime.

1. Add a new Python paragraph. Copy the code below, replace the placeholder with the workshop PAR URL, and run the paragraph.

    The output shows the number of park records and the `description` for the first park.

    <copy>
    ```
    %python
    import json
    from urllib.request import urlopen

    par_url = "<National Parks Object Storage PAR URL>"

    with urlopen(par_url) as response:
        park_data_json = json.load(response)

    print(len(park_data_json), park_data_json[0]["description"])
    ```
    </copy>

2. Add a new Python paragraph. Copy the following code into it and run it to view the complete JSON document.

    This output is long because it displays every park record.

    <copy>
    ```
    %python
    print(park_data_json)
    ```
    </copy>

3. Add another Python paragraph. Copy the following code into it and run it to list the keys in the first park record.

    <copy>
    ```
    %python
    print(list(park_data_json[0].keys()))
    ```
    </copy>

4. Review the output. The `parks` table embeds records from `description`. A later exercise uses `DIRECTIONS_INFO` to generate external vectors for `directions`.

## Task 3: Load National Parks Records into parks

This task loads National Parks records into the `parks` integrated embedding table that you created in Lab 4. The table definition identifies `description` as the text field to embed. Therefore, the upsert sends metadata only; you do not specify the embedding field again.

1. Add a new Python paragraph. Copy the following code into it and run it to prepare the vector records.

    Each record stores one park object as metadata. The filter excludes records without a `description`, because that is the field configured for automatic embedding.

    <copy>
    ```
    %python
    park_data = [
        {"metadata": park}
        for park in park_data_json
        if park.get("description")
    ]

    print(f"Prepared {len(park_data):,} park records.")
    ```
    </copy>

2. Add a new Python paragraph. Copy the following code into it and run it to upload the park data.

    <copy>
    ```
    %python
    vecdb.upsert_vectors(table_name="parks", vectors=park_data)
    ```
    </copy>

    The database reads each metadata object's `description`, creates its dense vector with `all_MiniLM_L12_v2`, and stores the record in `parks`.

3. Add a new Python paragraph. Copy the following code into it and run it to see how many rows the table contains.

    <copy>
    ```
    %python
    parks_details = vecdb.describe_vector_table(name="parks").to_dict()
    print(f"Rows uploaded: {parks_details['stats']['total_vectors']:,}")
    ```
    </copy>

4. Confirm that the row count matches the number of prepared records.

    The `parks` table automatically generates IDs. Run the upsert paragraph once; running it again creates additional records because the submitted records do not have fixed IDs.
## Learn More

- [List loaded models](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/list-models.html)
- [Create a vector table](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/create-vector-table.html)
- [Integrated embedding and bring-your-own-vector tables](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/vector-table.html)
- [Oracle VecDB Python SDK API reference](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/python-api-reference.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026





