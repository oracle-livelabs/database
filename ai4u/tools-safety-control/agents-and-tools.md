# Tools, Safety, and Human Control

## Introduction

In this capstone lab, you'll build a complete agent system with tools that act, rules that constrain, and human oversight that keeps people in control.

Agents don't act directly on systems—they act through tools you explicitly build and register. This separation is what makes agents both powerful and safe. Tools define what's *possible*. Rules define what's *allowed*. Human-in-the-loop defines when to *pause*.

You'll create an expense processing agent with multiple tools, add safety rules that enforce business policies, enable human approval for high-stakes decisions, and query the audit trail to see everything that happened.

Estimated Time: 25 minutes

### Objectives

* Create PL/SQL functions as agent tools
* Build a safety rules system with JSON configuration
* Add database constraints as a backstop
* Enable human-in-the-loop for approval workflows
* Query the audit trail to see all actions

### Prerequisites

This lab assumes you have:

* Completed Labs 1-9 or have a working agent setup
* An AI profile named `genai` already configured
* Oracle Database 26ai with Select AI Agent
* Basic knowledge of SQL and PL/SQL

---

## Part 1: Tools That Act

Tools are PL/SQL functions that agents can call. They're the only way an agent can affect your systems.

### Task 1: Create the Data Model

1. Create tables with built-in constraints (safety at the database level).

    ```sql
    <copy>
    -- Employees table
    CREATE TABLE employees (
        employee_id   VARCHAR2(20) PRIMARY KEY,
        name          VARCHAR2(100) NOT NULL,
        email         VARCHAR2(100) NOT NULL,
        department    VARCHAR2(50),
        manager_id    VARCHAR2(20),
        expense_limit NUMBER(10,2) DEFAULT 500
    );

    -- Expense requests with constraints
    CREATE TABLE expense_requests (
        request_id    VARCHAR2(20) PRIMARY KEY,
        employee_id   VARCHAR2(20) NOT NULL REFERENCES employees(employee_id),
        amount        NUMBER(10,2) NOT NULL 
                      CONSTRAINT chk_positive_amount CHECK (amount > 0),
        category      VARCHAR2(50) NOT NULL
                      CONSTRAINT chk_category CHECK (category IN ('travel','meals','supplies','equipment','training')),
        description   VARCHAR2(500),
        status        VARCHAR2(20) DEFAULT 'PENDING'
                      CONSTRAINT chk_status CHECK (status IN ('PENDING','APPROVED','REJECTED','NEEDS_APPROVAL','PAID')),
        submitted_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
        approved_by   VARCHAR2(100),
        approved_at   TIMESTAMP
    );

    -- Sequence for request IDs
    CREATE SEQUENCE expense_seq START WITH 1001;

    -- Insert sample employees
    INSERT INTO employees VALUES ('EMP-001', 'Alice Johnson', 'alice@company.com', 'Engineering', NULL, 1000);
    INSERT INTO employees VALUES ('EMP-002', 'Bob Smith', 'bob@company.com', 'Sales', 'EMP-001', 500);
    INSERT INTO employees VALUES ('EMP-003', 'Carol Davis', 'carol@company.com', 'Marketing', 'EMP-001', 500);

    COMMIT;
    </copy>
    ```

### Task 2: Create Tool Functions

1. Create the expense submission tool.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION submit_expense(
        p_employee_id VARCHAR2,
        p_amount      NUMBER,
        p_category    VARCHAR2,
        p_description VARCHAR2
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_request_id VARCHAR2(20);
        v_limit NUMBER;
    BEGIN
        -- Get employee's expense limit
        SELECT expense_limit INTO v_limit 
        FROM employees WHERE employee_id = p_employee_id;
        
        -- Generate request ID
        v_request_id := 'EXP-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || expense_seq.NEXTVAL;
        
        -- Insert the request
        INSERT INTO expense_requests (request_id, employee_id, amount, category, description, status)
        VALUES (
            v_request_id, 
            p_employee_id, 
            p_amount, 
            LOWER(p_category), 
            p_description,
            CASE WHEN p_amount > v_limit THEN 'NEEDS_APPROVAL' ELSE 'PENDING' END
        );
        
        COMMIT;
        
        RETURN JSON_OBJECT(
            'request_id' VALUE v_request_id,
            'status'     VALUE CASE WHEN p_amount > v_limit THEN 'NEEDS_APPROVAL' ELSE 'PENDING' END,
            'message'    VALUE CASE 
                WHEN p_amount > v_limit THEN 'Amount exceeds limit ($' || v_limit || '). Requires approval.'
                ELSE 'Expense submitted successfully.'
            END
        );
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN JSON_OBJECT('error' VALUE SQLERRM);
    END;
    /
    </copy>
    ```

2. Create an expense lookup tool.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION get_expense_status(
        p_request_id VARCHAR2
    ) RETURN VARCHAR2 AS
        v_result VARCHAR2(500);
    BEGIN
        SELECT JSON_OBJECT(
            'request_id'  VALUE request_id,
            'employee'    VALUE (SELECT name FROM employees WHERE employee_id = e.employee_id),
            'amount'      VALUE amount,
            'category'    VALUE category,
            'status'      VALUE status,
            'submitted'   VALUE TO_CHAR(submitted_at, 'YYYY-MM-DD HH24:MI'),
            'approved_by' VALUE NVL(approved_by, 'N/A')
        )
        INTO v_result
        FROM expense_requests e
        WHERE request_id = p_request_id;
        
        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN JSON_OBJECT('error' VALUE 'Expense not found: ' || p_request_id);
    END;
    /
    </copy>
    ```

3. Create an employee lookup tool.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION get_employee_info(
        p_employee_id VARCHAR2
    ) RETURN VARCHAR2 AS
        v_result VARCHAR2(500);
    BEGIN
        SELECT JSON_OBJECT(
            'employee_id'   VALUE employee_id,
            'name'          VALUE name,
            'department'    VALUE department,
            'expense_limit' VALUE expense_limit
        )
        INTO v_result
        FROM employees
        WHERE employee_id = p_employee_id;
        
        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN JSON_OBJECT('error' VALUE 'Employee not found: ' || p_employee_id);
    END;
    /
    </copy>
    ```

---

## Part 2: Safety Rules

Tools define what's possible. Rules define what's allowed. We'll create a flexible rules system using JSON.

### Task 3: Create the Rules System

1. Create a safety rules table.

    ```sql
    <copy>
    CREATE TABLE safety_rules (
        rule_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        rule_name    VARCHAR2(200) NOT NULL,
        rule_type    VARCHAR2(20) NOT NULL 
                     CONSTRAINT chk_rule_type CHECK (rule_type IN ('BLOCK','REQUIRE_APPROVAL','WARN','AUTO_APPROVE')),
        rule_config  JSON NOT NULL,
        priority     NUMBER DEFAULT 100,
        is_active    NUMBER(1) DEFAULT 1,
        created_at   TIMESTAMP DEFAULT SYSTIMESTAMP
    );
    </copy>
    ```

2. Add safety rules.

    ```sql
    <copy>
    -- Block excessive amounts
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'Block Excessive Expense',
        'BLOCK',
        JSON_OBJECT(
            'field'    VALUE 'amount',
            'operator' VALUE 'gt',
            'value'    VALUE 5000,
            'message'  VALUE 'Expenses over $5,000 are not permitted through self-service. Contact Finance directly.'
        ),
        10
    );

    -- Require approval for high amounts
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'High Amount Approval',
        'REQUIRE_APPROVAL',
        JSON_OBJECT(
            'field'    VALUE 'amount',
            'operator' VALUE 'gte',
            'value'    VALUE 1000,
            'message'  VALUE 'Expenses $1,000 and above require manager approval.'
        ),
        20
    );

    -- Require approval for equipment
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'Equipment Approval',
        'REQUIRE_APPROVAL',
        JSON_OBJECT(
            'field'    VALUE 'category',
            'operator' VALUE 'eq',
            'value'    VALUE 'equipment',
            'message'  VALUE 'Equipment purchases require manager approval regardless of amount.'
        ),
        30
    );

    -- Auto-approve small expenses
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'Auto-approve Small',
        'AUTO_APPROVE',
        JSON_OBJECT(
            'field'    VALUE 'amount',
            'operator' VALUE 'lt',
            'value'    VALUE 50,
            'message'  VALUE 'Small expenses under $50 are auto-approved.'
        ),
        100
    );

    COMMIT;
    </copy>
    ```

3. Create the rules checking function.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION check_expense_rules(
        p_amount   NUMBER,
        p_category VARCHAR2
    ) RETURN VARCHAR2 AS
        v_result JSON;
    BEGIN
        -- Check rules in priority order
        FOR rec IN (
            SELECT rule_name, rule_type, rule_config
            FROM safety_rules
            WHERE is_active = 1
            ORDER BY priority
        ) LOOP
            DECLARE
                v_field    VARCHAR2(50) := JSON_VALUE(rec.rule_config, '$.field');
                v_operator VARCHAR2(10) := JSON_VALUE(rec.rule_config, '$.operator');
                v_value    VARCHAR2(100) := JSON_VALUE(rec.rule_config, '$.value');
                v_message  VARCHAR2(500) := JSON_VALUE(rec.rule_config, '$.message');
                v_match    BOOLEAN := FALSE;
            BEGIN
                -- Evaluate rule
                IF v_field = 'amount' THEN
                    IF v_operator = 'gt' AND p_amount > TO_NUMBER(v_value) THEN v_match := TRUE;
                    ELSIF v_operator = 'gte' AND p_amount >= TO_NUMBER(v_value) THEN v_match := TRUE;
                    ELSIF v_operator = 'lt' AND p_amount < TO_NUMBER(v_value) THEN v_match := TRUE;
                    ELSIF v_operator = 'lte' AND p_amount <= TO_NUMBER(v_value) THEN v_match := TRUE;
                    ELSIF v_operator = 'eq' AND p_amount = TO_NUMBER(v_value) THEN v_match := TRUE;
                    END IF;
                ELSIF v_field = 'category' THEN
                    IF v_operator = 'eq' AND LOWER(p_category) = LOWER(v_value) THEN v_match := TRUE;
                    END IF;
                END IF;
                
                -- Return first matching rule
                IF v_match THEN
                    IF rec.rule_type = 'BLOCK' THEN
                        RETURN JSON_OBJECT(
                            'allowed' VALUE false,
                            'action'  VALUE 'BLOCKED',
                            'rule'    VALUE rec.rule_name,
                            'message' VALUE v_message
                        );
                    ELSIF rec.rule_type = 'REQUIRE_APPROVAL' THEN
                        RETURN JSON_OBJECT(
                            'allowed' VALUE true,
                            'action'  VALUE 'NEEDS_APPROVAL',
                            'rule'    VALUE rec.rule_name,
                            'message' VALUE v_message
                        );
                    ELSIF rec.rule_type = 'AUTO_APPROVE' THEN
                        RETURN JSON_OBJECT(
                            'allowed' VALUE true,
                            'action'  VALUE 'AUTO_APPROVED',
                            'rule'    VALUE rec.rule_name,
                            'message' VALUE v_message
                        );
                    END IF;
                END IF;
            END;
        END LOOP;
        
        -- No rule matched - allow with standard processing
        RETURN JSON_OBJECT(
            'allowed' VALUE true,
            'action'  VALUE 'STANDARD',
            'message' VALUE 'No special rules apply. Standard processing.'
        );
    END;
    /
    </copy>
    ```

4. Test the rules.

    ```sql
    <copy>
    -- Test various scenarios
    SELECT check_expense_rules(25, 'meals') as small_expense FROM DUAL;
    SELECT check_expense_rules(500, 'travel') as medium_expense FROM DUAL;
    SELECT check_expense_rules(1500, 'training') as large_expense FROM DUAL;
    SELECT check_expense_rules(200, 'equipment') as equipment_expense FROM DUAL;
    SELECT check_expense_rules(10000, 'travel') as blocked_expense FROM DUAL;
    </copy>
    ```

---

## Part 3: Human-in-the-Loop

Some decisions need human judgment. Oracle's agent framework supports genuine pauses for approval.

### Task 4: Register Tools and Create the Agent

1. Register all tools.

    ```sql
    <copy>
    BEGIN
        -- Submit expense tool
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'SUBMIT_EXPENSE_TOOL',
            attributes  => '{"instruction": "Submit an expense request. Parameters: P_EMPLOYEE_ID, P_AMOUNT (number), P_CATEGORY (travel/meals/supplies/equipment/training), P_DESCRIPTION.",
                            "function": "submit_expense"}',
            description => 'Creates expense request'
        );
        
        -- Check rules tool
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'CHECK_RULES_TOOL',
            attributes  => '{"instruction": "Check expense rules BEFORE submitting. Parameters: P_AMOUNT (number), P_CATEGORY. ALWAYS call this before SUBMIT_EXPENSE_TOOL.",
                            "function": "check_expense_rules"}',
            description => 'Validates expense against rules'
        );
        
        -- Get expense status tool
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'GET_EXPENSE_TOOL',
            attributes  => '{"instruction": "Look up expense status. Parameter: P_REQUEST_ID.",
                            "function": "get_expense_status"}',
            description => 'Retrieves expense details'
        );
        
        -- Get employee info tool
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'GET_EMPLOYEE_TOOL',
            attributes  => '{"instruction": "Look up employee info. Parameter: P_EMPLOYEE_ID.",
                            "function": "get_employee_info"}',
            description => 'Retrieves employee details'
        );
    END;
    /
    </copy>
    ```

2. Create the agent with human-in-the-loop enabled.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'EXPENSE_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are an expense processing agent. ALWAYS check rules before submitting expenses. If rules require approval, ask the human before proceeding. Never submit blocked expenses."}',
            description => 'Expense processing agent with safety controls'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'EXPENSE_TASK',
            attributes  => '{"instruction": "Process expense requests following this workflow: 1. First, call CHECK_RULES_TOOL to validate the expense 2. If BLOCKED: Explain why and do NOT submit 3. If NEEDS_APPROVAL: Ask human for authorization before submitting 4. If allowed: Call SUBMIT_EXPENSE_TOOL. User request: {query}",
                            "tools": ["CHECK_RULES_TOOL", "SUBMIT_EXPENSE_TOOL", "GET_EXPENSE_TOOL", "GET_EMPLOYEE_TOOL"],
                            "enable_human_tool": "true"}',
            description => 'Expense processing with human-in-the-loop'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'EXPENSE_TEAM',
            attributes  => '{"agents": [{"name": "EXPENSE_AGENT", "task": "EXPENSE_TASK"}],
                            "process": "sequential"}',
            description => 'Expense processing team'
        );
    END;
    /
    </copy>
    ```

### Task 5: Test the Complete Workflow

1. Set the team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('EXPENSE_TEAM');
    </copy>
    ```

2. Test a small expense (auto-approve path).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $35 expense for office supplies for employee EMP-002;
    </copy>
    ```

The agent should check rules, see AUTO_APPROVED, and submit.

3. Test a medium expense (standard path).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $200 expense for team lunch for employee EMP-003;
    </copy>
    ```

4. Test a high-value expense (approval required path).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $1,500 expense for conference registration for employee EMP-002;
    </copy>
    ```

**The agent should pause and ask for approval.**

5. Test a blocked expense.

    ```sql
    <copy>
    SELECT AI AGENT Submit a $7,500 expense for new servers for employee EMP-001;
    </copy>
    ```

The agent should check rules, see BLOCKED, and refuse to submit.

6. Test equipment (always needs approval).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $150 expense for a keyboard for employee EMP-002;
    </copy>
    ```

---

## Part 4: Audit Trail

Everything the agent does is logged. This is essential for compliance and debugging.

### Task 6: Query the Audit Trail

1. See all tool calls.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as called,
        SUBSTR(input, 1, 50) as input_preview,
        SUBSTR(output, 1, 50) as output_preview
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 15 ROWS ONLY;
    </copy>
    ```

2. See the full input/output for recent calls.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'YYYY-MM-DD HH24:MI:SS') as when,
        input as full_input,
        output as full_output
    FROM USER_AI_AGENT_TOOL_HISTORY
    WHERE start_date > SYSTIMESTAMP - INTERVAL '10' MINUTE
    ORDER BY start_date;
    </copy>
    ```

3. See all expense requests created.

    ```sql
    <copy>
    SELECT 
        request_id,
        (SELECT name FROM employees WHERE employee_id = e.employee_id) as employee,
        amount,
        category,
        status,
        TO_CHAR(submitted_at, 'HH24:MI:SS') as submitted
    FROM expense_requests e
    ORDER BY submitted_at DESC;
    </copy>
    ```

4. Audit summary: tools used by type.

    ```sql
    <copy>
    SELECT 
        tool_name,
        COUNT(*) as call_count,
        MIN(start_date) as first_call,
        MAX(start_date) as last_call
    FROM USER_AI_AGENT_TOOL_HISTORY
    GROUP BY tool_name
    ORDER BY call_count DESC;
    </copy>
    ```

---

## Summary

In this capstone lab, you built a complete agent system with:

**Part 1: Tools**
- PL/SQL functions that agents can call
- Clean separation: LLM reasons, tools act
- If there's no tool, the agent can't do it

**Part 2: Safety Rules**
- JSON-configured business rules
- BLOCK / REQUIRE_APPROVAL / WARN / AUTO_APPROVE
- Rules engine the agent calls before acting
- Database constraints as the final backstop

**Part 3: Human-in-the-Loop**
- `enable_human_tool` for approval workflows
- Agent genuinely pauses for human input
- Collaboration spectrum: autonomous → supervised → collaborative

**Part 4: Audit Trail**
- Every tool call logged automatically
- Full input/output captured
- Explainable agent behavior

**Key takeaway:** Agents are safe because their boundaries are explicit. Tools define capabilities. Rules define constraints. Humans retain control. Everything is auditable.

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/dbseg/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('EXPENSE_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('EXPENSE_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('EXPENSE_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('SUBMIT_EXPENSE_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('CHECK_RULES_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_EXPENSE_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_EMPLOYEE_TOOL', TRUE);
DROP TABLE expense_requests;
DROP TABLE employees;
DROP TABLE safety_rules;
DROP SEQUENCE expense_seq;
DROP FUNCTION submit_expense;
DROP FUNCTION get_expense_status;
DROP FUNCTION get_employee_info;
DROP FUNCTION check_expense_rules;
</copy>
```
