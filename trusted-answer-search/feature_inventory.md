# Trusted Answer Search LiveLab Feature Inventory

This inventory is based on the shipped Admin APEX app metadata in `trusted_search/apex_ship/f610` and the current LiveLab markdown.

## Current Coverage

| Feature | Covered Today | Where |
| --- | --- | --- |
| Green-button setup | Yes | Get Started |
| Manual APEX app setup | Yes | Lab 3 |
| Create a search space | Yes | Lab 3 |
| Import search targets and target value sets | Yes | Lab 3 |
| Run a natural-language query | Yes | Lab 4 |
| Clone published version to draft | Yes | Lab 4 |
| Published-version editing guardrail | Yes | Lab 4 |
| Downvote a bad result | Yes | Lab 4 |
| Add a target description | Yes | Lab 4 |
| Deterministic repeated search | Yes | Lab 4 |
| Run/view test runs and quality metrics | Yes | Lab 5 |
| Structured input extraction | Yes | Lab 5 |
| Search history | Light coverage | Lab 5 |
| Additional feedback | Light coverage | Lab 5 |

## Features Available In The Admin App

### Dashboard

* API call volume and average latency.
* Feedback metrics.
* Latest test-run summary.
* Top upvoted, downvoted, and trending queries.
* Operational view that makes TAS feel like a managed search system, not just a search box.

### Search Spaces

* Create a new search space.
* Update search-space metadata.
* Open the version tree.
* Clone a published version into a draft.
* Publish a draft.
* Delete versions/search spaces.
* Import/export search metadata.
* Generate diffs between versions.
* Review current draft changes.
* Run search-space regression/impact analysis before promotion.

### Search Targets

* Browse targets as cards or list.
* Create a new target.
* Open and edit a target.
* Add/edit/delete descriptions.
* Add/edit/delete sample queries.
* Edit target action as URL or SQL.
* Add target inputs backed by target value sets.
* Delete targets.
* Inspect target maintenance jobs/status.

### Target Value Sets

* Create a new target value set.
* Add values and synonyms manually.
* Set a default value.
* Edit/delete values and synonyms.
* Generate/sync values from a database table column.
* Generate values with AI, if configured.
* Delete target value sets.

### Query Tester

* Run a query against a selected search-space version.
* Inspect ranked targets.
* Inspect extracted target inputs.
* Upvote/mark the best target.
* Downvote bad matches.
* Choose another target when the expected result is not in the top results.
* Mark a query as irrelevant.
* Create a target from a failed/no-good-result query.

### Test Runs

* Upload curated regression questions from `test_run.json`.
* Run tests from uploaded questions.
* Run tests from sample queries.
* Run tests from past user queries.
* View past test runs.
* Inspect run status, progress, Top-1/Top-3/Top-5 accuracy, and passed queries.
* Drill into individual query results and target-input mismatches.
* Cancel active runs and delete old runs.

### Search History And Feedback

* Review real user queries.
* Inspect feedback details for a query.
* Use query history as input for new descriptions, sample queries, and regression tests.
* Review additional free-text feedback.

### Users And Settings

* Add users.
* Grant search-space access.
* Manage runtime settings such as thresholds, weights, model configuration, deduplication, and resource controls.

## Gaps In The Current Story

* Target value set creation is not currently shown, even though it is one of the clearest ways to explain controlled vocabulary.
* Editing a target action is not shown. This is important because it proves TAS returns executable application actions, not just labels.
* Adding sample queries is not shown. This is a good companion to adding descriptions because it explains the two kinds of expert evidence.
* Publishing the draft after validation is only implied. The lab should explicitly close the loop: fix, test, review diff, publish.
* Rollback/delete-draft behavior is not shown. Enterprise developers will ask how to recover from a bad curation change.
* Search-space diff/current draft changes are not shown, but they are very useful for the governance story.
* Query Tester's "Choose another target" and "Mark question as irrelevant" workflows are not shown.
* Dashboard metrics are only referenced lightly. They should be used as the final proof page.

## Recommended Demo Arc

1. Start with the broken query and correction loop.
2. Show that the correction is isolated in a draft.
3. Add a phrase as a description.
4. Add or edit a target value set synonym to show controlled vocabulary.
5. Add one sample query to show another form of expert evidence.
6. Run regression tests.
7. Review diff/current draft changes.
8. Publish the draft.
9. Return to the dashboard and show metrics/history as the operational record.

## Optional Advanced Branches

* Create a brand-new target from a failed query.
* Edit a target action URL to pass a new target input.
* Sync a target value set from a database table column.
* Use search history to create a new regression question.
* Show user/search-space access control.
* Show settings only as an admin/operator appendix; avoid making it part of the main story.
