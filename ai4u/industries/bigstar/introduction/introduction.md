# Introduction

## About this Workshop

**If AI can't remember what it did yesterday, it can't run your business tomorrow.**

Most AI agents have amnesia. Every conversation starts fresh. They don't remember the customer they helped last week, the decision they made yesterday, or the pricing guide they're supposed to follow. This works for demos. It fails completely in production.

This workshop shows how to build AI agents with **agentic memory**: agents that remember, learn, and improve over time. Using Oracle Database 26ai and Select AI Agent, you'll create agents that store facts, recall context, and make consistent decisions across sessions.

## Meet Big Star Collectibles

Throughout this workshop, you will build AI agents for **Big Star Collectibles**, a growing retail business specializing in sports cards, vintage comics, rare toys, and sports memorabilia.

Big Star Collectibles has been growing fast. Maybe too fast. Their inventory specialists are overwhelmed, and cracks are starting to show.

### The Problems Keeping Leadership Up at Night

**"We keep forgetting our VIP collectors."**

Last month, an inventory specialist quoted standard pricing to Alex Martinez, a collector who's been with Big Star Collectibles for six years and has a 20% loyalty discount on file. Alex was not happy. They'd told three different specialists about their preferences, and none of them remembered. How many other VIP collectors are getting this treatment?

**"Every appraiser values items differently."**

Two similar vintage comic books came in last quarter. One got graded 9.2 and listed at $1,200; the other got graded 8.0 and listed at $600. Same condition, similar provenance, similar rarity. The only difference? Which appraiser happened to evaluate it. There's no way to learn from past appraisals or ensure consistency.

**"We have no idea what our AI assistants are actually doing."**

The company deployed AI chatbots to help inventory specialists, but they're black boxes. When a customer asks "why was this graded 8.5?", nobody can answer. The chatbots don't log their reasoning, don't follow documented grading standards, and sometimes make up information about values and rarity.

**"Common items take as long to process as rare ones."**

A $50 recent sports card shouldn't require the same scrutiny as a $5,000 vintage comic. But without smart routing, everything goes through the same manual authentication process. Inventory specialists spend hours on submissions that should take minutes.

**"We can't enforce authentication workflows."**

Compliance requires that the person who submits an item for authentication can't be the same person who grades and prices it. But their current systems don't enforce this. It's just policy that people are supposed to follow. One mistake away from a provenance disaster.

### How Agent Memory Solves These Problems

This workshop walks you through building AI agents that address each of Big Star Collectibles' struggles:

| Business Problem | Agent Solution | You'll Build It In |
|------------------|----------------|---------------------|
| Forgetting collector preferences | Persistent memory that survives sessions | Labs 5, 7, 9 |
| Inconsistent appraisals | Past decision lookup for guidance | Labs 8, 9 |
| No audit trail | Automatic logging of every tool call | Labs 4, 10 |
| No access to pricing guides | Enterprise data integration | Lab 6 |
| Manual processing of routine items | Rarity-based auto-listing rules | Labs 4, 10 |
| No workflow enforcement | Role-based agents with limited tools | Lab 10 |

By the end, you'll have a complete item authentication system where:

- **Collectors are remembered**: Loyalty discounts, contact preferences, and collection history persist forever
- **Decisions are consistent**: Agents check what worked before in similar appraisals
- **Everything is auditable**: Every tool call is logged with inputs and outputs
- **Pricing guides are followed**: Agents consult the actual corporate grading standards
- **Routine work is automated**: Low-value common items auto-list; rare ones get expert review
- **Workflows are enforced**: Inventory specialists can submit but not grade; authenticators can grade but not submit

## Workshop Structure

✅ **Start with the basics (Labs 1-4)**

Before solving Big Star Collectibles' problems, you need to understand how agents work:

* **Lab 1 – What is an AI Agent?** Build your first agent that queries item submission data. See the difference between a chatbot that *explains* how to check item status versus an agent that *actually checks it*.

* **Lab 2 – Agents vs Zero-Shot** Compare three approaches: zero-shot (no data access), SELECT AI (read-only), and agents (read and write). Watch an agent check an item's status and update it based on conditions.

* **Lab 3 – How Agents Plan** Give an agent a complex request about a customer. Watch it plan which tools to call and in what order. See how explicit instructions create predictable behavior.

* **Lab 4 – How Agents Execute** Build Big Star Collectibles' item appraisal workflow. Create tools that evaluate submissions and route them based on value and rarity. See conditional logic in action: auto-list, standard appraisal, or expert appraisal.

✅ **Build memory systems (Labs 5-9)**

Now you'll solve the "forgetting" problem that frustrates Big Star Collectibles' VIP collectors:

* **Lab 5 – Experience the Forgetting Problem** Tell an agent about Alex Martinez's email preference and 20% loyalty discount. Clear the session. Ask again. *The agent has no idea who Alex Martinez is.* This is exactly what's happening to Big Star's VIP collectors.

* **Lab 6 – Connect Agents to Enterprise Data** Ask an agent about Big Star Collectibles' pricing tiers. Without enterprise data, it gives generic answers. Connect it to the actual pricing database and watch it quote real values, grading standards, and customer-specific information.

* **Lab 7 – Build Your Memory Core** Create memory tables using Oracle's native JSON. Build `remember_fact` and `recall_facts` functions. Register them as agent tools. Now when you tell the agent about Alex Martinez, clear the session, and ask again, *the agent remembers*.

* **Lab 8 – Implement All Four Memory Types** Build the complete memory architecture:
  - **Short-term context**: What item submission are we working on right now?
  - **Long-term facts**: Collector preferences, loyalty discounts, collection history
  - **Decisions and outcomes**: What did we grade before? What happened?
  - **Reference knowledge**: Corporate grading standards (human-maintained)

* **Lab 9 – The Learning Loop** Create a fully memory-enabled inventory assistant. It checks memory before answering, stores new information automatically, consults past appraisals for guidance, and looks up pricing guides on demand. Test it across session boundaries. It remembers everything.

✅ **Control and safety (Lab 10)**

Finally, you'll build the guardrails that make agents safe for retail collectibles:

* **Lab 10 – Tools, Safety, and Human Control** Build a two-agent system that enforces workflow separation:

  **INVENTORY_AGENT** (for inventory specialists):
  - Can submit item submissions
  - Cannot authenticate or price anything
  - Literally doesn't have the grading tools

  **AUTHENTICATION_AGENT** (for authenticators):
  - Can view pending submissions
  - Can authenticate and price
  - Cannot submit items

  **Automatic Rarity Assessment:**
  - Condition grade below 3.0 → REJECTED (item damaged)
  - Common items under $500 with good condition → AUTO_LISTED
  - Items $500-$5K → Requires STANDARD_APPRAISAL
  - Items over $5K or rare collectibles → Requires EXPERT_APPRAISAL

  **Complete Audit Trail:**
  - Every tool call logged with timestamp
  - Full input and output captured
  - Queryable for provenance verification

## The Big Star Collectibles Item Workflow

Here's the complete workflow you'll build across the labs:

```
┌───────────────────────────────────────────────────────────────┐
│              BIG STAR COLLECTIBLES ITEM PROCESSING            │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  CUSTOMER SUBMITS ITEM                                        │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ INVENTORY AGENT (Inventory Specialist)                  │  │
│  │ • Recalls customer history from memory                  │  │
│  │ • Looks up applicable pricing tiers and grading guides  │  │
│  │ • Submits item with rarity assessment                   │  │
│  │ • Stores new customer information for next time         │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ RARITY ASSESSMENT                                       │  │
│  │ • Condition < 3.0      → REJECTED                       │  │
│  │ • Common < $500        → AUTO_LIST                      │  │
│  │ • $500 - $5K           → STANDARD_APPRAISAL             │  │
│  │ • > $5K or Rare        → EXPERT_APPRAISAL               │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ AUTHENTICATION AGENT (if needed)                        │  │
│  │ • Reviews pending submissions                           │  │
│  │ • Checks past appraisals for similar items              │  │
│  │ • Authenticates and prices with logged rationale        │  │
│  └─────────────────────────────────────────────────────────┘  │
│       ↓                                                       │
│  DECISION RECORDED → AUDIT TRAIL COMPLETE                     │
│                                                               │
├───────────────────────────────────────────────────────────────┤
│  PRICING TIERS                                                │
│  • Platinum (750+ loyalty points): 20% discount               │
│  • Gold (500-749 loyalty points): 10% discount                │
│  • Silver (250-499 loyalty points): 5% discount               │
│  • Standard (< 250 loyalty points): No discount               │
├───────────────────────────────────────────────────────────────┤
│  MEMORY ENABLES                                               │
│  • Customer preferences persist across sessions               │
│  • Loyalty discounts are remembered and applied               │
│  • Past appraisals guide new ones                             │
│  • Every action is logged for provenance                      │
└───────────────────────────────────────────────────────────────┘
```

### Objectives

By the end of this workshop, you'll be able to:

* Understand how AI agents plan, execute, and coordinate tools
* Build memory systems using JSON and PL/SQL for persistent customer knowledge
* Create tools that connect agents to item data and pricing guides
* Implement safety rules and human-in-the-loop authentication workflows
* Query audit trails for provenance and debugging
* Design role-based agent systems with proper workflow separation

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
