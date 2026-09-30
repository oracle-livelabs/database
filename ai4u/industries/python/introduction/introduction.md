# Introduction

## About this Workshop

**If AI can't remember what it did yesterday, it can't run your business tomorrow.**

Most AI agents have amnesia. Every conversation starts fresh. They don't remember the customer they helped last week, the decision they made yesterday, or the pricing guide they're supposed to follow. This works for demos. It fails completely in production.

This workshop shows how to build AI agents with **agentic memory** using **Python**, **LangChain**, and **Oracle Database 26ai** as the memory substrate. Unlike the Select AI edition of this workshop (which runs entirely inside the database), this edition builds agents in Python that can be deployed **anywhere** — on your laptop, in a container, on any cloud — while Oracle 26ai handles the hard part: memory that's concurrent, semantic, and auditable.

No Select AI. No `DBMS_CLOUD_AI_AGENT`. Pure Python + LangChain + Oracle as the memory substrate.

## Meet Seer Equity

Throughout this workshop, you will build AI agents for **Seer Equity**, a fictional financial services company offering personal, auto, mortgage, and business loans.

Seer Equity has been growing fast. Maybe too fast. Their loan officers are overwhelmed, and cracks are starting to show.

### The Problems Keeping Leadership Up at Night

**"We keep forgetting our best clients."**

Last month, a loan officer quoted standard rates to Sarah Chen, a client who's been with Seer Equity for six years and has a 15% rate exception on file. Sarah was not happy. She'd told three different loan officers about her preferences, and none of them remembered. How many other long-term clients are getting this treatment?

**"Every loan officer makes different decisions."**

Two similar personal loan applications came in last quarter. One got approved at 7.9% APR; the other got quoted 12.9% for the same credit profile. The only difference? Which loan officer happened to review it. There's no way to learn from past decisions or ensure consistency.

**"We have no idea what our AI assistants are actually doing."**

The company deployed AI chatbots to help loan officers, but they're black boxes. When a client asks "why was my rate set to 9.9%?", nobody can answer. The chatbots don't log their reasoning, don't follow documented lending policies, and sometimes make up information about rates and requirements.

**"Small loans take as long to process as large ones."**

A $25,000 personal loan for a client with 780 credit shouldn't require the same scrutiny as a $450,000 mortgage. But without smart routing, everything goes through the same manual underwriting process. Loan officers spend hours on applications that should take minutes.

**"We can't enforce separation of duties."**

Compliance requires that the person who submits a loan application can't be the same person who approves it. But their current systems don't enforce this. It's just policy that people are supposed to follow. One mistake away from a regulatory disaster.

### How Agent Memory Solves These Problems

This workshop walks you through building AI agents that address each of Seer Equity's struggles:

| Business Problem | Agent Solution | You'll Build It In |
|------------------|----------------|---------------------|
| Forgetting client preferences | Persistent memory that survives sessions | Labs 5, 7, 9 |
| Inconsistent decisions | Past decision lookup for guidance | Labs 8, 9 |
| No audit trail | Automatic logging of every tool call | Labs 4, 10 |
| No access to lending policies | Enterprise data integration | Lab 6 |
| Manual processing of routine loans | Risk-based auto-approval rules | Labs 4, 10 |
| No workflow enforcement | Role-based agents with limited tools | Lab 10 |

By the end, you'll have a complete loan processing system where:

- **Clients are remembered**: Rate exceptions, contact preferences, and relationship history persist forever
- **Decisions are consistent**: Agents check what worked before in similar situations
- **Everything is auditable**: Every tool call is logged with inputs and outputs
- **Lending policies are followed**: Agents consult the actual corporate rate tables
- **Routine work is automated**: Low-risk personal loans auto-approve; large loans get underwriter review
- **Workflows are enforced**: Loan officers can submit but not approve; underwriters can approve but not submit

## The Technology Stack

This workshop uses Python and LangChain as the agent framework, with Oracle Database 26ai as the memory substrate:

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Agent Framework** | LangChain + LangGraph | Agent loop, tool calling, ReAct reasoning |
| **LLM Provider** | OpenAI (GPT-4o-mini) | Reasoning and generation |
| **Database Driver** | python-oracledb | Direct SQL operations against Oracle 26ai |
| **Vector Store** | langchain-oracledb (OracleVS) | Semantic memory with HNSW indexes |
| **Embeddings** | sentence-transformers | Vector embeddings for semantic search |
| **Notebook** | Jupyter | Interactive lab delivery |

> **Why this stack?** The agent loop (Python/LangChain) is stateless and disposable — you can restart it, scale it horizontally, or swap the framework. The memory substrate (Oracle 26ai) is durable and shared — it survives restarts, handles concurrency, and provides the guarantees that production systems need.

## Workshop Structure

✅ **Start with the basics (Labs 1-4)**

Before solving Seer Equity's problems, you need to understand how agents work:

* **Lab 1 – What Is an AI Agent?** Build your first LangChain agent that queries loan data in Oracle. See the difference between a chatbot that *explains* how to check loan status versus an agent that *actually checks it*.

* **Lab 2 – Agents vs Zero-Shot** Compare three approaches: zero-shot (no data access), LLM with read-only tools, and a full agent (read and write). Watch an agent check a loan's status and update it based on conditions.

* **Lab 3 – How Agents Plan** Give an agent a complex request about an applicant. Watch it plan which tools to call and in what order. See how explicit instructions create predictable behavior.

* **Lab 4 – How Agents Execute** Build Seer Equity's loan processing workflow in Python. Create tools that assess risk and route applications based on credit score and loan amount. See conditional logic in action: auto-approve, underwriter review, or senior review.

✅ **Build memory systems (Labs 5-9)**

Now you'll solve the "forgetting" problem that frustrates Seer Equity's long-term clients:

* **Lab 5 – Experience the Forgetting Problem** Tell an agent about Sarah Chen's email preference and 15% rate exception. Start a new agent instance. Ask again. *The agent has no idea who Sarah Chen is.* This is exactly what's happening to Seer Equity's clients.

* **Lab 6 – Connect to Enterprise Data** Show that a generic LLM doesn't know Seer Equity's rates. Connect the agent to policy tables and applicant data in Oracle so it gives correct answers instead of hallucinating.

* **Lab 7 – Build the Memory Core** Create a persistent memory system using Oracle's native JSON type. Build `remember_fact` and `recall_facts` tools. Prove that memory survives across agent restarts.

* **Lab 8 – Four Types of Memory** Not all memory is the same. Build short-term context (expires), long-term facts (forever), decision history (what happened and why), and reference knowledge (human-maintained policies).

* **Lab 9 – Semantic Search** Keyword search breaks when people use different words for the same thing. Build vector embeddings with `sentence-transformers` and HNSW indexes in Oracle. Search "late payment" and find "overdue installment" — because they mean the same thing.

✅ **Control and safety (Lab 10)**

* **Lab 10 – Separation of Duties** Build two agents with different tool sets: a loan officer agent that can submit but not approve, and an underwriter agent that can approve but not submit. This is security through architecture, not just prompts.

### Objectives

* Build AI agents in Python using LangChain and Oracle 26ai
* Understand agent fundamentals: tools, planning, execution
* Create persistent memory systems using Oracle's JSON and VECTOR types
* Implement semantic search with vector embeddings and HNSW indexes
* Enforce safety controls through role-based tool access

### Prerequisites

* Basic knowledge of Python
* Basic knowledge of SQL (or the ability to follow along)
* No prior experience with LangChain required

## Learn More

* [LangChain Documentation](https://python.langchain.com/docs/introduction/)
* [python-oracledb Documentation](https://python-oracledb.readthedocs.io/)
* [langchain-oracledb Package](https://pypi.org/project/langchain-oracledb/)
* [Oracle Database 26ai Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [Richmond Alake: Choosing the Right Memory Substrate for AI Agents](https://medium.com/@richmondalake)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, February 2026
