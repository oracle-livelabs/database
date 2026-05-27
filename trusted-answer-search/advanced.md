# Lab 5: Prove and Operate Trusted Search

## Introduction

In Lab 4, Maya improved the Wikimedia search experience. Now her engineering lead asks the next set of questions.

What changed? Did the fix help? Did it break anything else? How does this connect to the real application? What happens when users ask things the team did not expect?

This lab focuses on the deeper operational features that turn Trusted Answer Search from a good demo into a manageable enterprise search capability.

**Estimated time:** 25 minutes

### Objectives

In this lab, you will:

* See portal user feedback appear in the Admin app.
* Run regression tests and review Top-1, Top-3, and Top-5 accuracy.
* Inspect an individual test result.
* Add a sample query as another form of expert evidence.
* Inspect a target action URL and its target inputs.
* Review search history and additional feedback.
* Review draft changes before promotion.
* Publish the improved draft when quality is acceptable.

### Prerequisites

This lab assumes you completed Lab 4 and are signed in to the Trusted Answer Search Admin app.

> **Learn more:** For the underlying product model, see the Oracle Database documentation for [Trusted Answer Search overview](https://docs.oracle.com/en/database/oracle/oracle-database/26/otasc/trusted-answer-search-overview.html). The sections on target actions, target inputs, target value sets, feedback-aware relevance, and change management are especially relevant to this lab.

## Task 1: See Portal Feedback in Admin

In Lab 4, the user left feedback in the published portal. Maya now checks whether that signal reached the admin experience.

1. In the Admin app, click **Dashboard**.
2. Review the feedback regions.

    ![Dashboard Metrics](images/dashboard-metrics.jpg)

    Depending on recent activity, the dashboard can show signals such as:

    * Feedback metrics.
    * Top user-upvoted queries.
    * Top user-downvoted queries.
    * Trending queries.

3. If the feedback does not appear immediately, refresh the page.
4. In the left navigation menu, click **Search History**.
5. Find the recent query:

    ```text
    <copy>
    Total page views MoM all projects
    </copy>
    ```

6. Review the feedback indicators for that query.

This closes the first loop: users do not just search. Their feedback becomes an operational signal for the application team.

## Task 2: Run the Regression Test Suite

Maya fixed one query. Her team needs to know whether the draft is still safe.

1. In the left navigation menu, click **Test Runs**.
2. If you are using the green-button environment, the Wikimedia uploaded test questions are already loaded and an initial lightweight run may already appear under **View Past Runs**.
3. Select the search-space version you want to evaluate.

    * Use the **Published** version to see the current baseline.
    * Use your **Draft** version to evaluate the changes you made in Lab 4.

4. Click **Run Tests**.
5. Keep the available query sources selected, such as:

    * Uploaded test questions.
    * Sample queries.
    * Past user queries, if available.

6. Click **Run**.

![Upload Test Runs](images/upload-test-runs.png)

The uploaded Wikimedia test file contains curated regression questions. Running with sample queries evaluates a much larger set generated from the search target sample queries. Either way, the system is replaying known questions and checking whether the expected target still appears in the ranked results.

## Task 3: Review Search Quality Metrics

1. Click **View Past Runs**.
2. Open or review the latest completed run.

![Test Run Results](images/test-run-results.jpg)

### Observe

Review:

* Total queries evaluated.
* Progress.
* Status.
* Top-1, Top-3, and Top-5 accuracy.
* Passed queries.

In the current Admin app UI, these may appear as:

| UI Label | Meaning |
| --- | --- |
| P1 | Top-1 accuracy: the expected target was ranked first. |
| P3 | Top-3 accuracy: the expected target appeared in the first three results. |
| P5 | Top-5 accuracy: the expected target appeared in the first five results. |

In a green-button environment, you may see a seeded run from the uploaded Wikimedia test questions. If you run the larger sample-query suite, the published baseline should produce results similar to:

```text
<copy>
Total Queries: about 802
Status: COMPLETED
Top-1 accuracy / P1: about 99.88
Top-3 accuracy / P3: 100
Top-5 accuracy / P5: 100
</copy>
```

Exact values vary depending on whether you use uploaded questions, sample queries, past user queries, or a draft after making changes. The important pattern is that search quality is measurable.

## Task 4: Inspect One Test Result

1. Open a completed test run.
2. Review the query result rows.
3. Pick one query and compare:

    * Query text.
    * Ground truth target.
    * Matched search target.
    * Rank.
    * Pass or fail status.
    * Target input mismatches, if any.

This is how a team investigates regressions. Instead of arguing about whether search "feels better," you can inspect the query, the expected target, the returned target, and the rank.

## Task 5: Add a Sample Query

Descriptions explain what a target is. Sample queries show how users ask for it.

1. In the left navigation menu, click **Search Targets**.
2. Search for:

    ```text
    <copy>
    Total Page Views - All Projects
    </copy>
    ```

3. Open the target.
4. In the **Sample Queries** region, click **Add Sample Query**.
5. Enter:

    ```text
    <copy>
    Show the overall Wikimedia traffic trend
    </copy>
    ```

6. Click **Add**.

Sample queries are another way application experts can teach the system without retraining a model.

## Task 6: Inspect the Target Action

Maya's engineering lead now asks: "When the user clicks a result, what actually happens?"

1. Stay on the `Total Page Views - All Projects` search target.
2. Find the **Target Action** region.
3. Review the URL or SQL action for the target.

For this target, the action is a Wikimedia URL template similar to:

```text
<copy>
https://stats.wikimedia.org/#/all-projects/reading/total-page-views/normal|bar|:period|~total|:frequency
</copy>
```

The placeholders are backed by target inputs:

```text
<copy>
:period
:frequency
</copy>
```

Those inputs are resolved from target value sets. That is why `past 24 months` can become `2-year`, and `by month` can become `monthly`.

Trusted Answer Search returns the target action metadata. The application decides how to execute it.

## Task 7: Review Target Value Sets

1. In the left navigation menu, click **Target Value Sets**.
2. Open the `period` value set.
3. Find the value:

    ```text
    <copy>
    2-year
    </copy>
    ```

4. Review its synonyms, such as:

    ```text
    <copy>
    2 years
    last 2 years
    past 24 months
    last two years
    </copy>
    ```

This is controlled vocabulary. Users can say "past 24 months," but the application receives the canonical value `2-year`.

## Task 8: Review Search History

1. In the left navigation menu, click **Search History**.
2. Review recent queries.

Search History shows:

* Query text.
* User.
* Rank #1 target.
* Feedback.
* Timestamp.

This is where Maya's team learns what users actually asked, not what the design document hoped they would ask.

For the query you used in Lab 4, confirm that the portal feedback is visible as part of the search record.

## Task 9: Review Additional Feedback

1. In the left navigation menu, click **Additional Feedback**.
2. Review any free-text feedback captured from users.

Additional feedback is useful when users need more than an upvote or downvote. Their comments can become new descriptions, sample queries, synonyms, test questions, or new application targets.

## Task 10: Review the Draft Before Publishing

Before Maya promotes the draft, she checks what changed.

1. In the left navigation menu, click **Search Spaces**.
2. Open the `trusted_search` search space.
3. Open your draft version.
4. Review available draft-change, diff, or version comparison actions.

Look for the changes you made:

```text
<copy>
Downvote feedback for Top Viewed Articles - All Projects
New description: Wikimedia traffic trend over time
New sample query: Show the overall Wikimedia traffic trend
</copy>
```

If the change list does not look right, do not publish yet. Delete the draft and clone the published version again, or return to the affected target and correct the issue.

![Published Guardrail](images/published-guardrail.jpg)

## Task 11: Publish the Improved Draft

When the test run looks acceptable and the draft changes make sense, publish the draft.

1. Stay on the draft version for `trusted_search`.
2. Click **Publish**.
3. Confirm the publish action.
4. Return to the **Published Wiki Search URL**.
5. Search again:

    ```text
    <copy>
    Total page views MoM all projects
    </copy>
    ```

The portal now uses the improved published version.

## Task 12: Check the Dashboard

1. In the Admin app, click **Dashboard**.
2. Review the available operational metrics.

![Dashboard Metrics](images/dashboard-metrics.jpg)

Depending on recent activity, the dashboard can show signals such as:

* API call volume and average latency.
* Feedback metrics.
* Latest test-run summary.
* Upvoted, downvoted, and trending queries.

This is the operational view. Trusted search is not just a search box. It is a managed application feature.

## Task 13: Know the Recovery Path

If a draft goes wrong, you do not need heroics.

1. Return to **Search Spaces**.
2. Open `trusted_search`.
3. If the bad change is still in a draft, delete the draft and clone the published version again.
4. If the bad change was already published, clone the last acceptable version into a new draft, validate it, and publish it.

The workflow is intentionally boring. Boring is good when production behavior is involved.

## Summary

In this lab, you:

* Saw portal user feedback appear in the Admin app.
* Ran regression tests.
* Reviewed Top-1, Top-3, and Top-5 accuracy.
* Inspected an individual test result.
* Added a sample query.
* Reviewed a target action and its target inputs.
* Reviewed target value set synonyms.
* Used search history and feedback as improvement signals.
* Reviewed draft changes before publishing.
* Published the improved version.

The main idea:

```text
<copy>
Trusted Answer Search turns natural-language search into an application
feature that can be curated, tested, measured, published, and recovered.
</copy>
```

You have now completed the Trusted Answer Search LiveLab.

## Acknowledgements

**Authors**

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - May, 2026
