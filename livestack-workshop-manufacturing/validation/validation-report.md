# Validation report: 23 September 2026

### Objectives

- Summarize the completed workshop validation, recorded results, and checks deferred to the green-button phase.

Estimated Time: **10 minutes**

**Manual workshop walkthrough complete; green-button phase not started.** All 43 planned database screenshots and six live-application examples are installed beside the matching instructions. The main labs, primary graph notebook, optional PGX notebook, AutoML, Select AI, agent test and quiz were exercised.

## Data model and loader alignment

The single canonical loader creates manufacturing plants, component revisions, customer sites, production orders and lines, inspections, traceability entities, work centers and material transfers. Its 15 tables, 18 foreign keys, four reporting/training views, JSON duality view, SQL property graph and three spatial indexes match the revised labs. The fixture includes 16 plants, 192 components, 1,024 customer sites, 3,739 orders, 4,985 lines and 1,536 inspections. All 15 live table counts and the loader assertions passed; 192 vectors have 384 dimensions. The OML view has 192 rows, evenly split between REVIEW and STABLE.

The loader ran in stages through Database Actions after interrupted sessions. The original completion marker and all assertions were observed. This verifies the loader SQL stages and loaded state, not a fresh end-to-end SQLcl invocation. Only the optional appendix's Python graph-source spelling changed during this walkthrough; executable loader SQL was retained. The optional PGQL graph was then created separately in Graph Studio and loaded with 105 vertices and 114 edges.

See [live-validation.json](live-validation.json), [recorded SQL results](live-sql-results.json), [PGX results](pgx-results.json), and the [schema contract](schema-contract.json). The reproducible [validator](validate.py) separately checks exact loader/fixture equality, relational constraints and arithmetic, manifests, local links, code fences, table and column references, notebook JSON/Python, quiz structure and deployment entry point. Its SQLite checks do not claim Oracle syntax validation.

## Live walkthrough results

| Exercise | Observed result |
| --- | --- |
| Converged dashboard | Baseline bearing query and revised drive-shaft search returned manufacturing results. |
| JSON and duality | JSON insert/update and relational/document projections agreed. Order 900001 and line 990001 were created. |
| Vector search | 192 teaching embeddings populated; component and affected-site searches returned results. |
| SQL property graph | Traceability queries and shared-lot pairs passed. Primary notebook displayed all 9 vertices/12 edges and the shared-lot view's 6 vertices/10 edges. |
| Optional PGX | All 43 paragraphs ran through the final two-hop query after correcting the case-sensitive source option to `pg_pgql`. PageRank, paths, personalized PageRank and hop-distance stages completed. |
| Spatial | Four queries returned region distances and nearest-plant routing results. |
| OML | SQL GLM created and scored 12 rows. AutoML completed with five models. Synthetic same-window labels explain the high scores; this is not a future-quality benchmark. |
| Select AI | SQL generation, execution, refinement and narrative passed after explicit lowercase order-status values were added to prompts. |
| Agent | Approved temporary Llama test succeeded in 32.019 seconds with one SQL tool call. Cohere was restored and verified. |
| Quiz | Refreshed browser run scored 7/7 and displayed the completion badge. |

The earlier Cohere agent request timed out after 300 seconds and six repeated successful SQL calls. Its history still shows RUNNING with a null end time. That historical row does not establish continued execution. Lab 8 now records the previous model, selects the tested model, and restores it after inspection or a failed request. Its five tasks remain in order; these three additional SQL blocks are the justified executable change.

After the labs, there are 3,740 orders and 4,986 lines, and the teaching vector column exists. Fresh-loader assertions deliberately expect the earlier state and should not be rerun against this occupied schema. The optional destructive agent-reset appendix was not executed.

## Images, structure and residue

All 11 lesson pages were rendered again after screenshot replacement: 69 image references loaded successfully, with no broken images. [Screenshot coverage](screenshots.md) records 43 authentic database captures and six live-application captures with their inline placement. Five generic platform screenshots remain. There are no pending capture markers.

Seven original persona banners have zero changed pixels outside their caption masks; the repeated Nina banner is byte-identical. Captions reflect manufacturing roles and scenarios. The introduction retains its static Redwood-style Jessica/Thomas scene and illustrated five-table ERD; the linked technical SVG and five relationships match the loader contract. OCR covers all 64 raster files. See [image review](image-review.json), [domain audit](domain-audit.json), and [structure comparison](structure-comparison.json).

The source workshop was not a write target. All 116 current source files match the existing source archive byte-for-byte. Eleven existing files differ from the original starting snapshot, including six banners, and one introduction image was added. The cause was not established; this conversion did not write to or restore the source. This distinction remains recorded in [source preservation](source-preservation.json).

Unavoidable platform content includes LiveLabs reservation labels, Oracle property-graph terminology and Graph Studio's built-in BANK_GRAPH, MovieStream and sales-history templates/tags visible in authentic service captures. These are not workshop data or business scenarios.

## Deferred validation

No Terraform or LiveLabs green-button provisioning was attempted. That phase must validate the fresh SQLcl invocation, stack API-key authentication, supplied inference-region/model values and bootstrap prerequisites. The manual tests used resource-principal authentication. Prior public URL HEAD checks timed out; local links and hosted renderer loading passed. Clipboard contents remain unverified although the copy control was exercised. See the [green-button checklist](green-button-checklist.md).

## Wording review update, 22 September 2026

The [jargon and antislop review](copy-review.md) updated 20 files while preserving all SQL, notebook code, task headings, and navigation. All 11 pages rendered and the revised quiz passed 7/7. No image writes were made by the wording edit. Ten illustration files changed outside those edits, including eight with changed dimensions. Earlier exact-pixel banner comparisons are historical; see [current image checks](copy-review-image-changes.json) and [fresh OCR](current-image-ocr.json). All 43 authentic database captures remain byte-identical; this follow-up adds six live-application captures.

## Acknowledgements

* **Author** - Matt Kowalik
* **Last Updated By/Date** - Matt Kowalik, September 2026
