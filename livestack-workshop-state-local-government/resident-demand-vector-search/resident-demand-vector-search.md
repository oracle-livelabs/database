# Resident Demand Signals with AI Vector Search

## Introduction

Residents and caseworkers may describe the same service problem in different words. A search for "benefits eligibility appointment backlog" should find relevant services and signals even when the stored text says "application review delay" or "caseworker scheduling."

You are the service intelligence analyst supporting Jessica. You will turn a plain-language concern into an embedding, compare it with stored vectors, and rank the closest public-service evidence.

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

The concept graphic follows the query from plain-language concern to service action.

![Resident demand semantic-search flow](images/resident-demand-vector-flow.svg " ")

The SQL reproduces the meaning-based search used by the Resident Demand Signals workflow inside Oracle Database.

### Objectives

- Search public services by meaning.
- Search resident signals with the same vector pattern.
- Interpret similarity as a ranking signal, not a final decision.

Estimated Time: **12 minutes**

### Business Scenario

| Step | State and local government focus |
| --- | --- |
| Business Problem | Residents and caseworkers use different language for related service pressure. |
| Technical Challenge | Analysts need semantic search without exporting governed text to another service. |
| Persona Focus | A service intelligence analyst supports the statewide investigation led by Jessica. |
| What You Will Do | Create a query embedding and compare it with stored service and signal vectors. |
| Database Capability | Oracle AI Vector Search stores vectors and runs similarity SQL in the database. |
| Outcome | Jessica receives a ranked review queue even when wording differs. |

**Persona focus:** You help Jessica connect an operating concern to relevant services and resident signals.

## Task 1: Search public services by meaning

Search for services related to a benefits appointment backlog.

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

    **Format-only example:** Similarity decimals and close-result ordering can vary by database model build. Capture the target ADB result before publication. The rows below show the intended result shape, not a runtime-validated ranking.

    | Service Name | Service Category | Similarity |
    | --- | --- | --- |
    | Medicaid Eligibility Review | Benefits and Health | Representative score around 0.70 |
    | Benefits Appointment Scheduling | Benefits and Health | Representative score around 0.65 |
    | SNAP Application Support | Benefits and Health | Representative score around 0.60 |
    | Child Care Subsidy | Family Services | Representative score around 0.50 |
    | Housing Assistance Intake | Housing | Representative score around 0.45 |

2. Interpret the ranking.

    Similarity helps Jessica decide which service definitions to inspect first. It does not prove that a service caused the early warning. The ranking narrows the review queue while the source rows remain available for normal SQL analysis.

## Task 2: Search resident signals by meaning

Use the same phrase against resident and caseworker observations.

1. Run the signal search.

    `POST_EMBEDDINGS` stores vectors for signal text, while `SLED_RESIDENT_SIGNALS_V` presents the source, urgency, and public-service wording. The query returns an excerpt so the analyst can read the evidence behind each score.

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

    **Format-only example:** Capture the target ADB ranking before publication. The rows below illustrate the result columns and the range of evidence that the learner should review.

    | Resident Signal Id | Source Channel | Urgency Band | Signal Excerpt | Similarity |
    | --- | --- | --- | --- | --- |
    | 1 | caseworker | critical | Eligibility appointments are booking three weeks out in the Western Slope. | Highest representative score |
    | 2 | resident portal | urgent | My benefits renewal is waiting for eligibility review and I cannot get an appointment. | High representative score |
    | 6 | partner hotline | urgent | Housing intake and benefits reviews need a shared appointment plan. | High representative score |
    | 7 | caseworker | rising | Senior transportation requests are delaying scheduled eligibility visits. | Related representative score |
    | 3 | call center | rising | Permit inspection scheduling is beginning to exceed the published service window. | Lower representative score |

2. Compare meaning with urgency.

    A high similarity score means the text is close to the search intent. `Urgency Band` supplies a separate operating signal. Jessica should review both: meaning identifies relevance, while urgency helps prioritize the response.

    The SQL keeps the underlying text and scores reviewable, so a team can compare semantic relevance with urgency before acting.

## Acknowledgements

* **Author** - Oracle LiveLabs Team
* **Last Updated By/Date** - Oracle LiveLabs Team, August 2026
