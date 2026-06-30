# Get Started

## Introduction

Your workshop environment has already been provisioned by the ASCEND Resource Manager stack. The stack installs Oracle AI Database Private Agent Factory, configures the database and models, and stages the ACME demo services in the background.

You are not here to install software. You are here to evaluate a repeatable enterprise pattern: connect trusted ERP data, private knowledge, and narrow approved actions into a governed agent workflow.

You only need three values from the instructor or LiveLab reservation page:

- Private Agent Factory URL
- Username
- Password

All database connections, demo data, LLM configuration, embeddings, MCP server, REST tools, policy PDFs, and contract PDFs are configured in the background.

If any PAF chat, Knowledge Agent, or Agent Builder step asks you to choose an application LLM, choose:

```
<copy>
ACME_xai.grok-4
</copy>
```

The live story follows one order:

```
<copy>
SO-48192 | Northstar Mining Ltd. | CONTRACT_ID_1111
</copy>
```

The other orders, contracts, and policy sources are present so the workshop feels like a real enterprise environment, but the main runthrough should stay centered on this one path.

**Estimated Time:** 10 minutes

### Objectives

In this lab, you will:

- Sign in to Private Agent Factory.
- Confirm the preconfigured data, document, MCP, and REST assets.
- Learn the before-and-after action check used throughout the workshop.
- Confirm that contract retrieval is scoped by contract ID.
- Understand that the final artifact is a governed Margin Recovery Case, not an ERP update or customer email.

### Prerequisites

- The Private Agent Factory URL supplied by the instructor or LiveLab reservation page.
- The workshop username and password.
- The Resource Manager stack has completed successfully.

## Task 1: Sign In

1. Open the Private Agent Factory URL.

2. Sign in with the supplied username and password.

If the URL opens an installation page instead of the PAF home page, stop and ask the instructor to refresh the environment. Attendees should not run installation steps.

## Task 2: Confirm the Business Architecture

Open **Builder Studio** and confirm these assets are available.

Database source:

```
<copy>
ACME EBS AI Database
</copy>
```

This source represents the trusted ERP evidence layer. It includes curated views over EBS-like orders, costs, charges, tax signals, pricing signals, contract metadata, CRM context, and recovery candidates.

REST API source:

```
<copy>
ACME EBS Action Service
</copy>
```

Expected REST operations used in this workshop:

- `listActionAudit`
- `createMarginInvestigationNote`
- `createRevenueExceptionPackage`
- `createMarginRecoveryCase`

You may also see `createComplianceReview`. That is a legacy supporting action from an earlier version of the lab and is not required for the current story.

MCP source:

```
<copy>
ACME Oracle AI Database MCP Server
</copy>
```

The live source name can include the database name as a suffix, for example:

```
<copy>
ACME Oracle AI Database MCP Server - ACMECUST...
</copy>
```

Data Analysis / Select AI:

```
<copy>
ACME EBS AI Database
</copy>
```

If the UI shows a profile named `ACME_EBS_MARGIN_PROFILE`, select it. If no profile selector is shown, continue with the database source. The lab queries name the ACME views explicitly.

The first lab uses `ADMIN.ACME_MARGIN_FULL`. Treat it as an AI-ready evidence view, not as Maya's dashboard. It combines operational columns from orders, lines, costs, absorbed charges, tax matrix timing, custom pricing rules, and remediation plans so PAF can infer the business explanation.

Prebuilt Data Analysis agents:

```
<copy>
ACME Margin Full Agent
ACME Contract Exception Packet Agent
ACME Order Contract Context Agent
ACME Margin Recovery Candidate Agent
</copy>
```

If Data Analysis asks you to choose an agent instead of a database profile, use the prebuilt agent named in each lab. Do not spend workshop time creating these agents manually.

If you see **ACME Margin Explanation Agent**, treat it as a legacy agent from an earlier zip. The current lab path uses **ACME Margin Full Agent**.

Policy PDF sources for Knowledge Agents:

```
<copy>
ACME Policy Revenue Contract Review
ACME Policy Regional Compliance
ACME Policy Commercial Recovery
</copy>
```

You may also see the combined legacy source:

```
<copy>
ACME EBS Policy PDFs
</copy>
```

Use the individual policy sources when the lab asks for a specific policy.

Contract PDF sources:

```
<copy>
ACME Contract CONTRACT ID 1111 ACME Northstar Master Agreement
ACME Contract CONTRACT ID 1212 ACME Valewood Master Supply Services Agreement
ACME Contract CONTRACT ID 1243 ACME Cresthaven Rail Utility Master Commercial Agreement
ACME Contract CONTRACT ID 1276 ACME Marineris Cold Chain Master Commercial Agreement
ACME Contract CONTRACT ID 1301 ACME Sableford Energy Storage Master Commercial Agreement
</copy>
```

Each contract is staged as its own source so a Knowledge Agent can be scoped to one contract. The source descriptions and filenames preserve the exact `CONTRACT_ID_####` value.

For the main demo path, use the Northstar source for `CONTRACT_ID_1111`. Treat the other four contract sources as proof that the environment can support many large contracts without forcing the agent to search everything at once.

## Task 3: Learn the Before-and-After Check

The demo does not let agents update EBS-like source tables directly. Instead, agents create governed review artifacts through **ACME EBS Action Service**.

Before and after each agent run, use PAF to inspect the action state:

1. Open **Builder Studio**.
2. Open REST API source **ACME EBS Action Service**.
3. Run or test the operation:

```
<copy>
listActionAudit
</copy>
```

On a fresh environment, the response should show empty arrays for:

- `margin_notes`
- `revenue_exceptions`
- `margin_recovery_cases`
- `audit`

After each lab, run `listActionAudit` again. A new note, exception package, or margin recovery case should appear with a generated ID, status, timestamp, and audit record.

If testing the REST operation reports that port `8020` is not allowed, the environment was not patched by the latest Resource Manager zip. Ask the instructor to refresh the stack with the current package.

This check is the executive proof point. PAF is not just answering questions; it is creating governed work artifacts through a narrow approved action surface.

## Task 4: Retrieval Scope Rule

When the lab asks about a contract, choose the source for that exact contract ID.

Examples:

- For `CONTRACT_ID_1111`, use **ACME Contract CONTRACT ID 1111 ACME Northstar Master Agreement**.
- For `CONTRACT_ID_1212`, use **ACME Contract CONTRACT ID 1212 ACME Valewood Master Supply Services Agreement**.

Do not build one Knowledge Agent across all contracts for this workshop. The point of the contract step is to show reliable, governed retrieval scoped to the contract being reviewed.

This matters in production. A contract agent that searches every agreement can produce an impressive-looking but unreliable answer. A scoped agent gives Finance and Legal a result they can defend.

You may now **proceed to the next lab**.

## Acknowledgements

**Authors**

- Database Applied AI Technical Staff
- Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - June, 2026
