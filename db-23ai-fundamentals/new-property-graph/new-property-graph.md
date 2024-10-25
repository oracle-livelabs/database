# Exploring SQL Property Graphs and SQL/PGQ in Oracle Database 23ai

## Introduction

Welcome to the "Exploring SQL Property Graphs and SQL/PGQ in Oracle Database 23ai" workshop. In this workshop, you will learn about the new SQL property graph feature, and the new SQL/PGQ syntax in Oracle Database 23ai. SQL Property Graphs enable you to define graph structures inside the database, using tables and relationships as graph vertices and edges. This feature simplifies graph data analysis using SQL/PGQ queries.

Estimated Lab Time: 20 minutes

Watch the video below for a walkthrough of the lab.
[Lab walkthrough video](videohub:1_hxipitm1)

### Objective:

The objective of this workshop is to show you SQL property graphs and demo their practical use. By the end of this workshop, you will be able to create property graphs, query them using SQL/PGQ, and visualize the relationships within your data.

This lab is just a short overview of the functionality introduced with Property Graphs in Oracle Database 23ai and is meant to give you a small example of what is possible. For more in depth Property Graphs explanations and workshops check out the following labs

* [Graphs in the Oracle Database](https://livelabs.oracle.com/pls/apex/f?p=133:100:105582422382278::::SEARCH:graph)

### Prerequisites:
- Access to Oracle Database 23ai.
- Basic understanding of SQL is helpful.


## Task 1: Lab Setup

1. If you haven't done so already, from the Autonomous Database home page, **click** Database action and then **click** SQL.

    ![click SQL](images/im1.png =50%x*)

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](images/simple-db-actions.png =50%x*)

3. Here we can go ahead and create our user for this lab. We'll call our user `DB23AI` and grant the user the new developer role and the graph developer role.

    ```
    <copy>
  -- USER SQL
  CREATE USER DB23AI IDENTIFIED BY Oracledb_4U#;

  -- ADD ROLES
  GRANT DB_DEVELOPER_ROLE TO DB23AI;

  GRANT CONNECT TO DB23AI;
  GRANT RESOURCE TO DB23AI;
  GRANT CONSOLE_DEVELOPER TO DB23AI;
  GRANT GRAPH_DEVELOPER TO DB23AI;


  -- REST ENABLE
  BEGIN
      ORDS_ADMIN.ENABLE_SCHEMA(
          p_enabled => TRUE,
          p_schema => 'DB23AI',
          p_url_mapping_type => 'BASE_PATH',
          p_url_mapping_pattern => 'db23ai',
          p_auto_rest_auth=> TRUE
      );
      -- ENABLE DATA SHARING
      C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
              SCHEMA_NAME => 'DB23AI',
              ENABLED => TRUE
      );
      commit;
  END;
  /

  ALTER USER DB23AI DEFAULT ROLE CONSOLE_DEVELOPER,DB_DEVELOPER_ROLE,GRAPH_DEVELOPER;
  ALTER USER DB23AI GRANT CONNECT THROUGH GRAPH$PROXY_USER;

  -- QUOTA
  ALTER USER DB23AI QUOTA UNLIMITED ON DATA;

    </copy>
    ```
4. Let's sign in as our new user. Click on the admin profile in the top right hand of Database Actions and sign out.

  ![log out of our admin user](images/im12.png " ")

5. Sign in with the username **DB23AI** and password **Oracledb_4U#**

    ![sign in with db23ai](images/im19.png =50%x*)

6. Click SQL to open the SQL editor.

  ![Open SQL with db23ai](images/im20.png " ")

7. Lets create some tables for our demo. We'll create a people and relationship table which will be our vertices (people) and edges (relationship) of the graph. 

    ```
    <copy>

    drop table if exists people cascade CONSTRAINTS;
    drop table if exists relationship cascade CONSTRAINTS;

    CREATE TABLE people (
        p_id NUMBER PRIMARY KEY,
        name VARCHAR2(50)
    );

    INSERT INTO people (p_id, name) VALUES 
        (1, 'Alice'), 
        (2, 'Bob'), 
        (3, 'Carol'), 
        (4, 'Dave'), 
        (5, 'Eve');

    CREATE TABLE relationship (
        r_id NUMBER PRIMARY KEY,
        source_id NUMBER,
        target_id NUMBER,
        relationship VARCHAR2(50),
        CONSTRAINT connections_people_1_fk FOREIGN KEY (source_id) REFERENCES people (p_id),
        CONSTRAINT connections_people_2_fk FOREIGN KEY (target_id) REFERENCES people (p_id)
    );

    INSERT INTO relationship (r_id, source_id, target_id, relationship) 
    VALUES 
        (1, 1, 2, 'friend'),
        (2, 2, 3, 'colleague'),
        (3, 3, 4, 'neighbor'),
        (4, 4, 1, 'sibling'),
        (5, 1, 3, 'mentor');

    </copy>
    ```
    ![create the data](images/im2.png =50%x*)


## Task 2: Creating Property Graphs  

1. Property graphs give you a different way of looking at your data. With Property Graphs you model data with edges and nodes. Edges represent the relationships that exist between our nodes (also called vertices). 

    In Oracle Database 23ai we can create property graphs inside the database. These property graphs allow us to map the vertices and edges to new or existing tables, external tables, materialized views or synonyms to these objects inside the database. 
    
    The property graphs are stored as metadata inside the database meaning they don't store the actual data. Rather, the data is still stored in the underlying objects and we use the SQL/PQG syntax to interact with the property graphs.

    "Why not do this in SQL?" Short answer is, you can. However, it may not be simple. Modeling graphs inside the database using SQL can be difficult and cumbersome and could require complex SQL code to accurately represent and query all aspects of a graph.

    This is where property graphs come in. Property graphs make the process of working with interconnected data, like identifying influencers in a social network, predicting trends and customer behavior, discovering relationships based on pattern matching and more by providing a more natural and efficient way to model and query them. Let's take a look at how to create property graphs and query them using the SQL/PGQ extension.

2. We'll first create a property graph that models the relationship between people (our tables created earlier).

    ```
    <copy>
        
    drop property graph if exists relationships_pg;

    CREATE PROPERTY GRAPH relationships_pg
        VERTEX TABLES (
            people
            KEY (p_id)
            LABEL person
            PROPERTIES ALL COLUMNS
        )
        EDGE TABLES (
            relationship
            KEY (r_id)
            SOURCE KEY (source_id) REFERENCES people (p_id)
            DESTINATION KEY (target_id) REFERENCES people (p_id)
            LABEL relationship
            PROPERTIES ALL COLUMNS
        );

    </copy>
    ```

    A couple things to point out here:
    * Vertex represent our people table
    * Edges represent how they are connected (relationship table)
    * Our edges table has a source key and destination key, representing the connection between the two people

    ![create the property graph](images/im3.png =50%x*)


## Task 3: Discovering Graph Studio

1. Now we're going to take a look at Graph Studio. Click the hamburger menu and then select Graph Studio.

    ![Updating the our customers view](images/im7.png " ")

2. Login with our db23ai user credentials.

    Username: db23ai
    Password: Oracledb_4U#

    ![Updating the our customers view](images/im8.png " ")

3. Inside Graph Studio, click on Notebooks.

    ![Updating the our customers view](images/im9.png " ")

4. Select **Create** in the upper right hand corner.

    ![Updating the our customers view](images/im10.png " ")

5. Give your notebook a name. I'll go with **cust_graph**

    ![Updating the our customers view](images/im11.png " ")

6. If the compute environment pops up, click close in the bottom right corner. 
    ![Updating the our customers view](images/im13.png " ")

7. Since we haven't set up the compute server, and don't need it for this lab, you may get an error saying it wasn't able to create. Close these messages.
    ![Updating the our customers view](images/im14.png " ")


8. Hover over the middle of the textbox and click add SQL Paragraph. See the gif below for an example

    ![Updating the our customers view](images/im12.gif " ")


9. We can now query this graph using the new SQL/PGQ extension in Oracle Database 23ai. The following query looks for customers, starting at the vertices 'Jim Brown' and then his friends (directional) within 1 to 3 hops. The important step here is the match clause which allows us to define the nodes we are looking for in our graph. We indicate we are starting from V1. We then apply a filter to, select Jim Brown. We tell it to traverse the graph in a single direction with -> navigating all edges that are marked friends from 1 to 3 hops. We finally tell the query to return the paths for the hops that match the query.

    Paste the following and click the run query button

    **Keep the %sql at the top of each SQL paragraph in the notebook**

    ```
    <copy>
    select distinct
    full_names,
    cust_id
    from graph_table(moviestreams_pg
                match
                (v1 is customer) ( -[e is related where e.relationship = 'Friend']-> (v2 is customer where v2.first_name != 'Jim')) {1,3}
                where v1.first_name = 'Jim' and v1.last_name = 'Brown'
                columns (LISTAGG(v2.first_name ||' '|| v2.last_name, ', ') as full_names,
                            LISTAGG(v2.customer_id, ', ') as cust_id,
                        v1.first_name ||' '|| v1.last_name as source)
        )
    </copy>
    ```

    ![Updating the our customers view](images/im15.png " ")

8. If we add new customers and relationships they are part of the graph and can be queried instantly. Add the insert statement into the a paragraph and run the query

    ```
    <copy>
    INSERT INTO customers (customer_id, first_name, last_name, email, signup_date, has_sub)
    VALUES
        (9, 'Jwan', 'Brown', 'Jwan.brown@example.com', SYSDATE, TRUE)
    </copy>
    ```

    ![Updating the our customers view](images/im16.png " ")

9. Add the customer relationship into the next cell and run the query.

    ```
    <copy>
    INSERT INTO customer_relationships (SOURCE_ID, TARGET_ID, RELATIONSHIP)
    VALUES
        (9, 7, 'Cousin'),
        (7, 9, 'Cousin')
    </copy>
    ```
    ![Updating the our customers view](images/im17.png " ")


10. We can update the first cell and change Friend to Cousin

    ```
    <copy>
    select distinct
    full_names,
    cust_id
    from graph_table(moviestreams_pg
                match
                (v1 is customer) ( -[e is related where e.relationship = 'Cousin']-> (v2 is customer where v2.first_name != 'Jim')) {1}
                where v1.first_name = 'Jim' and v1.last_name = 'Brown'
                columns (LISTAGG(v2.first_name ||' '|| v2.last_name, ', ') as full_names,
                            LISTAGG(v2.customer_id, ', ') as cust_id,
                        v1.first_name ||' '|| v1.last_name as source)
        )
    </copy>
    ```
    ![Updating the our customers view](images/im18.png " ")


11. Navigate back to SQL Developer Web by switching your browser tabs.


12. In this short lab we've looked at SQL property graphs and SQL/PGQ in Oracle Database 23ai. We've learned how to create property graphs from existing tables, query these graphs to discover relationships, and prepare data for visualization. 


## Task 3: Querying Property Graphs with SQL/PGQ

1. Now we can use SQL/PQG to query and work with our property graphs. We'll use the GRAPH_TABLE operator here to display people who are connected to each other.

    ```
    <copy>
        
    SELECT person_1, relationship, person_2
    FROM   graph_table (relationships_pg
            MATCH
            (p1 IS person) -[r IS relationship]-> (p2 IS person)
            COLUMNS (p1.name AS person_1, r.relationship, p2.name AS person_2)
        );

    </copy>
    ```

    ![use sql/pgq to query the graph](images/im4.png =50%x*)

2. We can filter our results like we can in SQL.

    ```
    <copy>
        
    SELECT person_1, relationship, person_2
    FROM   graph_table (relationships_pg
            MATCH
            (p1 IS person WHERE p1.name = 'Alice') -[r IS relationship]-> (p2 IS person)
            COLUMNS (p1.name AS person_1, r.relationship, p2.name AS person_2)
        );

    </copy>
    ```

    ![use sql/pgq to select a person from the graph](images/im5.png " ")

3. We can also check the metadata about our graph
    ```
    <copy>
        
    SELECT person_1, relationship, person_2, id_person_1, id_relationship, id_person_2
    FROM   graph_table (relationships_pg
            MATCH
            (p1 IS person) -[r IS relationship]-> (p2 IS person)
            COLUMNS (p1.name AS person_1,
                    p2.name AS person_2,
                    r.relationship AS relationship,
                    vertex_id(p1) AS id_person_1,
                    edge_id(r) AS id_relationship,
                    vertex_id(p2) AS id_person_2)
        );

    </copy>
    ```
    ![check graph metadata using sql/pgq](images/im6.png " ")


4. In this short lab we've looked at SQL property graphs and SQL/PGQ in Oracle Database 23ai. We've learned how to create property graphs from existing tables, query these graphs to discover relationships, and prepare data for visualization. 

    This is just a small sample of what you can do with Property Graphs and SQL/PQG in Oracle Database 23ai. For more in depth labs and other graph functionality, brows through the following link
    * [Graphs in 23ai](https://livelabs.oracle.com/pls/apex/f?p=133:100:105582422382278::::SEARCH:graph)

5. We can clean our environment.
    ```
    <copy>
    drop table people cascade CONSTRAINTS;
    drop table relationship cascade CONSTRAINTS;
    drop property graph relationships_pg;
    </copy>
    ```

You may now **proceed to the next lab** 

## Learn More

* [Graph Developer's Guide for Property Graph](https://docs.oracle.com/en/database/oracle/property-graph/24.2/spgdg/index.html)
* [New! Discover connections with SQL Property Graphs](https://blogs.oracle.com/database/post/sql-property-graphs-in-oracle-autonomous-database)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors** - Dom Giles, Distinguished Database Product Manager
* **Last Updated By/Date** - Killian Lynch, April 2024
