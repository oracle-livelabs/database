# Enterprise Data Integration

## Introduction

Retail valuations must cite official pricing policies, SKU catalogs, and provenance standards. This lab connects Seer Equity agents to enterprise data so recommendations come from governed sources, not guesses.

### Scenario

Marcus Patel needs to justify pricing for ITEM-40105. He must reference the official `PRICING_POLICIES` table and loyalty history before finalizing the recommendation.

### Objectives

- Load policy excerpts, SKU catalog entries, and fraud rules into dedicated tables.
- Register retrieval tools that expose enterprise data to agents with read-only access.
- Demonstrate RAG prompts that quote policy IDs and clauses within responses.

## Task 1: Review Enterprise Tables

Ensure the schema contains:

- `PRICING_POLICIES` – official pricing tiers, maximum discounts, provenance requirements.
- `REFERENCE_KNOWLEDGE` – curated policy excerpts for RAG.
- `LOYALTY_HISTORY` – record of loyalty adjustments and exception approvals.

```sql
<copy>
SELECT table_name FROM user_tables
 WHERE table_name IN ('PRICING_POLICIES', 'REFERENCE_KNOWLEDGE', 'LOYALTY_HISTORY')
 ORDER BY table_name;
</copy>
```

## Task 2: Seed Policy Content

```sql
<copy>
INSERT INTO pricing_policies (policy_id, title, policy_text, max_discount, applies_to)
VALUES ('POL-PLAT', 'Platinum Collector Policy', 'Platinum collectors receive up to 20% loyalty discount on authenticated items under $10,000. Expert appraisal required above $5,000.', 0.20, 'Platinum Tier');

INSERT INTO pricing_policies (policy_id, title, policy_text, max_discount, applies_to)
VALUES ('POL-GOLD', 'Gold Collector Policy', 'Gold collectors receive up to 10% loyalty discount on items under $5,000. Standard appraisal required above $2,500.', 0.10, 'Gold Tier');

COMMIT;
</copy>
```

## Task 3: Populate Reference Knowledge

```sql
<copy>
INSERT INTO reference_knowledge (reference_id, topic, content)
VALUES (
    sys_guid(),
    'Routing Tiers',
    json_object(
        'auto_list' VALUE 'Items under $500 with condition ≥7.0 and rarity COMMON auto-list.',
        'standard'  VALUE 'Items $500–$5,000 or rarity LIMITED require standard appraisal.',
        'expert'    VALUE 'Items over $5,000 or rarity GRAIL require expert appraisal with provenance attachments.'
    )
);

COMMIT;
</copy>
```

## Task 4: Register Enterprise Data Tools

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'POLICY_LOOKUP_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"authentication_profile"}}',
        description => 'Retrieve official pricing policies and discount thresholds.'
    );

    DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'REFERENCE_LOOKUP_TOOL',
        attributes  => '{"tool_type":"SQL","tool_params":{"profile_name":"authentication_profile"}}',
        description => 'Fetch curated policy excerpts and routing guidance for RAG prompts.'
    );
END;
/
</copy>
```

## Task 5: Update Authentication Agent

```sql
<copy>
BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_AGENT(
        agent_name => 'AUTHENTICATION_AGENT',
        attributes => json_object(
            'role' VALUE 'You authenticate submissions and provide policy-backed valuations.',
            'instructions' VALUE 'Cite PRICING_POLICIES policy_id and relevant clauses for each recommendation.'
        )
    );
END;
/

BEGIN
    DBMS_CLOUD_AI_AGENT.UPDATE_TASK(
        task_name  => 'AUTHENTICATION_TASK',
        attributes => json_object(
            'prompt' VALUE 'Answer authentication questions backed by policy data.
Request: {query}',
            'tools'  VALUE json_array('POLICY_LOOKUP_TOOL', 'REFERENCE_LOOKUP_TOOL', 'MEMORY_LOOKUP_TOOL')
        )
    );
END;
/
</copy>
```

## Task 6: Ask for a Policy-Cited Recommendation

```sql
<copy>
SELECT ai_response
  FROM TABLE(DBMS_CLOUD_AI.ASK_AGENT(
        agent_name => 'AUTHENTICATION_AGENT',
        prompt     => 'Provide price guidance for submission ITEM-40105, including applicable policy IDs and justification for the proposed tier.' ));
</copy>
```

Verify the response references `POL-PLAT`, loyalty discount limits, and routing tiers.

## Task 7: Audit Policy Usage

```sql
<copy>
SELECT tool_name, SUBSTR(output, 1, 120) AS excerpt
  FROM user_ai_agent_tool_history
 WHERE tool_name IN ('POLICY_LOOKUP_TOOL', 'REFERENCE_LOOKUP_TOOL')
 ORDER BY start_date DESC
 FETCH FIRST 5 ROWS;
</copy>
```

## Summary

Enterprise data integration ensures every valuation cites the same source of truth. Agents no longer guess; they pull policy IDs, discount thresholds, and provenance requirements straight from governed tables.

## Workshop Plan (Generated)
- Integrate Seer Equity pricing policies, SKU catalogs, and fraud rules into RAG examples.
- Demonstrate certified data sources powering price guidance, restocking fees, and policy citations.
- Highlight alignment with retail megalab scenario around high-value electronics and apparel returns.
