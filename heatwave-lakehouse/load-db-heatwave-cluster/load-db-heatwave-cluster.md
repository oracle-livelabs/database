# Load data into HeatWave Cluster

## Introduction

A HeatWave cluster comprise of a MySQL DB System and one or more HeatWave nodes. The MySQL DB System  includes a plugin that is responsible for cluster management, loading data into the HeatWave cluster, query scheduling, and returning query result.

In this lab, you will load data and run queries in the HeatWave Cluster. You will see the query performance improvements on HeatWave compare to MySQL.

![Setup Lab](./images/heatwave-lab-setup.png "heatwave lab setup ")

_Estimated Time:_ 15 minutes

### Objectives

In this lab, you will be guided through the following task:

- Load mysql\_customer\_orders Data into the HeatWave Cluster
- Run Comparison Queries  with the HeatWave Cluster loaded data

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 4

## Task 1: Load Schema Data into HeatWave Cluster

1. Login to the OCI Console.
2. Click the Cloud Shell icon in the Console
3. If not already connected with SSH, on Command Line, connect to the Compute instance using SSH ... be sure replace the  "private key file"  and the "new compute instance ip"

     ```bash
    <copy>ssh -i private_key_file opc@new_compute_instance_ip</copy>
     ```

4. Connect to MySQL using the MySQL Shell client tool with the following command:

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1... --sql </copy>
    ```

    ![MySQL shell Connect](./images/mysql-shell-login.png " mysql shell login")

5. Run the following Auto Parallel Load command to load the  mysql\_customer\_orders tables data into the HeatWave Cluster

    ```bash
    <copy>CALL sys.heatwave_load(JSON_ARRAY('mysql_customer_orders'), NULL);</copy>
    ```

6. The completed load cluster screen should look like this:

    ![Cluster load start](./images/load-cluster-begin.png "load cluster begin")

    ![Cluster load end](./images/load-cluster-end.png "load cluster end")

- Auto Parallel Load command Result highlights:

    - a. Load analysis box: shows the number of tables/columns being loaded

    - b. Capacity estimation box: showis estimated memory and load time

    - c. Loading table boxes: use different thread to load based on the table

    - d. Load summary box: shows the actual load time

7. Verify that the tables are loaded in the HeatWave cluster. Loaded tables have an AVAIL_RPDGSTABSTATE load status.

    ```bash
    <copy>USE performance_schema;</copy>
    ```

    ```bash
    <copy>SELECT NAME, LOAD_STATUS FROM rpd_tables,rpd_table_id WHERE rpd_tables.ID = rpd_table_id.ID;</copy>
    ```

    ![Cluster is loaded](./images/heatwave-loaded-data.png "heatwave loaded data")

## Task 2: Run Queries in HeatWave

1. If not already connected then connect to MySQL using the MySQL Shell client tool with the following command:

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1... --sql </copy>
    ```

    ![MySQl Shell Connect](./images/mysql-shell-login.png " mysql shell login")

2. Change to the mysql\_customer\_orders database

    Enter the following command at the prompt

    ```bash
    <copy>USE mysql_customer_orders;</copy>
    ```

3. **Query 1** - List Customer total purchase for the year by month

4. Before running a query, use EXPLAIN to verify that the query can be offloaded to the HeatWave cluster. You should see "Use secondary engine RAPID" in the explain plan. For example:

    ```bash
    <copy>EXPLAIN  
    SELECT
    SUBSTRING_INDEX(c.EMAIL_ADDRESS, '@', -1) AS email_domain,
    SUM(oi.QUANTITY * oi.UNIT_PRICE) AS total_revenue,
    AVG(
        LENGTH(p.PRODUCT_NAME) / (
            LENGTH(p.PRODUCT_NAME) - LENGTH(REPLACE(p.PRODUCT_NAME, ' ', '')) + 1
        )
    ) AS avg_word_length_in_product_name
    FROM
        customers c
    JOIN
        orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
    JOIN
        order_items oi ON o.ORDER_ID = oi.ORDER_ID
    JOIN
        products p ON oi.PRODUCT_ID = p.PRODUCT_ID
    WHERE
        o.ORDER_STATUS = 'COMPLETE'
    GROUP BY
        email_domain
    ORDER BY
        total_revenue DESC;
    </copy>
    ```

    ![RUN](./images/mysql-customer-order-explain.png "mysql customer order explain")

5. After verifying that the query can be offloaded, run the query and note the execution time. Enter the following command at the prompt:

     ```bash
    <copy> SELECT
    SUBSTRING_INDEX(c.EMAIL_ADDRESS, '@', -1) AS email_domain,
    SUM(oi.QUANTITY * oi.UNIT_PRICE) AS total_revenue,
    AVG(
        LENGTH(p.PRODUCT_NAME) / (
            LENGTH(p.PRODUCT_NAME) - LENGTH(REPLACE(p.PRODUCT_NAME, ' ', '')) + 1
        )
    ) AS avg_word_length_in_product_name
    FROM
        customers c
    JOIN
        orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
    JOIN
        order_items oi ON o.ORDER_ID = oi.ORDER_ID
    JOIN
        products p ON oi.PRODUCT_ID = p.PRODUCT_ID
    WHERE
        o.ORDER_STATUS = 'COMPLETE'
    GROUP BY
        email_domain
    ORDER BY
        total_revenue DESC;
    </copy>
    ```

    - With HeatWave Cluster **ON: 1.3930 seconds**

    ![mysql-customer-order data](./images/mysql-customer-order.png "mysql customer order ")

6. To compare the HeatWave execution time with MySQL DB System execution time, disable the `use_secondary_engine` variable to see how long it takes to run the same query on the MySQL DB System. For example:

    Enter the following command at the prompt:

     ```bash
    <copy>SET SESSION use_secondary_engine=OFF;</copy>
    ```

7. Enter the following command at the prompt:

     ```bash
    <copy> SELECT
    SUBSTRING_INDEX(c.EMAIL_ADDRESS, '@', -1) AS email_domain,
    SUM(oi.QUANTITY * oi.UNIT_PRICE) AS total_revenue,
    AVG(
        LENGTH(p.PRODUCT_NAME) / (
            LENGTH(p.PRODUCT_NAME) - LENGTH(REPLACE(p.PRODUCT_NAME, ' ', '')) + 1
        )
    ) AS avg_word_length_in_product_name
    FROM
        customers c
    JOIN
        orders o ON c.CUSTOMER_ID = o.CUSTOMER_ID
    JOIN
        order_items oi ON o.ORDER_ID = oi.ORDER_ID
    JOIN
        products p ON oi.PRODUCT_ID = p.PRODUCT_ID
    WHERE
        o.ORDER_STATUS = 'COMPLETE'
    GROUP BY
        email_domain
    ORDER BY
        total_revenue DESC;
    </copy>
    ```

    - With HeatWave Cluster **OFF: 5.1417 seconds**

    ![RUN](./images/mysql-customer-order-nocluster.png "mysql customer order")

8. Keep HeatWave processing enabled

    ```bash
    <copy>SET SESSION use_secondary_engine=ON;</copy>
    ```

9. Exit MySQL Shell

      ```bash
      <copy>\q</copy>
      ```

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Cristian Aguilar, MySQL Solution Engineering, August 2025