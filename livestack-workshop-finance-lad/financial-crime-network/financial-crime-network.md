# Investigate a Financial Crime Network

## Introduction

Bob Green is a seasoned graph specialist at Seer Bank. He has worked on fraud detection and investigation for the past decade. When the bank needs to improve how it finds and investigates financial crime, Bob recommends a property graph.

Bob's starting point is simple: fraud patterns often hide in relationships, not in one transaction row. One account may not reveal the full picture, but a shared device, reused phone number, mule payee, or repeated IP address can reveal coordinated activity.

In this lab, you review Bob's approach. You start with the basic parts of a graph, use SQL/PGQ to follow connections, and finish with a result a business user can understand: which accounts are connected, what they share, and why the relationship deserves review.

<details>
<summary><strong>Key terms: property graph, vertex, edge, and SQL Property Graph Queries (SQL/PGQ)</strong></summary>

> - A **property graph** represents things and how they are connected. In this lab, things include accounts, devices, IP addresses, phone numbers, payees, branches, and cases. A graph makes relationship patterns easier to see than they are in a flat table.
>
> - A **vertex** is a graph node that represents something investigators care about, such as an account, device, IP address, payee, phone number, or case. In this graph, vertices use the `entity` label and carry properties such as a risk score, channel, or total amount.
>
> - An **edge** is a connection between vertices, such as an account using a device, sharing a phone number, sending funds to a payee, or opening activity from an IP address. In this graph, edges use the `related_to` label and carry properties such as the relationship type.
>
> - A **hop** is one step across an edge from one vertex to another. `ACCT-8841` to a device is one hop. `ACCT-8841` to that device and then to another account is two hops. The hop count tells investigators how far the search travels from the starting account; it does not describe physical distance or transaction time.
>
> - **SQL Property Graph Queries (SQL/PGQ)** let you describe graph patterns in SQL, such as "start with this account and follow related entities." That lets investigators ask relationship questions in SQL without moving fraud evidence into a separate graph-only database.

</details>

### Objectives

- Identify vertices and edges in a property graph.
- Follow connections from a suspicious account.
- Find account pairs that share identifying evidence.
- Explain the result in terms a business user can act on.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step                | Finance focus                                                                                                  |
| ---------------------| ----------------------------------------------------------------------------------------------------------------|
| Business Problem    | Fraud teams need to see relationships that are hard to detect from transaction tables alone.                   |
| Technical Challenge | Bob needs to follow paths and find shared evidence without writing long chains of self-joins.                  |
| Persona Focus       | You review Bob's graph design and interpret its results for a fraud review.                                     |
| What You Will See   | A property graph shows connected entities and account pairs with SQL.                                           |
| Database Capability | FRAUD\_NETWORK and GRAPH\_TABLE support SQL/PGQ traversal.                                                     |
| Outcome             | A business user can see which accounts are connected, what they share, and which relationships deserve review. |

Persona focus: You are reviewing Bob's graph solution with a fraud analyst.

> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

## Task 1: Follow a suspicious account with SQL

Jessica has already written a query for Bob. It shows the entities directly connected to suspicious account `ACCT-8841`. The query works, but Jessica is concerned about what happens when investigators need to follow relationships several steps away.

In this lab, a **hop** means one relationship step. The account to a device is one hop. The account to that device and then to another account is two hops. A four-hop search follows four such steps from `ACCT-8841`, so it can reveal entities that are not directly connected to the account.

1. Run Jessica's ordinary SQL query:

    ```sql
    <copy>
    SELECT account.entity_key AS account_key,
           connected.entity_key AS connected_key,
           connected.entity_type AS connected_type,
           rel.relationship_type,
           connected.risk_score AS connected_risk
    FROM fraud_entities account
    JOIN fraud_relationships rel
      ON rel.from_entity = account.entity_id
    JOIN fraud_entities connected
      ON connected.entity_id = rel.to_entity
    WHERE account.entity_key = 'ACCT-8841'
    ORDER BY connected_risk DESC;
    </copy>
    ```

    The query joins `FRAUD_ENTITIES` twice: once for the account and once for the connected entity. `FRAUD_RELATIONSHIPS` supplies the edge between them.

    **Expected output: Direct Account Connections**

    The result lists the device, mule payee, IP address, phone, or branch directly connected to `ACCT-8841`.

2. Extend Jessica's query to follow one through four hops:

    ```sql
    <copy>
    SELECT account_key, connected_key, connected_type,
           relationship_path, connected_risk
    FROM (
      SELECT seed.entity_key AS account_key,
             reached.entity_key AS connected_key,
             reached.entity_type AS connected_type,
             r1.relationship_type AS relationship_path,
             reached.risk_score AS connected_risk
      FROM fraud_entities seed
      JOIN fraud_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN fraud_entities reached
        ON reached.entity_id = r1.to_entity
      WHERE seed.entity_key = 'ACCT-8841'

      UNION

      SELECT seed.entity_key,
             reached.entity_key,
             reached.entity_type,
             r1.relationship_type || ' -> ' || r2.relationship_type,
             reached.risk_score
      FROM fraud_entities seed
      JOIN fraud_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN fraud_entities v1
        ON v1.entity_id = r1.to_entity
      JOIN fraud_relationships r2
        ON r2.from_entity = v1.entity_id
      JOIN fraud_entities reached
        ON reached.entity_id = r2.to_entity
      WHERE seed.entity_key = 'ACCT-8841'

      UNION

      SELECT seed.entity_key,
             reached.entity_key,
             reached.entity_type,
             r1.relationship_type || ' -> ' ||
               r2.relationship_type || ' -> ' ||
               r3.relationship_type,
             reached.risk_score
      FROM fraud_entities seed
      JOIN fraud_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN fraud_entities v1
        ON v1.entity_id = r1.to_entity
      JOIN fraud_relationships r2
        ON r2.from_entity = v1.entity_id
      JOIN fraud_entities v2
        ON v2.entity_id = r2.to_entity
      JOIN fraud_relationships r3
        ON r3.from_entity = v2.entity_id
      JOIN fraud_entities reached
        ON reached.entity_id = r3.to_entity
      WHERE seed.entity_key = 'ACCT-8841'

      UNION

      SELECT seed.entity_key,
             reached.entity_key,
             reached.entity_type,
             r1.relationship_type || ' -> ' ||
               r2.relationship_type || ' -> ' ||
               r3.relationship_type || ' -> ' ||
               r4.relationship_type,
             reached.risk_score
      FROM fraud_entities seed
      JOIN fraud_relationships r1
        ON r1.from_entity = seed.entity_id
      JOIN fraud_entities v1
        ON v1.entity_id = r1.to_entity
      JOIN fraud_relationships r2
        ON r2.from_entity = v1.entity_id
      JOIN fraud_entities v2
        ON v2.entity_id = r2.to_entity
      JOIN fraud_relationships r3
        ON r3.from_entity = v2.entity_id
      JOIN fraud_entities v3
        ON v3.entity_id = r3.to_entity
      JOIN fraud_relationships r4
        ON r4.from_entity = v3.entity_id
      JOIN fraud_entities reached
        ON reached.entity_id = r4.to_entity
      WHERE seed.entity_key = 'ACCT-8841'
    ) paths
    ORDER BY connected_risk DESC;
    </copy>
    ```

    Jessica now needs four separate query branches. The first branch follows one relationship step, the second follows two, the third follows three, and the fourth follows four. Each additional hop adds another relationship join and another entity join. The `UNION` combines the four path lengths and removes duplicate rows. This returns the same one-through-four-hop range as Bob's graph query, but it is much longer and harder to change.

3. Review the query's growing complexity.

    Jessica can add another relationship step, but she must join `FRAUD_ENTITIES` and `FRAUD_RELATIONSHIPS` again. Four hops need four relationship joins and five instances of the entity table. If she wants to support several possible path lengths, the query needs more joins, unions, and duplicate handling. The SQL becomes harder to read just as the investigation becomes more important.

    This is the problem Bob's graph approach is meant to solve. The relationships already exist in relational tables, but a graph query can express the path directly.

## Task 2: Read the same connections as a graph

Bob has already created the `FRAUD_NETWORK` property graph for this lab. You do not need to create it before running the queries. The graph definition uses the existing relational tables as its source; it does not create a second copy of the fraud data. Check the appendix to learn how Bob created the graph and mapped the relational tables to vertices and edges.

In graph terms, the account and connected objects are **vertices**. The row in `FRAUD_RELATIONSHIPS` between them is an **edge**. `GRAPH_TABLE` lets Bob query those vertices and edges with a graph pattern while Oracle keeps the source data in the database.

1. Run Bob's SQL/PGQ query:

    ```sql
    <copy>
    SELECT account_key,
           connected_key,
           connected_type,
           relationship_type,
           connected_risk
    FROM GRAPH_TABLE ( fraud_network
      MATCH (account IS entity) -[edge IS related_to]-> (connected IS entity)
      WHERE account.entity_key = 'ACCT-8841'
      COLUMNS (
        account.entity_key AS account_key,
        connected.entity_key AS connected_key,
        connected.entity_type AS connected_type,
        edge.relationship_type AS relationship_type,
        connected.risk_score AS connected_risk
      )
    )
    ORDER BY connected_risk DESC;
    </copy>
    ```

    In the `MATCH` pattern, `account` and `connected` are vertices. `edge` is the edge between them, so this pattern follows one hop. `IS entity` and `IS related_to` refer to the labels defined in `FRAUD_NETWORK`.

    The result has the same shape as Jessica's query. The difference is the way Bob describes the investigation: start at one vertex, follow one edge, and return the connected vertex.

## Task 3: Trace four-hop fraud reach

Start from suspicious account `ACCT-8841` and trace the connected entities within four relationship hops.

1. Run the SQL/PGQ traversal from `ACCT-8841`.

    This query treats the fraud data as a graph. In the `MATCH` pattern, `(seed IS entity)` is the starting account, `-[e IS related_to]->{1,4}` means follow a path of one, two, three, or four hops, and `(reached IS entity)` is every entity reached from that starting point. The database counts each relationship in the path as one hop. `COUNT(e.relationship_type)` returns that count as `relationship_hops`; `relationship_type` is an edge property exposed by the graph definition.

    The `WHERE` clause anchors the search on `ACCT-8841`, and the `COLUMNS` clause returns graph properties in a normal SQL result table.

    This is much easier than writing the same logic with ordinary joins. Without SQL/PGQ graph pattern matching, you would need separate self-joins for one-hop and four-hop paths, extra union logic for each hop level, and more code every time investigators want to follow another type of relationship.

    The graph pattern says the investigation in plain terms: start with this account, follow the relationships, and show what is connected.

    ```sql
    <copy>
    SELECT DISTINCT entity_key, display_name, entity_type,
           relationship_hops, risk_score, risk_level,
           total_amount, channel
    FROM GRAPH_TABLE ( fraud_network
      MATCH (seed IS entity) -[e IS related_to]->{1,4} (reached IS entity)
      WHERE seed.entity_key = 'ACCT-8841'
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

    RELATIONSHIP_HOPS shows the entity's level in the search. A value of `1` means the entity is directly connected to `ACCT-8841`; a value of `2` means the query reached it after one intermediate vertex; values `3` and `4` show deeper connections.

    **Expected output: High Risk Fraud Entities**

    ![hraph result](images/graph4result.png)

2. Review the high-risk entities.
    The query returns connected entities as a risk-sorted table, not as a visual network. That makes the graph result usable in the same SQL review workflow as the dashboard, vector search, and transaction labs.

    The expected rows show the evidence connected to suspicious account `ACCT-8841`. 
    For example:
    * `DEV-fp-91a7` is a device 
    * `PAYEE-MULE-017` is a payee
    * `IP-198.51.100.44` is an IP address
    * `PHONE-212-0199` is a phone number
    
    These rows matter because they show what the suspicious account touched or shared.

    The result gives investigators a risk-sorted list of connected entities. Instead of reviewing a tangle of connections, the analyst gets a table sorted by risk. High risk scores and large amounts point to entities that may require account holds, case escalation, or deeper review before looking at lower-risk connections.

## Task 4: Find accounts that share identifying information

Bob now moves from one suspicious account to a broader fraud question: **which account pairs share a device, IP address, phone number, or email address?** This is the kind of relationship pattern that can be difficult to find with ordinary joins.

1. Run Bob's account-pair query:

    ```sql
    <copy>
    SELECT account_a, shared_entity, shared_type, account_b,
           a_risk, b_risk,
           ROUND((a_risk + b_risk) / 2, 1) AS combined_risk,
           e1_type, e2_type
    FROM GRAPH_TABLE ( fraud_network
        MATCH (a IS entity)
              -[e1 IS related_to]-> (shared IS entity)
              <-[e2 IS related_to]- (b IS entity)
        WHERE a.entity_type = 'account'
          AND b.entity_type = 'account'
          AND a.entity_id < b.entity_id
          AND shared.entity_type IN ('device','ip_address','phone','email')
          AND (a.risk_score >= 70 OR b.risk_score >= 70)
        COLUMNS (
            a.entity_key AS account_a,
            shared.entity_key AS shared_entity,
            shared.entity_type AS shared_type,
            b.entity_key AS account_b,
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

    The pattern starts at account `a`, follows an edge to a shared entity, and follows another edge back to account `b`. The two accounts can therefore be connected through the same device, IP address, phone number, or email address. `a.entity_id < b.entity_id` keeps the result from returning the same pair twice in reverse order.

2. Review the business result.

    The result shows the two accounts, the information they share, the relationship type on each side, and the risk score for each account. `COMBINED_RISK` helps the analyst review the strongest account pairs first. A shared identifier does not prove fraud, but it gives the fraud team a clear reason to investigate the accounts together.

    ![investigate](images/investigate.png)

## Conclusion: Make Relationships Easy to Review

Bob's graph queries show why a property graph fits financial-crime investigations. Bob can start with one suspicious account, follow its relationships, limit the search to a chosen number of hops, and find account pairs that share identifying information. The queries stay readable as the network grows, while the results still include the risk and activity details needed for review.

The same relationships can also be shown visually. Open the Seer Bank Finance LiveStack Demo and select the financial-crime graph page to explore the network view. A graphical interface, such as one built with the Oracle Graph JavaScript plugin, can turn vertices and edges into an interactive network. This helps a business user spot clusters, shared devices, and links between accounts.

## Appendix: Create the Property Graph

Bob creates a property graph by mapping relational tables to graph elements. `FRAUD_ENTITIES` becomes the vertex table, and each row receives the `entity` label. `FRAUD_RELATIONSHIPS` becomes the edge table, with foreign keys identifying the source and destination vertices. The graph queries in this lab use those two labels.

This statement is provided for reference. The `FRAUD_NETWORK` graph has already been created in the workshop database.

```sql
<copy>
CREATE PROPERTY GRAPH fraud_network
  VERTEX TABLES (
    fraud_entities KEY (entity_id)
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
        is_confirmed_fraud
      ),
    fraud_cases KEY (case_id)
      LABEL fraud_case
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
    fraud_relationships KEY (relationship_id)
      SOURCE KEY (from_entity)
        REFERENCES fraud_entities (entity_id)
      DESTINATION KEY (to_entity)
        REFERENCES fraud_entities (entity_id)
      LABEL related_to
      PROPERTIES (
        relationship_type,
        strength,
        event_count,
        total_amount
      ),
    fraud_case_entities KEY (case_entity_id)
      SOURCE KEY (case_id)
        REFERENCES fraud_cases (case_id)
      DESTINATION KEY (entity_id)
        REFERENCES fraud_entities (entity_id)
      LABEL contains_entity
      PROPERTIES (
        role,
        evidence_score
      )
  );
</copy>
```

The statement defines the graph structure over the relational tables. It does not move the rows to a separate graph database. `FRAUD_NETWORK` can then be queried with `GRAPH_TABLE` while the relational tables remain the source of the data.



## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
