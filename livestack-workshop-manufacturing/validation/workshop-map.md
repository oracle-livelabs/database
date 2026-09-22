# Workshop structure

The full source workshop and supplied stack were inspected before conversion: both manifests and launchers, all lesson text and SQL blocks, two native notebooks, image inventory, deployment files/templates, loader DDL and fixture rows. Existing validation claims were not carried forward as manufacturing test results.

Both manifests preserve the original lesson positions. Every lesson preserves its numbered task count. Lab 8 adds three SQL blocks for tested model selection and restoration; other SQL block counts are unchanged. The notebook paragraph counts remain 8 and 43; five Python/PGX paragraphs parse successfully. Need Help remains the shared LiveLabs destination.

| Position | Lesson | Tasks | SQL blocks |
| --- | --- | --- | --- |
| 1 | Build Connected Manufacturing Solutions with Oracle AI Database | 0 | 0 |
| 2 | Getting Started | 2 | 1 |
| 3 | Lab 1: Build a Converged Dashboard Query | 2 | 1 |
| 4 | Lab 2: Build a JSON Application Model | 6 | 14 |
| 5 | Lab 3: Search Components by Meaning | 4 | 8 |
| 6 | Lab 4: Trace a Production Quality Network | 7 | 6 |
| 7 | Lab 5: Find the Closest Manufacturing Plant | 3 | 4 |
| 8 | Lab 6: Build a Quality Review Watchlist with Oracle Machine Learning | 4 | 5 |
| 9 | Lab 7: Ask Manufacturing Questions with Select AI | 6 | 9 |
| 10 | Lab 8: Build a Manufacturing Agent with Select AI Agent | 5 | 15 |
| 11 | Lab 9: Final Quiz | 1 | 0 |

The core technical path remains converged SQL, JSON columns/collections/duality, vectors, property graph/SQL-PGQ/Graph Studio, spatial queries, OML training/scoring, Select AI, Select AI Agent, and the scored quiz. Both launch variants use the existing Oracle CDN renderer.

The justified domain changes are manufacturing units and independent schedule dates, inspection measurements and quality-review labels, material-lot and machine traceability, customer-site requirements, material/setup costs, and plant routing. Graph source-system and material-value properties replace transaction-oriented fields. New synthetic fixtures and a core ERD reflect those relationships. All 43 replacement captures now show the manually executed manufacturing exercises beside their instructions.

The stack contains the Terraform resources and two SQL templates from the supplied archive plus the single revised loader. No application server or interactive product demo was included in that archive. Provider and credential configuration was retained; adb.tf now invokes the manufacturing loader. See structure-comparison.json for the counts and schema-contract.md for all objects.
