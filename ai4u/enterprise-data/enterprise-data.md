# Why Enterprise Data Matters

## Introduction

In this lab, you'll see why agents fail without enterprise data, and how connecting them to your business context transforms their usefulness.

Agents don't show up understanding your organization. They don't know your policies, your workflows, or how decisions were handled last time. That knowledge lives in your enterprise data.

You'll first ask the LLM business-specific questions it can't answer, then give an agent access to your data and see the difference.

### The Business Problem

At Seer Equity, a loan officer asked the AI assistant about rates for preferred customers:

> *"I asked the AI what rates we offer preferred customers. It said 6.5%. Our actual preferred rate is 7.9%. I almost quoted wrong rates to a client!"*
>
> Marcus, Senior Loan Officer

The chatbot doesn't know Seer Equity's actual rates, policies, or client information. It gives generic answers that sound confident but are confidently wrong.

Seer Equity needs AI that knows:
- **Actual rate tiers**: Preferred is 7.9%, Standard is 12.9%
- **Lending policies**: Credit requirements, documentation needed
- **Client details**: Who qualifies for what, what exceptions exist

### What You'll Learn

This lab shows you the difference between generic AI knowledge and enterprise-connected AI. You'll see the same questions answered wrong (without data) and right (with data access).

**What you'll build:** An agent connected to Seer Equity's loan policies and applicant data.

Estimated Time: 10 minutes

### Objectives

* Experience LLM failure without business context
* Create enterprise data tools for agents
* See how data access transforms agent responses
* Understand why enterprise data provides judgment and guardrails

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

## Task 1: Import the Lab Notebook

Before you begin, you are going to import a notebook that has all of the commands for this lab into Oracle Machine Learning. This way you don't have to copy and paste them over to run them.

1. From the Oracle Machine Learning home page, click **Notebooks**.

2. Click **Import** to expand the Import drop down.

3. Select **Git**.

4. Paste the following GitHub URL leaving the credential field blank:

    ```text
    <copy>
    https://github.com/davidastart/database/blob/main/ai4u/enterprise-data/lab6-enterprise-data.json
    </copy>
    ```

5. Click **Import**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Experience the Knowledge Gap

Let's see what happens when you ask an LLM about your business without giving it access to your data. We'll use `SELECT AI CHAT` which uses the LLM's general knowledge.

1. Set the AI profile and ask about Seer Equity's rates.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Set the AI profile for SELECT AI CHAT
    EXEC DBMS_CLOUD_AI.SET_PROFILE('genai');

    SELECT AI CHAT What interest rates does Seer Equity offer for preferred customers;
    </copy>
    ```

The LLM gives a generic response. It doesn't know YOUR rates because it has no access to your data. It might make up a number or say it doesn't have that information.

2. Ask about a specific applicant.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI CHAT Is applicant Sarah Chen eligible for preferred rates at Seer Equity;
    </copy>
    ```

The LLM can't answer. It has no applicant data. It might make something up or tell you it doesn't have access.

3. Ask about lending policy.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI CHAT What credit score does Seer Equity require for a mortgage;
    </copy>
    ```

Generic answer. Not YOUR policy.

## Task 3: Create Enterprise Data

Now let's create the business data that an agent needs. This is the key difference—instead of hoping the AI knows your rates and policies, we store them in tables the agent can query.

1. Create loan policy and applicant tables.

    These tables contain Seer Equity's actual business information: real rate tiers, real credit requirements, and real client data. This is what turns a generic AI into YOUR AI.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Seer Equity loan policies
    CREATE TABLE loan_policies (
        policy_id    VARCHAR2(20) PRIMARY KEY,
        policy_name  VARCHAR2(100),
        policy_text  CLOB,
        rate_tier    VARCHAR2(50),
        loan_types   VARCHAR2(200)
    );

    INSERT INTO loan_policies VALUES (
        'POL-PREF', 'Preferred Rate Tier',
        'Preferred rate is 7.9% APR for customers with credit score 750+. ' ||
        'Maximum loan amount $500,000. Requires 20% down payment for mortgages. ' ||
        'Rate exception up to 15% discount available for clients with 5+ year history.',
        'PREFERRED',
        'Personal, Auto, Mortgage, Business'
    );

    INSERT INTO loan_policies VALUES (
        'POL-STD', 'Standard Rate Tier',
        'Standard rate is 12.9% APR for customers with credit score 650-749. ' ||
        'Maximum loan amount $250,000. Requires 25% down payment for mortgages. ' ||
        'No rate exceptions available for this tier.',
        'STANDARD',
        'Personal, Auto, Business'
    );

    INSERT INTO loan_policies VALUES (
        'POL-CREDIT', 'Credit Requirements',
        'Minimum credit score 550 for any loan consideration. ' ||
        'Credit score 750+ qualifies for Preferred tier. ' ||
        'Credit score 650-749 qualifies for Standard tier. ' ||
        'Credit score below 650 requires additional documentation and cosigner.',
        'ALL',
        'All loan types'
    );

    -- Seer Equity applicant data
    CREATE TABLE se_applicants (
        applicant_id      VARCHAR2(20) PRIMARY KEY,
        name              VARCHAR2(100),
        company           VARCHAR2(100),
        credit_score      NUMBER(3),
        rate_tier         VARCHAR2(20),
        client_since      DATE,
        rate_exception    NUMBER(5,2),
        total_loans       NUMBER(3)
    );

    INSERT INTO se_applicants VALUES ('APP-001', 'Sarah Chen', 'Acme Industries', 780, 'PREFERRED', DATE '2019-03-15', 15, 8);
    INSERT INTO se_applicants VALUES ('APP-002', 'TechStart LLC', NULL, 710, 'STANDARD', DATE '2022-06-01', NULL, 2);
    INSERT INTO se_applicants VALUES ('APP-003', 'GlobalCo', NULL, 620, 'STANDARD', DATE '2024-01-10', NULL, 1);

    COMMIT;
    </copy>
    ```

2. Create tool functions to access this data.

    Now we create functions that can look up this information. These functions become the agent's eyes into your enterprise data. When someone asks about rates, the agent can look up the real answer instead of guessing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Tool to look up loan policies
    CREATE OR REPLACE FUNCTION get_loan_policy(
        p_policy_type VARCHAR2,
        p_rate_tier   VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 AS
        v_result CLOB := '';
    BEGIN
        FOR rec IN (
            SELECT policy_name, policy_text, rate_tier
            FROM loan_policies 
            WHERE (UPPER(policy_name) LIKE '%' || UPPER(p_policy_type) || '%'
                   OR UPPER(policy_text) LIKE '%' || UPPER(p_policy_type) || '%')
            AND (p_rate_tier IS NULL OR rate_tier = p_rate_tier OR rate_tier = 'ALL')
        ) LOOP
            v_result := v_result || rec.policy_name || ' (' || rec.rate_tier || '): ' || 
                       rec.policy_text || CHR(10) || CHR(10);
        END LOOP;
        
        IF v_result IS NULL THEN
            RETURN 'No policy found for: ' || p_policy_type;
        END IF;
        RETURN v_result;
    END;
    /

    -- Tool to look up applicant
    CREATE OR REPLACE FUNCTION get_applicant_info(
        p_applicant_name VARCHAR2
    ) RETURN VARCHAR2 AS
        v_result VARCHAR2(1000);
    BEGIN
        SELECT 'Applicant: ' || name || 
               CASE WHEN company IS NOT NULL THEN ' (' || company || ')' ELSE '' END ||
               ', Credit Score: ' || credit_score || 
               ', Rate Tier: ' || rate_tier ||
               ', Client Since: ' || TO_CHAR(client_since, 'YYYY-MM-DD') ||
               ', Total Loans: ' || total_loans ||
               CASE WHEN rate_exception IS NOT NULL 
                    THEN ', Rate Exception: ' || rate_exception || '% discount'
                    ELSE ', No rate exception' END
        INTO v_result
        FROM se_applicants
        WHERE UPPER(name) LIKE '%' || UPPER(p_applicant_name) || '%';
        
        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Applicant not found: ' || p_applicant_name;
        WHEN TOO_MANY_ROWS THEN
            RETURN 'Multiple applicants found matching: ' || p_applicant_name || '. Please be more specific.';
    END;
    /
    </copy>
    ```

3. Register the tools.

    We turn these functions into tools the agent can use. The instructions tell the agent to ALWAYS use these tools for policy and applicant questions—never guess. This is how you prevent the agent from making up answers.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'POLICY_LOOKUP_TOOL',
            attributes  => '{"instruction": "Look up Seer Equity loan policies. Parameters: P_POLICY_TYPE (e.g. rate, credit, preferred, standard), P_RATE_TIER (PREFERRED or STANDARD, optional). Always use this to answer policy questions - never guess at rates or requirements.",
                            "function": "get_loan_policy"}',
            description => 'Retrieves Seer Equity loan policies including rates and requirements'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'APPLICANT_LOOKUP_TOOL',
            attributes  => '{"instruction": "Look up applicant information. Parameter: P_APPLICANT_NAME (full or partial name). Returns credit score, rate tier, client history, and any rate exceptions. Always use this when asked about specific applicants.",
                            "function": "get_applicant_info"}',
            description => 'Retrieves applicant details including credit tier and rate exceptions'
        );
    END;
    /
    </copy>
    ```

## Task 4: Create an Informed Agent

Now let's create an agent with access to Seer Equity's enterprise data. The key difference from a regular chatbot is that this agent has tools to look up real information.

1. Create the informed agent.

    Notice how the role and task both emphasize using tools and not guessing. This is important—you're training the agent to rely on your data rather than its general knowledge.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'INFORMED_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a loan officer assistant for Seer Equity. You have access to company loan policies and applicant information. Always use your tools to look up real data - never guess at rates, requirements, or applicant details."}',
            description => 'Agent with enterprise data access'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'INFORMED_TASK',
            attributes  => '{"instruction": "Help the loan officer by looking up relevant policies and applicant information using your tools. Do not guess - if asked about rates, policies, or applicants, use the tools. User request: {query}",
                            "tools": ["POLICY_LOOKUP_TOOL", "APPLICANT_LOOKUP_TOOL"]}',
            description => 'Task with data access'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'INFORMED_TEAM',
            attributes  => '{"agents": [{"name": "INFORMED_AGENT", "task": "INFORMED_TASK"}],
                            "process": "sequential"}',
            description => 'Team with enterprise data'
        );
    END;
    /
    </copy>
    ```

2. Set the team.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('INFORMED_TEAM');
    </copy>
    ```

## Task 5: Ask the Same Questions Again

Now let's see the difference. This time we use `SELECT AI AGENT` which has access to our enterprise data tools.

1. Ask about rates for preferred customers.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What interest rates does Seer Equity offer for preferred customers;
    </copy>
    ```

**Now you get YOUR actual rate:** 7.9% APR for Preferred tier with credit score 750+.

2. Ask about Sarah Chen specifically.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Is Sarah Chen eligible for preferred rates and does she have any special pricing;
    </copy>
    ```

**The agent looks up the applicant and reports:** Sarah Chen has credit score 780 (Preferred tier), has been a client since 2019, and has a 15% rate exception.

3. Ask about credit requirements.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What credit score does Seer Equity require for a mortgage;
    </copy>
    ```

**Your actual policy:** Minimum 550 for any loan, 750+ for Preferred tier, 650-749 for Standard.

4. Ask a combination question.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What rate would TechStart LLC qualify for on a new loan;
    </copy>
    ```

**The agent checks both:** TechStart has credit score 710 (Standard tier), so they qualify for 12.9% APR.

## Task 6: See the Tool Calls

Let's verify the agent is using enterprise data.

1. Query tool history.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as when,
        SUBSTR(output, 1, 80) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

You can see the agent called POLICY_LOOKUP_TOOL and APPLICANT_LOOKUP_TOOL to get real data.

## Summary

In this lab, you experienced the difference enterprise data makes:

* `SELECT AI CHAT`: LLM general knowledge only, gave generic or wrong answers
* `SELECT AI AGENT`: Agent with tools, gave YOUR specific accurate answers
* Enterprise data transforms generic AI into your AI

**Key takeaway:** Agents don't fail because they're not smart. They fail because they don't know your business. Marcus almost quoted wrong rates because the AI didn't have access to Seer Equity's actual rate tables. Enterprise data is what transforms generic AI into your AI.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('INFORMED_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('INFORMED_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('INFORMED_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('POLICY_LOOKUP_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('APPLICANT_LOOKUP_TOOL', TRUE);
DROP TABLE loan_policies PURGE;
DROP TABLE se_applicants PURGE;
DROP FUNCTION get_loan_policy;
DROP FUNCTION get_applicant_info;
</copy>
```
