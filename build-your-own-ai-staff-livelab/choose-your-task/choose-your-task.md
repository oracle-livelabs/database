# Lab 1: Define a Focused GPT Task

## Introduction

A useful GPT starts with one repeatable job. In this lab, you will turn a broad idea into a Task Brief that a person and a team of agents can understand.

Choose a task with a recognizable result. Examples include organizing fictional notes, drafting a study plan, classifying club requests, reviewing a short draft, or preparing a community checklist.

### Objectives

- Select one repeat task and its main result.
- Write a Task Paragraph with safe boundaries.
- Turn the paragraph into a Task Brief for the agent team.

### Hands-on Scenario

Use the fictional or approved example you prepared in Get Started. Keep the task small enough to practice in one conversation.

Estimated Time: **7 minutes**

## Task 1: Choose the task boundary

1. Choose the task type that best matches the result you want:

    - Organize or summarize.
    - Draft or rewrite.
    - Classify or route.
    - Plan or create a checklist.
    - Research information you provide or approve.
    - Review or improve.

2. Write down the repeat task, who benefits, and the result you want. Make the scope small. Choose “turn fictional weekly meeting notes into decisions and follow-ups,” not “manage all project communication.”

3. Decide what information the owner approves for practice and what is out of scope. Keep the owner responsible for review before anyone shares or changes anything.

## Task 2: Write the Task Paragraph

1. Replace the bracketed text in this template:

    ```text
    <copy>
    I want a task-focused GPT to help me [ACTION] using [TYPE OF INPUT] for [PERSON OR GROUP]. It should return [DESIRED RESULT] in [USEFUL FORMAT]. It may use [FICTIONAL OR APPROVED INFORMATION], but it must not use [SENSITIVE OR OUT-OF-SCOPE INFORMATION]. I will review the result before [APPROVAL OR OUTSIDE ACTION].
    </copy>
    ```

2. Compare your paragraph with this example:

    ```text
    <copy>
    I want a task-focused GPT to turn fictional weekly meeting notes into decisions, follow-ups, and a short recap for a student project team. It should return a concise summary with owners and open questions. It may use the practice notes I provide, but it must not use private student records or invent decisions that are not in the notes. I will review the result before sharing it with the team.
    </copy>
    ```

3. Revise the paragraph until it answers what the GPT does, what it receives, who benefits, what it returns, what it must not use, and what you will review.

## Task 3: Create the Task Brief

1. Save your paragraph in a note named **Task Paragraph**.

2. In the Staff Room, ask for this structured brief. Replace `[TASK PARAGRAPH]` with your paragraph:

    ```text
    <copy>
    Use this Task Paragraph to create a TASK BRIEF. Do not broaden the task or invent details.

    Task Paragraph:
    [TASK PARAGRAPH]

    Return these fields:

    TASK BRIEF
    Owner:
    Repeat task:
    Who benefits:
    Desired result:
    Approved practice information:
    Excluded information:
    Definition of done:
    Open questions:
    Selected roles:

    For Definition of done, write three checks. Recommend the smallest useful group from Maya, Nova, and Tessa. Write UNKNOWN when a required value is missing. Do not treat UNKNOWN as complete.
    </copy>
    ```

3. Review the brief. Resolve every required `UNKNOWN`, then save the completed version. Use the same version in the remaining labs.

### Expected Result: Task Brief Ready

You have one focused GPT task, a safe boundary, a definition of done, and a saved brief for the agent team.

Continue to [Lab 2: Build the Agent Team](../build-the-staff/build-the-staff.md).

## Acknowledgements

* **Product resource** - [Oracle LiveLabs](https://livelabs.oracle.com/).
