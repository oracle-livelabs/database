# Phase 1 result: Hospitality LiveLabs workshop

Phase 1 repository transformation is complete, with runtime validation and environment-dependent screenshots explicitly pending. Phase 2 has not started.

Target: `/Users/mkowalik/Documents/GitHub/oracle-livelabs/database/livestack-workshop-hospitality`

Reference provenance and source hashes are preserved outside this workshop in the migration-evidence deliverable.

## What changed

The workshop now follows **Seer Hotels**, a fictional hotel group. The introduction, setup, nine labs, both navigation variants, two notebooks, quiz, and editable vector assets use a coherent hospitality model. The original lab order, task counts, all 60 SQL blocks, Oracle capabilities, copy controls, and LiveLabs rendering conventions are retained. The duplicate Task 5 heading in the graph lesson was renumbered without moving or removing a task.

The core entities are **HOTEL_PROPERTIES, STAY_OFFERS, GUESTS, RESERVATIONS, and RESERVATION_NIGHTS**. Offers identify a room type and rate plan at a property. Reservations carry property and guest keys, check-in/out dates, status, and nightly-charge lines. Guest arrival points, visitor regions, service posts/alerts, booking evidence/cases, and optional loyalty membership support the remaining labs.

Naming uses unquoted snake-case SQL identifiers, `_ID` keys, `_V` views and `_DV` duality views. `LLUSER`, `GENAI`, and Oracle package/model names are retained. The machine-readable contract defines 24 table/view objects and 18 foreign-key relationships, with ownership and creation timing recorded.

## Significant transformations

| Area | Hospitality change |
| --- | --- |
| Dashboard | Service alerts, affected reservations, semantic stay-offer matches, JSON reservation activity and nearby hotel context |
| JSON | Reservations with stay dates and property; room-night charges at hotel rates; optional SERVICE_FEE is separate from room revenue; insert/update examples remain |
| Vector search | Accessible-room concern uses step-free-access descriptions; joins find guests with pending, confirmed or checked-in reservations |
| Graph | Reservations, shared booking devices and tokenized payment references support booking-abuse review; styles, seeds and notebook names updated |
| Spatial | Guest relocation to nearby active hotels replaces service-center routing; distance is explicitly separate from date-specific room availability |
| OML | Stay-demand classification uses room nights, booked room revenue and guest-post activity; unsupported prior accuracy/ranking claims removed |
| Select AI / Agent | Four hospitality tables, precise booked-room-revenue prompts and NINA_HOSPITALITY_* objects |
| Optional PGX | Loyalty-points transfers preserve PageRank, personalized PageRank, cycles, shortest paths, degree and hop-distance exercises |

Notebook execution results and obsolete graph runtime metadata were cleared. A changed identifier is never presented as a newly executed result.

## Screenshots and illustrations

**Actually regenerated from the local hospitality workshop:**

- `introduction/images/details-accordion-closed.jpg`
- `introduction/images/details-accordion-expanded.jpg`

An additional real browser capture, `hospitality-quiz-verified.png`, records the 100% quiz result and rendered hospitality badge in the delivered outputs.

**Not regenerated:** 54 source screenshots or worksheet illustrations require a hospitality Database Actions, Graph Studio, AutoML, Select AI/Agent or application environment. The source has no deployment/loader files or connection details, and no connected browser session provided such an environment. These assets were excluded instead of leaving misleading prior-domain content. Their asset IDs, intended target filenames and reasons are listed in the [complete image inventory](validation/screenshots.md).

Nine generic raster images and five navigation SVG illustrations were retained. A static cartoon ERD now explains the five core entities in the introduction, with a link to the full schema. Its five relationships were checked against the schema contract. Four existing native SVGs were edited (welcome illustration, two graph illustrations, completion badge); these are not screenshots. Twelve obsolete illustrations/reference captures were omitted; their instructional meaning remains in prose. All 86 original image assets are accounted for. The original source assets remain unchanged.

## Validation performed

- **PASS: source immutability.** SHA-256 comparison covers all 104 source files, including images and notebooks, and detects additions/removals.
- **PASS: structural equivalence.** Both manifests retain the same sequence, all 40 task headings, and all 60 SQL blocks. Paths changed only for domain names, excluded visual assets, and the added validation documentation.
- **PASS: internal links and structure.** Local lesson, image, notebook and audit-document targets resolve; lab/task shortcuts, Markdown fences, copy wrappers, and details tags pass checks. Both manifest JSON files and nine SVGs parse.
- **PASS: bounded static SQL/contract review.** 259 qualified base-column references match the specified objects; 18 FK endpoints resolve; the reservation JSON keys agree across duality and JSON_TABLE; example nightly-charge arithmetic is consistent. This is not SQL compilation or database execution.
- **PASS: notebook checks.** Both exports parse, all 51 paragraphs remain, embedded settings JSON parses, five Python paragraphs pass syntax parsing, and cached results are absent.
- **PASS: legacy-domain audit.** The follow-up domain audit covers every target path and text file, including reports, validation code and nested notebook settings. Reference provenance is archived outside the workshop. The only prohibited words retained are executable detection rules in the validator; Oracle platform terminology remains where appropriate. See the [domain audit](validation/domain-audit.md).
- **PASS: original Phase 1 browser checks.** Introduction, Getting Started and all nine labs loaded with the LiveLabs renderer; task expansion worked; the tenancy route loaded; the worksheet shortcut navigated correctly; notebook links rendered; SQL copying was checked; the quiz returned 7/7 and its SVG badge loaded.
- **LIMITED: external links.** Direct HTTP checks reached PGQL successfully, but 19 Oracle requests timed out. The browser loaded the actual LiveLabs assets, and Oracle technical references were corroborated through web browsing. Do not interpret this as a full external-link health pass.

Detailed evidence and the rerunnable offline validator are under `validation/`. The browser report is dated evidence of the earlier run; the domain audit records the later checks. No Oracle SQL, PL/SQL, model training, AI call, infrastructure deployment, or Graph Studio import was executed.

## Remaining issues and Phase 2 focus

1. Inspect the Terraform/data-loader ZIP recursively, then reconcile it with the [schema contract](validation/schema-contract.md). No source DDL or loader exists in this Phase 1 reference, so the contract is a proposed implementation boundary, not a deployed schema.
2. Confirm primary/foreign keys, JSON dates, defaults, derived line totals, reservation-property/date invariants, initial duality permissions, seeded IDs, and rerun behavior. Run every SQL block against Oracle 26ai.
3. Preload dashboard embeddings and the booking graph before their labs; leave Lab 3's teaching vector column for the learner. Verify both notebook formats, optional PGX vertex identities and graph services.
4. Define and test hospitality OML labels/features, sufficient class examples and aggregation windows. The scoring perturbation is synthetic, not holdout accuracy evidence.
5. Configure the actual GENAI provider and privileges; verify generated revenue filters, tool behavior and history. LLUSER remains the workshop owner, not a production read-only identity.
6. Reconcile sandbox/tenancy provisioning instructions and Terraform outputs; then capture every pending database/application screenshot from the final implementation.
7. Recheck external links in the deployment environment. The containing source/target tree currently has no `.git` metadata; no commit was created.

The [Phase 2 checklist](validation/phase2-checklist.md) records the acceptance steps. The [workshop map](validation/workshop-map.md) records capability preservation and the reasons for the domain choices.

Latest update: Seer Hotels naming applied throughout; introduction data-model prose replaced with an illustrated ERD and short caption. Introduction screenshots were recaptured after the change.
