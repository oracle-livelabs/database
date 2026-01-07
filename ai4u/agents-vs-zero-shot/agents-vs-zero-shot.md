# Why Agents Beat Zero Shot Prompts

## Introduction

In this lab, you'll directly compare zero-shot prompting with agent-based execution to understand why agents are transforming how work gets done.

Zero-shot prompting means: one question, one answer, done. It's useful for general knowledge, but it doesn't execute workflows or access your data. Agents break tasks into steps, use tools, and actually complete the work.

Estimated Time: 10 minutes

### Objectives

* Understand what zero-shot prompting means
* Compare zero-shot responses to agent responses
* See how agents coordinate multiple tools to complete work
* Recognize when to use each approach

### Prerequisites

This lab assumes you have:

* An AI profile named `genai` already configured with your AI provider credentials

## Task 1: Experience Zero-Shot Prompting

Zero-shot queries go directly to the LLM for general knowledge answers. Use `SELECT AI CHAT` to ask questions without involving your database.

1. Set the profile.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI.SET_PROFILE('genai');
    </copy>
    ```

2. Ask a procedural question using zero-shot.

    **Observe:** You get a helpful explanation of the steps. But you still have to do each step yourself.

    ```sql
    <copy>
    SELECT AI CHAT How do I process an expense report;
    </copy>
    ```

3. Now try asking for something that requires YOUR data.

    **Observe:** The AI can't answer this because it has no access to your data. It gives a generic response about how to check order status, but it doesn't actually know YOUR order 12345.

    This is the limitation of zero-shot: great for general knowledge, useless for your specific business data.

    ```sql
    <copy>
    SELECT AI CHAT What is the status of order 12345;
    </copy>
    ```

4. Ask it to do something.

    **Observe:** The AI explains HOW to update an order but cannot actually do it. Zero-shot can advise; it cannot act.

    ```sql
    <copy>
    SELECT AI CHAT Update order 12345 to delivered;
    </copy>
    ```

## Task 2: Create an Agent with Tools

Now let's create an agent that can actually access AND modify your data. We'll give it two tools: one to look up orders and one to update them.

1. Create a sample orders table.

    ```sql
    <copy>
    CREATE TABLE sample_orders (
        order_id    VARCHAR2(20) PRIMARY KEY,
        customer    VARCHAR2(100),
        status      VARCHAR2(20),
        amount      NUMBER(10,2),
        order_date  DATE DEFAULT SYSDATE
    );

    INSERT INTO sample_orders VALUES ('12345', 'Acme Corp', 'SHIPPED', 299.00, SYSDATE - 3);
    INSERT INTO sample_orders VALUES ('12346', 'TechStart', 'PENDING', 150.00, SYSDATE - 1);
    INSERT INTO sample_orders VALUES ('12347', 'GlobalCo', 'DELIVERED', 499.00, SYSDATE - 7);
    COMMIT;
    </copy>
    ```

2. Create a function to look up orders (read).

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION lookup_order(
        p_order_id VARCHAR2
    ) RETURN VARCHAR2 AS
        v_result VARCHAR2(500);
    BEGIN
        SELECT 'Order ' || order_id || ': ' || status || 
               ', Customer: ' || customer || 
               ', Amount: $' || amount ||
               ', Date: ' || TO_CHAR(order_date, 'YYYY-MM-DD')
        INTO v_result
        FROM sample_orders
        WHERE order_id = p_order_id;
        
        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Order ' || p_order_id || ' not found.';
    END;
    /
    </copy>
    ```

3. Create a function to update order status (write).

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION update_order_status(
        p_order_id   VARCHAR2,
        p_new_status VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_old_status VARCHAR2(20);
    BEGIN
        -- Get current status
        SELECT status INTO v_old_status
        FROM sample_orders
        WHERE order_id = p_order_id;
        
        -- Update the status
        UPDATE sample_orders
        SET status = UPPER(p_new_status)
        WHERE order_id = p_order_id;
        
        COMMIT;
        
        RETURN 'Order ' || p_order_id || ' updated from ' || v_old_status || ' to ' || UPPER(p_new_status);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Order ' || p_order_id || ' not found. Cannot update.';
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN 'Error updating order: ' || SQLERRM;
    END;
    /
    </copy>
    ```

4. Register both as tools.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ORDER_LOOKUP_TOOL',
            attributes  => '{"instruction": "Look up order status and details by order ID. Parameter: P_ORDER_ID (the order number, e.g. 12345). Use this to check current order status before making updates.",
                            "function": "lookup_order"}',
            description => 'Retrieves order status, customer, amount, and date by order ID'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ORDER_UPDATE_TOOL',
            attributes  => '{"instruction": "Update an order status. Parameters: P_ORDER_ID (the order number), P_NEW_STATUS (PENDING, SHIPPED, or DELIVERED). Only call this after confirming the current status with ORDER_LOOKUP_TOOL.",
                            "function": "update_order_status"}',
            description => 'Updates order status to a new value'
        );
    END;
    /
    </copy>
    ```

5. Create an agent with both tools.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'ORDER_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are an order management agent. You can look up orders and update their status. Always look up an order first before updating it. Never make up order information - always use your tools."}',
            description => 'Agent that can look up and update orders'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'ORDER_TASK',
            attributes  => '{"instruction": "Help with order inquiries and updates. When asked to check an order, use ORDER_LOOKUP_TOOL. When asked to update an order, first use ORDER_LOOKUP_TOOL to verify current status, then use ORDER_UPDATE_TOOL to make the change. Do not ask clarifying questions - just do it. User request: {query}",
                            "tools": ["ORDER_LOOKUP_TOOL", "ORDER_UPDATE_TOOL"]}',
            description => 'Task for order lookups and updates'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'ORDER_TEAM',
            attributes  => '{"agents": [{"name": "ORDER_AGENT", "task": "ORDER_TASK"}],
                            "process": "sequential"}',
            description => 'Team for order management'
        );
    END;
    /
    </copy>
    ```

## Task 3: See the Agent Read Data

First, let's verify the agent can look up orders.

1. Set the team and ask about an order.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ORDER_TEAM');
    SELECT AI AGENT What is the status of order 12345;
    </copy>
    ```

**Compare to Task 1:** Zero-shot could only give generic advice. The agent returns the ACTUAL status: SHIPPED.

## Task 4: See the Agent Coordinate and Act

Now the real difference. Ask the agent to check AND update.

1. Ask the agent to update an order.

    ```sql
    <copy>
    SELECT AI AGENT Check order 12345 and if it has shipped, mark it as delivered;
    </copy>
    ```

**Observe:** The agent:
1. Called ORDER_LOOKUP_TOOL to check current status (SHIPPED)
2. Made a decision based on the result
3. Called ORDER_UPDATE_TOOL to change it to DELIVERED
4. Reported what it did

This is what zero-shot cannot do: **coordinate multiple steps and take action**.

2. Verify the change actually happened.

    ```sql
    <copy>
    SELECT order_id, customer, status FROM sample_orders WHERE order_id = '12345';
    </copy>
    ```

The status is now DELIVERED. The agent didn't just talk about updating - it actually did it.

3. Try a conditional update that should NOT happen.

    ```sql
    <copy>
    SELECT AI AGENT Check order 12346 and if it has shipped, mark it as delivered;
    </copy>
    ```

**Observe:** The agent looked up order 12346, saw it was PENDING (not SHIPPED), and correctly decided NOT to update it. This is intelligent coordination.

## Task 5: See What the Agent Did

The key difference is that agents take actions. Let's see the tool calls.

1. Query the tool history.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as called_at,
        SUBSTR(output, 1, 80) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

You can see the sequence: lookup, then update (or just lookup if no update was needed).

## Task 6: When to Use Each Approach

**Use zero-shot (SELECT AI CHAT) when:**
- You need a quick answer from general knowledge
- No data access is required
- You want advice or explanation

**Use SELECT AI (runsql/narrate) when:**
- You need to query your data
- Read-only access is sufficient
- Single-step retrieval

**Use agents (SELECT AI AGENT) when:**
- The task requires multiple steps
- You need to READ and WRITE data
- Decisions depend on data (conditional logic)
- Actions need coordination across tools

## Summary

In this lab, you directly compared zero-shot prompting with agent execution:

* Saw that zero-shot explains work but cannot access your data
* Built an agent with lookup AND update tools
* Watched the agent coordinate: check status → decide → act
* Verified the agent actually changed the data

**Key takeaway:** The difference isn't just intelligence—it's action. Zero-shot AI tells you what to do. Agents do it.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('ORDER_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('ORDER_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('ORDER_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ORDER_LOOKUP_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ORDER_UPDATE_TOOL', TRUE);
DROP TABLE sample_orders PURGE;
DROP FUNCTION lookup_order;
DROP FUNCTION update_order_status;
</copy>
```
