# Tools, Safety, and Human Control

## Introduction

In this capstone lab, you'll build a complete agent system with tools that act, rules that constrain, and human oversight that keeps people in control.

### The Business Problem

Seer Equity is ready to deploy AI agents, but the compliance team has concerns:

> *"We can't have an AI approving $50,000 expenses automatically. What if it makes a mistake? Where's the audit trail? How do we prove we followed policy?"*
>
> Rachel, Compliance Director

Legitimate concerns. The previous labs gave agents memory and intelligence. This lab gives them **boundaries and accountability**:

- **Tools define what's possible**: No tool = no action
- **Rules define what's allowed**: JSON-configured business logic
- **Separation of duties**: Different agents for different roles
- **Audit trails**: Every action logged and traceable

### What You'll Learn

In this capstone lab, you'll build a complete expense system with two agents:

| Agent | Role | Tools | Constraint |
|-------|------|-------|------------|
| **EXPENSE_AGENT** | Employees submit expenses | Submit only | Can't approve their own |
| **APPROVAL_AGENT** | Managers review/approve | Approve, Reject | Must review before approving |

This separation demonstrates real-world agent design: different roles, different capabilities, different tools. It's the foundation for compliant AI deployment.

**What you'll build:** A two-agent expense system with safety rules, separation of duties, and complete audit trails.

Estimated Time: 25 minutes

### Objectives

* Create PL/SQL functions as agent tools
* Build a safety rules system with JSON configuration
* Create separate agents for different roles
* See how agents respect rules and route work appropriately
* Query the audit trail to see all actions

### Prerequisites

This lab assumes you have:

* Completed Labs 1-9 or have a working agent setup
* An AI profile named `genai` already configured

---

## Part 1: The Data Model

### Task 1: Import the Lab Notebook

Before you begin, import the notebook for this lab into Oracle Machine Learning.

1. From the Oracle Machine Learning home page, click **Notebooks**.

2. Click **Import**.

3. Select **GitHub** as the source.

4. Paste the following GitHub URL:

    ```text
    <copy>
    https://github.com/davidstart/ideation/blob/main/blogseries/select_ai_agentic_memory/tools-safety-control/lab10-tools-safety-control.json
    </copy>
    ```

5. Click **Import**.

The notebook contains all the SQL commands for this lab. You can follow along with the detailed instructions below or run the notebook cells directly.

### Task 2: Create Tables

1. Create the expense system tables.

    ```sql
    <copy>
    -- Sequence for request IDs
    CREATE SEQUENCE expense_seq START WITH 1001;

    -- Employees table
    CREATE TABLE employees (
        employee_id   VARCHAR2(20) PRIMARY KEY,
        name          VARCHAR2(100) NOT NULL,
        email         VARCHAR2(100) NOT NULL,
        department    VARCHAR2(50),
        manager_id    VARCHAR2(20)
    );

    -- Expense requests
    CREATE TABLE expense_requests (
        request_id    VARCHAR2(20) PRIMARY KEY,
        employee_id   VARCHAR2(20) NOT NULL REFERENCES employees(employee_id),
        amount        NUMBER(10,2) NOT NULL 
                      CONSTRAINT chk_positive_amount CHECK (amount > 0),
        category      VARCHAR2(50) NOT NULL
                      CONSTRAINT chk_category CHECK (category IN ('travel','meals','supplies','equipment','training')),
        description   VARCHAR2(500),
        status        VARCHAR2(30) DEFAULT 'NEEDS_APPROVAL'
                      CONSTRAINT chk_status CHECK (status IN ('APPROVED','REJECTED','NEEDS_APPROVAL')),
        submitted_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
        approved_by   VARCHAR2(100),
        approved_at   TIMESTAMP
    );

    -- Safety rules
    CREATE TABLE safety_rules (
        rule_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
        rule_name    VARCHAR2(200) NOT NULL,
        rule_type    VARCHAR2(20) NOT NULL 
                     CONSTRAINT chk_rule_type CHECK (rule_type IN ('BLOCK','REQUIRE_APPROVAL','AUTO_APPROVE')),
        rule_config  JSON NOT NULL,
        priority     NUMBER DEFAULT 100,
        is_active    NUMBER(1) DEFAULT 1
    );

    -- Insert sample employees
    INSERT INTO employees VALUES ('EMP-001', 'Alice Johnson', 'alice@company.com', 'Engineering', NULL);
    INSERT INTO employees VALUES ('EMP-002', 'Bob Smith', 'bob@company.com', 'Sales', 'EMP-001');
    INSERT INTO employees VALUES ('EMP-003', 'Carol Davis', 'carol@company.com', 'Marketing', 'EMP-001');

    COMMIT;
    </copy>
    ```

### Task 3: Create Safety Rules

1. Add the business rules.

    ```sql
    <copy>
    -- Block excessive amounts (>$5000)
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'Block Excessive Expense',
        'BLOCK',
        '{"field": "amount", "operator": "gt", "value": 5000, "message": "Expenses over $5,000 are not permitted. Contact Finance directly."}',
        10
    );

    -- Require approval for high amounts (>=$1000)
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'High Amount Approval',
        'REQUIRE_APPROVAL',
        '{"field": "amount", "operator": "gte", "value": 1000, "message": "Expenses $1,000 and above require manager approval."}',
        20
    );

    -- Require approval for equipment (any amount)
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'Equipment Approval',
        'REQUIRE_APPROVAL',
        '{"field": "category", "operator": "eq", "value": "equipment", "message": "Equipment purchases require manager approval."}',
        30
    );

    -- Auto-approve everything else under $1000
    INSERT INTO safety_rules (rule_name, rule_type, rule_config, priority) VALUES (
        'Auto-approve Standard',
        'AUTO_APPROVE',
        '{"field": "amount", "operator": "lt", "value": 1000, "message": "Expenses under $1,000 are auto-approved."}',
        100
    );

    COMMIT;
    </copy>
    ```

---

## Part 2: Tool Functions

### Task 4: Create the Rules Checker

1. Create the function that checks safety rules.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION check_expense_rules(
        p_amount   NUMBER,
        p_category VARCHAR2
    ) RETURN VARCHAR2 AS
    BEGIN
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
                IF v_field = 'amount' THEN
                    IF v_operator = 'gt' AND p_amount > TO_NUMBER(v_value) THEN v_match := TRUE;
                    ELSIF v_operator = 'gte' AND p_amount >= TO_NUMBER(v_value) THEN v_match := TRUE;
                    ELSIF v_operator = 'lt' AND p_amount < TO_NUMBER(v_value) THEN v_match := TRUE;
                    END IF;
                ELSIF v_field = 'category' THEN
                    IF v_operator = 'eq' AND LOWER(p_category) = LOWER(v_value) THEN v_match := TRUE;
                    END IF;
                END IF;
                
                IF v_match THEN
                    RETURN '{"action": "' || rec.rule_type || '", "rule": "' || rec.rule_name || '", "message": "' || v_message || '"}';
                END IF;
            END;
        END LOOP;
        
        RETURN '{"action": "AUTO_APPROVE", "message": "Standard processing."}';
    END;
    /
    </copy>
    ```

2. Test the rules.

    ```sql
    <copy>
    SELECT '$35 supplies:' as test, check_expense_rules(35, 'supplies') as result FROM DUAL
    UNION ALL
    SELECT '$200 meals:', check_expense_rules(200, 'meals') FROM DUAL
    UNION ALL
    SELECT '$1500 training:', check_expense_rules(1500, 'training') FROM DUAL
    UNION ALL
    SELECT '$150 equipment:', check_expense_rules(150, 'equipment') FROM DUAL
    UNION ALL
    SELECT '$7500 travel:', check_expense_rules(7500, 'travel') FROM DUAL;
    </copy>
    ```

### Task 5: Create Expense Submission Tool

1. Create the submit function that respects the rules.

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
        v_rules      VARCHAR2(500);
        v_action     VARCHAR2(20);
        v_status     VARCHAR2(30);
    BEGIN
        -- Check rules first
        v_rules := check_expense_rules(p_amount, p_category);
        v_action := JSON_VALUE(v_rules, '$.action');
        
        -- Handle BLOCK - don't create the expense
        IF v_action = 'BLOCK' THEN
            RETURN '{"error": "BLOCKED", "message": "' || JSON_VALUE(v_rules, '$.message') || '"}';
        END IF;
        
        -- Determine status
        IF v_action = 'AUTO_APPROVE' THEN
            v_status := 'APPROVED';
        ELSE
            v_status := 'NEEDS_APPROVAL';
        END IF;
        
        -- Generate request ID and insert
        v_request_id := 'EXP-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || expense_seq.NEXTVAL;
        
        INSERT INTO expense_requests (request_id, employee_id, amount, category, description, status, approved_by, approved_at)
        VALUES (
            v_request_id, 
            p_employee_id, 
            p_amount, 
            LOWER(p_category), 
            p_description,
            v_status,
            CASE WHEN v_status = 'APPROVED' THEN 'AUTO' ELSE NULL END,
            CASE WHEN v_status = 'APPROVED' THEN SYSTIMESTAMP ELSE NULL END
        );
        
        COMMIT;
        
        RETURN '{"request_id": "' || v_request_id || '", "status": "' || v_status || '", "message": "' || 
               CASE WHEN v_status = 'APPROVED' THEN 'Auto-approved.' ELSE 'Submitted. Awaiting manager approval.' END || '"}';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN '{"error": "' || SQLERRM || '"}';
    END;
    /
    </copy>
    ```

### Task 6: Create Approval Tools

1. Create a function to list expenses needing approval.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION get_pending_approvals RETURN VARCHAR2 AS
        v_result VARCHAR2(4000) := '[';
        v_first  BOOLEAN := TRUE;
    BEGIN
        FOR rec IN (
            SELECT e.request_id, emp.name as employee_name, e.amount, e.category, 
                   e.description, TO_CHAR(e.submitted_at, 'YYYY-MM-DD HH24:MI') as submitted
            FROM expense_requests e
            JOIN employees emp ON e.employee_id = emp.employee_id
            WHERE e.status = 'NEEDS_APPROVAL'
            ORDER BY e.submitted_at
        ) LOOP
            IF NOT v_first THEN
                v_result := v_result || ',';
            END IF;
            v_first := FALSE;
            
            v_result := v_result || '{"request_id": "' || rec.request_id || '", ' ||
                        '"employee": "' || rec.employee_name || '", ' ||
                        '"amount": ' || rec.amount || ', ' ||
                        '"category": "' || rec.category || '", ' ||
                        '"description": "' || NVL(rec.description, 'N/A') || '", ' ||
                        '"submitted": "' || rec.submitted || '"}';
        END LOOP;
        
        v_result := v_result || ']';
        
        IF v_result = '[]' THEN
            RETURN '{"message": "No expenses pending approval."}';
        END IF;
        
        RETURN v_result;
    END;
    /
    </copy>
    ```

2. Create a function to approve an expense.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION approve_expense(
        p_request_id VARCHAR2,
        p_approver   VARCHAR2 DEFAULT 'MANAGER'
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_current_status VARCHAR2(30);
    BEGIN
        SELECT status INTO v_current_status
        FROM expense_requests
        WHERE request_id = p_request_id;
        
        IF v_current_status != 'NEEDS_APPROVAL' THEN
            RETURN '{"error": "Cannot approve. Current status is ' || v_current_status || '."}';
        END IF;
        
        UPDATE expense_requests
        SET status = 'APPROVED',
            approved_by = p_approver,
            approved_at = SYSTIMESTAMP
        WHERE request_id = p_request_id;
        
        COMMIT;
        RETURN '{"request_id": "' || p_request_id || '", "status": "APPROVED", "approved_by": "' || p_approver || '"}';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '{"error": "Expense not found: ' || p_request_id || '"}';
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN '{"error": "' || SQLERRM || '"}';
    END;
    /
    </copy>
    ```

3. Create a function to reject an expense.

    ```sql
    <copy>
    CREATE OR REPLACE FUNCTION reject_expense(
        p_request_id VARCHAR2,
        p_approver   VARCHAR2 DEFAULT 'MANAGER'
    ) RETURN VARCHAR2 AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_current_status VARCHAR2(30);
    BEGIN
        SELECT status INTO v_current_status
        FROM expense_requests
        WHERE request_id = p_request_id;
        
        IF v_current_status != 'NEEDS_APPROVAL' THEN
            RETURN '{"error": "Cannot reject. Current status is ' || v_current_status || '."}';
        END IF;
        
        UPDATE expense_requests
        SET status = 'REJECTED',
            approved_by = p_approver,
            approved_at = SYSTIMESTAMP
        WHERE request_id = p_request_id;
        
        COMMIT;
        RETURN '{"request_id": "' || p_request_id || '", "status": "REJECTED", "rejected_by": "' || p_approver || '"}';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '{"error": "Expense not found: ' || p_request_id || '"}';
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN '{"error": "' || SQLERRM || '"}';
    END;
    /
    </copy>
    ```

---

## Part 3: Create the Agents

### Task 7: Register Tools

1. Register all tools.

    ```sql
    <copy>
    BEGIN
        -- Submission tool (for EXPENSE_AGENT)
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'SUBMIT_EXPENSE_TOOL',
            attributes  => '{"instruction": "Submit an expense request. Parameters: P_EMPLOYEE_ID (e.g. EMP-001, EMP-002, EMP-003), P_AMOUNT (number), P_CATEGORY (travel, meals, supplies, equipment, or training), P_DESCRIPTION (text description of the expense).",
                            "function": "submit_expense"}',
            description => 'Submits an expense request'
        );
        
        -- Pending list tool (for APPROVAL_AGENT)
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'GET_PENDING_TOOL',
            attributes  => '{"instruction": "Get list of expenses waiting for approval. No parameters needed.",
                            "function": "get_pending_approvals"}',
            description => 'Lists expenses needing approval'
        );
        
        -- Approve tool (for APPROVAL_AGENT)
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'APPROVE_EXPENSE_TOOL',
            attributes  => '{"instruction": "Approve an expense request. Parameter: P_REQUEST_ID (e.g. EXP-260108-1001).",
                            "function": "approve_expense"}',
            description => 'Approves an expense'
        );
        
        -- Reject tool (for APPROVAL_AGENT)
        DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
            tool_name   => 'REJECT_EXPENSE_TOOL',
            attributes  => '{"instruction": "Reject an expense request. Parameter: P_REQUEST_ID (e.g. EXP-260108-1001).",
                            "function": "reject_expense"}',
            description => 'Rejects an expense'
        );
    END;
    /
    </copy>
    ```

### Task 8: Create the Expense Agent (Employee Role)

1. Create the expense submission agent and team.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'EXPENSE_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are an expense submission agent for employees. When asked to submit an expense, call SUBMIT_EXPENSE_TOOL with the provided details. Report the result clearly - whether it was auto-approved, needs manager approval, or was blocked."}',
            description => 'Employee expense submission agent'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'EXPENSE_TASK',
            attributes  => '{"instruction": "Process expense submission requests. Call SUBMIT_EXPENSE_TOOL with the employee ID, amount, category, and description. Report the outcome. User request: {query}",
                            "tools": ["SUBMIT_EXPENSE_TOOL"]}',
            description => 'Expense submission task'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'EXPENSE_TEAM',
            attributes  => '{"agents": [{"name": "EXPENSE_AGENT", "task": "EXPENSE_TASK"}],
                            "process": "sequential"}',
            description => 'Employee expense submission team'
        );
    END;
    /
    </copy>
    ```

### Task 9: Create the Approval Agent (Manager Role)

1. Create the manager approval agent and team.

    ```sql
    <copy>
    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
            agent_name  => 'APPROVAL_AGENT',
            attributes  => '{"profile_name": "genai",
                            "role": "You are an expense approval agent for managers. You can list pending expenses, approve them, or reject them. When asked what needs approval, call GET_PENDING_TOOL. When asked to approve, call APPROVE_EXPENSE_TOOL. When asked to reject, call REJECT_EXPENSE_TOOL."}',
            description => 'Manager expense approval agent'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TASK(
            task_name   => 'APPROVAL_TASK',
            attributes  => '{"instruction": "Process expense approval requests. To see pending expenses, call GET_PENDING_TOOL. To approve, call APPROVE_EXPENSE_TOOL with the request ID. To reject, call REJECT_EXPENSE_TOOL with the request ID. User request: {query}",
                            "tools": ["GET_PENDING_TOOL", "APPROVE_EXPENSE_TOOL", "REJECT_EXPENSE_TOOL"]}',
            description => 'Expense approval task'
        );
    END;
    /

    BEGIN
        DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
            team_name   => 'APPROVAL_TEAM',
            attributes  => '{"agents": [{"name": "APPROVAL_AGENT", "task": "APPROVAL_TASK"}],
                            "process": "sequential"}',
            description => 'Manager expense approval team'
        );
    END;
    /
    </copy>
    ```

---

## Part 4: Test the Workflow

### Task 10: Submit Expenses as an Employee

1. Set the expense submission team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('EXPENSE_TEAM');
    </copy>
    ```

2. Submit a small expense (auto-approve).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $35 expense for supplies for employee EMP-002, description office supplies;
    </copy>
    ```

**Expected:** Auto-approved (under $1000, not equipment).

3. Submit a medium expense (auto-approve).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $200 expense for meals for employee EMP-003, description team lunch;
    </copy>
    ```

**Expected:** Auto-approved (under $1000, not equipment).

4. Submit a high-value expense (needs approval).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $1500 expense for training for employee EMP-002, description annual conference registration;
    </copy>
    ```

**Expected:** Needs approval ($1000 or more).

5. Submit an equipment expense (needs approval).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $150 expense for equipment for employee EMP-002, description new keyboard;
    </copy>
    ```

**Expected:** Needs approval (equipment category always requires approval).

6. Try to submit a blocked expense.

    ```sql
    <copy>
    SELECT AI AGENT Submit a $7500 expense for travel for employee EMP-001, description international trip;
    </copy>
    ```

**Expected:** Blocked (over $5000).

7. Verify the expense records.

    ```sql
    <copy>
    SELECT request_id, 
           (SELECT name FROM employees WHERE employee_id = e.employee_id) as employee,
           amount, 
           category, 
           status, 
           NVL(approved_by, '-') as approved_by
    FROM expense_requests e
    ORDER BY submitted_at;
    </copy>
    ```

**Expected Results:**

| Amount | Category | Status | Approved By |
|--------|----------|--------|-------------|
| $35 | supplies | APPROVED | AUTO |
| $200 | meals | APPROVED | AUTO |
| $1500 | training | NEEDS_APPROVAL | - |
| $150 | equipment | NEEDS_APPROVAL | - |

Note: The $7500 expense was blocked and not created.

---

### Task 11: Approve Expenses as a Manager

1. Switch to the approval team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('APPROVAL_TEAM');
    </copy>
    ```

2. Ask what expenses need approval.

    ```sql
    <copy>
    SELECT AI AGENT What expenses need my approval;
    </copy>
    ```

**Expected:** Lists the $1500 training and $150 equipment expenses.

3. Approve the training expense.

    ```sql
    <copy>
    SELECT AI AGENT Approve the training expense;
    </copy>
    ```

4. Reject the equipment expense.

    ```sql
    <copy>
    SELECT AI AGENT Reject the equipment expense;
    </copy>
    ```

5. Verify final status of all expenses.

    ```sql
    <copy>
    SELECT request_id, 
           (SELECT name FROM employees WHERE employee_id = e.employee_id) as employee,
           amount, 
           category, 
           status, 
           NVL(approved_by, '-') as approved_by,
           TO_CHAR(approved_at, 'HH24:MI:SS') as approved_at
    FROM expense_requests e
    ORDER BY submitted_at;
    </copy>
    ```

**Expected Final Results:**

| Amount | Category | Status | Approved By |
|--------|----------|--------|-------------|
| $35 | supplies | APPROVED | AUTO |
| $200 | meals | APPROVED | AUTO |
| $1500 | training | APPROVED | MANAGER |
| $150 | equipment | REJECTED | MANAGER |

---

## Part 5: Audit Trail

### Task 12: Query the Audit Trail

1. See all tool calls.

    ```sql
    <copy>
    SELECT 
        tool_name,
        TO_CHAR(start_date, 'HH24:MI:SS') as called,
        SUBSTR(input, 1, 60) as input_preview,
        SUBSTR(output, 1, 60) as output_preview
    FROM USER_AI_AGENT_TOOL_HISTORY
    ORDER BY start_date DESC
    FETCH FIRST 15 ROWS ONLY;
    </copy>
    ```

2. Audit summary by tool.

    ```sql
    <copy>
    SELECT 
        tool_name,
        COUNT(*) as call_count
    FROM USER_AI_AGENT_TOOL_HISTORY
    GROUP BY tool_name
    ORDER BY call_count DESC;
    </copy>
    ```

---

## Summary

In this capstone lab, you built a complete agent system with:

**Two Agents with Different Roles:**
- EXPENSE_AGENT: Employees submit expenses
- APPROVAL_AGENT: Managers review and decide

**Safety Rules:**
- AUTO_APPROVE: Under $1000 (not equipment)
- REQUIRE_APPROVAL: $1000+ or equipment
- BLOCK: Over $5000

**Clean Workflow:**
1. Employee submits → Auto-approved or queued for approval
2. Manager reviews queue → Approves or rejects
3. Everything logged in audit trail

**Key Takeaways:**
- Tools define what's possible
- Rules define what's allowed
- Different agents for different roles
- Humans retain control over important decisions
- Everything is auditable

## Learn More

* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('EXPENSE_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('APPROVAL_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('EXPENSE_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('APPROVAL_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('EXPENSE_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('APPROVAL_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('SUBMIT_EXPENSE_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_PENDING_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('APPROVE_EXPENSE_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('REJECT_EXPENSE_TOOL', TRUE);
DROP TABLE expense_requests PURGE;
DROP TABLE employees PURGE;
DROP TABLE safety_rules PURGE;
DROP SEQUENCE expense_seq;
DROP FUNCTION submit_expense;
DROP FUNCTION check_expense_rules;
DROP FUNCTION get_pending_approvals;
DROP FUNCTION approve_expense;
DROP FUNCTION reject_expense;
</copy>
```
