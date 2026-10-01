# HighTech workshop editorial sweep — second pass

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: TODO - x minutes


Reviewed all 11 lessons, both Graph Studio notebooks, and the workshop/supporting READMEs. Edited ten lessons. The quiz, notebooks, and READMEs remain unchanged because their current text is concise or necessary for execution.

This pass reduced lesson prose from **8,873 to 6,817 words (23.2%)**, removing 2,056 words from the current workshop. Counts exclude fenced code, image markup, HTML tags, and link destinations; they include headings and instructions. This is a text reduction, not a measured reduction in completion time.

## What changed

- Shortened glossary entries to definitions; kept examples beside the exercise that uses them.
- Removed repeated setup descriptions and screenshot labels that merely restated the surrounding step.
- Kept expected values and verification actions, including order 900001, released status, and the agent’s five-row SQL comparison.
- Condensed repeated explanations of JSON/relational access, vector ranking, and point-to-region distance.
- Removed Graph Studio’s duplicate paragraph index; the numbered steps already identify each query and visualization.
- Shortened the JSON comparison table while preserving ownership, storage, and application-use distinctions.
- Retained each character’s question, task transitions, and decisions based on the results. Kept the persona artwork and all authentic database captures.

## Per-lesson prose counts

| Lesson | Before this pass | After | Reduction |
| --- | ---: | ---: | ---: |
| component-quality-vector-search | 909 | 582 | 36.0% |
| final-quiz | 81 | 81 | 0.0% |
| getting-started | 465 | 340 | 26.9% |
| introduction | 555 | 496 | 10.6% |
| plant-routing-spatial | 924 | 638 | 31.0% |
| production-operations-dashboard | 552 | 454 | 17.8% |
| production-order-duality | 1,424 | 999 | 29.8% |
| production-quality-network | 1,070 | 807 | 24.6% |
| quality-review-oml | 922 | 789 | 14.4% |
| selectai | 909 | 753 | 17.2% |
| selectai-agent | 1,062 | 878 | 17.3% |

## Preservation and validation

Compared against a fresh snapshot taken immediately before this pass:

- All 40 tasks, every heading and objective, all 64 SQL blocks and other fenced code, and all 63 image references are unchanged.
- Both notebooks and all other shipped files are byte-identical, including screenshots, manifests, loader SQL/ZIP, and Terraform.
- The focused agent and narration prompts, SQL verification query, model restoration, setup/rerun guidance, and result-interpretation boundaries remain intact.
- Static checks and the source/structure/domain audit pass. All 136 immutable Manufacturing source files remain unchanged.
- Local LiveLabs rendering checks cover the refreshed introduction, JSON decision table, vector glossary, and Graph Studio walkthrough. These are page checks; Oracle exercises were not rerun for this prose-only change.
- The production ZIP was rebuilt with the same 94 learner files and checked for integrity, exact entries, and byte-for-byte agreement with the target. Maintainer reports and snapshots are excluded.

## Relationship to previous work

The first editorial pass reduced prose from 11,863 to 8,819 words. Subsequent runtime guidance and focused AI instructions brought the starting point for this pass to 8,873 words. The figures above compare only this new pass against that current baseline.

The previously captured 48 database/Graph Studio/AutoML placements remain unchanged. See [the screenshot update](SEER-HighTech-screenshot-update.md) for the latest live retest and remaining limits; this editorial pass does not establish new database or provisioning results.

## Acknowledgements

* **Author** - TODO: Your Name, Your Title, Your Organization
* **Last Updated By/Date** - TODO: Your Name, Month Year
