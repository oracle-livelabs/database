# Final Quiz

```quiz-config
passing: 75
badge: images/energy-utilities-badge.svg
```

## Introduction

Use this scored quiz to connect Seer Utility Network outcomes to the database evidence from the labs.

### Objectives

- Review the main database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **5 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz. A score of **75%** or higher earns the badge.

    ```quiz score
    Q: Why does Jessica build the energy operations review query from governed views?
    - To replace source tables with dashboard screenshots.
    * To connect requests, signals, logistics, and capacity evidence without separate operational data copies.
    - To let every user bypass database privileges.
    - To turn every row into JSON before analysis.
    > Lab 1 uses relational SQL to connect evidence from one database foundation. JSON, vector, graph, and spatial operations appear in later labs, not in this query.

    Q: What does JSON Relational Duality give Thomas?
    - A second document database that Thomas must synchronize manually.
    - A vector index for service-request text.
    * An application-ready JSON document backed by the same relational request and line-item data.
    - A replacement for relational constraints.
    > The duality view presents relational rows as a document. Applications get JSON while operations teams retain SQL, keys, and database controls.

    Q: What does a high vector similarity score mean in Gilly's search?
    - The service caused the operational event.
    * The stored service description is semantically close to the question and deserves review.
    - The utility confirmed a compliance breach.
    - The result is approved automatically for dispatch.
    > Similarity ranks related meanings. It supports investigation, but it does not prove causality or authorize an operational action.

    Q: What does Bob inspect with the lab's directed, one-hop graph query?
    - Every incoming and outgoing path of any length.
    - Proof that each connected asset caused the event.
    - A road route between the event and a field site.
    * The entities reached by an outgoing relationship from a selected operational event.
    > The SQL property graph query follows one directed edge from a seed entity. The separate prepared findings view summarizes broader evidence; a connection does not prove causality.

    Q: Why does Moon include operational status and capacity with distance?
    * The nearest active site may still be constrained, so dispatch requires more than proximity.
    - Spatial distance includes crew qualifications and safety approval automatically.
    - Capacity is needed only to draw the map.
    - The database cannot calculate distance without an AI provider.
    > Distance identifies candidates. Dispatchers still review workload, supply, safety, skills, and territory constraints.

    Q: How should Otto use a demand-surge probability?
    - As certainty that a surge will occur.
    - As permission to dispatch a crew automatically.
    * As decision-support evidence for a human review queue, checked against known outcomes and capacity data.
    - As a substitute for validation data.
    > Otto evaluates a prepared model on labeled cases separate from training, then combines scores with capacity evidence. Probability is model confidence, not certainty; a tiny synthetic test set does not establish production performance.

    Q: Why does Nina use SHOWSQL before RUNSQL?
    - To reveal the AI provider credential.
    * To inspect selected objects, filters, ordering, and row limits before generated SQL executes.
    - To grant Select AI access to every schema.
    - To prevent the database from enforcing privileges.
    > SHOWSQL exposes the proposed query so Nina can review and refine the request. A later RUNSQL call may generate different SQL; review does not bind that call to the exact displayed statement.

    Q: What evidence makes the Select AI Agent workflow reviewable?
    - The agent's confident wording alone.
    - A screenshot without SQL or history.
    - A broad write-capable tool with no confirmation step.
    * Verified tool permissions, database access controls, and history tied to the specific team execution.
    > Read-only wording in a prompt is an intention, not enforcement. The object list supplies context; tool configuration and database security enforce access. History supports review but does not prove an answer is correct. Labs 7–8 live behavior remains pending validation.
    ```

2. When you achieve the passing score, the quiz displays your Energy and Utilities completion badge.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
