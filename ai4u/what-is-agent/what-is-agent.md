# What Is an AI Agent, Really?

## Introduction

Most people think AI is just a chatbot—you ask a question, it gives an answer. But agents do more. They don't just respond, they *act*. They look up real data, make decisions based on your systems, and complete tasks.

In this lab, you'll see that difference firsthand. You'll create an agent that can query actual order data from your database—not explain how to check orders, but actually check them and give you real answers.

Estimated Time: 10 minutes

### Objectives

* Create sample data for the agent to query
* Build an agent with a SQL tool
* See the agent look up real information
* Understand why execution beats explanation

### Prerequisites

This lab assumes you have:

* An AI profile named `genai` already configured with your AI provider credentials

## Task 1: Create Sample Order Data

First, let's create a simple orders table. This gives the agent something real to work with.

1. Create the orders table.

    ```sql
    <copy>
    CREATE TABLE customer_orders (
        order_id           VARCHAR2(20) PRIMARY KEY,
        customer_name      VARCHAR2(100),
        order_date         DATE,
        order_status       VARCHAR2(30),
        order_total_amount NUMBER(10,2)
    );
    </copy>
    ```

2. Add comments so Select AI understands what this table contains.

    >**Note:** Select AI reads table and column comments to understand your schema. Good comments make the AI smarter about your data.

    ```sql
    <copy>
    COMMENT ON TABLE customer_orders IS 'Customer orders including status tracking and amounts';
    COMMENT ON COLUMN customer_orders.order_id IS 'Unique order identifier like ORD-12345';
    COMMENT ON COLUMN customer_orders.customer_name IS 'Full name of the customer who placed the order';
    COMMENT ON COLUMN customer_orders.order_date IS 'Date the order was placed';
    COMMENT ON COLUMN customer_orders.order_status IS 'Current status: Pending, Processing, Shipped, or Delivered';
    COMMENT ON COLUMN customer_orders.order_total_amount IS 'Total order amount in dollars';
    </copy>
    ```

3. Add some sample orders.

    ```sql
    <copy>
    INSERT INTO customer_orders VALUES ('ORD-12345', 'Alex Chen', DATE '2025-01-02', 'Shipped', 299.99);
    INSERT INTO customer_orders VALUES ('ORD-12346', 'Maria Santos', DATE '2025-01-03', 'Processing', 149.50);
    INSERT INTO customer_orders VALUES ('ORD-12347', 'James Wilson', DATE '2024-12-28', 'Delivered', 89.00);
    INSERT INTO customer_orders VALUES ('ORD-12348', 'Sarah Johnson', DATE '2025-01-04', 'Pending', 450.00);
    COMMIT;
    </copy>
    ```

4. Verify the data exists.

    ```sql
    <copy>
    SELECT order_id, customer_name, order_status, order_total_amount FROM customer_orders;
    </copy>
    ```

## Task 2: Create the Agent Components

Now let's build an agent that can query this data. We need four pieces: a tool, an agent, a task, and a team.

1. Create the SQL tool. This gives the agent the ability to query your database.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'ORDER_LOOKUP',
            attributes  => '{"tool_type": "SQL",
                            "tool_params": {"profile_name": "genai"}}',
            description => 'Query the CUSTOMER_ORDERS table to look up order status, amounts, dates, and customer information'
        );
    END;
    /
    </copy>
    ```

2. Create the agent with a clear role.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'ORDER_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are a helpful order assistant. Look up order information and provide accurate answers based on actual data."}',
            description => 'Agent that looks up order information'
        );
    END;
    /
    </copy>
    ```

3. Create the task that tells the agent what to do and which tools to use.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'ORDER_TASK',
            attributes  => '{"instruction": "Help the user with their order inquiry. Use the ORDER_LOOKUP tool to find real order data. User request: {query}",
                            "tools": ["ORDER_LOOKUP"]}',
            description => 'Task for handling order inquiries'
        );
    END;
    /
    </copy>
    ```

4. Create the team that connects everything together.

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

5. Verify everything is created.

    ```sql
    <copy>
    SELECT tool_name, status FROM USER_AI_AGENT_TOOLS WHERE tool_name = 'ORDER_LOOKUP';
    SELECT agent_name, status FROM USER_AI_AGENTS WHERE agent_name = 'ORDER_AGENT';
    SELECT task_name, status FROM USER_AI_AGENT_TASKS WHERE task_name = 'ORDER_TASK';
    SELECT agent_team_name, status FROM USER_AI_AGENT_TEAMS WHERE agent_team_name = 'ORDER_TEAM';
    </copy>
    ```

## Task 3: See the Agent in Action

Now let's see the difference between an agent and a chatbot.

1. Set the team for your session.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ORDER_TEAM');
    </copy>
    ```

2. Ask about a specific order.

    **This is the key moment.** The agent doesn't explain *how* to check order status. It actually queries the customer_orders table and tells you the answer.

    ```sql
    <copy>
    SELECT AI AGENT What is the status of order ORD-12345;
    </copy>
    ```

3. Ask about another order.

    ```sql
    <copy>
    SELECT AI AGENT How much was order ORD-12347;
    </copy>
    ```

4. Ask a question that requires reasoning over data.

    ```sql
    <copy>
    SELECT AI AGENT Which orders are still being processed;
    </copy>
    ```

## Task 4: See What Happened Behind the Scenes

The agent used a tool to get real answers. Let's see the evidence.

1. Check the tool execution history.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as called_at,
        SUBSTR(output, 1, 60) as result
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

2. Check the team execution history.

    ```sql
    <copy>
    SELECT 
        team_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as started,
        state
    FROM USER_AI_AGENT_TEAM_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

## Task 5: The Chatbot vs Agent Difference

**A chatbot would say:**

> "To check the status of an order, you would typically:
> 1. Log into your account
> 2. Navigate to Order History
> 3. Find the order by ID
> 4. View the current status"

**The agent said:**

> "Order ORD-12345 was placed on January 2, 2025 for $299.99. Current status: Shipped."

Same question. One explains the process. The other runs it.

That's what makes an agent an agent—it doesn't just know things, it *does* things.

## Summary

In this lab, you experienced the fundamental nature of AI agents:

* Created a table with descriptive comments for Select AI
* Built an agent with access to a SQL tool
* Watched it query real data to answer questions
* Saw the execution history proving it took action
* Understood the difference between explanation and execution

**Key takeaway:** An agent acts on your systems. A chatbot explains how you could act on your systems. That's the difference that matters.

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
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ORDER_LOOKUP', TRUE);
DROP TABLE customer_orders PURGE;
</copy>
```
