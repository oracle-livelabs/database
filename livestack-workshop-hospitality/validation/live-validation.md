# Seer Hotels live validation

Validated on 21 September 2026 against the manually provisioned Autonomous Database. All eight core SQL lab paths passed. SQL, Graph Studio, AutoML and all local-demo captures are installed. The separate application story and dataset were approved by the user; the application is unchanged.

## Passed live

- Resource principal enabled for ADMIN and LLUSER. Required privileges, shared embedding model and Studio proxy grants verified.
- Loader completed: 13,095 seed rows, 192 embeddings, 3,739 reservation documents, valid spatial geometry and booking-graph assertions.
- Lab 1 dashboard query returned ten hospitality results, led by the Newark accessible-room offer.
- Lab 2 JSON collection, duality view, insert and update exercises passed. Reservation 900001 changed from pending to confirmed; its two room nights total 250.
- Lab 3 vector column populated and similarity searches passed. The guest follow-up query returned 93 rows.
- Lab 4 five relational and SQL graph queries passed, including six shared-identifier reservation pairs. The supplied Graph Studio notebook imported in Chrome and all eight paragraphs executed. Its investigation table and both graph visualizations rendered successfully; the shared device connects RSV-8841, RSV-5077 and RSV-1190 as expected.
- Lab 5 four spatial queries passed: property GeoJSON, regional distances and 25 guest-routing results.
- Lab 6 GLM classification model trained successfully and scored twelve synthetic scenarios. Optional AutoML completed: five candidates scored 1.0000 balanced accuracy on the synthetic fixture; the AutoML GLM confusion matrix had zero off-diagonal errors.
- OCI model catalog is readable using the database resource principal.

## Select AI investigation

Ashburn does not provide on-demand Llama 3.3, Llama 4 or Cohere Command A. The regional model catalog and Oracle regional availability matrix explain why those chat requests returned ORA-20404. The GENAI profile successfully completed chat inference using Llama 3.3 in Chicago. Lab 7 passed showsql, runsql, the refined question and narrate. Generated joins and reservation-status filters were reviewed. The first-ranked offer is Joliet Family suite - Advance stay at 16,620 and 60 room nights. An independent hand-written SQL query matched all five revenue and room-night totals. Lab 8 created its tool, agent, task and team; RUN_TEAM returned the same five offers and totals. Team history records SUCCEEDED and exactly one SQL-tool invocation.

Reference: https://docs.oracle.com/en-us/iaas/Content/generative-ai/model-endpoint-regions.htm

## Loader fixes and package

- Check existing SPATIAL_AUTHOR role instead of trying to re-grant it from ADMIN; the missing-role error directs the administrator to Database Actions user management.
- Exclude only DBTOOLS$EXECUTION_HISTORY from the fresh-schema gate.
- Omit the redundant OFFER_EMBEDDINGS foreign-key index already covered by its primary key.
- All 60 offline checks passed; archive integrity passed.
- Clean ZIP SHA-256: 5255cccbc3939acd44907fb4602073b360e098195abccc27d62a44214c7ddf2f.

The clean ZIP in Documents and outputs contains these fixes. Its provider and credential templates remain unchanged. This manual database uses resource-principal authentication. Browser execution used scripts derived from the SQLcl loader; Terraform/green-button provisioning has not been executed.

## Remaining

All screenshot entries are complete, including the three approved local-demo map/network views. All database lab result screenshots, Graph Studio import/result screenshots and optional AutoML screens have been refreshed. Setup illustrations and persona artwork are retained as illustrations. Terraform/green-button provisioning has not been executed. The test database contains learner-created objects, sample reservation 900001 and the completed AutoML experiment.
