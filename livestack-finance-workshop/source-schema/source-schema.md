# Source schema notes

## Introduction

This folder contains sanitized schema scripts copied from the input package. Use them as source references while you run the labs.

### Objectives

- Keep SQL examples close to the packaged source.
- Preserve source-owned object names.
- Remove credentials before workshop publication.

Estimated Time: 5 minutes

## Source schema contents

| File group | Purpose |
| --- | --- |
| `00_setup.sql` | Creates the `LIVESTACK` schema and grants privileges. |
| `01_tables.sql` | Creates core finance, transaction, service, and signal tables. |
| `02_json_collections.sql` | Adds JSON storage and JSON Relational Duality Views. |
| `03_graph.sql`, `10_fraud_graph.sql` | Build relationship and fraud investigation graphs. |
| `04_vector.sql` | Defines vector tables, indexes, and search routines. |
| `05_spatial.sql` | Adds service-center locations and routing functions. |
| `06_security.sql` | Creates roles, VPD policy functions, context, and audit policy. |
| `07_ai_profile.sql`, `08_agents.sql` | Define optional AI profiles, tools, agents, teams, and logs. |
| `11_finance_views.sql` | Exposes learner-friendly finance views. |

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
