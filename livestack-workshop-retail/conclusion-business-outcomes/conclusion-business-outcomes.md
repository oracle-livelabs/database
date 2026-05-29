# Conclusion

## Introduction

This closing lab ties the workshop together. Learners review how one Oracle Database 26ai foundation supports the retail decision loop: observe the business, understand demand, trace influence, route fulfillment, protect orders, score risk, ask questions, and record agent actions.


The practical point is simple: Oracle Database 26ai backs one connected retail decision path across data, AI, security, and operations. Each lab showed a different part of that path: observe the business, understand demand, trace influence, route fulfillment, protect orders, score risk, ask questions, and record agent actions.

Estimated Time: **5 minutes**

### Objectives

- Review the end-to-end scene sequence.
- Connect each screen to a practical retail decision.
- Explain the workshop flow in plain retail terms.

## Task 1: Review the final outcome

Perform the following set of steps to connect each lab back to the same retail decision loop and database foundation.

1. Review the workshop flow from the database point of view.

    This final query ties every lab back to a retail decision and the database evidence behind it. `UNION ALL` stacks several short result sets into one evidence map. Each row names a signal, the screen where the learner saw it, and the Oracle Database evidence behind the screen. Use the result to explain the workshop as one governed decision loop across the major database features.

    ```sql
    <copy>
    SELECT 'Operating picture' AS "Signal", 'Retail Command Center' AS "Scene", 'ORDERS, SOCIAL_POSTS, INVENTORY, RETURN_REQUESTS, and AGENT_ACTIONS' AS "Database Evidence" FROM dual
    UNION ALL SELECT 'Viral demand', 'Customer Trend Signals', 'SOCIAL_POSTS, PRODUCT_EMBEDDINGS, and SEMANTIC_MATCHES' FROM dual
    UNION ALL SELECT 'Creator propagation', 'Creator Influence Network', 'INFLUENCER_NETWORK property graph' FROM dual
    UNION ALL SELECT 'Fulfillment distance', 'Intelligent Fulfillment Network', 'SDO_GEOMETRY locations and SDO_DISTANCE' FROM dual
    UNION ALL SELECT 'Order state', 'Unified Order Intelligence', 'ORDERS_DV JSON Relational Duality view' FROM dual
    UNION ALL SELECT 'ML prediction', 'Retail OML Analytics', 'DBMS_DATA_MINING models and OML feature views' FROM dual
    UNION ALL SELECT 'Plain-English analytics', 'Ask Retail Data', 'Semantic views, comments, and visible SQL' FROM dual
    UNION ALL SELECT 'Agent action', 'Retail AI Agent Console', 'PL/SQL tools and AGENT_ACTIONS audit rows' FROM dual;
    </copy>
    ```

    Expected output:

    | Signal | Scene | Database Evidence |
    | --- | --- | --- |
    | Operating picture | Retail Command Center | ORDERS, `SOCIAL_POSTS`, INVENTORY, `RETURN_REQUESTS`, and `AGENT_ACTIONS` |
    | Viral demand | Customer Trend Signals | `SOCIAL_POSTS`, `PRODUCT_EMBEDDINGS`, and `SEMANTIC_MATCHES` |
    | Creator propagation | Creator Influence Network | `INFLUENCER_NETWORK` property graph |
    | Fulfillment distance | Intelligent Fulfillment Network | `SDO_GEOMETRY` locations and `SDO_DISTANCE` |
    | Order state | Unified Order Intelligence | `ORDERS_DV` JSON Relational Duality view |
    | ML prediction | Retail OML Analytics | `DBMS_DATA_MINING` models and OML feature views |
    | Plain-English analytics | Ask Retail Data | Semantic views, comments, and visible SQL |
    | Agent action | Retail AI Agent Console | PL/SQL tools and `AGENT_ACTIONS` audit rows |
    {: title="Decision Loop Evidence"}

2. Each signal supports a practical retail question, such as what is selling, what demand is changing, where fulfillment risk appears, which order evidence matters, or what an agent did.

## Task 2: Explain the workshop flow

Perform the following set of steps as one connected retail operating pattern, not a set of disconnected database feature demos.

1. Use this concise summary to explain the workshop flow.

    ```text
    Seer Sporting Goods connects product demand, customer signals, creator influence, fulfillment routing, order documents, in-database machine learning, natural-language SQL, and auditable agent actions through one Oracle AI Database 26ai foundation.
    ```

2. Close with the same idea that opened the lab: less data movement, clearer decisions, and a direct path from evidence to action. The workshop is not a set of disconnected feature demos. It is one retail operating pattern where Oracle Database 26ai keeps the data, AI, security, analytics, and agent history together.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
