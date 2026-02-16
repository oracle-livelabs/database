# Why Enterprise Data Matters

## Introduction

In this lab, you'll see why agents fail without enterprise data, and how connecting them to your business context transforms their usefulness.

Agents don't show up understanding your organization. They don't know your pricing guides, your workflows, or how decisions were handled last time. That knowledge lives in your enterprise data.

You'll first ask the LLM business-specific questions it can't answer, then give an agent access to your data and see the difference.

### The Business Problem

At Big Star Collectibles, an inventory specialist asked the AI assistant about pricing for platinum collectors:

> *"I asked the AI what pricing we offer platinum collectors. It said 15%. Our actual platinum discount is 20%. I almost quoted wrong pricing to a VIP customer!"*
>
> Marcus, Senior Inventory Specialist

The chatbot doesn't know Big Star Collectibles' actual pricing tiers, grading standards, or customer information. It gives generic answers that sound confident but are confidently wrong.

Big Star Collectibles needs AI that knows:
- **Actual pricing tiers**: Platinum is 20%, Gold is 10%, Silver is 5%
- **Grading standards**: Condition requirements, authentication policies
- **Customer details**: Who qualifies for what, what discounts exist

### What You'll Learn

This lab shows you the difference between generic AI knowledge and enterprise-connected AI. You'll see the same questions answered wrong (without data) and right (with data access).

**What you'll build:** An agent connected to Big Star Collectibles' pricing policies and customer data.

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
    https://github.com/davidastart/database/blob/main/ai4u/industries/bigstar/enterprise-data/lab6-enterprise-data.json
    </copy>
    ```

5. Click **Ok**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Experience the Knowledge Gap

Let's see what happens when you ask an LLM about your business without giving it access to your data. We'll use `SELECT AI CHAT` which uses the LLM's general knowledge.

1. Set the AI profile and ask about Big Star Collectibles' pricing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Set the AI profile for SELECT AI CHAT
    EXEC DBMS_CLOUD_AI.SET_PROFILE('genai');

    SELECT AI CHAT What pricing discounts does Big Star Collectibles offer for platinum collectors;
    </copy>
    ```

The LLM gives a generic response. It doesn't know YOUR pricing because it has no access to your data. It might make up a number or say it doesn't have that information.

2. Ask about a specific customer.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI CHAT Is customer Alex Martinez eligible for platinum pricing at Big Star Collectibles;
    </copy>
    ```

The LLM can't answer. It has no customer data. It might make something up or tell you it doesn't have access.

3. Ask about grading policy.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI CHAT What condition grade does Big Star Collectibles require for vintage comics;
    </copy>
    ```

Generic answer. Not YOUR policy.

## Task 3: Create Enterprise Data

Now let's create the business data that an agent needs. This is the key difference—instead of hoping the AI knows your pricing and policies, we store them in tables the agent can query.

1. Create pricing policy and customer tables.

    These tables contain Big Star Collectibles' actual business information: real pricing tiers, real grading requirements, and real customer data. This is what turns a generic AI into YOUR AI.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Big Star Collectibles pricing policies
    CREATE TABLE pricing_policies (
        policy_id     VARCHAR2(20) PRIMARY KEY,
        policy_name   VARCHAR2(100),
        policy_text   CLOB,
        pricing_tier  VARCHAR2(50),
        item_types    VARCHAR2(200)
    );

    INSERT INTO pricing_policies VALUES (
        'POL-PLAT', 'Platinum Collector Tier',
        'Platinum collectors receive 20% loyalty discount on all purchases. ' ||
        'VIP authentication service. Priority access to rare items. ' ||
        'Loyalty discount earned after 750+ loyalty points or 5+ years as customer.',
        'PLATINUM',
        'Sports Cards, Comics, Vintage Toys, Memorabilia'
    );

    INSERT INTO pricing_policies VALUES (
        'POL-GOLD', 'Gold Collector Tier',
        'Gold collectors receive 10% loyalty discount on all purchases. ' ||
        'Standard authentication service. Access to most inventory. ' ||
        'Loyalty discount earned after 500-749 loyalty points.',
        'GOLD',
        'Sports Cards, Comics, Vintage Toys, Memorabilia'
    );

    INSERT INTO pricing_policies VALUES (
        'POL-GRADE', 'Grading Requirements',
        'Minimum condition grade 3.0 for any item consideration. ' ||
        'Grade 7.0+ qualifies for premium listing. ' ||
        'Grade 9.0+ qualifies for expert authentication. ' ||
        'Vintage comics require grade 5.0+ for authentication.',
        'ALL',
        'All item types'
    );

    -- Big Star Collectibles customer data
    CREATE TABLE bs_customers (
        customer_id       VARCHAR2(20) PRIMARY KEY,
        name              VARCHAR2(100),
        specialty         VARCHAR2(100),
        loyalty_points    NUMBER(6),
        pricing_tier      VARCHAR2(20),
        customer_since    DATE,
        loyalty_discount  NUMBER(5,2),
        total_purchases   NUMBER(4)
    );

    INSERT INTO bs_customers VALUES ('CUST-001', 'Alex Martinez', 'Vintage Sports Cards', 7800, 'PLATINUM', DATE '2019-03-15', 20, 82);
    INSERT INTO bs_customers VALUES ('CUST-002', 'TechStart Collectibles', 'Modern Comics', 650, 'GOLD', DATE '2022-06-01', 10, 25);
    INSERT INTO bs_customers VALUES ('CUST-003', 'GlobalCo Toys', 'Vintage Toys', 420, 'SILVER', DATE '2024-01-10', 5, 12);

    COMMIT;
    </copy>
    ```

2. Create tool functions to access this data.

    Now we create functions that can look up this information. These functions become the agent's eyes into your enterprise data. When someone asks about pricing, the agent can look up the real answer instead of guessing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    -- Tool to look up pricing policies
    CREATE OR REPLACE FUNCTION get_pricing_policy(
        p_policy_type VARCHAR2,
        p_pricing_tier VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 AS
        v_result CLOB := '';
    BEGIN
        FOR rec IN (
            SELECT policy_name, policy_text, pricing_tier
            FROM pricing_policies
            WHERE (UPPER(policy_name) LIKE '%' || UPPER(p_policy_type) || '%'
                   OR UPPER(policy_text) LIKE '%' || UPPER(p_policy_type) || '%')
            AND (p_pricing_tier IS NULL OR UPPER(pricing_tier) = UPPER(p_pricing_tier))
            ORDER BY pricing_tier
        ) LOOP
            v_result := v_result || rec.policy_name || ' (' || rec.pricing_tier || '): ' || rec.policy_text || CHR(10) || CHR(10);
        END LOOP;

        IF v_result IS NULL THEN
            RETURN 'No policy found matching: ' || p_policy_type;
        END IF;

        RETURN v_result;
    END;
    /

    -- Tool to look up customer information
    CREATE OR REPLACE FUNCTION get_customer_info(
        p_customer_id VARCHAR2 DEFAULT NULL,
        p_customer_name VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 AS
        v_result VARCHAR2(1000);
    BEGIN
        SELECT 'Customer: ' || name || ', Tier: ' || pricing_tier ||
               ', Discount: ' || loyalty_discount || '%, Loyalty Points: ' || loyalty_points ||
               ', Customer Since: ' || TO_CHAR(customer_since, 'YYYY') ||
               ', Total Purchases: ' || total_purchases
        INTO v_result
        FROM bs_customers
        WHERE (p_customer_id IS NULL OR customer_id = p_customer_id)
        AND (p_customer_name IS NULL OR UPPER(name) LIKE '%' || UPPER(p_customer_name) || '%')
        FETCH FIRST 1 ROW ONLY;

        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Customer not found.';
    END;
    /
    </copy>
    ```

3. Register the tools with the agent framework.

    Now we make these functions available to agents. The `instruction` tells the agent what each function does and when to use it.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'PRICING_POLICY_TOOL',
            attributes  => '{"instruction": "Look up Big Star Collectibles pricing policies. Parameters: P_POLICY_TYPE (e.g. platinum, grading, discount), P_PRICING_TIER (optional: PLATINUM, GOLD, SILVER). Returns official policy text.",
                            "function": "get_pricing_policy"}',
            description => 'Retrieves pricing policies and tier information'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CUSTOMER_INFO_TOOL',
            attributes  => '{"instruction": "Look up customer information. Parameters: P_CUSTOMER_ID (e.g. CUST-001) or P_CUSTOMER_NAME (e.g. Alex Martinez). Returns customer tier, discount, loyalty points, and history.",
                            "function": "get_customer_info"}',
            description => 'Retrieves customer tier and eligibility information'
        );
    END;
    /
    </copy>
    ```

4. Create an enterprise-connected agent.

    This agent has access to your actual business data through the tools we just created.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'ENTERPRISE_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are an inventory specialist assistant for Big Star Collectibles. Use PRICING_POLICY_TOOL to look up official policies and CUSTOMER_INFO_TOOL to check customer eligibility. Always consult the actual policies - never guess or make up pricing information."}',
            description => 'Agent with enterprise data access'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'ENTERPRISE_TASK',
            attributes  => '{"instruction": "Answer questions about Big Star Collectibles pricing, policies, and customers by using the tools to look up actual data. Do not make assumptions - always check the official policies. User request: {query}",
                            "tools": ["PRICING_POLICY_TOOL", "CUSTOMER_INFO_TOOL"]}',
            description => 'Task with enterprise data access'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'ENTERPRISE_TEAM',
            attributes  => '{"agents": [{"name": "ENTERPRISE_AGENT", "task": "ENTERPRISE_TASK"}],
                            "process": "sequential"}',
            description => 'Team with enterprise data capabilities'
        );
    END;
    /
    </copy>
    ```

## Task 4: See the Difference Enterprise Data Makes

Now ask the same questions, but this time the agent can look up your actual policies.

1. Set the team and ask about platinum pricing.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ENTERPRISE_TEAM');
    SELECT AI AGENT What pricing discounts does Big Star Collectibles offer for platinum collectors;
    </copy>
    ```

**Observe:** The agent looked up the actual policy and returned the correct answer: 20% discount.

2. Ask about a specific customer.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT Is customer Alex Martinez eligible for platinum pricing;
    </copy>
    ```

**Observe:** The agent looked up Alex Martinez in the customer table and confirmed platinum tier eligibility.

3. Ask about grading requirements.

    > This command is already in your notebook—just click the play button (▶) to run it.

    ```sql
    <copy>
    SELECT AI AGENT What condition grade does Big Star Collectibles require for vintage comics;
    </copy>
    ```

**Observe:** The agent retrieved the actual grading policy (grade 5.0+ for vintage comics).

## Task 5: See What the Agent Looked Up

Check the tool history to see the agent accessing your enterprise data.

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
SELECT
    tool_name,
    TO_CHAR(start_date, 'HH24:MI:SS') as called_at,
    SUBSTR(output, 1, 100) as result
FROM USER_AI_AGENT_TOOL_HISTORY
ORDER BY start_date DESC
FETCH FIRST 10 ROWS ONLY;
</copy>
```

You'll see calls to PRICING_POLICY_TOOL and CUSTOMER_INFO_TOOL with the actual data returned.

## Task 6: Understand Why This Matters

**Without enterprise data:**
- AI makes up answers that sound right but are wrong
- No way to verify information
- Can't handle customer-specific questions
- Gives generic advice instead of your policies

**With enterprise data:**
- AI looks up actual policies before answering
- Answers are grounded in your business rules
- Can handle customer-specific eligibility questions
- Provides YOUR pricing, not generic industry pricing

**The transformation:**
- From "I think platinum collectors get around 15% off" (WRONG)
- To "According to policy POL-PLAT, platinum collectors receive 20% discount" (CORRECT)

## Summary

In this lab, you experienced the power of enterprise-connected agents:

* Saw generic AI fail at business-specific questions
* Created tables with your actual pricing policies and customer data
* Built tools that let agents query enterprise information
* Watched the same questions get answered correctly with data access
* Understood why enterprise context transforms agent usefulness

**Key takeaway:** An agent without access to your data is guessing. An agent with enterprise data access is consulting your actual business rules. For Big Star Collectibles, that's the difference between quoting wrong pricing to VIP customers and delivering accurate, policy-compliant service.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

> This command is already in your notebook—just click the play button (▶) to run it.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('ENTERPRISE_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('ENTERPRISE_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('ENTERPRISE_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('PRICING_POLICY_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CUSTOMER_INFO_TOOL', TRUE);
DROP TABLE pricing_policies PURGE;
DROP TABLE bs_customers PURGE;
DROP FUNCTION get_pricing_policy;
DROP FUNCTION get_customer_info;
</copy>
```
