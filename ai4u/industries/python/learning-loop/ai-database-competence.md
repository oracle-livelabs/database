# How Agents Get Better Over Time

## Introduction

In Lab 8, you built four types of memory. But there's a limitation: the decision history tool uses keyword matching. Search "late delivery" and it won't find "shipping delay" — even though they mean the same thing.

In this lab, you'll solve that with **vector embeddings** and **semantic search** in Oracle 26ai. You'll store experiences with their meaning encoded as vectors, and retrieve them by similarity rather than exact keywords. This is the leap from keyword lookup to meaning-based retrieval.

This is Richmond Alake's key argument in action: **semantic retrieval beats keyword search at scale**. When your agent has thousands of past experiences, the right one needs to surface — even when the words are different.

### The Business Problem

A customer calls Seer Equity upset about an "incorrect invoice." The agent searches its decision history for "incorrect invoice" — and finds nothing. But there are three past experiences about "billing errors" that would be incredibly helpful.

Same meaning. Different words. Keyword search fails. Semantic search succeeds.

**Estimated Time**: 15 minutes

### Objectives

* Set up vector embeddings with `sentence-transformers`
* Create a memory table with a VECTOR column in Oracle 26ai
* Build an HNSW vector index for fast similarity search
* Store experiences with semantic embeddings
* Search by meaning — "late delivery" finds "shipping delay"

### Prerequisites

* Completed the **Getting Started** lab
* Jupyter Notebook running with Oracle 26ai connection verified
* `sentence-transformers` package installed (included in Getting Started setup)

## Task 1: Set Up the Notebook

1. Create a new Jupyter notebook for this lab.

2. Run the shared setup code with the embedding model.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    import oracledb
    import os
    import array
    from langchain_openai import ChatOpenAI
    from langchain_core.tools import tool
    from langgraph.prebuilt import create_react_agent
    from sentence_transformers import SentenceTransformer

    conn = oracledb.connect(
        user=os.getenv("ORACLE_USER", "AGENT_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=os.getenv("ORACLE_DSN", "localhost:1521/FREEPDB1"),
    )
    print(f"Connected as: {conn.username}")

    llm = ChatOpenAI(
        model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        temperature=0,
    )

    def execute_ddl(conn, sql):
        """Execute DDL (CREATE, DROP, etc.)."""
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()

    # ── Embedding model (runs locally in Python) ─────────────────────────
    embedding_model_name = "sentence-transformers/all-MiniLM-L12-v2"
    st_model = SentenceTransformer(embedding_model_name)
    EMBEDDING_DIM = 384  # all-MiniLM-L12-v2 produces 384-dim vectors

    print(f"Embedding model loaded: {embedding_model_name} ({EMBEDDING_DIM} dimensions)")
    print("Setup complete.")
    </copy>
    ```

    >**Note:** The embedding model runs locally in Python. It converts text into a 384-dimensional vector that captures the *meaning* of the text. Similar meanings produce similar vectors, even when the words are different.

## Task 2: Create the Vector-Enabled Memory Table

Oracle 26ai supports VECTOR columns natively. You store the vector right next to the JSON content — no external vector database needed.

1. Create the table with a VECTOR column.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, f"""
    CREATE TABLE agent_memory (
        memory_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        memory_type    VARCHAR2(20) NOT NULL,
        session_id     VARCHAR2(100),
        entity_id      VARCHAR2(100),
        content        JSON NOT NULL,
        embedding      VECTOR({EMBEDDING_DIM}),
        created_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
        expires_at     TIMESTAMP
    )
    """)

    execute_ddl(conn, "CREATE INDEX idx_mem_type ON agent_memory(memory_type)")

    print(f"Memory table created with VECTOR({EMBEDDING_DIM}) column.")
    </copy>
    ```

## Task 3: Create the Vector Index

An HNSW (Hierarchical Navigable Small World) index makes vector searches fast — even with millions of rows.

1. Create the HNSW vector index.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, """
    CREATE VECTOR INDEX idx_memory_vector ON agent_memory(embedding)
    ORGANIZATION NEIGHBOR PARTITIONS
    DISTANCE COSINE
    WITH TARGET ACCURACY 95
    """)

    print("HNSW vector index created. Semantic search is now fast at scale.")
    </copy>
    ```

    >**Note:** `DISTANCE COSINE` means the index measures similarity by angle between vectors — the standard approach for text embeddings. `TARGET ACCURACY 95` means the index trades a tiny amount of precision for significant speed gains.

## Task 4: Build Semantic Memory Tools

These tools store and retrieve experiences by meaning, not by keywords.

1. Create the embedding helper and memory tools.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    def text_to_vector(text: str) -> list:
        """Convert text to a 384-dim embedding vector."""
        return st_model.encode(text).tolist()


    @tool
    def store_experience(
        situation: str, action: str, outcome: str, success: str = "true"
    ) -> str:
        """Store an experience with a semantic embedding so it can be found by meaning later."""
        search_text = f"{situation} {action} {outcome}"
        vec = text_to_vector(search_text)

        # Convert to Oracle VECTOR format
        vec_array = array.array("f", vec)

        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO agent_memory (memory_type, content, embedding)
                VALUES ('EPISODIC', JSON_OBJECT(
                    'situation' VALUE :sit, 'action' VALUE :act,
                    'outcome' VALUE :out, 'success' VALUE :succ,
                    'recorded' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS')
                ), :vec)
            """, {"sit": situation, "act": action, "out": outcome,
                  "succ": success, "vec": vec_array})
        conn.commit()

        return "Experience stored with semantic embedding."


    @tool
    def find_relevant_experience(situation: str, limit: int = 3) -> str:
        """Find past experiences semantically similar to the given situation.
        Uses vector distance — finds matches by MEANING, not just keywords."""
        vec = text_to_vector(situation)
        vec_array = array.array("f", vec)

        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    JSON_VALUE(content, '$.situation') as situation,
                    JSON_VALUE(content, '$.action') as action,
                    JSON_VALUE(content, '$.outcome') as outcome,
                    JSON_VALUE(content, '$.success') as success,
                    ROUND(1 - VECTOR_DISTANCE(embedding, :vec, COSINE), 3) as relevance
                FROM agent_memory
                WHERE memory_type = 'EPISODIC' AND embedding IS NOT NULL
                ORDER BY VECTOR_DISTANCE(embedding, :vec2, COSINE)
                FETCH FIRST :lim ROWS ONLY
            """, {"vec": vec_array, "vec2": vec_array, "lim": limit})
            rows = cur.fetchall()

        if not rows:
            return "No relevant experiences found. This appears to be a new situation."

        lines = []
        for sit, act, out, succ, rel in rows:
            lines.append(
                f"Situation: {sit}\n"
                f"Action taken: {act}\n"
                f"Outcome: {out} (Success: {'Yes' if succ == 'true' else 'No'})\n"
                f"Relevance: {rel * 100:.1f}%\n"
            )
        return f"Found {len(rows)} relevant experiences:\n\n" + "\n".join(lines)

    print("Semantic memory tools created: store_experience, find_relevant_experience")
    </copy>
    ```

## Task 5: Seed Experiences

Let's store several past experiences with their semantic embeddings.

1. Store a variety of customer service experiences.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    experiences = [
        ("Premium customer complained about shipping delay",
         "Offered expedited shipping at no cost plus $20 credit",
         "Customer satisfied, left positive review", "true"),
        ("Customer requested price match from competitor",
         "Verified competitor price and approved 15% discount",
         "Customer placed order immediately", "true"),
        ("New customer confused about product setup",
         "Scheduled 30-minute video call for walkthrough",
         "Customer completed setup, purchased add-on products", "true"),
        ("Customer upset about billing error",
         "Explained company policy without offering resolution",
         "Customer cancelled account and posted negative review", "false"),
        ("Customer upset about billing error",
         "Immediately corrected the error and applied 10% credit",
         "Customer satisfied and upgraded their plan", "true"),
    ]

    for sit, act, out, succ in experiences:
        store_experience.invoke({
            "situation": sit, "action": act, "outcome": out, "success": succ
        })

    print(f"Stored {len(experiences)} experiences with semantic embeddings.")
    </copy>
    ```

## Task 6: The Magic — Semantic Search

Now search using different words than what was stored. This is where vector embeddings shine.

1. Search "late delivery" — should find "shipping delay".

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("=== Search: 'customer angry about late delivery' ===")
    print(find_relevant_experience.invoke({"situation": "customer angry about late delivery"}))
    </copy>
    ```

    "Late delivery" finds "shipping delay" — because the vectors capture *meaning*, not just words.

2. Search "match Amazon's price" — should find "price match from competitor".

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("=== Search: 'customer wants us to match Amazon price' ===")
    print(find_relevant_experience.invoke({"situation": "customer wants us to match Amazon price"}))
    </copy>
    ```

3. Search "incorrect invoice" — should find "billing error" experiences.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("=== Search: 'customer upset about incorrect invoice' ===")
    print(find_relevant_experience.invoke({"situation": "customer upset about incorrect invoice"}))
    </copy>
    ```

    Notice that the billing error search returns *two* results — one successful and one failed. The agent can learn from both: the successful approach (immediate correction + credit) worked, while the unsuccessful one (policy explanation without resolution) led to account cancellation.

## Task 7: The Learning Loop

1. Understand the pattern.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    print("""
    The Learning Loop:
      1. Action → Result
      2. Observe → Interpret
      3. Store with embedding (Oracle 26ai VECTOR column)
      4. Retrieve by MEANING (HNSW index, cosine distance)
      5. Better decisions next time

    The agent doesn't just remember what happened —
    it finds RELEVANT experiences even when the words are different.
    This is the competence that keyword search can never provide.
    """)
    </copy>
    ```

## Task 8: Clean Up

1. Drop the memory table when you're done.

    > Run this cell in your Jupyter notebook.

    ```python
    <copy>
    execute_ddl(conn, "DROP TABLE agent_memory PURGE")
    print("Cleanup complete.")
    </copy>
    ```

## Summary

You've built a semantic search system that finds experiences by meaning:

| Search Query | Found Experience | Why It Works |
|---|---|---|
| "late delivery" | "shipping delay" | Same meaning, different words |
| "match Amazon price" | "price match from competitor" | Concept matching |
| "incorrect invoice" | "billing error" | Synonym recognition |

The technology stack:
* **sentence-transformers** converts text to 384-dimensional vectors
* **Oracle 26ai VECTOR column** stores vectors next to JSON content
* **HNSW index** makes similarity search fast at any scale
* **VECTOR_DISTANCE with COSINE** measures semantic similarity

The key insight: **agents that search by meaning find relevant experiences that keyword search misses**. This is how agents get better over time — by learning from all past experiences, not just the ones that happen to use the same words.

You may now **proceed to the next lab**.

## Learn More

* [Oracle 26ai Vector Search Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [sentence-transformers Documentation](https://www.sbert.net/)
* [HNSW Algorithm Explained](https://arxiv.org/abs/1603.09320)
* [Richmond Alake: Semantic Retrieval at Scale](https://medium.com/@richmondalake)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
