# Why Enterprise Data Matters

## Introduction

In this lab, you'll see why agents fail without enterprise data—and how connecting them to your business context transforms their usefulness.

Agents don't show up understanding your organization. They don't know your policies, your workflows, or how decisions were handled last time. That knowledge lives in your enterprise data.

You'll first ask the LLM business-specific questions it can't answer, then give an agent access to your data and see the difference.

Estimated Time: 10 minutes

### Objectives

* Experience LLM failure without business context
* Create enterprise data tools for agents
* See how data access transforms agent responses
* Understand why enterprise data provides judgment and guardrails

### Prerequisites

This lab assumes you have:

* Completed Labs 1-5 or have a working agent setup
* An AI profile named `genai` already configured

## Task 1: Experience the Knowledge Gap

Let's see what happens when you ask an LLM about your business without giving it access to your data. We'll use `SELECT AI CHAT` which uses the LLM's general knowledge.

1. Set the AI profile and ask about your return policy.

    ```sql
    <copy>
    -- Set the AI profile for SELECT AI CHAT
    EXEC DBMS_CLOUD_AI.SET_PROFILE('genai');

    SELECT AI CHAT What is the return policy for premium members at TechCorp;
    </copy>
    ```

The LLM gives a generic response—it doesn't know YOUR return policy because it has no access to your data.

2. Ask about a specific customer.

    ```sql
    <copy>
    SELECT AI CHAT Is customer CUST-1001 eligible for an upgrade;
    </copy>
    ```

The LLM can't answer—it has no customer data. It might make something up or tell you it doesn't have access.

## Task 2: Create Enterprise Data

Now let's create the business data that an agent needs.

1. Create policy and customer tables.

    ```sql
    <copy>
    -- Company policies
    CREATE TABLE company_policies (
        policy_id    VARCHAR2(20) PRIMARY KEY,
        policy_name  VARCHAR2(100),
        policy_text  CLOB,
        applies_to   VARCHAR2(50)
    );

    INSERT INTO company_policies VALUES (
        'POL-001', 'Return Policy - Premium',
        'Premium members may return items within 90 days for full refund, no questions asked. ' ||
        'Standard restocking fees are waived. Free return shipping included.',
        'PREMIUM'
    );

    INSERT INTO company_policies VALUES (
        'POL-002', 'Return Policy - Standard',
        'Standard members may return items within 30 days. A 15% restocking fee applies. ' ||
        'Customer pays return shipping.',
        'STANDARD'
    );

    INSERT INTO company_policies VALUES (
        'POL-003', 'Escalation Process',
        'Billing disputes: 1) Agent attempts resolution, 2) If over $100, escalate to Team Lead, ' ||
        '3) If unresolved after 24 hours, escalate to Manager, 4) Customer may request VP review.',
        'ALL'
    );

    -- Customer data
    CREATE TABLE enterprise_customers (
        customer_id   VARCHAR2(20) PRIMARY KEY,
        name          VARCHAR2(100),
        tier          VARCHAR2(20),
        since         DATE,
        total_spend   NUMBER(12,2),
        upgrade_eligible VARCHAR2(1)
    );

    INSERT INTO enterprise_customers VALUES ('CUST-1001', 'Acme Corp', 'STANDARD', DATE '2022-01-15', 45000, 'Y');
    INSERT INTO enterprise_customers VALUES ('CUST-1002', 'TechStart', 'PREMIUM', DATE '2020-06-01', 125000, 'N');
    INSERT INTO enterprise_customers VALUES ('CUST-1003', 'NewCo', 'STANDARD', DATE '2024-01-10', 5000, 'N');

    COMMIT;
    </copy>
    ```

2. Create tool functions to access this data.

    ```sql
    <copy>
    -- Tool to look up policies
    CREATE OR REPLACE FUNCTION get_policy(
        p_policy_type VARCHAR2,
        p_member_tier VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 AS
        v_result CLOB := '';
    BEGIN
        FOR rec IN (
            SELECT policy_name, policy_text 
            FROM company_policies 
            WHERE UPPER(policy_name) LIKE '%' || UPPER(p_policy_type) || '%'
            AND (applies_to = p_member_tier OR applies_to = 'ALL' OR p_member_tier IS NULL)
        ) LOOP
            v_result := v_result || rec.policy_name || ': ' || rec.policy_text || CHR(10);
        END LOOP;
        
        IF v_result IS NULL THEN
            RETURN 'No policy found for: ' || p_policy_type;
        END IF;
        RETURN v_result;
    END;
    /

    -- Tool to look up customer
    CREATE OR REPLACE FUNCTION get_customer_info(
        p_customer_id VARCHAR2
    ) RETURN VARCHAR2 AS
        v_result VARCHAR2(500);
    BEGIN
        SELECT 'Customer: ' || name || ', Tier: ' || tier || 
               ', Member since: ' || TO_CHAR(since, 'YYYY-MM-DD') ||
               ', Total spend: $' || TO_CHAR(total_spend, '999,999') ||
               ', Upgrade eligible: ' || upgrade_eligible
        INTO v_result
        FROM enterprise_customers
        WHERE customer_id = p_customer_id;
        
        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Customer not found: ' || p_customer_id;
    END;
    /
    </copy>
    ```

3. Register the tools.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'POLICY_LOOKUP_TOOL',
            attributes  => '{"instruction": "Look up company policies. Parameters: P_POLICY_TYPE (e.g. return, escalation), P_MEMBER_TIER (PREMIUM or STANDARD, optional). Always use this to answer policy questions.",
                            "function": "get_policy"}',
            description => 'Retrieves company policies including return policies and escalation procedures'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CUSTOMER_LOOKUP_TOOL',
            attributes  => '{"instruction": "Look up customer information. Parameter: P_CUSTOMER_ID (e.g. CUST-1001). Returns tier, spend, and upgrade eligibility. Always use this when asked about specific customers.",
                            "function": "get_customer_info"}',
            description => 'Retrieves customer details including tier, spend history, and upgrade eligibility'
        );
    END;
    /
    </copy>
    ```

## Task 3: Create an Informed Agent

Now let's create an agent with access to enterprise data.

1. Create the informed agent.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'INFORMED_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a customer service agent for TechCorp. You have access to company policies and customer information. Always use your tools to look up real data - never guess."}',
            description => 'Agent with enterprise data access'
        );
        
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'INFORMED_TASK',
            attributes  => '{"instruction": "Help the customer by looking up relevant policies and customer information using your tools. Do not ask clarifying questions - use the tools and report what you find. User request: {query}",
                            "tools": ["POLICY_LOOKUP_TOOL", "CUSTOMER_LOOKUP_TOOL"]}',
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

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('INFORMED_TEAM');
    </copy>
    ```

## Task 4: Ask the Same Questions Again

Now let's see the difference. This time we use `SELECT AI AGENT` which has access to our enterprise data tools.

1. Ask about return policy for premium members.

    ```sql
    <copy>
    SELECT AI AGENT What is the return policy for premium members;
    </copy>
    ```

**Now you get YOUR actual policy:** 90 days, no questions, waived fees, free shipping.

2. Ask about the specific customer.

    ```sql
    <copy>
    SELECT AI AGENT Is customer CUST-1001 eligible for an upgrade;
    </copy>
    ```

**The agent looks up the customer and reports:** Yes, Acme Corp is eligible for upgrade.

3. Ask about escalation.

    ```sql
    <copy>
    SELECT AI AGENT What is the escalation process for billing disputes;
    </copy>
    ```

**Your actual process:** Agent first, Team Lead if over $100, Manager after 24 hours, VP if requested.

## Task 5: See the Tool Calls

Let's verify the agent is using enterprise data.

1. Query tool history.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as when,
        SUBSTR(output, 1, 60) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

## Summary

In this lab, you experienced the difference enterprise data makes:

* `SELECT AI CHAT` - LLM general knowledge only, gave generic answers
* `SELECT AI AGENT` - Agent with tools, gave YOUR specific answers
* Enterprise data transforms generic AI into your AI

**Key takeaway:** Agents don't fail because they're not smart—they fail because they don't know your business. Enterprise data is what transforms generic AI into your AI.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('INFORMED_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('INFORMED_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('INFORMED_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('POLICY_LOOKUP_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CUSTOMER_LOOKUP_TOOL', TRUE);
DROP TABLE company_policies PURGE;
DROP TABLE enterprise_customers PURGE;
DROP FUNCTION get_policy;
DROP FUNCTION get_customer_info;
</copy>
```
