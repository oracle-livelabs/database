# Lab 2: Janice Finds the Contract Signal

## Introduction

Janice Walker is in-house counsel in ACME's CLO office. She reviews customer POs and contracts for clauses that can change downstream processing. One clause matters a lot in this story: customer acceptance after installation or site testing. If Janice misses it, an order can move too quickly toward invoicing or revenue treatment.

In this lab, you build an Agent Builder flow that reads EBS-like order evidence, uses source-scoped contract and policy context, and creates a revenue exception package through an approved REST action. This adds the contract signal that John will need before creating the recovery case.

The business value is speed with control. Janice does not search a shared drive, paste contract text into a public tool, or make an accounting decision. PAF helps her find the relevant contract signal, connect it to the order, and create the right internal package for review.

**Estimated Time:** 30 minutes

### Objectives

In this lab, you will:

- Scope contract retrieval to the exact Northstar contract source.
- Use PAF to see the contract exception issue before automation.
- Build an Agent Builder flow with SQL, policy context, prompt, condition, and REST action steps.
- Confirm the before-and-after result using the PAF REST source.
- Show how private knowledge can be used without searching every contract in the enterprise.

### Prerequisites

- You have completed **Lab 1: Maya Finds the Margin Leak**.
- You can access the **ACME EBS AI Database** and **ACME EBS Action Service** sources.
- The Northstar contract source and revenue policy source are available in Private Agent Factory.

Role boundary:

- Janice is the Legal user. She reviews the evidence and exception package.
- You are temporarily acting as the PAF builder. SQL and retrieval wiring are private implementation steps that give the agent controlled access to approved evidence.
- Janice's experience is a natural-language request and an auditable exception package, not direct database work.

### Preconfigured Components Used

- Database source: **ACME EBS AI Database**
- Data Analysis agents: **ACME Contract Exception Packet Agent**, **ACME Order Contract Context Agent**
- REST API source: **ACME EBS Action Service**
- Revenue policy source: **ACME Policy Revenue Contract Review**
- Contract source: **ACME Contract CONTRACT ID 1111 ACME Northstar Master Agreement**
- Demo views: `ADMIN.ACME_CONTRACT_EXCEPTION_PACKET_V`, `ADMIN.ACME_ORDER_CONTRACT_CONTEXT_V`

## Task 1: Confirm Contract Retrieval Scope

The workshop uses one contract source for this order. This is intentional. A production Legal or Contracts team needs answers scoped to the agreement under review, not a blended answer from every customer contract.

Open **Knowledge Agents** in PAF.

Create a Knowledge Agent named:

```
<copy>
ACME Northstar Contract Agent
</copy>
```

Use only this preloaded filesystem source:

```
<copy>
ACME Contract CONTRACT ID 1111 ACME Northstar Master Agreement
</copy>
```

Do not select the other contract sources. This makes retrieval explicit: when the user asks about `CONTRACT_ID_1111`, the agent should search only the Northstar contract.

If the Knowledge Agent chat asks for a model, choose `ACME_xai.grok-4`.

Test the Knowledge Agent with:

```
<copy>
For Contract ID 1111 / CONTRACT_ID_1111, summarize acceptance, rebate, pricing, freight, and recovery terms that could affect margin recovery.
</copy>
```

Expected answer:

- The answer should stay scoped to `CONTRACT_ID_1111`.
- It should identify the counterparty as `Northstar Mining Ltd.`
- It should not cite `CONTRACT_ID_1212`, `CONTRACT_ID_1243`, `CONTRACT_ID_1276`, or `CONTRACT_ID_1301`.
- It should identify terms that matter for acceptance, pricing/rebates, freight, or commercial recovery.

If the Knowledge Agent chat runtime is unavailable in your environment, continue with the SQL evidence below. The contract is still staged and discoverable as a source; the rest of this lab uses the database contract signal and approved REST action.

## Task 2: See the Issue in PAF

Janice's business question is simple: does this order carry a contract term that changes how ACME should handle downstream review? The copied prompt names the evidence view and output fields so the lab is repeatable.

Open **Data Analysis**.

Use Database source:

```
<copy>
ACME EBS AI Database
</copy>
```

If Data Analysis asks you to select an agent for the first question, choose:

```
<copy>
ACME Contract Exception Packet Agent
</copy>
```

Ask:

```
<copy>
For order SO-48192, show the contract exception packet. Include customer name, contract_id, contract_title, contract_file_name, gross revenue, gross margin percent, revenue review signal, order status, and the contract clause context. Use ADMIN.ACME_CONTRACT_EXCEPTION_PACKET_V.
</copy>
```

Expected result:

- `SO-48192` is for `Northstar Mining Ltd.`
- The contract is `CONTRACT_ID_1111`.
- The signal is `REVENUE_REVIEW_REQUIRED`.
- The issue is acceptance after installation, commissioning, and a site performance test.
- The agent will create a review package, not release a hold or decide accounting treatment.

Ask a follow-up:

```
<copy>
For SO-48192, show the order-to-contract context from ADMIN.ACME_ORDER_CONTRACT_CONTEXT_V. Include customer_name, contract_id, item_family, region, pricing_program, rebate_program, tax_category, SLA profile, account_owner, relationship_health, open_pipeline, and recommended_engagement_path.
</copy>
```

If Data Analysis asks you to select an agent for this follow-up, choose:

```
<copy>
ACME Order Contract Context Agent
</copy>
```

Expected result:

- `SO-48192` maps to `CONTRACT_ID_1111`.
- Account owner is `Elena Brooks`.
- Relationship health is `At risk`.
- The account context matters before ACME decides how to recover margin.

This is why the agent should not stop at "recover the money." Northstar is strategic and at risk, so the right output is a governed internal case with the account owner involved.

## Task 3: Check Before State in PAF

Before running the agent, check whether a revenue exception package already exists.

1. Open **Builder Studio**.
2. Open REST API source **ACME EBS Action Service**.
3. Test operation `listActionAudit`.

On a fresh run, `revenue_exceptions` should be empty. If it is not empty, note the current count so you can confirm the count increases after the agent runs.

## Task 4: Build the Contract Exception Agent

In this task, switch from Janice's business-user view to the PAF builder view.

The SQL node is not something Janice writes. It is the controlled data-access step inside the agent flow.

Create an Agent Builder flow named:

```
<copy>
ACME Contract Exception Agent
</copy>
```

Add these nodes:

1. **Chat Input:** accepts `order_number`.
2. **SQL Query:** uses **ACME EBS AI Database** and selects from `ADMIN.ACME_CONTRACT_EXCEPTION_PACKET_V`.
3. **Prompt/LLM Step:** classifies the clause and produces an action payload.
4. **Condition:** if revenue review is required, call the OpenAPI tool.
5. **OpenAPI Tool:** uses **ACME EBS Action Service** operation `createRevenueExceptionPackage`.
6. **Chat Output:** returns evidence, package ID, and audit ID.

    SQL Query for the builder-only evidence step:

    ```
    <copy>
    select *
    from admin.acme_contract_exception_packet_v
    where order_number = :order_number
    </copy>
    ```

    Prompt/LLM Step:

    ```
    <copy>
    You are a contracts operations assistant for ACME Precision Components.

    Use only the SQL evidence below and the ACME revenue policy principle that acceptance after installation, site testing, customer sign-off, milestone acceptance, or other post-shipment acceptance language requires revenue review.

    SQL evidence:
    {{SQL Query}}

    Classify whether the order requires revenue review. If it does, produce:
    1. The exact clause issue.
    2. Why it matters operationally.
    3. A JSON payload for createRevenueExceptionPackage with order_number, customer_name, clause_summary, recommended_hold, and evidence_summary.

    Use recommended_hold = "Revenue review hold" when review is required.
    Do not make final accounting conclusions. Recommend review only.
    Do not claim the EBS order status or revenue treatment has been changed.
    </copy>
    ```

    Condition:

    ```
    <copy>
    Call createRevenueExceptionPackage only when revenue_review_signal = REVENUE_REVIEW_REQUIRED or the Prompt/LLM Step says revenue review is required.
    </copy>
    ```

    If you need a deterministic payload for the first run, use:

    ```
    <copy>
    {
      "order_number": "SO-48192",
      "customer_name": "Northstar Mining Ltd.",
      "clause_summary": "Customer PO requires acceptance after installation, commissioning, and a 72-hour site performance test.",
      "recommended_hold": "Revenue review hold",
      "evidence_summary": "Order packet is marked REVENUE_REVIEW_REQUIRED because acceptance is contingent on post-shipment installation or site testing. Contract context maps SO-48192 to CONTRACT_ID_1111."
    }
    </copy>
    ```

## Task 5: Run and Confirm the After State

Run the agent with:

```
<copy>
Review SO-48192 for revenue-impacting contract clauses and create the exception package if required.
</copy>
```

Expected agent response:

- The acceptance-after-installation clause is identified.
- The agent recommends revenue review.
- A revenue exception package is created.
- The response includes a generated `package_id` and `audit_id`.

Now return to **ACME EBS Action Service** and run `listActionAudit` again.

Expected after-state:

- `revenue_exceptions` contains one additional record for `SO-48192`.
- The new record has status `PENDING_REVENUE_ACCOUNTING_REVIEW`.
- `audit` contains a matching `CREATE_REVENUE_EXCEPTION_PACKAGE` entry.

This is the enterprise pattern: Janice still owns the review, but the agent finds the clause, gathers the evidence, and creates the package without giving itself broad ERP write access.

The important point is not that PAF read a PDF. The important point is that PAF connected a specific contract, a specific order, a revenue policy, and an approved action without losing the control boundary.

### What Leaders Should Notice

- Contract retrieval stayed scoped to `CONTRACT_ID_1111`.
- The agent created a review package, not a final accounting conclusion.
- Legal and Contracts remain in control of interpretation.
- The pattern can scale to other contract-heavy processes such as service credits, acceptance terms, rebate programs, termination rights, renewal exposure, and negotiated freight terms.

You may now **proceed to the next lab**.

## Acknowledgements

**Authors**

- Database Applied AI Technical Staff
- Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - June, 2026
