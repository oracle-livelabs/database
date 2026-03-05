# Getting Started

## Introduction

Welcome to the Seer Equity Retail Intelligence edition of AI4U. This lab prepares your Autonomous Database tenancy so the remaining labs can execute inventory intake, appraisal routing, provenance logging, and governed memory workflows without interruption. You will import notebooks, configure Select AI profiles, load the retail schema, and verify role-based access for intake and authentication teams.

## Objectives

- Import the Seer Equity Retail notebooks for every lab.
- Configure Select AI profiles that a) surface submission, pricing, and memory tables for inventory specialists and b) expose appraisal, precedent, and audit artifacts for authenticators.
- Load seed data covering submissions, loyalty tiers, pricing policies, routing logs, and memory stores.
- Validate user accounts, wallets, and privileges for `INVENTORY_AGENT_USER` and `AUTHENTICATION_AGENT_USER`.
- Smoke-test routing and memory packages so later labs focus on the scenario, not setup.

## Task 1: Import the Retail Notebooks

Each lab has a companion Oracle Machine Learning notebook under the `industries/retail/notebooks` directory in the AI4U repository.

1. Open Oracle Machine Learning from your Autonomous Database console.
2. Click **Notebooks**, then **Import**.
3. Choose **Git** and paste the retail notebooks URL:

    ```text
    <copy>
    https://github.com/davidastart/database/tree/main/ai4u/industries/retail/notebooks
    </copy>
    ```

4. Import `lab1-item-agent.json` through `lab10-governance.json`. These notebooks mirror the markdown instructions and contain all code cells.

## Task 2: Confirm Wallets and Credentials

Separation of duties starts with database accounts.

```sql
<copy>
SELECT username, account_status
  FROM dba_users
 WHERE username IN ('INVENTORY_AGENT_USER', 'AUTHENTICATION_AGENT_USER');
</copy>
```

- Unlock the accounts if necessary with provided lab credentials.
- Download and configure the wallet if your tenancy requires it so notebooks can authenticate with distinct users.

```sql
<copy>
ALTER USER inventory_agent_user IDENTIFIED BY "<provided_password>" ACCOUNT UNLOCK;
ALTER USER authentication_agent_user IDENTIFIED BY "<provided_password>" ACCOUNT UNLOCK;
</copy>
```

## Task 3: Load the Retail Schema

Run `setup-retail-schema.ipynb`. It creates the core tables for every lab:

- `ITEM_SUBMISSIONS`, `ITEM_REQUESTS`, `ITEM_WORKFLOW_LOG` – intake to decision workflow
- `SAMPLE_ITEMS`, `DEMO_CUSTOMERS`, `DEMO_COLLECTIONS` – lightweight datasets for early labs
- `PRICING_POLICIES`, `BS_CUSTOMERS`, `LOYALTY_HISTORY` – enterprise data for policy-cited responses
- `AGENT_MEMORY`, `DECISION_MEMORY`, `REFERENCE_KNOWLEDGE` – memory layers for Labs 5–9
- `AUDIT_LOG`, `ROLE_ASSIGNMENTS`, `TOOL_REGISTRY` – governance artifacts for Lab 10

Verify the tables after execution:

```sql
<copy>
SELECT table_name
  FROM user_tables
 WHERE table_name IN ('ITEM_SUBMISSIONS', 'ITEM_REQUESTS', 'ITEM_WORKFLOW_LOG',
                      'PRICING_POLICIES', 'BS_CUSTOMERS', 'LOYALTY_HISTORY',
                      'AGENT_MEMORY', 'DECISION_MEMORY', 'REFERENCE_KNOWLEDGE',
                      'AUDIT_LOG')
 ORDER BY table_name;
</copy>
```

## Task 4: Configure Select AI Profiles

Two profiles keep tools scoped to their duties:

- `inventory_profile` – grants read/write to submission tables, pricing policies, and fact memories
- `authentication_profile` – exposes routing functions, decision memories, and audit logging

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name => 'inventory_profile',
        attribute    => 'object_list',
        value        => json_array(
            json_object('schema_name' VALUE user, 'object_name' VALUE 'ITEM_SUBMISSIONS'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'PRICING_POLICIES'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'AGENT_MEMORY'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'LOYALTY_HISTORY')
        ));

    DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name => 'authentication_profile',
        attribute    => 'object_list',
        value        => json_array(
            json_object('schema_name' VALUE user, 'object_name' VALUE 'ITEM_REQUESTS'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'ITEM_WORKFLOW_LOG'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'DECISION_MEMORY'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'REFERENCE_KNOWLEDGE'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'AUDIT_LOG')
        ));
END;
/
</copy>
```

## Task 5: Validate Routing Packages

Seer Equity retail routing mirrors the finance baseline’s complexity: auto-list, standard appraisal, expert appraisal, and blocked.

```sql
<copy>
DECLARE
    v_status VARCHAR2(30);
BEGIN
    v_status := retail_routing.evaluate_item(
        p_submitter        => 'Test Collector',
        p_item_type        => 'sports_card',
        p_declared_value   => 450,
        p_condition_grade  => 8.1,
        p_rarity_code      => 'COMMON');
    DBMS_OUTPUT.PUT_LINE('Routing result: ' || v_status);
END;
/
</copy>
```

Expected outputs to confirm parity:
- `AUTO_LIST` for low-value, high-condition common items
- `STANDARD_APPRAISAL` for mid-tier value
- `EXPERT_APPRAISAL` for rare or high-value assets
- `BLOCKED` when authenticity or policy checks fail

## Task 6: Seed Memory Content

Insert baseline facts so Labs 5–7 can demonstrate recall.

```sql
<copy>
INSERT INTO agent_memory (memory_id, agent_id, memory_type, content)
VALUES (
    sys_guid(),
    'INVENTORY_AGENT',
    'FACT',
    json_object(
        'fact'      VALUE 'Alex Martinez has a 20% loyalty discount and prefers email updates',
        'about'     VALUE 'Alex Martinez',
        'category'  VALUE 'loyalty_preference',
        'effective' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD')
    ));

COMMIT;
</copy>
```

## Task 7: Verify Audit Permissions

Ensure authentication users can append but not alter audit logs.

```sql
<copy>
GRANT INSERT ON audit_log TO authentication_agent_user;
REVOKE UPDATE, DELETE ON audit_log FROM authentication_agent_user;
</copy>
```

Attempting to update should raise `ORA-01031: insufficient privileges`, confirming separation of duties.

## Next Steps

Proceed to **Lab 1 – What Is an AI Agent?** to build the inventory lookup agent now that your tenancy mirrors Seer Equity Retail’s operational blueprint.

## Workshop Plan (Generated)
- Emphasize Seer Equity Retail tenancy setup, including inventory vs authentication database users and profile scoping.
- Ensure notebook import paths, schema loaders, and validation steps reference retail tables and routing packages.
- Highlight memory seeding for Alex Martinez loyalty perks and governance grants for audit-safe operations.
- Document checkpoints that confirm three-tier routing thresholds remain intact after data loads.
