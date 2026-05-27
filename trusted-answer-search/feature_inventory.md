# Trusted Answer Search LiveLab Feature Inventory

This inventory is based on the shipped Admin APEX app metadata in `trusted_search/apex_ship/f610`, the Wikimedia sample, and the current LiveLab markdown.

## Priority Model

### P1: Main Story Features

These are the most important, differentiated Trusted Answer Search features. They belong in the primary Lab 4 path.

| Feature | Why It Matters | Where Covered |
| --- | --- | --- |
| Natural language to trusted target | Users ask normally, but the app routes to an approved report, URL, or query instead of generating an answer. | Lab 4 |
| Structured input extraction | Human language becomes controlled inputs such as language, project, period, and frequency. | Lab 4 |
| Controlled value sets and synonyms | Enterprise-safe vocabulary mapping, such as `past 24 months` to `2-year`. | Lab 4 |
| Executable target actions | TAS returns an application action, such as a URL or SQL-backed report, not just a label. | Lab 4 |
| Portal user feedback | End-user upvotes/downvotes become admin-visible operational signals. | Lab 4 / Lab 5 |
| Draft vs published governance | Published behavior is protected; experts clone to draft before changing search behavior. | Lab 4 |
| Feedback correction loop | Downvote a bad result, rerun the query, and see the correct result move to Rank #1. | Lab 4 |
| Deterministic search | The same query against the same version returns stable behavior. | Lab 4 |

### P2: Deep-Dive Features

These are natural follow-up questions once the main story lands. They are covered in Lab 5.

| Feature | Natural Follow-Up Question | Where Covered |
| --- | --- | --- |
| Regression test runs | Did the fix help, and did it break anything else? | Lab 5 |
| Top-1/Top-3/Top-5 accuracy | How do we measure search quality? | Lab 5 |
| Individual test result inspection | Which specific query passed or failed, and why? | Lab 5 |
| Add sample queries | Besides descriptions, how do experts teach examples of user language? | Lab 5 |
| Inspect target action URL/SQL | How does TAS connect to my real application workflow? | Lab 5 |
| Review target value set synonyms | Where do canonical values and synonyms live? | Lab 5 |
| Search history | What are users actually asking? | Lab 5 |
| Additional feedback | What did users say beyond upvote/downvote? | Lab 5 |
| Review draft changes/diff | What exactly changed before publish? | Lab 5 |
| Publish improved draft | How do approved changes reach the portal app? | Lab 5 |
| Recovery path | What happens if a draft or published version is wrong? | Lab 5 |
| Dashboard metrics | How does this feel like an operational system, not just a search box? | Lab 5 |

### P3: Appendix Or Instructor Notes

These are real features, but they are lower priority for the workshop story.

| Feature | Reason Lower Priority |
| --- | --- |
| Create/delete search spaces | Setup/admin plumbing; covered only where needed. |
| Import/export metadata | Important operationally, but not part of the core value moment. |
| Delete old test runs or cancel active runs | Admin hygiene. |
| Browse targets as cards or list | Useful UI detail, but implied by Search Targets workflows. |
| Target maintenance jobs/status | Operational detail for administrators. |
| Users and search-space access | Enterprise-relevant, but better as an appendix or separate admin lab. |
| Runtime settings, thresholds, weights, model configuration | Powerful, but can distract from the trusted-search story. |
| Generate/sync values from table columns | Advanced setup path requiring more application context. |
| AI-generated value sets | Interesting, but should not compete with the governed deterministic message. |

## Current Coverage

| Feature | Covered | Where |
| --- | --- | --- |
| Green-button setup | Yes | Get Started |
| Manual APEX app setup | Yes | Lab 3 |
| Create a search space | Yes | Lab 3 |
| Import search targets and target value sets | Yes | Lab 3 |
| Load regression questions from `test_run.json` | Yes | Lab 3 / Terraform |
| Publish the sample search space | Yes | Lab 3 / Terraform |
| Run a natural-language query | Yes | Lab 4 |
| Inspect target inputs | Yes | Lab 4 |
| Open an executable target action | Yes | Lab 4 |
| Leave portal user feedback | Yes | Lab 4 |
| Review portal feedback in Admin | Yes | Lab 5 |
| Clone published version to draft | Yes | Lab 4 |
| Published-version editing guardrail | Yes | Lab 4 |
| Downvote a bad result | Yes | Lab 4 |
| Add a target description | Yes | Lab 4 |
| Controlled synonym/value mapping | Yes | Lab 4 |
| Deterministic repeated search | Yes | Lab 4 |
| Run/view test runs and quality metrics | Yes | Lab 5 |
| Add a sample query | Yes | Lab 5 |
| Inspect target action URL and inputs | Yes | Lab 5 |
| Review target value set synonyms | Yes | Lab 5 |
| Search history | Yes | Lab 5 |
| Additional feedback | Yes | Lab 5 |
| Review draft changes/diff | Yes | Lab 5 |
| Publish improved draft | Yes | Lab 5 |
| Recovery path | Yes | Lab 5 |
| Dashboard metrics | Yes | Lab 5 |

## Remaining Gaps

The current workshop intentionally does not walk through every admin feature.

* Creating a brand-new target from a failed query is not shown.
* Choosing another target when the expected result is not in the top results is not shown.
* Marking a query as irrelevant is not shown.
* Editing a target action is not shown; the lab inspects one instead.
* Creating a new target value set is not shown; the lab reviews an existing one.
* User administration and runtime settings are not shown.

These are good candidates for an optional advanced appendix after the core LiveLab is stable.
