# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

Use this scored quiz to check whether you can connect State and Local Government service decisions to the database evidence you inspected in the labs.

### Objectives

- Review the main database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does JSON Relational Duality help a public-service application do?
    - Copy service-request rows into a separate document database.
    * Use the same service-request data as JSON documents or relational rows without maintaining duplicate records.
    - Remove relational tables from the application design.
    - Force developers to assemble every JSON payload manually.
    > A duality view presents relational rows as a JSON document. Applications get the payload they need, while developers and DBAs retain SQL, keys, transactions, and database controls against the same source.

    Q: In the vector lab, what does the similarity score help a public-service team do?
    - Prove that a service request requires intervention.
    - Replace service descriptions and requests with embeddings only.
    * Rank public services by how closely they match a plain-language concern.
    - Count how many service-request rows exist.
    > The query turns vector distance into a similarity score, where a higher score means the stored public-service text is closer in meaning to the search phrase.

    Q: What business problem does the property graph lab solve for public-service operations?
    - It predicts future demand for every service without review.
    * It makes partner handoffs and multi-hop coordination paths easier to inspect.
    - It stores service-center locations as a replacement for spatial data.
    - It replaces partner relationships with flat service totals.
    > The graph lab focuses on relationship evidence. A public-service team can trace direct and two-hop partner handoffs without relying on fragile chains of manual joins.

    Q: Why does the State and Local Government team use spatial data?
    - To make routing decisions outside the governed database.
    - To replace service-center capacity with a static region label.
    * To find the closest service center for a residential customer or demand region and compare that location with service capacity.
    - To avoid using customer and service-center data together.
    > Spatial functions calculate distance and location relationships. SQL combines those results with residential-customer, service-center, capacity, and demand data to support routing decisions.

    Q: In the Oracle Machine Learning lab, what does model confidence mean?
    - It guarantees that the prediction will happen.
    * It is the model probability for a prediction and should still be reviewed.
    - It is the number of rows in the model catalog.
    - It means the model no longer needs operational context.
    > Confidence helps compare stronger and weaker demand predictions, but it is not certainty. The lab also uses an agreement check to compare predicted labels with the known labels in the training data.

    Q: What makes a Select AI answer governed and reviewable?
    - The model can query every object in the database automatically.
    - The narrative wording is guaranteed to be identical every time.
    * The profile restricts approved objects and the generated SQL remains visible.
    - The answer bypasses the database and uses only general model knowledge.
    > The Select AI profile has a narrow object list. SHOWSQL exposes the generated query, and direct SQL lets reviewers compare the response with the database result.

    Q: What makes the public-service AI agent in Lab 8 controlled?
    - It can query every object in the database automatically.
    * It has one approved read-only SQL tool, one task, one team, and a history record for review.
    - It writes service decisions directly into operational tables.
    - It hides the generated SQL from the DBA.
    > The agent's tool, task, and team define a narrow execution path. The tool history lets Nina and Jessica review what ran, while the read-only boundary prevents database changes.

    Q: What is the main advantage of using Oracle AI Database as the converged foundation for this workshop?
    - Each public-service capability must use a separate specialized data store.
    * One Oracle AI Database connects relational, JSON, vector, graph, spatial, machine-learning, and AI capabilities to the same governed data.
    - Application screenshots replace the need for database evidence.
    - Public-service teams must reconcile copied data before every review.
    > Each lab uses a different capability, but the work stays connected to the same data and database controls. This reduces duplicate copies and separate integration paths.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Acknowledgements

* **Author** - Pat Shepherd
* **Last Updated By/Date** - Pat Shepherd, September 2026
