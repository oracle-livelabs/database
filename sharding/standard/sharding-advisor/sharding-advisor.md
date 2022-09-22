# Using Sharding Advisor

## Introduction

Sharding Advisor simplifies the migration of your existing, non-sharded Oracle database to a sharded database, by analyzing your workload and database schema, and recommending the most effective Oracle Sharding configurations. The Sharding Advisor is a client-side, command-line tool that you run against any non-sharded, production, 10g or later release, Oracle Database that you are considering migrating to an Oracle Sharding environment.

The Sharding Advisor utility, `GWSADV`, is installed with Oracle Database 21c as a standalone tool, and connects to your database using authenticated OCI connections.

Estimated Lab Time: 30 minutes.

### Objectives

In this lab, you will perform the following steps:

- Run Sharding Advisor
- Review Sharding Advisor Output

### Prerequisites

This lab assumes you have already completed the following:

- Setup non-Shard Database Application

## Task 1: Run Sharding Advisor

1. Connect to the non-Shard database with sysdba.

    ```
    [oracle@shd3 ~]$ sqlplus sys/Ora_DB4U@shd3:1521/nspdb as sysdba
    
    SQL*Plus: Release 19.0.0.0.0 - Production on Thu Dec 10 02:09:00 2020
    Version 19.14.0.0.0
    
    Copyright (c) 1982, 2020, Oracle.  All rights reserved.
    
    
    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
    
    SQL> 
    ```

2. Copy and run the following commands in the sqlplus. The user running Sharding Advisor requires the following priviledges.

    ```
    ALTER SYSTEM SET statistics_level=all;
    grant create session to app_schema;
    grant alter session to app_schema;
    grant select on v_$sql_plan to app_schema;
    grant select on v_$sql_plan_statistics_all to app_schema;
    grant select on gv_$sql_plan to app_schema;
    grant select on gv_$sql_plan_statistics_all to app_schema;
    grant select on DBA_HIST_SQLSTAT to app_schema;
    grant select on dba_hist_sql_plan to app_schema;
    grant select on dba_hist_snapshot to app_schema;
    ```

   

3. Run the workload in the non-sharded database.

    ```
    [oracle@cata sdb_demo_app]$ ./run.sh demo nonsharddemo.properties 
     RO Queries | RW Queries | RO Failed  | RW Failed  | APS 
              0            0            0            0            3
            384           52            0            0          158
           2266          404            0            0          816
           4381          759            0            0          910
           6529         1112            0            0          921
           8552         1490            0            0          884
          10688         1894            0            0          924
          12859         2280            0            0          907
          15034         2663            0            0          925
          17104         3064            0            0          881
          19274         3455            0            0          953
          21392         3854            0            0          904
          23451         4268            0            0          913
          25663         4647            0            0          964
          27855         5006            0            0          964
          29880         5352            0            0          862
          31772         5710            0            0          825
          33953         6106            0            0          928
          36093         6505            0            0          926
          38271         6866            0            0          970
    ```

   

4. Wait several minutes and press Ctrl+C to cancel the workload.

5. From Database 21c hosts. Run the command to capture the workload information.

    ```
    [oracle@db21c ~]$ gwsadv -n 193.123.236.194:1521 -s nspdb -u app_schema -p app_schema sch=app_schema -c -w
    SHADV-00325: additional schema specified has the same name as the current schema, and will be ignored
    ********** WELCOME TO THE SHARDING ADVISOR **********
    Sharding Advisor: Release 20.0 - Development on Thu Dec 10 2020 02:15:14
    Copyright (c) 1982, 2018, Oracle and/or its affiliates. All rights reserved.
    
    ** Sharding is a database scaling technique based on horizontal partitioning ** 
    ** of data across multiple independent physical databases, called shards. **
    
    ** The sharding advisor will analyze your schema and workload and **
    ** recommend sharding configurations that are best suited for the workload. **
    ** The advisor will recommend how to construct table families, and **
    ** specify which tables to shard and which tables to duplicate. **
    
    ** A Sharded Table is a table that is partitioned into smaller and **
    ** more manageable pieces among multiple databases, called shards. **
    ** A Sharded Table Family is a set of tables that are sharded in the same way. **
    ** A Duplicated Table is a table that is duplicated on all shards. **
    
    ** There could be multiple ways to shard a database schema. The sharding advisor **
    ** will generate a set of alternative sharding configurations, which will be ranked. **
    
    ** The ranking algorithm gives preference to sharding configurations that minimize **
    ** the execution time for most frequent queries and require less data to be **
    ** duplicated across shards. Since these goals are often conflicting, the advisor **
    ** will generate multiple alternative sharding configurations that represent **
    ** different trade-offs between the goals. **
    ** IT IS HIGHLY RECOMMENDED TO COMPARE A FEW ALTERNATIVES AND CHOOSE ONE WHICH IS BEST **
    ** SUITABLE FOR YOUR APPLICATION. **
    
    ** The advisor is invoked with the following command:
    ** Example: gwsadv -u scott -p tiger -w **
    
    ** The advisor will ask you some questions to help in the sharded database design. **
    
    ** The number of shards in a sharded configuration is an important parameter **
    ** that can influence scalability, fault isolation, and availability. **
    ```

   

6. Enter the number of primary shards you want to deploy. For example: 3.

    ```
    ENTER THE ESTIMATED NUMBER OF PRIMARY SHARDS FOR YOUR CURRENT CONFIGURATION (1-1000): 3
    
    *** CAPTURING QUERY WORKLOAD PREDICATES ... ***
    
    *** ANALYZING USER SCHEMA ... ***
    
    * The workload predicates indicate that direct routing to a shard may be possible.
    ** In direct routing, a connection is established to a single, relevant shard **
    ** which contains the data pertinent to the required transaction using a sharding key. **
    * Direct routing requires the sharding key to be passed as part of the connection.
    ```

   

7. Enter **y** when ask if a sharding key can be provided.

    ```
    CAN A SHARDING KEY BE PROVIDED AS PART OF THE CONNECTION (y/n)? y
    ```

   

8. Two candidate sharding keys are founded by the advisor, Enter 1 for choose the first candidate.

    ```
    * 1. CANDIDATE SHARDING KEY FOR DIRECT ROUTING IS APP_SCHEMA.CUSTOMERS.CUSTID 
       THE APP_SCHEMA.CUSTOMERS TABLE has 151044 ROWS WITH AN AVERAGE ROWLENGTH OF 233.0 
       THE APP_SCHEMA.CUSTOMERS.CUSTID COLUMN HAS A WIDTH OF 22.0 AND HAS 151044 NUMBER OF DISTINCT VALUES
     * 2. CANDIDATE SHARDING KEY FOR DIRECT ROUTING IS APP_SCHEMA.ORDERS.CUSTID 
       THE APP_SCHEMA.ORDERS TABLE has 281479 ROWS WITH AN AVERAGE ROWLENGTH OF 48.0 
       THE APP_SCHEMA.ORDERS.CUSTID COLUMN HAS A WIDTH OF 22.0 AND HAS 150144 NUMBER OF DISTINCT VALUES
    
    PICK THE BEST SHARDING KEY FOR DIRECT ROUTING: 1
    ```

   

9. You can then get the sharding advisor result.

    ```
      * COMPUTING SHARDING CONFIGURATIONS WITH 'APP_SCHEMA.CUSTOMERS.CUSTID' AS SHARDING KEY ... 
    * DONE COMPUTING SHARDING CONFIGURATIONS
    
    * THE SHARDING CONFIGURATIONS ARE STORED IN THE 'APP_SCHEMA.SHARDINGADVISOR_CONFIGURATIONS' TABLE
    * THE CONFIGURATION DETAILS ARE STORED IN THE 'APP_SCHEMA.SHARDINGADVISOR_CONFIGDETAILS' TABLE
    * THE QUERY TYPES ARE STORED IN THE 'APP_SCHEMA.SHARDINGADVISOR_QUERYTYPES' TABLE
    * THE SHARDING CONFIGURATIONS ARE RANKED BASED ON PROVIDING THE BEST PERFORMANCE
    
    **********************************************************************
    * THE TABLE FAMILY OF THE TOP SHARDING CONFIGURATION IS LISTED BELOW *
    **********************************************************************
    
    RANK TABLE                     TYPE LEVEL PARENT                    SHARDBY    SHARDORREFCOLS            UNENFORCEABLECONSTRAINTS  SIZE(BLKS)
    ---- ------------------------- ---- ----- ------------------------- ---------- ------------------------- ------------------------- ----------
    1    APP_SCHEMA.CUSTOMERS      S    1                               HASH       CUSTID                                              4024      
    1    APP_SCHEMA.ORDERS         S    2     APP_SCHEMA.CUSTOMERS      REFERENCE  FK_ORDERS_PARENT                                    4024      
    1    APP_SCHEMA.LINEITEMS      S    3     APP_SCHEMA.ORDERS         REFERENCE  FK_ITEMS_PARENT                                     4024      
    
    *****************************************************************
    * THE DETAILS OF THE TOP SHARDING CONFIGURATION IS LISTED BELOW *
    *****************************************************************
    
    RANK RATING NUMSTABS SIZESTABS(BLKS) NUMDTABS SIZEDTABS(BLKS) NUMSSQ NUMMSQ NUMCSQ COST
    ---- ------ -------- --------------- -------- --------------- ------ ------ ------ ----
    1    1      3        12000           1        5               2      0      0      2         
    
    * A RATING OF 1 OR 2 MEANS THE SHARDING CONFIGURATION IS GOOD FOR SHARDING
    * A RATING OF 3 MEANS THE SHARDING CONFIGURATION MAY BE GOOD FOR SHARDING
    * A RATING OF 4 OR 5 MEANS THE SHARDING CONFIGURATION IS NOT VERY GOOD FOR SHARDING
    
    ***********************************************
    *** SHARDING ADVISOR FINISHED SUCCESSFULLY! ***
    ***********************************************
    [oracle@db21c ~]$ 
    ```

   

## Task 2: Review Sharding Advisor Outputs

To review the sharding configurations and related information that is owned by the user running Sharding Advisor, you can query the following output database tables, which are stored in the same schema as your source database.

- `SHARDINGADVISOR_CONFIGURATIONS` has one row for each table in a ranked sharded configuration, and provides details for each table, such as whether to shard or duplicate it, and if sharded, its level in a table family hierarchy, its parent table, root table sharding key, foreign key reference constraints, and the estimated size per shard.
- `SHARDINGADVISOR_CONFIGDETAILS` has one row for each ranked sharding configuration, and provides details for each ranked sharding configuration, such as the number and collective size, per shard, of the sharded tables, and the number and collective size of the duplicated tables. It also provides the number of single shard and multi-shard queries to expect in production, as well as the number of multi-shard queries requiring cross-shard joins, based on your source database's current workload, and an estimated cost.
- `SHARDINGADVISOR_QUERYTYPES`, for each query in the workload, lists the query type for each sharding configuration. Note that the same query can be of a different query type depending on the sharding configuration.

1. Connect to the user with SQLPLUS.

    ```
    [oracle@shd3 ~]$ sqlplus app_schema/app_schema@shd3:1521/nspdb
    
    SQL*Plus: Release 19.0.0.0.0 - Production on Thu Dec 10 02:21:21 2020
    Version 19.14.0.0.0
    
    Copyright (c) 1982, 2020, Oracle.  All rights reserved.
    
    Last Successful login time: Thu Dec 10 2020 02:15:13 +00:00
    
    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
    
    SQL> 
    ```

   

2. Format the Sqlplus output.

    ```
    set linesize 200
    column rank format 99
    column tname format a20
    column type format a4
    column tlevel format 99
    column parent format a10
    column shardby format a10
    column cols format a10
    column unenforceableconstraints format a10
    column sizeoftable format 9999
    ```

   

3. Display the sharding configurations in ranking order

    ```
    SQL> SELECT rank, tableName as tname, tabletype as type,
               tablelevel as tlevel, parent, shardby as shardBy,
               shardingorreferencecols as cols, unenforceableconstraints,
               sizeoftable  
    FROM SHARDINGADVISOR_CONFIGURATIONS
    ORDER BY rank, tlevel, tname, parent;  2    3    4    5    6 
    
    RANK TNAME		  TYPE TLEVEL PARENT	 SHARDBY    COLS       UNENFORCEA SIZEOFTABLE
    ---- -------------------- ---- ------ ---------- ---------- ---------- ---------- -----------
       1 APP_SCHEMA.CUSTOMERS S	    1		 HASH	    CUSTID			 4024
       1 APP_SCHEMA.ORDERS	  S	    2 APP_SCHEMA REFERENCE  FK_ORDERS_			 4024
    				      .CUSTOMERS	    PARENT
    
       1 APP_SCHEMA.LINEITEMS S	    3 APP_SCHEMA REFERENCE  FK_ITEMS_P			 4024
    				      .ORDERS		    ARENT
    
       1 APP_SCHEMA.PRODUCTS  D			 NONE					    5
    ```

   

4. Display the table family of the top ranked sharding configuration

    ```
    SQL> SELECT rank, tableName as tname, tabletype as type,
            tablelevel as tlevel, parent, shardby as shardBy,
            shardingorreferencecols as cols, unenforceableconstraints,
            sizeoftable
    FROM SHARDINGADVISOR_CONFIGURATIONS 
    WHERE rank = 1 AND tabletype = 'S' 
    ORDER BY tlevel, tname, parent;  2    3    4    5    6    7  
    
    RANK TNAME		  TYPE TLEVEL PARENT	 SHARDBY    COLS       UNENFORCEA SIZEOFTABLE
    ---- -------------------- ---- ------ ---------- ---------- ---------- ---------- -----------
       1 APP_SCHEMA.CUSTOMERS S	    1		 HASH	    CUSTID			 4024
       1 APP_SCHEMA.ORDERS	  S	    2 APP_SCHEMA REFERENCE  FK_ORDERS_			 4024
    				      .CUSTOMERS	    PARENT
    
       1 APP_SCHEMA.LINEITEMS S	    3 APP_SCHEMA REFERENCE  FK_ITEMS_P			 4024
    				      .ORDERS		    ARENT
    
    ```

   

5. Display the details of the sharding configurations in ranking order

    ```
    SQL> SELECT rank, chosenbyuser,
            numshardedtables as stabs, sizeofshardedtables as sizestabs,
            numduplicatedtables as dtabs,
            sizeofduplicatedtables as sizedtabs,
            numsingleshardqueries as numssq,
            nummultishardqueries as nummsq,
            numcrossshardqueries as numcsq, cost
    FROM SHARDINGADVISOR_CONFIGDETAILS
    ORDER BY rank;  2    3    4    5    6    7    8    9  
    
    RANK C	    STABS  SIZESTABS	  DTABS  SIZEDTABS     NUMSSQ	  NUMMSQ     NUMCSQ	  COST
    ---- - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
       1 Y		3      12072	      1 	 5	    2	       0	  0	     2
    ```

6.  Lists the query type and SQL ID.

    ```
    SQL> select * from SHARDINGADVISOR_QUERYTYPES;
    
    SHARDINGCONFIGURATIONNUM SQLID
    ------------------------ -------------
    QUERYTYPE
    --------------------------------------------------
    		       1 7a836gta3176u
    SINGLE SHARD QUERY
    
    		       1 fmptaf9h11q1q
    SINGLE SHARD QUERY
    
    
    SQL> 
    ```

   You may now [proceed to the next lab](#next) 

   ## Acknowledgements
   * **Author** - Minqiao Wang, DB Product Management, Dec 2020 
   * **Last Updated By/Date** - Minqiao Wang, Jun 2021

