# Ask Retail Data

## Introduction

A retail business analyst, merchandising operations lead, customer service analyst, or store operations manager often needs an answer before a custom report can be built. Natural-language data access creates governance risk if a model generates invalid SQL, references the wrong tables, hides its logic, or exposes more data than the user should see.

Oracle AI Database helps by keeping query execution grounded in the live retail schema. In the application, Ask Retail Data can show SQL before execution and can run read-only SQL against governed data. In this lab, you inspect the semantic views, comments, and query surfaces that ground those questions safely.

Estimated Time: 8 minutes

### Objectives

- Inspect semantic views used to ground retail questions.
- Read schema comments that guide natural-language SQL generation.
- Run deterministic SQL that answers current Ask Retail Data prompts.
- Explain why visible SQL improves governance for natural-language data access.


## Task 1: Inspect semantic views for Ask Retail Data
1. Review the related application screen before you run the SQL.

    ![Ask Retail Data workspace with query modes](images/ask-retail-data-workspace.png " ")

    *Figure 1: Ask Retail Data exposes runtime profile, modes, and example questions.*

2. Run this query.

    ```sql
    <copy>
    SELECT view_name AS "View", text_length AS "SQL Text"
    FROM all_views
    WHERE owner = 'RETAILDB'
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
    {: title="Ask Retail Semantic Views"}

3. Ask Retail Data should ground answers in these views and metadata, not in an uncontrolled data copy.

## Task 2: Read comments used for grounding

1. Run this query.

    ```sql
    <copy>
    SELECT table_name AS "Table",
           comments AS "Business Meaning"
    FROM all_tab_comments
    WHERE owner = 'RETAILDB'
      AND table_name IN ('ORDERS','PRODUCTS','RETURN_REQUESTS','AGENT_ACTIONS')
    ORDER BY table_name;
    </copy>
    ```

    Expected output:

    | Table | Business Meaning |
    | --- | --- |
    | `AGENT_ACTIONS` | Audit log of AI agent decisions and database-backed actions. |
    | ORDERS | Customer orders with status, revenue, demand score, fulfillment center, and optional social source. |
    | PRODUCTS | Retail products with category, price, tags, and brand relationship. |
    | `RETURN_REQUESTS` | Retail return requests with reason, channel, risk rating, recommendation, status, policy evidence, and confidence. |
    {: title="Grounding Comments for Retail Tables"}

2. Good comments and semantic views help AI-assisted interfaces generate safer SQL because the database exposes business meaning with the data.

## Task 3: Answer a signal question with visible SQL
1. Use the live Ask Retail Data context from Figure 1 before you run the SQL.

2. Run this deterministic version of the current prompt, "Which demand signals mention damaged packaging or sizing complaints?"

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
      FROM RETAILDB.retail_signal_product_v rsp
      UNION ALL
      SELECT 'Return request' AS signal_source,
             TO_CHAR(rr.return_id) AS signal_id,
             p.product_name,
             p.category,
             NVL(rr.return_value, 0) AS signal_strength,
             rr.return_reason || ': ' || TO_CHAR(SUBSTR(rr.damage_description, 1, 220)) AS signal_text,
             LOWER(rr.return_reason || ' ' || TO_CHAR(SUBSTR(rr.damage_description, 1, 4000))) AS search_text
      FROM RETAILDB.return_requests rr
      JOIN RETAILDB.products p ON p.product_id = rr.product_id
      UNION ALL
      SELECT 'Return evidence' AS signal_source,
             TO_CHAR(rd.document_id) AS signal_id,
             p.product_name,
             p.category,
             ROUND(NVL(rd.similarity_score, 0) * 100, 2) AS signal_strength,
             rd.title || ': ' || TO_CHAR(SUBSTR(rd.excerpt, 1, 220)) AS signal_text,
             LOWER(rd.title || ' ' || TO_CHAR(SUBSTR(rd.excerpt, 1, 4000))) AS search_text
      FROM RETAILDB.return_documents rd
      JOIN RETAILDB.return_requests rr ON rr.return_id = rd.return_id
      JOIN RETAILDB.products p ON p.product_id = rr.product_id
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
    {: title="Visible SQL for Demand Signals"}

3. The first row is the key demo point: Smart Herb Garden has a return request worth 209.97, classified as damaged packaging, with evidence about a missing charging cable and a serial-number mismatch. The value is not only convenience. The page makes the SQL path visible, uses read-only execution, and keeps the answer grounded in Oracle data rather than treating the language model response as the source of truth.

## Task 4: Answer a fulfillment risk question with visible SQL

1. Run this deterministic version of the prompt, "Which fulfillment centers have inventory pressure?"

    ```sql
    <copy>
    SELECT center_name AS "Center",
           city AS "City",
           COUNT(*) AS "At-Risk Products",
           MIN(quantity_on_hand) AS "Lowest On Hand"
    FROM RETAILDB.retail_fulfillment_risk_v
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
    {: title="Visible SQL for Fulfillment Risk"}

2. Required student steps do not call `DBMS_CLOUD_AI.GENERATE`, `CREATE_PROFILE`, `ENABLE_PROFILE`, or `SET_PROFILE`. Live generation depends on profile ownership and OCI Generative AI configuration, so this lab teaches the safe deterministic grounding path.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
