# Create Embeddings and Load Text

## Introduction

Explore the National Parks data set, load it into the `parks` table, and manually embed park directions for the `directions` table.

Estimated Time: X

### Objectives

- Explore the National Parks JSON data set from Oracle Object Storage.
- Load National Parks records into the `parks` integrated embedding table.
- Generate direction embeddings and load them into the bring-your-own-vector `directions` table.

### Prerequisites

- Complete Lab 3: Install oracle-vecdb package.
- Complete Lab 4: Understand Models, Records, and Vector Tables.
- Keep the `vecdb` client initialized in your OML Notebook.
- Have the National Parks Object Storage PAR URL provided for this workshop.

## Task 1: Explore National Parks Data

The National Parks data set is in Oracle Object Storage. A pre-authenticated request (PAR) URL lets the notebook read the shared JSON file. The workshop PAR URL is provided in the code below. Do not commit a PAR URL to source control. Anyone with it can access the object during the PAR lifetime.

1. Add a new Python paragraph and run the following code to load the National Parks JSON file.

    `urlopen()` reads the object through the PAR URL, and `json.load()` converts it into a Python list of dictionaries. The resulting `park_data_json` object remains in notebook memory for the remaining tasks in this lab.

    ```python
    %python
    import json
    from urllib.request import urlopen

    par_url = "https://c4u02.objectstorage.us-ashburn-1.oci.customer-oci.com/p/9DEArLjsgbKXuJgQtSG95E8hMXRFtxgHR8jiHbqz4HgyVYXVnSo0SC_s-zq5CJA3/n/c4u02/b/hosted-files/o/national_parks.json"

    with urlopen(par_url) as response:
        park_data_json = json.load(response)

    print(len(park_data_json), park_data_json[0]["description"])
    ```

    The output confirms that the notebook can access Object Storage and that the file contains a list of park records with a `description` field.

2. Add a new Python paragraph and run the following code to view the first 3000 characters of the JSON document.

    ```python
    %python
    print(json.dumps(park_data_json, indent=2)[:3000])
    ```

3. Add a new Python paragraph and run the following code to list the keys in the first park record.

    ```python
    %python
    print(list(park_data_json[0].keys()))
    ```

    These keys define how later tasks use the data: `description` supplies text for automatic embedding in `parks`, `DIRECTIONS_INFO` supplies text for manually generated vectors, and `park_code` becomes the stable ID for `directions`.

4. Review the output. The `parks` table embeds records from `description`. Task 3 uses `DIRECTIONS_INFO` to generate bring-your-own vectors for `directions`.

## Task 2: Load National Parks Records into `parks`

This task loads National Parks records into the `parks` integrated embedding table that you created in Lab 4. The table definition identifies `description` as the text field to embed. Therefore, the upsert sends metadata only; you do not specify the embedding field again. In Task 3, the bring-your-own-vector `directions` table requires an ID, dense vector, and metadata because it has no integrated embedding configuration.

1. Add a new Python paragraph and run the following code to prepare the vector records.

    Each item has the upsert shape required for an integrated embedding table: a dictionary containing `metadata`. The filter excludes records without a `description`, because that is the field configured for automatic embedding. No ID is provided because `parks` uses `auto_generate_id=True`.

    ```python
    %python
    park_data = [
        {"metadata": park}
        for park in park_data_json
        if park.get("description")
    ]

    print(f"Prepared {len(park_data):,} park records.")
    ```

2. Add a new Python paragraph and run the following code to upload the park data.

    ```python
    %python
    vecdb.upsert_vectors(table_name="parks", vectors=park_data)
    ```

    In one call, the database stores each metadata object, reads its `description`, creates a dense vector with `all_MiniLM_L12_v2`, and stores the record in `parks`. This step can take longer than the earlier steps because it processes every eligible park record. The paragraph output shows the number of rows processed.

3. Review the output from both paragraphs. Confirm that the number of uploaded rows matches the number of prepared records.

    The `parks` table automatically generates IDs. Run the upsert paragraph once; running it again creates additional records because the submitted records do not have fixed IDs.

## Task 3: Create Direction Embeddings and Load the Directions Table

The `directions` table is a bring-your-own-vector table created in Lab 4. Unlike the `parks` table, it does not create embeddings automatically. This task follows a different data flow: read `DIRECTIONS_INFO`, generate an embedding, create a record with an ID, dense vector, and metadata, then upsert that record into `directions`.

1. Add a new Python paragraph and run the following code.

    The loop uses `park_code` as a stable ID, skips records with missing or blank directions, generates an embedding from each usable `DIRECTIONS_INFO` value, and retains the full park object as searchable metadata. This example makes one embedding call for each eligible park record and typically takes about one minute to complete.

    ```python
    %python
    direction_vectors = []

    for park in park_data_json:
        park_id = park.get("park_code")
        directions_text = park.get("DIRECTIONS_INFO")
        if not park_id or not isinstance(directions_text, str) or not directions_text.strip():
            continue
        embedding_response = vecdb.generate_embedding(
            model_name="all_MiniLM_L12_v2",
            inputs=[directions_text],
        )
        direction_vectors.append(
            {
                "id": park_id,
                "dense_vector": embedding_response.data[0].embedding,
                "metadata": park,
            }
        )

    print(f"Prepared {len(direction_vectors)} direction vectors.")

    upsert_result = vecdb.upsert_vectors(
        table_name="directions",
        vectors=direction_vectors,
    )

    print(upsert_result)
    ```

2. Review the output. The embedding step typically takes about one minute. The paragraph prints the number of prepared direction vectors, and the final upsert result confirms that the vectors and metadata were loaded into `directions`.

    This example makes one embedding request per eligible park record so that the flow is easy to follow. For larger data sets, batch inputs when your application and service limits allow it.

## Learn More

- [List loaded models](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/list-models.html)
- [Create a vector table](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/api-guide/create-vector-table.html)
- [Integrated embedding and bring-your-own-vector tables](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/how-oracle-vecdb-works/vector-table.html)
- [Oracle VecDB Python SDK API reference](https://docs.oracle.com/en/cloud/paas/autonomous-database/vcapi/python-api-reference.html)

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, August 27, 2026