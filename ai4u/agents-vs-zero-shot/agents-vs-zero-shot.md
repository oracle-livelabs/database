# Why Agents Beat Zero Shot Prompts

## Introduction

In this lab, you'll directly compare zero-shot prompting with agent-based execution to understand why agents are transforming how work gets done.

Zero-shot prompting means: one question, one answer, done. It's useful for general knowledge, but it doesn't execute workflows or access your data. Agents break tasks into steps, use tools, and actually complete the work.

Estimated Time: 10 minutes

### Objectives

* Understand what zero-shot prompting means
* Compare zero-shot responses to agent responses
* See how agents can execute multi-step tasks
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

3. Ask a more complex question.

    **Observe:** Again, you get instructions. The AI explains the work but doesn't do the work.

    ```sql
    <copy>
    SELECT AI CHAT A customer says their order never arrived. What should I do;
    </copy>
    ```

4. Ask about best practices.

    **Observe:** Great for general knowledge—no data needed.

    ```sql
    <copy>
    SELECT AI CHAT What are best practices for customer service;
    </copy>
    ```

5. Now try asking for something that requires YOUR data.

    **Observe:** The AI can't answer this because it has no access to your data. It gives a generic response about how to check order status, but it doesn't actually know YOUR order 12345.

    This is the limitation of zero-shot: great for general knowledge, useless for your specific business data.

    ```sql
    <copy>
    SELECT AI CHAT What is the status of order 12345;
    </copy>
    ```

## Task 2: Create an Agent with Tools

Now let's create an agent that can actually access your data. We'll give it a tool to look up order information.

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

2. Create a function to look up orders.

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

3. Register it as a tool.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ORDER_LOOKUP_TOOL',
            attributes  => '{"instruction": "Look up order status and details by order ID. Parameter: P_ORDER_ID (the order number, e.g. 12345). Always use this tool when asked about orders.",
                            "function": "lookup_order"}',
            description => 'Retrieves order status, customer, amount, and date by order ID'
        );
    END;
    /
    </copy>
    ```

4. Create an agent with this tool.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'ORDER_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a customer service agent. When asked about orders, ALWAYS use the ORDER_LOOKUP_TOOL to get the actual data. Never make up order information - always look it up."}',
            description => 'Agent that can look up orders'
        );
    END;
    /
    </copy>
    ```

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'ORDER_TASK',
            attributes  => '{"instruction": "Help with order inquiries. ALWAYS use ORDER_LOOKUP_TOOL to look up order information - never guess or ask clarifying questions about order details. Just look up the order and report what you find. User request: {query}",
                            "tools": ["ORDER_LOOKUP_TOOL"]}',
            description => 'Task for order lookups'
        );
    END;
    /
    </copy>
    ```

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'ORDER_TEAM',
            attributes  => '{"agents": [{"name": "ORDER_AGENT", "task": "ORDER_TASK"}],
                            "process": "sequential"}',
            description => 'Team for order inquiries'
        );
    END;
    /
    </copy>
    ```

## Task 3: Compare the Same Question

Now let's ask about order 12345 again—but this time with an agent.

1. Set the team and ask the agent.

    **Result:** The agent calls the lookup tool and returns the actual status. Compare this to Task 1 where zero-shot couldn't tell you anything about order 12345!

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ORDER_TEAM');
    SELECT AI AGENT What is the status of order 12345;
    </copy>
    ```

2. Try another order.

    ```sql
    <copy>
    SELECT AI AGENT Is order 12346 ready yet;
    </copy>
    ```

3. Ask about a non-existent order.

    ```sql
    <copy>
    SELECT AI AGENT Check on order 99999;
    </copy>
    ```

## Task 4: See What the Agent Did

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
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

## Task 5: When to Use Each Approach

**Use zero-shot (SELECT AI CHAT) when:**
- You need a quick answer from general knowledge
- No data access is required
- Single-step response is sufficient
- You're brainstorming or exploring

**Use agents (SELECT AI AGENT) when:**
- The task requires multiple steps
- You need to access business data
- Actions need to happen in systems
- Results should be tracked

## Summary

In this lab, you directly compared zero-shot prompting with agent execution:

* Saw that zero-shot explains work but doesn't execute it
* Built an agent with a tool to access data
* Compared the same question using both approaches
* Understood when each approach is appropriate

**Key takeaway:** The difference isn't intelligence—it's action. Zero-shot AI tells you what to do. Agents do it.

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
DROP TABLE sample_orders;
DROP FUNCTION lookup_order;
</copy>
```
