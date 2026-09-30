# SEER HIGHTECH — LLUSER learner pass

The core exercise sequence was executed through the shared browser as LLUSER. Database execution completed, but the AI agent's answer failed the lesson's SQL comparison. Screenshot replacement is unfinished: the database browser viewport clips wide results. The existing production ZIP has not been refreshed for this pass.

## Execution boundary

- Used the supplied, prepared Autonomous Database. No ADMIN login, privilege grants, model loading, direct SQL REST calls, or SQLcl execution in this pass.
- Followed the displayed lessons, using their documented repeat-run paths where objects already existed. This was not a fresh-schema or LiveLabs provisioning test.
- The shared browser's Copy button returned an empty clipboard; displayed code was read from the page and pasted into SQL Worksheet through the browser clipboard.
- Notebook downloading failed in the shared-browser download handler. The exact linked files from the local workshop were imported with the browser file chooser. Import and execution were tested; downloading was not passed.

## Results

| Exercise | Observed result |
| --- | --- |
| Getting Started | USER and CURRENT_SCHEMA both LLUSER. Prepared environment substituted for provisioning. |
| Lab 1: dashboard | Original and changed investigation queries each returned 10 rows. Original first result: Power control module P07, similarity 0.5372, 20 active orders and 2,494 units. |
| Lab 2: JSON duality | Document and relational projections agree for order 900001, released status and production0001@example.com. Guarded repeat insert inserted zero rows; update changed one row and committed. |
| Lab 3: vectors | Existing ADMIN-owned embedding model accessible to LLUSER. Guarded vector update changed zero rows. Distance, similarity and customer follow-up queries returned results. |
| Lab 4: graph | Direct SQL and property-graph queries each returned four rows. Ordinary multi-hop UNION returned 64 rows; graph multi-hop query returned 21. Three shared-lot pairs returned. Fresh primary notebook ran: PO-8841 graph has nine vertices/twelve edges; shared-lot graph has six vertices/ten edges. |
| Optional PGX notebook | Imported and ran the supplied notebook, then inspected graph, ranking, shortest-path and hop results. Repeat-run property naming needs correction or clarification; see below. |
| Lab 5: spatial | All four queries and the Chicago routing variation returned results. New York has five zero-distance plants, Chicago three. Milwaukee distance is 82.02 km/50.96 miles; routing returns 25 rows for each region. |
| Lab 6: OML | Documented model recreation completed as LLUSER. Twelve rows scored. A fresh AutoML experiment completed five candidate models; GLM confusion matrix has zero off-diagonal values. These synthetic, same-window labels do not establish future prediction quality. |
| Lab 7: Select AI | Generated SQL and both tabular answers matched the expected five component rankings. Narrative omitted requested numerical totals and quantities: incomplete answer. |
| Lab 8: agent | Documented reset/recreation completed as LLUSER. RUN_TEAM finished with SUCCEEDED status, but returned repeated components and incorrect totals. The fixed verification query exposed the error. Original model restored and verified. Optional follow-up challenge was not run. |
| Lab 9: quiz | Seven correct answers; 100% and achievement badge displayed. |

## Findings requiring attention

1. **Agent execution success does not establish answer accuracy.** The answer returned repeated P07/P08 components and material values of 45,310, 45,080, 44,850, 43,930 and 43,700. The correct SQL comparison is below. Tool history shows a request with invented singular table names and grouping by planned units. The tool returned the same incorrect values that appeared in the final answer. The requested query is not proof of the exact SQL ultimately executed by the tool.
2. **Select AI narration omits requested numbers.** Names, categories and ranking agree with the tabular answer; material totals and quantities are absent.
3. **Optional PGX repeat-run property mismatch.** The fresh personalized PageRank call returned a property named `personalized_pagerank_2`; the following supplied query reads `personalized_pagerank`. In this reused graph session, that query can read an older property. The ranking output is therefore not sufficient proof that it used this run's new property. No hidden graph reset was performed.
4. **AutoML metric caveat.** Balanced accuracy and accuracy display 1.0000, while ROC AUC displays 0.0000. This pass does not certify the AUC metric. GLM correctly classified 40.82% REVIEW and 59.18% STABLE in its displayed confusion matrix.
5. **Screenshot publication remains pending.** New captures contain page content only, without Chrome tabs/address bar. Several narrow or full-page captures clip columns or leave excessive blank space. They were retained as working evidence and were not installed as publication replacements.

| Component | Scheduled material value | Planned units |
| --- | ---: | ---: |
| Pressure sensor P15 | 585,580 | 2,546 |
| Pressure sensor P07 | 532,450 | 2,315 |
| Encoder P09 | 520,800 | 2,480 |
| Encoder P01 | 519,750 | 2,475 |
| Pressure sensor P14 | 511,290 | 2,223 |

The original `cohere.command-a-03-2025` model was restored after the agent exercise. The learner's supplied password was not included in this report or evidence bundle.

## Changes and checks

Fixed two Markdown identifiers in the Select AI instructions (`LINE_TOTAL` and `SETUP_COST`) so underscores no longer render as italics. Static validation and the source/structure/domain audit pass; the immutable Manufacturing source remains unchanged. No screenshot assets were installed in this pass, so the prior image OCR and package checks are historical checks, not fresh screenshot validation.

Next: widen the shared database browser panel, capture readable results and dialogs, resolve the optional PGX repeat-run issue, update screenshot coverage, rerun OCR, and rebuild/verify the learner archive. The six separate application views, fresh bootstrap and LiveLabs provisioning remain outside the evidence supplied by this prepared database session.

The evidence ZIP contains the observed text, draft captures and their SHA-256 manifest. It is maintainer evidence, not a learner publication package.
