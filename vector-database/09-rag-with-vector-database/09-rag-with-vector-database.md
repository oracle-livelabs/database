# Assemble a RAG Retrieval Flow

## Introduction

RAG starts with good retrieval. In this lab, you load support records, search for context, rerank results, and build a prompt for an LLM or agent framework.

Estimated Time: X

### Objectives

- Create a support incident vector table.
- Load records with integrated embedding.
- Retrieve context for a user request.
- Optionally rerank retrieved documents.
- Assemble a RAG prompt payload.

### Prerequisites

- Python SDK configuration from Lab 2.
- An embedding model loaded in Autonomous AI Vector Database.

## Task 1: Create and Load a Support Table

1. Create a file named `load_incidents.py`.

2. Add this code.

    ```
    <copy>
    import json
    import os
    from pathlib import Path

    from files.vector_client import make_client, print_items

    vecdb = make_client()
    table_name = "support_incidents"
    embed_model = os.environ.get("VECDB_EMBED_MODEL", "all_MiniLM_L12_v1")

    try:
        vecdb.drop_vector_table(table_name)
    except Exception:
        pass

    vecdb.create_vector_table(
        table_name=table_name,
        description="Support incidents for RAG retrieval",
        auto_generate_id=False,
        embed_params={
            "model": embed_model,
            "embed_metadata_jsonpath": "content"
        },
        index_params={
            "indexing": "auto",
            "organization": "PARTITIONS",
            "distance_metric": "COSINE"
        }
    )

    records = []
    for line in Path("files/support-incidents.jsonl").read_text().splitlines():
        item = json.loads(line)
        records.append({"id": item["id"], "metadata": item})

    print_items("Incident load", vecdb.upsert_vectors(table_name=table_name, vectors=records))
    </copy>
    ```

3. Run the script.

    ```
    <copy>
    python load_incidents.py
    </copy>
    ```

## Task 2: Retrieve Context

1. Create a file named `rag_retrieve.py`.

2. Add the retrieval function.

    ```
    <copy>
    import os

    from files.vector_client import make_client

    vecdb = make_client()

    def retrieve_context(q):
        results = vecdb.query(
            table_name="support_incidents",
            query_by={"text": q},
            top_k=4,
            advanced_options={
                "distance_metric": "COSINE",
                "accuracy": 90
            }
        )

        documents = [item["metadata"]["content"] for item in results]
        rerank_model = os.environ.get("VECDB_RERANK_MODEL", "").strip()

        if rerank_model:
            reranked = vecdb.rerank(
                query=q,
                documents=documents,
                model_name=rerank_model,
                model_params={"top_n": 3}
            )
            print("Reranked documents:", reranked)

        return results
    </copy>
    ```

## Task 3: Assemble the Prompt Payload

1. Add a prompt builder to `rag_retrieve.py`.

    ```
    <copy>
    def build_prompt(q, results):
        context_lines = []
        for item in results:
            metadata = item["metadata"]
            context_lines.append(
                f"- {item['id']}: {metadata['content']} "
                f"Resolution: {metadata['resolution']}"
            )

        context = "\n".join(context_lines)
        return f"""You are a support assistant. Answer only from the retrieved context.

    Retrieved context:
    {context}

    User question:
    {q}
    """

    if __name__ == "__main__":
        q = "The camera app times out during authentication. What should I check?"
        retrieved = retrieve_context(q)
        print(build_prompt(q, retrieved))
    </copy>
    ```

2. Run the script.

    ```
    <copy>
    python rag_retrieve.py
    </copy>
    ```

3. Review the prompt payload.

    The final LLM call stays outside this workshop. Plug the retrieval step into your preferred model, agent framework, or app service.

## Learn More

- `OracleVecDB.query`
- `OracleVecDB.rerank`
- Autonomous AI Vector Database RAG use cases

## Acknowledgements

* **Author** - Oracle LiveLabs workshop authoring team
* **Last Updated By/Date** - Codex, May 28, 2026

