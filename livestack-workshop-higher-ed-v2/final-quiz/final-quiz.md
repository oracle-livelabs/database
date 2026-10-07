# Final Quiz

```quiz-config
passing: 75
badge: images/higher-ed-badge.svg
```

## Introduction

Use this scored quiz to review the Oracle AI Database capabilities used in the Seer Higher Education workshop.

### Objectives

- Connect each database capability to the operations question it supports.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does JSON Relational Duality help Seer Higher Education do in the request lab?
    - Copy every student-support document into a separate document database.
    * Present relational request data as JSON while keeping the same underlying records and database controls.
    - Remove the relational request tables from the application workflow.
    - Require staff to manually read raw JSON for every request.
    > A duality view exposes relational rows as a JSON document. The application can use a document interface while the database retains its relational records and controls.

    Q: What does a similarity score help Gilly do in the vector lab?
    - Determine whether a student qualifies for a service.
    - Replace support-resource records with vectors only.
    * Rank support resources by how closely their meaning matches a plain-language question.
    - Count the number of rows in each table.
    > Vector similarity helps find candidate resources by meaning. Staff review the result before taking action.

    Q: What does the student-support property graph represent?
    - A model of individual academic performance.
    * Relationships between students, course sections, advisors, and services that can help staff explore operational connections.
    - A set of campus service-area polygons.
    - A replacement for the relational student and request records.
    > The graph makes selected relationships easier to traverse. A shared course or service connection is not a judgment about a student.

    Q: Why does Moon use Oracle Spatial?
    - To move campus coordinates to an unrelated mapping system before every query.
    - To make decisions about student eligibility.
    * To compare support-center points with service areas and request locations, then combine distance with center capacity.
    - To replace service-center records with map labels.
    > Spatial functions calculate distance and location relationships. SQL adds center capacity and workload to the result.

    Q: What does the OML probability mean in the support-demand lab?
    - It guarantees a future service surge.
    * It is the model's probability for SURGE and should be reviewed with the synthetic workload inputs.
    - It is the number of models in the database catalog.
    - It replaces operations planning.
    > The lab returns the probability assigned to SURGE. The synthetic data demonstrates scoring; it does not establish forecast accuracy, and the model does not score individual students.

    Q: What makes Select AI questions reviewable?
    - The model can query every database object automatically.
    - The generated narrative is guaranteed to be identical on every run.
    * The profile lists approved views and the generated SQL can be inspected before it is run.
    - The answer bypasses database privileges.
    > The object list narrows the metadata available to Select AI, and the generated SQL stays visible for review. Database privileges still apply.

    Q: What is the main value of Oracle AI Database as the workshop foundation?
    - Each data capability requires a separate copy of the support records.
    * Relational, JSON, vector, graph, spatial, machine-learning, and AI capabilities can work with connected data in one governed database.
    - Screenshots replace the need to inspect database results.
    - Teams must reconcile independently copied records before every decision.
    > The labs use different capabilities while keeping the records, SQL, and access controls connected in one database.
    ```

2. When you achieve the passing score, the quiz displays your workshop badge.

## Acknowledgements

* **Author** - Linda Foinding
* **Contributor** - Teodor Constantin Nechita
* **Last Updated By/Date** - Teodor Constantin Nechita, October 2026
