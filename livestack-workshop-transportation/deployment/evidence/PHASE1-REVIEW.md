# Phase 1 review — Seer Transport

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: TODO - x minutes


Date: 2026-10-01

## Quality gate finding

The Phase 1 report correctly described a structurally transformed workshop, but it did not establish full completion. The loader, runtime SQL, learner-user workflow, and replacement screenshots were unverified. The review also found inherited “risk team / risk analyst” wording in the operations and Select AI labs and a converged query that attached a New York station to Chicago services.

## Corrections made

- Replaced the stale role wording with service operations language.
- Added a service region to each transport service and changed Lab 1 to select the nearest active station in that service's own region. The corrected live query returns Joliet Rail Station for Chicago services and New York Central for New York services.
- Added a dedicated passenger transportation loader and executed Labs 1–6 SQL against its data.
- Replaced generic passenger names and made the training label a function of the seeded activity values.
- Captured six screenshots from real Database Actions results. These are stored under `deployment/evidence/screenshots` because the browser session is ADMIN with `CURRENT_SCHEMA=SEER_TRANSPORT`; they are validation evidence, not learner-facing `LLUSER` images.

## Phase 1 gate status

The source workshop remains unmodified. Both target manifests have the same 12 tutorial entries and resolve to existing lab files. All 60 copy blocks are balanced, and local image links resolve. Text audit found no Finance, Banking, Fraud, Mortgage, Retail, or Healthcare residue in the passenger workshop content.

Phase 1 is not fully release-complete: no learner-user LiveLabs session, Graph Studio notebook execution, AutoML interface run, Select AI or Agent execution, or final learner-session screenshots have been validated. The local LiveLabs quiz preview passed 7/7 questions and displayed the supplied Transportation badge. The Graph Studio notebook imported successfully, but the compute environment could not attach because the Free Tier daily usage was exceeded. The static and SQL evidence is described in `PHASE2-REPORT.md` without treating these remaining checks as complete.

## Acknowledgements

* **Author** - TODO: Your Name, Your Title, Your Organization
* **Last Updated By/Date** - TODO: Your Name, Month Year
