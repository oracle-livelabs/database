# Final Quiz

```quiz-config
passing: 75
badge: images/badge-transportation.svg
```

## Introduction

Use this scored quiz to check whether you can connect Seer Transport business decisions to database evidence. The questions span fleet operations, shipment documents, and governed AI assistance across all eight labs.

### Objectives

- Review the converged transportation decision flow and the role each persona played.
- Explain why scores, generated SQL, and agent recommendations remain evidence for human review.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: Why does Jessica use one converged fleet operations query?
    - To hide the source evidence behind dashboard totals.
    * To connect service pressure, semantic relevance, shipment activity, and terminal geography in one reviewable result.
    - To copy each data type into a separate specialist database.
    - To replace operational judgment with a dashboard score.
    > The converged query keeps several data models connected to the same governed transportation records and makes drill-through possible.

    Q: What does a JSON-Relational Duality View help Thomas do?
    - Maintain a separate document copy of every shipment order.
    - Remove relational keys from the application model.
    * Serve shipment orders as JSON while analysts query the same underlying relational rows.
    - Require every application to assemble JSON outside the database.
    > `ORDERS_DV` presents order headers and items as one document without abandoning relational SQL or duplicating the source records.

    Q: What does a higher semantic similarity score indicate in the disruption lab?
    * The stored service or signal text is closer in meaning to the search phrase.
    - The disruption is proven to be the root cause.
    - The signal row bypassed database security.
    - The embedding replaced the source text.
    > Similarity ranks evidence for review. It does not establish certainty or remove the need to inspect urgency and source text.

    Q: Why does Bob start a graph investigation with a bounded hop count?
    - Property graphs cannot represent more than two relationships.
    - The graph automatically changes transportation records at each hop.
    - A larger graph always returns fewer entities.
    * A small depth keeps direct evidence readable before expanding to wider propagation paths.
    > One hop shows direct dependencies; two hops can reveal propagation through an intermediary while expanding the review queue.

    Q: Why does Moon combine spatial distance with terminal capacity when ranking candidates?
    - The nearest terminal is always the correct operational choice.
    * It provides candidate-terminal evidence for human review when a nearby terminal is active and has enough unreserved service capacity.
    - Capacity rows replace the need for geographic data.
    - Spatial calculations require a separate mapping database.
    > Oracle Spatial lets distance join directly to the same terminal and capacity records used by operations. It does not calculate a road route or make a routing decision.

    Q: Which statement correctly describes the Oracle Machine Learning for SQL result and its evaluation?
    - `PREDICTION_PROBABILITY` guarantees that the service will surge in the outcome week.
    - Training-set agreement is sufficient evidence for an operational capacity watchlist.
    * `PREDICTION_PROBABILITY(..., 'SURGE')` is the estimated class probability for `SURGE`, not a confidence guarantee, and Otto checks predictions on held-out labeled rows.
    - `DBMS_DATA_MINING` is a SQL scoring function that replaces held-out evaluation.
    > `PREDICTION` and `PREDICTION_PROBABILITY` score rows in SQL. Held-out evaluation checks those results on rows excluded from training; the estimated class probability is not certainty or calibrated confidence.

    Q: What makes the Select AI workflow used by Nina reviewable?
    - The provider can use every database object automatically.
    - The narrative response is identical on every run.
    * The profile narrows approved objects and Nina can inspect generated SQL before running it.
    - The answer bypasses Oracle Database.
    > The object list, database privileges, and visible SQL keep natural-language access connected to governed execution.

    Q: What approved capability does the agent have in Lab 8?
    - Unrestricted insert, update, and delete access.
    - Direct control of transportation equipment.
    - A hidden copy of the operational schema.
    * One read-only SQL tool backed by the approved Select AI profile.
    > The agent, task, and team use a narrow tool boundary, and Oracle records team and tool execution history.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
