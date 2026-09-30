# SEER HIGHTECH conversion and validation

The Seer HighTech workshop has been converted, shortened, tested against the supplied Autonomous AI Database and updated with 48 authentic worksheet captures and six related application captures. The learner archive has been rebuilt. The focused instruction changes produced one correct agent retest and a narration with all requested totals; narration format compliance and repeated-run reliability remain unqualified. The deterministic SQL comparison remains in the lesson. The six application captures are complete; fresh provisioning validation remains outstanding.

## Scenario and preserved structure

Seer HighTech assembles and tests electronic control modules using purchased packaged semiconductors. An electrical leakage-current concern leads the team through test observations, semiconductor lot SEMI-91A7, test station ATE-017, affected build commitments and fulfillment options. This is electronics assembly and testing, not wafer fabrication.

All 136 immutable Manufacturing source files still match the initial hashes. Both manifests retain eleven lessons and forty tasks. There are 63 SQL blocks: one deterministic agent-answer verification query was added and the optional reset appendix was removed. Both notebooks retain eight and 43 paragraphs. The data model retains fifteen tables, eighteen foreign keys and unchanged numeric fixtures. Terraform deployment logic and authentication are preserved; the loader filename references reflect HighTech.

The second editorial pass reduced learner prose from 8,873 to 6,817 words (23.2%). It shortened definitions, repeated setup and result summaries while preserving every task, objective, code block and screenshot. The earlier pass reduced 11,863 to 8,819 words before runtime additions. See SEER-HighTech-editorial-sweep.md for that comparison.

The subsequent jargon/antislop follow-up applied only approved findings 4–7: corrected the OML objective and two task headings, split the training-label explanation, clarified notebook prose, and made Select AI checks and Agent model restoration easier to follow. All executable code and images remain unchanged. See anti-slop/follow-up-001-2026-09-29.md for the approved scope and checks; interface findings 1–3 remain open.

A later learner-facing correction rewrote all five Lab 7 prompts as business questions, removing SQL expressions and schema identifiers from the prompt text. Tasks 3/4 share the same question; Task 5 adds category and planned units; Task 6 retains the table and exact-totals requirements in plain language. Technical correctness checks remain in the review steps. These new prompts have not been rerun against Oracle: the existing test database returned HTTP 571 (Database Connection Error). Existing screenshots are labeled as example outputs. See SEER-HighTech-Select-AI-natural-language-update.md for checks and the live-retest boundary.

## Validation

The learner instructions assume a new database provisioned by the LiveLabs green button. Repeat-run advice in Labs 2, 3, and 8 and the Agent reset appendix have been removed. The supporting README follows the same lifecycle, and the loader's missing-role diagnostic no longer instructs a rerun. Model restoration and checks within the same exercise remain. See SEER-HighTech-fresh-sandbox-update.md for the sweep and verification.

- All 154 static checks and the source/structure/domain audit pass. Fixture constraints and relational arithmetic were first checked in SQLite, then exercised in Oracle during the manual live run.
- Canonical SQL and the single-entry loader ZIP agree byte-for-byte. All 1,024 customer requirement documents parse and generated strings fit declared column sizes.
- Manual loader assertions passed before lesson mutations. Dashboard, JSON duality, vector search, SQL property graph, Spatial and SQL OML exercises completed; guarded JSON/vector reruns behaved as intended.
- Primary Graph Studio notebook completed and displayed the table and graph results. All 43 optional PGX paragraphs exported with SUCCESS, including 24 executable paragraphs. Graph Studio switched four scalar outputs to Graph despite their saved Table defaults; concise Table-selection guidance was added and code was preserved.
- AutoML completed five candidate models. The synthetic fixture's high scores do not establish predictive quality on future data.
- Initial Select AI narration omitted totals and the initial agent answer was incorrect. After focused instruction changes, one agent run matched all five verified rows and narration included all ten numeric totals. Narration returned a list instead of a table. Successful execution remains separate from answer correctness; repeated-run reliability is not claimed.
- 48 database/Graph Studio/AutoML placements and 6 related application views use authentic shared-browser page-only captures. Application captions use the approved scene-name format. Persona artwork was preserved or narrowly adapted; no screenshots were fabricated.
- Raster OCR was rerun after captures. Text, SQL, notebooks, metadata and diagram residue checks pass.
- Local LiveLabs renderer and quiz checks are documented separately in browser-results.json and browser-live-update.json. These are local preview checks, not a green-button provisioning test.
- ZIP integrity, exact entries and byte-for-byte agreement with 100 intended learner files pass.

See SEER-HighTech-screenshot-update.md for the latest captures and focused instruction retest, and SEER-HighTech-live-validation-report.md for the earlier runtime observations and execution boundaries.

## Image and link sweep

The prior browser sweep checked all eleven lesson pages and 63 image placements, including 23 lazy images. The six newly added application captures are checked separately in this update. The earned quiz badge, linked schema SVG, and all six images in Oracle’s shared help page also load. The quiz reached 7/7 with its badge visible.

The prior sweep found all existing local references resolving. The six new application images were verified in the current package and local preview. Eight authored lesson links, generated navigation anchors, both workshop launchers, the notebook and loader downloads, and external documentation/footer destinations were checked. The stale Ad Choices footer redirected to a contracts page; both launchers now link to [Oracle’s current cookie and advertising-choice guidance](https://www.oracle.com/legal/privacy/privacy-policy/#11).

One upstream content issue remains: Oracle’s shared help page links database password restrictions to [Responsys password guidance](https://docs.oracle.com/en/cloud/saas/marketing/responsys-user/Account_PasswordRestrictions.htm). That destination loads, but is the wrong product; the externally hosted page was not modified. No missing local images or broken local links remain. Evidence is in `validation/image-link-audit/`. This sweep did not rerun Oracle exercises or send support email.

## Remaining work and limits

All six application capture placements now show the linked live HighTech demo. Fresh SQLcl invocation, supplied stack API-key bootstrap, Terraform validation/plan/apply and LiveLabs green-button reservation/login remain unrun. No learner package was published; notebook imports were limited to the authorized test database. AI model output remains variable. The initial agent failure is retained as historical evidence; one revised run passed the SQL comparison, without establishing repeated-run reliability. Narration table formatting and the optional PGX repeat-session property mismatch remain open.

## Package

SHA-256: `b16b93d8c3972155a28fc79dcff595ffdfabeaf68d60fbbf6a92c71ce00fdfcb`

Archive: `/Users/mkowalik/Documents/Codex/2026-09-29/files-pasted-by-the-user-convert/outputs/SEER-HighTech-LiveLabs-production.zip`

The archive contains all 100 current learner files, both notebooks, launchers/manifests and complete supporting stack. It excludes maintainer validation/history, obsolete source captures, the archive itself and macOS metadata. Current evidence remains in `/Users/mkowalik/Documents/GitHub/oracle-livelabs/database/livestack-workshop-hightech/validation`. Historical Manufacturing evidence under source-baseline never establishes a HighTech pass. The production filename follows the request and does not imply completed provisioning qualification.
