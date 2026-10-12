# Final Quiz

```quiz-config
passing: 75
badge: images/energy-utilities-badge.png
```

## Introduction

Review how Jessica and her colleagues use database evidence to support operational decisions at Seer Utility Network.

The questions cover the workshop’s demonstrated capabilities and the approval boundaries for Labs 7–8. Completing the quiz does not establish that the pending Select AI workflows have been validated.

### Objectives

- Connect each database capability to its operational use case.
- Distinguish supporting evidence from an automatic decision or a proven outcome.
- Earn the workshop badge by answering at least six of the eight questions correctly.

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
    * The embedded service text is semantically close to the question, making the service a candidate for review.
    - The utility confirmed a compliance breach.
    - The result is approved automatically for dispatch.
    > Similarity ranks related meanings. It supports investigation, but it does not prove a service problem, establish causality, or authorize an operational action.

    Q: What does Bob inspect with the lab's directed, one-hop graph query?
    - Every incoming and outgoing path of any length.
    - Proof that each connected asset caused the event.
    - A road route between the event and a field site.
    * The entities reached by an outgoing relationship from a selected operational event.
    > The SQL/PGQ query follows one directed edge from the starting event. The separate prepared findings view summarizes broader evidence; a connection does not prove causality.

    Q: Why does Moon include operational status and capacity with distance?
    * The nearest active site may still be constrained, so dispatch requires more than proximity.
    - Spatial distance includes crew qualifications and safety approval automatically.
    - Capacity is needed only to draw the map.
    - The database cannot calculate distance without an AI provider.
    > Geographic distance identifies nearby candidates, not road routes or travel times. Dispatchers still review workload, supplies, safety, skills, and service-territory constraints.

    Q: How should Otto use a demand-surge probability?
    - As certainty that a surge will occur.
    - As permission to dispatch a crew automatically.
    * As a model estimate for human review, evaluated against held-out labels and considered alongside capacity evidence.
    - As a substitute for validation data.
    > Otto evaluates the prepared model against synthetic labels on cases excluded from training, then combines predictions with capacity evidence. The class-probability estimate is not certainty or a validated forecast of future demand. A six-case synthetic test set does not establish production performance.

    Q: Why does Nina use SHOWSQL before making a separate execution request?
    - To reveal the AI provider credential.
    * To inspect the proposed query's objects, filters, ordering, and row limits and refine the question if needed.
    - To grant Select AI access to every schema.
    - To guarantee that RUNSQL executes exactly the displayed statement.
    > SHOWSQL exposes a proposed query for review. A later RUNSQL call may generate different SQL; the review does not bind that call to the displayed statement. To execute precisely the reviewed SQL, run that statement directly in SQL Worksheet within the authorized scope.

    Q: What evidence makes the Select AI Agent workflow reviewable?
    - The agent's confident wording alone.
    - A screenshot without SQL or history.
    - A broad write-capable tool with no verified restrictions.
    * Verified tool permissions, database access controls, and history tied to the specific team execution.
    > Read-only wording in a prompt expresses an intention, not enforcement. The object list supplies context; verified tool restrictions and effective database permissions enforce access. History supports review but does not prove that an answer is correct or that read-only access was enforced. Labs 7–8 live behavior remains pending validation.
    ```

2. Review the explanations for any incorrect answers. When you achieve the passing score, the quiz displays your Energy and Utilities completion badge.

## Acknowledgements

* **Author** - Zileyah Onafowora
* **Last Updated By/Date** - Zileyah Onafowora, September 2026
