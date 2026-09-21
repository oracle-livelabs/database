# Workshop map and transformation record

## Reference inspection

The source was inspected recursively before the working copy was created: 104 files, including 11 Markdown lessons, 2 manifests, 2 HTML launch pages, 2 Graph Studio notebooks, 86 image assets (75 PNG and 11 SVG), and an empty image-directory marker. No SQL files, shell scripts, Terraform modules, loaders, dependency manifests, or deployment credentials are present. All executable examples are embedded in Markdown or notebook paragraphs. The containing directory is not currently a Git working tree; immutability is verified with SHA-256 rather than Git status.

Both launch variants use the Oracle-hosted LiveLabs renderer, CSS, and navigation convention. Their manifests have the same introduction, setup, nine labs, and external Need Help page. Links and notebook downloads are resolved relative to each lesson. The lab footer, acknowledgements, copy wrappers, details panels, quiz syntax, and teaching depth are retained.

## Lab and dependency map

| Sequence | Preserved capability | Hospitality purpose and dependency |
| --- | --- | --- |
| Introduction / setup | Personas, objectives, reservation login, LLUSER worksheet check | Seer Hotels scenario; Phase 2 readiness is explicit before running SQL |
| 1 | CTEs, relational aggregation, VECTOR_EMBEDDING / VECTOR_DISTANCE, JSON_TABLE, SDO_DISTANCE | Rank stay offers needing guest assistance; preloaded OFFER_EMBEDDINGS, RESERVATIONS_DV, service posts, properties and polygons |
| 2 | Native JSON column, JSON collection WITH ETAG, updatable JSON Relational Duality, insert/update/projection | Guest reservation payload with property, stay dates, and room-night charges; creates THOMAS_APP_DATA / THOMAS_RESERVATION_DOCS and changes RESERVATIONS_DV |
| 3 | ONNX model catalog, VECTOR(384), in-database embeddings, distance and similarity, relational joins | Find accessible stay offers and guests booked on them; creates STAY_OFFERS.OFFER_EMBEDDING separately from the preloaded dashboard embeddings |
| 4 | Relational self-joins, SQL/PGQ, one-to-four-hop traversal, shared identifiers, Graph Studio import/visualization | Review booking abuse evidence from RSV-8841 and shared devices; loader creates BOOKING_ABUSE_NETWORK |
| 5 | SDO_GEOMETRY points/polygons, GeoJSON conversion, distance units, ANYINTERACT, ROW_NUMBER | Recommend the nearest active hotel to a guest arrival/relocation point; recommendations require a separate date-specific availability check |
| 6 | Optional AutoML, GLM settings, DBMS_DATA_MINING, classification, PREDICTION and probability | Stay-demand watchlist; synthetic labels and scoring perturbation remain teaching examples, not measured forecast quality |
| 7 | Select AI profile/object list, showsql, runsql, narrate | Ask for booked room revenue by offer with explicit reservation-status filters |
| 8 | Tool, agent, task, team, RUN_TEAM, conversation ID, execution/tool history, reset | NINA_HOSPITALITY_* query assistant; depends on Lab 7's GENAI profile |
| 9 | Seven scored questions, 75% passing threshold, completion badge | Hospitality learning check; same quiz mechanism |
| Optional notebook | PGQL/PGX, bind parameters, degree, cycles, PageRank, shortest paths, personalized PageRank, hop distance | Loyalty-points transfers between members; requires separately provisioned LOYALTY_GRAPH and PGX |

The reference graph lesson has two Task 5 headings. The target keeps all seven tasks in their original order and numbers them 1–7. No technical exercise was removed.

## Major domain decisions

| Hospitality model | Purpose and dependent areas |
| --- | --- |
| Seer Hotels | Fictional hotel group used in titles, navigation, prose, diagrams and quiz |
| STAY_OFFERS / STAY_OFFERS_V | Room type and rate plan at a property; search, rates, charges, JSON, AI and demand analytics |
| HOTEL_PROPERTIES / HOTEL_PROPERTIES_V | Shared hotel identity for offers and guest routing |
| GUESTS | Contact details, loyalty tier, preferences and requested arrival point |
| RESERVATIONS / RESERVATION_NIGHTS | One-room stay with property, dates and aggregated nightly charges |
| SERVICE_FEE | Optional hospitality fee, excluded from booked room revenue |
| SERVICE_ALERTS_V / POST_OFFER_MENTIONS | Service disruptions and affected-reservation counts |
| Accessible-room semantic search | Find offers with step-free access and guests booked on them |
| Booking evidence graph | Reservation, device, contact and token links for manual booking-abuse review |
| Visitor-region polygons | Spatial demand context; actual distances depend on the new loader |
| Booked room revenue | Nightly-charge totals for confirmed, checked_in and checked_out reservations |
| Loyalty-points graph | Optional PGX algorithm exercises using transfers between hotel loyalty members |

## Scope and naming

The [schema contract](schema-contract.md) records 24 table/view objects, 18 foreign-key relationships, two distinct graphs, model names, fixtures, and lab-created objects. The four core AI tables remain a deliberately small object list. LLUSER, GENAI, Oracle API names, official author credits and the Oracle navigation footer are platform terminology and are intentionally preserved.

Individual room assignment, restaurant operations, employees, payment settlement, full room-inventory management, and production revenue recognition are not added: they are unnecessary for these exercises. Loyalty membership is included to preserve the supplemental PGX technical content.

## Changes to derived content

Both notebook exports have all cached results cleared and obsolete runtime graph metadata/positions removed. Their query paragraphs and visualization styles remain, with hospitality identifiers and a reservation calendar icon. Five embedded Python paragraphs pass syntax parsing. The notebooks must be imported and run in Graph Studio after provisioning to validate runtime compatibility.

The [image inventory](screenshots.md) accounts for every source asset. Native SVGs are diagrams or badges; no edited image is represented as a real database capture. File-level provenance and reference hashes are preserved in a separate migration-evidence deliverable. Asset IDs connect that archive to this workshop’s image inventory without embedding reference filenames here.
