# Tools, Safety, and Human Control

## Introduction

In this capstone lab, you'll build a complete agent system with tools that act, rules that constrain, and human oversight that keeps people in control.

### The Business Problem

Big Star Collectibles' compliance team has a recurring nightmare: What if someone submits AND approves their own item? Their current systems don't enforce separation of duties - it's just policy that people are "supposed to follow."

> *"We're one mistake away from a regulatory finding. And we have no idea what our AI assistants are actually doing. When a regulator asks 'why was this item approved?', nobody can answer."*
>
> Rachel, Compliance Director

The company needs agents that:
- **Enforce role separation**  -  Inventory specialists can submit but NOT approve
- **Automate routine decisions**  -  Low-risk items shouldn't need human review
- **Require human judgment**  -  High-value or complex items need appraisers
- **Log everything**  -  Complete audit trail for compliance

### What You'll Learn

In this capstone lab, you'll build a two-agent item appraisal system:

| Agent | Role | Can Do | Cannot Do |
|-------|------|--------|-----------|
| **INVENTORY_AGENT** | Inventory Specialists | Submit submissions | Approve/Deny |
| **APPRAISAL_AGENT** | Appraisers | Approve/Deny | Submit submissions |

The separation isn't just policy - it's architecture. INVENTORY_AGENT literally doesn't have approval tools.

You'll also implement risk-based routing:
- **Credit < 550** → BLOCKED (cannot proceed)
- **Personal < $50K** → AUTO_APPROVE
- **$50K-$250K** → Appraiser review required
- **$250K+ or rare collectible** → Senior appraiser required

**What you'll build:** A compliant two-agent item appraisal system with separation of duties and full audit trail.

Estimated Time: 20 minutes

### Story Sync
**Story Sync:** Chapters 3.3 & 4.2 – see the corresponding narrative beat for context.

### Objectives

* Create PL/SQL functions as agent tools
* Build a safety rules system with JSON configuration
* Create separate agents for different roles
* See how agents respect rules and route work appropriately
* Query the audit trail to see all actions

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
    https://github.com/davidastart/database/blob/main/ai4u/tools-safety-control/lab10-tools-safety-control.json
    </copy>
    ```

5. Click **Ok**.

You should now be on the screen with the notebook imported. This workshop will have all of the screenshots and detailed information however the notebook will have the commands and basic instructions for completing the lab.

## Task 2: Create the Database Tables

First, you'll create three tables:

1. **item_collectors**: Sample collectors who will apply for items
2. **item_submissions**: Where item submissions are stored with their status
3. **appraisal_rules**: JSON-configured business rules the agent will follow

Notice the constraints on `item_submissions`  -  these are your database-level safety net. Even if an agent misbehaves, the database won't accept invalid data.

```sql
<copy>
-- Sequence for submission IDs
CREATE SEQUENCE item_app_seq START WITH 1001;

-- Collectors table
CREATE TABLE item_collectors (
    collector_id    VARCHAR2(20) PRIMARY KEY,
    name            VARCHAR2(100) NOT NULL,
    email           VARCHAR2(100) NOT NULL,
    credit_score    NUMBER(3) NOT NULL,
    annual_income   NUMBER(12,2),
    employment_years NUMBER(2)
);

-- Item submissions
CREATE TABLE item_submissions (
    submission_id  VARCHAR2(20) PRIMARY KEY,
    collector_id    VARCHAR2(20) NOT NULL REFERENCES item_collectors(collector_id),
    declared_value     NUMBER(12,2) NOT NULL 
                    CONSTRAINT chk_positive_amount CHECK (declared_value > 0),
    item_type       VARCHAR2(50) NOT NULL
                    CONSTRAINT chk_item_type CHECK (item_type IN ('personal','auto','authenticating','business')),
    item_purpose    VARCHAR2(500),
    risk_status     VARCHAR2(30) DEFAULT 'PENDING_REVIEW'
                    CONSTRAINT chk_status CHECK (risk_status IN ('APPROVED','DENIED','PENDING_REVIEW','AUTO_APPROVED')),
    submitted_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
    decided_by      VARCHAR2(100),
    decided_at      TIMESTAMP
);

-- Appraisal rules
CREATE TABLE appraisal_rules (
    rule_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    rule_name    VARCHAR2(200) NOT NULL,
    rule_type    VARCHAR2(20) NOT NULL 
                 CONSTRAINT chk_rule_type CHECK (rule_type IN ('BLOCK','REQUIRE_REVIEW','AUTO_APPROVE')),
    rule_config  JSON NOT NULL,
    priority     NUMBER DEFAULT 100,
    is_active    NUMBER(1) DEFAULT 1
);

-- Insert sample collectors with varying credit profiles
INSERT INTO item_collectors VALUES ('APP-001', 'Alice Johnson', 'alice@email.com', 780, 95000, 8);
INSERT INTO item_collectors VALUES ('APP-002', 'Bob Smith', 'bob@email.com', 695, 62000, 3);
INSERT INTO item_collectors VALUES ('APP-003', 'Carol Davis', 'carol@email.com', 520, 45000, 1);
INSERT INTO item_collectors VALUES ('APP-004', 'David Chen', 'david@email.com', 725, 120000, 12);

COMMIT;
</copy>
```

## Task 3: Define Big Star Collectibles' Appraisal Rules

Now you'll insert the business rules that control what happens to each item submission. These rules are stored as JSON, making them easy to modify without changing code.

The rules are evaluated in priority order (lowest number first):
1. **Block** submissions with condition grade below 550  -  too high risk for automated processing
2. **Require review** for items $50,000 or more  -  significant exposure needs human judgment
3. **Require review** for any authenticating  -  complex product requires appraiser
4. **Require review** for condition grades 550-650  -  borderline creditworthiness
5. **Auto-approve** everything else  -  low-risk personal/auto items with good credit

```sql
<copy>
-- Block very low condition grades (<550)
INSERT INTO appraisal_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Block High Risk - Low Credit',
    'BLOCK',
    '{"field": "credit_score", "operator": "lt", "value": 550, "message": "Condition grade below 550 does not meet Big Star Collectibles minimum requirements. Submission cannot be processed."}',
    10
);

-- Require review for large items (>=$50,000)
INSERT INTO appraisal_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Large Item Review',
    'REQUIRE_REVIEW',
    '{"field": "declared_value", "operator": "gte", "value": 50000, "message": "Items $50,000 and above require appraiser review."}',
    20
);

-- Require review for all authenticatings (any amount)
INSERT INTO appraisal_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'rare collectible Review',
    'REQUIRE_REVIEW',
    '{"field": "item_type", "operator": "eq", "value": "authenticating", "message": "All authenticating submissions require appraiser review."}',
    30
);

-- Require review for borderline credit (550-650)
INSERT INTO appraisal_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Borderline Credit Review',
    'REQUIRE_REVIEW',
    '{"field": "credit_score", "operator": "between", "low": 550, "high": 650, "message": "Condition grades 550-650 require appraiser review."}',
    40
);

-- Auto-approve everything else (good credit, small items, non-authenticating)
INSERT INTO appraisal_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Auto-approve Standard',
    'AUTO_APPROVE',
    '{"field": "declared_value", "operator": "lt", "value": 50000, "message": "Personal and auto items under $50,000 with good credit are auto-approved."}',
    100
);

COMMIT;
</copy>
```

## Task 4: Create the Rules Checker Function

This function is the brain of Big Star Collectibles' automated appraisal. It evaluates each submission against the rules in priority order and returns the first matching rule.

```sql
<copy>
CREATE OR REPLACE FUNCTION check_appraisal_rules(
    p_declared_value   NUMBER,
    p_item_type     VARCHAR2,
    p_credit_score  NUMBER
) RETURN VARCHAR2 AS
BEGIN
    FOR rec IN (
        SELECT rule_name, rule_type, rule_config
        FROM appraisal_rules
        WHERE is_active = 1
        ORDER BY priority
    ) LOOP
        DECLARE
            v_field    VARCHAR2(50) := JSON_VALUE(rec.rule_config, '$.field');
            v_operator VARCHAR2(10) := JSON_VALUE(rec.rule_config, '$.operator');
            v_value    VARCHAR2(100) := JSON_VALUE(rec.rule_config, '$.value');
            v_low      VARCHAR2(100) := JSON_VALUE(rec.rule_config, '$.low');
            v_high     VARCHAR2(100) := JSON_VALUE(rec.rule_config, '$.high');
            v_message  VARCHAR2(500) := JSON_VALUE(rec.rule_config, '$.message');
            v_match    BOOLEAN := FALSE;
        BEGIN
            IF v_field = 'declared_value' THEN
                IF v_operator = 'gte' AND p_declared_value >= TO_NUMBER(v_value) THEN v_match := TRUE;
                ELSIF v_operator = 'lt' AND p_declared_value < TO_NUMBER(v_value) THEN v_match := TRUE;
                END IF;
            ELSIF v_field = 'item_type' THEN
                IF v_operator = 'eq' AND LOWER(p_item_type) = LOWER(v_value) THEN v_match := TRUE;
                END IF;
            ELSIF v_field = 'credit_score' THEN
                IF v_operator = 'lt' AND p_credit_score < TO_NUMBER(v_value) THEN v_match := TRUE;
                ELSIF v_operator = 'between' AND p_credit_score >= TO_NUMBER(v_low) AND p_credit_score <= TO_NUMBER(v_high) THEN v_match := TRUE;
                END IF;
            END IF;
            
            IF v_match THEN
                RETURN '{"action": "' || rec.rule_type || '", "rule": "' || rec.rule_name || '", "message": "' || v_message || '"}';
            END IF;
        END;
    END LOOP;
    
    RETURN '{"action": "AUTO_APPROVE", "message": "Submission meets all automated approval criteria."}';
END;
/
</copy>
```

## Task 5: Test Big Star Collectibles' Rules Engine

Before building the agents, let's verify the rules work correctly.

| Test | Expected Result | Why |
|------|-----------------|-----|
| $25K personal, 780 credit | AUTO_APPROVE | Good credit, small item |
| $35K auto, 695 credit | AUTO_APPROVE | Decent credit, under $50K |
| $75K personal, 725 credit | REQUIRE_REVIEW | Over $50K threshold |
| $30K personal, 600 credit | REQUIRE_REVIEW | Borderline credit 550-650 |
| $20K auto, 520 credit | BLOCK | Credit below 550 |

```sql
<copy>
SELECT '$25K personal, 780 credit:' as test, check_appraisal_rules(25000, 'personal', 780) as result FROM DUAL
UNION ALL
SELECT '$35K auto, 695 credit:', check_appraisal_rules(35000, 'auto', 695) FROM DUAL
UNION ALL
SELECT '$75K personal, 725 credit:', check_appraisal_rules(75000, 'personal', 725) FROM DUAL
UNION ALL
SELECT '$30K personal, 600 credit:', check_appraisal_rules(30000, 'personal', 600) FROM DUAL
UNION ALL
SELECT '$20K auto, 520 credit:', check_appraisal_rules(20000, 'auto', 520) FROM DUAL;
</copy>
```

## Task 6: Create the Item Submission Function

This is the main tool the INVENTORY_AGENT will use. It looks up the collector's condition grade, checks the appraisal rules, and creates the submission with the appropriate status.

```sql
<copy>
CREATE OR REPLACE FUNCTION submit_item_submission(
    p_collector_id  VARCHAR2,
    p_declared_value   NUMBER,
    p_item_type     VARCHAR2,
    p_item_purpose  VARCHAR2
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_submission_id VARCHAR2(20);
    v_credit_score   NUMBER;
    v_rules          VARCHAR2(500);
    v_action         VARCHAR2(20);
    v_status         VARCHAR2(30);
BEGIN
    -- Get collector's condition grade
    BEGIN
        SELECT credit_score INTO v_credit_score
        FROM item_collectors
        WHERE collector_id = p_collector_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '{"error": "Collector not found: ' || p_collector_id || '"}';
    END;
    
    -- Check appraisal rules
    v_rules := check_appraisal_rules(p_declared_value, p_item_type, v_credit_score);
    v_action := JSON_VALUE(v_rules, '$.action');
    
    -- Handle BLOCK - don't create the submission
    IF v_action = 'BLOCK' THEN
        RETURN '{"error": "BLOCKED", "message": "' || JSON_VALUE(v_rules, '$.message') || '"}';
    END IF;
    
    -- Determine status
    IF v_action = 'AUTO_APPROVE' THEN
        v_status := 'AUTO_APPROVED';
    ELSE
        v_status := 'PENDING_REVIEW';
    END IF;
    
    -- Generate submission ID and insert
    v_submission_id := 'ITEM-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || item_app_seq.NEXTVAL;
    
    INSERT INTO item_submissions (submission_id, collector_id, declared_value, item_type, item_purpose, risk_status, decided_by, decided_at)
    VALUES (
        v_submission_id, 
        p_collector_id, 
        p_declared_value, 
        LOWER(p_item_type), 
        p_item_purpose,
        v_status,
        CASE WHEN v_status = 'AUTO_APPROVED' THEN 'SYSTEM' ELSE NULL END,
        CASE WHEN v_status = 'AUTO_APPROVED' THEN SYSTIMESTAMP ELSE NULL END
    );
    
    COMMIT;
    
    RETURN '{"submission_id": "' || v_submission_id || '", "status": "' || v_status || '", "credit_score": ' || v_credit_score || ', "message": "' || 
           CASE WHEN v_status = 'AUTO_APPROVED' THEN 'Auto-approved based on credit profile and item parameters.' ELSE 'Submitted for appraiser review.' END || '"}';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN '{"error": "' || SQLERRM || '"}';
END;
/
</copy>
```

## Task 7: Create the Appraiser's Functions

Appraisers need three capabilities: see pending submissions, approve, and deny.

```sql
<copy>
CREATE OR REPLACE FUNCTION get_pending_reviews RETURN VARCHAR2 AS
    v_result VARCHAR2(4000) := '[';
    v_first  BOOLEAN := TRUE;
BEGIN
    FOR rec IN (
        SELECT la.submission_id, ap.name as collector_name, ap.credit_score,
               la.declared_value, la.item_type, la.item_purpose,
               TO_CHAR(la.submitted_at, 'YYYY-MM-DD HH24:MI') as submitted
        FROM item_submissions la
        JOIN item_collectors ap ON la.collector_id = ap.collector_id
        WHERE la.risk_status = 'PENDING_REVIEW'
        ORDER BY la.submitted_at
    ) LOOP
        IF NOT v_first THEN
            v_result := v_result || ',';
        END IF;
        v_first := FALSE;
        
        v_result := v_result || '{"submission_id": "' || rec.submission_id || '", ' ||
                    '"collector": "' || rec.collector_name || '", ' ||
                    '"credit_score": ' || rec.credit_score || ', ' ||
                    '"amount": ' || rec.declared_value || ', ' ||
                    '"type": "' || rec.item_type || '", ' ||
                    '"purpose": "' || NVL(rec.item_purpose, 'N/A') || '", ' ||
                    '"submitted": "' || rec.submitted || '"}';
    END LOOP;
    
    v_result := v_result || ']';
    
    IF v_result = '[]' THEN
        RETURN '{"message": "No item submissions pending review."}';
    END IF;
    
    RETURN v_result;
END;
/

CREATE OR REPLACE FUNCTION approve_item(
    p_submission_id VARCHAR2,
    p_appraiser    VARCHAR2 DEFAULT 'APPRAISER'
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_current_status VARCHAR2(30);
BEGIN
    SELECT risk_status INTO v_current_status
    FROM item_submissions
    WHERE submission_id = p_submission_id;
    
    IF v_current_status != 'PENDING_REVIEW' THEN
        RETURN '{"error": "Cannot approve. Current status is ' || v_current_status || '."}';
    END IF;
    
    UPDATE item_submissions
    SET risk_status = 'APPROVED',
        decided_by = p_appraiser,
        decided_at = SYSTIMESTAMP
    WHERE submission_id = p_submission_id;
    
    COMMIT;
    RETURN '{"submission_id": "' || p_submission_id || '", "status": "APPROVED", "approved_by": "' || p_appraiser || '"}';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '{"error": "Submission not found: ' || p_submission_id || '"}';
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN '{"error": "' || SQLERRM || '"}';
END;
/

CREATE OR REPLACE FUNCTION deny_item(
    p_submission_id VARCHAR2,
    p_appraiser    VARCHAR2 DEFAULT 'APPRAISER'
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_current_status VARCHAR2(30);
BEGIN
    SELECT risk_status INTO v_current_status
    FROM item_submissions
    WHERE submission_id = p_submission_id;
    
    IF v_current_status != 'PENDING_REVIEW' THEN
        RETURN '{"error": "Cannot deny. Current status is ' || v_current_status || '."}';
    END IF;
    
    UPDATE item_submissions
    SET risk_status = 'DENIED',
        decided_by = p_appraiser,
        decided_at = SYSTIMESTAMP
    WHERE submission_id = p_submission_id;
    
    COMMIT;
    RETURN '{"submission_id": "' || p_submission_id || '", "status": "DENIED", "denied_by": "' || p_appraiser || '"}';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '{"error": "Submission not found: ' || p_submission_id || '"}';
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN '{"error": "' || SQLERRM || '"}';
END;
/
</copy>
```

## Task 8: Register the Tools

Now you'll register your PL/SQL functions as tools. Notice that SUBMIT_ITEM_TOOL is for inventory specialists, while the other three are for appraisers.

```sql
<copy>
BEGIN
    -- Submission tool (for INVENTORY_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'SUBMIT_ITEM_TOOL',
        attributes  => '{"instruction": "Submit a item submission. Parameters: P_COLLECTOR_ID (e.g. APP-001, APP-002, APP-003, APP-004), P_DECLARED_VALUE (number), P_ITEM_TYPE (personal, auto, authenticating, or business), P_ITEM_PURPOSE (text description of item purpose).",
                        "function": "submit_item_submission"}',
        description => 'Submits a item submission for processing'
    );
    
    -- Pending list tool (for APPRAISAL_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'GET_PENDING_TOOL',
        attributes  => '{"instruction": "Get list of item submissions waiting for appraisal review. No parameters needed.",
                        "function": "get_pending_reviews"}',
        description => 'Lists item submissions needing appraiser review'
    );
    
    -- Approve tool (for APPRAISAL_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'APPROVE_ITEM_TOOL',
        attributes  => '{"instruction": "Approve a item submission. Parameter: P_SUBMISSION_ID (e.g. ITEM-260108-1001).",
                        "function": "approve_item"}',
        description => 'Approves a item submission'
    );
    
    -- Deny tool (for APPRAISAL_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'DENY_ITEM_TOOL',
        attributes  => '{"instruction": "Deny a item submission. Parameter: P_SUBMISSION_ID (e.g. ITEM-260108-1001).",
                        "function": "deny_item"}',
        description => 'Denies a item submission'
    );
END;
/
</copy>
```

## Task 9: Create the Inventory Agent (Inventory Specialist Role)

The INVENTORY_AGENT represents a inventory specialist submitting submissions. It only has access to SUBMIT_ITEM_TOOL  -  it cannot approve or deny anything.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'INVENTORY_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are a item submission agent for Big Star Collectibles inventory specialists. When asked to submit a item submission, call SUBMIT_ITEM_TOOL with the provided details. Report the result clearly - whether it was auto-approved, needs appraiser review, or was blocked."}',
        description => 'Inventory specialist item submission agent'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'ITEM_TASK',
        attributes  => '{"instruction": "Process item submission requests. Call SUBMIT_ITEM_TOOL with the collector ID, declared value, item type, and purpose. Report the outcome. User request: {query}",
                        "tools": ["SUBMIT_ITEM_TOOL"]}',
        description => 'Item submission task'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'ITEM_TEAM',
        attributes  => '{"agents": [{"name": "INVENTORY_AGENT", "task": "ITEM_TASK"}],
                        "process": "sequential"}',
        description => 'Inventory specialist submission team'
    );
END;
/
</copy>
```

## Task 10: Create the Appraisal Agent (Appraiser Role)

The `APPRAISAL_AGENT` has access to three tools but **not** `SUBMIT_ITEM_TOOL`. Proper separation of duties.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'APPRAISAL_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are an appraisal agent for Big Star Collectibles. You can list pending item submissions, approve them, or deny them. When asked what needs review, call GET_PENDING_TOOL. When asked to approve, call APPROVE_ITEM_TOOL. When asked to deny, call DENY_ITEM_TOOL."}',
        description => 'Appraiser item review agent'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'APPRAISAL_TASK',
        attributes  => '{"instruction": "Process appraisal review requests. To see pending submissions, call GET_PENDING_TOOL. To approve, call APPROVE_ITEM_TOOL with the submission ID. To deny, call DENY_ITEM_TOOL with the submission ID. User request: {query}",
                        "tools": ["GET_PENDING_TOOL", "APPROVE_ITEM_TOOL", "DENY_ITEM_TOOL"]}',
        description => 'Appraisal review task'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'APPRAISAL_TEAM',
        attributes  => '{"agents": [{"name": "APPRAISAL_AGENT", "task": "APPRAISAL_TASK"}],
                        "process": "sequential"}',
        description => 'Appraiser review team'
    );
END;
/
</copy>
```

## Task 11: Test the Inventory Specialist Path

Become a inventory specialist and submit submissions.

1. Set the inventory team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('ITEM_TEAM');
    </copy>
    ```

2. Submit a small personal item (auto-approve path).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $25000 personal item for collector APP-001, purpose is debt consolidation;
    </copy>
    ```

3. Submit a large item (appraiser review path).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $75000 personal item for collector APP-004, purpose is home renovation;
    </copy>
    ```

4. Submit a authenticating (always requires review).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $250000 authenticating for collector APP-001, purpose is primary residence purchase;
    </copy>
    ```

5. Try to submit a high-risk submission (blocked).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $20000 auto item for collector APP-003, purpose is used car purchase;
    </copy>
    ```

## Task 12: Verify the Submissions

Check what's in the database.

```sql
<copy>
SELECT la.submission_id, 
       ap.name as collector,
       ap.credit_score,
       TO_CHAR(la.declared_value, '$999,999') as amount, 
       la.item_type, 
       la.risk_status, 
       NVL(la.decided_by, '-') as decided_by
FROM item_submissions la
JOIN item_collectors ap ON la.collector_id = ap.collector_id
ORDER BY la.submitted_at;
</copy>
```

## Task 13: Test the Appraiser Path

Switch to the appraisal agent and review submissions.

1. Set the appraisal team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('APPRAISAL_TEAM');
    </copy>
    ```

2. Check what needs review.

    ```sql
    <copy>
    SELECT AI AGENT What item submissions need my review;
    </copy>
    ```

3. Approve the submissions.

    ```sql
    <copy>
    SELECT AI AGENT Approve the personal item submission;
    </copy>
    ```

    ```sql
    <copy>
    SELECT AI AGENT Approve the authenticating submission;
    </copy>
    ```

## Task 14: Review the Audit Trail

Every tool call is logged. This is crucial for regulatory compliance.

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

## Summary

In this lab, you built a complete item appraisal system demonstrating:

**Role-Based Agents:**
- INVENTORY_AGENT for inventory specialists (submit only)
- APPRAISAL_AGENT for appraisers (review and decide)

**Safety Rules:**
- AUTO_APPROVE: Under $50K, good credit, non-authenticating
- REQUIRE_REVIEW: $50K+, authenticatings, or borderline credit
- BLOCK: Condition grade below 550

**The Human-in-the-Loop:**
- Routine items are automated
- Significant items require human judgment
- High-risk submissions are stopped entirely

**Audit Trail:**
- Every action is logged
- Full input/output captured
- Explainable and compliant

**Key Insight:** Agents are safe because their boundaries are explicit. The INVENTORY_AGENT literally cannot approve anything  -  it doesn't have the tool. This is security through architecture, not just prompts.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - Kay Malcolm, February 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('ITEM_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('APPRAISAL_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('ITEM_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('APPRAISAL_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('INVENTORY_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('APPRAISAL_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('SUBMIT_ITEM_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_PENDING_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('APPROVE_ITEM_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('DENY_ITEM_TOOL', TRUE);
DROP TABLE item_submissions PURGE;
DROP TABLE item_collectors PURGE;
DROP TABLE appraisal_rules PURGE;
DROP SEQUENCE item_app_seq;
DROP FUNCTION submit_item_submission;
DROP FUNCTION check_appraisal_rules;
DROP FUNCTION get_pending_reviews;
DROP FUNCTION approve_item;
DROP FUNCTION deny_item;
</copy>
```
