# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

Use this scored quiz to review one key idea from each of the eight hands-on labs.

### Objectives

- Review the healthcare scenarios and database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **4 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: In Lab 1, what does the converged dashboard query combine?
    * Relational, vector, JSON, and spatial data in one result.
    - Four separate reports that learners reconcile by hand.
    - Only vector embeddings and generated text.
    - Only patient and service tables.
    > The query brings four data models together in one governed healthcare operations result.

    Q: In Lab 2, what does JSON Relational Duality provide?
    - A second copy of every care service request.
    * A JSON document and relational access to the same data.
    - A replacement for database tables and keys.
    - A file that must be synchronized manually.
    > A duality view lets an application use JSON while SQL users work with the same relational data.

    Q: In Lab 3, what does a higher vector similarity score mean?
    - The result contains more rows.
    - The search phrase is an exact text match.
    * The stored healthcare text is closer in meaning to the search phrase.
    - The result is a confirmed clinical finding.
    > Vector similarity ranks results by meaning. It supports review but does not prove a clinical conclusion.

    Q: In Lab 4, what does the property graph help Bob explore?
    - The size of each database table.
    - A list of unrelated service requests.
    - A forecast with no connected care facts.
    * Relationships across a patient journey and its quality signals.
    > The graph makes connected care events and quality-signal paths easier to follow.

    Q: In Lab 5, what must the routing query consider in addition to distance?
    - The alphabetical order of site names.
    * Required service, active status, workload, and capacity.
    - Only the state where the site is located.
    - The number of columns in the site table.
    > The closest site is useful only when it can provide the service and has suitable operating capacity.

    Q: In Lab 6, how should the demand-risk prediction be used?
    - As a guaranteed future outcome.
    - As an automatic capacity decision.
    * As planning evidence that a reviewer evaluates with business context.
    - As a replacement for the healthcare data.
    > A prediction and its confidence help prioritize review. They do not guarantee what will happen.

    Q: In Lab 7, what should Nina inspect before relying on a Select AI answer?
    * The generated SQL and its database results.
    - Only the wording of the natural-language response.
    - An unrelated table outside the approved profile.
    - A separate spreadsheet copy of the data.
    > SHOWSQL exposes the generated query so Nina can compare the answer with the database evidence.

    Q: In Lab 8, what helps keep the healthcare agent controlled?
    - Giving it permission to change every table.
    - Hiding its execution history.
    - Allowing it to call any external service.
    * An approved read-only SQL tool, focused data access, database privileges, and execution history.
    > The agent uses a bounded tool and governed database access, while its actions remain available for review.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Acknowledgements

* **Author** - Linda Foinding, Principal Product Manager, Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
