# Risk Signal Intelligence with AI Vector Search

## Introduction

Risk teams often know the concern before they know the exact words used in the data. This lab uses finance embeddings to search by meaning instead of relying only on exact keyword matches.

That matters because a risk analyst may ask about "mortgage pre-approval risk" while the data uses related phrases such as loan review, lending exposure, or adjustable-rate mortgage. Vector search helps find related finance language, not just exact text matches.

After reviewing numeric exposure, analysts often need to search the language behind the signals. After reviewing numeric exposure, analysts often need to search the language behind the signals. In this lab, you ask Oracle Database to find products and signal text that mean roughly the same thing as the analyst's question.

<details>
<summary><strong>Key terms: embedding, vector, vector distance, and semantic search</strong></summary>

> - An **embedding** is a numerical profile of what text means. In this lab, product descriptions and risk-signal language can be embedded so similar finance ideas sit near each other mathematically, even when the wording is different.
>
> - A **vector** is the stored numerical form of an embedding. Oracle Database stores vectors beside the finance rows they describe, so the search result can include product names, exposure values, signal counts, and other business columns.
>
> - **Vector distance** measures how close two vectors are. A smaller distance means the meanings are more similar; a larger distance means they are farther apart. In this lab, distance helps rank which products or signals best match a risk analyst's question.
>
> - **Semantic search** means searching by meaning instead of exact words. In this lab, it helps analysts find related mortgage, AML, fraud, sanctions, or exposure language even when the wording differs.
>
> - **ALL\_MINILM\_L12\_V2** is the embedding model used in this lab. A model is the trained pattern that turns text into embeddings. This model reads a phrase such as `mortgage pre-approval risk` and returns a vector that Oracle Database can compare with the stored finance vectors.

</details>

The image below is the Risk Signal Intelligence page. The top search area lets a risk analyst enter business language, such as mortgage pre-approval risk, and receive ranked financial products by meaning rather than exact keyword match. The activity feed below connects regulatory notices, market signals, fraud alerts, branch advisories, exposure, confidence, and severity so a vague risk concern can become a concrete product or signal review.

![Financial Product and Exposure Intelligence search](images/vector-product-search.png " ")

### Objectives

- Search financial products by meaning.
- Search risk signals by meaning.

Estimated Time: **12 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Risk analysts cannot rely only on keyword matching when signals use different words for similar exposure. |
| Technical Challenge | AI and data teams need search by meaning without exporting sensitive finance text to a separate embedding or search pipeline. |
| Persona Focus | Risk analysts ask by intent; AI engineers and database developers keep embedding and search work inside the database. |
| What You Will See | Vector search ranks finance products and risk signals by semantic similarity. |
| Database Capability | VECTOR\_EMBEDDING, vector columns, and VECTOR\_DISTANCE run inside Oracle AI Database. |
| Outcome | Analysts can find mortgage, AML, fraud, and exposure signals even when wording varies. |

**Persona focus:** You help the risk analyst search product and signal language by meaning while keeping the source text, vectors, and scores in Oracle AI Database.

## Task 1: Search products by meaning

Search for financial products related to mortgage pre-approval risk by meaning, not exact keyword match:

1. Run the following query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are asking the database to find products related to a risk concept, even when the product text does not use the exact same words. The SQL creates an embedding for the phrase `mortgage pre-approval risk`, compares it with stored product embeddings using cosine vector distance, and orders the result by closest semantic match. The closer the meaning, the higher the result should appear in the review list.

    <details>
    <summary><strong>Why this matters: better than exporting text to a separate AI search service</strong></summary>

    > In a fractured environment, teams often export text to an external embedding pipeline or search service. That can create extra copies of sensitive finance text and make it harder to explain which data was searched.
    >
    > Oracle AI Vector Search keeps the source text, vectors, SQL query, and similarity score in Oracle AI Database, so analysts can review both the match and the data behind it.

    </details>

    <details>
    <summary><strong>Why does the model name include ADMIN?</strong></summary>

    > `ALL_MINILM_L12_V2` is the shared embedding model available in the workshop database. In this environment, the model is owned by `ADMIN`, so the SQL calls it as `ADMIN.ALL_MINILM_L12_V2`.
    >
    > The finance tables and views are in your `LLUSER` schema. Only the shared embedding model uses the `ADMIN.` prefix.

    </details>

    ```sql
    <copy>
    SELECT p.product_name,
           p.category,
           ROUND(1 - VECTOR_DISTANCE(
             pe.embedding,
             VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING 'mortgage pre-approval risk' AS DATA),
             COSINE), 4) AS similarity
    FROM product_embeddings pe
    JOIN products p ON p.product_id = pe.product_id
    ORDER BY similarity DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Mortgage Product Matches**

    | Product Name | Category | Similarity |
    | --- | --- | --- |
    | Mortgage Pre-Approval | Mortgage Lending | 0.6875 |
    | Loan Modification Review | Loan Servicing | 0.4409 |
    | Loan Portfolio Review | Risk Analytics | 0.4267 |
    | Risk Tolerance Assessment | Advisory | 0.4198 |
    | Adjustable Rate Mortgage | Mortgage Lending | 0.4161 |


2. Review the ranked products.
    The query embeds the analyst phrase at runtime and compares it to stored product embeddings. The `VECTOR_DISTANCE` order ranks products by semantic closeness, while the similarity score gives the analyst a way to compare the strength of each match.

    The expected top result is `Mortgage Pre-Approval`, followed by related lending and risk analytics products. The ranking helps analysts review likely matches first, even when the search phrase and product name are not identical.

    In the broader workflow, these ranked products can become the next filter for dashboard review, product exposure analysis, or operational follow-up.

## Task 2: Search risk signals by meaning

Now apply the same search-by-meaning pattern to monitored risk signal text:

1. Run the following query:

    You are applying the same semantic-search pattern to monitored risk signal text. The SQL embeds the phrase `Financial crime screening update affecting Liquidity Investment Sweep, suspicious ACH activity, sanctions compliance, and case review`, compares it with stored signal embeddings, joins back to the source signal text, and returns the highest-scoring excerpts for analyst review.

    ```sql
    <copy>
    SELECT sp.post_id AS signal_id,
           SUBSTR(sp.post_text, 1, 120) AS signal_excerpt,
           ROUND(1 - VECTOR_DISTANCE(
             se.embedding,
             VECTOR_EMBEDDING(ADMIN.ALL_MINILM_L12_V2 USING 'Financial crime screening update affecting Liquidity Investment Sweep, suspicious ACH activity, sanctions compliance, and case review' AS DATA),
             COSINE), 4) AS similarity
    FROM signal_embeddings se
    JOIN social_posts sp ON sp.post_id = se.post_id
    ORDER BY similarity DESC, signal_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Financial Crime Signal Matches**

    | Signal Id | Signal Excerpt | Similarity |
    | --- | --- | --- |
    | 2290 | AML screening update affects Liquidity Investment Sweep; FraudGuard Operations suspicious ACH and sanctions case review | 0.7352 |
    | 10 | AML screening update affects Liquidity Stress Test; Civic National Bank suspicious ACH and sanctions case review volume | 0.6762 |
    | 3310 | AML screening update affects Liquidity Stress Test; Civic National Bank suspicious ACH and sanctions case review volume | 0.6762 |
    | 2530 | AML screening update affects Secure Document Vault; CleanRate Lending suspicious ACH and sanctions case review volume ex | 0.6553 |
    | 3010 | AML screening update affects Secure Document Vault; CleanRate Lending suspicious ACH and sanctions case review volume ex | 0.6553 |


2. Compare the excerpts and scores.
    This query uses the same pattern against risk signal embeddings. It searches the language of monitored events, not just product metadata, so analysts can find signals that discuss fraud, AML, sanctions, or suspicious activity even when the wording is not identical to the search phrase.

    The returned excerpts contain AML, fraud, sanctions, and suspicious-activity language even though the search phrase does not use the AML abbreviation. The similarity score gives analysts a ranked review queue instead of an unordered pile of signal text.

    This connects dashboard risk signals to the language behind them. The analyst can move from a KPI to the related signal text without exporting the data to another search system.

## Next Steps

Congratulations on completing the AI Vector Search lab. You searched finance product and risk-signal text by meaning, not just by matching exact words. For a deeper hands-on workshop focused on AI Vector Search in Oracle Database, open the [AI Vector Search LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=4166).

## Acknowledgements

* **Authors** - Pat Shepherd, Linda Foinding
* **Contributors** - Teodor Nechita
* **Last Updated By/Date** - Oracle Database Product Management, August 2026
