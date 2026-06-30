# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

Use this scored quiz to check whether you can connect each Seer Bank finance outcome to the database evidence you inspected in the labs.

### Objectives

- Review the main database capabilities used in the workshop.
- Connect each finance outcome to supporting database evidence.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **5 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: Why does the workshop begin with the finance data foundation?
    - To manually install every finance table.
    * To map the shared data used by each later finance workflow.
    - To replace the application dashboard with catalog reports.
    - To move the finance records into external analysis files.
    > The foundation lab orients you to the shared database objects behind the application. Later labs reuse that foundation for dashboard evidence, transaction documents, vector search, graph analysis, spatial coverage, and Oracle Machine Learning (OML) scoring.

    Q: What is the main business value of recreating dashboard evidence with SQL?
    - It hides supporting rows from the risk operations review process.
    - It treats dashboard screenshots as the final evidence source.
    * It connects KPI summaries to reviewable database evidence.
    - It removes the need for finance semantic views.
    > The dashboard lab is about explainability. SQL aggregates connect the application summary to reviewable signal, exposure, transaction, product, and service evidence.

    Q: Which persona benefit does JSON Relational Duality provide in the transaction lab?
    - Risk teams lose SQL access to transaction review details.
    - Application teams must copy each transaction into another store.
    - Business users must manually parse raw JSON strings for review.
    * Developers can serve JSON while preserving relational control.
    > The business outcome is API-friendly transaction access without sacrificing relational integrity, governance, or SQL projection, which means returning selected JSON document fields as SQL columns.

    Q: Why is in-database AI Vector Search valuable for risk signal intelligence?
    * Analysts can search by meaning inside governed finance data.
    - Analysts must export signal text into a separate search service.
    - Search results come only from table and column metadata.
    - Reviewable SQL is replaced by hidden prompt output.
    > The vector lab shows semantic search by intent, not just keywords. The governance value is that embedding and similarity scoring stay near the finance data.

    Q: What business problem does the property graph lab solve for fraud investigators?
    - It scores future revenue for financial products and segments.
    * It explains connections across accounts and shared entities.
    - It stores service coverage regions for operations teams.
    - It replaces relationship evidence with flat product totals.
    > The graph lab focuses on relationship evidence. A fraud analyst can prioritize connected accounts, devices, payees, IP addresses, and phones without relying on fragile chains of manual joins.

    Q: Why does the service coverage lab use spatial data?
    - To make coverage decisions outside the governed database.
    - To hide capacity evidence from service operations leaders.
    * To compare distance, demand regions, and SLA zones.
    - To replace spatial queries with static labels.
    > Spatial data lets operations teams reason about distance and coverage from database evidence, which supports mapping, spatial queries, and location-aware applications.

    Q: What outcome does in-database OML scoring support?
    - Finance records must be exported into a separate prediction store.
    - Model output can only be reviewed inside the application UI.
    - Models can be trusted without showing SQL evidence.
    * Predictions can be scored where governed data already lives.
    > The OML lab is not only about model names. It shows how deployed models produce reviewable predictions close to the data that drives them.

    Q: What is the main advantage of using Oracle Database as the converged foundation for this workshop?
    - Each finance capability must use a separate specialized data store.
    * SQL, JSON, vector, graph, spatial, and OML evidence stay connected.
    - Application screenshots replace the need for database evidence.
    - Risk teams must reconcile copied data before every investigation.
    > The workshop uses different database capabilities for different finance questions, but the value is that they operate from connected governed data. That reduces copying, reconciliation, and fragmented explanations.
    ```

2. Review the completion badge.

    ![Finance LiveStack badge](images/livestack-finance-badge.png " ")

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
