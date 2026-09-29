# Final Quiz

```quiz-config
passing: 75
badge: images/livestack-telecommunications-badge.svg
```

## Introduction

Use this quiz to check how the database results support the SEER Telecomms tasks you completed.

### Objectives

- Review the main database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does JSON Relational Duality help SEER Telecomms do in the service order lab?
    - Copy service order documents into a separate document database.
    * Use the same service order data as JSON documents or relational tables without maintaining duplicate records.
    - Remove relational tables from the service order review process.
    - Force analysts to manually read raw JSON for every review.
    > A duality view presents relational rows as a JSON document. Applications get the document they need, while analysts still use SQL, keys, joins, and database controls against the same source.

    Q: In the vector lab, what does the similarity score help an analyst do?
    - Prove that a subscriber concern confirms activation fraud.
    - Replace the service plan and service order tables with embeddings only.
    * Rank service plans by how closely they match the search phrase.
    - Count how many rows exist in each telecommunications table.
    > The query turns vector distance into a similarity score, where a higher score means the stored service plan text is closer in meaning to the search phrase.

    Q: What business problem does the property graph lab solve for activation fraud investigators?
    - It scores future monthly charges for service plans and segments.
    * It explains connections across service orders and shared entities.
    - It stores service coverage regions for operations teams.
    - It replaces relationship data with flat service plan totals.
    > The graph lab focuses on relationship data. An activation fraud analyst can prioritize connected service orders, devices, payment tokens, IP addresses, and phones without writing a separate chain of joins for each path length.

    Q: Why does SEER Telecomms use spatial data in the network-site lab?
    - To make coverage decisions outside the shared database.
    - To hide capacity data from service operations leaders.
    * To find the closest network site for a subscriber or high-demand region and combine that location with site capacity and current workload.
    - To replace spatial queries with static labels.
    > Spatial functions calculate distance and location relationships. SQL combines those results with subscriber, network-site, capacity, and demand data to help the operations team review nearby sites.

    Q: What does the OML lab's `SURGE_SCORE` represent?
    - It guarantees that the prediction will happen.
    * The model's probability for the SURGE class, which the analyst should still review.
    - It is the number of rows in the OML model catalog.
    - It means the model no longer needs business context.
    > The score ranks plans for review; it does not guarantee a surge. Inspect the model's errors in the confusion matrix. These sample labels describe the same period as the inputs, so the exercise does not measure future-demand accuracy.

    Q: What makes the Select AI answers reviewable?
    - The model can query every object in the database automatically.
    - The narrative wording is guaranteed to be identical every time.
    * The profile lists the intended objects and the generated SQL remains visible.
    - The answer bypasses the database and uses only general model knowledge.
    > The telecommunications Select AI profile has a narrow object list to guide generation; database privileges enforce access. SHOWSQL shows the generated query, and SQL review lets reviewers compare the narrative with the database result.

    Q: What is the main advantage of using Oracle AI Database as the shared database for this workshop?
    - Each telecommunications capability must use a separate specialized data store.
    * One Oracle AI Database connects relational, JSON, vector, graph, spatial, machine-learning, and AI capabilities to the same shared data.
    - Application screenshots replace the need for database results.
    - Subscriber service teams must reconcile copied data before every investigation.
    > Each lab uses a different capability, but the teams work from connected data in one database. This reduces duplicate copies and separate integration paths while preserving database controls.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026

