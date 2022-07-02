# Explore Sharding Topology

## Introduction   
Docker is a set of platform-as-a-service products that use OS-level virtualization to deliver software in packages called containers. Docker containers are used to deploy the Oracle Sharding topology and the eShop application.

In this workshop, we attempt to use minimal resources to show the demonstration, and in the process we chose a single compute instance to install all of the Oracle Sharding components and the eShop application as containers.

You can find more details at [Oracle Sharding on Docker](https://github.com/oracle/db-sharding/tree/master/docker-based-sharding-deployment)


*Estimated Time*: 15 Minutes

 ![<workshop architecture>](./images/topology.jpg " ")  

As shown in the diagram above, the sharded database is deployed as multiple containers all running within the same Compute VM.


### Objectives
In this lab, you will:
* Explore Sharding environment.
* Understand Sharding architecture and its components.
* Try running your queries on already loaded data.

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment


## Task 1: Check for containers in your VM

1. Open a terminal window and execute below as **opc** user.

    ```
    <copy>
    sudo docker ps -a
    </copy>
    ```

     ![<vm containers>](./images/containers.jpg " ")

## Task 2: Connect to Shard director

A **shard director** is a specific implementation of a global service manager that acts as a regional listener for clients that connect to a sharded database. The director maintains a current topology map of the sharded database. Based on the sharding key passed during a connection request, the director routes the connections to the appropriate shard. The key capabilities of shard directors are as follows.

-	Maintain runtime data about sharded database configuration and availability of shards.
-	Measure network latency between its own and other regions.
-	Act as a regional listener for clients to connect to a sharded database.
-	Manage global services.
-	Perform connection load balancing

**Global Data Services Control Utility (GDSCTL):**  GDSCTL is a command-line interface used to configure the sharded database topology. You can connect to the shard director (global services manager) server and run the following GDSCTL commands to validate the Oracle Sharding environment.

For more details check [GDSCTL with Oracle Sharding] (https://docs.oracle.com/en/database/oracle/oracle-database/19/shard/oracle-sharding-reference1.html#GUID-15553DBF-2D49-4A2B-B49D-5770414ED2A3)

1. Run in the terminal as **opc** user and connect to the shard directory server.
    ```
    <copy>
    sudo docker exec -i -t gsm1 /bin/bash
    </copy>
    ```

    ![<connect to shard director>](./images/docker.jpg " ")

2. Verify sharding topology using the  **CONFIG** command.

    ```
    <copy>
    gdsctl config database
    </copy>
    ```

    ![<config command>](./images/config.jpg " ")

3. Lists all of the database shards and the chunks that they contain.

    ```
    <copy>
    gdsctl config chunks
    </copy>
    ```

    ![<list chunks>](./images/chunks.jpg " ")

4. Display information about all table families in the sharded database.

    ```
    <copy>
    gdsctl config table family
    </copy>
    ```

    ![<table family>](./images/tablefamily.jpg " ")

5. Show all the services in the user's Global Data Services pool.

    ```
    <copy>
    gdsctl config service
    </copy>
    ```

    ![<list services>](./images/service.jpg " ")

6. Check  for DDL statements execution status.

    ```
    <copy>
    gdsctl show ddl
    </copy>
    ```

    ![<show ddl statements>](./images/showddl.jpg " ")

## Task 3: Connect to Catalog

**Shard Catalog:** The shard catalog is a special-purpose Oracle Database that is a persistent store for sharded database configuration data and plays a key role in centralized management of a sharded database. All configuration changes, such as adding and removing shards and global services, are initiated on the shard catalog. All DDLs in a sharded database are executed by connecting to the shard catalog.

The shard catalog also contains the master copy of all duplicated tables in a sharded database. The shard catalog uses materialized views to automatically replicate changes to duplicated tables in all shards. The shard catalog database also acts as a query coordinator used to process multi-shard queries and queries that do not specify a sharding key.

A shard catalog serves following purposes.

-	Serves as an administrative server for entire sharded database
-	Stores a gold copy of the database schema
-	Manages multi-shard queries with a multi-shard query coordinator
-	Stores a gold copy of duplicated table data

For more details see [Oracle Sharding documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/19/shard/oracle-sharding-architecture-and-concepts1.html#GUID-5D5E33CA-0770-4659-8D1F-888DA552366B)

1. Run in the terminal as **opc** user and connect to the shard catalog server.

    ```
    <copy>
    sudo docker exec -i -t catalog /bin/bash
    </copy>
    ```

    ![<connect to catalog>](./images/catalog.jpg " ")

2. Connect to the shard schema in catalog server.

    ```
    <copy>
    sqlplus SHARDUSERTEST/oracle@PCAT1PDB
    </copy>
    ```

3. Check core pre-loaded shard tables in shard schema.

    ```
    <copy>
    set pagesize 300;
    set linesize 300;
    col OBJECT_NAME for a30;
    col Sharding for a30;
    select OBJECT_NAME,SHARDED as Sharding from user_objects where SHARDED='Y' and OBJECT_NAME in ('PRODUCTS','REVIEWS','CUSTOMER','CART');
    </copy>
    ```

4. Check the row count on the Product & Review shard tables.

     ```
    <copy>
    set heading off;
    select 'PRODUCTS', count(*) from products union select 'REVIEWS', count(*) from reviews;
    </copy>
    ```

   ![<check row count at catalog>](./images/query.jpg " ")

## Task 4: Connect to Shard 1 Database

**Sharded Database and Shards** Each shard in the sharded database is an independent Oracle Database instance that hosts a subset of a sharded database's data. Shared storage is not required across the shards.

Shards can be hosted anywhere an Oracle database can be hosted. Oracle Sharding supports all of the deployment choices for a shard that you would expect with a single instance or clustered Oracle Database, including on-premises, any cloud platform, Oracle Exadata Database Machine, virtual machines, and so on.

For more details see [Oracle Sharding documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/19/shard/oracle-sharding-architecture-and-concepts1.html#GUID-AD61049F-4A94-4298-A8CD-8F2536399CAD)

1.  Run in the terminal as **opc** user and connect to the shard1 DB.

    ```
    <copy>
    sudo docker exec -i -t shard1 /bin/bash
    </copy>
    ```

2. Connect to the shard schema in one of the shard database.

    ```
    <copy>
    sqlplus SHARDUSERTEST/oracle@PORCL1PDB
    </copy>
    ```

3. Check core pre-loaded shard tables in shard schema.

    ```
    <copy>
   set pagesize 300;
   set linesize 300;
   col OBJECT_NAME for a30;
   col Sharding for a30;
   select OBJECT_NAME,SHARDED as Sharding from user_objects where SHARDED='Y' and OBJECT_NAME in ('PRODUCTS','REVIEWS','CUSTOMER','CART');
    </copy>
    ```

4. Check the row count for the Product & Review shard tables in one of the shard database.

    ```
    <copy>
    set heading off;
    select 'PRODUCTS', count(*) from products union select 'REVIEWS', count(*) from reviews;
    </copy>
    ```

    ![check row count at shard](./images/shardcount.jpg " ")

   You can find the difference in the row count between the shard catalog and the shard-database (porcl1cdb\_porcl1pdb, porcl2cdb\_porcl2pdb, porcl3cdb\_porcl3pdb).

## Task 5: Run Application Queries on a sharded Database

Run each SQL query by logging in to the shard catalog database as well as one of the shard databases. You can observe the difference in row count on the shard catalog compared to the shard-database (porcl1cdb\_porcl1pdb, porcl2cdb\_porcl2pdb and porcl3cdb\_porcl3pdb).

**Establish connection to Catalog and to one of the Shards.**

1. Open a terminal and execute below as **opc** user to connect to **Catalog**.

    ```
    <copy>
    sudo docker exec -i -t catalog /bin/bash
    </copy>
    ```

    ```
    <copy>
    sqlplus SHARDUSERTEST/oracle@PCAT1PDB
    </copy>
    ```

2. Open another terminal and execute below as **opc** user to connect to one of the shards. In this    case, you will connect to **shard3** as below.

    ```
    <copy>
    sudo docker exec -i -t shard3 /bin/bash
    </copy>
    ```
    ```
    <copy>
    sqlplus SHARDUSERTEST/oracle@PORCL3PDB
    </copy>
    ```

    ![<application queries>](./images/appquery.jpg " ")

**Run Application Queries on sharding Database.**

Run the below each sql query by login into Catalog database as well as one of the shard database(shard3 in this case). You can notice the difference of row count on Shard catalog vs shard-DB (porcl1cdb\_porcl1pdb, porcl2cdb\_porcl2pdb and porcl3cdb\_porcl3pdb).

1. Text search on Products (JSON) table with auto corrections: Oracle Fuzzy matching is a method that provides an improved ability to process word-based matching queries to find matching phrases or sentences from a database.

    ```
    <copy>
    select p.json_text.NAME from PRODUCTS p where contains(json_text, 'fuzzy((meras))', 1) > 0 order by score(1) desc;
    </copy>
    ```

    ![<oracle fuzzy query>](./images/fuzzyquery.jpg " ")

2. Top Selling Products: Return top Selling products in the store ranging from high to low from last two months by fetching from LINE_ITEM (Relational ) & Products (JSON) & Reviews (JSON) Tables.

    ```
    <copy>
    set lines 200 pages 200
    col SKU for a20
    col PRODUCT_NAME for a30
    col BEST_REVIEW for a50
    select le.SKU,pr.Product_Name,le.count,le.SELL_VALUE,re.Avg_Senti_Score,rev.BEST_REVIEW from (select product_id as SKU, sum(PRODUCT_QUANTITY) as count,ROUND(sum(PRODUCT_COST*PRODUCT_QUANTITY),2) as SELL_VALUE from LINE_ITEM where DATE_ORDERED > sysdate -60 group by product_id ) le,(select r.sku as id,round(avg(r.senti_score)) as Avg_Senti_Score from reviews r group by r.sku) re,(select p.sku as pid,substr(p.json_text.NAME,0,30) as Product_Name from products p) pr,(select r.sku as rvid,r.revid,substr(r.json_text.REVIEW,0,40) as BEST_REVIEW from reviews r,(select sku as pid ,max(senti_score) as bestscore from reviews group by sku) where r.sku=pid and r.senti_score=bestscore) rev where re.id=le.SKU and pr.pid=le.SKU and rev.rvid=le.SKU order by 3 desc;
    </copy>
    ```
    ![<top selling products>](./images/queryone.jpg " ")


3. Select products ordered by maximum sell

    ```
    <copy>
    set lines 200 pages 200
    col SKU for a40
    select product_id as SKU, sum(PRODUCT_QUANTITY) as count,ROUND(sum(PRODUCT_COST*PRODUCT_QUANTITY),2) as SELL_VALUE from LINE_ITEM where DATE_ORDERED > sysdate -60 group by product_id order by count desc;
    </copy>
    ```
    ![<maximum sell>](./images/maximumsell.jpg " ")

4. Customer Average Review and review count

    ```
    <copy>
    Set lines 200 pages 200
    col NAME for a40
    col AVG_REV for a5
    col REV_COUNT for a5
    col SKU for a30
    select substr(p.json_text.NAME,0,40) NAME,p.json_text.CUSTOMERREVIEWAVERAGE as AVG_REV,p.json_text.CUSTOMERREVIEWCOUNT as REV_COUNT,SKU from PRODUCTS p ;
    </copy>
    ```

    ![<average review>](./images/average.jpg " ")

5.  Let's try one query at **shard2** database. Open another terminal and execute below as **opc** user to connect to **shard2**.

    ```
    <copy>
    sudo docker exec -i -t shard2 /bin/bash
    </copy>
    ```
    ```
    <copy>
    sqlplus SHARDUSERTEST/oracle@PORCL2PDB
    </copy>
    ```

    Dollar Value sale by month: A single query spanning from LINE_ITEM shard table by accessing multiple (3) shard databases.

    ```
    <copy>
    Select L.monthly,to_char(l.monthly,'MON') as month,sum(l.value) value from (select TRUNC(date_ordered, 'MON') as Monthly,Product_Cost*Product_Quantity as value, date_ordered from LINE_ITEM order by date_ordered asc) l group by l.monthly order by monthly asc;
    </copy>
    ```

   ![<run at another shard>](./images/anothershard.jpg " ")

This is the end of the Oracle Sharding Workshop.


## **Appendix 1**: Sharding Overview & Architecture

**Oracle Sharding** is a feature of Oracle Database that lets you automatically distribute and replicate data across a pool of Oracle databases that share no hardware or software. Oracle Sharding provides the best features and capabilities of mature RDBMS and NoSQL databases.

![<architecture>](./images/arch.jpg " ")  

**Core Components of the Oracle Sharding Architecture**

1. **Partitions, Tablespaces and Chunks:** Distribution of partitions across shards is achieved by creating partitions in tablespaces that reside on different shards.

2. **Tablespace Sets:** Oracle Sharding creates and manages tablespaces as a unit called a TABLESPACE SET.

3. **Sharding Methods:** The following topics discuss sharding methods supported by Oracle Sharding, how to choose a method, and how to use subpartitioning.

4. **Sharded Database Schema Objects:** To obtain the benefits of sharding, the schema of a sharded database should be designed in a way that maximizes the number of database requests executed on a single shard. The following topics define and illustrate the schema objects that form a sharded database to inform your design.

For more details see [Oracle Sharding documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/19/shard/oracle-sharding-architecture-and-concepts1.html#GUID-9DC0048A-2D6E-4759-BA80-10F8855E6871)

**Oracle Sharding Components**

1. **Shard Director:** Shard directors are network listeners that enable high performance connection routing based on a sharding key.

2. **Global Service:** A global service is a database service that is use to access data in a sharded database.

3. **Shard Catalog:** A shard catalog is an Oracle Database that supports automated shard deployment, centralized management of a sharded database, and multi-shard queries.

4. **Sharded Database and Shards:** A sharded database is a collection of shards.


**Sharded database schema objects**

To obtain the benefits of sharding, the schema of a sharded database should be designed in a way that maximizes the number of database requests executed on a single shard. The following topics define and illustrate the schema objects that form a sharded database to inform your design.

**Sharded Tables:** A database table is split up across the shards, so that each shard contains the table with the same columns, but a different subset of rows. A table split up in this manner is called a sharded table.

**Sharded Table Family:** A sharded table family is a set of tables that are sharded in the same way. Often there is a parent-child relationship between database tables with a referential constraint in a child table (foreign key) referring to the primary key of the parent table.

**Duplicated Tables:** In Oracle Sharding a table with the same contents in each shard is called a duplicated table.

**Non-Table Objects Created on All Shards:** In addition to duplicated tables, other schema objects, such as users, roles, views, indexes, synonyms, functions, procedures, and packages, and non-schema database objects, such as tablespaces, tablespace sets, directories, and contexts, can be created on all shards.

Click [here] (https://github.com/alexkovuru/Oracle-Shard-Schema-Design/blob/main/Shard_Schema_Design.txt) for more details.


## **Appendix 2**: Sharding Methods

The following topics discuss sharding methods supported by Oracle Sharding, how to choose a method, and how to use subpartitioning.

- **System-Managed Sharding:** System-managed sharding is a sharding method which does not require the user to specify mapping of data to shards. Data is automatically distributed across shards using partitioning by consistent hash. The partitioning algorithm evenly and randomly distributes data across shards.

- **User-Defined Sharding:** User-defined sharding lets you explicitly specify the mapping of data to individual shards. It is used when, because of performance, regulatory, or other reasons, certain data needs to be stored on a particular shard, and the administrator needs to have full control over moving data between shards.

- **Composite Sharding:** The composite sharding method allows you to create multiple shardspaces for different subsets of data in a table partitioned by consistent hash. A shardspace is set of shards that store data that corresponds to a range or list of key values.

- **Using Subpartitions with Sharding:** Because Oracle Sharding is based on table partitioning, all of the subpartitioning methods provided by Oracle Database are also supported for sharding.

In this demonstration, we choose the **system-managed sharding.**

For more details see [Oracle sharding documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/19/shard/sharding-overview.html#GUID-3427DEDA-39E8-4E92-9A47-D0C65A240223)

Below are Sample sharded table DDLs:

 ```
    CREATE SHARDED TABLE "CUSTOMER_AUTH"
	( "USER_ID" NUMBER NOT NULL ENABLE,
	"EMAIL" VARCHAR2(200 BYTE) NOT NULL ENABLE,
	"PASSWORD" VARCHAR2(100 BYTE) NOT NULL ENABLE,
	PRIMARY KEY ("USER_ID")
	)
    TABLESPACE SET TTTSP_SET_1   PARTITION BY CONSISTENT HASH (USER_ID) PARTITIONS AUTO;
```

```
    CREATE SHARDED TABLE "PRODUCTS"
       ( "SKU" VARCHAR2(255 BYTE) NOT NULL ENABLE,
         "JSON_TEXT" CLOB,
          CHECK ("JSON_TEXT" is json strict) ENABLE,
          PRIMARY KEY ("SKU")
      ) TABLESPACE SET TTTSP_SET_2 PARTITION BY CONSISTENT HASH (SKU) PARTITIONS AUTO;
 ```

You may now [proceed to the next lab](#next).

## Learn More

- [Oracle Sharding Documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/19/shard/sharding-overview.html#GUID-0F39B1FB-DCF9-4C8A-A2EA-88705B90C5BF)

## Rate this Workshop
When you are finished don't forget to rate this workshop!  We rely on this feedback to help us improve and refine our LiveLabs catalog.  Follow the steps to submit your rating.

1.  Go back to your **workshop homepage** in LiveLabs by searching for your workshop and clicking the Launch button.
2.  Click on the **Brown Button** to re-access the workshop  

    ![](https://oracle-livelabs.github.io/common/labs/cloud-login/images/workshop-homepage-2.png " ")

3.  Click **Rate this workshop**

    ![](https://oracle-livelabs.github.io/common/labs/cloud-login/images/rate-this-workshop.png " ")

If you selected the **Green Button** for this workshop and still have an active reservation, you can also rate by going to My Reservations -> Launch Workshop.

## Acknowledgements
* **Authors** - Shailesh Dwivedi, Database Sharding PM , Vice President
* **Contributors** - Balasubramanian Ramamoorthy, Alex Kovuru, Nishant Kaushik, Ashish Kumar, Priya Dhuriya, Richard Delval, Param Saini,Jyoti Verma, Virginia Beecher, Rodrigo Fuentes
* **Last Updated By/Date** - Priya Dhuriya, Staff Solution Engineer - July 2021
