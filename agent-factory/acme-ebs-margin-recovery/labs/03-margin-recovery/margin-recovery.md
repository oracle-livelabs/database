# Lab 3: John Creates the Governed Recovery Case

## Introduction

John Patel is a contract manager in Finance. He owns the human path for margin recovery. He is not trying to send a negotiation email, change a price list, or update EBS directly. His job is to create a governed recovery case that gives Finance, Sales, Revenue Accounting, Legal, and the account owner the evidence they need.

In this lab, you build an operational agent that combines margin evidence, contract signal, CRM account context, and commercial recovery policy. The agent creates a Margin Recovery Case through an approved REST action.

This is the payoff of the workshop. PAF turns scattered EBS-like order data, contract language, CRM account context, private policy, and approved action APIs into one governed business artifact. For executives and AI CoEs, this is the difference between an impressive assistant and a production-shaped agent.

**Estimated Time:** 30 minutes

### Objectives

In this lab, you will:

- Use Data Analysis to inspect the recovery candidate for `SO-48192`.
- Scope contract retrieval to `CONTRACT_ID_1111`.
- Include CRM context before recommending a recovery path.
- Create a governed Margin Recovery Case with required approvals and audit ID.
- Confirm the before-and-after result using the PAF REST source.
- Show how agents can take action safely by creating a controlled case instead of changing ERP records directly.

### Prerequisites

- You have completed **Lab 2: Janice Finds the Contract Signal**.
- You can access the **ACME Margin Recovery Candidate Agent**.
- The commercial recovery policy source and Northstar contract source are available in Private Agent Factory.

Role boundary:

- John is the Finance user who owns the recovery path. He asks for a case and works the governed next action.
- You are temporarily acting as the PAF builder. SQL, source selection, and REST-tool wiring are private implementation details inside the agent.
- John's experience is natural language, evidence, owner, next action, approvals, and audit trail.

### Preconfigured Components Used

- Database source: **ACME EBS AI Database**
- Data Analysis agent: **ACME Margin Recovery Candidate Agent**
- REST API source: **ACME EBS Action Service**
- Commercial recovery policy source: **ACME Policy Commercial Recovery**
- Contract source: **ACME Contract CONTRACT ID 1111 ACME Northstar Master Agreement**
- Demo view: `ADMIN.ACME_MARGIN_RECOVERY_CANDIDATE_V`
- REST action: `createMarginRecoveryCase`

## Task 1: See the Recovery Candidate

John's business question is practical: should ACME pursue recovery on this order, and how should the case be routed so the account is protected? The copied prompt asks for the full case evidence so the created artifact is complete and repeatable.

Open **Data Analysis**.

Use Database source:

```
<copy>
ACME EBS AI Database
</copy>
```

If Data Analysis asks you to select an agent, choose:

```
<copy>
ACME Margin Recovery Candidate Agent
</copy>
```

Ask:

```
<copy>
For order SO-48192, show the margin recovery candidate. Include contract_id, customer_name, account_owner, strategic_tier, annual_revenue, open_pipeline, renewal_timing, relationship_health, recent_support_escalation, prior_concessions, executive_sponsor, revenue_review_signal, primary_root_cause, gross_margin_pct, estimated_margin_impact, required_approvals, recommended_owner, recommended_next_step, margin_impact_summary, contract_summary, crm_summary, and evidence_summary. Use ADMIN.ACME_MARGIN_RECOVERY_CANDIDATE_V.
</copy>
```

Expected result:

- `SO-48192` maps to `CONTRACT_ID_1111`.
- Customer is `Northstar Mining Ltd.`
- Account owner is `Elena Brooks`.
- Relationship health is `At risk`.
- The view combines margin, contract, and CRM context.
- The recommended path is an executive-led commercial recovery review, not an automatic price change.

This should feel different from a normal analytics answer. The view already contains the evidence needed to route the work, not just explain the variance.

## Task 2: Confirm the Contract and Policy Scope

Before creating a case, confirm the two knowledge boundaries: the Northstar contract and the commercial recovery policy. This keeps the recommendation focused and reviewable.

For contract context, use only this contract source:

```
<copy>
ACME Contract CONTRACT ID 1111 ACME Northstar Master Agreement
</copy>
```

For policy context, use only this policy source:

```
<copy>
ACME Policy Commercial Recovery
</copy>
```

The contract source is scoped to `CONTRACT_ID_1111`. The policy source is scoped to the commercial recovery playbook. This is intentional: the agent should not search every contract or every policy when John is creating a case for one order.

If you create Knowledge Agents for this task, use names like:

```
<copy>
ACME Northstar Contract Agent
ACME Commercial Recovery Policy Agent
</copy>
```

Test question for the commercial policy:

```
<copy>
When should ACME create a Margin Recovery Case, and what approvals are required before customer engagement?
</copy>
```

Expected answer:

- Create a case when margin leakage depends on customer relationship context, contract signal, or prior concessions.
- Include Finance Operations or controller review, account owner involvement for strategic accounts, and Revenue Accounting when revenue-review clauses are present.
- The policy should recommend a governed case, not a direct customer email or automatic EBS update.

If the Knowledge Agent chat runtime is unavailable in your environment, continue with the SQL evidence and deterministic payload below. The sources are still staged for source-scoped retrieval.

## Task 3: Check Before State in PAF

Before running the agent, check whether a margin recovery case already exists.

1. Open **Builder Studio**.
2. Open REST API source **ACME EBS Action Service**.
3. Test operation `listActionAudit`.

On a fresh run, `margin_recovery_cases` should be empty. If it is not empty, note the current count so you can confirm the count increases after the agent runs.

## Task 4: Build the Margin Recovery Case Agent

In this task, switch from John's business-user view to the PAF builder view.

The SQL node is not something John writes. It is the controlled evidence retrieval step inside the agent flow.

Create an Agent Builder flow named:

```
<copy>
ACME Margin Recovery Case Agent
</copy>
```

Add these nodes:

1. **Chat Input:** accepts `order_number`.
2. **SQL Query:** uses **ACME EBS AI Database** and selects from `ADMIN.ACME_MARGIN_RECOVERY_CANDIDATE_V`.
3. **Prompt/LLM Step:** prepares the governed case payload.
4. **OpenAPI Tool:** uses **ACME EBS Action Service** operation `createMarginRecoveryCase`.
5. **Chat Output:** returns the case ID, audit ID, evidence summary, owner, next action, and status.

SQL Query for the builder-only evidence step:

```
<copy>
select *
from admin.acme_margin_recovery_candidate_v
where order_number = :order_number
</copy>
```

Prompt/LLM Step:

```
<copy>
You are a commercial margin recovery assistant for ACME Precision Components.

Use only the SQL evidence below and the ACME commercial recovery policy principle that the approved deliverable is a governed Margin Recovery Case.

SQL evidence:
{{SQL Query}}

Produce:
1. Customer/order summary.
2. Margin impact and primary root cause.
3. Contract signal and contract_id.
4. CRM account context, including account owner and relationship health.
5. Recommended recovery path.
6. Required approvals.
7. Evidence summary.
8. A JSON payload for createMarginRecoveryCase with order_number, contract_id, customer_name, account_owner, priority, margin_impact_summary, contract_summary, crm_summary, recommended_next_step, required_approvals, and evidence_summary.

Use priority = "HIGH" when relationship_health is "At risk" or estimated_margin_impact is material.
Do not send a negotiation email.
Do not update EBS.
Do not claim pricing, rebate, revenue, or customer records have been changed.
</copy>
```

If you need a deterministic payload for the first run, use:

```
<copy>
{
  "order_number": "SO-48192",
  "contract_id": "CONTRACT_ID_1111",
  "customer_name": "Northstar Mining Ltd.",
  "account_owner": "Elena Brooks",
  "priority": "HIGH",
  "margin_impact_summary": "June 2026 industrial pump order SO-48192 has low margin from expired rebate behavior and emergency freight absorption. The estimated recovery opportunity should be reviewed before any customer engagement.",
  "contract_summary": "SO-48192 maps to CONTRACT_ID_1111 for Northstar Mining Ltd. Contract and order evidence include a revenue-review signal tied to customer acceptance after installation and site testing.",
  "crm_summary": "Northstar is a strategic account with relationship health At risk, open expansion pipeline, prior concessions, and account owner Elena Brooks.",
  "recommended_next_step": "Create an executive-led commercial recovery review with the account owner, CFO delegate, and Pricing Operations before requesting repayment. Required approvals are Revenue Accounting, Account Owner, and Finance Controller.",
  "required_approvals": ["Revenue Accounting", "Account Owner", "Finance Controller"],
  "evidence_summary": "Margin, contract, and CRM context support a governed recovery case rather than an automatic EBS update, price change, or customer email."
}
</copy>
```

## Task 5: Run and Confirm the After State

Run the agent with:

```
<copy>
Create a margin recovery case for SO-48192 using margin evidence, contract signal, and CRM account context.
</copy>
```

Expected agent response:

- A Margin Recovery Case is created.
- The status is `PENDING_COMMERCIAL_REVIEW`.
- The response includes a generated `case_id` and `audit_id`.
- The answer names the owner and next action.
- The answer does not claim EBS, pricing, or customer records were changed.
- The answer makes clear that Elena Brooks and the required approval owners now have a governed case to work from.

Now return to **ACME EBS Action Service** and run `listActionAudit` again.

Expected after-state:

- `margin_recovery_cases` contains one additional record for `SO-48192`.
- The new record has status `PENDING_COMMERCIAL_REVIEW`.
- `audit` contains a matching `CREATE_MARGIN_RECOVERY_CASE` entry.

This is the enterprise pattern: John gets a complete recovery case with evidence, approvals, owner, next action, and audit trail, while the business control remains intact.

That is the "why PAF" moment: the agent did not just summarize data. It transformed a messy cross-functional issue into an auditable case that the business can act on.

### What Leaders Should Notice

- The agent took action, but only through an approved OpenAPI operation.
- The output includes owner, next action, approvals, status, and audit ID.
- CRM context changed the recommendation from "recover the money" to "route an executive-led recovery review."
- The pattern is repeatable for other high-value ERP workflows where the business needs evidence plus controlled action.

You may now **proceed to the next lab**.

## Acknowledgements

**Authors**

- Database Applied AI Technical Staff
- Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - June, 2026
