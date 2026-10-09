# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

Use this scored quiz to check how Seer Scientific answers clinical supply questions with the database capabilities and query results covered in the labs.

### Objectives

- Review the main database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **5 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What makes Jessica's dashboard query a converged query?
    - It copies each data type into a separate reporting database.
    * It combines relational records, JSON order data, vector comparisons, and spatial calculations in one SQL statement.
    - It converts every record into JSON before analysis.
    - It replaces the source records with dashboard screenshots.
    > Oracle AI Database lets Jessica combine different data models in one query while keeping the result connected to the underlying records.

    Q: Thomas updates an order's status through the JSON Relational Duality View. Why can Jessica immediately see that status in a relational query?
    - A scheduled process copies the JSON document into the order table.
    - The document collection automatically synchronizes every source table.
    * The duality view maps the permitted document update to the underlying relational order row.
    - Jessica's query reads a separate JSON-only order database.
    > The duality document and relational queries operate on the same underlying practice records. The view's write annotations and relational constraints control supported changes; a stored JSON collection is a different pattern.

    Q: Gilly’s semantic search returns a product whose catalog text does not contain “sterility.” How should the team interpret that result?
    * Its text may describe a related concept, making it a candidate for review—not proof that it is affected.
    - The search has established that the product has a sterility defect.
    - The product must have matched the exact keyword somewhere in its order records.
    - Its similarity score is the probability that a clinical-supply order is affected.
    > Embeddings support comparison by meaning rather than exact wording. The team must inspect the product text and related records before drawing a business conclusion.

    Q: What qualifies an alternative depot for Bob's candidate list?
    - It has an inventory connection to any product in the order.
    - It is the geographically closest depot.
    - Its total stock across all products exceeds the order's total units.
    * It is active, differs from the assigned depot, and has enough recorded unreserved stock for every required product.
    > The order's product branches must converge on the same qualifying depot. Quantities are checked per product; surplus stock of one product cannot compensate for a shortage of another. The query identifies candidates without reserving inventory.

    Q: Moon's query identifies the closest active depot for a trial site. What does that establish?
    - The depot can deliver within the required time window.
    * It has the shortest calculated geographic distance among the active depots considered.
    - It has suitable temperature-controlled stock for the site's order.
    - Its distance to every site in the same region is identical.
    > Spatial SQL measures relationships between stored locations. Proximity alone does not establish road travel time, available inventory, or cold-chain suitability.

    Q: Otto's watchlist shows a high probability of SURGE. Which interpretation is appropriate for this workshop?
    - The model has independently verified future demand.
    - The product has been approved for release.
    * The model strongly favors the demonstration's SURGE class, but that is not proof of future demand.
    - The score is an observed future outcome used to validate the model.
    > The training labels are rule-generated, and the scoring exercise reuses existing product inputs. It demonstrates training, scoring, and interpretation—not independent forecast validation.

    Q: Before using Nina's generated product-ranking answer, what should she check?
    * The SQL's joins, filters, and aggregation, then whether the returned facts and explanation answer her question.
    - Only whether the SQL executes without an error.
    - Whether the narrative uses exactly the same wording as the screenshot.
    - Whether the AI profile makes further result review unnecessary.
    > Valid SQL can still answer the wrong question—for example, by repeating order-header totals across line items. Generated SQL and database results make the answer reviewable; they do not guarantee correctness.

    Q: Why does Nina inspect the team and tool history after receiving an agent answer?
    - A successful history entry proves every statement in the answer is correct.
    - Registering a SQL tool makes the entire workshop account read-only.
    - The instruction “use the tool once” guarantees exactly one invocation.
    * The history records execution and tool activity, which she can review alongside the returned facts.
    > History helps explain how the agent handled the request. Nina must still check the answer against query results; model instructions are not enforced call limits, and tool restrictions do not remove the account's other privileges.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Bring the evidence together

Seer Scientific’s teams use the same data for different tasks. Jessica combines records in a dashboard query; Thomas presents orders as JSON; Gilly finds products by meaning; Bob finds shared stocking depots; Moon measures trial-site proximity; Otto builds a demand watchlist; and Nina uses Select AI and an agent to answer questions.

Oracle AI Database supports these different access patterns without requiring a separate operational data store for every capability. The business value is a clearer path from a question to records and calculations the team can inspect. Those results support human review; they do not by themselves approve product release, guarantee cold-chain service, or validate a demand forecast.

## Acknowledgements

* **Author** - Joshua Pasaribu
* **Contributor** - Nechita C. Teodor
* **Last Updated By/Date** - Nechita C. Teodor, October 2026