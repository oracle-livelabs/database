# Seer Hotels live validation

Validated first on 21 September 2026 against a manually provisioned Autonomous Database, then through LiveLabs green-button provisioning on 23 September 2026. All eight core SQL lab paths passed. SQL, Graph Studio, AutoML and all local-demo captures are installed. The separate application story and dataset were approved by the user; the application is unchanged.

## LiveLabs green-button validation

- LiveLabs reservation 234787 provisioned `ATP234787` in Jeddah. **View Login Info** opened the authenticated Database Actions session as `LLUSER`.
- The loader supplied the hospitality schema and data. Verified counts included 16 hotel properties, 1,024 guests, 3,739 reservations, 1,725 guest posts, 192 offer embeddings, 12 booking entities and 24 booking relationships.
- `RESERVATIONS_DV`, `BOOKING_ABUSE_NETWORK`, and `OML_STAY_DEMAND_TRAINING_V` were valid. JSON duality projection, SQL property-graph traversal, spatial distance, the 192-row OML training view, and access to `ADMIN.ALL_MINILM_L12_V2` all executed successfully.
- The provisioned `GENAI` profile was enabled. `DBMS_CLOUD_AI.GENERATE` completed both `showsql` and `runsql`; the generated query returned the expected five stay offers, led by Joliet Family suite - Advance stay at 16,620 booked-room revenue.
- Lab 8 created the hospitality tool, agent, task, and team. `RUN_TEAM` returned the same five offers with revenue and room-night totals. The temporary agent objects were then removed so the learner starts from the documented clean state.
- Graph Studio launched as `LLUSER`, attached its compute environment, imported **Booking Abuse Network**, and ran the investigation table and both network visualizations. The table returned seven connected entities; the reservation view showed six of seven vertices and eight of ten edges; the device view showed four of five vertices and five of seven edges.
- The fresh Graph Studio run exposed an empty line immediately after `%sql` in the final notebook paragraph. Removing that line fixed the tokenizer failure; the exported notebook was corrected and retested.
- Oracle Machine Learning launched as `LLUSER`, and the AutoML Experiments interface opened successfully. The optional experiment itself was already completed during the manual-database validation and was not repeated for this provisioning check.

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

The clean ZIP in Documents and outputs contains these fixes. Its provider and credential templates remain unchanged. The manual database uses resource-principal authentication. The later LiveLabs run verified the actual green-button loader and launch path.

## Remaining

All screenshot entries are complete, including the three approved local-demo map/network views. All database lab result screenshots, Graph Studio import/result screenshots and optional AutoML screens have been refreshed. Setup illustrations and persona artwork are retained as illustrations. Green-button provisioning is validated. The optional PGX loyalty extension still depends on its separately provisioned `LOYALTY_GRAPH`; it is not part of the required booking-network path.
