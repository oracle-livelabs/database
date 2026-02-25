# Introduction

## About this Workshop

Estimated Workshop Time: 90 minutes

**If AI can't remember what it did yesterday, it can't run your business tomorrow.**

Most AI agents have amnesia. Every conversation starts fresh. They don't remember the customer they helped last week, the decision they made yesterday, or the policy they're supposed to follow. This works for demos. It fails completely in production.

This workshop shows how to build AI agents with **agentic memory**: agents that remember, learn, and improve over time. Using Oracle Database 26ai and Select AI Agent, you'll create agents that store facts, recall context, and make consistent decisions across sessions.

## Meet Big Star Collectibles

Throughout this workshop, you will build AI agents for **Big Star Collectibles**, a growing collectibles retailer known for authenticated sports memorabilia, vintage comics, limited-edition sneakers, and VIP resale collections.

Big Star Collectibles has been growing fast. Maybe too fast. Their warehouse intake specialists are buried under VIP return backlogs, authentication queues, and loyalty escalations.

### The Problems Keeping Leadership Up at Night

**"We keep forgetting our best clients."**

Last month, Marcus Reed promised platinum collector Alex Martinez a 20% loyalty discount on every authenticated drop, yet the next specialist quoted full price. Alex had emailed Marcus, Priya, and Jennifer in Chapter 1.1 of the story, but without memory the team forgot the promise. How many other VIPs are slipping through?

**"Every inventory specialist handles the same situation differently."**

Two nearly identical submissions hit the queue in the Chapter 1.2 warehouse scene: a signed baseball card and a limited-edition vinyl record. One was auto-listed, the other sat in limbo because the on-call specialist couldn't see prior grading results. Without shared precedent, Big Star delivers inconsistent experiences.

**"We have no idea what our AI assistants are actually doing."**

The company deployed AI chatbots to help the warehouse team, but Priya Desai still can't answer auditors when they ask “who approved Alex's refund and why?” The bots don't log reasoning, cite pricing guides, or show the provenance packets Jennifer Morales assembled in Chapter 3.2.

**"Small items take as long to process as big ones."**

A $350 common drop shouldn't take the same path as a $7,800 rookie card. Without the grading-tier routing Marcus describes in Chapter 2.1, everything flows through manual appraisal and the loyalty queue explodes.

**"We can't enforce separation of duties."**

Compliance requires Marcus' intake team to pass anything over $5,000 to Priya for expert appraisal sign-off, yet today the separation lives in sticky notes. One mistake puts the Big Star pilot at risk.

### How Agent Memory Solves These Problems

This workshop walks you through building AI agents that address each of Big Star Collectibles' struggles:

| Business Problem | Agent Solution | You'll Build It In |
|------------------|----------------|---------------------|
| Forgetting VIP collector preferences | Persistent memory that survives sessions | Labs 5, 7, 9 |
| Inconsistent decisions | Past decision lookup for guidance | Labs 8, 9 |
| No audit trail | Automatic logging of every tool call | Labs 4, 10 |
| No access to policies | Enterprise data integration | Lab 6 |
| Manual processing of routine items | Rarity-based auto-listing rules | Labs 4, 10 |
| No separation of duties | Role-based agents with limited tools | Lab 10 |

By the end, you'll have a complete item processing system where:

- **Clients are remembered**: Loyalty discounts, grading preferences, and provenance history persist forever
- **Decisions are consistent**: Agents check what worked before for Alex, Jennifer, and other collectors in similar situations
- **Everything is auditable**: Every tool call is logged with inputs and outputs
- **Policies are followed**: Agents consult the actual corporate collectibles policies
- **Routine work is automated**: Low-risk items auto-approve; complex ones get human review
- **Duties are separated**: Inventory specialists like Marcus can submit but not approve; appraisers like Priya can approve but not submit

## Story Sync
- Chapters 1.1–1.2 introduce Marcus Reed, Alex Martinez, and the warehouse backlog resolved in Labs 1–4.
- Chapters 2.1–2.4 map to Labs 5–8, covering loyalty memory, provenance packets, and grading tiers.
- Chapters 3.2–4.2 highlight Priya Desai and Jennifer Morales as governance leads reviewed in Labs 9–10.

## Workshop Structure

✅ **Start with the basics (Labs 1-4)**

Before solving Big Star Collectibles' problems, you need to understand how agents work:

* **Lab 1 – What is an AI Agent?** Build your first agent that queries item submission data. See the difference between a chatbot that *explains* how to check item status versus an agent that *actually checks it*.

* **Lab 2 – Agents vs Zero-Shot** Compare three approaches: zero-shot (no data access), SELECT AI (read-only), and agents (read and write). Watch an agent check a item's status and update it based on conditions.

* **Lab 3 – How Agents Plan** Give an agent a complex request about a item collector. Watch it plan which tools to call and in what order. See how explicit instructions create predictable behavior.

* **Lab 4 – How Agents Execute** Build Big Star Collectibles' item risk assessment workflow. Create tools that evaluate item submissions and route them based on amount and type. See conditional logic in action: auto-approve, appraiser review, or senior appraiser.

✅ **Build memory systems (Labs 5-9)**

Now you'll solve the "forgetting" problem that frustrates Big Star Collectibles' clients:

* **Lab 5 – Experience the Forgetting Problem** Tell an agent about Alex Martinez's email preference and 15% loyalty discount. Clear the session. Ask again. *The agent has no idea who Alex Martinez is.* This is exactly what's happening to Big Star Collectibles' clients.

* **Lab 6 – Connect Agents to Enterprise Data** Ask an agent about Big Star Collectibles' loyalty pricing. Without enterprise data, it gives generic answers. Connect it to the actual policy database and watch it quote real rates, requirements, and client-specific information.

* **Lab 7 – Build Your Memory Core** Create memory tables using Oracle's native JSON. Build `remember_fact` and `recall_facts` functions. Register them as agent tools. Now when you tell the agent about Alex Martinez, clear the session, and ask again, *the agent remembers*.

* **Lab 8 – Implement All Four Memory Types** Build the complete memory architecture:
  - **Short-term context**: What item submission are we working on right now?
  - **Long-term facts**: Client preferences, loyalty discounts, relationship history
  - **Decisions and outcomes**: What did we decide before? What happened?
  - **Reference knowledge**: Corporate collectibles policies (human-maintained)

* **Lab 9 – The Learning Loop** Create a fully memory-enabled inventory specialist assistant. It checks memory before answering, stores new information automatically, consults past decisions for guidance, and looks up policies on demand. Test it across session boundaries. It remembers everything.

✅ **Control and safety (Lab 10)**

Finally, you'll build the guardrails that make agents safe for collectibles retail:

* **Lab 10 – Tools, Safety, and Human Control** Build a two-agent system that enforces separation of duties:
  
  **INVENTORY_AGENT** (for inventory specialists):
  - Can submit item submissions
  - Cannot approve or deny anything
  - Literally doesn't have the approval tools
  
  **APPRAISAL_AGENT** (for appraisers):
  - Can view pending submissions
  - Can approve or deny
  - Cannot submit submissions
  
  **Automatic Risk Assessment:**
  - Condition grade below 550 → BLOCKED (submission rejected)
  - Personal items under $50K with good credit → AUTO_APPROVED
  - Items $50K-$250K → Requires APPRAISER review
  - Items over $250K or any authenticating → Requires SENIOR_APPRAISER
  
  **Complete Audit Trail:**
  - Every tool call logged with timestamp
  - Full input and output captured
  - Queryable for compliance review

## The Big Star Collectibles Item Workflow

Here's the complete workflow you'll build across the labs:

```
┌───────────────────────────────────────────────────────────────┐
│               BIG STAR COLLECTIBLES AUTHENTICATION            │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  COLLECTOR SUBMITS ITEM                                       │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ INVENTORY AGENT (Marcus Reed)                           │  │
│  │ • Recalls VIP history from memory                       │  │
│  │ • Looks up loyalty pricing and grading policies         │  │
│  │ • Submits appraisal packet with rarity assessment       │  │
│  │ • Stores new collector information for next time        │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ RARITY ROUTING                                          │  │
│  │ • Condition < 3        → SECURITY HOLD                  │  │
│  │ • Value < $500         → AUTO-LIST                      │  │
│  │ • $500 – $5K           → STANDARD APPRAISAL             │  │
│  │ • > $5K or Limited     → EXPERT APPRAISAL               │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ APPRAISAL AGENT (Priya Desai & Jennifer Morales)        │  │
│  │ • Reviews pending submissions                           │  │
│  │ • Checks past decisions for similar situations          │  │
│  │ • Approves or denies with logged rationale              │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  DECISION RECORDED → AUDIT TRAIL COMPLETE                     │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  TIER HIGHLIGHTS                                             │
│  • Auto-List: Common items, pristine condition               │
│  • Standard Appraisal: Mid-tier collectibles                │
│  • Expert Appraisal: High-value or suspect items            │
│  • Security Hold: Counterfeits or damaged arrivals          │
├───────────────────────────────────────────────────────────────┤
│  MEMORY ENABLES                                               │
│  • Collector preferences persist across sessions             │
│  • Loyalty discounts are remembered and applied              │
│  • Past decisions guide new ones                             │
│  • Every action is logged for compliance                     │
└───────────────────────────────────────────────────────────────┘
```

### Objectives

By the end of this workshop, you'll be able to:

* Understand how AI agents plan, execute, and coordinate tools
* Build memory systems using JSON and PL/SQL for persistent client knowledge
* Create tools that connect agents to submission data and policies
* Implement safety rules and human-in-the-loop approval workflows
* Query audit trails for compliance and debugging
* Design role-based agent systems with proper separation of duties

### Prerequisites

For this workshop, we provide the environment. You'll need:

* Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

## Story Sync
- Chapters 1.1–1.2 introduce Marcus Reed, Alex Martinez, and the return backlog you'll resolve in Labs 1–4.
- Chapters 2.1–2.4 map directly to Labs 5–8, where you capture loyalty perks, provenance packets, and memory types.
- Chapters 3.1–3.4 and 4.2 inform Labs 9–10, highlighting Priya Desai and Jennifer Morales as governance leads reviewing every high-value decision.

## Learn More

* [Oracle Database 26ai Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [AI Vector Search Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - Kay Malcolm, February 2026
