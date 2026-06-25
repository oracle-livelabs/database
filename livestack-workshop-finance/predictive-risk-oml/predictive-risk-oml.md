# Predictive Risk, Capacity, and Revenue with Oracle Machine Learning (OML)

## Introduction

Predictions become useful when they can be explained and used in the same place as the finance data. This lab scores persisted **Oracle Machine Learning** models directly in SQL, so the prediction is not separated from the evidence that produced it.

Prediction helps teams look ahead instead of only describing what already happened. The database can help answer questions such as "Which products may surge?", "Which customers behave similarly?", and "What revenue outcome should we expect?"

You use the same governed finance records to support planning decisions. The records used for dashboard, service, and transaction review also become model features that can be scored in place.

<details>
<summary><strong>Key terms: OML model, feature, classification, regression, clustering, and confidence</strong></summary>

> - A **model** is a trained pattern that can score new or current data. In this lab, OML models help estimate outcomes such as demand surge, revenue impact, or product grouping from the finance records already in Oracle Database.
>
> - A **feature** is an input value used by a model. Features can come from product activity, risk severity, transaction attributes, customer behavior, case-processing capacity, or revenue history. Good features translate raw finance records into signals the model can learn from.
>
> - **Classification** predicts a category or label, such as `SURGE` or `STABLE`. This is useful when the business decision is a choice between states, such as whether a product is likely to need more case-processing capacity for reviews, outreach, or support work.
>
> - **Regression** predicts a number, such as expected revenue, forecasted load, or estimated impact. This is useful when planners need a measurable value rather than a yes/no label.
>
> - **Clustering** groups similar records together without requiring a preassigned label. In finance, clustering can help compare similar products, identify cohorts, or find groups that behave alike for risk, revenue, or service planning.
>
> - **Confidence** is the model's estimated strength for a prediction. It helps you compare stronger and weaker predictions, but it is not the same thing as a guaranteed outcome. Treat confidence as decision support: useful for prioritization, but still something to review with business context.

</details>

The first image below explains the Oracle Machine Learning (OML) scoring flow. Product, transaction, risk, client, revenue, and case-processing capacity data become model features; Oracle Machine Learning scores the models inside the database; and the results return to SQL as labels, clusters, forecasts, probabilities, and operational risk signals.

![Finance Oracle Machine Learning scoring flow](images/finance-oml-scoring-flow.svg " ")

The second image is the Predictive Risk, Capacity and Revenue page. It gives finance teams a business-facing view of product risk, client segments, revenue forecast quality, product cohorts, and case-processing pressure. In this financial-services context, capacity means the ability of teams or service centers to absorb review, support, onboarding, dispute, fraud, or AML work. The SQL in this lab shows how those predictive results can be inventoried and scored inside Oracle Database instead of being disconnected in a separate notebook or external model service.

![Predictive Risk Capacity and Revenue page](images/predictive-risk-oml.png " ")

### Objectives

- Inventory the four OML models.
- Score classification, clustering, and regression models.

Estimated Time: **12 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Finance teams need prediction without exporting sensitive operating data. |
| Technical Challenge | Data science and application teams need deployed models that can be scored from SQL without copying governed finance records elsewhere. |
| Persona Focus | Risk and revenue leaders use predictions; database developers and ML engineers show how models score inside the database. |
| What You Will See | Persisted OML models can be inventoried and scored directly in SQL. |
| Database Capability | The Oracle Data Mining package (`DBMS_DATA_MINING`), PREDICTION, PREDICTION\_PROBABILITY, CLUSTER\_ID, and CLUSTER\_PROBABILITY support in-database ML. |
| Outcome | Risk, segmentation, revenue, and product grouping outputs are explainable from SQL. |

Persona focus: You bridge the ML engineer and finance decision-maker by showing how deployed models produce reviewable scores where the data already lives.

## Task 1: Inventory persisted OML models

Begin by reviewing the persisted OML models available for scoring.

1. Run this model inventory query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](/workshops/sandbox/index.html?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are confirming which predictive models are available before using them in finance decisions. The SQL reads the Oracle Machine Learning model catalog, returning each model name, mining function, and algorithm so you can distinguish classification, clustering, and regression models before scoring data.

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

    Expected models are CUSTOMER\_SEGMENT\_MODEL, DEMAND\_SURGE\_MODEL, PRODUCT\_CLUSTER\_MODEL, and REVENUE\_PREDICT\_MODEL. The list shows that the database contains deployed models for several finance decisions, not just one isolated prediction.

    This inventory is important because a prediction is only useful when teams know which model produced it. The model list is the starting point for explainable prediction: what model exists, what type of prediction it performs, and whether it can be scored from SQL.

## Task 2: Score demand risk and revenue in SQL

Perform the following set of steps to score demand risk and revenue directly in SQL:

1. Run the demand surge classification query:

    You are scoring product demand pressure and showing the product names behind the model output. The SQL uses `PREDICTION` to classify each row from `OML_DEMAND_TRAINING_V` and `PREDICTION_PROBABILITY` to return confidence.

    `OML_DEMAND_TRAINING_V` is a view that packages the demand-surge model inputs into a repeatable feature set. In this lesson, its value is that the model sees the same governed columns every time it scores: product activity, risk context, and the training label used for comparison. You do not have to reconstruct the feature logic before focusing on what the prediction means.

    It then joins the scored rows to `PRODUCTS` so the results are meaningful to a business reviewer.

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

    The inline query scores the same model inputs as the training view, then joins to `PRODUCTS` to show the business-readable financial product name. The `ORDER BY product_id` clause makes the displayed sample rows stable. The `Confidence` values are OML model scores, not stored source data.


2. Run revenue regression.

    You are estimating revenue outcomes from the persisted regression model. The SQL scores rows from `OML_REVENUE_TRAINING_V` with `REVENUE_PREDICT_MODEL`, rounds the predicted value for review, and returns it next to the known target revenue so you can compare model output with actual business values.

    `OML_REVENUE_TRAINING_V` is the revenue-model feature view. It gives the regression model a consistent set of revenue-related inputs and keeps the scoring example tied to governed database data. That consistency is important because revenue prediction is easier to explain when the model input shape is defined in the database instead of hidden in a separate notebook or script.

    ```sql
    <copy>
    SELECT order_id,
           target_revenue,
           ROUND(PREDICTION(REVENUE_PREDICT_MODEL USING *), 2) AS predicted_revenue
    FROM oml_revenue_training_v
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: Revenue Prediction Results**

    | Order Id | Target Revenue | Predicted Revenue |
    | --- | --- | --- |
    | 534 | 10035 | 8122.69 |
    | 578 | 5280 | 7385.46 |
    | 579 | 1050 | 802.92 |
    | 6 | 5830 | 5460.79 |
    | 14 | 5400 | 6105.85 |
    | 27 | 2900 | 3772.87 |
    | 50 | 2815 | 4198.3 |
    | 124 | 10390 | 8707.78 |
    | 158 | 2900 | 4522.79 |
    | 173 | 5390 | 7872.1 |


3. Compare actual target revenue to predicted revenue.
    The demand query classifies product pressure from stored finance features, and the revenue query estimates a transaction outcome from customer, order, and fulfillment attributes.

    The demand query returns predicted surge labels with confidence, which helps product and operations teams decide where to watch case-processing or risk pressure. The revenue query compares known target revenue to predicted revenue, which helps reviewers understand whether the model is directionally useful for planning.

    Both queries score persisted models without leaving Oracle Database. That keeps sensitive finance records close to the models and gives technical teams SQL evidence for each prediction.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
