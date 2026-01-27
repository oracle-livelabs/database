# Introduction to the Private Agent Factory

Welcome to the first lab of this 10-part workshop series. In this introductory session, you will gain a foundational understanding of the **Oracle AI Database 26ai Private Agent Factory** and how it enables enterprises to transform their data into autonomous action.

### Objectives
Throughout this workshop we will cover the following. Users are encouraged to skip around to the workshops most pertinent to them.

1.   Introducing the Private Agent Factory
2.1.       Installing the Private Agent Factory from the OCI Marketplace
2.2.       Installing the Private Agent Factory from source
3.   Logging in to the Private Agent Factory
4.   Pre-Built Agents
5.   Agents Built from Custom Templates
6.   Agent Builder: Build Agents From Scratch
7.   Multi-Agent Systems in the Private Agent Factory
8.   Deploy Agents from the Private Agent Factory
9.   Adding data sources to Private Agent Factory
10.   Evaluation Using the Prompt Lab 

### Prerequisites
There are no prerequisites. 
An OCI tenancy is necessary for **Installing the Private Agent Factory from the OCI Marketplace**. If users do not have a tenancy, they are instead encouraged to follow **Installing the Private Agent Factory from source**. The rest of the workshop will be the same whether the Agent Factory is installed on OCI or not.

## 1. The Big Picture: From AI to Agentic AI
To understand the Private Agent Factory, we must first look at the broader landscape of artificial intelligence. The evolution of AI moves through several distinct phases:

*   **AI & ML:** Turning raw data into actionable decisions through supervised and unsupervised learning.
*   **Deep Learning:** Utilizing multi-layered neural networks for complex tasks like image and video generation.
*   **Generative AI:** Generating content and code at scale using Large Language Models (LLMs) and Retrieval-Augmented Generation (RAG).
*   **AI Agents:** Executing complex tasks autonomously using tool orchestration and context management.
*   **Agentic AI:** The final frontier where systems automate entire processes through long-term autonomy, multi-agent collaboration, and self-reflection.

The Private Agent Factory is your gateway to this final stage, allowing you to build "Agentic Flows" that just work.

## 2. What is the Private Agent Factory?
The **Private Agent Factory** is a **no-code platform** designed to help enterprises rapidly build and deploy intelligent AI agents. It is built on the fundamental principle that **an agent is only as powerful as the data it can access and the actions it can take.** 

Unlike disparate database strategies that focus on complex integration, the Factory utilizes a **converged AI Database architecture**. This allows developers and IT teams to focus on **innovation** rather than plumbing, as data and AI services exist within the same secure ecosystem.

## 3. The S3P3 Framework
To ensure these agents are enterprise-grade, the Private Agent Factory follows the **S3P3 Framework**:

*   **Simplicity:** Features a converged architecture and a drag-and-drop, no-code **Agent Builder**.
*   **Safety:** Includes built-in guardrails and agent evaluation tools to mitigate hallucinations.
*   **Security:** Maintains existing data security with **Role-Based Access Control (RBAC)**.
*   **Portability:** Uses the **Open Agent Spec**, allowing you to import or export agents across OCI, Azure, AWS, and GCP.
*   **Performance:** Leverages **Vector AI Search** and in-database execution for maximum speed.
*   **Privacy:** Offers **air-gapped options** for data, LLMs, and agents to ensure your proprietary information never leaves your control.

## 4. Choose Your Path
The Factory meets you where you are by offering three distinct paths for building agents:

1.  **Rapid Deployment:** Use **Pre-Built Agents** for immediate functionality. Examples include the **Knowledge Agent** (for processing documents and web sources) and the **Data Analysis Agent** (for extracting semantic insights from structured databases).
2.  **Warm Start:** Utilize the **Agent Template Gallery** to customize existing flow templates for specific business needs.
3.  **From Scratch:** Use the **Agent Builder** to design custom agents. You can combine LLMs (like OCI GenAI or OpenAI), tools (via MCP Servers or REST APIs), and data connectors to create unique workflows.

## 5. Workshop Roadmap: Setting Up for Success
Before we can build agents, we must establish the infrastructure. In the upcoming labs, we will follow the official deployment walkthrough:

*   **Create Networking:** Provisioning a Virtual Cloud Network (VCN) and updating security rules to open essential ports (22, 8080, and 1521).
*   **Create Database:** Provisioning an **Autonomous AI Database** to serve as the brain and memory for our agents.
*   **Marketplace Installation:** Launching the Factory stack directly from the OCI Marketplace.
*   **Configuration:** Setting up administrative users and connecting your LLM and embedding providers.

**Next Steps:** If you have an OCI tenancy, go to **Installing from OCI Marketplace** to get started building agents. If you don't have an OCI tenancy, go to **Installing from source**. 

## Acknowledgements

- **Authors** 
* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026