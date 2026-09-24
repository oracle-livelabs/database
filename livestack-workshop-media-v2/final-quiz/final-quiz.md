# Final Quiz

```quiz-config
passing: 75
badge: images/livestack-media-badge.svg
```

## Introduction

Use this scored quiz to review the Seer Media labs. Connect each campaign and content result to its database evidence.

### Objectives

- Review the main database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does JSON Relational Duality help Seer Media do in the campaign order lab?
    - Copy campaign order documents into a separate document database.
    * Use the same campaign order data as JSON documents or relational tables without maintaining duplicate records.
    - Remove relational tables from the campaign order review process.
    - Force analysts to manually read raw JSON for every review.
    > A duality view presents relational rows as a JSON document. Applications get the payload they need, while analysts still use SQL, keys, joins, and database controls against the same source.

    Q: In the vector lab, what does the similarity score help an analyst do?
    - Confirm that a launch signal requires community-operations review.
    - Replace the content and signal tables with embeddings only.
    * Rank content assets or audience signals by how closely they match the search phrase.
    - Count how many rows exist in each Media view.
    > The query turns vector distance into a similarity score, where a higher score means the stored content description or audience signal text is closer in meaning to the search phrase.

    Q: What business problem does the property graph lab solve for Seer Media community analysts?
    - It predicts future campaign value from operational features.
    * It explains connections among creators, audience signals, content assets, and studios or labels.
    - It stores service coverage regions for operations teams.
    - It replaces relationship evidence with flat content totals.
    > The graph lab focuses on relationship evidence. A community analyst follows creator connections and creator-to-studio relationships. The graph also represents audience-signal mentions of content assets.

    Q: Why does Seer Media use spatial data in the distribution capacity lab?
    - To make coverage decisions outside the governed database.
    - To hide capacity evidence from distribution operations leaders.
    * To find nearby distribution hubs for an audience account or demand region and compare capacity and current workload.
    - To replace spatial queries with static labels.
    > Spatial functions calculate distance and location relationships. SQL combines those results with audience account, distribution hub, capacity, and demand data to support routing decisions.

    Q: In the OML lab, what does the SURGE probability score mean?
    - It guarantees that the prediction will happen.
    * It is the model score for the SURGE class and should be reviewed with the activity data.
    - It is the number of rows in the OML model catalog.
    - It means the model no longer needs business context.
    > The score ranks content assets for review. The loader derives synthetic SURGE and STABLE labels from current activity, so the score is not a measured future outcome or proof of forecasting accuracy.

    Q: What makes the Select AI answers governed and reviewable?
    - The model can query every object in the database automatically.
    - The narrative wording is guaranteed to be identical every time.
    * The profile enforces its Media view list, database privileges still apply, and generated SQL remains visible.
    - The answer bypasses the database and uses only general model knowledge.
    > The profile lists five MEDIA_* views and enables enforce_object_list. SHOWSQL exposes the generated query, and a direct SQL check compares its answer with the database result. Neither a prompt nor an object list makes the schema owner a read-only account.

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
