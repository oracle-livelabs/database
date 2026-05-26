# Lab 5: Prove Quality with Metrics and Regression Tests

## Introduction

In Lab 4, you improved search behavior. In this lab, you will inspect the evidence.

Enterprise developers do not just need a cool demo. They need to know what changed, whether it helped, whether it broke something else, and whether the application can explain the decision.

That is where metrics, test runs, search history, and structured inputs become important.

**Estimated time:** 20 minutes

### Objectives

In this lab, you will:

* Run a regression test suite.
* Review Top-1, Top-3, and Top-5 quality metrics.
* Inspect individual test results.
* Explore structured input extraction.
* Review search history and feedback.
* Identify current limits that should be handled deliberately.

### Prerequisites

This lab assumes you completed Lab 4 and are signed in to the Trusted Answer Search Admin app.

## Task 1: Run the Regression Test Suite

1. In the left navigation menu, click **Test Runs**.
2. Select the search-space version you want to evaluate.
    * Use the **Published** version to see the baseline.
    * Use your **Draft** version to evaluate the changes you made in Lab 4.
3. Click **Run Tests**.
4. Keep the available query sources selected, such as:

    * Sample queries.
    * Past user queries, if available.

5. Click **Run**.

![Upload Test Runs](images/upload-test-runs.png)

The test run may take a minute. This is the system replaying known questions and checking whether the expected target still appears in the ranked results.

## Task 2: Review the Test Run Metrics

1. Click **View Past Runs**.
2. Open or review the latest completed run.

![Test Run Results](images/test-run-results.jpg)

### Observe

Review:

* Total queries evaluated.
* Progress.
* Status.
* Top-1, Top-3, and Top-5 accuracy.

In the current Admin app UI, these may appear as:

| UI Label | Meaning |
| --- | --- |
| P1 | Top-1 accuracy: the expected target was ranked first. |
| P3 | Top-3 accuracy: the expected target appeared in the first three results. |
| P5 | Top-5 accuracy: the expected target appeared in the first five results. |

* Passed queries.

In the tested green-button environment, the published baseline produced:

```text
<copy>
Total Queries: 802
Status: COMPLETED
Top-1 accuracy / P1: 99.88
Top-3 accuracy / P3: 100
Top-5 accuracy / P5: 100
Passed Queries: 802
</copy>
```

Exact values can vary if you evaluate a draft after making changes, but the important pattern is that search quality is measurable.

That is the kind of number an application team can discuss. It is not a vibe. It is a measurable system.

## Task 3: Inspect an Individual Test Result

1. Open a completed test run.
2. Review the query result rows.
3. Pick one query and compare:

    * Query text.
    * Ground truth target.
    * Matched search target.
    * Rank.
    * Pass or fail status.
    * Target input mismatches, if any.

This is useful when a search result regresses. Instead of guessing why users are unhappy, you can inspect exactly which query moved and which target won.

## Task 4: Explore Structured Intent

Go to **Query Tester** and run:

```text
<copy>
How has French Wiktionary readership changed by month over the last year?
</copy>
```

![Structured Inputs](images/structured-inputs.jpg)

### Observe

The top result should be a total page views trend target, with structured values:

```text
<copy>
Language: fr
Project: wiktionary
Period: 1-year
Frequency: monthly
</copy>
```

The user did not type `fr`, `wiktionary`, `1-year`, or `monthly` as system codes. Trusted Answer Search mapped human phrasing to controlled values.

That is a big deal for enterprise apps because controlled values are what applications can actually execute safely.

## Task 5: Explore Synonyms and Value Mapping

Run:

```text
<copy>
Show page views for all Wikimedia projects over the past 24 months
</copy>
```

### Observe

The top result should be:

```text
<copy>
Total Page Views - All Projects
</copy>
```

The phrase:

```text
<copy>
past 24 months
</copy>
```

maps to the controlled period value:

```text
<copy>
2-year
</copy>
```

This is not magic. It is governed vocabulary. Application experts decide which phrases map to which values.

## Task 6: See a Current Limit

Run:

```text
<copy>
Show page views for all Wikimedia projects this month
</copy>
```

### Observe

The system should still select a reasonable target:

```text
<copy>
Total Page Views - All Projects
</copy>
```

But it may not resolve `this month` into an exact current date range. In the tested environment, it fell back to:

```text
<copy>
Period: 2-year
</copy>
```

This is useful to show honestly. Trusted systems should make limits visible. The goal is not to pretend the system knows everything. The goal is to make behavior inspectable and improvable.

Future enhancements can use named entity recognition or date normalization to map phrases like:

```text
<copy>
this month
last quarter
last fiscal year
</copy>
```

to exact validated values.

## Task 7: Review Search History

1. In the left navigation menu, click **Search History**.
2. Review recent queries.

Search History shows:

* Query text.
* User.
* Rank #1 target.
* Feedback.
* Timestamp.

This is the product manager's favorite page and the developer's early-warning system. It tells you what users actually asked, not what the design document hoped they would ask.

## Task 8: Review Additional Feedback

1. In the left navigation menu, click **Additional Feedback**.
2. Review any text feedback captured from users.

This helps teams find phrases, expectations, or complaints that should become new descriptions, sample queries, value synonyms, or test cases.

## Task 9: Connect the Pieces

Trusted Answer Search is powerful because these features reinforce each other.

| Feature | What You Saw | Why It Matters |
| --- | --- | --- |
| Search targets | Trusted report/action catalog | The app controls what can be returned. |
| Value sets | Language, project, period, frequency | User text becomes validated application inputs. |
| Draft versions | Safe editing workflow | Experts can improve behavior without changing production immediately. |
| Feedback | Downvote and correction loop | Bad rankings can be fixed directly. |
| Descriptions | New phrase matching | Business language can evolve without retraining. |
| Test runs | Top-1/Top-3/Top-5 metrics | Changes can be measured before promotion. |
| Search history | Real user queries | Teams can improve based on actual usage. |
| Additional feedback | User comments | Qualitative feedback becomes curation input. |

## Task 10: What to Do Next in a Real Application

For your own enterprise app, the same pattern applies:

1. List the trusted actions users should be able to reach.
2. Add descriptions and sample queries for each action.
3. Define controlled value sets for parameters.
4. Launch search in a portal, app page, or widget.
5. Review user behavior.
6. Fix weak rankings in a draft.
7. Run regression tests.
8. Promote the version when quality is acceptable.

This is how search becomes a managed application feature instead of a mysterious text box.

## Summary

In this lab, you:

* Ran a test suite.
* Reviewed quality metrics.
* Inspected structured input extraction.
* Explored synonym mapping.
* Saw a current limitation.
* Reviewed search history and feedback.

You have now completed the Trusted Answer Search LiveLab.

The closing idea:

```text
<copy>
Trusted Answer Search gives users natural language,
developers controlled application actions,
and experts a measurable way to improve the system over time.
</copy>
```

## Acknowledgements

**Authors**

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - May, 2026
