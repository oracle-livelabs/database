# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

Use this scored quiz to check whether you can connect the Seer Bank finance outcomes to the database evidence you inspected in the labs.

### Objectives

- Review the main database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does JSON Relational Duality help Seer Bank do in the transaction lab?
    - Copy transaction documents into a separate document database.
    * Use the same transaction data as JSON documents or relational tables without maintaining duplicate records.
    - Remove relational tables from the transaction review process.
    - Force analysts to manually read raw JSON for every review.
    > A duality view presents relational rows as a JSON document. Applications get the payload they need, while analysts still use SQL, keys, joins, and database controls against the same source.

    Q: In the vector lab, what does the similarity score help an analyst do?
    - Prove that a risk signal is confirmed fraud.
    - Replace the product and signal tables with embeddings only.
    * Rank products or signals by how closely they match the search phrase.
    - Count how many rows exist in each finance table.
    > The query turns vector distance into a similarity score, where a higher score means the stored product or signal text is closer in meaning to the search phrase.

    Q: What business problem does the property graph lab solve for fraud investigators?
    - It scores future revenue for financial products and segments.
    * It explains connections across accounts and shared entities.
    - It stores service coverage regions for operations teams.
    - It replaces relationship evidence with flat product totals.
    > The graph lab focuses on relationship evidence. A fraud analyst can prioritize connected accounts, devices, payees, IP addresses, and phones without relying on fragile chains of manual joins.

    Q: Why does Seer Bank use spatial data in the service coverage lab?
    - To make coverage decisions outside the governed database.
    - To hide capacity evidence from service operations leaders.
    * To find the closest service center for a customer or high-demand region and combine that location with center capacity and current workload.
    - To replace spatial queries with static labels.
    > Spatial functions calculate distance and location relationships. SQL combines those results with customer, service-center, capacity, and demand data to support routing decisions.

    Q: In the OML lab, what does model confidence mean?
    - It guarantees that the prediction will happen.
    * It is the model probability for a prediction and should still be reviewed.
    - It is the number of rows in the OML model catalog.
    - It means the model no longer needs business context.
    > Confidence helps compare stronger and weaker predictions, but it is not certainty. The lab also uses a simple agreement check to compare predicted labels with the demo labels.

    Q: What makes the Select AI answers governed and reviewable?
    - The model can query every object in the database automatically.
    - The narrative wording is guaranteed to be identical every time.
    * The profile restricts approved objects and the generated SQL remains visible.
    - The answer bypasses the database and uses only general model knowledge.
    > The finance Select AI profile has a narrow object list. SHOWSQL exposes the generated query, and the direct SQL proof lets reviewers compare the narrative with the database result.

    Q: What is the main advantage of using Oracle AI Database as the converged foundation for this workshop?
    - Each finance capability must use a separate specialized data store.
    * One Oracle AI Database connects relational, JSON, vector, graph, spatial, machine-learning, and AI capabilities to the same governed data.
    - Application screenshots replace the need for database evidence.
    - Risk teams must reconcile copied data before every investigation.
    > Each lab uses a different capability, but the teams work from connected data in one database. This reduces duplicate copies and separate integration paths while preserving database controls.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Acknowledgements

* **Authors** - Pat Shepherd, Linda Foinding
* **Contributors** - Teodor Nechita
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
