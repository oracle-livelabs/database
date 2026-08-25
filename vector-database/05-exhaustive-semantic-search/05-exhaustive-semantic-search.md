# Run Baseline Semantic Search

## Introduction

The original workshop compared exact and approximate vector search. In this lab, you run baseline semantic searches before creating a manual index. This gives you a clear result set to compare with indexed searches in the next lab.

Estimated Time: 10 minutes

### Objectives

- Search by natural language text.
- Inspect scores and metadata.
- Filter by metadata.
- Use advanced options for high-accuracy baseline search.

### Prerequisites

- Loaded `parks_text` records from Lab 4.

## Task 1: Search by Text

1. Create a file named `search_parks.py`.

2. Add the following code.

    ```python
    from files.vector_client import make_client

    vecdb = make_client()

    def show(label, results):
        print(f"\n{label}")
        for item in results:
            metadata = item.get("metadata", {})
            print(item.get("id"), item.get("score"), metadata.get("park_name"), metadata.get("state"))

    results = vecdb.query(
        table_name="parks_text",
        query_by={"text": "historic battlefield from the civil war"},
        top_k=3,
        advanced_options={
            "distance_metric": "COSINE",
            "accuracy": 100
        }
    )

    show("Civil War search", results)
    ```

3. Run the search.

    ```bash
    python search_parks.py
    ```

4. Confirm that the top results include the record whose content discusses Civil War battlefield landscapes.

## Task 2: Search for Terms Not Present in the Text

1. Add a second query to `search_parks.py`.

    ```python
    climbing = vecdb.query(
        table_name="parks_text",
        query_by={"text": "rock climbing near mountain lakes"},
        top_k=3,
        advanced_options={
            "distance_metric": "COSINE",
            "accuracy": 100
        }
    )

    show("Climbing search", climbing)
    ```

2. Run the script again.

    ```bash
    python search_parks.py
    ```

3. Notice whether records about mountains, climbing, or geology appear even when the exact query words are not all present.

## Task 3: Add a Metadata Filter

1. Add a filtered search.

    ```python
    western_water = vecdb.query(
        table_name="parks_text",
        query_by={"text": "waterfalls and rivers"},
        filters={"region": {"$eq": "west"}},
        top_k=5,
        advanced_options={
            "distance_metric": "COSINE",
            "accuracy": 100
        }
    )

    show("Western water search", western_water)
    ```

2. Run the script.

    ```bash
    python search_parks.py
    ```

3. Confirm that the results show only records whose metadata has `region` set to `west`.

## Learn More

- `OracleVecDB.query`
- Metadata filter operators in the REST API reference

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
