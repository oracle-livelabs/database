# Ask Manufacturing Questions with Select AI

![Nina: manufacturing lab banner](images/nina.png)

## Introduction

> **Validation status:** The manual LLUSER walkthrough and authentic manufacturing captures are recorded in the [validation report](../validation/validation-report.md). Green-button and Terraform provisioning remain untested.

Nina Patel is a production analyst at SEER MANUFACTURING. She wants to ask about components and production orders without writing every table join and filter herself.

Jessica, the DBA, has already configured a Select AI profile for the manufacturing schema. Nina can ask a question in ordinary language. Select AI uses the profile and the database metadata to generate SQL, run it, or explain the result.

Nina still needs to review the generated SQL. The model can misunderstand a question or choose the wrong columns. The useful pattern is simple: ask a question, inspect the SQL, run it only when it makes sense, and refine the question when the result is not what the business user needs.

In this lab, you check the available Select AI profile, ask a manufacturing question, inspect the SQL behind the answer, and improve the question for a more useful business result.


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
- Add the manufacturing tables that Select AI may use to the profile.
- Generate SQL from a manufacturing question and inspect it.
- Run a natural-language question through `DBMS_CLOUD_AI.GENERATE`.
- Refine a question to include the component, order, and cost details Nina needs.
- Explain why generated SQL still requires review.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step                | Manufacturing focus                                                                                |
| ---------------------| ----------------------------------------------------------------------------------------------|
| Business Problem    | Nina needs answers from manufacturing data without writing every query from scratch.               |
| Technical Challenge | Select AI must choose the correct tables, joins, and filters for Nina’s question.                |
| Persona Focus       | You follow Nina as she checks, reviews, and improves a Select AI question.                   |
| What You Will See   | A natural-language question becomes SQL that can be inspected and run in the database.       |
| Database Capability | Select AI, `DBMS_CLOUD_AI`, AI profiles, and natural-language-to-SQL generation.             |
| Outcome             | Nina gets a repeatable way to ask manufacturing questions while keeping SQL review in the process. |

> **SQL Worksheet reminder:** See [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the steps to paste and run SQL.

## Task 1: Check the Select AI profile

Select AI uses an AI profile to identify the AI provider and the database objects available for natural-language questions. The workshop database should already contain a profile for the `LLUSER` schema.

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

## Task 2: Add the manufacturing tables to the profile

The profile needs a list of tables that Select AI may use. Nina's questions require component, production order, production-order-line, and customer site data, so Jessica adds those four tables to the `GENAI` profile.

1. Add the manufacturing tables to the profile:

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

    ![ai object list](images/sql-ai-object-list.png)

    

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

    ![ai generated](images/sql-ai-generated.png)

    
  
    

2. Read the generated SQL before running it.

    Check that the statement joins `COMPONENTS`, `PRODUCTION_ORDER_LINES`, and `PRODUCTION_ORDERS`, groups by component, returns five rows, sums LINE_TOTAL, and filters the stated production order statuses. Exclude SETUP_COST from material value. Select AI can generate a valid-looking statement that does not answer the question precisely, so the generated SQL is part of the result Nina reviews.

## Task 4: Run the question in the database

Nina has reviewed the SQL. She now asks Select AI to run the question and return the database result.

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

    ![ai answer](images/sql-ai-answer.png)

    
  
    

2. Compare the answer with the SQL you inspected in Task 3.

    Select AI has generated and run SQL against the manufacturing schema. The query still runs under Nina's database privileges, and the result comes from the database tables rather than from a separate copy of the manufacturing data.

    > **Note:** Select AI can generate incorrect SQL or misunderstand a question. Use `showsql` when the exact query matters, and treat the generated answer as a starting point for review.

## Task 5: Improve the business question

Nina's first question gives her a component ranking, but she also needs enough detail to decide what to review. She changes the question to request the component category, total material value, and planned units.

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

    ![ai refined generated](images/sql-ai-refined-generated.png)

    
  
    

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

    ![ai refined answer](images/sql-ai-refined-answer.png)

    
  
    

3. Compare the first and second questions.

  The revised prompt asks for the columns Nina needs in her review. She still checks that the SQL uses the right joins, totals, and production order statuses.

## Task 6: Explain the result

Nina wants a short explanation of the revised result. Select AI can run the SQL and ask the AI provider to describe the returned rows.

1. Run the revised question with the `narrate` action:

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show the five components with the highest scheduled material value. Include component name, category, summed line_total, and summed quantity. Include only released, in_production, or completed production_orders; exclude setup costs. Status values are case-sensitive lowercase strings: use order_status IN (''released'', ''in_production'', ''completed'') exactly; do not uppercase them.',
             profile_name => 'genai',
             action       => 'narrate'
           ) AS explanation;
    </copy>
    ```

    ![ai narration](images/sql-ai-narration.png)

    
  
    

2. Review the explanation against the SQL result.

  The explanation is a convenience for a production analyst. The SQL result remains the record Nina can inspect, repeat, and use to check whether the explanation is accurate.

  > **Note:** The `narrate` action sends the query result to the AI provider configured in the profile. Use it only for data approved for that provider.

## Conclusion: Ask, Inspect, and Refine

Nina asked a manufacturing question, inspected the generated SQL, ran it, and refined the prompt. Select AI reduced the SQL she needed to write. Reviewing the query helped her check that it answered her question.

Nina can ask questions in ordinary language and inspect the queries behind the answers. The queries use the shared manufacturing schema and run with the database user’s access rights.

Select AI does not replace judgment. A good workflow is to show the SQL, check the tables and filters, run the statement, and compare the answer with the business question.

## Next Steps

For the full list of Select AI actions, profile attributes, and supported providers, see the [Oracle AI Database 26ai Select AI documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/).

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026
