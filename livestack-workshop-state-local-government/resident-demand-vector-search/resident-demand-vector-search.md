# Resident Demand Signals with AI Vector Search

## Introduction

Residents and caseworkers often describe the same service problem in different words. A search for benefits eligibility appointment backlog should still find records that say application review delay or caseworker scheduling.

**Jessica**, the State Services Risk Analyst, needs to find related services and resident concerns even when people use different words. **Priya**, the Government AI Engineer, prepares the meaning-based search. In this lab, you turn a plain-language concern into an embedding, compare it with stored vectors, and rank the closest public-service matches.

<details>
<summary><strong>Key terms: embedding, vector, vector distance, and semantic search</strong></summary>

> - An **embedding** is a numerical representation of meaning. `VECTOR_EMBEDDING` creates one from the phrase entered by the analyst.
>
> - A **vector** stores that representation beside the service or resident signal it describes.
>
> - **Vector distance** measures how far two meanings are from each other. With cosine distance, a smaller distance means a closer match.
>
> - **Semantic search** ranks results by meaning rather than exact keywords. The expression `1 - VECTOR_DISTANCE(...)` converts distance into a similarity score, where a higher value is a closer match.

</details>

The concept graphic traces a plain-language concern through the query to a service action.

![Resident demand semantic-search flow](images/resident-demand-vector-flow.svg " ")

The **Resident Demand Signals** page lets an analyst search in plain language, review demand, and inspect resident signals. The application uses a larger demonstration dataset; this lab repeats the same meaning-based search with compact, fixed workshop data.

![Resident Demand Signals vector-search page](images/resident-demand-signals.png " ")

### Objectives

- Search public services by meaning, not just by exact keyword match.
- Search resident signals with the same vector pattern.
- Interpret similarity as a ranking signal, not a final decision.

Estimated Time: **12 minutes**

### Business Scenario

| Step | State and local government focus |
| --- | --- |
| Business Problem | Residents and caseworkers use different language for related service pressure. |
| Technical Challenge | Analysts need semantic search without sending protected text to another service. |
| Persona Focus | Jessica frames the question; Priya keeps embeddings and similarity search in the database. |
| What You Will Do | Create a query embedding and compare it with stored service and signal vectors. |
| Database Capability | Oracle AI Vector Search stores vectors and runs similarity SQL in the database. |
| Outcome | Jessica receives a ranked review queue even when wording differs. |

**Persona focus:** You join Jessica and Priya as you connect an operating concern to relevant services and resident signals.

## Task 1: Search public services by meaning

Jessica has a plain-language concern, but the service catalog may use different terms. Search the descriptions and inspect the top similarity scores and matching service names. The result tells Jessica which services to examine first.

Start with services. Jessica can turn her plain-language concern into a short list of programs and service types to examine.

1. Run the semantic service query.

    > **SQL Worksheet reminder:** Need a reminder on how to open and use SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](/workshops/sandbox/index.html?lab=getting-started#Task2:OpenSQLWorksheet).

    `PRODUCT_EMBEDDINGS` is an inherited physical table that stores vectors for public-service descriptions. `SLED_PUBLIC_SERVICES_V` supplies the learner-facing service names. The shared `ADMIN.ALL_MINILM_L12_V2` model embeds the search phrase inside the database.

    <details>
    <summary><strong>Why this matters: meaning stays connected to source rows</strong></summary>

    > Exporting service text to an external vector store creates another sensitive copy and another access-control boundary. Oracle AI Vector Search keeps the text, vectors, SQL, and public-service context together.

    </details>

    ```sql
    <copy>
    SELECT services.service_name,
           services.service_category,
           ROUND(1 - VECTOR_DISTANCE(
             embeddings.embedding,
             VECTOR_EMBEDDING(
               ADMIN.ALL_MINILM_L12_V2
               USING 'benefits eligibility appointment backlog' AS DATA
             ),
             COSINE
           ), 4) AS similarity
    FROM product_embeddings embeddings
    JOIN sled_public_services_v services
      ON services.service_id = embeddings.product_id
    ORDER BY similarity DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Related Public Services**

    The rows below were validated with the workshop seed data and shared MiniLM model. Similarity decimals can vary slightly if the database model build changes.

    ![SQL Worksheet result showing the related public services ranked by vector similarity](images/sql-related-services.png " ")

2. Interpret the ranking.

    Similarity ranks the service definitions Jessica should inspect first. It does not prove that a service caused the early warning. The source rows remain available for normal SQL analysis.

## Task 2: Search resident signals by meaning

Service matches are only part of the picture. Jessica also needs to know what residents and caseworkers reported. Search the resident signals and inspect both similarity and urgency; together, they help her prioritize human review instead of relying on wording alone.

Next, compare the service match with the concerns residents and caseworkers actually expressed.

1. Run the signal search.

    `POST_EMBEDDINGS` stores vectors for signal text, while `SLED_RESIDENT_SIGNALS_V` presents the source, urgency, and public-service wording. The query returns an excerpt so the analyst can read the text behind each score.

    ```sql
    <copy>
    SELECT signals.resident_signal_id,
           signals.source_channel,
           signals.urgency_band,
           SUBSTR(signals.signal_text, 1, 100) AS signal_excerpt,
           ROUND(1 - VECTOR_DISTANCE(
             embeddings.embedding,
             VECTOR_EMBEDDING(
               ADMIN.ALL_MINILM_L12_V2
               USING 'benefits eligibility appointment backlog' AS DATA
             ),
             COSINE
           ), 4) AS similarity
    FROM post_embeddings embeddings
    JOIN sled_resident_signals_v signals
      ON signals.resident_signal_id = embeddings.post_id
    ORDER BY similarity DESC, resident_signal_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Related Resident Signals**

    These results use the same validated query embedding as the service search. Close scores can shift slightly if the shared model build changes.

    ![SQL Worksheet result showing resident signals ranked by vector similarity](images/sql-related-resident-signals.png " ")

2. Compare meaning with urgency.

    A high similarity score means the text is close to the search intent. `Urgency Band` supplies a separate operating signal. Jessica should review both: meaning identifies relevance, while urgency helps prioritize the response.

    The SQL shows the source text and scores together, so the team can compare relevance with urgency before acting.

3. 🎯 **Interactive challenge: Reframe the resident-service concern.**

    Starting with the resident-signal query above, replace the phrase `benefits eligibility appointment backlog` with `emergency shelter intake coordination` to investigate a different service concern. Run your revised query. Which returned row should enter Jessica's human review queue first when semantic relevance and urgency are considered together?

    **Expected output: Re-Ranked Resident Signals**

    Emergency-shelter, housing-intake, or partner-coordination signals should move relative to the eligibility-focused baseline. Exact row order and similarity decimals are dynamic because they depend on the deployed embedding-model build.

    <details>
    <summary><strong>Challenge answer: Combine semantic relevance with urgency</strong></summary>

    > In the validated result, signal `5` is the closest semantic match, but its urgency band is `steady`. Signal `6` ranks second and is `urgent`, so Jessica should review it first. This is a review priority, not an automatic action; exact rankings can change with the embedding-model build. Oracle AI Database keeps the source text, vectors, urgency, and service context together, so teams can investigate without copying sensitive resident-service data into disconnected systems.

    If you need the runnable solution, use this query:

    ```sql
    <copy>
    SELECT signals.resident_signal_id,
           signals.source_channel,
           signals.urgency_band,
           SUBSTR(signals.signal_text, 1, 100) AS signal_excerpt,
           ROUND(1 - VECTOR_DISTANCE(
             embeddings.embedding,
             VECTOR_EMBEDDING(
               ADMIN.ALL_MINILM_L12_V2
               USING 'emergency shelter intake coordination' AS DATA
             ),
             COSINE
           ), 4) AS similarity
    FROM post_embeddings embeddings
    JOIN sled_resident_signals_v signals
      ON signals.resident_signal_id = embeddings.post_id
    ORDER BY similarity DESC, resident_signal_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    </details>

### What have I achieved when the lab ends?

You turned one service concern into ranked service and resident-signal matches. Jessica can find related records despite different wording, then choose what to investigate next.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
