# Setup HeatWave with mysql\_customer\_orders Data

## Introduction

We will be using the mysql\_customer\_orders Data for this wprkshop

_Estimated Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following task:

- Connect to database using MySQL Shell
- Add the mysql\_customer\_orders Datato  HeatWave if it is not already there

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Completed Lab 2

## Task 1: Connect to database using MySQL Shell

1. If not already connected with SSH, on Command Line, connect to the Compute instance using SSH ... be sure replace the  "private key file"  and the "new compute instance ip"

     ```bash
    <copy>ssh -i private_key_file opc@new_compute_instance_ip</copy>
     ```

2. Use the following command to connect to MySQL using the MySQL Shell client tool. Be sure to add the **heatwave-db** private IP address at the end of the command. Also enter the admin user and the db password created on Lab 1

    (Example  **mysqlsh -uadmin -p -h10.0.1..   --sql**)

    **[opc@...]$**

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1.... --sql</copy>
    ```

    ![MySQL Shell connected DB](./images/connect-myslqsh.png "connect myslqsh")

3. List schemas in your heatwave instance

    ```bash
    <copy>show databases;</copy>
    ```

    ![Database Schema List](./images/list-schemas-after.png "list schemas first view")

4. if you do not see the **mysql\_customer\_orders** schema on the list, then load it using the following commands:
    - a. change to JS

        ```bash
        <copy>\js</copy>
        ```

    - b. Run load command

        ```bash
        <copy>util.loadDump("https://objectstorage.us-ashburn-1.oraclecloud.com/p/e9-qd9eqC2gatEl4qqsRD4L_mqn433tr00ALKmYzh8AuTQ-drS1thJvgLoz64-vF/n/mysqlpm/b/mysql_customer_orders/o/mco_nocoupon_11272024/", {progressFile: "progress.json", loadIndexes:false,ignoreVersion:true})</copy>
        ```

        **Note**: If you get errors like the one below, the **mysql\_customer\_orders** schema already exists. You used the correct PAR Link to load the data during the creation process in Lab1. Don't worry; everything is okay.

         *ERROR: Schema `mysql_customer_orders` already contains a table named customers*

    - c. Change to SQL mode

        ```bash
        <copy>\sql</copy>
        ```

    - d. Make sure the **mysql\_customer\_orders** schema was loaded

        ```bash
        <copy>show databases;</copy>
        ```

        ![Database Schema List](./images/list-schemas-after.png "list schemas second view")

5. View  the mysql\_customer\_orders total records per table in

    ```bash
    <copy>SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'mysql_customer_orders';</copy>
    ```

    ![Databse Tables](./images/mysql-customer-orders-list.png "mysql customer orders list")

## Task 2: Review the HeatWave Cluster Setup

1. Go to Navigation Menu
    Databases
        MySQL

2. Click the `heatwave-db` Database System link

    ![Database List](./images/db-list.png "Database List")

3. In the list of DB Systems, click the **heatwave-db** system. On  the **HeatWave Cluster** Section, click on Details

    ![Databse Cluster Detail](./images/mysql-heatwave-more.png "mysql heatwave cluster")

4. The HeatWave Cluster Information section will look like this:
    ![Completed Cluster Creation](./images/mysql-heat-cluster-complete.png "mysql heat cluster complete ")

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, December 2024
