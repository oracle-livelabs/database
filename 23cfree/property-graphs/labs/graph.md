# Bank Transfers Graph Example with SQL/PGQ in 23c

## Introduction

In this lab you will query the newly create graph (that is, `bank_graph`) in PGQL paragraphs.

Estimated Time: 30 minutes.

Watch the video below for a quick walk through of the lab.

<!-- update video link. Previous iteration: [](youtube:XnE1yw2k5IU) -->

### Objectives
Learn how to:
- Use APEX and PGQL to query, analyze, and visualize a graph.

### Prerequisites
This lab assumes:
- The graph user exists
- You have logged into APEX
- The graph bank_graph exists

*See Lab \_\_ for instructions to complete these prerequisites.*

### Tables are
| Name | Null? | Type |
| ------- |:--------:| --------------:|
| ACCT_ID | NOT NULL | NUMBER|
| NAME |  | VARCHAR2(4000) |
| BALANCE |  | NUMBER |
{: title="ACCOUNTS"}

| Name | Null? | Type |
| ------- |:--------:| --------------:|
| TXN_ID | NOT NULL | NUMBER|
| SRC\_ACCT\_ID |  | NUMBER |
| DST\_ACCT\_ID |  | NUMBER |
| DESCRIPTION |  | VARCHAR2(4000) |
| AMOUNT |  | NUMBER |
{: title="TRANSFERS"}

## Task 1 : Define a graph view on these tables

1. Go to this URL to access SQL developer: 

    ```
    <copy>
    http://localhost:8080/ords/sql-developer
    </copy>
    ```

    Use the following SQL statement to create a graph using the ACCOUNTS table as vertex elements and the TRANSFERS table as edge elements. <!-- edit above text as needed -HF -->
    ```
    <copy>
    CREATE PROPERTY GRAPH BANK_TRANSFERS
      VERTEX TABLES (
        ACCOUNTS
        PROPERTIES (ACCT_ID, BALANCE)
      )
      EDGE TABLES (
        TRANSFERS
        SOURCE KEY (SRC_ACCT_ID) REFERENCES ACCOUNTS(ACCT_ID)
        DESTINATION KEY (DST_ACCT_ID) REFERENCES ACCOUNTS(ACCT_ID)
        PROPERTIES (AMOUNT)
      )
    ;
    </copy>
    ```

2. You can check the metadata views to list the graph, its elements, their labels, and their properties. 

    First we will be listing the graphs, but there is only one property graph we have created, so BANK_TRANSFERS will be the only entry.
    ```
    <copy>
    select * from user_property_graphs;
    </copy>
    ```
    Here you can look at the elements of the BANK_TRANSFERS graph (i.e. its vertices and edges).
    ```
    <copy>
    select * from user_pg_elements
    where graph_name='BANK_TRANSFERS';
    </copy>
    ```
    These are the labels used in the graph.
    ```
    <copy>
    select * from user_pg_labels
    where graph_name='BANK_TRANSFERS';
    </copy>
    ```

    Get the properties associated with the labels.
    ```
    <copy>
    select * from user_pg_label_properties where graph_name='BANK_TRANSFERS';

    select label_name, property_name, data_type from user_pg_label_properties
    where graph_name='BANK_TRANSFERS' order by label_name;
    </copy>
    ```

## Task 2 : Query a transfer sequence
A common query in analyzing money flows is to see if there are a sequence of transfers that connect one source account to a destination account. We'll be demonstrating that sequence of transfers in standard SQL.

1. Let's start by finding which accounts have the most incoming transfers.
    ```
    <copy>
    Select acct_id, count(1) as Num_Deposits
    from graph_table (bank_transfers
    match (src) - [is TRANSFERS] -> (dst)
    Columns (dst.acct_id as acct_id)) 
    group by acct_id 
    order by Num_Deposits desc
    Fetch first 10 rows only;
    </copy>
    ```

    How many transferred money into account 387?
    ```
    <copy>
    select count(distinct acct_id)
    from graph_table (bank_transfers
    match (src) - [is TRANSFERS] -> (dst)
    where dst.acct_id = 387
    columns (src.acct_id as acct_id)
    );
    </copy>
    ```

    You can see that 39 distinct accounts have deposited money into account 387 - the most distinct incoming transfers out of this entire dataset.

    To view with traditional SQL, use the following code.
    ```
    <copy>
    select count(distinct src_acct_id) from transfers where dst_acct_id = 387;
    </copy>
    ```


    How many accounts transferred into 387 via 2 hops?
    ```
    <copy>
    select count(distinct a.src_acct_id) from transfers a, transfers b
    where b.dst_acct_id=387 and a.dst_acct_id = b.src_acct_id;
    </copy>
    ```

    Now we see that 209 accounts are linked to account ID 387 by two hops. 

    What about the case of either 2 or 3 hops?
    ```
    <copy>
    Select count(1) from
    (
    select a.src_acct_id as acct_id from transfers a, transfers b
    where b.dst_acct_id=387 and a.dst_acct_id = b.src_acct_id
    Union
    select a.src_acct_id as acct_id from transfers a, transfers b, transfers c
    where c.dst_acct_id=387 and a.dst_acct_id = b.src_acct_id
    and b.dst_acct_id = c.src_acct_id
    );
    </copy>
    ```

    The result is that 731 accounts are linked with account ID 387, which is an extremely high rate of association. This is quite unusual. 

    You might have also noticed that as we search for longer chains on the graph, aka paths with more hops, we added another join each time. This is manageable for now when we're looking for 1, 2 or 3 hops. But as you can imagine, many graphs in real life consist of a ton more nodes and there would be use cases to look for much longer paths than 3 hops.

    This can become unideal when writing in SQL. In our next section, we'll be introducing the same queries but in Property Graph Query Language (PGQL).

    
2. So as we just mentioned, you can create more compact queries using graphs.

    How many accounts transferred money into 387 in 2 or 3 hops?
    ```
    <copy>
    select count(distinct acct_id) from graph_table (bank_transfers
    match (src) - [is TRANSFERS]-> {2,3} (dst)
    where dst.acct_id = 387
    columns (src.acct_id as acct_id));
    </copy>
    ```

    What about 4 to 5 hops?
    ```
    <copy>
    select count(distinct acct_id) from graph_table (bank_transfers
    match (src) - [is TRANSFERS]-> {4,5} (dst)
    where dst.acct_id = 387
    columns (src.acct_id as acct_id));
    </copy>
    ```

    As you can see, though we are looking for longer lengths on the chain, there is no additional lines of code that need to be written.


3. Another common query is to look for cycles (sequences of transfers that start and end at the same account) of length 3 or more. 

  Are there any circular transfers of length 4 or 5?
    ```
    <copy>
    select count(distinct acct_id) from graph_table (bank_transfers
    match (src) - [is TRANSFERS]-> {4,5} (dst)
    where dst.acct_id = src.acct_id
    columns (src.acct_id as acct_id));
    </copy>
    ```

  List the top 10 accounts by the number of circular transfers.
    ```
    <copy>
    select acct_id, count(1) as Num_Cycles from graph_table (bank_transfers
    match (src) - [is TRANSFERS]-> {4,5} (dst)
    where dst.acct_id = src.acct_id
    columns (src.acct_id as acct_id))
    Group by acct_id order by Num_Cycles desc fetch first 10 rows only;
    </copy>
    ```

    The higher the number of circular payment chains that start and end with the same account, the more suspicious it is.


4. Lets look at 3-hop cycles for some of these top accounts.
  Are there any 3-hop cycles for account 387?
    ```
  <copy>
  select count(1) as Num_3hop_Cycles from graph_table (bank_transfers
  match (src) - [is TRANSFERS]-> {3} (dst)
  where dst.acct_id = 387 and src.acct_id=387
  columns (1 as dummy));
  </copy>
    ```

  Is there a 3 hop transfer between 387 and 934?
    ```
  <copy>
  select count(1) as Num_3hop_transfers
  from graph_table (bank_transfers
  match (src) - [is TRANSFERS]-> {3} (dst)
  where src.acct_id = 387 and dst.acct_id=934
  columns (1 as dummy));
  </copy>
    ```

  List the accounts in the 3 hop transfer between 387 and 934.
    ```
  <copy>
  select start_acct, first_acct, second_acct, dest_acct
  from graph_table (bank_transfers
  match
  (src) - [is TRANSFERS]-> (f)
  - [is TRANSFERS]-> (s)
  - [is TRANSFERS]-> (dst)
  where src.acct_id = 387 and dst.acct_id=934
  columns (
  src.acct_id as start_Acct,
  f.acct_id as first_Acct,
  s.acct_id as second_Acct,
  dst.acct_id as dest_acct)
  );
  </copy>
    ```

5. Let's consider longer hop cycles.
    What about 4 or 5 hop cycles?
    ```
  <copy>
  select count(1) as Num_4or5_hop_Cycles from graph_table (bank_transfers
  match (src) - [is TRANSFERS]-> {4,5} (dst)
  where dst.acct_id = 387 and src.acct_id=387
  columns (1 as dummy));
  </copy>
    ```

  Are there any 6, 7, or 8 hop cycles?
    ```
  <copy>
  select count(distinct acct_id)  from graph_table (bank_transfers
  match (src) - [is TRANSFERS]-> {6} (dst)
  where dst.acct_id = src.acct_id
  columns (src.acct_id as acct_id));
  select count(distinct acct_id)  from graph_table (bank_transfers
  match (src) - [is TRANSFERS]-> {7} (dst)
  where dst.acct_id = src.acct_id
  columns (src.acct_id as acct_id));
  select count(distinct acct_id)  from graph_table (bank_transfers
  match (src) - [is TRANSFERS]-> {8} (dst)
  where dst.acct_id = src.acct_id
  columns (src.acct_id as acct_id));
  </copy>
    ```

  List the accounts in a 6 hop cycle starting from acct 39.
    ```
  <copy>
  select start_acct, first_acct, second_acct, third_acct,
  fourth_acct, fifth_acct, start_acct
  from graph_table (bank_transfers
  match (src) - [is TRANSFERS]->  (f) - [is TRANSFERS]->  (s)
  - [is TRANSFERS]->  (t) - [is TRANSFERS]->  (fo)
  - [is TRANSFERS]->  (fi)- [is TRANSFERS]->  (src)
  where src.acct_id=39
  columns (
  src.acct_id as start_acct,
  f.acct_id as first_acct,
  s.acct_id as second_acct,
  t.acct_id as third_acct,
  fo.acct_id as fourth_acct,
  fi.acct_id as fifth_acct
  ));
  </copy>
    ```
6. You have now completed this lab.