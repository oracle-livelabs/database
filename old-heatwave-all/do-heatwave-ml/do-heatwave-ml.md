# Build HeatWave ML with SQL

## Introduction

To load the Aiport Delay data components, perform the following steps to create and load the required schema and tables. The requirements for Python 3 are already loaded in the compute instance and you have already installed MySQL Shell in the previous Lab.

After this step the data is stored in the MySQL HeatWave database in the following schema and tables:

**FLIGHTS\_BTS\_DELAY schema:** The schema containing training and test dataset tables.

**bts\_airport\_delay\_train table:** The training dataset (labeled). Includes feature columns (OPER\_CARRIER, MONTH, ORIGIN\_AIRPORT,  SCHEDULED\_DEPT\_TIME, AVG\_MINUTES\_LATE) and a populated class target column with ground truth values.

**bts\_airport\_delay\_test table:** The test dataset (unlabeled). Includes feature columns ( MONTH, ORIGIN\_AIRPORT,  SCHEDULED\_DEPT\_TIME, AVG_MINUTES\_LATE) but no target column.

**bts\_airport\_delay\_validate table:** The validation dataset (labeled). Includes feature columns (OPER\_CARRIER, MONTH, ORIGIN\_AIRPORT,  SCHEDULED\_DEPT\_TIME, AVG\_MINUTES\_LATE) and a populated class target column with ground truth values.

_Estimated Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following task:

- Load airport Data into HeatWave
- Train ML model

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 2

## Task 1: Connect MySQL Shell:

1. If not already connected with SSH, connect to Compute instance using Cloud Shell

    (Example: **ssh -i ~/.ssh/id_rsa opc@132.145.17....**)

2. On the command line, connect to MySQL using the MySQL Shell client tool with the following command:

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.... -P3306 --sql </copy>
    ```

    ![Connect](./images/heatwave-load-shell.png "heatwave-load-shell ")

## Task 2: Create ML Data

1. To Create the Machine Learning schema and tables on the MySQL HeatWave DB System perform the following steps :

    a. Create the ML database :

    ```bash
    <copy>CREATE SCHEMA FLIGHTS_BTS_DELAY;</copy>
    ```

    b. Set new database as default :

    ```bash
    <copy>use FLIGHTS_BTS_DELAY;</copy>
    ```

    c. Create train table :

    ```bash
    <copy>CREATE TABLE `bts_airport_delay_train` (
  `OPER_CARRIER` varchar(255) DEFAULT NULL,
  `MONTH` varchar(255) DEFAULT NULL,
  `ORIGIN_AIRPORT` varchar(255) DEFAULT NULL,
  `SCHEDULED_DEPT_TIME` int DEFAULT NULL,
  `AVG_MINUTES_LATE` float DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
</copy>
    ```
    d. Load data into train table : 
    [BTS raw data origin] (https://www.bts.gov/topics/airlines-and-airports/june-2022-regularly-scheduled-flights-more-50-delayed-arrivals-more-30)

    ```bash
    <copy>INSERT INTO  FLIGHTS_BTS_DELAY.bts_airport_delay_train 
SELECT OPER_CARRIER, bts_raw_data.MONTH,
ORIGIN_AIRPORT,  SCHEDULED_DEPT_TIME, AVG_MINUTES_LATE
from  airportdb.bts_raw_data where id >= 1001;</copy>
    ```
    e. Create test table :

    ```bash
    <copy>CREATE TABLE `bts_airport_delay_test` (
  `OPER_CARRIER` varchar(255) DEFAULT NULL,
  `MONTH` varchar(255) DEFAULT NULL,
  `ORIGIN_AIRPORT` varchar(255) DEFAULT NULL,
  `SCHEDULED_DEPT_TIME` int DEFAULT NULL,
  `AVG_MINUTES_LATE` float DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;</copy>
    ```
    f. Load data into test table  :

    ```bash
    <copy>INSERT INTO  FLIGHTS_BTS_DELAY.bts_airport_delay_test
SELECT OPER_CARRIER, bts_raw_data.MONTH, 
ORIGIN_AIRPORT,  SCHEDULED_DEPT_TIME, AVG_MINUTES_LATE
from  airportdb.bts_raw_data where id < 1001;</copy>
    ```
   g. Create validate  table :

    ```bash
    <copy>CREATE TABLE `bts_airport_delay_validate` (
  `OPER_CARRIER` varchar(255) DEFAULT NULL,
  `MONTH` varchar(255) DEFAULT NULL,
  `ORIGIN_AIRPORT` varchar(255) DEFAULT NULL,
  `SCHEDULED_DEPT_TIME` int DEFAULT NULL,
  `AVG_MINUTES_LATE` float DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;</copy>
    ```
    h. Load validate table :

    ```bash
    <copy>INSERT INTO  FLIGHTS_BTS_DELAY.bts_airport_delay_validate
SELECT OPER_CARRIER, bts_raw_data.MONTH, 
ORIGIN_AIRPORT,  SCHEDULED_DEPT_TIME, AVG_MINUTES_LATE
from  airportdb.bts_raw_data where id < 1001;</copy>
    ```
    i. Remove labeled column from test table:

    ```bash
    <copy>ALTER TABLE FLIGHTS_BTS_DELAY.bts_airport_delay_test DROP COLUMN OPER_CARRIER;</copy>
    ```
    j. Drop target variables with less than 5 values :

    ```bash
    <copy>select OPER_CARRIER, count(OPER_CARRIER ) from bts_airport_delay_train group by OPER_CARRIER;</copy>
    ```

    ```bash
    <copy>delete  from bts_airport_delay_train  where OPER_CARRIER in ("ENDEAVOR", "HAWAIIAN", "PIEDMONT");</copy>
    ```
    k. Review delete action :

    ```bash
    <copy>select OPER_CARRIER, count(OPER_CARRIER ) from bts_airport_delay_train group by OPER_CARRIER;</copy>
    ```

2. View the content of  your machine Learning schema (ml_data)

    a.

    ```bash
    <copy>use FLIGHTS_BTS_DELAY;</copy>
    ```

    b.

    ```bash
    <copy>show tables; </copy>
    ```

## Task 3: Train the machine learning model

1. Train the model using ML_TRAIN. Since this is a classification dataset, the classification task is specified to create a classification model:

    ```bash
    <copy>CALL sys.ML_TRAIN('FLIGHTS_BTS_DELAY.bts_airport_delay_train','OPER_CARRIER',JSON_OBJECT('task','classification'),@airport_model);</copy>
    ```

2. When the training operation finishes, the model handle is assigned to the @airport_model session variable, and the model is stored in your model catalog. You can view the entry in your model catalog using the following query, where user1 is your MySQL account name:

    ```bash
    <copy>SELECT model_id, model_handle, train_table_name FROM ML_SCHEMA_admin.MODEL_CATALOG;</copy>
    ```

3. Load the model into HeatWave ML using ML\_MODEL\_LOAD routine:

    a.  Reset model handle variable

    ```bash
    <copy>SET @airline_model = (SELECT model_handle FROM ML_SCHEMA_admin.MODEL_CATALOG   ORDER BY model_id DESC LIMIT 1);</copy>
    ```

    b. A model must be loaded before you can use it. The model remains loaded until you unload it or the HeatWave Cluster is restarted.

    ```bash
    <copy>CALL sys.ML_MODEL_LOAD(@airline_model, NULL);</copy>
    ```

    ```bash
    <copy>select @airline_model;</copy>
    ```

## Task 4: Predict and Explain for Single Row

1. Make a prediction for a single row of data using the ML\_PREDICT\_ROW routine.
In this example, data is assigned to a @row\_input session variable, and the variable is called by the routine. The model handle is called using the @airport\_model session variable:

    ```bash
    <copy>SET @airline_input = JSON_OBJECT('MONTH', 'Oct', 'ORIGIN_AIRPORT', 'MIA', 'SCHEDULED_DEPT_TIME', 1800, 'AVG_MINUTES_LATE', 0);  </copy>
    ```

    ```bash
    <copy>SELECT sys.ML_PREDICT_ROW(@airline_input, @airline_model);</copy>
    ```

2. Generate an explanation for the same row of data using the ML\_EXPLAIN\_ROW routine to understand how the prediction was made:

    ```bash
    <copy>SELECT sys.ML_EXPLAIN_ROW(@airline_input, @airline_model);</copy>
    ```


## Task 5: Score your machine learning model to assess its reliability and unload the model

1. Score the model using ML\_SCORE to assess the model's reliability. This example uses the accuracy metric, which is one of the many scoring metrics supported by HeatWave ML.

    ```bash
    <copy>CALL sys.ML_SCORE('FLIGHTS_BTS_DELAY.bts_airport_delay_train', 'OPER_CARRIER', @airline_model, 'accuracy', @score);</copy>
    ```

2. To retrieve the computed score, query the @score session variable

    ```bash
    <copy>SELECT @score;</copy>
    ```

3. Unload the model using ML\_MODEL\_UNLOAD:

    ```bash
    <copy>CALL sys.ML_MODEL_UNLOAD(@airport_model);</copy>
    ```

    To avoid consuming too much space, it is good practice to unload a model when you are finished using it.


## Learn More

* [Oracle Cloud Infrastructure MySQL Database Service Documentation ](https://docs.cloud.oracle.com/en-us/iaas/MySQL-database)
* [MySQL HeatWave ML Documentation] (https://dev.mysql.com/doc/heatwave/en/heatwave-machine-learning.html)

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Salil Pradhan, Principal Product Manager,
Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2022
