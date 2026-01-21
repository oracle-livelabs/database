# Introduction

## About this Workshop

**What if your AI could actually do things instead of just explaining how?**

Most AI chatbots are helpful explainers. Ask about a loan status and they will tell you how to log into the portal, navigate to the right screen, and find the information yourself. Helpful, sure. But you wanted the status, not a tutorial.

AI agents are different. They act. Ask an agent about a loan status and it queries the database and tells you the answer. Same question, completely different outcome.

This workshop teaches you to build agents that execute instead of explain.

## Meet Seer Equity

Throughout this workshop, you will build AI agents for **Seer Equity**, a growing financial services company specializing in personal, auto, mortgage, and business loans.

Seer Equity deployed AI chatbots to help their loan officers. The reviews are mixed.

### The Problem That Started It All

> *"I asked the AI about my loan and it told me how to look it up. I know how to look it up! I wanted you to just tell me the status."*
>
> Frustrated Seer Equity Client

When a client calls asking about their loan application, they want an answer. They do not want a five-step tutorial on navigating the loan portal. But that is exactly what the chatbot gives them.

The loan officers are frustrated too. They spend time on calls walking clients through information they could have gotten instantly if the AI just queried the database.

Seer Equity needs AI that acts on their systems, not AI that explains their systems.

### What You Will Build

In Lab 1, you will build your first AI agent for Seer Equity. This agent will:

- Connect to the loan applications database
- Receive natural language questions about loan status
- Query the actual data and return real answers
- Log every action it takes for transparency

By the end, when someone asks "What is the status of loan application LOAN-12345?", the agent will tell them: "Approved, $45,000 personal loan for Alex Chen, submitted January 2nd." No tutorials. No explanations. Just the answer.

## What is Coming Next

Seer Equity has solved their first problem, but bigger challenges are waiting.

**The Forgetting Problem**

Next week, a loan officer will tell the AI about Sarah Chen's email preference and her 15% rate exception. The AI will acknowledge it. Then the session will end. The next day, a different loan officer will ask about Sarah Chen, and the AI will have no idea who she is. Clients hate repeating themselves. Seer Equity needs agents that remember.

**The Consistency Problem**

Two similar loan applications will come in next month. Same amount, similar credit profiles, similar businesses. One will get approved at preferred rates. The other will get denied. The only difference is which loan officer handled it. There is no way to learn from past decisions. Seer Equity needs agents that learn.

**The Compliance Problem**

A regulator will eventually ask: "Why was this loan approved?" Nobody will be able to answer. The AI does not log its reasoning. It does not follow documented policies. Sometimes it makes up information about rates. Seer Equity needs agents they can trust and audit.

**The Control Problem**

Compliance requires that the person who submits a loan cannot be the same person who approves it. But nothing enforces this. It is just policy. One mistake away from a finding. Seer Equity needs agents with boundaries.

We will solve all of these problems in future labs. This is Part 1 of an ongoing series following Seer Equity as they transform their AI from helpful explainers into trusted actors.

**Follow us on LinkedIn to catch new labs as they drop. Also check back into this workshop as we add more content.**

## This Workshop

This release includes:

- **Lab 1**: Build your first AI agent with a SQL tool that queries loan data

You will learn:

- The difference between chatbots (explain) and agents (act)
- The four components of an agent system: tools, agents, tasks, and teams
- How to create a SQL tool that connects to your data
- How to ask natural language questions and get real answers
- How to view execution history proving the agent took action

### Prerequisites

For this workshop, we provide the environment. You will need:

- Basic knowledge of SQL and PL/SQL, or the ability to follow along with the prompts

### Objectives

By the end of this workshop, you will be able to:

- Explain the difference between a chatbot and an agent
- Create database tables with comments that help Select AI understand your schema
- Build an agent with a SQL tool using Oracle Select AI Agent framework
- Query the agent using natural language and receive data-driven answers
- View execution history to see what the agent did

## Learn More

* [Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
* [`DBMS_CLOUD_AI_AGENT` Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)

## Acknowledgements

* **Author** - David Start
* **Last Updated By/Date** - David Start, January 2026
