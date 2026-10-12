# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

Use this scored quiz to check whether you can connect Seer Sporting Goods' retail decisions to the database evidence explored in Labs 1–8. Each question covers one part of the team's journey, from Jessica's connected query to Nina's inspectable assistant.

### Objectives

- Connect each database capability to the retail question it helps answer.
- Distinguish observed evidence from claims a query or model cannot establish.
- Earn the workshop badge by answering at least six of the eight questions correctly.

Estimated Time: **5 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does Jessica's converged dashboard query bring into one retail review result?
    - Product names and a guarantee that the nearest center can fulfill each order.
    * Product signals, semantic relevance, active-order information, and regional location context.
    - Copied dashboard images that replace the underlying order and product records.
    - Future sales predictions derived only from the number of social-post views.
    > The query combines relational product signals, vector comparisons, JSON order items, and spatial distance. Its center is regional context; the query does not check that center's inventory or guarantee fulfillment.

    Q: How does Thomas's duality view differ from the order document copied into a JSON collection?
    - The duality view removes relational keys so the application can write any shape.
    - The collection automatically follows every change to the original order tables.
    - The duality view stores a second order that Jessica must reconcile later.
    * The duality view reads and permits writes to the existing relational order rows.
    > ORDERS_DV presents the order and its items as JSON over ORDERS and ORDER_ITEMS. Enabled document writes change those same rows. The collection exercise stores an independent document copy with its own lifecycle.

    Q: What does a higher similarity score tell Gilly about a product search result?
    * The embedded text is closer in meaning to the search phrase.
    - The product will generate more sales than every lower-ranked match.
    - Every customer who ordered the product needs an immediate follow-up.
    - The product is available at the customer's nearest fulfillment center.
    > The lab displays one minus cosine distance as a similarity score. It ranks the meaning of the text; ordinary relational joins add actual order and customer context. Similarity is not a sales forecast or proof of customer intent.

    Q: What can Bob establish by following a path in the creator influence graph?
    - The exact number of purchases caused by a creator's latest post.
    - That two creators who promote a brand have identical audiences.
    * Recorded creator and brand relationships at the explored path depth.
    - That an indirect relationship is stronger than every direct connection.
    > Graph paths expose relationships recorded in the retail tables. Bob can explore direct connections, several hops, and shared brands. Those relationships support investigation but do not prove causal influence or attributable sales.

    Q: How should Moon use the result that combines distance with positive stock on hand?
    - Assign the order immediately because the query guarantees a delivery time.
    * Review those stocked locations alongside the remaining fulfillment conditions.
    - Treat on-hand quantity as stock available after all reservations are subtracted.
    - Assume every returned center is active and has enough operating capacity.
    > The stock query combines geographic distance with positive quantity on hand. It does not subtract reservations, require active status, or assess workload. Those conditions and the delivery promise still matter before allocating an order.

    Q: How should Otto interpret a high model probability for SURGE?
    * As a model score to review beside the product's business evidence.
    - As proof that future demand will increase by the displayed percentage.
    - As held-out accuracy measured by scoring the demonstration rows.
    - As evidence that the model has no class imbalance or training limitations.
    > PREDICTION_PROBABILITY reports the model's score for a class. The lab's derived labels and perturbed examples demonstrate building and scoring a model; they do not establish held-out accuracy or future-demand forecasting quality.

    Q: What makes Nina's Select AI result reviewable?
    - A convincing narrative that removes the need to inspect the database result.
    - An object list that automatically replaces the user's database privileges.
    - Repeating RUNSQL to guarantee execution of the exact SQL shown earlier.
    * Inspecting the generated SQL and comparing its results with database evidence.
    > SHOWSQL returns SQL text to review. Running that reviewed SQL lets Nina compare its facts with the deterministic query and the narrative. RUNSQL can generate SQL again. The profile's object scope and the caller's database privileges both matter.

    Q: What evidence shows that Nina's agent actually used its approved SQL tool?
    - The agent instructions ask it to call the tool exactly once.
    - The answer sounds plausible and includes familiar product names.
    * A completed team run and tool history matched to that exact execution.
    - A successful Select AI query from a different workshop task.
    > Match the captured conversation and team execution to its completed status and actual tool activity, then inspect the returned facts and invocation count. Instructions describe the intended behavior; execution history shows what happened. Select AI success alone does not prove that the agent ran its tool.
    ```

2. Review the explanations. A score of **75% or higher**, meaning **at least six of eight** correct answers, unlocks the Retail Workshop completion badge.

Jessica and the team have followed one connected investigation: product signals, order documents, semantic matches, creator relationships, fulfillment options, model scores, natural-language questions, and an assistant whose work can be inspected. Use the evidence behind each result when deciding what the retail operation should do next.

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, October 2026
