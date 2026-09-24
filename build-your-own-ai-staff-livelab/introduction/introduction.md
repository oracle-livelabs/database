# Build Your Own AI Staff

## Introduction

Most people do not need another tool to manage. They need help with the work that keeps returning: sorting information, preparing a first draft, reviewing details, keeping decisions organized, or getting something ready to share.

In this workshop, you will turn one repeat task into a small team of role-based agents. Each agent will have a clear job, a useful background, a defined handoff, and boundaries that keep you in control.

You will begin with three core teammates and add up to two more if time allows. The team will work from one shared request and pass a simple handoff from one role to the next.

This lab uses ChatGPT so that you can see the idea quickly without an Oracle Cloud Infrastructure environment. Later, the same workflow can move toward Oracle AI Database, Agent Memory, governed data, and more durable automation.

> **Important:** This lab uses a Project or separate private chats called `My AI Staff`. You will create role-based agents with reusable prompts, then pass work between them with visible handoffs. You do not need to create or install a plugin for this workshop. At the end, we will briefly discuss how tested role instructions can be packaged as a plugin for additional functionality.

### What You Will Build

| Teammate | Job | What You Will See |
| --- | --- | --- |
| Maya | Coordinator | Turns a broad request into a clear next step and prepares the first handoff. |
| Nova | Researcher | Organizes approved information and prepares a fact-based first pass. |
| Tessa | Reviewer | Checks accuracy, clarity, inclusion, privacy, and readiness. |
| Lumen | Memory Keeper | Identifies stable decisions or preferences that may be worth retaining. |
| Jo | Publisher | Prepares approved work for a specific channel without sending or posting it. |

Maya, Nova, Tessa, Lumen, and Jo are workshop names only. Rename every teammate before using the pattern for your own work. Do not copy names, examples, or private information from another person's setup.

<details>
<summary><strong>Key terms: AI, GPT, agent, plugin, skill, memory, handoff, and guardrail</strong></summary>

> - **AI** is the broad category of computer systems that can recognize patterns, create content, answer questions, or support decisions.
>
> - **GPT** is a language model that can generate and transform text from instructions. This lab does not ask you to create a custom GPT. It uses role prompts in private chats instead.
>
> - **Agent** is a role-based helper with a goal, steps, inputs, outputs, boundaries, and a way to pass work to the next role.
>
> - **AI Staff** is a small group of role-based helpers that divide a repeat task into manageable parts. This is a workshop pattern, not a product name.
>
> - **Plugin** is an optional package that can contain one or more reusable skills and, when needed, approved connections to outside services. This workshop treats plugin packaging as a next step.
>
> - **Skill** is a reusable instruction set for one role. In this workshop, you will use the same idea as a role prompt inside a chat. Later, the prompt could be packaged as a skill.
>
> - **Agent Memory** is information intentionally retained or supplied so a helper can remain consistent across work. Memory should have an owner, a source, a purpose, a sensitivity level, and a retention decision.
>
> - **Handoff** is a structured packet that tells the next role what the task is, what is known, what is needed, what constraints apply, and what decision remains with the person.
>
> - **Guardrail** is a rule that tells a helper what it may do, what it must ask before doing, and when it must stop.

ChatGPT memory, Project context, and saved instructions can be useful for a prototype, but they are not automatically the same as Oracle Agent Memory. A durable enterprise memory design needs governed storage, access controls, retention rules, and an auditable way to review what is remembered.

</details>

### Before You Begin

Take a quick mental snapshot before you build. There is no expected answer.

1. Can you define agent memory?
2. Have you ever built a set of agents and had them work together?

We will return to these questions at the end and use what you build today to answer them more clearly.

### Education Model And Production Path

This lab is designed to make the idea visible in a short session. You will use separate role chats, copied handoffs, and owner approval. That approach is intentionally simple so you can focus on the work pattern.

In a production environment, the same pattern would usually be coordinated by an application. One coordinator could call a specialist for a narrow task, keep the final response in one place, and pass a structured handoff instead of relying on manual copying. Each specialist would receive only the data and tools needed for its job. Higher-risk steps would require a person or an approved business process.

Use this lab to answer a practical question: does dividing this repeat task into clear responsibilities make the result more useful, consistent, reviewable, or efficient? If the answer is yes, the next step is to design the controls and data foundation around that proven workflow.

### Objectives

- Choose one repeat task that you want to make easier.
- Define AI, GPT, agent, agent memory, handoff, and guardrail in plain language.
- Create three role-based agents and optionally add two more.
- Give each teammate a background, responsibilities, outputs, guardrails, and security instructions.
- Pass work from one role to another using a structured handoff.
- Test the team with a realistic but non-sensitive example.
- Identify the path from a prompt-based prototype to Oracle AI Database and Agent Memory.

Estimated Workshop Time: **55 minutes**

### Workshop Journey

| Module | Focus | Outcome |
| --- | --- | --- |
| Getting Started | Open ChatGPT and prepare a private Staff Room. | A place to coordinate the work. |
| Choose Your Task | Select one repeat task and define success. | A clear task statement and boundaries. |
| Build The Staff | Create three to five role-based agents. | Reusable role prompts with guardrails. |
| Run The Staff Together | Pass work from role to role. | A tested handoff chain. |
| Final Quiz | Review the design and optional packaging path. | A completion result and next step. |

## Start The Lab

Continue to [Getting Started](../getting-started/getting-started.md) to open ChatGPT and prepare the Staff Room.

## Acknowledgements

* **Author** - Angela Wall
* **Contributor** - Kay Malcolm
* **Source Pattern** - Oracle LiveLabs finance LiveStack workshop structure
* **Last Updated By/Date** - Draft for review, September 2026
