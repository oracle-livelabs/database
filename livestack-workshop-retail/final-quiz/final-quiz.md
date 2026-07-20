# Final Quiz

## Introduction

Use this quiz to check your understanding of how the retail LiveStack uses Oracle Database 26ai to support a SQL-backed decision path.

Estimated Time: **5 minutes**

### Objectives

- Review the core database capabilities used in the workshop.
- Match visible retail outcomes to database-side patterns.
- Confirm that you can explain the converged database value.

```quiz-config
passing: 75
badge: images/livestack-retail-badge.png
```

## Task 1: Check your understanding

1. Answer the following questions.

    ```quiz score
    Q: Why does the workshop start with the Retail Data Foundation lab?
    - To skip business context and count objects only.
    * To anchor later results in known database evidence.
    - To move product data into a separate store.
    - To replace the application with catalog views and manual counts.
    > Lab 1 confirms the object families and data groups that support the rest of the decision path.

    Q: What makes the Retail Command Center more trustworthy?
    - It shows only screenshots of business metrics.
    - It calculates every card outside the governed database layer.
    - It removes detail rows from the workflow.
    * Its metrics can drill back to governed rows.
    > The command center is useful because you can trace summary metrics to orders, products, categories, and shipments.

    Q: What is the value of JSON Relational Duality in the order lab?
    * It gives applications JSON while preserving relational truth.
    - It stores order screenshots as documents.
    - It removes SQL access to order data.
    - It requires a separate document database for every order.
    > Duality views expose document-shaped JSON while the business data remains governed in relational tables.

    Q: Why does AI Vector Search help with customer trend signals?
    - It searches only exact product names.
    - It replaces product rows with images.
    * It compares meaning through embeddings.
    - It calculates fulfillment mileage.
    > Vector search can rank relevant products or signals even when the wording differs.

    Q: What does `GRAPH_TABLE` return in the creator influence lab?
    - A static graph image for the dashboard.
    * Table-shaped rows from graph paths.
    - A file export from another graph engine.
    - Hidden scores without SQL output.
    > `GRAPH_TABLE` lets you query graph paths and read the result as SQL rows.

    Q: How does Oracle Spatial support fulfillment decisions?
    - It stores only map screenshots.
    - It trains the demand model.
    - It hides customer and center locations from planners.
    * It joins distance, location, and stock evidence.
    > Spatial points and distance calculations can be joined to products, inventory, and customer evidence.

    Q: What should you remember about OML prediction probability?
    * It is model confidence, not certainty.
    - It guarantees the event will happen.
    - It can only be read outside SQL.
    - It replaces feature review entirely.
    > Probability helps rank rows, but business teams still need to inspect the feature evidence and operational context.

    Q: What is the overall technical outcome of the workshop?
    - More pipelines between disconnected specialist data systems and reports.
    - Less visibility into business evidence.
    * Connected data models with governed SQL evidence.
    - Static examples that cannot be validated.
    > The converged database foundation keeps different data models and workloads connected in Oracle Database 26ai.
    ```

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, July 2026
