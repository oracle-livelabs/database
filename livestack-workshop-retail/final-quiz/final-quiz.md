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
badge: images/retail-badge.png
```

## Task 1: Check Your Understanding

1. Answer the following questions.

    ```quiz score
    Q: What is the main operating pattern of the retail workshop?
    * Observe demand, understand what is happening, decide how to respond, act through trusted database-backed tools, and review the evidence.
    - Export every retail dataset into separate specialty systems before making decisions.
    - Replace SQL, governance, and audit trails with static application screenshots.
    - Focus only on one dashboard metric and ignore downstream actions.
    > The workshop follows one retail decision loop: observe, understand, decide, act, and review.

    Q: In Lab 1, why do you inventory the retail data foundation?
    * To confirm that the tables, views, vector artifacts, graph objects, OML models, and PL/SQL tools used by later labs are present.
    - To rebuild the entire workshop schema by hand.
    - To prove that the application does not use database objects.
    - To copy every table into a separate reporting database.
    > Lab 1 establishes that later answers are grounded in a known, queryable database foundation.

    Q: In Lab 2, what does the Retail Command Center prove?
    * Daily operating metrics, trending products, product detail, and revenue categories can be traced back to governed SQL evidence.
    - Dashboard values must be manually typed into the frontend.
    - Business users should trust a dashboard only when the SQL is hidden.
    - Retail command centers cannot combine orders, returns, social posts, and agent actions.
    > The command center is a live operating picture backed by database evidence.

    Q: In Lab 3, what is the key lesson of JSON Relational Duality?
    * The same order can be read and changed as a JSON document while Oracle stores the data in relational `ORDERS` and `ORDER_ITEMS` rows.
    - Creating a JSON view deletes the relational tables.
    - JSON documents must be stored in a separate database before SQL can use them.
    - A duality view can only be used for read-only screenshots.
    > JSON Relational Duality gives applications a document shape without moving the source of truth out of relational tables.

    Q: Why does Lab 3 recreate `ORDERS_DV` with INSERT, UPDATE, and DELETE enabled?
    * To show that the database owner can make a duality view writable with declarative SQL while keeping relational storage and transactions.
    - To disable SQL access to the `ORDERS` table.
    - To bypass relational constraints and commit rules.
    - To convert every order into a flat CSV file.
    > The lab shows that a view can support document-style writes while Oracle maps the changes back to relational rows.

    Q: In Lab 4, what do `DBMS_VECTOR_CHAIN.UTL_TO_EMBEDDING` and `VECTOR_DISTANCE` do together?
    * They turn a natural-language phrase into a vector and compare it with stored product vectors so closer matches can be ranked by meaning.
    - They encrypt order rows and hide them from SQL.
    - They create a property graph from creator relationships.
    - They calculate driving distance between fulfillment centers.
    > Lab 4 teaches semantic search: compare meaning, not just exact words.

    Q: In Lab 5, why is Property Graph useful for creator influence analysis?
    * It lets you query paths across creators, brands, products, and posts without building increasingly complex multi-hop joins.
    - It replaces all retail tables with image files.
    - It prevents relationship questions from using SQL.
    - It only counts rows and cannot show influence paths.
    > Property Graph and `GRAPH_TABLE` make connected retail relationships easier to express and inspect.

    Q: In Lab 6, what does Oracle Spatial add to fulfillment decisions?
    * It stores locations and service zones as geometry, outputs map-ready GeoJSON, and calculates distance alongside inventory data.
    - It generates customer passwords for SQL Worksheet.
    - It trains the demand-surge model.
    - It replaces inventory tables with static map screenshots.
    > Spatial analysis helps explain which fulfillment centers are practical choices for a customer order.

    Q: In Lab 7, why keep Oracle Machine Learning models in the database?
    * SQL can score current retail feature views with in-database models and connect predictions directly to inventory action.
    - Planners must export sensitive data before a model can be scored.
    - OML models are only labels on application screens.
    - Machine learning results cannot be joined to operational tables.
    > OML keeps predictions close to governed features, inventory evidence, and SQL action lists.

    Q: In Lab 8, what makes an Ask Retail Data answer trustworthy?
    * The answer maps to approved views, readable columns, visible filters, and repeatable SQL that can be inspected.
    - The answer is trusted because the generated SQL is hidden.
    - The answer should ignore database comments, views, and validation paths.
    - The answer requires every learner to configure a live GenAI profile.
    > Lab 8 focuses on trusted answers: plain-English questions should still trace back to governed SQL and data.

    Q: In Lab 9, what separates trusted agent actions from free-form AI guesses?
    * The agent uses approved PL/SQL tool functions, returns grounded database evidence, and leaves rows in `AGENT_ACTIONS`.
    - The agent is trusted because it avoids database tools.
    - The agent should call any function it invents at runtime.
    - Agent responses do not need audit history.
    > Lab 9 focuses on trusted actions: controlled tools plus durable audit evidence.

    Q: What is the overall business takeaway from the workshop?
    * Oracle AI Database 26ai can keep documents, vectors, graphs, spatial data, machine learning, SQL, security, and agent evidence close to one governed retail source of truth.
    - Every retail capability works best when copied into a disconnected system.
    - The workshop is only a set of unrelated feature demos.
    - Business teams should act before they can inspect the evidence.
    > The conclusion ties the labs together as one governed retail decision loop.
    ```

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
