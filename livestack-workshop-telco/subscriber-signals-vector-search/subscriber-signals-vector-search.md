# Lab 3: Subscriber Signals with AI Vector Search

## Introduction

Subscribers rarely describe problems in database terms. One person says the internet is lagging, another says video calls keep freezing, and another complains about installation instructions.

AI Vector Search helps care and network teams search by meaning, not only by exact keywords, while Oracle keeps the signal text, embeddings, SQL filters, and governance close to the same telecom data.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | Subscriber pain can surface in app feedback, outage reports, care chats, and community posts before traditional KPIs move. |
| Technical Challenge | Vector search is risky when sensitive signal text and embeddings must leave the governed database. |
| Persona Focus | Care operations leader, network experience analyst, and AI engineer. |
| What You Will Learn | Oracle AI Database can rank telecom services and subscriber signals by semantic meaning using in-database vectors. |
| Database Capability | Oracle AI Vector Search, VECTOR columns, `VECTOR_DISTANCE`, in-database embedding model. |
| Outcome | Teams can prioritize urgent subscriber intent without splitting the signal corpus into a separate vector store. |
{: title="What this lab covers"}

**Persona focus:** You are the care operations analyst looking for urgent meaning across subscriber language.

### Objectives

- Verify that service and subscriber-signal embeddings are available.
- Rank services by semantic similarity to subscriber language.
- Inspect high-priority signals that explain why a service needs attention.


The image below is the subscriber signals page. Care and network teams use this area to see how subscriber language clusters around services. The SQL in this lab shows how semantic matches behind the page can be queried from Oracle.

![Subscriber signals page](images/subscriber-signals-page.png)

The concept diagram below introduces the vector search pattern. It shows how text and embeddings stay connected to source service and signal rows, which helps search results remain governed instead of becoming a detached search index.

![AI Vector Search flow](images/vector-search-flow.svg)

## How This Lab Fits the Story

You move from dashboard symptoms to the words subscribers actually use. The vector and semantic-match queries show how Oracle AI Database can rank telecom intent by meaning while keeping sensitive signal text and embeddings governed.

## Scene Evidence

The image below is the signal feed result area. It gives care operations a way to inspect the subscriber words behind a service-pressure score. The SQL in this task returns the raw evidence that explains why a service is being prioritized.

![Signal feed results](images/signal-feed-results.png)

## Task 1: Verify signal and service embeddings

1. Run this SQL block.

    This query confirms that both sides of semantic matching exist: service embeddings and subscriber-signal embeddings. The `UNION ALL` result should return counts for both sets. If either side is missing, the database cannot compare subscriber language to services by meaning.

    ```sql
    <copy>
    SELECT 'Service embeddings' AS vector_set, COUNT(*) AS rows_loaded FROM service_embeddings
    UNION ALL
    SELECT 'Signal embeddings', COUNT(*) FROM signal_embeddings;
    </copy>
    ```

    **Expected output: Vector data available for semantic search**

    | Vector Set | Rows Loaded |
    | --- | ---: |
    | Service embeddings | 32 |
    | Signal embeddings | 5000 |
    {: title="Vector data available for semantic search"}

This count confirms that semantic search has material to work with. Services and subscriber signals both have embeddings, so the database can compare meaning without moving sensitive text into a separate search platform.

## Task 2: Rank services by signal similarity history

1. Run this SQL block.

    This query summarizes which services attract the most semantically similar subscriber signals. It groups `SEER_COMMS_SIGNAL_MATCHES_V` by service, counts matches, and reports strongest and average similarity. Look for services with many matches and high similarity, because those services are where subscriber language is concentrating.

    ```sql
    <copy>
    SELECT service_name,
       service_line_name,
       COUNT(*) AS matching_signals,
       ROUND(MAX(similarity_score), 3) AS strongest_similarity,
       ROUND(AVG(similarity_score), 3) AS avg_similarity
    FROM seer_comms_signal_matches_v
    GROUP BY service_name, service_line_name
    ORDER BY matching_signals DESC, strongest_similarity DESC
    FETCH FIRST 8 ROWS ONLY;
    </copy>
    ```

    **Expected output: Services ranked by signal meaning**

    | Service Name | Service Line Name | Matching Signals | Strongest Similarity | Avg Similarity |
    | --- | --- | ---: | ---: | ---: |
    | Fixed Wireless Home Internet | Seer Home Broadband | 57 | 0.89 | 0.72 |
    | Device Upgrade Enrollment | Seer Mobile | 55 | 0.88 | 0.71 |
    | Gigabit Fiber Install | Seer Fiber | 53 | 0.87 | 0.70 |
    {: title="Services ranked by signal meaning"}

This result turns noisy feedback into a short list. When many subscriber signals cluster around the same service, care and network teams get a practical place to focus.

## Task 3: Inspect high-priority subscriber signals

1. Run this SQL block.

    This query shows the raw subscriber evidence behind the ranked service pressure. It orders signals by exposure and escalations, then returns a short text excerpt. Look for the combination of reach, escalation, and wording so the ranking feels explainable rather than mysterious.

    ```sql
    <copy>
    SELECT signal_channel,
       advocate_handle,
       exposure_count,
       escalations,
       SUBSTR(signal_text, 1, 90) AS signal_excerpt
    FROM seer_comms_subscriber_signals_v
    ORDER BY exposure_count DESC, escalations DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Subscriber signals behind the match**

    | Signal Channel | Advocate Handle | Exposure Count | Escalations | Signal Excerpt |
    | --- | --- | ---: | ---: | --- |
    | threads | @roamflow_vince | 19937363 | 15923 | Subscribers are asking for clearer instructions after fiber installation and fas |
    | instagram | @signalbridge_leo | 19878738 | 89853 | Subscribers are asking about IoT Sensor Gateway Kit through OrbitMotion IoT |
    {: title="Subscriber signals behind the match"}


Exposure and escalations help triage urgency. The excerpt explains what subscribers are experiencing. Keeping both together lets Oracle support SQL review, vector search, and security policy enforcement from the same evidence.


## Learn More

- [Oracle AI Vector Search documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)

## Acknowledgements

- **Author** - Oracle LiveLabs Team
