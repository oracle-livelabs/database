# Build a Python Search API

## Introduction

The source workshop uses an APEX app to show search. In this lab, you build a small Python function for the same role.

Estimated Time: 10 minutes

### Objectives

- Create a reusable semantic search function.
- Return compact results for an app.
- Add metadata filtering as function arguments.
- Test the function from the command line.

### Prerequisites

- Loaded `parks_text` records.
- Successful semantic searches from Lab 5.

## Task 1: Create a Search Module

1. Create a file named `app_search.py`.

2. Add this function.

    ```python
    from files.vector_client import make_client

    vecdb = make_client()

    def search_parks(q, region=None, top_k=5):
        filters = None
        if region:
            filters = {"region": {"$eq": region}}

        results = vecdb.query(
            table_name="parks_text",
            query_by={"text": q},
            filters=filters,
            top_k=top_k,
            advanced_options={
                "distance_metric": "COSINE",
                "accuracy": 90
            }
        )

        response = []
        for item in results:
            metadata = item.get("metadata", {})
            response.append({
                "id": item.get("id"),
                "score": item.get("score"),
                "park_name": metadata.get("park_name"),
                "state": metadata.get("state"),
                "summary": metadata.get("content")
            })
        return response
    ```

## Task 2: Test the Search Function

1. Add a command-line test block.

    ```python
    if __name__ == "__main__":
        for row in search_parks("Where can I find rainforest and coastline?", region="west", top_k=3):
            print(row)
    ```

2. Run the script.

    ```bash
    python app_search.py
    ```

3. Confirm that the output is a list of dictionaries that an API route could return as JSON.

## Task 3: Add a Minimal API Shape

1. If you use FastAPI, the same function can sit behind an endpoint.

    ```python
    from fastapi import FastAPI

    from app_search import search_parks

    app = FastAPI()

    @app.get("/search")
    def search(q: str, region: str | None = None, top_k: int = 5):
        return {"items": search_parks(q, region=region, top_k=top_k)}
    ```

2. Treat the API layer as optional in this workshop.

    The key idea is simple: keep search logic in a reusable Python boundary.

## Learn More

- Python SDK `query` operation
- FastAPI documentation

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026
