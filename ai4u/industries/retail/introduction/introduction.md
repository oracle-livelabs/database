# Introduction

## About this Workshop

**If your retail AI forgets the collector it helped yesterday, it will fail the flash drop tomorrow.**

Seer Equity’s Retail Intelligence division runs the returns, consignment, and authentication desks for partner marketplaces and in-store lounges. Manual handoffs, scattered spreadsheets, and chatbot pilots that “explain” instead of “act” are eroding SLA reliability and collector trust. This LiveLab shows you how to build governed, execution-first agents with **agentic memory** on Oracle Database 26ai so every interaction remembers loyalty perks, cites policies, and leaves an audit-ready trail.

## Meet Seer Equity Retail Intelligence

You will operate inside Seer Equity’s retail operations hub as it absorbs record submission volumes from online flash sales, sneaker drops, and high-end memorabilia consignments. Intake specialists, authenticators, and governance leads share the same Oracle Database 26ai foundation, yet the workflows still lag behind the demand.

### The Problems Keeping Leadership Up at Night

**“VIP collectors keep repeating their loyalty perks every call.”**

Alex Martinez, a platinum-tier collector, negotiated a 20 percent loyalty discount and email-only communication. Three different specialists captured the notes in spreadsheets that no agent can recall. Alex escalated the complaint directly to Priya Desai, Director of Retail Operations.

**“Identical submissions receive different grades and price guidance.”**

Two 1986 rookie cards arrived with similar provenance packets. One auto-listed within an hour; the other stalled for four days and exited with a lower valuation. Marcus Patel, Senior Authenticator, can’t trace which decision path applied where.

**“We can’t explain what the AI just did.”**

Governance lead David Huang piloted chatbots to answer status questions. When he asked, “Why did we list ITEM-79214 at $6,200?”, the bot replied with marketing copy and no provenance log. Compliance refused to expand the pilot.

**“Common items clog the same queues as grails.”**

A $180 store-exclusive bobblehead flows through the same manual review path as a championship ring. Without value-, rarity-, and condition-based routing, SLA breaches keep climbing.

**“Separation of duties exists only on paper.”**

Inventory specialists can both submit and authenticate items in the legacy tools. That violates Seer Equity’s governance policy and invites fraud during high-volume events.

### How Agent Memory Solves These Problems

This workshop upgrades Seer Equity’s operations with governed agents that remember, route, and record every action.

| Business Problem | Agent Solution | You’ll Build It In |
|------------------|----------------|--------------------|
| Forgotten loyalty perks | Persistent memory of collector entitlements | Labs 5, 7, 9 |
| Inconsistent grading | Precedent search for similar authentications | Labs 8, 9 |
| Missing provenance trail | Tool-level audit logging with rationale | Labs 4, 10 |
| No policy access | Enterprise pricing and policy integration | Lab 6 |
| Manual routing for routine items | Auto-listing based on value and condition | Labs 4, 10 |
| Weak separation of duties | Role-scoped agents and tool permissions | Lab 10 |

By the end you will orchestrate a retail workflow where:

- **Collectors feel remembered** – loyalty tiers, communication preferences, and negotiated perks persist across every session.
- **Authenticators sync decisions** – agents compare new submissions against precedent memories before grading.
- **Every action is auditable** – tool calls, inputs, outputs, and decisions land in governed logs Seer Equity can defend.
- **Policies stay authoritative** – recommendations cite real pricing clauses, provenance requirements, and resale thresholds.
- **Routine work accelerates** – low-risk items auto-list while scarce pieces escalate to experts with full context.
- **Governance holds** – intake and authentication duties remain separate with enforced tool and data boundaries.

## Workshop Structure

✅ **Build the foundations (Labs 1–4)**

Before solving the backlog, master agent execution, planning, and routing in Seer Equity’s retail schema.

- **Lab 1 – What Is an AI Agent?** Create an inventory lookup agent backed by `ITEM_SUBMISSIONS` so specialists answer status questions instantly.
- **Lab 2 – Agents vs Zero Shot** Contrast zero-shot prompts with governed agents updating `SAMPLE_ITEMS` under strict role controls.
- **Lab 3 – How Agents Plan** Assemble collector briefings that blend loyalty tiers, submission history, and policy reminders.
- **Lab 4 – How Agents Execute** Implement routing that writes to `ITEM_REQUESTS` and `ITEM_WORKFLOW_LOG`, proving three-tier automation.

✅ **Install durable memory (Labs 5–9)**

- **Lab 5 – Why Agents Need Memory** Capture Alex Martinez’s loyalty perks in `AGENT_MEMORY` so the system never forgets.
- **Lab 6 – Enterprise Data Integration** Ground price guidance in `PRICING_POLICIES`, `BS_CUSTOMERS`, and catalog metadata.
- **Lab 7 – Memory Core** Design JSON schemas for facts, tasks, and in-flight checkpoints across retail teams.
- **Lab 8 – Four Memory Types** Distinguish episodic, semantic, procedural, and reference memory aligned to retail cases.
- **Lab 9 – Learning Loop** Build vector precedents in `DECISION_MEMORY` so agents surface similar authentications.

✅ **Seal with governance (Lab 10)**

- **Lab 10 – Tools, Safety & Control** Enforce separation between `INVENTORY_AGENT` and `AUTHENTICATION_AGENT`, logging every decision for compliance.

## Objectives

By completing the retail edition, you will:

- Implement submission intake, valuation, routing, and provenance logging on Oracle Database 26ai.
- Persist collector preferences, loyalty offers, and authentication results as durable memory.
- Ground agent answers in pricing policies, authenticity standards, and resale guidelines.
- Produce an auditable trail for every agent action with human escalation hooks.
- Coordinate multi-agent teams where tools, tasks, and governance boundaries remain explicit.

## Prerequisites

Everything runs inside the provided Autonomous Database tenancy. You should be comfortable following SQL, PL/SQL, and notebook-driven instructions.

## Learn More

- [Oracle Database 26ai Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
- [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
- [AI Vector Search Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)

## Workshop Plan (Generated)
- Refresh story framing so Seer Equity Retail Intelligence oversees high-velocity returns and consignments with Oracle Database 26ai.
- Spotlight Priya Desai, Alex Martinez, Jennifer Lee, Marcus Patel, and David Huang across problem statements and quotes.
- Recast business problem table around VIP memory, grading parity, provenance logging, autonomous routing, and separation of duties.
- Map Auto-List, Standard Appraisal, and Expert Appraisal into the workshop impact narrative and visuals.
- Tie success metrics to reduced SLA time, fraud mitigation, and auditable policy citations for Seer Equity leadership.
