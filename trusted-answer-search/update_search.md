# Lab 4: Trusted Continuous Improvement of Search

## Introduction

Wikimedia is the family of public knowledge projects behind sites such as Wikipedia, Wiktionary, Wikibooks, Wikimedia Commons, and Wikidata. Wikimedia also publishes analytics pages for traffic, edits, editors, devices, countries, languages, and projects.

That is useful data, but it creates a familiar enterprise problem: the application has many correct pages and queries, and users do not always know the exact report name, filter, project, language, or URL pattern.

Trusted Answer Search maps a user's natural-language intent to a trusted application target, such as a report URL, SQL query, or web page, plus controlled inputs the application can safely execute. In this lab, you will start with a published Wikimedia search app, clone the published search space into a draft, fix a bad ranking, and verify the improved behavior.

**Estimated time:** 25 minutes

### Objectives

In this lab, you will:

* Run natural-language searches against the Wikimedia sample.
* Use the published portal app as the end-user search experience.
* Observe how a query maps to a trusted application target.
* Clone a published search-space version into a draft.
* Correct a bad ranking with expert feedback.
* Teach the system a new phrase by adding a curated description.
* See why this is different from chatbot-style search.

### Prerequisites

You need:

* The Trusted Answer Search **Admin URL**.
* The **Published Wiki Search URL**.
* The `TASADMIN` username.
* The `TASADMIN` password.
* A loaded `trusted_search` search space.

If you are using the green button environment, these values are provided for you.

## Task 1: Create a Draft Version

The green-button environment starts with `trusted_search` already published. That is intentional: the published version powers the end-user portal app. Published versions are read-only, so you will clone the published version before making changes.

1. Open the **Admin URL**.
2. Sign in with:

    ```text
    <copy>
    Username: TASADMIN
    Password: {your TASADMIN password}
    </copy>
    ```

3. Confirm that the selected search space is:

    ```text
    <copy>
    trusted_search
    </copy>
    ```

4. In the left navigation menu, click **Search Spaces**.
5. Open the `trusted_search` search space.
6. Find the published version.
7. If a draft version already exists from an earlier attempt, either use that draft or delete it before cloning.

    > **Note:** A search space can have only one draft version at a time. For the cleanest walkthrough, delete the existing draft, then clone the published version again.

8. If no draft exists, open the actions menu for the published version.
9. Click **Clone**.
10. Enter a label such as:

    ```text
    <copy>
    LiveLab Draft
    </copy>
    ```

11. Click **Create**.

![Search Space Versions Screen](images/navigate-to-search-space.png)

You now have a draft version. This is where experts safely make improvements before promoting changes.

## Task 2: Try the Published Wiki Search App

1. Open the **Published Wiki Search URL** in a new browser tab.
2. Sign in with the same `TASADMIN` username and password if prompted.
3. Search for:

    ```text
    <copy>
    Total page views MoM all projects
    </copy>
    ```

This is a realistic user query. It is short, messy, and full of shorthand, exactly the kind of thing users type when they are trying to get work done.

The expected target is:

```text
<copy>
Total Page Views - All Projects
</copy>
```

If the top result is not the expected target, you have found the kind of issue that hurts enterprise application search. The application has the right answer, but the user did not know the exact thing to ask for.

## Task 3: Reproduce the Query in the Draft Version

1. Return to the Admin app.
2. In the left navigation menu, click **Query Tester**.
3. In the search-space version selector, choose your draft version.
4. Run the same query again:

    ```text
    <copy>
    Total page views MoM all projects
    </copy>
    ```

5. Confirm that the bad result is still visible near the top.

The expected target is:

```text
<copy>
Total Page Views - All Projects
</copy>
```

But the initial top result should be:

```text
<copy>
Top Viewed Articles - All Projects
</copy>
```

The correct result appears below it.

![Initial Query Results](images/initial-ranking.png)

You have reproduced the problem in a safe workspace. The published app still works from the current trusted version while you edit the draft.

## Task 4: Correct the Ranking

1. Find the incorrect result:

    ```text
    <copy>
    Top Viewed Articles - All Projects
    </copy>
    ```

2. Click **Downvote**.
3. Run the exact same query again:

    ```text
    <copy>
    Total page views MoM all projects
    </copy>
    ```

### Observe

The correct result moves to Rank #1:

```text
<copy>
Total Page Views - All Projects
</copy>
```

![Corrected Draft Ranking](images/draft-corrected-ranking.jpg)

The behavior changed because you changed the trusted evidence the system uses.

The model was not retrained. The app was not redeployed. The correction is now part of the governed search configuration.

### Expected result

After the downvote, the rerun should show:

```text
<copy>
Rank #1: Total Page Views - All Projects
Frequency: monthly
Period: 2-year
</copy>
```

## Task 5: Inspect the Structured Inputs

Look under the Rank #1 result.

You should see target inputs such as:

```text
<copy>
Frequency: monthly
Period: 2-year
</copy>
```

The system did not generate an answer paragraph. It selected a trusted action and extracted controlled values that the application can pass to a report.

That is the difference:

* A chatbot says something.
* Trusted Answer Search does something your application already trusts.

## Task 6: Teach the System a New Phrase

Now you will expand the system's vocabulary.

1. In the left navigation menu, click **Search Targets**.
2. Search for:

    ```text
    <copy>
    Total Page Views - All Projects
    </copy>
    ```

3. Open the target.
4. In the **Descriptions** region, click **Add Description**.
5. Enter:

    ```text
    <copy>
    Wikimedia traffic trend over time
    </copy>
    ```

6. Click **Add**.

## Task 7: Test the New Phrase

1. Return to **Query Tester**.
2. Confirm your draft version is still selected.
3. Run:

    ```text
    <copy>
    Wikimedia traffic trend
    </copy>
    ```

### Observe

The top result should be:

```text
<copy>
Total Page Views - All Projects
</copy>
```

The matched description should include:

```text
<copy>
Wikimedia traffic trend over time
</copy>
```

You just taught the search system a new business phrase with curation, not training.

### Expected result

The result should show:

```text
<copy>
Rank #1: Total Page Views - All Projects
Matched Description/Sample Query: Wikimedia traffic trend over time
</copy>
```

## Task 8: Run a Deterministic Search

Run this query twice:

```text
<copy>
Show total page views for Wikimedia Commons over the last 2 years
</copy>
```

### Observe

The Rank #1 result should be the same both times:

```text
<copy>
Total Page Views - Wikimedia Commons
</copy>
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
<copy>
Trusted Answer Search lets application experts improve natural-language search
inside a governed feedback loop, without retraining or redeploying the app.
</copy>
```

You may now **proceed to Lab 5**.

## Acknowledgements

**Authors**

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - May, 2026
