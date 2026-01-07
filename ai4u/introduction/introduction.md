# Introduction

## About this Workshop

**If AI can't remember what it did yesterday, it can't run your business tomorrow.**

Most AI agents have amnesia. Every conversation starts fresh. They don't remember the customer they helped last week, the decision they made yesterday, or the policy they're supposed to follow. This works for demos. It fails completely in production.

This workshop shows how to build AI agents with **agentic memory**—agents that remember, learn, and improve over time. Using Oracle Database 23ai and Select AI Agent, you'll create agents that store facts, recall context, and make consistent decisions across sessions.

You'll see how agents move from stateless demos to production-ready systems—and you'll build the same capabilities yourself in the labs that follow.

✅ **Start with the basics! (Labs 1-4)**

Step into the world of AI agents. You'll discover:

* What makes an agent different from a simple prompt
* How agents plan multi-step tasks and coordinate tools
* Why agents need the observe-think-act execution loop
* The difference between zero-shot queries and agentic workflows

These labs build your mental model of how agents actually work before you start building memory systems.

✅ **Build memory systems (Labs 5-9)**

After understanding agents, you'll switch to building. In these labs you'll create the memory infrastructure that makes agents useful in production:

* **Lab 5 – Experience the forgetting problem**
Tell an agent something important, clear the session, and watch it forget everything.

* **Lab 6 – Connect agents to enterprise data**
See agents fail without business context, then succeed with access to policies and customer data.

* **Lab 7 – Build your memory core**
Create memory tables with native JSON, build remember and recall functions, and register them as agent tools.

* **Lab 8 – Implement all four memory types**
Build short-term context, long-term facts, decisions/outcomes, and reference knowledge—each serving a distinct purpose.

* **Lab 9 – Add semantic search**
Load an ONNX embedding model, add VECTOR columns, and enable agents to find relevant experience by meaning, not just keywords.

✅ **Control and safety (Lab 10)**

Finally, you'll build the guardrails that make agents trustworthy:

* Create PL/SQL functions as agent tools
* Build a JSON-based safety rules system
* Enable human-in-the-loop approval workflows
* Query the audit trail to see everything the agent did

By the end, you'll have a complete agent system—with memory, tools, rules, and human oversight—all running on Oracle Database 23ai.

### Objectives

* Understand how AI agents plan, execute, and coordinate tools
* Build memory systems using JSON, VECTOR, and PL/SQL
* Create tools that connect agents to your data and systems
* Implement safety rules and human-in-the-loop workflows
* Query audit trails for compliance and debugging

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account with access to Oracle Database 23ai
* Access to an AI provider (OCI Generative AI, OpenAI, etc.)
* Basic knowledge of SQL and PL/SQL

## Learn More

* [Oracle Database 23ai Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/)
* [DBMS_CLOUD_AI_AGENT Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [AI Vector Search Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026
