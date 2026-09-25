# Governed Data Copilot: Trusted Answers

## Introduction

This lab prepares governed questions for a data copilot workflow. Reframe this as a trust pattern: *Natural-language answers are acceptable in finance only when the approved data boundary and SQL path remain visible.*

Natural-language answers are useful only when risk and governance teams can review the source. This lab shows how a copilot-style answer can stay grounded in approved views and visible SQL instead of relying on untraceable generated text.

This lab follows prediction because answers are only useful if decision-makers can review the data boundary. The copilot pattern here is not "ask anything"; it is "ask against approved finance views and show the SQL."

![Governed Data Copilot question examples](images/governed-data-copilot.png " ")

### Objectives

- List approved finance views.
- Run a trusted answer query that could back a copilot response.

Estimated Time: **8 minutes**

### Operating Story

| Step | Finance focus |
| --- | --- |
| Business Problem | Business users want natural-language answers, but risk teams need approved data boundaries. |
| Technical Challenge | AI teams need copilot answers that expose SQL and stay inside approved semantic views instead of relying on opaque prompt output. |
| Persona Focus | Business users ask questions; AI engineers and database developers enforce governed data boundaries and reviewable evidence. |
| What You Will Prove | Trusted answers can be grounded in finance semantic views and explicit SQL. |
| Database Capability | Semantic finance views and catalog comments expose controlled business meaning. |
| Outcome | Copilot-style answers can be reviewed, repeated, and governed. |

Persona focus: You support business users who want natural-language answers while proving to risk and governance teams that every answer has visible SQL behind it.

## Task 1: Review approved finance views

Perform the following set of steps to review the approved finance views before asking business questions:

1. Run this catalog query:

    ```sql
    <copy>
    SELECT view_name,
           text_length
    FROM user_views
    WHERE view_name LIKE 'FINANCE_%'
       OR view_name IN (
         'RISK_SIGNALS_V','SIGNAL_SOURCES_V','CLIENT_TRANSACTIONS_V',
         'SERVICE_CENTERS_V','SERVICE_CAPACITY_V','SERVICE_ROUTES_V'
       )
    ORDER BY view_name;
    </copy>
    ```

    **Expected output: Governed View Comments**

    | View Name | Text Length |
    | --- | --- |
    | CLIENT\_TRANSACTIONS\_V | 326 |
    | FINANCE\_INSTITUTIONS\_V | 158 |
    | FINANCE\_PRODUCTS\_V | 214 |
    | RISK\_SIGNALS\_V | 528 |
    | SERVICE\_CAPACITY\_V | 360 |
    | SERVICE\_CENTERS\_V | 547 |
    | SERVICE\_ROUTES\_V | 329 |
    | SIGNAL\_SOURCES\_V | 481 |


2. Treat these views as the approved data boundary.
    The query lists the approved view surface before any business question is answered. That gives AI engineers a concrete allowlist instead of relying on prompt instructions alone.

    These views expose finance language for institutions, products, signals, transactions, service centers, capacity, and routes. They are the objects a governed copilot should prefer because they already encode business meaning and hide lower-level implementation details.

    This matters in the broader workshop because the same foundation that supports dashboards and agents also constrains AI answers to approved database evidence.

**Note:** Sample values may change after data refreshes or rebuilds. Focus on the expected result pattern and the business takeaway, not the exact values.

## Task 2: Ground a natural-language question in SQL

Perform the following set of steps to ground a natural-language finance question in visible SQL:

1. For the question "Which product categories have the highest current risk exposure?", run visible SQL.

    ```sql
    <copy>
    SELECT fp.product_category,
           COUNT(DISTINCT rs.signal_id) AS signal_count,
           ROUND(AVG(rs.criticality_score), 1) AS avg_criticality,
           SUM(rs.exposure_count) AS exposure_count
    FROM risk_signals_v rs
    JOIN post_product_mentions ppm ON ppm.post_id = rs.signal_id
    JOIN finance_products_v fp ON fp.financial_product_id = ppm.product_id
    GROUP BY fp.product_category
    ORDER BY exposure_count DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: Exposure by Product Category**

    | Product Category | Signal Count | Avg Criticality | Exposure Count |
    | --- | --- | --- | --- |
    | Compliance Services | 174 | 42.1 | 127777803 |
    | Payments | 214 | 41.1 | 113565293 |
    | Risk Analytics | 198 | 41.2 | 93531273 |
    | Consumer Lending | 171 | 42.6 | 88437900 |
    | Capital Markets | 158 | 40.5 | 64735955 |
    | Wealth Management | 117 | 41.9 | 60648625 |
    | Investments | 170 | 41 | 59359773 |
    | Commercial Lending | 180 | 41.3 | 52379514 |
    | Specialty Finance | 54 | 42.9 | 51785604 |
    | Cards and Payments | 132 | 41.6 | 49978774 |


2. Use the result to draft a governed answer.
    The SQL groups risk exposure at the product-category level, which is the kind of summary a business user may ask for in natural language. The visible query makes the answer repeatable and reviewable.

    A governed answer should cite the rows and avoid claiming access to objects outside the approved set. For example, the answer can say which product categories have the highest exposure, how many signals support the ranking, and what average criticality was observed.

    The returned table is relevant because it gives a business user an answer and gives reviewers the SQL evidence behind that answer. The copilot pattern is trustworthy only when both are present.

**Note:** Sample values may change after data refreshes or rebuilds. Focus on the expected result pattern and the business takeaway, not the exact values.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
