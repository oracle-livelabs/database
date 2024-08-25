# Exploring SQL Property Graphs and SQL/PGQ in Oracle Database 23ai

## Introduction

Welcome to the "Exploring SQL Property Graphs and SQL/PGQ in Oracle Database 23ai" workshop. In this workshop, you will learn about the new SQL property graph feature and the new SQL/PGQ syntax in Oracle Database 23ai. SQL Property Graphs enable you to define graph structures inside the database, using tables and relationships as graph vertices and edges. This feature simplifies graph data analysis using SQL/PGQ queries.

Estimated Lab Time: 20 minutes

Watch the video below for a walkthrough of the lab.
[Lab walkthrough video](videohub:1_nyvxwdwz)

### Objective:

The objective of this workshop is to show you SQL property graphs and demo their practical use. By the end of this workshop, you will be able to create property graphs, query them using SQL/PGQ, and visualize the relationships within your data.

This lab is just a short overview of the functionality introduced with Property Graphs in Oracle Database 23ai and is meant to give you a small example of what is possible. For more in depth Property Graphs explanations and workshops check out the following labs

* [Graphs in the Oracle Database](https://livelabs.oracle.com/pls/apex/f?p=133:100:105582422382278::::SEARCH:graph)

### Prerequisites:
- Access to Oracle Database 23ai.
- Basic understanding of SQL is helpful.


## Task 1: Lab Setup and Creating Property Graphs  

1. Let's first enhance our customers and ratings datasets. 

    ```
    <copy>
        ALTER TABLE ratings
    ADD review VARCHAR2(20000)
    ANNOTATIONS (description 'customer review of the movie'); 


    INSERT INTO ratings (rating_id, customer_id, movie_id, rating, rating_date, content_policy, review)
    VALUES 
    (10, 3, 2, 5, SYSDATE, 'V.2', 'Hilarious and relatable. A true comedy gem.'),
    (11, 5, 2, 4, SYSDATE, 'V.2', 'Great laughs, though a bit over the top.'),
    (12, 1, 2, 5, SYSDATE, 'V.2', 'Classic teen comedy. Loved it.'),
    (13, 2, 1, 5, SYSDATE, 'V.2', 'Beautiful and quirky, a visual delight.'),
    (14, 4, 1, 4, SYSDATE, 'V.2', 'Wes Anderson at his best, very entertaining.'),
    (15, 6, 1, 3, SYSDATE, 'V.2', 'Visually stunning but not my type.'),
    (16, 1, 1, 5, SYSDATE, 'V.2', 'Loved every moment, a masterpiece.'),
    (17, 7, 1, 5, SYSDATE, 'V.2', 'One of Anderson’s best works.'),
    (18, 5, 3, 4, SYSDATE, 'V.2', 'Funny and clever, loved it.'),
    (19, 6, 4, 5, SYSDATE, 'V.2', 'Dark, funny, and beautifully shot.'),
    (20, 2, 4, 5, SYSDATE, 'V.2', 'An unforgettable dark comedy.'),
    (21, 4, 5, 5, SYSDATE, 'V.2', 'A hilarious and sharp look at high school.'),
    (22, 7, 5, 4, SYSDATE, 'V.2', 'Very funny, but also insightful.'),
    (23, 1, 5, 4, SYSDATE, 'V.2', 'A fun and memorable teen movie.'),
    (24, 2, 5, 5, SYSDATE, 'V.2', 'One of the best teen comedies ever.'),
    (25, 3, 5, 5, SYSDATE, 'V.2', 'Loved it, so funny and relatable.'),
    (26, 1, 6, 5, SYSDATE, 'V.2', 'Step Brothers is an absolutely hilarious movie! The chemistry between Will Ferrell and John C. Reilly is unmatched, and their antics keep you laughing throughout. It’s a comedy that’s not afraid to be absurd, and it pays off with some of the funniest scenes I’ve ever watched. Definitely a must-see for comedy fans.'),
    (27, 1, 7, 4, SYSDATE, 'V.2', 'Anchorman is a comedy classic that never gets old. Will Ferrell as Ron Burgundy is iconic, and the movie’s take on the 1970s news scene is both satirical and laugh-out-loud funny. While some jokes are a bit dated, it’s still a great watch for its memorable characters and quotable lines.'),
    (28, 1, 8, 5, SYSDATE, 'V.2', 'No Country for Old Men is a masterpiece of tension and suspense. The Coen Brothers crafted a film that’s as haunting as it is thrilling, with Javier Bardem delivering one of the most chilling performances as Anton Chigurh. This movie stays with you long after the credits roll, a true modern classic.'),
    (29, 1, 9, 5, SYSDATE, 'V.2', 'The Big Lebowski is one of those movies that you can watch over and over again and still find something new to enjoy. The Dude is an unforgettable character, and the film’s unique blend of humor and quirkiness makes it stand out in the best possible way. A cult classic for a reason!'),
    (30, 1, 10, 5, SYSDATE, 'V.2', 'Memento is a brilliant, mind-bending thriller that keeps you hooked from start to finish. Christopher Nolan’s storytelling is top-notch, and the reverse chronology adds a layer of complexity that perfectly mirrors the protagonist’s fractured memory. A must-watch for anyone who loves a good psychological thriller.');

    CREATE TABLE family_accounts (
    family_account_id NUMBER PRIMARY KEY,
    customer_id_1 NUMBER,
    customer_id_2 NUMBER,
    family_account_date DATE DEFAULT SYSDATE
    );

        INSERT INTO family_accounts (family_account_id, customer_id_1, customer_id_2, family_account_date)
    VALUES
    (1, 1, 2, SYSDATE),
    (2, 1, 3, SYSDATE),
    (3, 2, 4, SYSDATE),
    (4, 3, 5, SYSDATE),
    (5, 4, 6, SYSDATE),
    (6, 5, 7, SYSDATE),
    (7, 6, 1, SYSDATE),
    (8, 7, 2, SYSDATE);


    </copy>
    ```
  

1. Property graphs give you a different way of looking at your data. With Property Graphs you model data with edges and nodes. Edges represent the relationships that exist between our nodes (also called vertices). 

    In Oracle Database 23ai we can create property graphs inside the database. These property graphs allow us to map the vertices and edges to new or existing tables, external tables, materialized views or synonyms to these objects inside the database. 
    
    The property graphs are stored as metadata inside the database meaning they don't store the actual data. Rather, the data is still stored in the underlying objects and we use the SQL/PQG syntax to interact with the property graphs.

    "Why not do this in SQL?" The short answer is, you can. However, it may not be simple. Modeling graphs inside the database using SQL can be difficult and cumbersome and could require complex SQL code to accurately represent and query all aspects of a graph.

    This is where property graphs come in. Property graphs make the process of working with interconnected data, like identifying influencers in a social network, predicting trends and customer behavior, discovering relationships based on pattern matching and more by providing a more natural and efficient way to model and query them. Let's take a look at how to create property graphs and query them using the SQL/PGQ extension.

2. We'll first create a property graph that models the relationship between customers, movies and their ratings / reviews (our tables created earlier).

    ```
    <copy>
        
    DROP PROPERTY GRAPH IF EXISTS moviestreams_pg;

    CREATE PROPERTY GRAPH moviestreams_pg
        VERTEX TABLES (
            customers
            KEY (customer_id)
            LABEL customer
            PROPERTIES ALL COLUMNS,

            movies
            KEY (movie_id)
            LABEL movie
            PROPERTIES ALL COLUMNS
        )
        EDGE TABLES (
            ratings
            KEY (rating_id)
            SOURCE KEY (customer_id) REFERENCES customers (customer_id)
            DESTINATION KEY (movie_id) REFERENCES movies (movie_id)
            LABEL ratings
            PROPERTIES ALL COLUMNS,

            family_accounts
            KEY (family_account_id)
            SOURCE KEY (customer_id_1) REFERENCES customers (customer_id)
            DESTINATION KEY (customer_id_2) REFERENCES customers (customer_id)
            LABEL family_account
            PROPERTIES ALL COLUMNS
        );
    </copy>
    ```

    A couple things to point out here:
    * Customers are labeled as vertices.
	* Movies are labeled as vertices.
	* Reviews are edges that connect customers to movies.



## Task 2: Querying Property Graphs with SQL/PGQ

1. Now we can use SQL/PQG to query and work with property graphs. We'll use the GRAPH_TABLE operator here to display movies reviewed by a specific person.

    ```
    <copy>
        
    SELECT email, review, movie_title
    FROM graph_table (moviestreams_pg
            MATCH
            (c IS customer WHERE c.email = 'jim.brown@example.com') -[r IS ratings]-> (m IS movie)
            COLUMNS (c.email AS email, r.review, m.title AS movie_title)
        );

    </copy>
    ```


2. We can figure out which of our movies are highest rated.

    ```
    <copy>
        
    SELECT movie_title, AVG(rating) AS avg_rating
    FROM graph_table (
        moviestreams_pg
        MATCH (c IS customer) -[r IS ratings]-> (m IS movie)
        COLUMNS (
            m.title AS movie_title,
            r.rating AS rating
        )
    )
    GROUP BY movie_title
    HAVING AVG(rating) >= 4
    ORDER BY avg_rating DESC;

    </copy>
    ```


3. We can also find the customers with the highest “influence” within a specific graph of movie ratings and family connections. A customer is considered more “influential” if they are frequently connected to other customers through shared movie ratings and family account relationships.
    ```
    <copy>
        
    SELECT email, COUNT(*) AS influence_score
    FROM graph_table (
        moviestreams_pg
        MATCH (c1 IS customer) -[r1 IS ratings]-> (m IS movie) <-[r2 IS ratings]- (c2 IS customer),
            (c1) -[f IS family_account]-> (c2)
        COLUMNS (
            c1.email AS email
        )
    )
    GROUP BY email
    ORDER BY influence_score DESC;
    </copy>
    ```

4. We can also look the graphs available for our current user    

    ```
    <copy>
    SELECT * FROM user_property_graphs;
    </copy>
    ```


4. In this short lab we've looked at SQL property graphs and SQL/PGQ in Oracle Database 23ai. We've learned how to create property graphs from existing tables, query these graphs to discover relationships, and prepare data for visualization. 

    This is just a small sample of what you can do with Property Graphs and SQL/PQG in Oracle Database 23ai. For more in depth labs and other graph functionality, brows through the following link
    * [Graphs in 23ai](https://livelabs.oracle.com/pls/apex/f?p=133:100:105582422382278::::SEARCH:graph)


You may now **proceed to the next lab** 

## Learn More

* [Graph Developer's Guide for Property Graph](https://docs.oracle.com/en/database/oracle/property-graph/24.2/spgdg/index.html)
* [New! Discover connections with SQL Property Graphs](https://blogs.oracle.com/database/post/sql-property-graphs-in-oracle-autonomous-database)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors** 
* **Last Updated By/Date** - Killian Lynch, April 2024
