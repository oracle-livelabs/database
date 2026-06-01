# Final Quiz

## Introduction

Use this quiz to check your understanding of how the retail LiveStack uses Oracle Database 26ai to power the Seer Sporting Goods workflow. The questions focus on why each database capability matters to retail decisions.

Estimated Time: **5 minutes**

### Objectives

- Review the core Oracle Database 26ai capabilities used in the workshop.
- Match visible retail outcomes to database-side patterns.
- Confirm that you can explain the value of keeping data, AI context, security, and audit together.

```quiz-config
passing: 75
badge: images/badge.png
```

## Task 1: Check Your Understanding

1. Answer the following questions.

    ```quiz score
    Q: Why does the retail LiveStack use Oracle Database 26ai as a converged data platform?
    * It keeps relational, JSON, vector, graph, spatial, OML, security, and audit evidence close to governed operational data.
    - It copies every workload into a separate specialty database.
    - It removes the need for business rules or access controls.
    - It stores only static dashboard text.
    > The workshop shows several data models and AI-adjacent capabilities operating over one governed retail schema.



    Q: What does the Retail Command Center demonstrate?
    * Operational KPIs, customer signal velocity, revenue categories, product momentum, return exposure, and agent activity can be assembled from governed database evidence.
    - Dashboard values must be typed manually into the frontend.
    - Retail teams should copy operational data into unrelated tools before asking questions.
    - Command center screens cannot use SQL.
    > The command center brings operational and analytical evidence together without separating it from the governed retail schema.

    Q: What business value does JSON Relational Duality provide in the order lab?
    * It exposes order detail as JSON while preserving relational tables, constraints, joins, and transactions.
    - It deletes the relational order tables after creating JSON.
    - It bypasses VPD and auditing.
    - It only works for screenshots.
    > JSON Duality gives application-friendly documents without moving the source of truth out of Oracle Database.

    Q: What does VPD add to the retail order and fulfillment workflow?
    * Database-enforced regional access rules that stay with the protected tables.
    - A replacement for all indexes.
    - A way to generate embeddings.
    - A separate graph database.
    > VPD policies enforce access in the database, independent of the screen that asks for data.

    Q: Which capability powers semantic matching for customer trend signals?
    - Only exact string matching.
    * MiniLM L12 v2 embeddings with VECTOR_EMBEDDING and VECTOR_DISTANCE.
    - Only CSV export.
    - Only an application cache.
    > Vector search compares meaning, so a retail signal can match relevant products even when words differ.

    Q: Why use Property Graph for creator influence analysis?
    * It traverses connected creators, brands, products, and posts to reveal influence paths.
    - It converts every table into a PDF.
    - It prevents joins from running.
    - It must run before any SQL query.
    > SQL/PGQ lets the database answer relationship questions directly over graph-defined retail data.

    Q: What does Oracle Spatial contribute to fulfillment decisions?
    * Location storage, GeoJSON output, and distance calculations near inventory and order data.
    - Wallet password storage.
    - Quiz scoring.
    - A replacement for customer tables.
    > Spatial functions help decide which center can serve demand quickly without moving location logic elsewhere.

    Q: Why keep OML models in the database?
    * Models can train and score against governed operational features without exporting sensitive data.
    - Models can only run after a spreadsheet export.
    - OML disables SQL analytics.
    - OML is only a UI component.
    > In-database models keep scoring close to the feature views and operational controls.

    Q: Why does the Ask Retail Data lab avoid required DBMS_CLOUD_AI.GENERATE calls?
    * Live AI calls depend on profile ownership and OCI AI setup. The lab uses fixed semantic views, comments, PL/SQL tools, and audit evidence.
    - Natural-language workflows should never use database metadata.
    - The database cannot store comments.
    - Agent tools do not need audit records.
    > The safe path teaches grounding without requiring external AI setup.
    ```

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
