# Why Agents Beat Zero Shot Prompts

## Introduction

In this lab, you'll directly compare zero-shot prompting with agent-based execution to understand why agents are transforming how work gets done.

Zero-shot prompting means: one question, one answer, done. It's useful for general knowledge, but it doesn't execute workflows or access your data. Agents break tasks into steps, use tools, and actually complete the work.

You'll ask the same question using both approaches and see the difference firsthand.

Estimated Time: 10 minutes

### Objectives

* Understand what zero-shot prompting means
* Compare zero-shot responses to agent responses
* See how agents can execute multi-step tasks
* Recognize when to use each approach

### Prerequisites

This lab assumes you have:

* Completed Lab 1 or have a working agent setup
* An AI profile named `genai` already configured
* Oracle Database 26ai with Select AI Agent
* Basic knowledge of SQL

## Task 1: Experience Zero-Shot Prompting

Zero-shot queries go directly to the LLM for general knowledge answers. Use `SELECT AI CHAT` to ask questions without involving your database.

1. Set the profile.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI.SET_PROFILE('genai');
    </copy>
    ```

2. Ask a procedural question using zero-shot.

    ```sql
    <copy>
    SELECT AI CHAT How do I process an expense report;
    </copy>
    ```

    **Observe:** You get a helpful explanation of the steps. But you still have to do each step yourself.

3. Ask a more complex question.

    ```sql
    <copy>
    SELECT AI CHAT A customer says their order never arrived. What should I do;
    </copy>
    ```

    **Observe:** Again, you get instructions. The AI explains the work but doesn't do the work.

4. Ask about best practices.

    ```sql
    <copy>
    SELECT AI CHAT What are best practices for customer service;
    </copy>
    ```

    **Observe:** Great for general knowledge—no data needed.

5. Now try asking for something that requires YOUR data.

    ```sql
    <copy>
    SELECT AI CHAT What is the status of order 12345;
    </copy>
    ```

    **Observe:** The AI can't answer this because it has no access to your data. It gives a generic response about how to check order status, but it doesn't actually know YOUR order 12345.

This is the limitation of zero-shot: great for general knowledge, useless for your specific business data.

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
            attributes  => '{"instruction": "Look up order status and details. Use when someone asks about an order. IMPORTANT: Use UPPERCASE parameter name: P_ORDER_ID (the order number).",
                            "function": "lookup_order"}',
            description => 'Retrieves order information by order ID'
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
                            "role": "You are a customer service agent who can look up order information. When asked about orders, use the ORDER_LOOKUP_TOOL to get the actual status."}',
            description => 'Agent that can look up orders'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'ORDER_TASK',
            attributes  => '{"instruction": "Help with order inquiries. Use ORDER_LOOKUP_TOOL to get order details. User request: {query}",
                            "tools": ["ORDER_LOOKUP_TOOL"]}',
            description => 'Task for order lookups'
        );
    END;
    /

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

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ORDER_TEAM');
    SELECT AI AGENT What is the status of order 12345;
    </copy>
    ```

    **Result:** The agent calls the lookup tool and returns the actual status: "SHIPPED, Customer: Acme Corp, Amount: $299.00"

    Compare this to Task 1 where zero-shot couldn't tell you anything about order 12345!

2. Try another order.

    ```sql
    <copy>
    SELECT AI AGENT Is order 12346 ready yet;
    </copy>
    ```

    The agent looks it up and reports: "PENDING"

3. Ask about a non-existent order.

    ```sql
    <copy>
    SELECT AI AGENT Check on order 99999;
    </copy>
    ```

    The agent looks it up and reports it wasn't found.

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

    You'll see each ORDER_LOOKUP_TOOL call the agent made.

2. Compare the interaction patterns.

    | Zero-Shot (SELECT AI CHAT) | Agent (SELECT AI AGENT) |
    |----------------------------|-------------------------|
    | Single prompt, single response | Multi-step with tool calls |
    | No data access | Queries your database |
    | Explains what to do | Does the work |
    | General knowledge only | Your specific business data |

## Task 5: When to Use Each Approach

Based on what you've seen:

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

## Learn More

* [DBMS_CLOUD_AI Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html)
* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026
