# Final Quiz

```quiz-config
passing: 75
```

## Introduction

Use this scored quiz to review the design choices from **Build Your Own AI Staff**.

The goal is not to memorize product words. The goal is to recognize what makes a role useful, what makes a handoff clear, and what keeps the owner in control.

### Objectives

- Review the workshop definitions.
- Confirm that the role sequence and handoff are understood.
- Recognize safe response behavior when evidence or approval is missing.
- Connect the prototype to the next step with Oracle AI Database and Agent Memory.

Estimated Time: **3 minutes**

## Task 1: Answer The Quiz Questions

1. Complete the scored quiz.

    ```quiz score
    Q: In this workshop, what is an agent?
    - A tool that can take any action without permission.
    - A password manager for a team.
    * A role-based helper with a goal, steps, inputs, outputs, boundaries, and a handoff.
    - A database table that stores every conversation.
    > An agent is defined by its job, workflow, boundaries, and handoff. It does not automatically have permission to act outside the conversation.

    Q: What is the purpose of a HANDOFF CARD?
    * To give the next role the task, context, approved sources, constraints, definition of done, and decision status.
    - To hide work from the owner.
    - To let a role change the instructions of another role.
    - To store passwords for later use.
    > A handoff makes collaboration visible and gives the next role the context it needs without silently expanding scope.

    Q: What is the optional plugin step for?
    - To require every participant to build a technical server during the workshop.
    - To give an agent permission to act outside the conversation without approval.
    - To store every possible document and secret.
    * To package tested role instructions as reusable skills that can be shared or reused later.
    > The workshop can be completed with role prompts in private chats. Plugin packaging is an optional way to make tested instructions easier to reuse.

    Q: Which teammate should usually review a first draft before it is treated as ready?
    - Maya, Coordinator.
    * Tessa, Reviewer.
    - Nova, Researcher.
    - Jo, Publisher.
    > Tessa checks accuracy, clarity, inclusion, privacy, and readiness before the owner decides what happens next.

    Q: What should a teammate do when it is not sure about a fact or request?
    - Guess so the answer sounds complete.
    - Hide the uncertainty inside a long response.
    - Ask for a password.
    * Add a CONCERNS section that explains the concern, why it matters, what would resolve it, and whether work should continue.
    > A clear concern is better than a confident guess. The owner should be able to see what needs review.

    Q: What does useful variation mean in this workshop?
    * Vary wording, examples, organization, or level of detail while keeping facts, scope, sources, and guardrails stable.
    - Change facts so each answer sounds new.
    - Remove required sources and labels.
    - Use more technical language in every response.
    > Variation should make the result fit the task. It should never change what is known or weaken the safeguards.

    Q: What should Lumen do with a possible memory?
    - Save everything automatically.
    - Save secrets because they may be useful later.
    * Propose only small, stable, sourced information and ask the owner before saving it.
    - Treat every temporary detail as a permanent fact.
    > Useful memory is intentional, sourced, classified, and reviewable. Secrets and unnecessary sensitive details should not be retained.

    Q: What can Jo do in this lab?
    - Publish a message as soon as it has a draft.
    * Prepare a channel-ready draft and release checklist while leaving the final action with the owner.
    - Send an email without asking.
    - Change a database record.
    > Jo prepares approved work for a channel. Jo does not send, publish, schedule, or change systems in this lab.

    Q: Which statement best describes the path from this prototype to Oracle?
    * Prove the workflow first, then add governed data, durable memory, identity, permissions, logging, and enterprise controls as needed.
    - Prompts alone are a complete security boundary.
    - Every team should copy data into a separate system before testing a workflow.
    - Oracle Cloud Infrastructure is required before a person can define a role.
    > A small prototype helps clarify the use case. Oracle AI Database and Agent Memory can provide a durable, governed foundation when the work grows.
    ```

2. When you achieve the passing score, the workshop displays your completion result.

## Closing Reflection

Return to the questions from the beginning:

1. Can you define agent memory?
2. Have you ever built a set of agents and had them work together?

So now, can you tell me what an agent is?

Your answer should include four ideas: a clear job, a repeatable set of steps, boundaries that keep a person in control, and a handoff that helps the next role contribute.

## Keep Going

Follow [Angela Wall](https://www.linkedin.com/in/angela-l-wall) and [Kay Malcolm](https://www.linkedin.com/in/kaymalcolm/) for the live follow-up class.

Continue exploring:

- [Oracle LiveLabs](https://livelabs.oracle.com/)
- [Oracle AI Database](https://www.oracle.com/database/)
- [Oracle AI Agent Memory](https://docs.oracle.com/en/database/oracle/agent-memory/)

## For Additional Functionality: Package Your AI Staff As A Plugin

You do not need a plugin to complete this workshop. Once your role prompts and handoffs have been tested, you can package the instructions as reusable skills in one private plugin.

A plugin can make the Staff easier to reuse, share, and maintain. A skills-only plugin does not require an MCP server when the workflow only needs instructions, examples, templates, and other supporting files. A future production design may add approved connections to business systems when the workflow needs live information or controlled actions.

The practical order is:

1. Prove that the repeat task is worth improving.
2. Test the roles, handoffs, guardrails, and owner approvals.
3. Package the tested role instructions as skills if reuse or sharing would help.
4. Add tools, data, memory, and application controls only when the real use case requires them.

Learn more:

- [OpenAI plugin architecture](https://developers.openai.com/plugins/concepts/plugins)
- [OpenAI skills](https://developers.openai.com/plugins/concepts/skills)

## Why This Matters After The Workshop

This workshop is about more than creating helpers. It is about getting more done, staying organized, making repeat work easier, and giving yourself time back for the decisions and relationships that need you.

When a workflow grows beyond a personal experiment, Oracle can help take the same idea further:

| Value | What it means |
| --- | --- |
| More context | The Staff can work with information the organization already trusts. |
| More continuity | Approved preferences and decisions can be carried forward instead of recreated each time. |
| More control | People can keep approval, access, and review steps visible. |
| More room to grow | A useful personal workflow can become a repeatable process for a team or organization. |

Oracle Database and Agent Memory are possible next steps when the work needs a stronger foundation. You do not need to understand the technology today. The important first step is identifying a task that is worth making easier.

### The Practical Message

Start small. Prove the task. Keep a person involved where the decision matters. Then build on what works.

Learn more when you are ready:

- [Oracle AI Database](https://www.oracle.com/database/)
- [Oracle AI Agent Memory](https://docs.oracle.com/en/database/oracle/agent-memory/)

## Acknowledgements

* **Author** - Angela Wall
* **Contributor** - Kay Malcolm
* **Source Pattern** - Oracle LiveLabs finance LiveStack final quiz structure
* **Last Updated By/Date** - Draft for review, September 2026
