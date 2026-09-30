# Manual database validation — SEER Telecomms

Validated on 23 September 2026 as LLUSER in the manually provisioned LIVESTACKTELCO Autonomous Database, version 23.26.3.3.0. Work stopped before LiveLabs green-button and Terraform provisioning validation.

## Loader and model

The loader's canonical statements were executed through Database Actions in schema, bounded seed and derived-object sections. The full script exceeded the worksheet's practical execution size before table creation, so 11,491 explicit inserts were run in 23 batches. An accidental batch retry was rejected by primary keys; the final counts matched all 15 tables. The duality view initially held 3,843 documents; 192 embeddings had 384 dimensions. The property graph, spatial metadata and three spatial indexes, views, grants, profile object list and loader assertions passed. The completion marker was observed and no invalid schema objects were reported. The SQLcl password/CONNECT entrypoint itself was not tested. The optional agent cleanup block was not run, so its objects and history remain available for review.

The loader now prepares GENAI_AGENT from GENAI's OCI credential and compartment. Its fresh-create and existing-profile paths both passed. A disabled GENAI_AGENT_LOADER_CHECK profile remains as a validation artifact. GENAI uses Cohere Command A for SQL generation; GENAI_AGENT uses Meta Llama 3.3 70B Instruct for agent reasoning in us-chicago-1. Both use the already authorized resource principal. No IAM policy was edited.

## Lab results

| Lab | Live result |
| --- | --- |
| Subscriber operations | Ten rows from the converged query; changing the phrase moves fixed-wireless plans into the leading results. |
| Service-order duality | All 14 blocks passed. Order 900001 and line 990001 were inserted; the JSON update changed the relational status to confirmed. The current order and line counts are each 3,844 after this lab. |
| Vector search | All eight blocks passed; the teaching vector column holds 384-dimensional embeddings for 192 plans. Semantic queries and subscriber joins returned results. |
| Activation fraud | All five SQL queries and graph DDL passed. Graph Studio imported and ran the eight-paragraph notebook. The traversal shows seven vertices and ten edges; shared-device evidence shows five vertices and seven edges. |
| Optional airtime notebook | All 43 paragraphs ran after the graph-source option was corrected to lowercase pg_pgql. AIRTIME_GRAPH loaded 105 vertices and 114 edges. Parameterized cycles used accounts 934 and 534; degree, PageRank, personalized PageRank, shortest paths and hop-distance examples produced results. |
| Spatial | All four queries passed: coordinates/GeoJSON, New York and Chicago region distances, and nearest-site subscriber routing. |
| OML | Five SQL blocks passed. The GLM scoring query returned 12 rows, six SURGE and six STABLE. AutoML experiment 604 completed with five models. Perfect reported accuracy reflects sample labels calculated from the same month’s inputs; it does not establish forecasting performance. |
| Select AI | All nine blocks passed after prompts and column metadata were made explicit about lowercase status values. The five leading fiber plans each total 4,560 monthly charges and 48 connections. |
| Agent | The corrected run succeeded in 22.159 seconds with one SQL-tool call and the expected totals. Two earlier reasoning runs looped and timed out; their stale history rows are retained and are not counted as successful. |
| Quiz | Local renderer check returned 7/7 and the telecom completion badge. |

## Corrections incorporated in this edition

- Status prompts and column comments preserve the exact stored lowercase values, including failed_activation.
- Agent reasoning and SQL generation use separate tested profiles; task instructions request natural-language SQL-tool input, summed connection quantities and completion after one successful tool result.
- Oracle JSON_OBJECT is selected into a CLOB before profile creation; both loader branches were tested.
- The PGX Python client uses pg_pgql; graph visualization limits include every returned vertex and edge.
- Graph legend wording matches the high-risk condition.

## Boundaries and evidence

The database was provisioned manually. This run does not validate Terraform, generated setup-template ordering, wallet/SQLcl arguments or a LiveLabs launch. Those remain for the green-button phase. The seven inherited provisioning files retain their original flow; only adb.tf's loader path changed. The spatial-role prerequisite is documented in the stack runbook.

Authentic application captures use the separate supplied demo dataset and local llama3.2 runtime. Authentic workshop captures use this LLUSER database and are placed next to their matching instructions. Tables with more columns or rows than fit in a viewport show excerpts; the SQL and expected results remain alongside them. Graph Studio's built-in template tag moviestream and LiveLabs Reservation Information/My Reservations are platform text, not telecom fixture content.

See manual-results.json, database-captures.json, screenshot-inventory.json, and the selected live transcripts in manual-evidence/. Earlier errors are retained in transcripts where relevant; the result table above records the corrected outcome.
