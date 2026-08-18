# Ask Governed Finance Questions with Select AI

## Introduction

Risk analysts often know the business question they need answered before they know the joins, filters, and aggregations required to answer it. In this lab, you work in Oracle Machine Learning (OML) and compare three Oracle Select AI actions against the Seer Bank finance scenario:

- `SELECT AI CHAT` answers a general finance question without querying Seer Bank data.
- `SELECT AI SHOWSQL` turns a natural-language finance question into reviewable SQL.
- `SELECT AI NARRATE` queries approved finance objects and explains the result.

This follows the AI4U *Why Agents Beat Zero-Shot Prompts* pattern while using the existing Finance LiveStack dataset instead of creating a separate sample application or loan table.

> **Important:** Select AI output is generated. Wording and aliases can vary, but the approved object boundary, generated SQL, and database result remain reviewable.

### Objectives

- Import and run the supplied finance notebook in OML.
- Use `SELECT AI CHAT` for a general finance question.
- Compare the chat response with governed Select AI access to Seer Bank data.
- Review generated SQL before trusting the natural-language answer.
- Confirm that Select AI remains read-only.

Estimated Time: **18 minutes**

### Operating Story

| Step | Finance focus |
| --- | --- |
| Business Problem | Risk analysts need fast answers without losing the governed evidence behind a decision. |
| Technical Challenge | Natural-language questions must stay inside an approved data boundary and produce reviewable SQL. |
| Persona Focus | A risk analyst asks the question; an AI engineer controls the profile and approved objects. |
| What You Will Prove | Chat can explain general finance concepts, while Select AI can query Seer Bank data without gaining write access. |
| Database Capability | Oracle Select AI, `DBMS_CLOUD_AI`, finance semantic views, schema comments, and OML notebooks. |
| Outcome | Analysts receive a natural-language answer while reviewers retain the SQL and database evidence. |

Persona focus: You are the AI engineer helping a Seer Bank risk analyst move from a general question to an answer grounded in approved finance data.

## Task 1: Import the Finance Select AI Notebook

AI4U runs the hands-on experience from an imported OML notebook. The Finance workshop uses the same paragraph-by-paragraph workflow.

1. Download [finance-select-ai-notebook.json](files/finance-select-ai-notebook.json).

2. From the Oracle Machine Learning home page, click **Notebooks**.

    ![Oracle Machine Learning Notebooks page](images/oml-notebooks-home.png " ")

3. Click **Import** and select **From File**.

    ![Import a notebook in Oracle Machine Learning](images/oml-import-notebook.png " ")

4. Choose `finance-select-ai-notebook.json`.

    ![Choose the finance notebook file](images/oml-import-file.png " ")

5. Open the imported notebook.

    ![Open the imported Oracle Machine Learning notebook](images/oml-open-notebook.png " ")

Run each notebook paragraph when the matching workshop step tells you to continue.

## Task 2: Experience Select AI Chat

`SELECT AI CHAT` sends a prompt to the configured language model without using Seer Bank tables. It is useful for general explanations, but it cannot prove what is happening in Seer Bank's current data.

1. Activate the finance AI profile.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI.SET_PROFILE('FINANCE_V2_GENAI');
    </copy>
    ```

    **Expected result:** The paragraph completes successfully and `FINANCE_V2_GENAI` becomes the active profile for the OML session.

2. Ask a general finance question.

    ```sql
    <copy>
    SELECT AI CHAT
      What business factors commonly increase fraud and compliance risk at a financial institution?
    </copy>
    ```

    **Expected result:** Select AI Chat returns a general explanation of finance risk factors. The generated wording can vary.

3. Ask Chat a question that requires Seer Bank data.

    ```sql
    <copy>
    SELECT AI CHAT
      Which Seer Bank risk signal currently has the highest criticality score?
    </copy>
    ```

    **Expected result:** Chat cannot provide a verifiable answer from Seer Bank's current rows because the `CHAT` action does not query the approved database objects.

This is the AI4U zero-shot comparison: Chat can explain, but it does not supply database evidence.

## Task 3: Verify the Governed Finance Boundary

1. Verify that the finance profile is enabled.

    ```sql
    <copy>
    SELECT profile_name,
           status
    FROM user_cloud_ai_profiles
    WHERE profile_name = 'FINANCE_V2_GENAI';
    </copy>
    ```

    **Expected output:**

    | Profile Name | Status |
    | --- | --- |
    | FINANCE\_V2\_GENAI | ENABLED |

2. Confirm that the approved Finance LiveStack objects exist.

    ```sql
    <copy>
    SELECT object_name,
           object_type
    FROM user_objects
    WHERE object_name IN (
      'FINANCE_PRODUCTS_V',
      'RISK_SIGNALS_V',
      'SIGNAL_SOURCES_V',
      'POST_PRODUCT_MENTIONS',
      'AGENT_ACTIONS'
    )
    ORDER BY object_name;
    </copy>
    ```

    **Expected output:** Five approved finance objects are returned. Select AI uses these existing workshop objects rather than a separate demonstration table.

## Task 4: Query Seer Bank Data with Select AI

1. Ask Select AI to show the SQL before it runs.

    ```sql
    <copy>
    SELECT AI SHOWSQL
      Which Seer Bank product categories have the highest current risk exposure?
    </copy>
    ```

    **Expected result:** Select AI generates a read-only statement over approved finance objects. Table aliases and SQL shape can vary.

2. Review the generated statement. Confirm that it does not contain `INSERT`, `UPDATE`, `DELETE`, `MERGE`, or DDL.

3. Ask Select AI to query the data and narrate the result.

    ```sql
    <copy>
    SELECT AI NARRATE
      Which Seer Bank product categories have the highest current risk exposure?
    </copy>
    ```

    **Expected result:** Select AI returns a natural-language explanation grounded in the current Seer Bank rows. The wording can vary.

4. Run the stable SQL evidence query.

    ```sql
    <copy>
    SELECT fp.product_category,
           COUNT(DISTINCT rs.signal_id) AS signal_count,
           ROUND(AVG(rs.criticality_score), 1) AS avg_criticality,
           SUM(rs.exposure_count) AS exposure_count
    FROM risk_signals_v rs
    JOIN post_product_mentions ppm
      ON ppm.post_id = rs.signal_id
    JOIN finance_products_v fp
      ON fp.financial_product_id = ppm.product_id
    GROUP BY fp.product_category
    ORDER BY exposure_count DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output:** The query returns up to five product categories ordered by exposure. Use these rows to verify the generated Select AI answer.

## Task 5: Confirm the Read-Only Boundary

1. Record the number of Finance V2 agent actions.

    ```sql
    <copy>
    SELECT COUNT(*) AS v2_agent_actions
    FROM agent_actions
    WHERE agent_name = 'FINANCE_V2_RISK_AGENT';
    </copy>
    ```

    **Expected result:** Record the returned count for comparison.

2. Ask Select AI another governed finance question.

    ```sql
    <copy>
    SELECT AI NARRATE
      Which current Seer Bank risk signal should an analyst review first, and why?
    </copy>
    ```

    **Expected result:** Select AI explains the finance evidence but does not perform an action.

3. Run the action-count query again.

    **Expected result:** The count is unchanged. Select AI can read and explain approved data, but it has not been given an action tool.

You have now reproduced the AI4U progression with the Finance LiveStack dataset: Chat explains general knowledge, Select AI reads governed data, and the next lab adds a controlled agent action.

## Acknowledgements

* **Source Pattern** - AI4U, *Why Agents Beat Zero-Shot Prompts*
* **Finance Source** - Seer Bank Finance LiveStack
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, July 2026
