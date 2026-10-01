# SEER HIGHTECH live validation — 29 September 2026

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: TODO - x minutes


## Latest shared-browser capture and instruction retest

48 page-only captures now replace the earlier images. The revised agent returned the five verified rows in one fresh conversation; revised narration included all ten totals but used a numbered list instead of the requested table. The original profile model was restored. See shared-browser-capture-report.md for the current results and limits. The earlier observations below remain historical evidence.

The workshop's database exercises were executed against the user-provided Autonomous AI Database as LLUSER. The loader assertions, relational/JSON/vector/spatial/graph exercises, SQL model training and scoring, primary Graph Studio notebook, optional PGX notebook and AutoML completed. Select AI generated SQL and query results were checked against independent SQL. Agent execution completed, but its answer contained incorrect totals; answer accuracy is an open limitation, not a passed check.

## Execution boundary

The canonical loader was executed in ordered sections through Database Actions and its authenticated REST SQL endpoint. ADMIN supplied the 384-dimensional ALL_MINILM_L12_V2 model and the required access; resource-principal access and the existing OCI policy supported GENAI. This proves this manually prepared database workflow. It does not prove a fresh SQLcl run, stack API-key bootstrap, Terraform validation/plan/apply, or LiveLabs green-button reservation/login workflow. No new database was provisioned by this validation run.

## Results

| Area | Observed result |
| --- | --- |
| Loader | All original assertions passed before lab mutations; 15 tables, 192 component embeddings, graph/duality views and spatial indexes loaded. |
| Dashboard | Initial and follow-up queries returned ten ranked rows. |
| JSON duality | All 14 blocks completed; order 900001 inserted and released; JSON projection matched relational rows. Repeating the guarded insert added zero rows. |
| Vector | All eight blocks completed; 384-dimensional model, 192 teaching vectors, distance/similarity and customer-site queries returned results. Repeating the guarded embedding update affected zero rows. |
| SQL property graph | Main queries completed; direct trace four rows, four-hop trace 21 rows, shared entities three rows. Reference DDL agrees with executed loader definition. |
| Spatial | All four queries completed; containment and 25-row routing result inspected in Database Actions. |
| SQL OML | All five blocks completed; GLM created and twelve component predictions returned. |
| Graph Studio primary notebook | Imported and ran all eight paragraphs, including three SQL queries. Nine-row table, nine-vertex/twelve-edge production graph and six-vertex/ten-edge shared-lot graph displayed. |
| Optional PGX notebook | Prerequisite PGQL graph created from the loader's supplied definition. All 43 paragraphs exported with SUCCESS, including five Python and nineteen PGQL executable paragraphs. Loaded 105 vertices/114 edges; degree, PageRank, personalized PageRank, paths and hop-distance queries succeeded. Center 534's one-to-five-hop cycle query validly returned no rows. |
| AutoML | Component Quality Review completed with five models: DT, GLM, GLMR, NN and RF. Each showed balanced accuracy 1.0000 on the synthetic fixture. GLM confusion matrix had no off-diagonal results; prediction impact highlighted defect rate. These same-window labels do not establish future predictive performance. |
| Select AI | All nine blocks executed. Generated SQL was independently executed and checked. Refined query returned expected top-five names and totals. Narration omitted numeric totals and requires comparison with SQL results. |
| AI agent | Setup, task/team run and history queries completed. SUCCEEDED was recorded, but original answer totals and duplicate component entries were incorrect. A clearer experimental prompt still returned the wrong fifth component. Cleanup removed the agent/tool; canonical objects were recreated and GENAI restored and verified as cohere.command-a-03-2025. |

The original lessons contain 63 SQL blocks. The live correction adds one deterministic comparison query, making 64. The graph appendix repeats loader DDL, rather than requiring a second creation of the same object. Database state now includes the exercises' inserts, teaching vector column, models, graph and experiment; fresh-loader assertions are evidence of the pre-lab state.

## Corrections from the live run

- The agent lesson compares all five component names, ranks, summed values and quantities with a fixed SQL query, and exposes tool INPUT/OUTPUT in history. A successful execution status is explicitly distinguished from answer accuracy. The model prompt and business data were not altered to conceal the failing answer.
- Select AI guidance checks names, rankings and numeric totals; missing or inconsistent narration sends the learner back to SQL results.
- Four optional PGX ranking/hop paragraphs opened as graphs despite their saved Table defaults. Concise guidance now tells learners to choose Table to read numeric columns. Query code is byte-for-byte unchanged. The degree table was verified in the live UI.
- Thirty-eight authentic database, Graph Studio and AutoML capture placements now accompany the matching steps. They are native Chrome captures of the actual HighTech run, with no image editing or fabricated outputs. Existing persona artwork remains separate.

## Correct comparison result

| Component | Category | Total material value | Planned units |
| --- | --- | ---: | ---: |
| Pressure interface module P15 Rev A | Sensing | 585580 | 2546 |
| Pressure interface module P07 Rev A | Sensing | 532450 | 2315 |
| Encoder interface module P09 Rev A | Motor control | 520800 | 2480 |
| Encoder interface module P01 Rev A | Motor control | 519750 | 2475 |
| Pressure interface module P14 Rev A | Sensing | 511290 | 2223 |

## Evidence and remaining limits

Raw SQL results, the executed PGX export, UI accessibility observations and comparison SQL are retained under validation/live-runtime, outside the learner archive. The unsupported WHENEVER SQLERROR wrapper in an early ORDS attempt was a harness error; the subsequent individual lesson blocks were executed successfully. A sandbox DNS failure and initial editor input problem are likewise not counted as lesson SQL defects.

Six separate application screenshots remain outstanding because no runnable HighTech application was included in the supplied source. No substitute application screens were fabricated. Fresh SQLcl/API-key bootstrap, Terraform and green-button provisioning remain unrun. External links and responsive/accessibility behavior were not comprehensively revalidated.

## Acknowledgements

* **Author** - TODO: Your Name, Your Title, Your Organization
* **Last Updated By/Date** - TODO: Your Name, Month Year
