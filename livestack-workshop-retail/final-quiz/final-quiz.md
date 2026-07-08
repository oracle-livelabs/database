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
badge: images/livestack-retail-badge.png
```

## Task 1: Check Your Understanding

1. Answer the following questions.

    ```quiz score
    Q: What is the main business value shown by the Retail Command Center?
    - It proves a dashboard can be built from static sample text.
    * It combines many retail signals through one governed database foundation.
    - It requires every data type to be moved into a separate tool first.
    - It hides the source data so business users do not question it.
    > The command center is about converged data: orders, returns, social signals, inventory, and agent activity can support one operating view.

    Q: Why does the workshop start by checking the retail data foundation?
    - To make learners manually rebuild all application tables.
    - To replace the LiveStack Demo with a schema catalog exercise.
    * To prove later results start from known database evidence.
    - To show that dashboards do not need database objects.
    > Lab 1 is a trust check. It confirms the shared objects behind the later labs are present before the learner relies on their results.

    Q: Which outcome best describes JSON Relational Duality in the order lab?
    - It turns order data into screenshots for application users.
    - It removes the need for SQL, joins, and transactions.
    - It copies order documents into a separate document store.
    * It gives applications JSON while keeping relational truth.
    > The business value is API-friendly order access without losing relational storage, transactions, and SQL visibility.

    Q: Why is enabling writes on `ORDERS_DV` important in the workshop?
    * It shows document-style writes can still update relational rows.
    - It prevents applications from changing order information.
    - It moves order line items out of Oracle Database.
    - It converts relational orders into unmanaged JSON files.
    > The lab shows that document inserts and updates can be mapped back to the governed `ORDERS` and `ORDER_ITEMS` tables.

    Q: What is the key advantage of AI Vector Search in the customer signal lab?
    - It only finds products when the exact name appears.
    - It replaces all catalog tables with an external search index.
    * It matches shopper language to products by meaning.
    - It ranks fulfillment centers by shipping distance.
    > Vector search helps the business find product fit from natural language, even when the words differ from catalog terms.

    Q: Why does in-database embedding matter for retail data?
    - It makes the model name more visible in the application.
    - It requires customer and product text to leave the database.
    - It prevents SQL from comparing product vectors.
    * It keeps sensitive text and vectors close to governed data.
    > A key differentiator is that embeddings and similarity search can run near the data instead of pushing retail text to another service.

    Q: What business problem does the property graph lab address?
    - It replaces creator relationships with flat row counts.
    * It helps explain how influence can move through connected creators.
    - It prevents marketing teams from seeing relationship paths.
    - It stores social posts outside the retail data model.
    > The graph lab is about connected influence paths, not just individual creators or isolated posts.

    Q: How does Oracle Spatial support fulfillment decisions?
    - It stores only map images for the application.
    - It trains a model to predict social demand.
    * It handles locations, service zones, and distance queries.
    - It replaces inventory checks with customer addresses.
    > Spatial data supports maps, spatial queries, service coverage, and location-aware fulfillment logic.

    Q: What makes the OML lab useful to a merchandising planner?
    - It exports all model inputs before scoring can happen.
    * It connects surge predictions to inventory risk.
    - It focuses only on model names, not business action.
    - It requires the planner to write Python training code.
    > The OML workflow becomes useful when predictions are joined to operational inventory evidence.

    Q: What should a learner look for before trusting an Ask Retail Data answer?
    - Whether the generated SQL is hidden from view.
    * Whether the answer maps to approved views and visible filters.
    - Whether the question avoids governed database objects.
    - Whether the result ignores repeatable SQL validation.
    > Trusted answers need traceability: approved paths, readable columns, visible filters, and SQL that can be checked.

    Q: What separates a trusted agent action from a free-form AI response?
    - The agent avoids the database and answers from memory.
    - The agent can call any tool it invents at runtime.
    - The agent removes all records after completing work.
    * The agent uses approved tools and leaves audit evidence.
    > Lab 9 is about trusted actions: controlled database tools, grounded responses, and durable action history.

    Q: What is the overall outcome of the workshop for technical teams?
    - More pipelines between disconnected specialty systems.
    - Less visibility into where decisions came from.
    * Fewer integration points with more governed evidence.
    - Static demos that cannot be inspected with SQL.
    > The technical outcome is reduced integration work while keeping evidence, models, tools, and audit history governed in Oracle AI Database.
    ```

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
