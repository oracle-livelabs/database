# SEER MANUFACTURING: wording review

Completed 22 September 2026 using the supplied JARGONCHECK rubric and the antislop core skill. The user authorized wording fixes while preserving SQL, structure, artwork, and Oracle UI labels. The attached rubric's financial examples were treated as editing examples; the workshop remains about manufacturing.

## Coverage and changes

Reviewed all 11 lessons, all 19 existing Markdown files, both native notebooks, both manifest descriptions, quiz questions and explanations, schema documentation, stack documentation, image captions, SVG text, and fresh OCR records for all 58 current raster images. Structured records and executable files were scanned for wording; their technical content was preserved.

Updated 20 files. Changes replace vague roles and abstract nouns with the person, record, or action learners need. They also remove repeated claims about avoiding extra data stores and correct two stale notes: Getting Started no longer says captures are pending, and the optional graph notebook no longer says cycle counts have never been measured.

| Before | After |
| --- | --- |
| application payload | JSON document for the application |
| application shape | document structure |
| business users | production analysts |
| operational impact | active production orders or units that may need review |
| review scope | orders to review |
| assigns each one to the closest active plant | lists the closest active plant for each one |
| Identify components that may face a quality escalation | Flag components for quality review |
| Provider/credential plumbing | Provider and credential configuration |

The spatial explanation now describes distance to a polygon correctly, including zero for points inside it. The OML explanation keeps the synthetic-data limitation and avoids implying that the exercise establishes future predictive accuracy. Quiz scoring and all correct options remain unchanged.

Lanham's method for choosing active verbs and cutting excess words informed the sentence edits: name the actor, state the action, and retain the facts needed to understand it. Reference: [MIT handout adapted from Richard Lanham](https://ocw.mit.edu/courses/21l-007j-after-columbus-fall-2003/4cceed8afab4e80aba65fc83b8ec27ed_how_to_3.pdf).

## Antislop delivery gate for this copy edit

- PASS, R-02: no em dashes remain in authored Markdown prose or reviewed raster OCR text.
- PASS, R-15/R-16: instructions name the action and record; no flagged marketing terms remain in authored prose. Oracle UI labels are preserved as requested.
- PASS, R-17/R-18/R-36/R-38: synthetic manufacturing records and fictional teaching personas remain explicitly identified. Model and spatial limitations remain visible; no customer, security, or performance claims were added.
- PASS, R-22/R-23/R-31: the original character banners connect each lab to its named manufacturing role. The introduction and ERD explain the shared quality investigation and data relationships. No artwork or screenshots were edited by this wording pass. All 43 authentic captures retain their starting bytes. Ten illustration files changed outside these wording edits: two retain identical decoded pixels, and eight have different dimensions. The current files are retained; the earlier exact-pixel banner comparison is historical, not a new certification of resized files.
- PASS, R-05/R-24/C-3: the 11-lesson sequence, 40 numbered tasks, manifests' navigation fields, and link targets are preserved. The local validator found no broken local links or schema references.
- PASS, R-26/R-35, edited-content regression: all 11 pages rendered on a fresh local address; task expansion worked, and all seven quiz answers produced the completion badge. This is not a new test of every Oracle platform control.
- PASS, C-1/C-5: wording describes observable query results and identifies who reviews them. Historical database results remain historical; no database execution was claimed for this copy edit.

Visual direction is retained: static Redwood characters, manufacturing records and machinery, Oracle LiveLabs typography and navigation. ENERGY 2 / RHYTHM 2 / MOTION 1 describes the existing illustrated lessons and static step-by-step exercises. The character banners identify the person and problem; screenshots show the matching database operation; tables compare technical choices; spacing separates instructions from code. No new visual technique, component, theme, or layout was introduced.

UI-wide mobile, contrast, keyboard, loading/error-state, and theme certification was not part of this wording pass. Those antislop UI gates are not claimed as newly passed. The user explicitly required preserving artwork, structure, and Oracle UI labels.

## Preservation and validation

- All 63 SQL blocks are byte-identical to the pre-review copies. Other fenced executable examples are unchanged; only quiz prose was edited within its quiz block.
- Both notebooks retain all code, paragraph order, visualization settings, and cleared result state: 8 and 43 paragraphs.
- Hash comparisons confirm 66 protected code, deployment, and image files are unchanged, including the single loader, Terraform files, SQL templates, and all 43 authentic screenshot files. Ten illustration files differ from the starting snapshot outside this edit operation; see the image-change note above.
- All 116 source-workshop files match this review's starting snapshot. This statement concerns the wording-review interval; the older conversion baseline distinction remains documented separately.
- Static schema, fixture, foreign-key, notebook, manifest, image-reference, code-fence, and quiz checks passed. Coverage remains 43 authentic screenshot positions and 63 image references, with zero pending captures.
- The complete ZIP is rebuilt after this review and checked for CRC integrity and exact correspondence to current repository files. Only macOS metadata is excluded; archive details are supplied separately.

Necessary exceptions are literal manufacturing terms such as surface finish and surface hardness in preserved SQL fixtures; exact Oracle labels and technical identifiers; and historical image-generation prompts, which are provenance records rather than current learner copy. No raster editing was needed. OCR can miss text; this pass reran OCR on all current raster files. The earlier banner comparison remains a record of the previous conversion checks.

No database objects, profiles, grants, or data were changed. Fresh SQLcl bootstrap, stack API-key authentication, Terraform provisioning, and the LiveLabs green-button phase remain outside this completed wording review.

## Changed files

- `README.md`
- `production-operations-dashboard/production-operations-dashboard.md`
- `quality-review-oml/quality-review-oml.md`
- `workshops/tenancy/manifest.json`
- `workshops/sandbox/manifest.json`
- `production-order-duality/production-order-duality.md`
- `final-quiz/final-quiz.md`
- `introduction/introduction.md`
- `plant-routing-spatial/plant-routing-spatial.md`
- `selectai-agent/selectai-agent.md`
- `selectai/selectai.md`
- `production-quality-network/production-quality-network.md`
- `production-quality-network/files/getting-started-material-flow-graph.dsnb`
- `production-quality-network/files/manufacturing-production-quality-graph-studio.dsnb`
- `component-quality-vector-search/component-quality-vector-search.md`
- `getting-started/getting-started.md`
- `validation/schema-contract.md`
- `validation/validation-report.md`
- `validation/workshop-map.md`
- `validation/manual-database-checklist.md`
