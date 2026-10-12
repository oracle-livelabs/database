# Ask HighTech Questions with Select AI

![Nina: HighTech lab banner](images/nina-hightech.png)

## Introduction

Nina Patel, SEER HIGHTECH’s production analyst, wants answers about components and production orders without writing every join and filter. Jessica has configured a Select AI profile for the HighTech schema.

You will help Nina ask a question, inspect the generated SQL, run it, and refine the result. The model can choose the wrong columns or misunderstand a question, so SQL review remains part of her work.

<details>
<summary><strong>Key terms: Select AI, AI profile, generated SQL, and natural-language prompt</strong></summary>

> - **Select AI** lets a user work with database information through a natural-language question.
>
> - An **AI profile** connects Select AI to an AI provider and identifies the database objects that may be used for the question.
>
> - **Generated SQL** is the SQL statement created from the question. Nina should inspect it before relying on the result.
>
> - A **natural-language prompt** is the question sent to Select AI, such as `Which five components have the highest scheduled material value? Sum production_order_lines.line_total only for released, in_production, or completed production_orders.`

</details>

### Objectives

- Check which Select AI profile is available in the schema.
- Add the HighTech tables that Select AI may use to the profile.
- Generate SQL from a HighTech question and inspect it.
- Run a natural-language question through `DBMS_CLOUD_AI.GENERATE`.
- Refine a question to include the component, order, and cost details Nina needs.
- Explain why generated SQL still requires review.

Estimated Time: **10 minutes**


> **SQL Worksheet reminder:** See [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the steps to paste and run SQL.

## Task 1: Check the Select AI profile

Check the profile already configured for `LLUSER`.

1. Run this query:

    ```sql
    <copy>
    SELECT profile_name,
           status,
           description
    FROM user_cloud_ai_profiles
    ORDER BY profile_name;
    </copy>
    ```

    The workshop profile is expected to be named `GENAI`. Confirm that it is enabled. The AI model must also support on-demand inference in the profile’s region. Use the provider, model, and region approved for your workshop environment. Check [Oracle’s regional model availability](https://docs.oracle.com/en-us/iaas/Content/generative-ai/model-endpoint-regions.htm) before deployment; a model appearing in the catalog does not necessarily support on-demand calls in that region. If the query shows a different profile name, use that name in the following tasks.

2. Review the profile attributes:

    ```sql
    <copy>
    SELECT profile_name,
           attribute_name,
           attribute_value
    FROM user_cloud_ai_profile_attributes
    ORDER BY profile_name, attribute_name;
    </copy>
    ```

    The attributes show how the profile is configured and which database objects are available to Select AI. Do not copy credentials. In Task 2, you will change only the profile's `object_list`.

## Task 2: Add the HighTech tables to the profile

Jessica adds the four tables Nina needs: components, production orders, order lines, and customer sites.

1. Add the HighTech tables to the profile:

    ```sql
    <copy>
    BEGIN
      DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name    => 'genai',
        attribute_name  => 'object_list',
        attribute_value => '[{"owner": "' || USER || '", "name": "COMPONENTS"}, {"owner": "' || USER || '", "name": "PRODUCTION_ORDERS"}, {"owner": "' || USER || '", "name": "PRODUCTION_ORDER_LINES"}, {"owner": "' || USER || '", "name": "CUSTOMER_SITES"}]'
      );
    END;
    /
    </copy>
    ```

2. Confirm the object list:

    ```sql
    <copy>
    SELECT profile_name,
           attribute_name,
           attribute_value
    FROM user_cloud_ai_profile_attributes
    WHERE profile_name = 'GENAI'
      AND attribute_name = 'object_list';
    </copy>
    ```

    ![Select AI profile object list for the HighTech tables](images/sql-ai-object-list.png)

    The result should list `COMPONENTS`, `PRODUCTION_ORDERS`, `PRODUCTION_ORDER_LINES`, and `CUSTOMER_SITES`. Select AI can now use these tables when it translates Nina's questions into SQL.

## Task 3: Ask a question and inspect the SQL

Order statuses are stored in lowercase. Keep the exact-value instruction in each prompt and check the generated predicate before running it. Uppercase literals can return no rows because string comparisons are case-sensitive.

Nina starts with a simple question: which components have the highest scheduled material value? She first asks Select AI to show the SQL without running it.

Database Actions does not support the `SELECT AI` keyword. In SQL Worksheet, use `DBMS_CLOUD_AI.GENERATE` and provide the profile name directly.

1. Run the question with the `GENAI` profile:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Which five components have the highest scheduled material value? Sum production_order_lines.line_total only for released, in_production, or completed production_orders. Status values are case-sensitive lowercase strings: use order_status IN (''released'', ''in_production'', ''completed'') exactly; do not uppercase them.',
             profile_name => 'genai',
             action       => 'showsql'
           ) AS generated_sql;
    </copy>
    ```

    ![SQL generated for the scheduled material-value question](images/sql-ai-generated.png)

2. Read the generated SQL before running it.

    Check that the statement joins `COMPONENTS`, `PRODUCTION_ORDER_LINES`, and `PRODUCTION_ORDERS`, groups by component, returns five rows, sums `LINE_TOTAL`, and filters the stated production order statuses. Exclude `SETUP_COST` from material value. Select AI can generate a valid-looking statement that does not answer the question precisely, so the generated SQL is part of the result Nina reviews.

## Task 4: Run the question in the database

Nina now runs the question and compares the answer with the SQL she inspected.

1. Run the same question with the `runsql` action:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Which five components have the highest scheduled material value? Sum production_order_lines.line_total only for released, in_production, or completed production_orders. Status values are case-sensitive lowercase strings: use order_status IN (''released'', ''in_production'', ''completed'') exactly; do not uppercase them.',
             profile_name => 'genai',
             action       => 'runsql'
           ) AS answer;
    </copy>
      ```

    ![Select AI result for the scheduled material-value question](images/sql-ai-answer.png)

2. Compare the answer with the SQL you inspected in Task 3.

    Select AI has generated and run SQL against the HighTech schema. The query still runs under Nina's database privileges, and the result comes from the database tables rather than from a separate copy of the HighTech data.

## Task 5: Improve the business question

Nina adds category, total material value, and planned units to make the ranking useful for her review.

1. Use `showsql` to inspect this revised prompt:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show the five components with the highest scheduled material value. Include component name, category, summed line_total, and summed quantity. Include only released, in_production, or completed production_orders; exclude setup costs. Status values are case-sensitive lowercase strings: use order_status IN (''released'', ''in_production'', ''completed'') exactly; do not uppercase them.',
             profile_name => 'genai',
             action       => 'showsql'
           ) AS generated_sql;
    </copy>
    ```

    ![SQL generated for the refined component-ranking question](images/sql-ai-refined-generated.png)

2. Review the generated SQL, then run the revised question with `runsql`:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show the five components with the highest scheduled material value. Include component name, category, summed line_total, and summed quantity. Include only released, in_production, or completed production_orders; exclude setup costs. Status values are case-sensitive lowercase strings: use order_status IN (''released'', ''in_production'', ''completed'') exactly; do not uppercase them.',
             profile_name => 'genai',
             action       => 'runsql'
           ) AS answer;
    </copy>
    ```

    ![Select AI result for the refined component-ranking question](images/sql-ai-refined-answer.png)

3. Compare the first and second questions.

  The revised prompt asks for the columns Nina needs in her review. She still checks that the SQL uses the right joins, totals, and production order statuses.

## Task 6: Explain the result

Nina wants a short explanation of the revised result. Select AI can run the SQL and ask the AI provider to describe the returned rows.

1. Run the revised question with the `narrate` action:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show the five components with the highest scheduled material value. Include component name, category, summed line_total, and summed quantity. Include only released, in_production, or completed production_orders; exclude setup costs. Status values are case-sensitive lowercase strings: use order_status IN (''released'', ''in_production'', ''completed'') exactly; do not uppercase them. Return one table with exactly five data rows and columns component_name, category, total_material_value and planned_units, followed by one explanatory sentence. total_material_value is SUM(production_order_lines.line_total); planned_units is SUM(production_order_lines.quantity). Include both numeric totals for every component exactly as returned by the query, without rounding or abbreviation. Do not omit the table or substitute a prose-only summary. If a requested value is missing, state that the answer is incomplete rather than inventing it.',
             profile_name => 'genai',
             action       => 'narrate'
           ) AS explanation;
    </copy>
    ```

    ![Select AI narrative for the refined HighTech result](images/sql-ai-narration.png)

2. Review the explanation against the SQL result.

    Nina checks all five rows against the SQL result: names, categories, ranking and all ten numeric totals. If any value is missing or differs, use the verified SQL result for her decision.

  > **Note:** The `narrate` action sends the query result to the AI provider configured in the profile. Use it only for data approved for that provider.


## Next Steps

For the full list of Select AI actions, profile attributes, and supported providers, see the [Oracle AI Database 26ai Select AI documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/).

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026
