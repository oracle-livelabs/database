# Final Quiz

```quiz-config
passing: 75
badge: images/livestack-media-badge.svg
```

## Introduction

Use this scored quiz to check whether you can connect the Seer Media media outcomes to the database evidence you inspected in the labs.

### Objectives

- Review the main database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does JSON Relational Duality help Seer Media do in the viewing session lab?
    - Copy viewing session documents into a separate document database.
    * Use the same viewing session data as JSON documents or relational tables without maintaining duplicate records.
    - Remove relational tables from the viewing session review process.
    - Force analysts to manually read raw JSON for every review.
    > A duality view presents relational rows as a JSON document. Applications get the payload they need, while analysts still use SQL, keys, joins, and database controls against the same source.

    Q: In the vector lab, what does the similarity score help an analyst do?
    - Confirm that a launch signal requires community-operations review.
    - Replace the title and signal tables with embeddings only.
    * Rank titles or signals by how closely they match the search phrase.
    - Count how many rows exist in each media table.
    > The query turns vector distance into a similarity score, where a higher score means the stored title or signal text is closer in meaning to the search phrase.

    Q: What business problem does the property graph lab solve for Seer Media community analysts?
    - It scores future revenue for content titles and segments.
    * It explains connections across creators, viewer sessions, and shared entities.
    - It stores service coverage regions for operations teams.
    - It replaces relationship evidence with flat title totals.
    > The graph lab focuses on relationship evidence. A community analyst can prioritize connected creators, viewer sessions, devices, IP addresses, and phones without relying on fragile chains of manual joins.

    Q: Why does Seer Media use spatial data in the service coverage lab?
    - To make coverage decisions outside the governed database.
    - To hide capacity evidence from service operations leaders.
    * To find the closest live-event operations hub for a viewer or high-audience region and combine that location with center capacity and current workload.
    - To replace spatial queries with static labels.
    > Spatial functions calculate distance and location relationships. SQL combines those results with viewer, live-event-operations-hub, capacity, and demand data to support routing decisions.

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
    > The media Select AI profile has a narrow object list. SHOWSQL exposes the generated query, and the direct SQL proof lets reviewers compare the narrative with the database result.

    Q: What is the main advantage of using Oracle AI Database as the converged foundation for this workshop?
    - Each media capability must use a separate specialized data store.
    * One Oracle AI Database connects relational, JSON, vector, graph, spatial, machine-learning, and AI capabilities to the same governed data.
    - Application screenshots replace the need for database evidence.
    - Community operations teams must reconcile copied data before every investigation.
    > Each lab uses a different capability, but the teams work from connected data in one database. This reduces duplicate copies and separate integration paths while preserving database controls.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Acknowledgements

* **Authors** - Pat Shepherd, Linda Foinding
* **Contributors** - Teodor Nechita
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
