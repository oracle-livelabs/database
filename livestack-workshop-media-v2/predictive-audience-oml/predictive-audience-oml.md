# Build a Media Demand Watchlist with Oracle Machine Learning

## Introduction

Otto Spencer is Seer Media's data scientist. His team supplies the predictions used in analytics charts and dashboards.

The content team wants a demand watchlist that ranks assets for review and shows their campaign orders and audience activity.

Otto trains and scores the model in Oracle AI Database, where the content, campaign, and social activity data reside. The model classifies content assets as `SURGE` or `STABLE`. SQL joins those predictions to content names, campaign revenue, and engagement values for the dashboard.

Build Otto's demand model and use its scores to rank a review list.

![Otto introduces a Media demand model and simulated content scoring](images/media-otto.png)

<details>
<summary><strong>Key terms: model, feature, classification, probability, and in-database machine learning</strong></summary>

> - A **model** is a set of learned rules that turns input data into a prediction.
>
> - A **feature** is an input value used by the model. In this lab, features include content category, campaign value proxy, audience signals, and campaign orders.
>
> - **Classification** predicts a label. Otto's model predicts either `SURGE` or `STABLE`.
>
> - A **probability** is the model's value for a class. In this lab, the value is displayed as a `SURGE_SCORE` to rank content assets for review. It is a model score, not a measured future outcome.
>
> - **In-database machine learning** means the model is trained or scored where the source data already lives. The SQL result can include the prediction and the data used to explain it.

</details>


### Objectives

- Read the prepared training data and identify the model target.
- Optionally use AutoML to compare classification models and inspect their predictions.
- Create a Random Forest model using the loader's algorithm and features inside Oracle AI Database.
- Score content assets with `PREDICTION` and `PREDICTION_PROBABILITY`.
- Combine model output with content-asset, campaign-order, and engagement data for a dashboard result.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step                | Media & Entertainment focus                                                                                                        |
| ---------------------| ----------------------------------------------------------------------------------------------------------------------|
| Business Problem    | A business user needs a short list of content assets that may require attention.                                           |
| Technical Challenge | Otto needs to train and score a model without copying content-asset activity to another machine learning system.           |
| Persona Focus       | You follow Otto as he builds the model and checks the result before it reaches a dashboard.                          |
| What You Will See   | Optionally compare models with AutoML, then use SQL Developer Web to create and score a Random Forest model.             |
| Database Capability | AutoML, `DBMS_DATA_MINING`, `PREDICTION`, and `PREDICTION_PROBABILITY` support machine learning inside the database. |
| Outcome             | A watchlist for a dashboard combines the model result with the content-asset and activity data behind it.                  |

> **SQL Worksheet reminder:** See [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for setup and query instructions.

## Task 1: Read the training data

Otto first checks `OML_DEMAND_TRAINING_V`. This prepared view combines content-asset, audience-signal, and campaign-order data into one row per active content asset.

`SURGE_LABEL` is the training target. The loader ranks a weighted activity score and labels the highest quartile `SURGE`; the remaining rows receive `STABLE`. These are synthetic labels derived from current features, so model performance here does not establish future forecasting accuracy. The physical `PRODUCT_ID`, `UNIT_PRICE`, `UNITS_SOLD`, and `REVENUE` columns represent a content asset, its campaign value proxy, requested units, and campaign-order revenue in this dataset.

1. Run the training-data query:

    ```sql
    <copy>
    SELECT product_id,
           category,
           unit_price,
           total_posts,
           avg_sentiment,
           viral_posts,
           rising_posts,
           units_sold,
           revenue,
           surge_label
    FROM oml_demand_training_v
    ORDER BY product_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

2. Identify the parts of each row.

    The numeric and category columns are the model inputs. `SURGE_LABEL` is the answer the model learns to predict. `PRODUCT_ID` identifies the content asset but is not a business feature for this example.

    ![Media training rows with content categories, activity features, and SURGE_LABEL](images/media-training.jpg)

    Check that each training row contains the category and activity values used by the model.

## Task 2: Compare models with AutoML (optional)

AutoML selects and tunes candidate algorithms. Use its leaderboard and model details to compare how they distinguish `SURGE` from `STABLE`.

This optional task can take several minutes. Continue to Task 3 to build and score a model directly in SQL Developer Web.

1. Open **Machine Learning** from Database Actions.

    Select **Machine Learning** in Database Actions. Sign in with the credentials from **View Login Info**.
    
    ![Database Actions Machine Learning launcher for LLUSER](images/media-open-oml.jpg)
    
2. Click **AutoML**.

    ![LLUSER Machine Learning home with the AutoML quick action](images/media-oml-home.jpg)

3. Create a new experiment with these settings:
  
    | Setting         | Value                   |
    | -----------------| -------------------------|
    | Experiment name | `Media Content Demand`  |
    | Data source     | `OML_DEMAND_TRAINING_V` |
    | Predict         | `SURGE_LABEL`           |
    | Prediction type | `Classification`        |
    | Case ID         | `PRODUCT_ID`            |
  
    Start the experiment and wait for the leaderboard. Runtime depends on service capacity.

    ![Media Content Demand AutoML experiment settings using OML_DEMAND_TRAINING_V](images/media-automl-settings.jpg)

    > **Environment note:** AutoML requires available service capacity. If the experiment cannot start, record the returned message and continue to Task 3. The loader does not include saved AutoML experiment results.

4. Review the leaderboard and model details when AutoML capacity is available.

    ![Media AutoML leaderboard for content demand classification](images/media-automl-leaderboard.jpg)
  
    Compare the balanced accuracy and confusion matrix for the models in your run. A model that assigns every content asset `STABLE` cannot distinguish the watchlist candidates. Look for both predicted classes and inspect the false positives and false negatives.

    ![Media demand classification confusion matrix](images/media-automl-confusion.jpg)

    Review prediction impact for the selected candidate. Features such as `VIRAL_POSTS`, `AVG_VIRALITY`, `CATEGORY`, and `TOTAL_POSTS` are available, but their ranking depends on the trained model. Feature impact describes model behavior; it does not establish a cause of demand.

    ![Media demand model feature impact](images/media-automl-impact.jpg)

    The captured experiment reported balanced accuracy of `1.0000` for all five candidates. The selected Random Forest candidate shows `AVG_VIRALITY` as its prediction impact and no off-diagonal errors in the displayed confusion matrix. The loader derives `SURGE_LABEL` from the highest quartile of a weighted activity score. Virality, post counts, views, and units sold contribute to that score and also serve as input features. The results demonstrate the synthetic rule; they do not establish future forecasting accuracy. Your run can produce different model identifiers or rankings.

    The required SQL task uses Random Forest, matching the loader's `DEMAND_SURGE_MODEL` configuration.

## Task 3: Create the media demand model in SQL Developer Web

The loader creates `DEMAND_SURGE_MODEL` from `OML_DEMAND_TRAINING_V`. This task trains a separate model, `OTTO_MEDIA_DEMAND_MODEL`, for the workshop scoring query.

The settings table uses the loader's **Random Forest** algorithm, 50 trees, and random seed. `PREP_AUTO` lets the database prepare the input columns. You can run this task even if you skipped AutoML.

1. Create the settings table and train the model:

    ```sql
    <copy>
    
    DROP TABLE IF EXISTS otto_media_demand_settings;
    
    CREATE TABLE otto_media_demand_settings (
          setting_name  VARCHAR2(30),
          setting_value VARCHAR2(4000)
        );

    INSERT INTO otto_media_demand_settings (setting_name, setting_value)
    VALUES ('ALGO_NAME', 'ALGO_RANDOM_FOREST');

    INSERT INTO otto_media_demand_settings (setting_name, setting_value)
    VALUES ('PREP_AUTO', 'ON');

    INSERT INTO otto_media_demand_settings (setting_name, setting_value)
    VALUES ('RFOR_NUM_TREES', '50');

    INSERT INTO otto_media_demand_settings (setting_name, setting_value)
    VALUES ('ODMS_RANDOM_SEED', '20260505');

    COMMIT;

    DECLARE
      l_model_count NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO l_model_count
      FROM user_mining_models
      WHERE model_name = 'OTTO_MEDIA_DEMAND_MODEL';

      IF l_model_count > 0 THEN
        DBMS_DATA_MINING.DROP_MODEL('OTTO_MEDIA_DEMAND_MODEL');
      END IF;
    END;
    /

    BEGIN
      DBMS_DATA_MINING.CREATE_MODEL(
        model_name           => 'OTTO_MEDIA_DEMAND_MODEL',
        mining_function      => DBMS_DATA_MINING.CLASSIFICATION,
        data_table_name      => 'OML_DEMAND_TRAINING_V',
        case_id_column_name  => 'PRODUCT_ID',
        target_column_name   => 'SURGE_LABEL',
        settings_table_name  => 'OTTO_MEDIA_DEMAND_SETTINGS'
      );
    END;
    /
    </copy>
    ```

    Training reads the features and `SURGE_LABEL` from the view, then stores the learned model in Oracle Database.

2. Confirm that Oracle created the model:

    ```sql
    <copy>
    SELECT model_name,
           mining_function,
           algorithm
    FROM user_mining_models
    WHERE model_name = 'OTTO_MEDIA_DEMAND_MODEL';
    </copy>
    ```

    The result should show `CLASSIFICATION` and `RANDOM_FOREST`. Otto now has a database model that SQL can call.

## Task 4: Score a simulated media activity snapshot in SQL

Create a scoring table by adjusting twelve feature rows from `OML_DEMAND_TRAINING_V`. These simulated scenarios are not independent holdout data or measured future activity.

1. Create the scoring table and add the simulated activity snapshot:

    ```sql
    <copy>
    
    DROP TABLE IF EXISTS otto_media_demand_scoring_data;

    CREATE TABLE otto_media_demand_scoring_data (
      product_id    NUMBER,
      category      VARCHAR2(100),
      unit_price    NUMBER,
      total_posts   NUMBER,
      avg_sentiment NUMBER,
      total_likes   NUMBER,
      total_shares  NUMBER,
      total_views   NUMBER,
      avg_virality  NUMBER,
      viral_posts   NUMBER,
      rising_posts  NUMBER,
      units_sold NUMBER,
      revenue       NUMBER
    );

    INSERT INTO otto_media_demand_scoring_data (
      product_id,
      category,
      unit_price,
      total_posts,
      avg_sentiment,
      total_likes,
      total_shares,
      total_views,
      avg_virality,
      viral_posts,
      rising_posts,
      units_sold,
      revenue
    )
    SELECT product_id,
           category,
           unit_price,
           total_posts + 4,
           avg_sentiment,
           total_likes + 25,
           total_shares + 10,
           total_views + 500,
           LEAST(avg_virality + 5, 100),
           viral_posts + 1,
           rising_posts + 1,
           units_sold + 3,
           revenue + (unit_price * 3)
    FROM (
      SELECT product_id,
             category,
             unit_price,
             total_posts,
             avg_sentiment,
             total_likes,
             total_shares,
             total_views,
             avg_virality,
             viral_posts,
             rising_posts,
             units_sold,
             revenue,
             ROW_NUMBER() OVER (ORDER BY product_id) AS row_num
      FROM oml_demand_training_v
    )
    WHERE row_num <= 12;

    COMMIT;
    </copy>
    ```

    This creates a small simulated snapshot from the workshop data.
    > **Note:** The table has the model inputs, but it does not contain `SURGE_LABEL`. That label is the training target and is excluded from the scoring inputs.

2. Run the scoring query:

    ```sql
    <copy>
    WITH scored_content_assets AS (
      SELECT product_id,
             category,
             units_sold,
             revenue,
             total_posts,
             viral_posts,
             rising_posts,
             PREDICTION(
               OTTO_MEDIA_DEMAND_MODEL USING
               category, unit_price, total_posts, avg_sentiment,
               total_likes, total_shares, total_views, avg_virality,
               viral_posts, rising_posts, units_sold, revenue
             ) AS predicted_surge,
             ROUND(
               PREDICTION_PROBABILITY(
                 OTTO_MEDIA_DEMAND_MODEL,
                 'SURGE' USING
                 category, unit_price, total_posts, avg_sentiment,
                 total_likes, total_shares, total_views, avg_virality,
                 viral_posts, rising_posts, units_sold, revenue
               ), 8
             ) AS surge_score
      FROM otto_media_demand_scoring_data
    )
    SELECT p.product_id AS content_asset_id,
           p.product_name AS content_asset,
           sp.category,
           sp.predicted_surge,
           sp.surge_score,
           ROUND(sp.surge_score * 100, 2) AS surge_pct,
           sp.units_sold,
           sp.revenue,
           sp.total_posts,
           sp.viral_posts,
           sp.rising_posts
    FROM scored_content_assets sp
    JOIN products p
      ON p.product_id = sp.product_id
    ORDER BY sp.surge_score DESC,
             p.product_id;
    </copy>
    ```

3. Read the result as a dashboard user.

    `PREDICTED_SURGE` is the selected label. `SURGE_SCORE` is the model score for `SURGE`, between 0 and 1; `SURGE_PCT` expresses it as a percentage. Review the campaign-order and activity values alongside that score. One SQL query returns the prediction and its business context.

    ![Content assets ranked by SURGE probability from the OTTO media demand model](images/media-demand-scoring.jpg)

## Conclusion: Put the Prediction Beside the Business Data

You built a Random Forest using the loader's configuration and scored a simulated activity snapshot. The optional AutoML task compared candidate models. Read exact probabilities from your model run and review them alongside each asset's activity.

The dashboard query combines model scores with content details under the database's access controls. Users can inspect the supporting values and rerun the watchlist as the input data changes.

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano, Linda Foinding
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
