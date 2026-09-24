# Investigate a Booking Abuse Network

![Bob — hospitality lab banner](images/bob.png)

## Introduction

Bob Green is a graph specialist at Seer Hotels. He uses property graphs to investigate booking abuse.

A reservation row may not show coordinated activity. Shared devices, phone numbers, payment tokens, or IP addresses can reveal connections between reservations.

First, use SQL/PGQ to follow connections between reservations. Then open Graph Studio to view the same relationships as an interactive network.

Graph Studio is Oracle Database’s visual workspace for property graphs. SQL/PGQ returns tables you can sort and compare. Graph Studio shows nodes, edges, and paths you can explore. You will use both to investigate reservation `RSV-8841`.


<details>
<summary><strong>Key terms: property graph, vertex, edge, and SQL Property Graph Queries (SQL/PGQ)</strong></summary>

> - A **property graph** represents things and how they are connected. In this lab, things include reservations, devices, IP addresses, phone numbers, payment tokens, hotel properties, and cases. A graph makes relationship patterns easier to see than they are in a flat table.
>
> - A **vertex** is a graph node that represents something investigators care about, such as a reservation, device, IP address, payment token, phone number, or case. In this graph, vertices use the `entity` label and carry properties such as a risk score, channel, or total amount.
>
> - An **edge** is a connection between vertices, such as a reservation using a device, sharing a phone number, paying with a token, or opening activity from an IP address. In this graph, edges use the `related_to` label and carry properties such as the relationship type.
>
> - A **hop** is one step across an edge from one vertex to another. `RSV-8841` to a device is one hop. `RSV-8841` to that device and then to another reservation is two hops. The hop count tells investigators how far the search travels from the starting reservation; it does not describe physical distance or reservation time.
>
> - **SQL Property Graph Queries (SQL/PGQ)** let you describe graph patterns in SQL, such as "start with this reservation and follow related entities." That lets investigators ask relationship questions in SQL without moving booking abuse data into a separate graph-only database.

</details>

The local Hospitality LiveStack demo illustrates a related application story using a separate dataset. Its identifiers and results differ from the Seer Hotels SQL exercises below.

![Local demo guest experience network](images/demo-network-overview.jpg)

The application also exposes its own query details. Use the workshop SQL below for the Seer Hotels exercises.

![Local demo network query and results](images/demo-network-query.jpg)

### Objectives

- Identify vertices and edges in a property graph.
- Follow connections from a suspicious reservation.
- Find reservation pairs that share identifying information.
- Open Graph Studio from Database Actions.
- Import and run the hospitality booking-abuse-network notebook.
- Explain the result in terms a business user can act on.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step                | Hospitality focus                                                                                                  |
| ---------------------| ----------------------------------------------------------------------------------------------------------------|
| Business Problem    | Booking Abuse teams need to see relationships that are hard to detect from reservation tables alone.                   |
| Technical Challenge | Bob needs to follow paths and find shared identifiers without writing long chains of self-joins.                  |
| Persona Focus       | You review Bob's graph design and interpret its results for a booking abuse review.                                     |
| What You Will See   | A property graph shows connected entities and reservation pairs with SQL.                                           |
| Database Capability | BOOKING\_ABUSE\_NETWORK and GRAPH\_TABLE support SQL/PGQ traversal.                                                     |
| Outcome             | A business user can see which reservations are connected, what they share, and which relationships deserve review. |

Persona focus: You are reviewing Bob's graph solution with a booking abuse analyst.

> **SQL Worksheet reminder:** See [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the steps to paste and run SQL.

## Task 1: Follow a suspicious reservation with SQL

Jessica has already written a query for Bob. It shows the entities directly connected to suspicious reservation `RSV-8841`. The query works, but Jessica is concerned about what happens when investigators need to follow relationships several steps away.

In this lab, a **hop** means one relationship step. The reservation to a device is one hop. The reservation to that device and then to another reservation is two hops. A four-hop search follows four such steps from `RSV-8841`, so it can reveal entities that are not directly connected to the reservation.

1. Run Jessica's ordinary SQL query:

    ```sql
    <copy>
    SELECT reservation.entity_key AS reservation_key,
           connected.entity_key AS connected_key,
           connected.entity_type AS connected_type,
           rel.relationship_type,
           connected.risk_score AS connected_risk
    FROM booking_entities reservation
    JOIN booking_relationships rel
      ON rel.from_entity = reservation.entity_id
    JOIN booking_entities connected
      ON connected.entity_id = rel.to_entity
    WHERE reservation.entity_key = 'RSV-8841'
    ORDER BY connected_risk DESC;
    </copy>
    ```

    The query joins `BOOKING_ENTITIES` twice: once for the reservation and once for the connected entity. `BOOKING_RELATIONSHIPS` supplies the edge between them.

    **Expected output: Direct reservation Connections**

    The result lists the device, reused payment token, IP address, phone, or property directly connected to `RSV-8841`.

2. Extend Jessica's query to follow one through four hops without using a graph query:

    ```sql
    <copy>
    SELECT reservation_key, connected_key, connected_type,
           relationship_path, connected_risk
    FROM (
      SELECT seed.entity_key AS reservation_key,
             reached.entity_key AS connected_key,
             reached.entity_type AS connected_type,
             r1.relationship_type AS relationship_path,
             reached.risk_score AS connected_risk
      FROM booking_entities seed
      JOIN booking_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN booking_entities reached
        ON reached.entity_id = r1.to_entity
      WHERE seed.entity_key = 'RSV-8841'

      UNION

      SELECT seed.entity_key,
             reached.entity_key,
             reached.entity_type,
             r1.relationship_type || ' -> ' || r2.relationship_type,
             reached.risk_score
      FROM booking_entities seed
      JOIN booking_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN booking_entities v1
        ON v1.entity_id = r1.to_entity
      JOIN booking_relationships r2
        ON r2.from_entity = v1.entity_id
      JOIN booking_entities reached
        ON reached.entity_id = r2.to_entity
      WHERE seed.entity_key = 'RSV-8841'

      UNION

      SELECT seed.entity_key,
             reached.entity_key,
             reached.entity_type,
             r1.relationship_type || ' -> ' ||
               r2.relationship_type || ' -> ' ||
               r3.relationship_type,
             reached.risk_score
      FROM booking_entities seed
      JOIN booking_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN booking_entities v1
        ON v1.entity_id = r1.to_entity
      JOIN booking_relationships r2
        ON r2.from_entity = v1.entity_id
      JOIN booking_entities v2
        ON v2.entity_id = r2.to_entity
      JOIN booking_relationships r3
        ON r3.from_entity = v2.entity_id
      JOIN booking_entities reached
        ON reached.entity_id = r3.to_entity
      WHERE seed.entity_key = 'RSV-8841'

      UNION

      SELECT seed.entity_key,
             reached.entity_key,
             reached.entity_type,
             r1.relationship_type || ' -> ' ||
               r2.relationship_type || ' -> ' ||
               r3.relationship_type || ' -> ' ||
               r4.relationship_type,
             reached.risk_score
      FROM booking_entities seed
      JOIN booking_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN booking_entities v1
        ON v1.entity_id = r1.to_entity
      JOIN booking_relationships r2
        ON r2.from_entity = v1.entity_id
      JOIN booking_entities v2
        ON v2.entity_id = r2.to_entity
      JOIN booking_relationships r3
        ON r3.from_entity = v2.entity_id
      JOIN booking_entities v3
        ON v3.entity_id = r3.to_entity
      JOIN booking_relationships r4
        ON r4.from_entity = v3.entity_id
      JOIN booking_entities reached
        ON reached.entity_id = r4.to_entity
      WHERE seed.entity_key = 'RSV-8841'
    ) paths
    ORDER BY connected_risk DESC;
    </copy>
    ```

    Jessica now needs four separate SELECT statements. The first branch follows one relationship step, the second follows two, the third follows three, and the fourth follows four. Each additional hop adds another relationship join and another entity join. The `UNION` combines the four path lengths and removes duplicate rows. This returns the same one-through-four-hop range as Bob's graph query, but it is much longer and harder to change.

3. Review how the SQL grows more complex when it does not use a graph query.

    Jessica can add another relationship step, but she must join `BOOKING_ENTITIES` and `BOOKING_RELATIONSHIPS` again. Four hops need four relationship joins and five instances of the entity table. If she wants to support several possible path lengths, the query needs more joins, unions, and duplicate handling. The SQL becomes harder to read just as the investigation becomes more important.

    This is the problem Bob's graph approach is meant to solve. The relationships already exist in relational tables, but a graph query can express the path directly.

## Task 2: Read the same connections as a graph

Bob has already created the `BOOKING_ABUSE_NETWORK` property graph for this lab. You do not need to create it before running the queries. The graph definition uses the existing relational tables as its source; it does not create a second copy of the booking abuse data. Check the appendix to learn how Bob created the graph and mapped the relational tables to vertices and edges.

In graph terms, the reservation and connected objects are **vertices**. The row in `BOOKING_RELATIONSHIPS` between them is an **edge**. `GRAPH_TABLE` lets Bob query those vertices and edges with a graph pattern while Oracle keeps the source data in the database.

1. Run Bob's SQL/PGQ query:

    ```sql
    <copy>
    SELECT reservation_key,
           connected_key,
           connected_type,
           relationship_type,
           connected_risk
    FROM GRAPH_TABLE ( booking_abuse_network
      MATCH (reservation IS entity) -[edge IS related_to]-> (connected IS entity)
      WHERE reservation.entity_key = 'RSV-8841'
      COLUMNS (
        reservation.entity_key AS reservation_key,
        connected.entity_key AS connected_key,
        connected.entity_type AS connected_type,
        edge.relationship_type AS relationship_type,
        connected.risk_score AS connected_risk
      )
    )
    ORDER BY connected_risk DESC;
    </copy>
    ```

    ![SQL Worksheet result — graph direct](images/sql-graph-direct.jpg)

    *Scroll the result grid to inspect additional rows and columns.*

    In the `MATCH` pattern, `reservation` and `connected` are vertices. `edge` is the edge between them, so this pattern follows one hop. `IS entity` and `IS related_to` refer to the labels defined in `BOOKING_ABUSE_NETWORK`.

    The result has the same shape as Jessica's query. The difference is the way Bob describes the investigation: start at one vertex, follow one edge, and return the connected vertex.

## Task 3: Trace four-hop booking abuse reach

Start from suspicious reservation `RSV-8841` and trace the connected entities within four relationship hops.

1. Run the SQL/PGQ traversal from `RSV-8841`.

    This query treats the booking abuse data as a graph. In the `MATCH` pattern, `(seed IS entity)` is the starting reservation, `-[e IS related_to]->{1,4}` means follow a path of one, two, three, or four hops, and `(reached IS entity)` is every entity reached from that starting point. The database counts each relationship in the path as one hop. `COUNT(e.relationship_type)` returns that count as `relationship_hops`; `relationship_type` is an edge property exposed by the graph definition.

    The `WHERE` clause anchors the search on `RSV-8841`, and the `COLUMNS` clause returns graph properties in a normal SQL result table.

    This is much easier than writing the same logic with ordinary joins. Without SQL/PGQ graph pattern matching, you would need separate self-joins for one-hop and four-hop paths, extra union logic for each hop level, and more code every time investigators want to follow another type of relationship.

    The graph pattern says the investigation in plain terms: start with this reservation, follow the relationships, and show what is connected.

    ```sql
    <copy>
    SELECT DISTINCT entity_key, display_name, entity_type,
           relationship_hops, risk_score, risk_level,
           total_amount, channel
    FROM GRAPH_TABLE ( booking_abuse_network
      MATCH (seed IS entity) -[e IS related_to]->{1,4} (reached IS entity)
      WHERE seed.entity_key = 'RSV-8841'
      COLUMNS (
        reached.entity_key AS entity_key,
        reached.display_name AS display_name,
        reached.entity_type AS entity_type,
        COUNT(e.relationship_type) AS relationship_hops,
        reached.risk_score AS risk_score,
        reached.risk_level AS risk_level,
        reached.total_amount AS total_amount,
        reached.channel AS channel
      )
    )
    ORDER BY risk_score DESC
    FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    ![SQL Worksheet result — graph four hop](images/sql-graph-four-hop.jpg)

    *Scroll the result grid to inspect additional rows and columns.*

    RELATIONSHIP_HOPS shows the entity's level in the search. A value of `1` means the entity is directly connected to `RSV-8841`; a value of `2` means the query reached it after one intermediate vertex; values `3` and `4` show deeper connections.

    **Expected output: High Risk Booking Abuse Entities**

    

2. Review the high-risk entities.
    The query returns connected entities as a risk-sorted table, not as a visual network. That makes the graph result usable in the same SQL review workflow as the dashboard, vector search, and reservation labs.

    The expected rows show the entities connected to suspicious reservation `RSV-8841`. 
    For example:
    * `DEV-fp-91a7` is a device 
    * `TOKEN-REUSED-017` is a tokenized payment reference reused across reservations
    * `IP-198.51.100.44` is an IP address
    * `PHONE-212-0199` is a phone number
    
    These rows matter because they show what the suspicious reservation touched or shared.

    The result gives investigators a risk-sorted list of connected entities. Instead of reviewing a tangle of connections, the analyst gets a table sorted by risk. High risk scores and large amounts point to entities that may require manual booking review, case escalation, or deeper review before looking at lower-risk connections.

## Task 4: Find reservations that share identifying information

Bob now moves from one suspicious reservation to a broader booking abuse question: **which reservation pairs share a device, IP address, phone number, or email address?** This is the kind of relationship pattern that can be difficult to find with ordinary joins.

1. Run Bob's reservation-pair query:

    ```sql
    <copy>
    SELECT reservation_a, shared_entity, shared_type, reservation_b,
           a_risk, b_risk,
           ROUND((a_risk + b_risk) / 2, 1) AS combined_risk,
           e1_type, e2_type
    FROM GRAPH_TABLE ( booking_abuse_network
        MATCH (a IS entity)
              -[e1 IS related_to]-> (shared IS entity)
              <-[e2 IS related_to]- (b IS entity)
        WHERE a.entity_type = 'reservation'
          AND b.entity_type = 'reservation'
          AND a.entity_id < b.entity_id
          AND shared.entity_type IN ('device','ip_address','phone','email')
          AND (a.risk_score >= 70 OR b.risk_score >= 70)
        COLUMNS (
            a.entity_key AS reservation_a,
            shared.entity_key AS shared_entity,
            shared.entity_type AS shared_type,
            b.entity_key AS reservation_b,
            a.risk_score AS a_risk,
            b.risk_score AS b_risk,
            e1.relationship_type AS e1_type,
            e2.relationship_type AS e2_type
        )
    )
    ORDER BY combined_risk DESC, shared_entity
    FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    ![SQL Worksheet result — graph shared](images/sql-graph-shared.jpg)

    *Scroll the result grid to inspect additional rows and columns.*

    The pattern starts at reservation `a`, follows an edge to a shared entity, and follows another edge back to reservation `b`. The two reservations can therefore be connected through the same device, IP address, phone number, or email address. `a.entity_id < b.entity_id` keeps the result from returning the same pair twice in reverse order.

2. Review the business result.

    The result shows the two reservations, the information they share, the relationship type on each side, and the risk score for each reservation. `COMBINED_RISK` helps the analyst review the strongest reservation pairs first. A shared identifier does not prove booking abuse, but it gives the booking abuse team a clear reason to investigate the reservations together.

    

## Task 5: Visualize the relationship using Oracle Graph Studio

Oracle Graph Studio displays the reservations and identifiers as an interactive network. Bob can select nodes and follow relationships to find clusters, shared devices, and links between reservations.

In the following tasks, use Graph Studio to turn the SQL results for `RSV-8841` into an investigation map.

1. Start from the Database Actions Launchpad. Confirm that the upper-right corner shows `LLUSER`. If the dark-theme message appears, click **Done**.

    ![Database Actions Launchpad for the LLUSER workshop user](images/graph-launch.jpg " ")

3. On the **Development** tab, select **Graph Studio** from the left-side tool list and click **Open**.

    ![Open Graph Studio from the Database Actions launchpad](images/graph-launch.jpg " ")

4. If prompted, sign in with the `LLUSER` and the workshop password supplied.

5. Confirm that the Graph Studio home page opens. The landing page provides **Graphs**, **Notebooks**, **Templates**, and **Jobs**.

    ![Graph Studio overview page signed in as LLUSER](images/graph-studio-overview.jpg " ")

## Task 6: Download and import the hospitality notebook

The supplied `.dsnb` file is a native Graph Studio notebook: a reusable, runnable investigation guide that combines SQL/PGQ paragraphs and graph visualizations.

1. Download [hospitality-booking-abuse-graph-studio.dsnb](files/hospitality-booking-abuse-graph-studio.dsnb).

    If the notebook opens in your browser instead of downloading, right-click the link and select **Save Link As**.

2. In Graph Studio, click **Notebooks** in the landing page.

    ![Graph Studio Notebooks page for LLUSER](images/graph-notebooks.jpg " ")

3. Select **Import** in the upper-right corner.

    ![Graph Studio notebook import dialog](images/graph-import-dialog.jpg)

    

4. Once the import notebooks tab opens, drag & drop the `hospitality-booking-abuse-graph-studio.dsnb` file from your local computer into the import window, or browse to the file on your computer. Review the selected filename and click **Import**. Open **Booking Abuse Network** after the import completes.

    ![Hospitality notebook selected for import](images/graph-import-file.jpg)

    


## Task 7: Run and interpret the Graph Studio notebook

You already ran the SQL/PGQ patterns in SQL Worksheet. Now run selected parts of that investigation in Graph Studio so you can compare the query results with the visual graph experience. The notebook shows the `RSV-8841` path and the `DEV-fp-91a7` shared-device view.

Use the table to rank connected entities. Use the graph to follow the paths and shared identifiers that connect them.

1. Start at the top of the **Booking Abuse Network** notebook. Read the explanation for the `RSV-8841` traversal, then run the first SQL paragraph.

    ![Booking Abuse Network notebook introduction](images/graph-notebook-top.jpg)

    

2. Review the results in table format in the graph studio notebook:

    ![Ranked booking results in Graph Studio](images/live-09-graph-notebook-table.jpg)

    This uses the investigation pattern from Task 3 with a shorter one-to-two-hop limit: start from `RSV-8841`, follow one or two relationship hops, and return the connected entities as a prioritized table.

    | Paragraph | Result | Investigation purpose |
    | --- | --- | --- |
    | `SELECT DISTINCT ... WHERE seed.entity_key = 'RSV-8841'` | Table | Ranks entities reached within one or two hops of `RSV-8841`. |
    | `Graph Visualization of previous query` | Markdown label | Introduces the visual version of the first traversal. |
    | `SELECT * ... WHERE src.entity_key = 'RSV-8841'` | Graph visualization | Draws the one-hop and two-hop path from the suspicious reservation. |
    | `Shared Entity Connections` | Markdown label and explanation | Introduces the device-centered relationship view. |
    | `SELECT * ... WHERE device.entity_key = 'DEV-fp-91a7'` | Graph visualization | Centers on `DEV-fp-91a7` and draws its directly connected reservations. |

3. Under **Graph Visualization of previous query**, run the SQL paragraph that starts with `SELECT *` and anchors on `RSV-8841`. Review the graph visualization that appears below the paragraph.

    ![Reservation graph from RSV-8841](images/live-10-graph-reservation-network.jpg)
    Note how the reservations and devices in the previous query were turned into vertices and edges in Graph Studio to display an interactive network.

    

4. Under **Shared Entity Connections**, read the device-centered explanation, then run the final SQL paragraph that anchors on `DEV-fp-91a7`. Review the graph visualization that appears below the paragraph. This visualization narrows the investigation to the device DEV-fp-91a7.

    ![Reservations linked to the shared device](images/live-11-graph-shared-device.jpg)

    The supplied display filters show four of five vertices and five of seven edges.

    
The fixture requires device `DEV-fp-91a7` to link reservation vertices RSV-8841, RSV-5077, and RSV-1190. These links illustrate how reservations can share a booking device; verify the edges in your loaded data. This graph matters because it shows what the suspicious reservation touched or shared.

> **Result note:** Graph layouts and node positions can vary between runs. Compare entity keys, relationships, and query results.

You have used SQL/PGQ to list connected entities and Graph Studio to explore their relationships. Together, these views help you explain the connections around `RSV-8841`.

### Optional graph-algorithms extension

The companion [loyalty graph notebook](files/getting-started-loyalty-graph.dsnb) provides separate PGX exercises: parameterized paths, degree counts, PageRank, shortest paths, personalized PageRank, and hop distance. It uses `LOYALTY_GRAPH`, with loyalty members connected by allowed points transfers. It is separate from `BOOKING_ABUSE_NETWORK` and requires the optional PGQL graph, a provisioned `LOYALTY_GRAPH`, and an attached PGX service. Skip this extension if those resources are not available. Graph proximity is a review cue, not proof of abuse.

## Conclusion: Make Relationships Easy to Review

Bob's graph queries show why a property graph fits booking-abuse investigations. Bob can start with one suspicious reservation, follow its relationships, limit the search to a chosen number of hops, and find reservation pairs that share identifying information. The queries stay readable as the network grows, while the results still include the risk and activity details needed for review.

Graph Studio displayed the same relationships as an interactive network. Bob compared the notebook results with the earlier SQL Worksheet results, then explored clusters, shared devices, and links between reservations.

## Appendix: Create the Property Graph

Bob creates a property graph by mapping relational tables to graph elements. `BOOKING_ENTITIES` becomes the vertex table, and each row receives the `entity` label. `BOOKING_RELATIONSHIPS` becomes the edge table, with foreign keys identifying the source and destination vertices. The graph queries in this lab use those two labels.

This statement is provided for reference. The `BOOKING_ABUSE_NETWORK` graph has already been created in the workshop database.

```sql
<copy>
CREATE PROPERTY GRAPH booking_abuse_network
  VERTEX TABLES (
    booking_entities KEY (entity_id)
      LABEL entity
      PROPERTIES (
        entity_id,
        entity_key,
        display_name,
        entity_type,
        risk_score,
        risk_level,
        channel,
        total_amount,
        event_count,
        is_confirmed_abuse
      ),
    booking_cases KEY (case_id)
      LABEL booking_case
      PROPERTIES (
        case_id,
        case_ref,
        case_type,
        status,
        risk_score,
        loss_amount,
        event_count
      )
  )
  EDGE TABLES (
    booking_relationships KEY (relationship_id)
      SOURCE KEY (from_entity)
        REFERENCES booking_entities (entity_id)
      DESTINATION KEY (to_entity)
        REFERENCES booking_entities (entity_id)
      LABEL related_to
      PROPERTIES (
        relationship_type,
        strength,
        event_count,
        total_amount
      ),
    booking_case_entities KEY (case_entity_id)
      SOURCE KEY (case_id)
        REFERENCES booking_cases (case_id)
      DESTINATION KEY (entity_id)
        REFERENCES booking_entities (entity_id)
      LABEL contains_entity
      PROPERTIES (
        role,
        evidence_score
      )
  );
</copy>
```

The statement defines the graph structure over the relational tables. It does not move the rows to a separate graph database. `BOOKING_ABUSE_NETWORK` can then be queried with `GRAPH_TABLE` while the relational tables remain the source of the data.


## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026
