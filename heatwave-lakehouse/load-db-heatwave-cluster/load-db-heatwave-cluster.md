# Test Mysql HeatWave Cluster

## Introduction

A HeatWave cluster comprise of a MySQL DB System node and two or more HeatWave nodes. The MySQL DB System node includes a plugin that is responsible for cluster management, loading data into the HeatWave cluster, query scheduling, and returning query result.

In this lab, you will load data and run queries in the HeatWave Cluster. You will see the query performance improvements on HeatWave compare to MySQL.

![Connect](./images/heatwave-lab-setup.png "heatwave lab setup ")

_Estimated Time:_ 15 minutes

### Objectives

In this lab, you will be guided through the following task:

- Load mysql\_customer\_orders Data into the HeatWave Cluster
- Run Comparison Queries  with the HeatWave Cluster loaded data

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 2

## Task 1: Load Schema Data into HeatWave Cluster

1. Login to the OCI Console.
2. Click the Cloud Shell icon in the Console
3. Connect to MySQL using the MySQL Shell client tool with the following command:

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1... --sql </copy>
    ```

    ![Connect](./images/mysql-shell-login.png " mysql shell login")

4. Run the following Auto Parallel Load command to load the  mysql\_customer\_orders tables data into the HeatWavecluster

    ```bash
    <copy>CALL sys.heatwave_load(JSON_ARRAY('mysql_customer_orders'), NULL);</copy>
    ```

5. The completed load cluster screen should look like this:

    ![Connect](./images/load-cluster-begin.png "load cluster begin")

    ![Connect](./images/load-cluster-end.png "load cluster end")

6. Verify that the tables are loaded in the HeatWave cluster. Loaded tables have an AVAIL_RPDGSTABSTATE load status.

    ```bash
    <copy>USE performance_schema;</copy>
    ```

    ```bash
    <copy>SELECT NAME, LOAD_STATUS FROM rpd_tables,rpd_table_id WHERE rpd_tables.ID = rpd_table_id.ID;</copy>
    ```

    ![Connect](./images/heatwave-loaded-data.png "heatwave loaded data")

## Task 2: Run Queries in HeatWave

1. If not already connected then connect to MySQL using the MySQL Shell client tool with the following command:

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1... --sql </copy>
    ```

    ![Connect](./images/mysql-shell-login.png " mysql shell login")

2. Change to the mysql\_customer\_orders database

    Enter the following command at the prompt

    ```bash
    <copy>USE mysql_customer_orders;</copy>
    ```

3. **Query 1** - List Customer total purchase for the year by month

4. Before running a query, use EXPLAIN to verify that the query can be offloaded to the HeatWave cluster. You should see "Use secondary engine RAPID" in the explain plan. For example:

    ```bash
    <copy>EXPLAIN  
    select `o`.`ORDER_ID` AS `order_id`,`o`.`ORDER_DATETIME` AS `ORDER_DATETIME`,
	    `o`.`ORDER_STATUS` AS `order_status`, `c`.`CUSTOMER_ID` AS `customer_id`,
	    `c`.`EMAIL_ADDRESS` AS `email_address`,`c`.`FULL_NAME`  AS `full_name`,
	    sum((`oi`.`QUANTITY` * `oi`.`UNIT_PRICE`)) AS `order_total`,
	    `p`.`PRODUCT_NAME` AS `product_name`,`oi`.`LINE_ITEM_ID` AS `LINE_ITEM_ID`,
	    `oi`.`QUANTITY`  AS `QUANTITY`,`oi`.`UNIT_PRICE` AS `UNIT_PRICE` 
    from (((`orders` `o` join `order_items` `oi` on((`o`.`ORDER_ID` = `oi`.`ORDER_ID`))) 
	    join `customers` `c` on((`o`.`CUSTOMER_ID` = `c`.`CUSTOMER_ID`))) 
	    join `products` `p` on((`oi`.`PRODUCT_ID` = `p`.`PRODUCT_ID`))) 
    group by `o`.`ORDER_ID`,`o`.`ORDER_DATETIME`,`o`.`ORDER_STATUS`,`c`.`CUSTOMER_ID`
	    ,`c`.`EMAIL_ADDRESS` ,`c`.`FULL_NAME`,`p`.`PRODUCT_NAME`
        ,`oi`.`LINE_ITEM_ID`,`oi`.`QUANTITY`,`oi`.`UNIT_PRICE` limit 10;
    </copy>
    ```

    ![RUN](./images/mysql-customer-order-explain.png "mysql customer order explain")

5. After verifying that the query can be offloaded, run the query and note the execution time. Enter the following command at the prompt:

     ```bash
    <copy> select `o`.`ORDER_ID` AS `order_id`,`o`.`ORDER_DATETIME` AS `ORDER_DATETIME`,
	    `o`.`ORDER_STATUS` AS `order_status`, `c`.`CUSTOMER_ID` AS `customer_id`,
	    `c`.`EMAIL_ADDRESS` AS `email_address`,`c`.`FULL_NAME`  AS `full_name`,
	    sum((`oi`.`QUANTITY` * `oi`.`UNIT_PRICE`)) AS `order_total`,
	    `p`.`PRODUCT_NAME` AS `product_name`,`oi`.`LINE_ITEM_ID` AS `LINE_ITEM_ID`,
	    `oi`.`QUANTITY`  AS `QUANTITY`,`oi`.`UNIT_PRICE` AS `UNIT_PRICE` 
    from (((`orders` `o` join `order_items` `oi` on((`o`.`ORDER_ID` = `oi`.`ORDER_ID`))) 
	    join `customers` `c` on((`o`.`CUSTOMER_ID` = `c`.`CUSTOMER_ID`))) 
	    join `products` `p` on((`oi`.`PRODUCT_ID` = `p`.`PRODUCT_ID`))) 
    group by `o`.`ORDER_ID`,`o`.`ORDER_DATETIME`,`o`.`ORDER_STATUS`,`c`.`CUSTOMER_ID`
	    ,`c`.`EMAIL_ADDRESS` ,`c`.`FULL_NAME`,`p`.`PRODUCT_NAME`
        ,`oi`.`LINE_ITEM_ID`,`oi`.`QUANTITY`,`oi`.`UNIT_PRICE` limit 10;
    </copy>
    ```

    - With HeatWave Cluster **ON: .3509 seconds**

    ![Connect](./images/mysql-customer-order.png "mysql customer order ")

6. To compare the HeatWave execution time with MySQL DB System execution time, disable the `use_secondary_engine` variable to see how long it takes to run the same query on the MySQL DB System. For example:

    Enter the following command at the prompt:

     ```bash
    <copy>SET SESSION use_secondary_engine=OFF;</copy>
    ```

7. Enter the following command at the prompt:

     ```bash
    <copy> select `o`.`ORDER_ID` AS `order_id`,`o`.`ORDER_DATETIME` AS `ORDER_DATETIME`,
	    `o`.`ORDER_STATUS` AS `order_status`, `c`.`CUSTOMER_ID` AS `customer_id`,
	    `c`.`EMAIL_ADDRESS` AS `email_address`,`c`.`FULL_NAME`  AS `full_name`,
	    sum((`oi`.`QUANTITY` * `oi`.`UNIT_PRICE`)) AS `order_total`,
	    `p`.`PRODUCT_NAME` AS `product_name`,`oi`.`LINE_ITEM_ID` AS `LINE_ITEM_ID`,
	    `oi`.`QUANTITY`  AS `QUANTITY`,`oi`.`UNIT_PRICE` AS `UNIT_PRICE` 
    from (((`orders` `o` join `order_items` `oi` on((`o`.`ORDER_ID` = `oi`.`ORDER_ID`))) 
	    join `customers` `c` on((`o`.`CUSTOMER_ID` = `c`.`CUSTOMER_ID`))) 
	    join `products` `p` on((`oi`.`PRODUCT_ID` = `p`.`PRODUCT_ID`))) 
    group by `o`.`ORDER_ID`,`o`.`ORDER_DATETIME`,`o`.`ORDER_STATUS`,`c`.`CUSTOMER_ID`
	    ,`c`.`EMAIL_ADDRESS` ,`c`.`FULL_NAME`,`p`.`PRODUCT_NAME`
        ,`oi`.`LINE_ITEM_ID`,`oi`.`QUANTITY`,`oi`.`UNIT_PRICE` limit 10;
    </copy>
    ```

    - With HeatWave Cluster **OFF: 16.4660 seconds**

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
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2023
