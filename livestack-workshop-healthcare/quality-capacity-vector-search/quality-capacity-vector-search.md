# Quality and Capacity Search with AI Vector Search

## Introduction

After opening request `170104`, Jessica asks a quality analyst to find other records about the same capacity problem. The analyst discovers a common search challenge. One person may ask for “more appointment room for cancer treatments,” while stored records use terms such as “chair availability,” “oncology capacity,” or “continuity schedules.”

Anyone who has searched an email inbox or product catalog has faced this problem. Exact keyword search works when the wording matches. It can miss useful results when people express the same idea with different words. **AI Vector Search** addresses that gap by comparing mathematical representations of meaning.

Oracle Database turns Jessica’s search phrase into an embedding and compares it with stored service and signal vectors. The query then ranks the closest matches. It keeps each service name, priority, signal type, and similarity score visible for Jessica and the analyst to review.

<details>
<summary><strong>Key terms: embedding, vector, cosine distance, and similarity</strong></summary>

> - An **embedding** comes from a model that converts patterns in text into numbers. Those numbers do not form a readable summary. Instead, they act as coordinates that make mathematical comparison possible.
> - A **vector** is the ordered list of numbers produced for a service description or quality signal. Related texts often occupy nearby positions, even when they do not share keywords.
> - **Cosine distance** measures the difference between the directions of two vectors. A smaller distance means the vectors point in more similar directions. That result usually indicates more closely related meaning.
> - **Similarity** is the score calculated here as `1 - cosine distance`. Higher values represent closer semantic matches. The score ranks items for review, but it does not prove correctness, urgency, or clinical value.
>
> Imagine a map where nearby pins represent related ideas instead of nearby streets. Vector search finds the pins closest to the search phrase. The surrounding database columns tell Jessica what each match means in the real operation.

</details>

![Healthcare vector-search results](images/healthcare-vector-search.png " ")

*Figure 1: The application ranks services and signals that match the search idea.*

### Objectives

- Turn a healthcare phrase into a vector inside Oracle Database.
- Rank care services by meaning.
- Rank quality signals by meaning while keeping priority and service context.

Estimated Time: **12 minutes**

### Business Scenario

| Step | Healthcare focus |
| --- | --- |
| Business Problem | Care teams use different words for similar capacity and quality needs. |
| Technical Challenge | Exact keyword search can miss useful services or signals. |
| Persona Focus | A quality analyst searches by intent while a database developer keeps the search reviewable. |
| What You Will See | Vector search ranks healthcare text by semantic similarity. |
| Database Capability | `VECTOR_EMBEDDING`, stored vector columns, and `VECTOR_DISTANCE` run inside Oracle AI Database. |
| Outcome | Teams find relevant care evidence even when the wording changes. |
{: title="Vector search scenario"}

**Persona focus:** You help a quality analyst find related language. You also keep the service, priority, signal type, and similarity evidence visible.

## Task 1: Search care services by meaning

Search for services related to the need for more treatment appointments. The phrase intentionally avoids the word `infusion`, so the result demonstrates meaning-based matching instead of an obvious keyword match.

1. Run the service search.

    > **SQL Worksheet reminder:** Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) if you need help running SQL.

    Read the query in four parts.

    1. The `query_vector` common table expression turns the phrase into an embedding.
    2. `VECTOR_DISTANCE` compares that new vector with each stored service vector.
    3. `1 - VECTOR_DISTANCE(...)` changes cosine distance into an easier similarity score.
    4. `ORDER BY similarity DESC` puts the strongest match first.

    <details>
    <summary><strong>Why this matters: search stays beside governed data</strong></summary>

    > A separate AI search service can require another copy of service descriptions and signal text.
    >
    > Oracle AI Vector Search keeps the source text, vectors, SQL, and business columns together. The analyst can review both the match and the healthcare facts around it.

    </details>

    At this workshop scale, Oracle can compare all 187 service vectors exactly. A much larger production catalog may benefit from a vector index and relational filters, but those extra tuning choices are not needed to understand this result.

    ```sql
    <copy>WITH query_vector AS (
      SELECT VECTOR_EMBEDDING(
        ADMIN.ALL_MINILM_L12_V2
        USING 'more appointment room for cancer treatments' AS DATA
      ) AS embedding
    )
    SELECT s.service_name,
           s.provider_network,
           ROUND(
             1 - VECTOR_DISTANCE(
               s.service_embedding,
               q.embedding,
               COSINE
             ),
             4
           ) AS similarity
    FROM care_services_v s
    CROSS JOIN query_vector q
    ORDER BY similarity DESC
    FETCH FIRST 3 ROWS ONLY;</copy>
    ```

    **Expected output: Service matches**

    | Service | Provider Network | Similarity |
    | --- | --- | ---: |
    | Infusion Center Slot Bundle - Continuity Lot 3 | Regional Oncology Network | 0.6033 |
    | Infusion Center Slot Bundle - Continuity Lot 2 | Regional Oncology Network | 0.5341 |
    | Infusion Center Slot Bundle | Regional Oncology Network | 0.4807 |
    {: title="Service matches"}

2. Review the ranked services.

    All three results describe scheduling or capacity for oncology treatment even though the search phrase does not contain the word `infusion`. Continuity Lot 3 ranks first because its stored description about expanded treatment schedules and chair availability is the closest mathematical match to the phrase.

    The search phrase and service name do not need to use exactly the same words. That is the value of semantic search.

## Task 2: Search quality signals by meaning

Now use the same phrase against quality and capacity signal text.

1. Run the signal search.

    The embedding step stays the same. The query now compares the phrase with `SIGNAL_EMBEDDING`.

    The result keeps `CRITICALITY`, `SIGNAL_TYPE`, and `SERVICE_NAME` beside the similarity score. Vector ranking finds related language. The other columns help a person decide what to review.

    Oracle Database 26ai allows a `SELECT` that calculates an expression without a `FROM` clause. People who used earlier releases may recognize examples that add `FROM DUAL` to the embedding step. That familiar form still works, but Oracle AI Database 26ai does not require it here.

    ```sql
    <copy>WITH query_vector AS (
      SELECT VECTOR_EMBEDDING(
        ADMIN.ALL_MINILM_L12_V2
        USING 'more appointment room for cancer treatments' AS DATA
      ) AS embedding
    )
    SELECT s.signal_id,
           s.criticality,
           s.signal_type,
           s.service_name,
           ROUND(
             1 - VECTOR_DISTANCE(
               s.signal_embedding,
               q.embedding,
               COSINE
             ),
             4
           ) AS similarity
    FROM quality_capacity_signals_v s
    CROSS JOIN query_vector q
    ORDER BY similarity DESC
    FETCH FIRST 5 ROWS ONLY;</copy>
    ```

    **Expected output: Signal matches**

    | Signal Id | Priority | Signal Type | Service | Similarity |
    | ---: | --- | --- | --- | ---: |
    | 101 | CRITICAL | Capacity Alert | Infusion Center Slot Bundle - Continuity Lot 2 | 0.4776 |
    | 102 | HIGH | Capacity Alert | Infusion Center Slot Bundle - Continuity Lot 3 | 0.4091 |
    | 107 | MEDIUM | Specialty Review | Digital Pathology Slide Batch | 0.3881 |
    | 105 | MEDIUM | Diagnostic Capacity | qPCR Respiratory Panel | 0.3314 |
    | 106 | HIGH | Patient Flow Alert | Bed Capacity Surge Playbook | 0.2527 |
    {: title="Signal matches"}

2. Compare meaning with priority.

    Signal 101 is both the closest semantic match and a critical signal. That makes it a strong first item for human review.

    A high similarity score does not prove a clinical issue. It means the text is close to the search idea. The analyst still reviews the source, priority, service, and next step.

    Similarity values may change slightly if the embedding model or source text is rebuilt. Focus on the ranking and the healthcare meaning.

## Next Steps

You searched healthcare service and signal text by meaning. For a deeper workshop about Oracle AI Vector Search, open the [AI Vector Search LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=4166).

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Linda Foinding, Principal Database Product Manager, August 2026
