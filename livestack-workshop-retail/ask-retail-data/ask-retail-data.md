# Ask Retail Data

## Introduction

A retail analyst often needs an answer before a custom report can be built. That gets risky when the question is separated from the database objects, joins, filters, and security rules that make the answer trustworthy.

This lab does not require a live general-purpose LLM. Instead, you inspect the database foundation that makes an Ask Retail Data experience possible: semantic views, table comments, approved joins, and repeatable SQL patterns. The goal is to see how plain-English retail questions map back to governed Oracle data.

Estimated Time: 10 minutes

### Objectives

- Inspect semantic views used to ground retail questions.
- Read schema comments that describe business meaning in the database.
- Map common Ask Retail Data questions to approved Oracle objects.
- Run repeatable SQL that answers current Ask Retail Data prompts.
- Explain why Oracle Database remains the source of truth for the answer.


## Task 1: Inspect semantic views for Ask Retail Data
1. Review the related application screen before you run the SQL.

    ![Ask Retail Data workspace with query modes](images/ask-retail-data-workspace.png " ")

    *Figure 1: Ask Retail Data exposes query modes and example questions.*

2. Review the grounding pattern.

    Ask Retail Data is useful only when a business question can be tied back to database evidence. In this workshop, that grounding comes from three database assets: semantic views, comments, and repeatable SQL patterns. Semantic views provide approved business shapes. Comments explain what tables and views mean. SQL shows the exact objects, joins, filters, and result columns behind the answer.

3. Run this query.

    A semantic view is a database view designed around a business question, such as return workflow, fulfillment risk, or demand signals. This block checks `ALL_VIEWS` for the approved retail views exposed to Ask Retail Data. These views reduce ambiguity because Ask Retail Data examples can target business-ready shapes instead of raw tables.

    ```sql
    <copy>
    SELECT view_name AS "View", text_length AS "SQL Text"
    FROM all_views
    WHERE owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
      AND view_name IN (
        'RETAIL_RETURNS_WORKFLOW_V','RETAIL_SIGNAL_PRODUCT_V',
        'RETAIL_ORDER_RETURN_V','RETAIL_FULFILLMENT_RISK_V','RETAIL_RETURN_WORKBENCH_V'
      )
    ORDER BY view_name;
    </copy>
    ```

    Expected output:

    | View | SQL Text |
    | --- | ---: |
    | `RETAIL_FULFILLMENT_RISK_V` | 459 |
    | `RETAIL_ORDER_RETURN_V` | 474 |
    | `RETAIL_RETURNS_WORKFLOW_V` | 922 |
    | `RETAIL_RETURN_WORKBENCH_V` | 878 |
    | `RETAIL_SIGNAL_PRODUCT_V` | 324 |
    {: title="Ask Data Views"}

4. Ask Retail Data should ground answers in these views and metadata, not in copied data or unsupported table guesses.

## Task 2: Read comments used for grounding

1. Run this query.

    Table comments are part of the semantic layer. This block reads `ALL_TAB_COMMENTS` for the core retail tables. The `schema_ctx` CTE, or common table expression, finds the active workshop schema before the main query runs. `SYS_CONTEXT` reads the current session schema, `USER` identifies the connected user, and `ROWNUM = 1` keeps only the best schema match. Comments explain the data in business language, so query patterns can choose the right objects and produce answers you can audit.

    ```sql
    <copy>
    WITH schema_ctx AS (
      SELECT owner AS owner_name
      FROM (
        SELECT owner
        FROM all_tables
        WHERE table_name = 'ORDERS'
          AND owner IN (USER, 'LLUSER')
        ORDER BY CASE
                   WHEN owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA') THEN 1
                   WHEN owner = USER THEN 2
                   WHEN owner = 'LLUSER' THEN 3
                   ELSE 4
                 END
      )
      WHERE ROWNUM = 1
    )
    SELECT c.table_name AS "Object",
           COALESCE(
             c.comments,
             CASE c.table_name
               WHEN 'RETAIL_FULFILLMENT_RISK_V' THEN 'Retail fulfillment risk view for inventory levels, reorder points, product demand, and fulfillment center analysis.'
               WHEN 'RETAIL_ORDER_RETURN_V' THEN 'Retail order view with return context for Ask Retail Data and dashboard narration.'
               WHEN 'RETAIL_RETURNS_WORKFLOW_V' THEN 'Retail return workflow view for return exposure, policy evidence counts, customer value, risk rating, recommendation, and status.'
               WHEN 'RETAIL_RETURN_WORKBENCH_V' THEN 'Return queue view used by retail analytics and Ask Retail Data examples.'
               WHEN 'RETAIL_SIGNAL_PRODUCT_V' THEN 'Retail signal view that maps customer and creator signal events to the products they influence, including demand momentum and return-risk context.'
               WHEN 'AGENT_ACTIONS' THEN 'Audit log of AI agent decisions and database-backed actions.'
               WHEN 'ORDERS' THEN 'Customer orders with status, revenue, demand score, fulfillment center, and optional social source.'
               WHEN 'PRODUCTS' THEN 'Retail products with category, price, tags, and brand relationship.'
               WHEN 'RETURN_DOCUMENTS' THEN 'Grounding evidence for return decisions, including policy clauses, product notes, image notes, warranty terms, marketplace context, and customer history snippets.'
               WHEN 'RETURN_REQUESTS' THEN 'Retail return requests with reason, channel, risk rating, recommendation, status, policy evidence, and confidence.'
             END
           ) AS "Business Meaning"
    FROM all_tab_comments c
    JOIN schema_ctx s ON s.owner_name = c.owner
    WHERE c.table_name IN (
      'ORDERS','PRODUCTS','RETURN_REQUESTS','RETURN_DOCUMENTS','AGENT_ACTIONS',
      'RETAIL_RETURNS_WORKFLOW_V','RETAIL_SIGNAL_PRODUCT_V',
      'RETAIL_ORDER_RETURN_V','RETAIL_FULFILLMENT_RISK_V','RETAIL_RETURN_WORKBENCH_V'
    )
    ORDER BY CASE
               WHEN c.table_name LIKE 'RETAIL_%' THEN 1
               ELSE 2
             END,
             c.table_name;
    </copy>
    ```

    Expected output:

    | Object | Business Meaning |
    | --- | --- |
    | `RETAIL_FULFILLMENT_RISK_V` | Retail fulfillment risk view for inventory levels, reorder points, product demand, and fulfillment center analysis. |
    | `RETAIL_ORDER_RETURN_V` | Retail order view with return context for Ask Retail Data and dashboard narration. |
    | `RETAIL_RETURNS_WORKFLOW_V` | Retail return workflow view for return exposure, policy evidence counts, customer value, risk rating, recommendation, and status. |
    | `RETAIL_RETURN_WORKBENCH_V` | Return queue view used by retail analytics and Ask Retail Data examples. |
    | `RETAIL_SIGNAL_PRODUCT_V` | Retail signal view that maps customer and creator signal events to the products they influence, including demand momentum and return-risk context. |
    | `AGENT_ACTIONS` | Audit log of AI agent decisions and database-backed actions. |
    | `ORDERS` | Customer orders with status, revenue, demand score, fulfillment center, and optional social source. |
    | `PRODUCTS` | Retail products with category, price, tags, and brand relationship. |
    | `RETURN_DOCUMENTS` | Grounding evidence for return decisions, including policy clauses, product notes, image notes, warranty terms, marketplace context, and customer history snippets. |
    | `RETURN_REQUESTS` | Retail return requests with reason, channel, risk rating, recommendation, status, policy evidence, and confidence. |
    {: title="Ask Retail Data Metadata"}

2. Comments and semantic views put business meaning next to the data. That matters because a question such as "Which products have return exposure?" should start from approved retail objects, not from a guess about raw table names.

## Task 3: Map questions to database objects

1. Run this query.

    This query shows the database-backed path for common Ask Retail Data questions. Each row maps a plain-English question to the Oracle objects that provide the answer. The point is not that an interface can display SQL. The point is that the answer can be traced to approved views, tables, joins, and filters in Oracle Database.

    ```sql
    <copy>
    SELECT 'Which demand signals mention damaged packaging or sizing complaints?' AS "Question",
           'RETAIL_SIGNAL_PRODUCT_V, RETURN_REQUESTS, RETURN_DOCUMENTS, PRODUCTS' AS "Approved Objects",
           'Signals, return cases, evidence documents, and product context' AS "Database Evidence"
    FROM dual
    UNION ALL
    SELECT 'Which fulfillment centers have inventory pressure?',
           'RETAIL_FULFILLMENT_RISK_V',
           'Fulfillment center inventory compared with reorder points'
    FROM dual
    UNION ALL
    SELECT 'Which products have the highest return exposure?',
           'RETAIL_RETURNS_WORKFLOW_V, RETAIL_RETURN_WORKBENCH_V',
           'Return value, risk rating, recommendation, policy evidence, and status'
    FROM dual
    UNION ALL
    SELECT 'What is the total revenue from orders with an open return?',
           'RETAIL_ORDER_RETURN_V, ORDERS, RETURN_REQUESTS',
           'Order totals connected to active return status'
    FROM dual;
    </copy>
    ```

    Expected output:

    | Question | Approved Objects | Database Evidence |
    | --- | --- | --- |
    | Which demand signals mention damaged packaging or sizing complaints? | `RETAIL_SIGNAL_PRODUCT_V`, `RETURN_REQUESTS`, `RETURN_DOCUMENTS`, `PRODUCTS` | Signals, return cases, evidence documents, and product context |
    | Which fulfillment centers have inventory pressure? | `RETAIL_FULFILLMENT_RISK_V` | Fulfillment center inventory compared with reorder points |
    | Which products have the highest return exposure? | `RETAIL_RETURNS_WORKFLOW_V`, `RETAIL_RETURN_WORKBENCH_V` | Return value, risk rating, recommendation, policy evidence, and status |
    | What is the total revenue from orders with an open return? | `RETAIL_ORDER_RETURN_V`, `ORDERS`, `RETURN_REQUESTS` | Order totals connected to active return status |
    {: title="Question to Database Evidence Map"}

2. Read the map from left to right. The business question is useful because the database already has a safe path to the evidence. The semantic views reduce join ambiguity, the comments explain meaning, and the SQL keeps the result inspectable.

## Task 4: Answer a signal question with database-backed SQL
1. Use the live Ask Retail Data context from Figure 1 before you run the SQL.

2. Run this repeatable version of the current prompt, "Which demand signals mention damaged packaging or sizing complaints?"

    This is a stable SQL equivalent of an Ask Retail Data question. It turns three database-backed sources into one searchable result: social signals, return requests, and return evidence documents. `UNION ALL` stacks those sources into one shape. `LOWER` normalizes text for matching, `LIKE` finds the requested topics, and the `CASE` expression labels each row as damaged packaging or sizing-related evidence.

    ```sql
    <copy>
    SELECT signal_source AS "Source",
           signal_id AS "Signal ID",
           product_name AS "Product",
           category AS "Category",
           CASE
             WHEN search_text LIKE '%damag%'
               OR search_text LIKE '%packag%'
               OR search_text LIKE '%dented%'
               OR search_text LIKE '%cracked%'
               OR search_text LIKE '%crushed%'
             THEN 'Damaged packaging'
             ELSE 'Sizing complaint'
           END AS "Matched Topic",
           signal_strength AS "Signal Strength",
           signal_text AS "Signal Text"
    FROM (
      SELECT 'Social signal' AS signal_source,
             TO_CHAR(rsp.signal_id) AS signal_id,
             NVL(rsp.product_name, 'Unmapped product') AS product_name,
             NVL(rsp.category, 'Unmapped') AS category,
             NVL(rsp.virality_score, 0) AS signal_strength,
             TO_CHAR(SUBSTR(rsp.signal_text, 1, 240)) AS signal_text,
             LOWER(TO_CHAR(SUBSTR(rsp.signal_text, 1, 4000))) AS search_text
      FROM retail_signal_product_v rsp
      UNION ALL
      SELECT 'Return request' AS signal_source,
             TO_CHAR(rr.return_id) AS signal_id,
             p.product_name,
             p.category,
             NVL(rr.return_value, 0) AS signal_strength,
             rr.return_reason || ': ' || TO_CHAR(SUBSTR(rr.damage_description, 1, 220)) AS signal_text,
             LOWER(rr.return_reason || ' ' || TO_CHAR(SUBSTR(rr.damage_description, 1, 4000))) AS search_text
      FROM return_requests rr
      JOIN products p ON p.product_id = rr.product_id
      UNION ALL
      SELECT 'Return evidence' AS signal_source,
             TO_CHAR(rd.document_id) AS signal_id,
             p.product_name,
             p.category,
             ROUND(NVL(rd.similarity_score, 0) * 100, 2) AS signal_strength,
             rd.title || ': ' || TO_CHAR(SUBSTR(rd.excerpt, 1, 220)) AS signal_text,
             LOWER(rd.title || ' ' || TO_CHAR(SUBSTR(rd.excerpt, 1, 4000))) AS search_text
      FROM return_documents rd
      JOIN return_requests rr ON rr.return_id = rd.return_id
      JOIN products p ON p.product_id = rr.product_id
    )
    WHERE search_text LIKE '%damag%'
       OR search_text LIKE '%packag%'
       OR search_text LIKE '%dented%'
       OR search_text LIKE '%cracked%'
       OR search_text LIKE '%crushed%'
       OR search_text LIKE '%sizing%'
       OR search_text LIKE '%size chart%'
       OR search_text LIKE '%fit issue%'
       OR search_text LIKE '%fit complaint%'
       OR search_text LIKE '%too small%'
       OR search_text LIKE '%too large%'
    ORDER BY "Signal Strength" DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Source | Signal ID | Product | Category | Matched Topic | Signal Strength | Signal Text |
    | --- | --- | --- | --- | --- | ---: | --- |
    | Return request | 3 | Smart Herb Garden | Home | Damaged packaging | 209.97 | Missing accessories: Electronics return package is missing charging cable and the serial number does not match the original outbound scan. |
    | Return request | 5 | NovaWatch Ultra | Electronics | Sizing complaint | 199.98 | Product not as described: Customer cites inaccurate size chart for a preferred-tier order. Similar complaints appeared in recent product reviews. |
    | Return request | 2 | UltraWide Curved 34 | Gaming | Sizing complaint | 179.99 | Size and fit issue: Apparel was tried on but tags appear attached. Return was initiated 18 days after delivery from a store kiosk. |
    | Return evidence | 1 | Quantum Processor Desktop | Electronics | Damaged packaging | 96.41 | VIP save-the-customer override: High lifetime value customer with low risk and visible carrier damage is eligible for instant credit while the claim is routed to carrier recovery. |
    | Return evidence | 2 | Quantum Processor Desktop | Electronics | Damaged packaging | 93.88 | Package damage classifier: Vision tag: `crushed_corner`, `cracked_shell`, `carrier_label_visible.` Damage timestamp aligns with final-mile scan exception. |
    | Return evidence | 7 | NovaWatch Ultra | Electronics | Sizing complaint | 86.21 | Similar size chart complaints: Vector search found nine recent review snippets about inaccurate sizing for adjacent products in the same category. |
    | Return request | 1 | Quantum Processor Desktop | Electronics | Damaged packaging | 69.99 | Arrived damaged: Customer uploaded photos showing a dented package and cracked product shell. Carrier scan shows delayed handoff at the regional hub. |
    {: title="Demand Signal SQL"}

3. Read the result as an audit trail for the answer. The **Source** column shows where the evidence came from. **Matched Topic** shows how the SQL classified the text. **Signal Strength** gives the sort value used to rank the result. The answer stays grounded in Oracle data because the rows come from approved views and tables, not from a generated narrative.

## Task 5: Answer a fulfillment risk question with database-backed SQL

1. Run this repeatable version of the prompt, "Which fulfillment centers have inventory pressure?"

    The answer should start from inventory evidence. This block queries the fulfillment risk view, filters to rows already labeled `AT_RISK`, then groups by fulfillment center. `COUNT(*)` shows how many products are under pressure at each center. `MIN(quantity_on_hand)` shows the lowest available inventory among those products. The result shows how a plain-English risk question maps to a governed database view.

    ```sql
    <copy>
    SELECT center_name AS "Center",
           city AS "City",
           COUNT(*) AS "At-Risk Products",
           MIN(quantity_on_hand) AS "Lowest On Hand"
    FROM retail_fulfillment_risk_v
    WHERE inventory_risk = 'AT_RISK'
    GROUP BY center_name, city
    ORDER BY COUNT(*) DESC, MIN(quantity_on_hand)
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Center | City | At-Risk Products | Lowest On Hand |
    | --- | --- | ---: | ---: |
    | Seattle Pacific NW | Kent | 11 | 12 |
    | Reno West Hub | Sparks | 11 | 15 |
    | Dallas South Central | Lancaster | 10 | 12 |
    | Chicago Midwest Hub | Joliet | 10 | 12 |
    | Portland Pacific | Troutdale | 9 | 10 |
    | Tampa Florida | Brandon | 9 | 11 |
    | Columbus Midwest | Etna | 9 | 12 |
    | Baltimore East Coast | Aberdeen | 9 | 13 |
    | LA Mega Center | Ontario | 9 | 14 |
    | Philadelphia Mid-Atlantic | Middletown | 8 | 11 |
    {: title="Fulfillment Risk SQL"}

2. Required student steps do not call `DBMS_CLOUD_AI.GENERATE`, `CREATE_PROFILE`, `ENABLE_PROFILE`, or `SET_PROFILE`. This lab focuses on the database foundation: approved views, useful comments, stable SQL equivalents, and read-only query patterns that keep the answer traceable.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
