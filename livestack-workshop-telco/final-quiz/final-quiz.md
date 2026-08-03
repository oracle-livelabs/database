# Final Quiz

```quiz-config
passing: 75
badge: images/livestack-badge-telecommunications.png
```

## Introduction

Use this scored quiz to check whether you can connect a Seer Comms decision to the database evidence behind it.

### Objectives

- Review the seven database capabilities used in the workshop.
- Explain the business outcome of each SQL pattern.

Estimated Time: **5 minutes**

## Task 1: Answer the quiz questions

1. Follow the steps below.

    ```quiz score
    Q: Why does the Operations Center lab include a drill-through query after a summary?
    - To replace dashboard evidence with a screenshot.
    * To show the reviewable network-site rows behind a KPI.
    - To create a separate reporting database.
    - To generate a random capacity score.
    > A dashboard total is useful only when an operations team can inspect the contributing sites and decide what to do next.

    Q: What does ORDERS_DV provide for a service-order application?
    - A second copy of order rows in a document store.
    * A JSON projection backed by relational order data.
    - A property graph of service routes.
    - A vector index for network sites.
    > JSON Relational Duality lets an application use document-shaped data while SQL continues to use the same governed source.

    Q: Why does the vector lab show fixed rows from SIGNAL_SERVICE_MATCHES?
    - It replaces the source signal with an embedding only.
    * It lets an analyst review the matched service and retained similarity evidence.
    - It calculates the miles between network sites.
    - It creates a second service-order document.
    > The match table keeps the signal, service, score, and match method connected for review.

    Q: What does the graph seed case provide?
    - A random data sample.
    - A replacement for the subscriber table.
    * The starting point for an investigation of connected entities.
    - A model confidence score.
    > SQL/PGQ starts from the named experience case and follows its relationship evidence.

    Q: Why does the field-operations lab use Oracle Spatial?
    - To replace operational rows with a map image.
    - To export site coordinates to an unrelated system.
    - To turn graph edges into vectors.
    * To calculate point and distance evidence next to operational data.
    > Keeping geography in the same database makes field-response decisions easier to review and repeat.

    Q: What does a capacity-risk prediction in the OML lab provide?
    - A guaranteed outage outcome.
    * A model-based priority signal to review beside site capacity and load evidence.
    - A replacement for the network-site table.
    - A copy of capacity data in a separate machine-learning system.
    > A prediction helps a planner decide where to investigate. It does not replace the operational evidence or make the action automatically.

    Q: What is the main advantage of the converged database foundation in this workshop?
    - Each capability requires a separate specialist store.
    * SQL, JSON, vector, graph, and spatial evidence stay connected.
    - Screenshots replace the need for database evidence.
    - Teams must reconcile copied data before investigating.
    > The workshop uses several data models, but they remain connected under one governance model.
    ```

2. Review your completion badge.

    ![Telecommunications LiveStack completion badge](images/livestack-badge-telecommunications.png " ")

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Pat Shepherd, July 2026
