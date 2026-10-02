# Build a Service Demand Watchlist with Oracle Machine Learning

## Introduction

Otto Spencer is Seer Transport's data scientist. His team supplies the predictions used in analytics charts and dashboards.

![Otto Spencer, data scientist: Lab 6: Build a Service Demand Watchlist](images/otto-transport.png " ")

The transport service team wants a demand watchlist. A business user should be able to see which transport services may need more attention, why the model flagged them, and which transport services are already showing strong fare activity or passenger activity.

Otto has the transport service, fare activity, and social activity data in Oracle AI Database. He could copy the data to a separate machine learning platform, train a model there, and copy the scores back. That would create another copy of transportation data and another process for keeping scores current.

Instead, Otto builds and scores the model in the database. The model uses transport service activity to classify transport services as `SURGE` or `STABLE`. SQL then joins the prediction to the transport service name, fare activity, and engagement values that a dashboard needs.

In this lab, you build Otto's demand-surge model and turn its output into a review list for a business user.


<details>
<summary><strong>Key terms: model, feature, classification, probability, and in-database machine learning</strong></summary>

> - A **model** is a set of learned rules that turns input data into a prediction.
>
> - A **feature** is an input value used by the model. In this lab, features include transport service category, price, social activity, and fare activity.
>
> - **Classification** predicts a label. Otto's model predicts either `SURGE` or `STABLE`.
>
> - A **probability** is the model's value for a class. In this lab, the value is displayed as a `SURGE_SCORE` to rank transport services for review. It is not a guarantee.
>
> - **In-database machine learning** means the model is trained or scored where the source data already lives. The SQL result can include the prediction and the data used to explain it.

</details>

### Objectives

- Read the prepared training data and identify the model target.
- Optionally use AutoML to compare classification models and inspect their predictions.
- Create the selected Generalized Linear Model inside Oracle AI Database.
- Score transport services with `PREDICTION` and `PREDICTION_PROBABILITY`.
- Combine model output with transport service, fare activity, and engagement data for a dashboard result.

Estimated Time: **10 minutes**
### Hands-on Scenario

| Step                | Transportation focus                                                                                                        |
| ---------------------| ----------------------------------------------------------------------------------------------------------------------|
| Business Problem    | A business user needs a short list of transport services that may require attention.                                           |
| Technical Challenge | Otto needs to train and score a model without copying transport service activity to another machine learning system.           |
| Persona Focus       | You follow Otto as he builds the model and checks the result before it reaches a dashboard.                          |
| What You Will See   | Optionally compare models with AutoML, then use SQL Developer Web to create and score the selected model.             |
| Database Capability | AutoML, `DBMS_DATA_MINING`, `PREDICTION`, and `PREDICTION_PROBABILITY` support machine learning inside the database. |
| Outcome             | A watchlist for a dashboard combines the model result with the transport service and activity data behind it.                  |

> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

## Task 1: Read the training data

Before Otto creates a model, he checks the data that will teach it. The workshop already provides `OML_SERVICE_DEMAND_TRAINING_V`, a view that combines transport service, social activity, and fare activity data into one row per active transport service.

The view also contains `SURGE_LABEL`. This is the known label used during training. The demo data assigns each transport service `SURGE` or `STABLE` from its activity values so the SQL pattern can be tested without waiting for new business outcomes.

1. Run the training-data query:

    ```sql
    <copy>
    SELECT service_id,
           category,
           fare,
           total_mentions,
           avg_sentiment,
           high_interest_mentions,
           rising_mentions,
           seats_booked,
           fare_revenue,
           surge_label
    FROM oml_service_demand_training_v
    ORDER BY service_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

2. Identify the parts of each row.

    The numeric and category columns are the model inputs. `SURGE_LABEL` is the answer the model learns to predict. `SERVICE_ID` identifies the transport service but is not a business feature for this example.

    Otto is checking that the training data already brings together the values he needs. He does not have to export social activity, fare activity, and transport service data into separate files before training.

## Task 2: Compare models with AutoML (optional)

Otto first uses the Oracle Machine Learning AutoML interface to compare candidate models. AutoML can select algorithms, tune them, and show how well each model identifies the two labels.

This shows how a data scientist chooses a model: the leaderboard is a starting point, but Otto also checks whether the model identifies the business outcome he cares about.

This task is optional. AutoML can take several minutes to complete, so you can continue with Task 3 if you want to focus on creating and using the model in SQL Developer Web.

1. Open **Machine Learning** from Database Actions.

    Open **Database Actions**, select **Machine Learning**. Use the username and password you can find on the **View Login Info screen**.
    
    
2. Click **AutoML**.

3. Create a new experiment with these settings:
  
    | Setting         | Value                   |
    | -----------------| -------------------------|
    | Experiment name | `Service Demand Surge`  |
    | Data source     | `OML_SERVICE_DEMAND_TRAINING_V` |
    | Predict         | `SURGE_LABEL`           |
    | Prediction type | `Classification`        |
    | Case ID         | `SERVICE_ID`            |
  
    Start the experiment and wait for the model leaderboard (this can take between 5-10 minutes).

4. Review the leaderboard and model details.

  
  The leaderboard may show several models with a higher balanced-accuracy value than the Generalized Linear Model. Otto does not choose from that number alone. Open the different model details and inspect the confusion matrix.

  Check the confusion matrix for both `SURGE` and `STABLE`. A model that predicts only one class cannot help Otto prioritize a demand watchlist. Review prediction impact to see which inputs influenced the result; impact does not prove that one input causes demand.

  Select the Generalized Linear Model for the SQL exercise in Task 3. Compare its behavior with the AutoML candidates before using any model for an operational decision.

## Task 3: Create the selected model in SQL Developer Web

AutoML helped Otto compare models. He now moves to SQL Developer Web to create a named model that a SQL query can call repeatedly. The model is stored in Oracle AI Database under the name `OTTO_SERVICE_DEMAND_MODEL`.

The settings table tells Oracle to use the **Generalized Linear Model** that Otto selected in AutoML. `PREP_AUTO` lets the database handle standard preparation of the input columns.

If you skipped the optional AutoML task, use this setting as the model selected for the workshop.

1. Create the settings table and train the model:

    ```sql
    <copy>
    
    DROP TABLE IF EXISTS otto_service_demand_settings;
    
    CREATE TABLE otto_service_demand_settings (
          setting_name  VARCHAR2(30),
          setting_value VARCHAR2(4000)
        );

    INSERT INTO otto_service_demand_settings (setting_name, setting_value)
    VALUES ('ALGO_NAME', 'ALGO_GENERALIZED_LINEAR_MODEL');

    INSERT INTO otto_service_demand_settings (setting_name, setting_value)
    VALUES ('PREP_AUTO', 'ON');

    INSERT INTO otto_service_demand_settings (setting_name, setting_value)
    VALUES ('ODMS_RANDOM_SEED', '20260604');

    COMMIT;

    DECLARE
      l_model_count NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO l_model_count
      FROM user_mining_models
      WHERE model_name = 'OTTO_SERVICE_DEMAND_MODEL';

      IF l_model_count > 0 THEN
        DBMS_DATA_MINING.DROP_MODEL('OTTO_SERVICE_DEMAND_MODEL');
      END IF;
    END;
    /

    BEGIN
      DBMS_DATA_MINING.CREATE_MODEL(
        model_name           => 'OTTO_SERVICE_DEMAND_MODEL',
        mining_function      => DBMS_DATA_MINING.CLASSIFICATION,
        data_table_name      => 'OML_SERVICE_DEMAND_TRAINING_V',
        case_id_column_name  => 'SERVICE_ID',
        target_column_name   => 'SURGE_LABEL',
        settings_table_name  => 'OTTO_SERVICE_DEMAND_SETTINGS'
      );
    END;
    /
    </copy>
    ```

    The model reads the training view, learns the relationship between the features and `SURGE_LABEL`, and stores the trained model in the database. No transport service or social data leaves Oracle Database during training.

2. Confirm that Oracle created the model:

    ```sql
    <copy>
    SELECT model_name,
           mining_function,
           algorithm
    FROM user_mining_models
    WHERE model_name = 'OTTO_SERVICE_DEMAND_MODEL';
    </copy>
    ```

    The result should show `CLASSIFICATION` and `GENERALIZED_LINEAR_MODEL`. Otto now has a database model that SQL can call.

## Task 4: Score new transport service activity in SQL

Otto now receives a new activity snapshot for the next reporting period. He stores it in a separate scoring table. The model was trained with historical rows from `OML_SERVICE_DEMAND_TRAINING_V`; it will now score rows it did not see during training.

1. Create the scoring table and add the new activity snapshot:

    ```sql
    <copy>
    
    DROP TABLE IF EXISTS otto_service_demand_scoring_data;

    CREATE TABLE otto_service_demand_scoring_data (
      service_id    NUMBER,
      category      VARCHAR2(100),
      fare    NUMBER,
      total_mentions   NUMBER,
      avg_sentiment NUMBER,
      total_reactions   NUMBER,
      total_reshares  NUMBER,
      total_views   NUMBER,
      avg_interest  NUMBER,
      high_interest_mentions   NUMBER,
      rising_mentions  NUMBER,
      seats_booked    NUMBER,
      fare_revenue       NUMBER
    );

    INSERT INTO otto_service_demand_scoring_data (
      service_id,
      category,
      fare,
      total_mentions,
      avg_sentiment,
      total_reactions,
      total_reshares,
      total_views,
      avg_interest,
      high_interest_mentions,
      rising_mentions,
      seats_booked,
      fare_revenue
    )
    SELECT service_id,
           category,
           fare,
           total_mentions + 4,
           avg_sentiment,
           total_reactions + 25,
           total_reshares + 10,
           total_views + 500,
           avg_interest + 0.05,
           high_interest_mentions + 1,
           rising_mentions + 1,
           seats_booked + 3,
           fare_revenue + (fare * 3)
    FROM (
      SELECT service_id,
             category,
             fare,
             total_mentions,
             avg_sentiment,
             total_reactions,
             total_reshares,
             total_views,
             avg_interest,
             high_interest_mentions,
             rising_mentions,
             seats_booked,
             fare_revenue,
             ROW_NUMBER() OVER (ORDER BY service_id) AS row_num
      FROM oml_service_demand_training_v
    )
    WHERE row_num <= 12;

    COMMIT;
    </copy>
    ```

    This creates a small next-period snapshot from the workshop data. 
    >Note: The table has the model inputs, but it does not contain `SURGE_LABEL`. That label belongs to the historical training data and must not be passed to the model as an input.

2. Run the scoring query:

    ```sql
    <copy>
    WITH scored_services AS (
      SELECT service_id,
             category,
             seats_booked,
             fare_revenue,
             total_mentions,
             high_interest_mentions,
             rising_mentions,
             PREDICTION(
               OTTO_SERVICE_DEMAND_MODEL USING
               category, fare, total_mentions, avg_sentiment,
               total_reactions, total_reshares, total_views, avg_interest,
               high_interest_mentions, rising_mentions, seats_booked, fare_revenue
             ) AS predicted_surge,
             ROUND(
               PREDICTION_PROBABILITY(
                 OTTO_SERVICE_DEMAND_MODEL,
                 'SURGE' USING
                 category, fare, total_mentions, avg_sentiment,
                 total_reactions, total_reshares, total_views, avg_interest,
                 high_interest_mentions, rising_mentions, seats_booked, fare_revenue
               ), 8
             ) AS surge_score
      FROM otto_service_demand_scoring_data
    )
    SELECT p.service_id,
           p.service_name,
           sp.category,
           sp.predicted_surge,
           sp.surge_score,
           ROUND(sp.surge_score * 100, 2) AS surge_pct,
           sp.seats_booked,
           sp.fare_revenue,
           sp.total_mentions,
           sp.high_interest_mentions,
           sp.rising_mentions
    FROM scored_services sp
    JOIN transport_services p
      ON p.service_id = sp.service_id
    ORDER BY sp.surge_score DESC,
             p.service_id;
    </copy>
    ```

3. Read the result as a dashboard user.

  `PREDICTED_SURGE` tells the dashboard which label the model selected. `SURGE_SCORE` is the model value between 0 and 1, while `SURGE_PCT` presents the same value as a percentage for a dashboard user. The fare activity and activity columns give the business user something to review alongside the prediction.

  This is the value of in-database machine learning. Otto can return a prediction, the transport service name, fare activity, and social activity in one SQL result. There is no need to move data to an external machine learning platform.

## Conclusion: Put the Prediction Beside the Business Data

Otto used AutoML to compare models, selected the Generalized Linear Model because it identifies both classes, recreated it in SQL Developer Web, and scored a new activity snapshot. The query returns a watchlist that a dashboard can show alongside the transport service activity behind each score.

This is the business benefit of OML in the database. The model, the training data, the prediction, and the transport service details stay together. Otto does not have to copy sensitive transportation data to a separate machine learning platform, and the dashboard does not have to combine scores from one system with business data from another.

Oracle AI Database makes the model part of the dashboard query. A business user can read the watchlist, inspect the supporting values, and repeat the query using the same access controls that protect the source data.

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, October 2026
