# What Is an AI Agent, Really?

## Introduction

Retail teams do not need another chatbot that narrates click paths; they need automation that acts. In this lab you will build Seer Equity’s first inventory lookup agent. Instead of explaining how to check a submission, it will query `ITEM_SUBMISSIONS` and answer Alex Martinez’s status question in seconds.

### The Business Problem

Inventory specialists handle hundreds of calls every week:

> *“My rookie card was submitted last week. What’s the status of ITEM-302?”*
>
> Alex Martinez, Platinum Collector

Legacy chatbots reply with instructions: “Log in. Click Submissions. Filter for ITEM-302…” Collectors hang up. Specialists duplicate work. The retail division needs an agent that reads the actual database and responds with facts.

### What You Will Learn

You will create the foundational agent components: tool, agent, task, and team. By the end, `INVENTORY_AGENT` will retrieve submission status using approved tools.

**What you will build:** A submission lookup agent that reads the `ITEM_SUBMISSIONS` table through a governed SQL tool.

**Estimated Time:** 10 minutes

### Objectives

- Create `ITEM_SUBMISSIONS` with realistic retail attributes (condition, declared value, rarity).
- Populate sample submissions for VIP collectors and standard consignments.
- Register the table with `inventory_profile` so Select AI can access it.
- Build the `ITEM_LOOKUP` SQL tool and `INVENTORY_AGENT` that responds with actionable status summaries.

### Prerequisites

Complete the **Getting Started** lab to import notebooks, configure profiles, and load the retail schema.

## Task 1: Import the Lab Notebook

Use `lab1-item-agent.json` to run all commands from Oracle Machine Learning.

1. Open the notebook in Oracle Machine Learning.
2. Execute cells sequentially; screenshots in this markdown illustrate each step.

## Task 2: Create the Item Submissions Table

```sql
<copy>
CREATE TABLE item_submissions (
    submission_id      VARCHAR2(20)  PRIMARY KEY,
    submitter_name     VARCHAR2(100),
    collector_tier     VARCHAR2(20),
    item_type          VARCHAR2(40),
    condition_grade    NUMBER(3,1),
    declared_value     NUMBER(12,2),
    rarity_code        VARCHAR2(20),
    current_status     VARCHAR2(30),
    last_update_ts     DATE,
    loyalty_discount   NUMBER(5,2)
);
</copy>
```

Add schema comments so Select AI understands the retail vocabulary.

```sql
<copy>
COMMENT ON TABLE item_submissions IS 'Seer Equity retail submissions awaiting authentication, appraisal, or listing.';
COMMENT ON COLUMN item_submissions.submission_id IS 'Identifier like ITEM-30214 (ITM-YYMMDD-NNN pattern).';
COMMENT ON COLUMN item_submissions.collector_tier IS 'Loyalty tier: Platinum, Gold, Silver, or Standard.';
COMMENT ON COLUMN item_submissions.condition_grade IS 'Condition scale 1.0–10.0 used for routing.';
COMMENT ON COLUMN item_submissions.current_status IS 'SUBMITTED, AUTHENTICATING, GRADED, LISTED, or REJECTED.';
</copy>
```

## Task 3: Seed Sample Data

```sql
<copy>
INSERT INTO item_submissions VALUES ('ITEM-30214', 'Alex Martinez', 'Platinum', 'Sports Card', 9.1, 7200, 'GRAIL', 'AUTHENTICATING', SYSDATE - 2, 0.20);
INSERT INTO item_submissions VALUES ('ITEM-30215', 'Maria Santos', 'Gold', 'Vintage Comic', 8.3, 1850, 'LIMITED', 'SUBMITTED', SYSDATE - 1, 0.10);
INSERT INTO item_submissions VALUES ('ITEM-30216', 'James Wilson', 'Standard', 'Memorabilia', 6.4, 320, 'COMMON', 'LISTED', SYSDATE - 4, 0.00);
INSERT INTO item_submissions VALUES ('ITEM-30217', 'Sarah Johnson', 'Silver', 'Vintage Toy', 7.2, 860, 'LIMITED', 'GRADED', SYSDATE - 3, 0.05);
COMMIT;
</copy>
```

Validate the inserts:

```sql
<copy>
SELECT submission_id, collector_tier, current_status
  FROM item_submissions
 ORDER BY submission_id;
</copy>
```

## Task 4: Register the Table with the Inventory Profile

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name => 'inventory_profile',
        attribute    => 'object_list',
        value        => json_array(
            json_object('schema_name' VALUE user, 'object_name' VALUE 'ITEM_SUBMISSIONS'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'PRICING_POLICIES'),
            json_object('schema_name' VALUE user, 'object_name' VALUE 'AGENT_MEMORY')
        ));
END;
/
</copy>
```

## Task 5: Build the Agent Components

Create the SQL tool, the agent role, the task instructions, and the team wrapper.

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'ITEM_LOOKUP_TOOL',
        attributes  => '{"tool_type": "SQL", "tool_params": {"profile_name": "inventory_profile"}}',
        description => 'Lookup submissions in ITEM_SUBMISSIONS and summarize status, value, and loyalty tier.'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name => 'INVENTORY_AGENT',
        attributes => json_object(
            'role' VALUE 'You are a Seer Equity inventory specialist. You verify submission status, loyalty perks, and valuation data for collectors. Use tools; never guess.',
            'instructions' VALUE 'Confirm the submission status, cite loyalty perks, and reference relevant policy IDs when possible.'
        ),
        description => 'Retail intake assistant for Seer Equity.'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name  => 'INVENTORY_LOOKUP_TASK',
        attributes => json_object(
            'prompt' VALUE 'Answer collector questions about submission status and loyalty perks.
Request: {query}',
            'tools'  VALUE json_array('ITEM_LOOKUP_TOOL')
        ),
        description => 'Task binding the inventory agent to the lookup tool.'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name  => 'INVENTORY_SUPPORT_TEAM',
        attributes => json_object(
            'agents'  VALUE json_array(
                json_object('name' VALUE 'INVENTORY_AGENT', 'task' VALUE 'INVENTORY_LOOKUP_TASK')
            ),
            'process' VALUE 'sequential'
        ),
        description => 'Sequential team for inventory status lookups.'
    );
END;
/
</copy>
```

## Task 6: Ask the Agent

Set the team and request a status update for Alex Martinez.

```sql
<copy>
EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('INVENTORY_SUPPORT_TEAM');
SELECT AI AGENT 'Provide the latest status for submission ITEM-30214, including loyalty perks and valuation context.';
</copy>
```

Observe how the agent:
1. Calls `ITEM_LOOKUP_TOOL`.
2. Returns the status (`AUTHENTICATING`), declared value, and loyalty discount.
3. References relevant pricing policies if comments are present.

## Task 7: Log the Result

Each tool invocation lands in user history for audit purposes.

```sql
<copy>
SELECT tool_name, TO_CHAR(start_date, 'YYYY-MM-DD HH24:MI:SS') AS executed_at
  FROM user_ai_agent_tool_history
 ORDER BY start_date DESC
 FETCH FIRST 5 ROWS ONLY;
</copy>
```

## Summary

You built Seer Equity’s first retail-focused agent. It retrieves live submission status, respects loyalty perks, and leaves a trace. Subsequent labs will expand the toolset, add routing logic, and embed durable memory.

## Workshop Plan (Generated)
- Align narrative with Seer Equity inventory specialists answering submission status for VIP collectors.
- Define `ITEM_SUBMISSIONS` schema fields to capture condition grades, valuation bands, and provenance flags.
- Script agent build steps showing `INVENTORY_AGENT` using `ITEM_LOOKUP` to return actionable facts plus policy citations.
- Reinforce metrics: faster status responses, zero instruction-only replies, and initial audit logging footprint.
