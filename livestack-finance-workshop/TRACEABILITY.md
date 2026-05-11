# Source Traceability

## Introduction

This file maps the workshop to the supplied LiveStack input package. Use it to review where each claim came from.

### Objectives

- Connect each lab to packaged source files.
- Keep frontend, backend, and database claims traceable.
- Avoid unpublished local paths in student-facing content.

Estimated Time: 5 minutes

## Source package map

| Workshop area | Source files |
| --- | --- |
| Application navigation and screen story | `frontend-source/src/App.jsx`, `frontend-source/src/pages/*.jsx` |
| Frontend API helper | `frontend-source/src/utils/api.js` |
| Express routes and database pool | `api-map.md`, `backend-source/server.js`, `backend-source/config/database.js`, `backend-source/routes/*.js` |
| Core schema and seed data | `database-source/schema/01_tables.sql`, `database-source/data/load_all_data.sql` |
| Finance views | `database-source/schema/11_finance_views.sql` |
| JSON duality | `database-source/schema/02_json_collections.sql` |
| Graph investigation | `database-source/schema/03_graph.sql`, `database-source/schema/10_fraud_graph.sql` |
| Vector search | `database-source/schema/04_vector.sql`, `database-source/data/onnx/*` |
| Spatial routing | `database-source/schema/05_spatial.sql` |
| VPD and audit | `database-source/schema/06_security.sql` |
| Optional AI and agents | `database-source/schema/07_ai_profile.sql`, `database-source/schema/08_agents.sql` |

## Lab traceability

| Lab | Source grounding |
| --- | --- |
| Getting Started | Input package contract, app-flow prerequisites, source-schema safety checks |
| Lab1 | Control tower, source package contract, API map, health route |
| Lab2 | Data foundation page, schema load order, finance views, demo restore flow |
| Lab3 | Dashboard page, dashboard routes, product duality route, aggregate SQL |
| Lab4 | Regulatory signal page, social routes, vector tables and functions |
| Lab5 | Graph page, fulfillment page, graph and spatial source files |
| Lab6 | Orders page, orders routes, JSON duality views, VPD context |
| Lab7 | Predictive analytics page and ML route group |
| Lab8 | Ask Data, Agent Console, natural-language SQL helper, agent action logs |
| Lab9 | Key learning checks derived from the instructional labs |

## Publication cautions

- The backend uses Express with `node-oracledb`; do not describe ORDS as the API layer.
- Some source tables keep compatibility names. Use finance-friendly prose, but preserve SQL object names.
- Select AI profiles and database agent scripts are optional unless the target environment has required packages and OCI access.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
