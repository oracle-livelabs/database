# Predictive Risk, Capacity, and Revenue with Oracle Machine Learning (OML)

## Introduction

Finance teams use dashboards to understand what has already happened, but they also need predictions that help them plan what to do next. Those predictions are more useful when analysts can see which model produced the score, which business record was scored, and how the result connects back to product, revenue, or risk decisions.

In this lab, you will take on the persona of a database developer supporting both an ML engineer and a finance decision-maker. The ML engineer needs to show that deployed **Oracle Machine Learning (OML)** models can be scored consistently inside Oracle Database. The finance decision-maker needs results that are easy to review, explain, and use for planning.

You will inventory persisted OML models, score demand-surge and revenue-prediction models in SQL, and review the results next to finance data that business users recognize. By the end of the lab, you will see how in-database machine learning keeps the model, the score, and the supporting finance evidence together.

<details>
<summary><strong>Key terms: OML model, feature, classification, regression, clustering, and confidence</strong></summary>

> - A **model** is a trained pattern that can score new or current data. In this lab, OML models estimate demand surge, revenue impact, or product grouping from finance records in Oracle Database.
>
> - A **feature** is an input value used by a model. Features can come from product activity, risk severity, transaction attributes, customer behavior, case-processing capacity, or revenue history. Good features translate raw finance records into signals the model can learn from.
>
> - **Classification** predicts a category or label, such as `SURGE` or `STABLE`. This helps teams choose between states, such as whether a product may need more review capacity.
>
> - **Regression** predicts a number, such as expected revenue, forecasted load, or estimated impact. This is useful when planners need a measurable value rather than a yes/no label.
>
> - **Clustering** groups similar records together without requiring a preassigned label. In finance, clustering can compare products, identify cohorts, or find groups that behave alike.
>
> - **Confidence** is the estimated strength of a prediction. It helps you compare stronger and weaker predictions. It is not a guaranteed outcome. Treat confidence as decision support that still needs business review.

</details>

The first image below explains the Oracle Machine Learning (OML) scoring flow. Product, transaction, risk, client, revenue, and capacity data become model features. Oracle Machine Learning scores the models inside the database. The results return to SQL as labels, clusters, forecasts, probabilities, and operational risk signals.

![Finance Oracle Machine Learning scoring flow](images/finance-oml-scoring-flow.svg " ")

The second image is the Predictive Risk, Capacity and Revenue page. It gives finance teams a business view of product risk, client segments, forecast quality, product cohorts, and case pressure. In this lab, capacity means the ability of teams or service centers to handle review, support, onboarding, dispute, fraud, or AML work. The SQL shows how Oracle Database inventories and scores these predictive results.

![Predictive Risk Capacity and Revenue page](images/predictive-risk-oml.png " ")

### Objectives

- Inventory the four OML models.
- Score classification and regression models.
- Review a simple model quality check.

Estimated Time: **12 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Finance teams need prediction without exporting sensitive operating data. |
| Technical Challenge | Data science and application teams need deployed models that can be scored from SQL without copying governed finance records elsewhere. |
| Persona Focus | You connect deployed ML models to the finance decision-maker review process. |
| What You Will See | Persisted OML models can be inventoried and scored directly in SQL. |
| Database Capability | The Oracle Machine Learning model catalog, `PREDICTION`, and `PREDICTION_PROBABILITY` support in-database ML scoring. |
| Outcome | Risk, segmentation, revenue, and product grouping outputs are explainable from SQL. |

## Task 1: Inventory persisted OML models

Begin by reviewing the persisted OML models available for scoring.

1. Run this model inventory query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are confirming which predictive models are available before using them in finance decisions.

    In order to understand this query, you need to read it in three parts.

    1. `USER_MINING_MODELS` is the database catalog view for OML models owned by your schema.
    2. `MODEL_NAME` tells you which deployed model is available to score.
    3. `MINING_FUNCTION` and `ALGORITHM` tell you what kind of prediction the model makes and how it was trained.

    <details>
    <summary><strong>Why this matters: in-database machine learning</strong></summary>

    > In a fractured environment, data teams often export sensitive finance records to a separate machine learning platform, score the data there, and then send results back to the application or dashboard. That creates copies, governance questions, and extra movement of sensitive data.
    >
    > Oracle Machine Learning lets you score models inside Oracle Database. The model, data, SQL evidence, and business context stay close together, which is better for explainability and governance.

    </details>

    ```sql
    <copy>
    SELECT model_name,
           mining_function,
           algorithm
    FROM user_mining_models
    WHERE model_name IN (
      'CUSTOMER_SEGMENT_MODEL',
      'DEMAND_SURGE_MODEL',
      'PRODUCT_CLUSTER_MODEL',
      'REVENUE_PREDICT_MODEL'
    )
    ORDER BY model_name;
    </copy>
    ```

    Expected output: OML Model Inventory

    | Model Name | Mining Function | Algorithm |
    | --- | --- | --- |
    | CUSTOMER\_SEGMENT\_MODEL | CLUSTERING | KMEANS |
    | DEMAND\_SURGE\_MODEL | CLASSIFICATION | RANDOM\_FOREST |
    | PRODUCT\_CLUSTER\_MODEL | CLUSTERING | KMEANS |
    | REVENUE\_PREDICT\_MODEL | REGRESSION | GENERALIZED\_LINEAR\_MODEL |


2. Confirm the model list.
    The query reads the model catalog so you can see which predictive functions are available for finance decisions.

    Expected models are CUSTOMER\_SEGMENT\_MODEL, DEMAND\_SURGE\_MODEL, PRODUCT\_CLUSTER\_MODEL, and REVENUE\_PREDICT\_MODEL. The list shows that the database contains deployed models for several finance decisions, not just one isolated prediction. In this lab, you score the demand and revenue models.

    This matters because a prediction is easier to trust when teams know which model produced it. The inventory gives the learner a simple checkpoint before scoring: what model exists, what it predicts, and whether it can be called from SQL.

## Task 2: Score demand risk and revenue in SQL

Now score demand risk and revenue directly in SQL so learners can see how deployed OML models support finance decisions without moving governed data out of the database.

1. Run the demand surge classification query:

    You are scoring product demand pressure and showing the product names behind the model output.

    In order to understand this query, you need to read it in four parts.

    1. `OML_DEMAND_TRAINING_V` gives the model a repeatable set of product and risk inputs.
    2. `PREDICTION(DEMAND_SURGE_MODEL USING *)` asks the deployed model to classify each row as `SURGE` or `STABLE`.
    3. `PREDICTION_PROBABILITY(DEMAND_SURGE_MODEL USING *)` returns confidence for that prediction. The `ROUND` function makes the score easier to read.
    4. The outer query joins to `PRODUCTS` so the learner sees a product name, not just a product id.

    ```sql
    <copy>
    SELECT s.product_id,
           p.product_name,
           s.training_label,
           s.predicted_surge,
           s.confidence
    FROM (
      SELECT product_id,
             surge_label AS training_label,
             PREDICTION(DEMAND_SURGE_MODEL USING *) AS predicted_surge,
             ROUND(PREDICTION_PROBABILITY(DEMAND_SURGE_MODEL USING *), 4) AS confidence
      FROM oml_demand_training_v
    ) s
    JOIN products p ON p.product_id = s.product_id
    ORDER BY s.product_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: Surge Prediction Results**

    | Product Id | Product Name | Training Label | Predicted Surge | Confidence |
    | --- | --- | --- | --- | --- |
    | 1 | Premium Checking Bundle | STABLE | STABLE | 0.9674 |
    | 2 | High-Yield Savings Account | SURGE | STABLE | 0.6139 |
    | 3 | Rewards Credit Card | SURGE | STABLE | 0.6128 |
    | 4 | Small Business Term Loan | SURGE | SURGE | 0.5831 |
    | 5 | Home Equity Line of Credit | STABLE | STABLE | 0.8716 |
    | 6 | Robo Advisory Portfolio | STABLE | STABLE | 0.9361 |
    | 7 | Managed ETF Portfolio | STABLE | STABLE | 0.6684 |
    | 8 | Municipal Bond Ladder | STABLE | STABLE | 0.9435 |
    | 9 | Treasury Sweep Account | STABLE | STABLE | 0.6597 |
    | 10 | Corporate Card Program | STABLE | STABLE | 0.5252 |

    Review the predicted surge and confidence together. A `SURGE` prediction can help an analyst decide which products may need more monitoring, outreach, or case-processing capacity. Confidence helps the analyst decide how strongly the model supports that prediction. It does not replace review; it helps rank where to look first.


2. Check how often the demand model matches the known label.

    A model score is the result returned when a trained model evaluates a row of data. For a classification model, the score is the predicted label, such as `SURGE` or `STABLE`. The confidence value is the model probability for that prediction. It is not certainty, and it is not a guarantee that the outcome will happen.

    Before analysts use a model score, they need a quick check that the model is behaving reasonably on the workshop data. This query compares two values for each product: the known label in the training view and the label predicted by the model.

    ```sql
    <copy>
    SELECT actual_label,
           predicted_label,
           COUNT(*) AS product_count
    FROM (
      SELECT surge_label AS actual_label,
             PREDICTION(DEMAND_SURGE_MODEL USING *) AS predicted_label
      FROM oml_demand_training_v
    )
    GROUP BY actual_label,
             predicted_label
    ORDER BY actual_label,
             predicted_label;
    </copy>
    ```

    **Expected output: Demand Model Agreement Check**

    | Actual Label | Predicted Label | Product Count |
    | --- | --- | --- |
    | STABLE | STABLE | 59 |
    | SURGE | STABLE | 4 |
    | SURGE | SURGE | 16 |

    In order to understand this query, you need to read it in three parts.

    1. `SURGE_LABEL` comes from `OML_DEMAND_TRAINING_V`. It marks each product as `SURGE` or `STABLE` in the demo data, so the query renames it `ACTUAL_LABEL`.
    2. `PREDICTION(DEMAND_SURGE_MODEL USING *)` asks the model to predict a label for the same row. In this query, it is renamed `PREDICTED_LABEL`.
    3. The outer query groups the results so you can count how often each actual and predicted combination appears.

    Rows where `ACTUAL_LABEL` and `PREDICTED_LABEL` are the same are matches. Rows where they are different show where the model prediction differs from the label stored in `OML_DEMAND_TRAINING_V`. This is a simple learning check, not a full production model evaluation.

    The workshop uses synthetic demo data to teach the SQL pattern. Do not interpret these scores as a production financial risk model.

3. Run revenue regression.

    You are estimating revenue outcomes from the persisted regression model.

    In order to understand this query, you need to read it in three parts.

    1. `OML_REVENUE_TRAINING_V` gives the model a consistent set of revenue-related inputs.
    2. `PREDICTION(REVENUE_PREDICT_MODEL USING *)` returns a numeric revenue estimate for each row.
    3. The query shows `TARGET_REVENUE` next to `PREDICTED_REVENUE` so the learner can compare the known business value with the model estimate.

    ```sql
    <copy>
    SELECT order_id,
           target_revenue,
           ROUND(PREDICTION(REVENUE_PREDICT_MODEL USING *), 2) AS predicted_revenue
    FROM oml_revenue_training_v
    ORDER BY order_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: Revenue Prediction Results**

    | Order Id | Target Revenue | Predicted Revenue |
    | --- | --- | --- |
    | 1 | 2400 | 2225.21 |
    | 2 | 11685 | 7647.67 |
    | 3 | 8470 | 8394.92 |
    | 4 | 7540 | 6976.93 |
    | 5 | 4965 | 4240.34 |
    | 6 | 5830 | 5459.59 |
    | 8 | 2360 | 1901.23 |
    | 9 | 6300 | 7593.86 |
    | 10 | 1787.5 | 2654.61 |
    | 11 | 5450 | 7138.97 |


4. Compare actual target revenue to predicted revenue.
    Look for rows where predicted revenue is close to target revenue, then look for rows where the difference is larger. Close values show where the model estimate lines up with known outcomes. Larger gaps show where an analyst may want more context, such as unusual customer behavior, product mix, or fulfillment timing.

    The demand query helps teams decide which products may need attention. The revenue query helps teams see whether a model estimate is useful for planning. Both queries score persisted models without moving sensitive finance records out of Oracle Database.

## Next Steps

Congratulations on completing the Oracle Machine Learning lab. You inspected models, generated model scores, checked how often a prediction matched the demo label, and compared predicted revenue to target revenue. For a deeper hands-on workshop focused on Oracle Machine Learning, open the [Oracle Machine Learning LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=922).

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
