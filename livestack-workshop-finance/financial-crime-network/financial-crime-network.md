# Financial Crime Network with Property Graph

## Introduction

This lab investigates a fraud network with Oracle Property Graph and SQL/PGQ. You start from suspicious account `ACCT-8841` and trace connected devices, IP addresses, payees, phones, and other entities.

Fraud patterns often hide in relationships rather than in a single transaction row. This lab shows how a suspicious account can lead to connected devices, mule payees, IP addresses, and phone numbers that may explain coordinated activity.

This comes after semantic search because a suspicious signal often leads to the question, "Who or what else is connected?" The graph lets you move from a risky account to relationship evidence that can support escalation.

![Fraud graph investigation flow](images/fraud-graph-investigation-flow.svg " ")

![Financial Crime Network graph workspace](images/fraud-network.png " ")

### Objectives

- Traverse fraud ring reach from a seed account.
- Find shared device and IP clusters.

Estimated Time: **12 minutes**

### Operating Story

| Step | Finance focus |
| --- | --- |
| Business Problem | Fraud teams need to see relationships that are hard to detect from transaction tables alone. |
| Technical Challenge | Investigators need path-based relationship analysis without writing and maintaining long chains of self-joins. |
| Persona Focus | Fraud analysts interpret the network; database developers provide the graph pattern that explains why entities are connected. |
| What You Will Prove | A property graph exposes fraud ring reach and shared entity clusters with SQL. |
| Database Capability | FRAUD\_NETWORK and GRAPH\_TABLE support SQL/PGQ traversal. |
| Outcome | Investigators can explain why entities are related and prioritize high-risk nodes. |

Persona focus: You are helping a fraud analyst move from a suspicious account to explainable relationship evidence without turning the investigation into fragile join logic.

## Task 1: Trace two-hop fraud reach

1. Run the SQL/PGQ traversal from `ACCT-8841`.

    This query treats the fraud data as a graph. In the `MATCH` pattern, `(seed IS entity)` is the starting account, `-[e IS related_to]->{1,2}` means follow one or two relationship hops, and `(reached IS entity)` is every entity reached from that starting point. The `WHERE` clause anchors the search on `ACCT-8841`, and the `COLUMNS` clause projects graph properties back into a normal SQL result table.

    This is much easier than writing the same logic with ordinary joins. Without SQL/PGQ graph pattern matching, you would need separate self-joins for one-hop and two-hop paths, extra union logic for each relationship depth, and more code every time investigators want to follow another type of relationship. The graph pattern says what the investigator means: start here, follow related entities, and return the reached nodes.

    ```sql
    <copy>
    SELECT DISTINCT entity_key, display_name, entity_type,
           risk_score, risk_level, total_amount, channel
    FROM GRAPH_TABLE ( fraud_network
      MATCH (seed IS entity) -[e IS related_to]->{1,2} (reached IS entity)
      WHERE seed.entity_key = 'ACCT-8841'
      COLUMNS (
        reached.entity_key AS entity_key,
        reached.display_name AS display_name,
        reached.entity_type AS entity_type,
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

    Expected output: High Risk Fraud Entities

    | Entity Key | Display Name | Entity Type | Risk Score | Risk Level | Total Amount | Channel |
    | --- | --- | --- | --- | --- | --- | --- |
    | DEV-fp-91a7 | Mobile Fingerprint 91a7 | device | 98.0 | critical | 42211.05 | network |
    | PAYEE-MULE-017 | Mule Payee 017 | payee | 97.0 | critical | 36110.75 | payments |
    | IP-198.51.100.44 | Residential Proxy 198.51.100.44 | ip\_address | 95.0 | critical | 38200.25 | network |
    | PHONE-212-0199 | Reused VOIP 212-0199 | phone | 90.0 | critical | 25110.25 | contact\_center |
    | PAYEE-CRYPTO-3 | Crypto Ramp Wallet 3 | payee | 87.0 | high | 14325.5 | payments |
    | BRANCH-NY-014 | NY Midtown Branch 014 | branch | 49.0 | medium | 2800.0 | branch |


2. Review the high-risk entities.
    The query returns connected entities as a prioritized table, not as an abstract graph picture. That makes the graph result usable in the same SQL review workflow as the dashboard, vector search, and transaction labs.

    Expected rows include `DEV-fp-91a7`, `PAYEE-MULE-017`, `IP-198.51.100.44`, and `PHONE-212-0199`. These are not just labels; they are connected entities that help explain why the seed account deserves attention.

    The result gives investigators a prioritized reach map. High risk scores and large amounts point to entities that may require account holds, case escalation, or deeper review before looking at lower-risk branches of the network.

## Task 2: Find accounts sharing device, IP, phone, or email

1. Run this shared-entity graph query.

    This query looks for an account-to-shared-entity-to-account pattern. In graph terms, it finds `(a) -> (shared) <- (b)`: two accounts connected through the same device, IP address, phone, or email. The `a.entity_id < b.entity_id` filter prevents returning the same account pair twice, and the risk filter keeps the result focused on relationships where at least one account is already concerning.

    This is where SQL/PGQ is especially useful. A relational version would need multiple joins back to the same entity and relationship tables, separate conditions for each shared entity type, and careful duplicate handling for account pairs. The graph query is shorter and closer to the fraud question: "Which risky accounts share the same identifying evidence?"

    ```sql
    <copy>
    SELECT account_a, shared_entity, shared_type, account_b,
           a_risk, b_risk,
           ROUND((a_risk + b_risk) / 2, 1) AS combined_risk,
           e1_type, e2_type
    FROM GRAPH_TABLE ( fraud_network
      MATCH (a IS entity) -[e1 IS related_to]-> (shared IS entity) <-[e2 IS related_to]- (b IS entity)
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

    Expected output: Shared Entity Connections

    | Account A | Shared Entity | Shared Type | Account B | A Risk | B Risk | Combined Risk | E1 Type | E2 Type |
    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
    | ACCT-8841 | DEV-fp-91a7 | device | ACCT-1190 | 96.5 | 91.0 | 93.8 | shared\_device | shared\_device |
    | ACCT-8841 | IP-198.51.100.44 | ip\_address | ACCT-1190 | 96.5 | 91.0 | 93.8 | shared\_ip | shared\_ip |
    | ACCT-8841 | PHONE-212-0199 | phone | ACCT-1190 | 96.5 | 91.0 | 93.8 | same\_phone | same\_phone |
    | ACCT-8841 | DEV-fp-91a7 | device | ACCT-5077 | 96.5 | 88.0 | 92.3 | shared\_device | shared\_device |
    | ACCT-9204 | DEV-emulator-22 | device | ACCT-2188 | 94.0 | 86.0 | 90 | shared\_device | shared\_device |
    | ACCT-9204 | IP-203.0.113.17 | ip\_address | ACCT-2188 | 94.0 | 86.0 | 90 | shared\_ip | shared\_ip |
    | ACCT-1190 | DEV-fp-91a7 | device | ACCT-5077 | 91.0 | 88.0 | 89.5 | shared\_device | shared\_device |
    | ACCT-8841 | IP-198.51.100.44 | ip\_address | ACCT-3320 | 96.5 | 81.5 | 89 | shared\_ip | shared\_ip |
    | ACCT-1190 | IP-198.51.100.44 | ip\_address | ACCT-3320 | 91.0 | 81.5 | 86.3 | shared\_ip | shared\_ip |
    | ACCT-5077 | EMAIL-risk-drop-01 | email | ACCT-3320 | 88.0 | 81.5 | 84.8 | same\_email | same\_email |


2. Use the result to explain investigation priority.
    This query moves from reach to shared evidence. It identifies account pairs that reuse the same identifiers, which is stronger investigative evidence than a single high-risk score.

    A shared device, IP address, phone, or email can connect accounts that look separate in transaction tables. The combined risk score helps prioritize pairs where both sides of the relationship are risky, not just connected.

    This is relevant to the overall workshop because it turns dashboard suspicion into explainable relationship evidence. The fraud analyst can say which accounts are connected, what they share, and why that connection matters.


## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
