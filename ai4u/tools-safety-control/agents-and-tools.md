# Tools, Safety, and Human Control

## Introduction

In this capstone lab, you'll build a complete agent system with tools that act, rules that constrain, and human oversight that keeps people in control.

### The Business Problem

Seer Equity's compliance team has a recurring nightmare: What if someone submits AND approves their own loan? Their current systems don't enforce separation of duties—it's just policy that people are "supposed to follow."

> *"We're one mistake away from a regulatory finding. And we have no idea what our AI assistants are actually doing. When a regulator asks 'why was this loan approved?', nobody can answer."*
>
> Rachel, Compliance Director

The company needs agents that:
- **Enforce role separation** — Loan officers can submit but NOT approve
- **Automate routine decisions** — Low-risk loans shouldn't need human review
- **Require human judgment** — High-value or complex loans need underwriters
- **Log everything** — Complete audit trail for compliance

### What You'll Learn

In this capstone lab, you'll build a two-agent loan underwriting system:

| Agent | Role | Can Do | Cannot Do |
|-------|------|--------|-----------|
| **LOAN_AGENT** | Loan Officers | Submit applications | Approve/Deny |
| **UNDERWRITING_AGENT** | Underwriters | Approve/Deny | Submit applications |

The separation isn't just policy—it's architecture. LOAN_AGENT literally doesn't have approval tools.

You'll also implement risk-based routing:
- **Credit < 550** → BLOCKED (cannot proceed)
- **Personal < $50K** → AUTO_APPROVE
- **$50K-$250K** → Underwriter review required
- **$250K+ or Mortgage** → Senior underwriter required

**What you'll build:** A compliant two-agent loan underwriting system with separation of duties and full audit trail.

Estimated Time: 20 minutes

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

1. **loan_applicants**: Sample applicants who will apply for loans
2. **loan_applications**: Where loan submissions are stored with their status
3. **underwriting_rules**: JSON-configured business rules the agent will follow

Notice the constraints on `loan_applications` — these are your database-level safety net. Even if an agent misbehaves, the database won't accept invalid data.

```sql
<copy>
-- Sequence for application IDs
CREATE SEQUENCE loan_app_seq START WITH 1001;

-- Applicants table
CREATE TABLE loan_applicants (
    applicant_id    VARCHAR2(20) PRIMARY KEY,
    name            VARCHAR2(100) NOT NULL,
    email           VARCHAR2(100) NOT NULL,
    credit_score    NUMBER(3) NOT NULL,
    annual_income   NUMBER(12,2),
    employment_years NUMBER(2)
);

-- Loan applications
CREATE TABLE loan_applications (
    application_id  VARCHAR2(20) PRIMARY KEY,
    applicant_id    VARCHAR2(20) NOT NULL REFERENCES loan_applicants(applicant_id),
    loan_amount     NUMBER(12,2) NOT NULL 
                    CONSTRAINT chk_positive_amount CHECK (loan_amount > 0),
    loan_type       VARCHAR2(50) NOT NULL
                    CONSTRAINT chk_loan_type CHECK (loan_type IN ('personal','auto','mortgage','business')),
    loan_purpose    VARCHAR2(500),
    risk_status     VARCHAR2(30) DEFAULT 'PENDING_REVIEW'
                    CONSTRAINT chk_status CHECK (risk_status IN ('APPROVED','DENIED','PENDING_REVIEW','AUTO_APPROVED')),
    submitted_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
    decided_by      VARCHAR2(100),
    decided_at      TIMESTAMP
);

-- Underwriting rules
CREATE TABLE underwriting_rules (
    rule_id      RAW(16) DEFAULT SYS_GUID() PRIMARY KEY,
    rule_name    VARCHAR2(200) NOT NULL,
    rule_type    VARCHAR2(20) NOT NULL 
                 CONSTRAINT chk_rule_type CHECK (rule_type IN ('BLOCK','REQUIRE_REVIEW','AUTO_APPROVE')),
    rule_config  JSON NOT NULL,
    priority     NUMBER DEFAULT 100,
    is_active    NUMBER(1) DEFAULT 1
);

-- Insert sample applicants with varying credit profiles
INSERT INTO loan_applicants VALUES ('APP-001', 'Alice Johnson', 'alice@email.com', 780, 95000, 8);
INSERT INTO loan_applicants VALUES ('APP-002', 'Bob Smith', 'bob@email.com', 695, 62000, 3);
INSERT INTO loan_applicants VALUES ('APP-003', 'Carol Davis', 'carol@email.com', 520, 45000, 1);
INSERT INTO loan_applicants VALUES ('APP-004', 'David Chen', 'david@email.com', 725, 120000, 12);

COMMIT;
</copy>
```

## Task 3: Define Seer Equity's Underwriting Rules

Now you'll insert the business rules that control what happens to each loan application. These rules are stored as JSON, making them easy to modify without changing code.

The rules are evaluated in priority order (lowest number first):
1. **Block** applications with credit score below 550 — too high risk for automated processing
2. **Require review** for loans $50,000 or more — significant exposure needs human judgment
3. **Require review** for any mortgage — complex product requires underwriter
4. **Require review** for credit scores 550-650 — borderline creditworthiness
5. **Auto-approve** everything else — low-risk personal/auto loans with good credit

```sql
<copy>
-- Block very low credit scores (<550)
INSERT INTO underwriting_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Block High Risk - Low Credit',
    'BLOCK',
    '{"field": "credit_score", "operator": "lt", "value": 550, "message": "Credit score below 550 does not meet Seer Equity minimum requirements. Application cannot be processed."}',
    10
);

-- Require review for large loans (>=$50,000)
INSERT INTO underwriting_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Large Loan Review',
    'REQUIRE_REVIEW',
    '{"field": "loan_amount", "operator": "gte", "value": 50000, "message": "Loans $50,000 and above require underwriter review."}',
    20
);

-- Require review for all mortgages (any amount)
INSERT INTO underwriting_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Mortgage Review',
    'REQUIRE_REVIEW',
    '{"field": "loan_type", "operator": "eq", "value": "mortgage", "message": "All mortgage applications require underwriter review."}',
    30
);

-- Require review for borderline credit (550-650)
INSERT INTO underwriting_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Borderline Credit Review',
    'REQUIRE_REVIEW',
    '{"field": "credit_score", "operator": "between", "low": 550, "high": 650, "message": "Credit scores 550-650 require underwriter review."}',
    40
);

-- Auto-approve everything else (good credit, small loans, non-mortgage)
INSERT INTO underwriting_rules (rule_name, rule_type, rule_config, priority) VALUES (
    'Auto-approve Standard',
    'AUTO_APPROVE',
    '{"field": "loan_amount", "operator": "lt", "value": 50000, "message": "Personal and auto loans under $50,000 with good credit are auto-approved."}',
    100
);

COMMIT;
</copy>
```

## Task 4: Create the Rules Checker Function

This function is the brain of Seer Equity's automated underwriting. It evaluates each application against the rules in priority order and returns the first matching rule.

```sql
<copy>
CREATE OR REPLACE FUNCTION check_underwriting_rules(
    p_loan_amount   NUMBER,
    p_loan_type     VARCHAR2,
    p_credit_score  NUMBER
) RETURN VARCHAR2 AS
BEGIN
    FOR rec IN (
        SELECT rule_name, rule_type, rule_config
        FROM underwriting_rules
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
            IF v_field = 'loan_amount' THEN
                IF v_operator = 'gte' AND p_loan_amount >= TO_NUMBER(v_value) THEN v_match := TRUE;
                ELSIF v_operator = 'lt' AND p_loan_amount < TO_NUMBER(v_value) THEN v_match := TRUE;
                END IF;
            ELSIF v_field = 'loan_type' THEN
                IF v_operator = 'eq' AND LOWER(p_loan_type) = LOWER(v_value) THEN v_match := TRUE;
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
    
    RETURN '{"action": "AUTO_APPROVE", "message": "Application meets all automated approval criteria."}';
END;
/
</copy>
```

## Task 5: Test Seer Equity's Rules Engine

Before building the agents, let's verify the rules work correctly.

| Test | Expected Result | Why |
|------|-----------------|-----|
| $25K personal, 780 credit | AUTO_APPROVE | Good credit, small loan |
| $35K auto, 695 credit | AUTO_APPROVE | Decent credit, under $50K |
| $75K personal, 725 credit | REQUIRE_REVIEW | Over $50K threshold |
| $30K personal, 600 credit | REQUIRE_REVIEW | Borderline credit 550-650 |
| $20K auto, 520 credit | BLOCK | Credit below 550 |

```sql
<copy>
SELECT '$25K personal, 780 credit:' as test, check_underwriting_rules(25000, 'personal', 780) as result FROM DUAL
UNION ALL
SELECT '$35K auto, 695 credit:', check_underwriting_rules(35000, 'auto', 695) FROM DUAL
UNION ALL
SELECT '$75K personal, 725 credit:', check_underwriting_rules(75000, 'personal', 725) FROM DUAL
UNION ALL
SELECT '$30K personal, 600 credit:', check_underwriting_rules(30000, 'personal', 600) FROM DUAL
UNION ALL
SELECT '$20K auto, 520 credit:', check_underwriting_rules(20000, 'auto', 520) FROM DUAL;
</copy>
```

## Task 6: Create the Loan Submission Function

This is the main tool the LOAN_AGENT will use. It looks up the applicant's credit score, checks the underwriting rules, and creates the application with the appropriate status.

```sql
<copy>
CREATE OR REPLACE FUNCTION submit_loan_application(
    p_applicant_id  VARCHAR2,
    p_loan_amount   NUMBER,
    p_loan_type     VARCHAR2,
    p_loan_purpose  VARCHAR2
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_application_id VARCHAR2(20);
    v_credit_score   NUMBER;
    v_rules          VARCHAR2(500);
    v_action         VARCHAR2(20);
    v_status         VARCHAR2(30);
BEGIN
    -- Get applicant's credit score
    BEGIN
        SELECT credit_score INTO v_credit_score
        FROM loan_applicants
        WHERE applicant_id = p_applicant_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '{"error": "Applicant not found: ' || p_applicant_id || '"}';
    END;
    
    -- Check underwriting rules
    v_rules := check_underwriting_rules(p_loan_amount, p_loan_type, v_credit_score);
    v_action := JSON_VALUE(v_rules, '$.action');
    
    -- Handle BLOCK - don't create the application
    IF v_action = 'BLOCK' THEN
        RETURN '{"error": "BLOCKED", "message": "' || JSON_VALUE(v_rules, '$.message') || '"}';
    END IF;
    
    -- Determine status
    IF v_action = 'AUTO_APPROVE' THEN
        v_status := 'AUTO_APPROVED';
    ELSE
        v_status := 'PENDING_REVIEW';
    END IF;
    
    -- Generate application ID and insert
    v_application_id := 'LOAN-' || TO_CHAR(SYSDATE, 'YYMMDD') || '-' || loan_app_seq.NEXTVAL;
    
    INSERT INTO loan_applications (application_id, applicant_id, loan_amount, loan_type, loan_purpose, risk_status, decided_by, decided_at)
    VALUES (
        v_application_id, 
        p_applicant_id, 
        p_loan_amount, 
        LOWER(p_loan_type), 
        p_loan_purpose,
        v_status,
        CASE WHEN v_status = 'AUTO_APPROVED' THEN 'SYSTEM' ELSE NULL END,
        CASE WHEN v_status = 'AUTO_APPROVED' THEN SYSTIMESTAMP ELSE NULL END
    );
    
    COMMIT;
    
    RETURN '{"application_id": "' || v_application_id || '", "status": "' || v_status || '", "credit_score": ' || v_credit_score || ', "message": "' || 
           CASE WHEN v_status = 'AUTO_APPROVED' THEN 'Auto-approved based on credit profile and loan parameters.' ELSE 'Submitted for underwriter review.' END || '"}';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN '{"error": "' || SQLERRM || '"}';
END;
/
</copy>
```

## Task 7: Create the Underwriter's Functions

Underwriters need three capabilities: see pending applications, approve, and deny.

```sql
<copy>
CREATE OR REPLACE FUNCTION get_pending_reviews RETURN VARCHAR2 AS
    v_result VARCHAR2(4000) := '[';
    v_first  BOOLEAN := TRUE;
BEGIN
    FOR rec IN (
        SELECT la.application_id, ap.name as applicant_name, ap.credit_score,
               la.loan_amount, la.loan_type, la.loan_purpose,
               TO_CHAR(la.submitted_at, 'YYYY-MM-DD HH24:MI') as submitted
        FROM loan_applications la
        JOIN loan_applicants ap ON la.applicant_id = ap.applicant_id
        WHERE la.risk_status = 'PENDING_REVIEW'
        ORDER BY la.submitted_at
    ) LOOP
        IF NOT v_first THEN
            v_result := v_result || ',';
        END IF;
        v_first := FALSE;
        
        v_result := v_result || '{"application_id": "' || rec.application_id || '", ' ||
                    '"applicant": "' || rec.applicant_name || '", ' ||
                    '"credit_score": ' || rec.credit_score || ', ' ||
                    '"amount": ' || rec.loan_amount || ', ' ||
                    '"type": "' || rec.loan_type || '", ' ||
                    '"purpose": "' || NVL(rec.loan_purpose, 'N/A') || '", ' ||
                    '"submitted": "' || rec.submitted || '"}';
    END LOOP;
    
    v_result := v_result || ']';
    
    IF v_result = '[]' THEN
        RETURN '{"message": "No loan applications pending review."}';
    END IF;
    
    RETURN v_result;
END;
/

CREATE OR REPLACE FUNCTION approve_loan(
    p_application_id VARCHAR2,
    p_underwriter    VARCHAR2 DEFAULT 'UNDERWRITER'
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_current_status VARCHAR2(30);
BEGIN
    SELECT risk_status INTO v_current_status
    FROM loan_applications
    WHERE application_id = p_application_id;
    
    IF v_current_status != 'PENDING_REVIEW' THEN
        RETURN '{"error": "Cannot approve. Current status is ' || v_current_status || '."}';
    END IF;
    
    UPDATE loan_applications
    SET risk_status = 'APPROVED',
        decided_by = p_underwriter,
        decided_at = SYSTIMESTAMP
    WHERE application_id = p_application_id;
    
    COMMIT;
    RETURN '{"application_id": "' || p_application_id || '", "status": "APPROVED", "approved_by": "' || p_underwriter || '"}';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '{"error": "Application not found: ' || p_application_id || '"}';
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN '{"error": "' || SQLERRM || '"}';
END;
/

CREATE OR REPLACE FUNCTION deny_loan(
    p_application_id VARCHAR2,
    p_underwriter    VARCHAR2 DEFAULT 'UNDERWRITER'
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_current_status VARCHAR2(30);
BEGIN
    SELECT risk_status INTO v_current_status
    FROM loan_applications
    WHERE application_id = p_application_id;
    
    IF v_current_status != 'PENDING_REVIEW' THEN
        RETURN '{"error": "Cannot deny. Current status is ' || v_current_status || '."}';
    END IF;
    
    UPDATE loan_applications
    SET risk_status = 'DENIED',
        decided_by = p_underwriter,
        decided_at = SYSTIMESTAMP
    WHERE application_id = p_application_id;
    
    COMMIT;
    RETURN '{"application_id": "' || p_application_id || '", "status": "DENIED", "denied_by": "' || p_underwriter || '"}';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '{"error": "Application not found: ' || p_application_id || '"}';
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN '{"error": "' || SQLERRM || '"}';
END;
/
</copy>
```

## Task 8: Register the Tools

Now you'll register your PL/SQL functions as tools. Notice that SUBMIT_LOAN_TOOL is for loan officers, while the other three are for underwriters.

```sql
<copy>
BEGIN
    -- Submission tool (for LOAN_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'SUBMIT_LOAN_TOOL',
        attributes  => '{"instruction": "Submit a loan application. Parameters: P_APPLICANT_ID (e.g. APP-001, APP-002, APP-003, APP-004), P_LOAN_AMOUNT (number), P_LOAN_TYPE (personal, auto, mortgage, or business), P_LOAN_PURPOSE (text description of loan purpose).",
                        "function": "submit_loan_application"}',
        description => 'Submits a loan application for processing'
    );
    
    -- Pending list tool (for UNDERWRITING_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'GET_PENDING_TOOL',
        attributes  => '{"instruction": "Get list of loan applications waiting for underwriting review. No parameters needed.",
                        "function": "get_pending_reviews"}',
        description => 'Lists loan applications needing underwriter review'
    );
    
    -- Approve tool (for UNDERWRITING_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'APPROVE_LOAN_TOOL',
        attributes  => '{"instruction": "Approve a loan application. Parameter: P_APPLICATION_ID (e.g. LOAN-260108-1001).",
                        "function": "approve_loan"}',
        description => 'Approves a loan application'
    );
    
    -- Deny tool (for UNDERWRITING_AGENT)
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'DENY_LOAN_TOOL',
        attributes  => '{"instruction": "Deny a loan application. Parameter: P_APPLICATION_ID (e.g. LOAN-260108-1001).",
                        "function": "deny_loan"}',
        description => 'Denies a loan application'
    );
END;
/
</copy>
```

## Task 9: Create the Loan Agent (Loan Officer Role)

The LOAN_AGENT represents a loan officer submitting applications. It only has access to SUBMIT_LOAN_TOOL — it cannot approve or deny anything.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'LOAN_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are a loan submission agent for Seer Equity loan officers. When asked to submit a loan application, call SUBMIT_LOAN_TOOL with the provided details. Report the result clearly - whether it was auto-approved, needs underwriter review, or was blocked."}',
        description => 'Loan officer loan submission agent'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'LOAN_TASK',
        attributes  => '{"instruction": "Process loan application requests. Call SUBMIT_LOAN_TOOL with the applicant ID, loan amount, loan type, and purpose. Report the outcome. User request: {query}",
                        "tools": ["SUBMIT_LOAN_TOOL"]}',
        description => 'Loan submission task'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'LOAN_TEAM',
        attributes  => '{"agents": [{"name": "LOAN_AGENT", "task": "LOAN_TASK"}],
                        "process": "sequential"}',
        description => 'Loan officer submission team'
    );
END;
/
</copy>
```

## Task 10: Create the Underwriting Agent (Underwriter Role)

The UNDERWRITING_AGENT has access to three tools but NOT SUBMIT_LOAN_TOOL. Proper separation of duties.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'UNDERWRITING_AGENT',
        attributes  => '{"profile_name": "genai",
                        "role": "You are an underwriting agent for Seer Equity. You can list pending loan applications, approve them, or deny them. When asked what needs review, call GET_PENDING_TOOL. When asked to approve, call APPROVE_LOAN_TOOL. When asked to deny, call DENY_LOAN_TOOL."}',
        description => 'Underwriter loan review agent'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name   => 'UNDERWRITING_TASK',
        attributes  => '{"instruction": "Process underwriting review requests. To see pending applications, call GET_PENDING_TOOL. To approve, call APPROVE_LOAN_TOOL with the application ID. To deny, call DENY_LOAN_TOOL with the application ID. User request: {query}",
                        "tools": ["GET_PENDING_TOOL", "APPROVE_LOAN_TOOL", "DENY_LOAN_TOOL"]}',
        description => 'Underwriting review task'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name   => 'UNDERWRITING_TEAM',
        attributes  => '{"agents": [{"name": "UNDERWRITING_AGENT", "task": "UNDERWRITING_TASK"}],
                        "process": "sequential"}',
        description => 'Underwriter review team'
    );
END;
/
</copy>
```

## Task 11: Test the Loan Officer Path

Become a loan officer and submit applications.

1. Set the loan team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('LOAN_TEAM');
    </copy>
    ```

2. Submit a small personal loan (auto-approve path).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $25000 personal loan for applicant APP-001, purpose is debt consolidation;
    </copy>
    ```

3. Submit a large loan (underwriter review path).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $75000 personal loan for applicant APP-004, purpose is home renovation;
    </copy>
    ```

4. Submit a mortgage (always requires review).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $250000 mortgage for applicant APP-001, purpose is primary residence purchase;
    </copy>
    ```

5. Try to submit a high-risk application (blocked).

    ```sql
    <copy>
    SELECT AI AGENT Submit a $20000 auto loan for applicant APP-003, purpose is used car purchase;
    </copy>
    ```

## Task 12: Verify the Applications

Check what's in the database.

```sql
<copy>
SELECT la.application_id, 
       ap.name as applicant,
       ap.credit_score,
       TO_CHAR(la.loan_amount, '$999,999') as amount, 
       la.loan_type, 
       la.risk_status, 
       NVL(la.decided_by, '-') as decided_by
FROM loan_applications la
JOIN loan_applicants ap ON la.applicant_id = ap.applicant_id
ORDER BY la.submitted_at;
</copy>
```

## Task 13: Test the Underwriter Path

Switch to the underwriting agent and review applications.

1. Set the underwriting team.

    ```sql
    <copy>
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('UNDERWRITING_TEAM');
    </copy>
    ```

2. Check what needs review.

    ```sql
    <copy>
    SELECT AI AGENT What loan applications need my review;
    </copy>
    ```

3. Approve the applications.

    ```sql
    <copy>
    SELECT AI AGENT Approve the personal loan application;
    </copy>
    ```

    ```sql
    <copy>
    SELECT AI AGENT Approve the mortgage application;
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

In this lab, you built a complete loan underwriting system demonstrating:

**Role-Based Agents:**
- LOAN_AGENT for loan officers (submit only)
- UNDERWRITING_AGENT for underwriters (review and decide)

**Safety Rules:**
- AUTO_APPROVE: Under $50K, good credit, non-mortgage
- REQUIRE_REVIEW: $50K+, mortgages, or borderline credit
- BLOCK: Credit score below 550

**The Human-in-the-Loop:**
- Routine loans are automated
- Significant loans require human judgment
- High-risk applications are stopped entirely

**Audit Trail:**
- Every action is logged
- Full input/output captured
- Explainable and compliant

**Key Insight:** Agents are safe because their boundaries are explicit. The LOAN_AGENT literally cannot approve anything — it doesn't have the tool. This is security through architecture, not just prompts.

## Learn More

* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026

## Cleanup (Optional)

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('LOAN_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('UNDERWRITING_TEAM', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('LOAN_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('UNDERWRITING_TASK', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('LOAN_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('UNDERWRITING_AGENT', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('SUBMIT_LOAN_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('GET_PENDING_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('APPROVE_LOAN_TOOL', TRUE);
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('DENY_LOAN_TOOL', TRUE);
DROP TABLE loan_applications PURGE;
DROP TABLE loan_applicants PURGE;
DROP TABLE underwriting_rules PURGE;
DROP SEQUENCE loan_app_seq;
DROP FUNCTION submit_loan_application;
DROP FUNCTION check_underwriting_rules;
DROP FUNCTION get_pending_reviews;
DROP FUNCTION approve_loan;
DROP FUNCTION deny_loan;
</copy>
```
