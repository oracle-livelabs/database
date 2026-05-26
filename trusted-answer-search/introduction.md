# Introduction to Trusted Answer Search

## Introduction

Welcome to **Make Search Trusted, Faster, and Cheaper on your Application with Trusted Answer Search**.

Most enterprise applications already know the right answers. The problem is that users do not always know the exact report name, filter value, URL pattern, or navigation path. Trusted Answer Search solves that problem by mapping natural-language questions to trusted application targets and validated inputs.

This workshop supports two paths:

* **Green button path:** your environment is already provisioned. Start at **Lab 4**.
* **Manual walkthrough path:** you install the backend, APEX apps, and sample data yourself. Start at **Get Started**, then continue through Labs 1-3.

**Estimated workshop time:**

* Green button path: 35 minutes.
* Manual walkthrough path: 90 minutes.

### Objectives

In this workshop, you will:

* Understand the language-to-application-action architecture.
* Install Trusted Answer Search manually, or use a prebuilt green button environment.
* Work with a real Wikimedia analytics search space.
* Correct a bad ranking using expert feedback.
* Teach the system a new phrase without retraining a model.
* Prove search quality with metrics, search history, and regression tests.

## Task 1: Understand the Core Idea

Traditional generative AI is powerful, but it is not always the right tool for bounded enterprise application navigation. If the application has 80 approved reports, you usually do not want the system to invent report 81 during a dramatic moment.

Trusted Answer Search uses Oracle AI Vector Search to match user language against curated descriptions, sample queries, and controlled value sets. The application remains in control of the final action.

The result is:

* Natural-language input from users.
* Trusted targets managed by application experts.
* Validated parameters such as project, language, period, and frequency.
* Deterministic application actions instead of improvised generated answers.

## Task 2: Understand the Workshop Story

You will use a Wikimedia analytics sample application.

The story starts with an everyday enterprise problem:

> A user asks for a report in plain English, but the search system initially picks the wrong result.

Then you will act as the application expert:

1. Find the incorrect ranking.
2. Clone a published search-space version into a draft.
3. Downvote the bad result.
4. Rerun the same query.
5. Watch the correct report move to Rank #1.
6. Run quality checks before trusting the change.

That is the main aha moment: **human-guided search improvement without retraining, redeployment, or prompt gymnastics**.

## Task 3: Choose Your Path

If you are using a prebuilt LiveLabs reservation or green button stack, skip directly to **Lab 4: Trusted Continuous Improvement of Search**.

If you are doing the manual walkthrough, continue to **Get Started** and complete Labs 1-3 first.

You may now **proceed to the next lab**.

## Acknowledgements

**Authors**

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - May, 2026
