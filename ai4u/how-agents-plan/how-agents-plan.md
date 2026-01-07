# How Agents Plan the Work

## Introduction

In this lab, you'll observe how an AI agent plans its work before taking action.

Planning is what separates agents from chatbots. Before executing anything, an agent breaks a task into steps, identifies which tools to use, and determines the order of operations. This makes agent behavior predictable and debuggable.

You'll give an agent a multi-step task and watch how it decomposes the work.

Estimated Time: 10 minutes

### Objectives

* Understand how agents break tasks into steps
* Observe the planning process through history views
* See the relationship between instructions and execution
* Learn why planning makes agents predictable

### Prerequisites

This lab assumes you have:

* Completed Labs 1-2 or have a working agent setup
* An AI profile named `genai` already configured

## Task 1: Create a Multi-Tool Agent

To see planning in action, we need an agent with multiple tools. The agent will decide which tools to use and in what order.

1. Create sample data tables.

    ```sql
    <copy>
    -- Customer table
    CREATE TABLE demo_customers (
        customer_id   VARCHAR2(20) PRIMARY KEY,
        name          VARCHAR2(100),
        tier          VARCHAR2(20),
        contact_email VARCHAR2(100)
    );

    INSERT INTO demo_customers VALUES ('CUST-001', 'Acme Corp', 'PREMIUM', 'contact@acme.com');
    INSERT INTO demo_customers VALUES ('CUST-002', 'TechStart', 'STANDARD', 'info@techstart.com');

    -- Order table
    CREATE TABLE demo_orders (
        order_id    VARCHAR2(20) PRIMARY KEY,
        customer_id VARCHAR2(20),
        status      VARCHAR2(20),
        amount      NUMBER(10,2),
        order_date  DATE
    );

    INSERT INTO demo_orders VALUES ('ORD-100', 'CUST-001', 'SHIPPED', 500.00, SYSDATE - 2);
    INSERT INTO demo_orders VALUES ('ORD-101', 'CUST-001', 'PENDING', 250.00, SYSDATE);
    INSERT INTO demo_orders VALUES ('ORD-102', 'CUST-002', 'DELIVERED', 100.00, SYSDATE - 5);

    COMMIT;
    </copy>
    ```

2. Create tool functions.

    ```sql
    <copy>
    -- Tool 1: Look up customer
    CREATE OR REPLACE FUNCTION get_customer(p_customer_id VARCHAR2) RETURN VARCHAR2 AS
        v_result VARCHAR2(500);
    BEGIN
        SELECT 'Customer: ' || name || ', Tier: ' || tier || ', Email: ' || contact_email
        INTO v_result FROM demo_customers WHERE customer_id = p_customer_id;
        RETURN v_result;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'Customer not found: ' || p_customer_id;
    END;
    /

    -- Tool 2: Get customer orders
    CREATE OR REPLACE FUNCTION get_customer_orders(p_customer_id VARCHAR2) RETURN VARCHAR2 AS
        v_result CLOB := '';
        v_count NUMBER := 0;
    BEGIN
        FOR rec IN (SELECT order_id, status, amount, order_date 
                    FROM demo_orders WHERE customer_id = p_customer_id ORDER BY order_date DESC) LOOP
            v_result := v_result || rec.order_id || ': ' || rec.status || ', $' || rec.amount || CHR(10);
            v_count := v_count + 1;
        END LOOP;
        IF v_count = 0 THEN RETURN 'No orders found for customer.'; END IF;
        RETURN 'Found ' || v_count || ' orders:' || CHR(10) || v_result;
    END;
    /

    -- Tool 3: Check if customer is eligible for priority support
    CREATE OR REPLACE FUNCTION check_priority_eligibility(p_customer_id VARCHAR2) RETURN VARCHAR2 AS
        v_tier VARCHAR2(20);
    BEGIN
        SELECT tier INTO v_tier FROM demo_customers WHERE customer_id = p_customer_id;
        IF v_tier = 'PREMIUM' THEN
            RETURN 'ELIGIBLE: Customer is Premium tier - priority support available.';
        ELSE
            RETURN 'NOT ELIGIBLE: Customer is ' || v_tier || ' tier - standard support only.';
        END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'Customer not found.';
    END;
    /
    </copy>
    ```

3. Register the tools.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'GET_CUSTOMER_TOOL',
            attributes  => '{"instruction": "Get customer details by ID. Parameter: P_CUSTOMER_ID (e.g. CUST-001). Returns name, tier, and email.",
                            "function": "get_customer"}',
            description => 'Retrieves customer name, tier, and contact email'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'GET_ORDERS_TOOL',
            attributes  => '{"instruction": "Get all orders for a customer. Parameter: P_CUSTOMER_ID (e.g. CUST-001). Returns order IDs, statuses, and amounts.",
                            "function": "get_customer_orders"}',
            description => 'Retrieves customer order history with status and amounts'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CHECK_PRIORITY_TOOL',
            attributes  => '{"instruction": "Check if customer qualifies for priority support. Parameter: P_CUSTOMER_ID (e.g. CUST-001). Returns ELIGIBLE or NOT ELIGIBLE.",
                            "function": "check_priority_eligibility"}',
            description => 'Checks if customer tier qualifies for priority support'
        );
    END;
    /
    </copy>
    ```

4. Create the agent and team.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'PLANNING_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a customer service agent. Use your tools to look up customer information, orders, and support eligibility. Always use the tools - never guess or make up information."}',
            description => 'Agent that plans multi-step responses'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'PLANNING_TASK',
            attributes  => '{"instruction": "Answer customer inquiries by using the available tools. Do not ask clarifying questions - use the tools to look up the information and report what you find. User request: {query}",
                            "tools": ["GET_CUSTOMER_TOOL", "GET_ORDERS_TOOL", "CHECK_PRIORITY_TOOL"]}',
            description => 'Task with multiple tools for planning demonstration'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'PLANNING_TEAM',
            attributes  => '{"agents": [{"name": "PLANNING_AGENT", "task": "PLANNING_TASK"}],
                            "process": "sequential"}',
            description => 'Team demonstrating agent planning'
        );
    END;
    /
    </copy>
    ```

## Task 2: Observe Single-Tool Planning

Let's start with a simple request that needs only one tool.

1. Set the team and ask a simple question.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('PLANNING_TEAM');
    SELECT AI AGENT Who is customer CUST-001;
    </copy>
    ```

2. Check the tool history to see the plan execution.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS.FF3') as called_at,
        SUBSTR(output, 1, 60) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

**Observe:** The agent planned to use just GET_CUSTOMER_TOOL because that's all the question required.

## Task 3: Observe Multi-Tool Planning

Now let's ask a question that requires multiple tools.

1. Ask a complex question.

    ```sql
    <copy>
    SELECT AI AGENT Give me a complete picture of customer CUST-001 including their orders and support eligibility;
    </copy>
    ```

2. Check the tool history.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS.FF3') as called_at,
        SUBSTR(output, 1, 60) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

**Observe:** The agent planned to use multiple tools:
- GET_CUSTOMER_TOOL to get basic info
- GET_ORDERS_TOOL to get order history
- CHECK_PRIORITY_TOOL to verify eligibility

3. Notice the sequence—the agent determined the logical order.

## Task 4: See How Instructions Shape Planning

The task instruction guides how the agent plans. Let's modify it.

1. Create a more specific task.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'STRUCTURED_TASK',
            attributes  => '{"instruction": "For customer inquiries, ALWAYS follow this exact sequence: 1. First, look up the customer using GET_CUSTOMER_TOOL 2. Then, get their orders using GET_ORDERS_TOOL 3. Finally, check priority eligibility using CHECK_PRIORITY_TOOL. Report all findings. User request: {query}",
                            "tools": ["GET_CUSTOMER_TOOL", "GET_ORDERS_TOOL", "CHECK_PRIORITY_TOOL"]}',
            description => 'Task with explicit planning instructions'
        );
    END;
    /

    -- Update the team to use the new task
    BEGIN
        DBMS_CLOUD_AI_AGENT.DROP_TEAM('PLANNING_TEAM', TRUE);
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'PLANNING_TEAM',
            attributes  => '{"agents": [{"name": "PLANNING_AGENT", "task": "STRUCTURED_TASK"}],
                            "process": "sequential"}',
            description => 'Team with structured planning'
        );
    END;
    /
    </copy>
    ```

2. Test with the structured instructions.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('PLANNING_TEAM');
    SELECT AI AGENT Tell me about customer CUST-001;
    </copy>
    ```

3. Check the tool history again.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS.FF3') as called_at
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

**Observe:** The agent followed the explicit plan: customer first, then orders, then eligibility—in that order.

## Task 5: Understand Why Planning Matters

Planning provides:

1. **Predictability** — You can anticipate what the agent will do
2. **Debuggability** — When something goes wrong, you can see where
3. **Efficiency** — The agent gathers what it needs without redundant calls
4. **Control** — You shape the plan through instructions

Query the complete execution sequence:

```sql
<copy>
SELECT 
    tool_name,
    TO_CHAR(start_date, 'HH24:MI:SS') as started,
    TO_CHAR(end_date, 'HH24:MI:SS') as ended
FROM USER_AI_AGENT_TOOL_HISTORY
ORDER BY start_date DESC
FETCH FIRST 10 ROWS ONLY;
</copy>
```

## Summary

In this lab, you observed how agents plan their work:

* Created an agent with multiple tools
* Watched the agent choose tools based on the question
* Saw how multi-step questions trigger multi-tool plans
* Learned how instructions shape the planning process

**Key takeaway:** Planning is what makes agents predictable. Before any action happens, the agent knows the path. You can see that path in the history views.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('PLANNING_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('PLANNING_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('STRUCTURED_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('PLANNING_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_CUSTOMER_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_ORDERS_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CHECK_PRIORITY_TOOL', TRUE);
DROP TABLE demo_orders PURGE;
DROP TABLE demo_customers PURGE;
DROP FUNCTION get_customer;
DROP FUNCTION get_customer_orders;
DROP FUNCTION check_priority_eligibility;
</copy>
```
