# Lab 4: Trusted Continuous Improvement of Search

## Introduction

This is the main story.

You are now the application expert for a Wikimedia analytics app. Users ask questions in normal language. Trusted Answer Search maps those questions to approved application targets and validated inputs.

In this lab, you will catch a bad result, correct it in a governed draft version, and prove that the system learned from expert feedback immediately.

No retraining. No redeploy. No prompt ceremony.

**Estimated time:** 25 minutes

### Objectives

In this lab, you will:

* Run natural-language searches against the Wikimedia sample.
* Observe how a query maps to a trusted application target.
* Clone a published search-space version into a draft.
* Correct a bad ranking with expert feedback.
* Teach the system a new phrase by adding a curated description.
* See why this is different from chatbot-style search.

### Prerequisites

You need:

* The Trusted Answer Search Admin app URL.
* The `TASADMIN` username.
* The `TASADMIN` password.
* A loaded `trusted_search` search space.

If you are using the green button environment, these values are provided for you.

## Task 1: Sign In to the Admin App

1. Open the Trusted Answer Search Admin app.
2. Sign in with:

    ```text
    Username: TASADMIN
    Password: {your TASADMIN password}
    ```

3. Confirm that the selected search space is:

    ```text
    trusted_search
    ```

If you see the dashboard, you are in the right place.

## Task 2: Run a Search That Almost Works

1. In the left navigation menu, click **Query Tester**.
2. Run this query:

    ```text
    Total page views MoM all projects
    ```

This is a realistic user query. It is short, messy, and full of shorthand. In other words, a normal Tuesday.

### Observe

The expected target is:

```text
Total Page Views - All Projects
```

But the initial top result may be:

```text
Top Viewed Articles - All Projects
```

The correct result appears below it.

![Initial Query Results](images/initial-ranking.png)

This is exactly the kind of issue that hurts enterprise application search. The system is close, but close is not the same as trusted.

## Task 3: Notice the Governance Guardrail

Before fixing the result, look at the search-space version selector near the top of the page.

If the current version is **Published**, feedback and editing controls are disabled. That is intentional.

Published versions represent the current trusted behavior. You do not casually edit production behavior because someone typed "MoM" with confidence.

## Task 4: Clone the Published Version to a Draft

1. In the left navigation menu, click **Search Spaces**.
2. Open the `trusted_search` search space.
3. Find the published version.
4. If a draft version already exists from an earlier attempt, either use that draft or delete it before cloning.

    > **Note:** A search space can have only one draft version at a time. For the cleanest walkthrough, delete the existing draft, then clone the published version again.

5. If no draft exists, open the actions menu for the published version.
6. Click **Clone**.
7. Enter a label such as:

    ```text
    LiveLab Draft
    ```

8. Click **Create**.

![Search Space Versions Screen](images/navigate-to-search-space.png)

You now have a draft version. This is where experts safely make improvements before promoting changes.

## Task 5: Rerun the Query on the Draft Version

1. Return to **Query Tester**.
2. In the search-space version selector, choose your draft version.
3. Run the same query again:

    ```text
    Total page views MoM all projects
    ```

4. Confirm that the bad result is still visible near the top.

You have reproduced the problem in a safe workspace. That matters.

## Task 6: Correct the Ranking

1. Find the incorrect result:

    ```text
    Top Viewed Articles - All Projects
    ```

2. Click **Downvote**.
3. Run the exact same query again:

    ```text
    Total page views MoM all projects
    ```

### Observe

The correct result moves to Rank #1:

```text
Total Page Views - All Projects
```

![Updated Ranking results](images/updated-ranking.png)

This is the aha moment.

You just changed the system behavior with expert feedback. The model was not retrained. The app was not redeployed. Nobody had to argue with a prompt for 45 minutes.

## Task 7: Inspect the Structured Inputs

Look under the Rank #1 result.

You should see target inputs such as:

```text
Frequency: monthly
Period: 2-year
```

The system did not generate an answer paragraph. It selected a trusted action and extracted controlled values that the application can pass to a report.

That is the difference:

* A chatbot says something.
* Trusted Answer Search does something your application already trusts.

## Task 8: Teach the System a New Phrase

Now you will expand the system's vocabulary.

1. In the left navigation menu, click **Search Targets**.
2. Search for:

    ```text
    Total Page Views - All Projects
    ```

3. Open the target.
4. In the **Descriptions** region, click **Add Description**.
5. Enter:

    ```text
    Wikimedia traffic trend over time
    ```

6. Click **Add**.

## Task 9: Test the New Phrase

1. Return to **Query Tester**.
2. Confirm your draft version is still selected.
3. Run:

    ```text
    Wikimedia traffic trend
    ```

### Observe

The top result should be:

```text
Total Page Views - All Projects
```

The matched description should include:

```text
Wikimedia traffic trend over time
```

You just taught the search system a new business phrase with curation, not training.

## Task 10: Run a Deterministic Search

Run this query twice:

```text
Show total page views for Wikimedia Commons over the last 2 years
```

### Observe

The Rank #1 result should be the same both times:

```text
Total Page Views - Wikimedia Commons
```

This is not a roulette wheel wearing a user interface. For enterprise application navigation, repeatability is a feature.

## Summary

In this lab, you:

* Found an incorrect top result.
* Created a governed draft version.
* Corrected ranking with expert feedback.
* Added a new trusted description.
* Confirmed deterministic behavior.

The key takeaway:

```text
Trusted Answer Search lets application experts improve natural-language search
inside a governed feedback loop, without retraining or redeploying the app.
```

You may now **proceed to Lab 5**.

## Acknowledgements

**Authors**

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - May, 2026
