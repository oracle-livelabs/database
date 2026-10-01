# Seer Transport — Phase 2 implementation and validation report

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: TODO - x minutes


Date: 2026-10-01

## 1. Executive summary

No separate passenger transportation implementation package was provided. A new loader was built from the Phase 1 Seer Transport domain model and tested against a fresh, dedicated `SEER_TRANSPORT` schema in the user's Toronto 26ai Autonomous Database. The existing Finance and Retail schemas were not changed. Labs 1–6 SQL ran successfully, with the property graph definition provisioned by the loader. Six Database Actions result screenshots were captured as ADMIN validation evidence.

## 2. Final target data model

`SERVICE_LINES` and `TRANSPORT_SERVICES` describe passenger services. `PASSENGERS`, `BOOKINGS`, and `BOOKING_LEGS` record demand and fare activity. `DISRUPTION_SIGNALS` and `SIGNAL_SERVICE_MENTIONS` connect service incidents to those services. `STATIONS` and `SERVICE_REGIONS` hold 4326 point and polygon geometry. `NETWORK_ENTITIES` and `NETWORK_RELATIONSHIPS` back `SERVICE_DISRUPTION_NETWORK`. `SERVICE_EMBEDDINGS` and `OML_SERVICE_DEMAND_TRAINING_V` provide vector and OML prerequisites. `BOOKINGS_DV` exposes relational booking rows as JSON.

The seed contains 60 services, 80 passengers, 180 initial bookings, 30 disruption signals, four stations, two regions, seven graph entities, seven graph edges, and 60 service embeddings. Lab 2 adds booking `900001` and confirms its status, so post-lab booking count is 181.

## 3. SQL loader changes

`load_seer_transport.sql` is a fresh-schema loader. It creates objects in dependency order, seeds deterministic passenger transportation data, creates the duality view and property graph, and generates embeddings with the ADMIN ONNX model. It has no DROP loop or cross-schema teardown. It intentionally stops if an existing table is present; it is repeatable for fresh provisioning, not an in-place reset script. The learner's vector column and OML model remain lab activities.

## 4. Infrastructure and access

No Terraform or OCI policy package was supplied or modified. A dedicated `SEER_TRANSPORT` validation user was provisioned with a data quota and the object creation privileges needed by Labs 1–6, plus `SELECT ON MINING MODEL ADMIN.ALL_MINILM_L12_V2`. The personal database already had the ADMIN model and `GENAI` profiles in other schemas. The validation user does not have a configured `GENAI` profile or demonstrated OCI Generative AI authorization.

## 5. Workshop changes from implementation

Lab 1 now joins each service to its own region before finding the nearest active station. The operations and Select AI personas use service operations language. Seeded names and OML labels were revised after result review. No Finance source file was modified.

## 6. End-to-end testing

- SQLcl connected to database `G2F29A6E45A23FC_LINDASANDBOXADB` as ADMIN, then to the isolated validation schema. Loader object creation and data loading completed without ORA/PLS/SP2 errors.
- Lab 1 converged SQL returned 10 rows, combining relational disruptions, vectors, JSON booking activity, and spatial station context.
- Lab 2's 14 copy blocks executed, including JSON column and collection creation, duality view replacement, booking insert, status update, and relational/JSON comparison.
- Lab 3's eight blocks executed, including vector column addition, embedding update, similarity search, and passenger follow-up joins.
- Lab 4's five runnable query blocks executed. The graph definition was created by the loader; the appendix definition was inspected rather than rerun against an existing graph.
- Lab 5's four spatial queries executed, including 25 passenger-to-station rows.
- Lab 6's five SQL blocks executed, including model creation and 12 scored service rows. The optional AutoML interface was not run.
- The six final representative read-only queries were rerun after the last data revision. Outputs are in `final-query-results.json`. The final loader was then replayed in a second fresh scratch schema: 60 services, 80 passengers, 180 bookings, 60 embeddings, 39 SURGE and 21 STABLE training rows, and the corrected 10-row converged query all passed. That scratch schema was removed after validation; `fresh-loader-check.txt` preserves the result.

These runs use SQLcl as `SEER_TRANSPORT` and Database Actions as ADMIN with `CURRENT_SCHEMA=SEER_TRANSPORT`. The Graph Studio notebook imported successfully as ADMIN, but its three paragraphs could not run. These checks do not prove the `LLUSER` learner login, Green Button, Graph Studio execution, or LiveLabs rendering.

## 7. Screenshots

Six real Database Actions results are in `screenshots/`: converged query, booking duality, vector similarity, SQL/PGQ graph, spatial routing, and OML scoring. `screenshots/graph-studio-imported-detached.jpg` shows the imported notebook with a detached compute environment. They are validation captures from the personal ADMIN browser session and are deliberately outside learner-facing lab pages. The supplied Transportation PNG badge replaced the old quiz badge. All learner-facing image links now target PNG files; 16 image links resolve, and no SVG assets remain. The local LiveLabs preview passed all seven quiz questions, showed the achievement badge and download link, and was captured in `screenshots/quiz-preview-pass.png`. It also rendered the Lab 1 learner page with the PNG persona card, captured in `screenshots/learner-page-lab1-png.png`. The current learner-facing navigation screenshots were visually reviewed for source-industry residue. This local preview does not establish a Green Button or learner login; see `QUIZ-AND-IMAGE-REVIEW.md`.

## 8. Repository consistency audit

Both manifests retain the source sequence and resolve to existing Markdown. All 60 `<copy>` blocks and code fences are balanced. Local image links resolve. Text search found no Finance, Banking, Fraud, Mortgage, Retail, or Healthcare terms in learner-facing Markdown, SQL loader, or notebook text. The Finance source checkout has no modified tracked files.

## 9. Content quality

The stale risk-role wording was corrected and the regional result was made operationally coherent. This is a focused review of the changed labs; a full editorial pass and rendered LiveLabs preview remain open.

## 10. Remaining issues

The Phase 2 package and provider configuration were not supplied. Select AI (Lab 7) and Select AI Agent (Lab 8) were not executed. The Graph Studio notebook imported as ADMIN. Its compute environment remained `DETACHED`: the attach task failed with “Free Tier usage exceeded for the day” for a 30.0 GBs compute environment (request ID `GRAPHYYZ-d35377c5cd0271c025dc1e0c2490dd9b`). Its three paragraphs therefore remain unexecuted; the equivalent Lab 4 SQL/PGQ queries passed in SQLcl. The optional AutoML UI was not run. The final revised loader passed a second fresh-schema replay. The quiz review, local preview, PNG conversion, and current learner-facing image audit are complete. Learner-user and Green Button execution remain open; no learner-session SQL result screenshots have been captured. Do not treat this as a release sign-off.

## Acknowledgements

* **Author** - TODO: Your Name, Your Title, Your Organization
* **Last Updated By/Date** - TODO: Your Name, Month Year
