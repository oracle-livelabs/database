# Lab: In-Database Graph Algorithms in Oracle AI Database 26ai

## Introduction

SQL property graphs arrived in Oracle Database 23ai, letting you model and query connected data with the SQL/PGQ standard. But classic graph analytics like, "who is the most influential node?", "how many separate communities exist?" still meant exporting your graph to a separate graph server... Until now!

Oracle AI Database 26ai (23.26.2) closes that gap with the `DBMS_OGA` package (Oracle Graph Algorithms). PageRank, community detection, and shortest-path algorithms now run directly inside the database, and you read their results with the same GRAPH_TABLE operator you already use for graph queries. No graph server, no data movement.

Why does it matter?
- Graph analytics run where the data lives, inside your existing SQL
- Algorithm results are just columns! join them, filter them, GROUP BY them
- The algorithms see live, committed table data. That means no export step to go stale

In this lab, you'll build a social network as a SQL property graph and used the full set of DBMS_OGA algorithms to answer different questions about it. PageRank will find the most influential people, Personalized PageRank will show who mattered from one person's or group's point of view, Bellman-Ford will find the lowest-cost introductions from Zara, and WCC will identify separate communities and showed how one new follow could connect them. Each of these algos run inside the database.

Estimated Lab Time: 20 minutes

### Objectives

In this lab you will:

- Create a SQL property graph over relational tables
- Query graph patterns with GRAPH_TABLE and MATCH
- Rank influence with the PageRank algorithm using `DBMS_OGA`
- Personalize influence scores for one person and for a group
- Find the lowest-cost connections with Bellman-Ford
- Detect communities with Weakly Connected Components (WCC) and watch them merge

### Prerequisites

- Access to Oracle AI Database 26ai (23.26.2 or later)
- Basic understanding of SQL; the Property Graphs lab in this workshop is a helpful warm-up

## Task 1: Build the Social Network

Let's say you're modeling a small social app where people follow other people. Five food bloggers follow each other, and three gamers follow each other.

1. Create the people and follows tables and turn them into a property graph.

    ```sql
    <copy>
    DROP PROPERTY GRAPH IF EXISTS social_network;
    DROP TABLE IF EXISTS sn_follows CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS sn_people CASCADE CONSTRAINTS;

    CREATE TABLE sn_people (
        person_id NUMBER PRIMARY KEY,
        name      VARCHAR2(50) NOT NULL,
        interest  VARCHAR2(30) NOT NULL
    );

    CREATE TABLE sn_follows (
        follow_id  NUMBER PRIMARY KEY,
        source_id  NUMBER NOT NULL REFERENCES sn_people,
        target_id  NUMBER NOT NULL REFERENCES sn_people,
        intro_cost NUMBER NOT NULL
    );

    INSERT INTO sn_people VALUES
        (1, 'Maya',  'Food blogging'),
        (2, 'Liam',  'Food blogging'),
        (3, 'Sofia', 'Food blogging'),
        (4, 'Noah',  'Food blogging'),
        (5, 'Zara',  'Food blogging'),
        (6, 'Owen',  'Gaming'),
        (7, 'Ivy',   'Gaming'),
        (8, 'Felix', 'Gaming');

    INSERT INTO sn_follows VALUES
        (1,  2, 1, 1),
        (2,  3, 1, 1),
        (3,  4, 1, 1),
        (4,  5, 1, 5),
        (5,  1, 3, 1),
        (6,  3, 2, 1),
        (7,  4, 2, 1),
        (8,  5, 4, 1),
        (9,  2, 3, 1),
        (10, 6, 7, 1),
        (11, 7, 6, 1),
        (12, 8, 7, 1);

    COMMIT;

    CREATE PROPERTY GRAPH social_network
      VERTEX TABLES (
        sn_people KEY (person_id) PROPERTIES (person_id, name, interest)
      )
      EDGE TABLES (
        sn_follows KEY (follow_id)
          SOURCE KEY (source_id) REFERENCES sn_people (person_id)
          DESTINATION KEY (target_id) REFERENCES sn_people (person_id)
          PROPERTIES (intro_cost)
      );
    </copy>
    ```

    **What you should see:**
    - 8 people, 12 follow relationships, and a property graph named `social_network`
    - The graph is just metadata over your tables - no data is copied

2. Let's first try a pattern match: who follows whom?

    ```sql
    <copy>
    SELECT follower, followed
    FROM GRAPH_TABLE(
      social_network
      MATCH (a IS sn_people) -[IS sn_follows]-> (b IS sn_people)
      COLUMNS (a.name AS follower, b.name AS followed)
    )
    ORDER BY follower, followed;
    </copy>
    ```

    **What you should see:**
    - 12 rows, one per follow edge
    - Notice the bloggers (Maya, Liam, Sofia, Noah, Zara) and gamers (Owen, Ivy, Felix) only follow within their own group

## Task 2: Find the Influencers with PageRank

PageRank (the algo behind early Google) scores each node by how many important nodes point at it. In a social network, that's called influence.

1. Run PageRank and read the results in one statement. `DBMS_OGA.PAGERANK` wraps the graph and adds a new vertex property (here named `influence`) that GRAPH_TABLE can read like any other column.

    ```sql
    <copy>
    SELECT name, ROUND(influence, 4) AS influence
    FROM GRAPH_TABLE(
      DBMS_OGA.PAGERANK(
        social_network,
        PROPERTY(VERTEX OUTPUT influence),
        100, 1e-6, 0.85d, TRUE
      )
      MATCH (p IS sn_people)
      COLUMNS (p.name, p.influence)
    )
    ORDER BY influence DESC;
    </copy>
    ```

    **What you should see:**

    | NAME | INFLUENCE |
    | --- | --- |
    | Sofia | 0.2455 |
    | Maya | 0.1996 |
    | Ivy | 0.1824 |
    | Owen | 0.1738 |
    | Liam | 0.1345 |
    | Noah | 0.0267 |
    | Zara | 0.0188 |
    | Felix | 0.0188 |

    - Remember our table? Maya had more followers than Sofia, but Sofia is followed by the two most connected bloggers, and PageRank weighs *who* follows you, not just how many
    - The four arguments after the output property are: maximum iterations (100), convergence tolerance (1e-6), damping factor (0.85), and whether to normalize scores so they sum to 1 (TRUE). These settings control how PageRank settles on each person's influence score. It keeps passing influence through the follow network until the numbers stop meaningfully changing, then expresses each score as a share of the total influence.
        - `100` lets PageRank recalculate scores for up to 100 rounds. It usually finishes sooner.
        - `1e-6` tells it to stop once the score changes are tiny, so the results have effectively settled.
        - `0.85d` means 85% of a person's influence comes through follow relationships, while 15% is a small baseline shared across everyone. This keeps influence flowing even in loops or isolated parts of the graph.
        - `TRUE` scales the final scores so they add up to `1` (100%), making them easy to compare.

## Task 3: Personalize PageRank for One Person

Regular PageRank asks who is important to the whole network. Personalized PageRank asks a more focused question: who is important from one person's position in the network?

Let's personalize the results for Felix. Felix follows Ivy, so influence flows from Felix to Ivy and then around the gaming community.

1. Get Felix's graph vertex ID. Graph algorithms identify a starting vertex with JSON rather than just a relational key because a property graph can contain several vertex tables.

    ```sql
    <copy>
    SELECT vertex_id
    FROM GRAPH_TABLE(
      social_network
      MATCH (p IS sn_people)
      WHERE p.name = 'Felix'
      COLUMNS (VERTEX_ID(p) AS vertex_id)
    );
    </copy>
    ```

    **What you should see:**

    ```json
    {"GRAPH_OWNER":"YOUR_SCHEMA","GRAPH_NAME":"SOCIAL_NETWORK","ELEM_TABLE":"SN_PEOPLE","KEY_VALUE":{"PERSON_ID":8}}
    ```

    - Copy the entire JSON value from your result without changing it

2. Paste Felix's vertex ID into `JSON('...')`, replacing the sample JSON below, and run Personalized PageRank.

    ```sql
    <copy>
    SELECT name, ROUND(personalized_influence, 4) AS personalized_influence
    FROM GRAPH_TABLE(
      DBMS_OGA.PERSONALIZED_PAGERANK(
        social_network,
        PROPERTY(VERTEX OUTPUT personalized_influence),
        JSON('PASTE IT HERE'),
        100, 1e-6, 0.85d, TRUE
      )
      MATCH (p IS sn_people)
      COLUMNS (p.name, p.personalized_influence)
    )
    ORDER BY personalized_influence DESC, name;
    </copy>
    ```

    ![pagerank lab 3](./images/page-rank.gif =85%x*)


    **What you should see:**

    | NAME | PERSONALIZED_INFLUENCE |
    | --- | --- |
    | Ivy | 0.4595 |
    | Owen | 0.3905 |
    | Felix | 0.1500 |
    | Liam | 0.0000 |
    | Maya | 0.0000 |
    | Noah | 0.0000 |
    | Sofia | 0.0000 |
    | Zara | 0.0000 |

    - Ivy now ranks first because she is the person Felix follows
    - The food bloggers score zero because no directed follow path leads from Felix's gaming community to their community
    - `100` and `1e-6` control when the calculation stops, just as they did for regular PageRank
    - With `0.85d`, 85% of influence continues through follow relationships while the remaining 15% keeps the calculation anchored at Felix
    - `TRUE` scales the scores so they add up to 1, and Felix's vertex ID tells PageRank where to focus

## Task 4: Personalize PageRank for a Group

You can also personalize PageRank for a set of people. Think of this as asking, "who is relevant to this audience?" Each selected person gets an equal share of the starting preference.

Let's use Maya and Felix as the audience. They place one starting point in each community.

1. Build a JSON array containing both graph vertex IDs.

    ```sql
    <copy>
    SELECT JSON_ARRAYAGG(vertex_id) AS audience_vertices
    FROM GRAPH_TABLE(
      social_network
      MATCH (p IS sn_people)
      WHERE p.name IN ('Maya', 'Felix')
      COLUMNS (VERTEX_ID(p) AS vertex_id)
    );
    </copy>
    ```

    **What you should see:**

    ```json
    [{"GRAPH_OWNER":"YOUR_SCHEMA","GRAPH_NAME":"SOCIAL_NETWORK","ELEM_TABLE":"SN_PEOPLE","KEY_VALUE":{"PERSON_ID":1}},{"GRAPH_OWNER":"YOUR_SCHEMA","GRAPH_NAME":"SOCIAL_NETWORK","ELEM_TABLE":"SN_PEOPLE","KEY_VALUE":{"PERSON_ID":8}}]
    ```

    - The array order may differ, and your `GRAPH_OWNER` value will be different
    - Copy the entire JSON array from your result without changing it

2. Paste the array into `JSON('...')`, replacing the sample array below, and run Personalized PageRank for the set.

    ```sql
    <copy>
    SELECT name, ROUND(group_influence, 4) AS group_influence
    FROM GRAPH_TABLE(
      DBMS_OGA.PERSONALIZED_PAGERANK_SET(
        social_network,
        PROPERTY(VERTEX OUTPUT group_influence),
        JSON('PASTE IT HERE'),
        100, 1e-6, 0.85d, TRUE
      )
      MATCH (p IS sn_people)
      COLUMNS (p.name, p.group_influence)
    )
    ORDER BY group_influence DESC, name;
    </copy>
    ```
    ![pagerank lab 3](./images/page-rank2.gif =85%x*)

    **What you should see:**

    | NAME | GROUP_INFLUENCE |
    | --- | --- |
    | Ivy | 0.2297 |
    | Sofia | 0.2093 |
    | Maya | 0.2018 |
    | Owen | 0.1953 |
    | Liam | 0.0890 |
    | Felix | 0.0750 |
    | Noah | 0.0000 |
    | Zara | 0.0000 |

    - Results now appear in both communities because the audience contains Maya and Felix
    - The starting preference is split equally between the two people. Influence then flows through their outgoing follow relationships, with the calculation repeatedly returning some weight to Maya and Felix
    - Personalized PageRank answers "important to whom?" The single-vertex version focuses on one person; the set version focuses on an audience

## Task 5: Find the Lowest-Cost Introductions with Bellman-Ford

Bellman-Ford finds the lowest-cost route from one starting vertex to every other reachable vertex. A route's total cost is the sum of the edge costs it uses, so the lowest-cost route is not always the most direct one.

Here, `intro_cost` represents how much effort it takes one person to get an introduction to someone they follow. Lower numbers mean easier introductions. These are sample values that we assigned when creating `sn_follows`; they are not calculated by the algorithm.

Remember the row `(4, 5, 1, 5)` from Task 1? Its values are `follow_id = 4`, `source_id = 5` (Zara), `target_id = 1` (Maya), and `intro_cost = 5`. We chose 5 to represent a difficult direct introduction. The connections from Zara to Noah and from Noah to Maya each have a cost of 1, giving that indirect route a total cost of 2.

1. Get Zara's graph vertex ID and copy the entire JSON value.

    ```sql
    <copy>
    SELECT vertex_id
    FROM GRAPH_TABLE(
      social_network
      MATCH (p IS sn_people)
      WHERE p.name = 'Zara'
      COLUMNS (VERTEX_ID(p) AS vertex_id)
    );
    </copy>
    ```

    **What you should see:**

    ```json
    {"GRAPH_OWNER":"YOUR_SCHEMA","GRAPH_NAME":"SOCIAL_NETWORK","ELEM_TABLE":"SN_PEOPLE","KEY_VALUE":{"PERSON_ID":5}}
    ```

2. Paste Zara's vertex ID into `JSON('...')`, replacing the sample JSON below, and run Bellman-Ford.

    ```sql
    <copy>
    SELECT name,
           CASE
             WHEN intro_distance = BINARY_DOUBLE_INFINITY THEN 'Unreachable'
             ELSE TO_CHAR(intro_distance)
           END AS lowest_cost
    FROM GRAPH_TABLE(
      DBMS_OGA.BELLMAN_FORD(
        social_network,
        JSON('{"GRAPH_OWNER":"YOUR_SCHEMA","GRAPH_NAME":"SOCIAL_NETWORK","ELEM_TABLE":"SN_PEOPLE","KEY_VALUE":{"PERSON_ID":5}}'),
        PROPERTY(EDGE INPUT intro_cost),
        PROPERTY(VERTEX OUTPUT intro_distance)
      )
      MATCH (p IS sn_people)
      COLUMNS (p.name, p.intro_distance)
    )
    ORDER BY intro_distance, name;
    </copy>
    ```

    **What you should see:**

    | NAME | LOWEST_COST |
    | --- | --- |
    | Zara | 0 |
    | Noah | 1 |
    | Liam | 2 |
    | Maya | 2 |
    | Sofia | 3 |
    | Felix | Unreachable |
    | Ivy | Unreachable |
    | Owen | Unreachable |

    We are starting with Zara and asking, "What is the lowest total introduction cost from Zara to each person?" The output gives one answer per person. A lower number means that person is easier for Zara to reach, while `Unreachable` means there is no chain of follows from Zara to that person.

    - In our sample data, Zara's direct introduction to Maya was assigned a cost of 5. Going from Zara to Noah and then to Maya costs only 1 + 1 = 2, so Bellman-Ford chooses the lower-cost indirect route
    - The gamers are unreachable because Bellman-Ford follows edge direction, and there is no directed path from Zara's community to theirs
    - `PROPERTY(EDGE INPUT intro_cost)` tells the algorithm which edge property to add along each route
    - `PROPERTY(VERTEX OUTPUT intro_distance)` names the temporary result property
    - Edge costs must be numeric, non-negative, and not `NULL`

## Task 6: Detect Communities with WCC

Weakly Connected Components groups nodes into "islands". These are sets of people connected by any chain of follows, in either direction.

1. How many communities does the network have?

    ```sql
    <copy>
    SELECT community, COUNT(*) AS members, LISTAGG(name, ', ') WITHIN GROUP (ORDER BY name) AS people
    FROM GRAPH_TABLE(
      DBMS_OGA.WCC(
        social_network,
        PROPERTY(VERTEX OUTPUT community)
      )
      MATCH (p IS sn_people)
      COLUMNS (p.name, p.community)
    )
    GROUP BY community
    ORDER BY community;
    </copy>
    ```

    **What you should see:**

    | COMMUNITY | MEMBERS | PEOPLE |
    | --- | --- | --- |
    | 1 | 5 | Liam, Maya, Noah, Sofia, Zara |
    | 6 | 3 | Felix, Ivy, Owen |

    - Two communities: the food bloggers and the gamers


2. Now connect the two scenes: Owen discovers Maya's food blog and follows her. Commit the change - graph algorithms read committed data and raise ORA-40972 if you run them mid-transaction.

    ```sql
    <copy>
    INSERT INTO sn_follows VALUES (13, 6, 1, 1);
    COMMIT;
    </copy>
    ```

3. Re-run the exact same WCC query from step 1.

    ```sql
    <copy>
    SELECT community, COUNT(*) AS members, LISTAGG(name, ', ') WITHIN GROUP (ORDER BY name) AS people
    FROM GRAPH_TABLE(
      DBMS_OGA.WCC(
        social_network,
        PROPERTY(VERTEX OUTPUT community)
      )
      MATCH (p IS sn_people)
      COLUMNS (p.name, p.community)
    )
    GROUP BY community
    ORDER BY community;
    </copy>
    ```

    **What you should see:**

    | COMMUNITY | MEMBERS | PEOPLE |
    | --- | --- | --- |
    | 1 | 8 | Felix, Ivy, Liam, Maya, Noah, Owen, Sofia, Zara |

    - One follow was all it took to merge the islands into a single community
    - No graph rebuild, no refresh - the algorithm ran against the live tables

## Task 7: Clean Up

You built a social network as a SQL property graph and used the full set of `DBMS_OGA` algorithms to answer different questions about it. PageRank found the most influential people, Personalized PageRank showed who mattered from one person's or group's point of view, Bellman-Ford found the lowest-cost introductions from Zara, and WCC identified separate communities and showed how one new follow could connect them. Each algorithm ran inside the database and returned its results as temporary graph properties that you queried with `GRAPH_TABLE`.

1. Drop the graph and its tables.

    ```sql
    <copy>
    DROP PROPERTY GRAPH IF EXISTS social_network;
    DROP TABLE IF EXISTS sn_follows CASCADE CONSTRAINTS;
    DROP TABLE IF EXISTS sn_people CASCADE CONSTRAINTS;
    </copy>
    ```


## Learn More

- [In-Database Graph Algorithms - SQL Property Graph Developer's Guide](https://docs.oracle.com/en/database/oracle/property-graph/26.3/spgdg/index.html)
- [DBMS_OGA Package Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/arpls/dbms_oga1.html)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, July 2026
