# Build Your Own AI Staff

## Introduction

Repeat work often starts with a vague request and ends with a person checking every detail. This workshop turns one safe, repeat task into a small team of role-based AI helpers.

You will define a focused GPT task, build three agent roles, propose one memory item, and map the prototype to an OCI production path. You will keep the owner in control of facts, approvals, private information, and actions outside the chat.

The core path uses ChatGPT and fictional or approved practice information. Custom GPT creation is optional. A regular chat or Project chat can support the same learning pattern.

### Key Terms

| Term | Meaning in this workshop |
| --- | --- |
| GPT | A family of generative language models. In ChatGPT, a custom GPT is a configured version with instructions and optional capabilities for a focused purpose. |
| Agent | A software system or role-based helper that uses a model to pursue a goal through steps, context, and possibly tools. In this workshop, role chats simulate agents and have no system access. |
| Tool | A function or API an agent can call. The workshop roles use no outside tools. |
| Handoff | A structured packet that tells the next role the known facts, needed information, and owner decision. |
| Context window | Temporary input available to a model for a request or conversation. It is not the same as durable memory. |
| Memory | Selected information retained beyond the current request. Useful memory has an owner, source, purpose, scope, sensitivity, and review decision. |
| Guardrail | A rule that says what a helper may do, must ask before doing, or must stop doing. |
| OCI | Oracle Cloud Infrastructure, the Oracle cloud platform. OCI Identity and Access Management (IAM) controls access to OCI resources through identities, groups, compartments, and policies. |
| Oracle AI Database | An Oracle database with AI features such as vector data types and AI Vector Search. It can store vector embeddings with business data and retrieve content by semantic similarity. |
| Oracle AI Agent Memory | A persistent memory component for enterprise AI agents, built on Oracle AI Database. An application still controls what it stores, who can retrieve it, and how long it remains. |

ChatGPT chats, custom GPTs, and the role chats in this workshop form an educational prototype. They are not OCI agents and they are not Oracle AI Agent Memory. A production design needs governed storage, access controls, retention rules, and reviewable ownership.

### Objectives

- Define one repeat task for a focused GPT.
- Build a small team of three role-based agents.
- Use a visible handoff and an owner approval step.
- Propose a small, sourced memory item without saving it automatically.
- Explain the conceptual path from a ChatGPT prototype to OCI IAM, Oracle AI Database, and Oracle AI Agent Memory.

Estimated Workshop Time: **45 minutes**

### Workshop Journey

| Section | Time | Outcome |
| --- | ---: | --- |
| Get Started | 3 minutes | Safe workspace and practice information. |
| Lab 1: Define a Focused GPT Task | 7 minutes | Task Brief with a clear result and boundary. |
| Lab 2: Build the Agent Team | 12 minutes | Maya, Nova, and Tessa role instructions. |
| Lab 3: Add Memory and Plan the OCI Path | 10 minutes | Memory proposal and production map. |
| Lab 4: Run, Review, and Quiz | 13 minutes | Tested handoff chain and completion check. |

## Start the Workshop

Continue to [Get Started](../getting-started/getting-started.md). Then complete the four numbered labs in order.

## Acknowledgements

* **Product resources** - [Oracle AI Database](https://www.oracle.com/database/), [Oracle AI Vector Search](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/overview-ai-vector-search.html), [Oracle AI Agent Memory](https://docs.oracle.com/en/database/agent-memory/), and [Oracle LiveLabs](https://livelabs.oracle.com/).
