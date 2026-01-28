# Introduction

## About this Workshop

**If AI can't remember what it did yesterday, it can't run your business tomorrow.**

Most AI agents have amnesia. Every conversation starts fresh. They don't remember the customer they helped last week, the decision they made yesterday, or the policy they're supposed to follow. This works for demos. It fails completely in production.

This workshop shows how to build AI agents with **agentic memory**: agents that remember, learn, and improve over time. Using Oracle Database 26ai and Select AI Agent, you'll create agents that store facts, recall context, and make consistent decisions across sessions.

## Meet Seer Equity

Throughout this workshop, you'll build AI agents for **Seer Equity**, a growing financial services company specializing in personal, auto, mortgage, and business loans.

Seer Equity has been growing fast. Maybe too fast. Their loan officers are overwhelmed, and cracks are starting to show.

### The Problems Keeping Leadership Up at Night

**"We keep forgetting our best clients."**

Last month, a loan officer quoted standard rates to Sarah Chen, a client who's been with Seer Equity for six years and has a 15% rate exception on file. Sarah was not happy. She'd told three different loan officers about her preferences, and none of them remembered. How many other clients are getting this treatment?

**"Every loan officer handles the same situation differently."**

Two similar business loan applications came in last quarter. One got approved at preferred rates; the other got denied outright. Same loan amount, similar credit profiles, similar businesses. The only difference? Which loan officer happened to pick up the phone. There's no way to learn from past decisions or ensure consistency.

**"We have no idea what our AI assistants are actually doing."**

The company deployed AI chatbots to help loan officers, but they're black boxes. When a regulator asks "why was this loan approved?", nobody can answer. The chatbots don't log their reasoning, don't follow documented policies, and sometimes make up information about rates and requirements.

**"Small loans take as long to process as big ones."**

A $25,000 personal loan for a client with excellent credit shouldn't require the same scrutiny as a $500,000 mortgage. But without smart routing, everything goes through the same manual review process. Loan officers spend hours on applications that should take minutes.

**"We can't enforce separation of duties."**

Compliance requires that the person who submits a loan application can't be the same person who approves it. But their current systems don't enforce this. It's just policy that people are supposed to follow. One mistake away from a regulatory finding.

### How Agent Memory Solves These Problems

This workshop walks you through building AI agents that address each of Seer Equity's struggles:

| Business Problem | Agent Solution | You'll Build It In |
|------------------|----------------|---------------------|
| Forgetting client preferences | Persistent memory that survives sessions | Labs 5, 7, 9 |
| Inconsistent decisions | Past decision lookup for guidance | Labs 8, 9 |
| No audit trail | Automatic logging of every tool call | Labs 4, 10 |
| No access to policies | Enterprise data integration | Lab 6 |
| Manual processing of routine loans | Risk-based auto-approval rules | Labs 4, 10 |
| No separation of duties | Role-based agents with limited tools | Lab 10 |

By the end, you'll have a complete loan processing system where:

- **Clients are remembered**: Rate exceptions, contact preferences, and relationship history persist forever
- **Decisions are consistent**: Agents check what worked before in similar situations
- **Everything is auditable**: Every tool call is logged with inputs and outputs
- **Policies are followed**: Agents consult the actual corporate lending policies
- **Routine work is automated**: Low-risk loans auto-approve; complex ones get human review
- **Duties are separated**: Loan officers can submit but not approve; underwriters can approve but not submit

## Workshop Structure

✅ **Start with the basics (Labs 1-4)**

Before solving Seer Equity's problems, you need to understand how agents work:

* **Lab 1 – What is an AI Agent?** Build your first agent that queries loan application data. See the difference between a chatbot that *explains* how to check loan status versus an agent that *actually checks it*.

* **Lab 2 – Agents vs Zero-Shot** Compare three approaches: zero-shot (no data access), SELECT AI (read-only), and agents (read and write). Watch an agent check a loan's status and update it based on conditions.

* **Lab 3 – How Agents Plan** Give an agent a complex request about a loan applicant. Watch it plan which tools to call and in what order. See how explicit instructions create predictable behavior.

* **Lab 4 – How Agents Execute** Build Seer Equity's loan risk assessment workflow. Create tools that evaluate loan applications and route them based on amount and type. See conditional logic in action: auto-approve, underwriter review, or senior underwriter.

✅ **Build memory systems (Labs 5-9)**

Now you'll solve the "forgetting" problem that frustrates Seer Equity's clients:

* **Lab 5 – Experience the Forgetting Problem** Tell an agent about Sarah Chen's email preference and 15% rate exception. Clear the session. Ask again. *The agent has no idea who Sarah Chen is.* This is exactly what's happening to Seer Equity's clients.

* **Lab 6 – Connect Agents to Enterprise Data** Ask an agent about Seer Equity's loan rates. Without enterprise data, it gives generic answers. Connect it to the actual policy database and watch it quote real rates, requirements, and client-specific information.

* **Lab 7 – Build Your Memory Core** Create memory tables using Oracle's native JSON. Build `remember_fact` and `recall_facts` functions. Register them as agent tools. Now when you tell the agent about Sarah Chen, clear the session, and ask again, *the agent remembers*.

* **Lab 8 – Implement All Four Memory Types** Build the complete memory architecture:
  - **Short-term context**: What loan application are we working on right now?
  - **Long-term facts**: Client preferences, rate exceptions, relationship history
  - **Decisions and outcomes**: What did we decide before? What happened?
  - **Reference knowledge**: Corporate lending policies (human-maintained)

* **Lab 9 – The Learning Loop** Create a fully memory-enabled loan officer assistant. It checks memory before answering, stores new information automatically, consults past decisions for guidance, and looks up policies on demand. Test it across session boundaries. It remembers everything.

✅ **Control and safety (Lab 10)**

Finally, you'll build the guardrails that make agents safe for financial services:

* **Lab 10 – Tools, Safety, and Human Control** Build a two-agent system that enforces separation of duties:
  
  **LOAN_AGENT** (for loan officers):
  - Can submit loan applications
  - Cannot approve or deny anything
  - Literally doesn't have the approval tools
  
  **UNDERWRITING_AGENT** (for underwriters):
  - Can view pending applications
  - Can approve or deny
  - Cannot submit applications
  
  **Automatic Risk Assessment:**
  - Credit score below 550 → BLOCKED (application rejected)
  - Personal loans under $50K with good credit → AUTO_APPROVED
  - Loans $50K-$250K → Requires UNDERWRITER review
  - Loans over $250K or any mortgage → Requires SENIOR_UNDERWRITER
  
  **Complete Audit Trail:**
  - Every tool call logged with timestamp
  - Full input and output captured
  - Queryable for compliance review

## The Seer Equity Loan Workflow

Here's the complete workflow you'll build across the labs:

```
┌───────────────────────────────────────────────────────────────┐
│                  SEER EQUITY LOAN PROCESSING                  │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  CLIENT APPLIES                                               │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ LOAN AGENT (Loan Officer)                               │  │
│  │ • Recalls client history from memory                    │  │
│  │ • Looks up applicable rates and policies                │  │
│  │ • Submits application with risk assessment              │  │
│  │ • Stores new client information for next time           │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ RISK ASSESSMENT                                         │  │
│  │ • Credit < 550         → BLOCKED                        │  │
│  │ • Personal < $50K      → AUTO_APPROVE                   │  │
│  │ • $50K - $250K         → UNDERWRITER_REVIEW             │  │
│  │ • > $250K or Mortgage  → SENIOR_UNDERWRITER             │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ UNDERWRITING AGENT (if needed)                          │  │
│  │ • Reviews pending applications                          │  │
│  │ • Checks past decisions for similar situations          │  │
│  │ • Approves or denies with logged rationale              │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  DECISION RECORDED → AUDIT TRAIL COMPLETE                     │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  RATE TIERS                                                   │
│  • Preferred (750+ credit): 7.9% APR, up to $100K             │
│  • Standard (650-749):      12.9% APR, up to $50K             │
│  • Rate exceptions: Up to 15% discount for 5+ year clients    │
├───────────────────────────────────────────────────────────────┤
│  MEMORY ENABLES                                               │
│  • Client preferences persist across sessions                 │
│  • Rate exceptions are remembered and applied                 │
│  • Past decisions guide new ones                              │
│  • Every action is logged for compliance                      │
└───────────────────────────────────────────────────────────────┘
```

### Objectives

By the end of this workshop, you'll be able to:

* Understand how AI agents plan, execute, and coordinate tools
* Build memory systems using JSON and PL/SQL for persistent client knowledge
* Create tools that connect agents to loan data and policies
* Implement safety rules and human-in-the-loop approval workflows
* Query audit trails for compliance and debugging
* Design role-based agent systems with proper separation of duties

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

## Learn More

* [Oracle Database 26ai Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [AI Vector Search Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026
