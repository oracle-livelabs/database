# Lab 1: Maya Finds the Margin Leak

## Introduction

Maya Rodriguez is a business analyst in ACME's CFO office. The CFO asks her to investigate the June margin report after industrial pump orders show a sudden drop. The ordinary dashboard tells her which orders are low margin. It does not explain why the margin changed, which root causes are systemic, or who should own the next action.

In this lab, you use PAF Data Analysis over an AI-ready operational evidence view in Oracle AI Database, then build a small Agent Builder flow that creates a controlled finance review note. This is a high-value first agent because it turns a monthly reporting surprise into evidence, root cause, owner, and audit trail.

The evidence view is not Maya's dashboard. It is the trusted agent layer that combines EBS-like orders, item costs, absorbed charges, tax matrix signals, pricing-rule signals, and remediation plans so the agent can explain the variance and create the next controlled artifact.

**Estimated Time:** 25 minutes

### Objectives

In this lab, you will:

- Ask natural-language questions over the preconfigured ACME database source.
- Identify the business root causes behind low margin.
- Build a margin investigation agent in Builder Studio.
- Confirm the before-and-after result using the PAF REST source.
- Show how an AI CoE can convert a recurring finance investigation into a reusable agent pattern.

### Prerequisites

- You have completed the **Get Started** lab.
- You can sign in to Private Agent Factory.
- The **ACME EBS AI Database** and **ACME EBS Action Service** sources are available.

Role boundary:

- Maya is the business user from the CFO's office. She asks natural-language questions and receives a governed finance review note.
- You are temporarily acting as the PAF builder. When you configure SQL nodes later in the lab, that is private agent implementation work, not something Maya writes or sees.
- The SQL exists to ground the agent in approved ACME data. The business experience remains natural language plus controlled action output.

### Preconfigured Components Used

- Database source: **ACME EBS AI Database**
- Data Analysis agents: **ACME Margin Full Agent**, **ACME Margin Recovery Candidate Agent**
- REST API source: **ACME EBS Action Service**
- Demo views: `ADMIN.ACME_MARGIN_FULL`, `ADMIN.ACME_MARGIN_RECOVERY_CANDIDATE_V`

## Task 1: See the Issue in PAF

Open **Data Analysis**.

Select the Database source:

```
<copy>
ACME EBS AI Database
</copy>
```

If the UI shows a profile selector, select `ACME_EBS_MARGIN_PROFILE`. If no profile selector is shown, continue with the database source. The questions below name the exact ACME views to use.

If Data Analysis asks you to select an agent, choose:

```
<copy>
ACME Margin Full Agent
</copy>
```

Maya's business question is simple: which orders are below target margin, and what evidence explains the drop? The copied prompt is more explicit so every workshop environment asks for the same evidence columns.

Ask:

```
<copy>
Show June 2026 industrial pump orders with gross margin below 25 percent. Include order number, customer, ship-to country, gross revenue, margin percent, absorbed freight, absorbed export tax, rebate accrual, tax matrix status, expired pricing rules, remediation owner, and review signal. Use ADMIN.ACME_MARGIN_FULL. Derive a short root-cause explanation from those evidence columns.
</copy>
```

Expected result:

- Three June 2026 industrial pump orders are below 25 percent margin.
- Root causes include EU duty/carbon surcharge absorption, expired Northstar rebate rules, and emergency freight.
- The answer should cite `SO-48192`, `SO-48204`, and `SO-48217`.

`SO-48231` and `SO-48244` are not below 25 percent margin, but they appear in the next step as supporting absorbed-charge evidence.

In the story, Maya asks this as a business question. PAF handles the governed data access behind the scenes.

## Task 2: Ask Maya's Root-Cause Question

Maya's follow-up is the question executives usually care about: which causes are one-time recovery opportunities, and which ones are system-control fixes? The copied prompt names the approved evidence view so the answer stays grounded.

Ask:

```
<copy>
Why did gross margin drop or require attention on June 2026 industrial pump orders? Use ADMIN.ACME_MARGIN_FULL. Include orders with gross_margin_pct below 25 percent or nonzero freight_absorbed, export_tax_absorbed, or rebate_accrual. Infer the root causes from charge, tax matrix, expired pricing-rule, and remediation columns. Show affected orders and absorbed-charge impact by freight_absorbed, export_tax_absorbed, and rebate_accrual. Distinguish one-time recovery work from strategic system-control fixes.
</copy>
```

A strong answer should find:

- Below-25 margin review orders: `SO-48192`, `SO-48204`, and `SO-48217`.
- Additional absorbed-charge evidence: `SO-48231` for emergency freight and `SO-48244` for export tax absorption.
- Impact by category: freight absorbed about `45300`, rebate accrual about `39388`, and export tax absorbed about `21347`.
- Total estimated absorbed-charge impact: `106035`.
- Emergency freight is the largest immediate recovery opportunity.
- EU tax/quote mismatch and expired Northstar rebate behavior are strategic system-control fixes.

Ask a follow-up:

```
<copy>
Which root cause has the largest immediate dollar impact, and which root causes are strategic system-control fixes?
</copy>
```

Expected answer:

- Emergency freight is the largest immediate dollar impact.
- EU tax/quote mismatch and expired rebate are strategic system-control fixes.

## Task 3: Preview the Recovery Candidate

Now narrow the investigation from a broad finance issue to the Northstar thread that the rest of the workshop will follow. This is still a business question; the view name keeps the lab deterministic.

Ask:

```
<copy>
For order SO-48192, show the margin recovery candidate evidence. Include contract_id, customer_name, account_owner, relationship_health, revenue_review_signal, primary_root_cause, gross_margin_pct, estimated_margin_impact, recommended_owner, and recommended_next_step. Use ADMIN.ACME_MARGIN_RECOVERY_CANDIDATE_V.
</copy>
```

If Data Analysis asks you to select an agent, choose:

```
<copy>
ACME Margin Recovery Candidate Agent
</copy>
```

Expected result:

- `SO-48192` maps to `CONTRACT_ID_1111`.
- The customer is `Northstar Mining Ltd.`
- The account owner is `Elena Brooks`.
- Relationship health is `At risk`.
- The next step is an executive-led commercial recovery review, not an automatic price change.

This is the moment where the story narrows from a broad margin problem to one high-value business thread: Northstar, `SO-48192`, and `CONTRACT_ID_1111`.

## Task 4: Check Before State in PAF

Before creating anything, check whether a margin note already exists.

1. Open **Builder Studio**.
2. Open REST API source **ACME EBS Action Service**.
3. Test operation `listActionAudit`.

On a fresh run, `margin_notes` should be empty. If it is not empty, note the current count so you can confirm the count increases after the agent runs.

## Task 5: Build the Margin Investigation Agent

In this task, switch hats. You are no longer Maya. You are the PAF builder creating the private workflow Maya will use.

The SQL node is implementation detail. It gives the agent repeatable, approved evidence from the ACME database. Maya will only see the chat input, the explanation, and the created review note.

Create an Agent Builder flow named:

```
<copy>
ACME Margin Investigation Agent
</copy>
```

Add these nodes:

1. **Chat Input:** accepts the user request.
2. **SQL Query:** uses **ACME EBS AI Database**.
3. **Prompt/LLM Step:** summarizes the issue and prepares the action payload.
4. **OpenAPI Tool:** uses **ACME EBS Action Service** operation `createMarginInvestigationNote`.
5. **Chat Output:** returns the note ID, audit ID, and summary.

    SQL Query for the builder-only evidence step:

    ```
    <copy>
    select
      order_number,
      customer_name,
      ship_to_country,
      gross_revenue,
      gross_margin_pct,
      freight_absorbed,
      export_tax_absorbed,
      rebate_accrual,
      charge_explanation,
      tax_matrix_status,
      tax_matrix_evidence,
      expired_pricing_rule_count,
      expired_pricing_rules,
      expired_pricing_rule_end_date,
      pricing_rule_owner,
      remediation_owner,
      remediation_plan,
      remediation_target_date,
      review_signal
    from admin.acme_margin_full
    where booked_date between date '2026-06-01' and date '2026-06-30'
      and (
        gross_margin_pct < 25
        or coalesce(freight_absorbed, 0) > 0
        or coalesce(export_tax_absorbed, 0) > 0
        or coalesce(rebate_accrual, 0) > 0
      )
    order by gross_margin_pct
    </copy>
    ```

    Prompt/LLM Step:

    ```
    <copy>
    You are a finance operations assistant for ACME Precision Components.

    Use only the SQL evidence below.

    SQL evidence:
    {{SQL Query}}

    Produce:
    1. A concise explanation of why June 2026 industrial pump margin fell below target or required attention.
    2. The affected orders and inferred root causes. Derive the root causes from charge, tax matrix, expired pricing-rule, and remediation evidence columns.
    3. A JSON payload for createMarginInvestigationNote with period_name, finding, root_cause, estimated_margin_impact, and recommended_owner.

    Use estimated_margin_impact as the sum of freight_absorbed, export_tax_absorbed, and rebate_accrual when those columns are present. For the expected demo evidence, that total is 106035.
    The recommended owner should be Finance Operations.
    Do not claim the underlying EBS data has been fixed. The action creates a controller review note only.
    </copy>
    ```

    For the OpenAPI tool payload, use the JSON produced by the Prompt/LLM step. If you need a deterministic payload for the first run, use:

    ```
    <copy>
    {
      "period_name": "June 2026",
      "finding": "Industrial pump margin fell below target or required attention on June orders with low margin and absorbed charges.",
      "root_cause": "EBS applied EU duties not quoted by CPQ, expired Northstar rebate rules remained active, and emergency freight was absorbed for AX900 backorders.",
      "estimated_margin_impact": 106035,
      "recommended_owner": "Finance Operations"
    }
    </copy>
    ```

## Task 6: Run and Confirm the After State

Run the agent with:

```
<copy>
Create a margin investigation note for June 2026 low-margin industrial pump orders.
</copy>
```

Expected agent response:

- A note was created.
- The note status is `READY_FOR_CONTROLLER_REVIEW`.
- The response includes a generated `note_id` and `audit_id`.

Now return to **ACME EBS Action Service** and run `listActionAudit` again.

Expected after-state:

- `margin_notes` contains one additional record.
- The new record has status `READY_FOR_CONTROLLER_REVIEW`.
- `audit` contains a matching `CREATE_MARGIN_INVESTIGATION_NOTE` entry.

This is the enterprise pattern: Maya sees the issue, the agent creates a governed work artifact, and the source-of-truth EBS-like data is not silently modified.

Before PAF, Maya would need Finance Operations, EBS support, Contracts, Pricing, and Sales to manually stitch this together. With PAF, she gets evidence-grounded insight and a controlled next-step artifact in the same workflow.

### What Leaders Should Notice

- The business user did not need to know the schema or write SQL.
- The answer stayed grounded in approved Oracle Database evidence.
- The agent created a finance review note, not an uncontrolled ERP change.
- The same pattern can be reused for other recurring investigations: tax variance, rebate leakage, fulfillment cost spikes, service-credit exposure, or revenue-review queues.

You may now **proceed to the next lab**.

## Acknowledgements

**Authors**

- Database Applied AI Technical Staff
- Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - June, 2026
