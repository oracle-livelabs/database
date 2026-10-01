# HighTech workshop editorial sweep

## Objectives

In this lab, you will:

* TODO: Add objectives

Estimated Time: TODO - x minutes

Reviewed all 11 lessons, both notebooks, and the learner/supporting README
files. Tightened 10 lessons and both notebooks; the quiz and already concise
READMEs needed no changes.

Lesson prose decreased from **11,863 to 8,819 words (25.7%)**. Counts exclude
fenced code, image markup, HTML tags, and link destinations; headings and
instructions are included. This measures text reduction, not a measured
reduction in workshop completion time.

## What changed

* Removed repeated Hands-on Scenario summaries after persona-led introductions
  and objectives.
* Removed five recap-only conclusions; retained the JSON decision table and
  agent access guidance.
* Shortened repeated explanations of the same data appearing as JSON and
  relational rows, graph hops versus joins, and geometry versus map output.
* Kept the story in each persona’s question, task transitions, and decisions
  based on results.
* Made result review more direct: compare specific values, inspect a shared
  record, or check the customer contact before acting.
* Shortened the introduction’s team table and repeated notebook setup prose.

## Per-lesson prose counts

| Lesson | Before | After | Reduction |
| --- | ---: | ---: | ---: |
| component-quality-vector-search | 1,193 | 909 | 23.8% |
| final-quiz | 81 | 81 | 0.0% |
| getting-started | 528 | 465 | 11.9% |
| introduction | 639 | 555 | 13.1% |
| plant-routing-spatial | 1,371 | 924 | 32.6% |
| production-operations-dashboard | 741 | 552 | 25.5% |
| production-order-duality | 2,168 | 1,424 | 34.3% |
| production-quality-network | 1,809 | 1,070 | 40.9% |
| quality-review-oml | 1,202 | 922 | 23.3% |
| selectai | 1,037 | 885 | 14.7% |
| selectai-agent | 1,094 | 1,032 | 5.7% |

## Preserved and checked

All 40 task headings and their sequence, 63 SQL blocks, every other fenced block
(including the quiz), learning objectives, and image references are unchanged.
Both notebooks retain every code paragraph, interpreter, visualization
configuration, and other non-Markdown field. All other shipped files match the
previous package hashes, including images, manifests, loader SQL/ZIP, Terraform,
and templates. The Manufacturing source remains unchanged.

The result-interpretation boundaries, setup prerequisites, rerun instructions,
model-restoration steps, and warnings about synthetic ML data remain beside the
relevant work. The JSON comparison is retained because it helps learners choose
an approach rather than merely recapping the lab.

Static validation passes. Local browser checks cover the edited introduction,
JSON, graph, and spatial pages with expanded tasks; these are rendering checks,
not Oracle execution. Live database validation and the 44 outstanding authentic
captures remain outside this editorial pass.

The updated production ZIP is rebuilt from the revised learner files. Maintainer
snapshots, reports, and validation scripts are excluded from it.

## Acknowledgements

* **Author** - TODO: Your Name, Your Title, Your Organization
* **Last Updated By/Date** - TODO: Your Name, Month Year
