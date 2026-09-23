# Workshop and stack map

Both manifests retain the reference lesson order. The numbered tasks match the reference in each lesson.

| Lesson | Tasks in order | SQL blocks |
| --- | --- | --- |
| Build Connected Telecommunications Solutions with Oracle AI Database | None | 0 |
| Getting Started | 1, 2 | 1 |
| Lab 1: Build a Converged Dashboard Query | 1, 2 | 1 |
| Lab 2: Build a JSON Application Model | 1, 2, 3, 4, 5, 6 | 14 |
| Lab 3: Search Service Plans by Meaning | 1, 2, 3, 4 | 8 |
| Lab 4: Investigate an Activation Fraud Network | 1, 2, 3, 4, 5, 6, 7 | 6 |
| Lab 5: Find Nearby Network Sites | 1, 2, 3 | 4 |
| Lab 6: Build a Service Plan Demand Watchlist with Oracle Machine Learning | 1, 2, 3, 4 | 5 |
| Lab 7: Ask Telecom Questions with Select AI | 1, 2, 3, 4, 5, 6 | 9 |
| Lab 8: Build a Telecom Agent with Select AI Agent | 1, 2, 3, 4, 5 | 12 |
| Lab 9: Final Quiz | 1 | 0 |

The two Graph Studio notebooks retain 51 paragraphs, including five Python paragraphs. Their data objects, graph identifiers, markdown and query text use the activation-evidence and prepaid-airtime scenarios. Stored output is cleared so it cannot imply a successful run.

The complete schema, views, graph fixtures, JSON keys, OML features and AI object lists are mapped in [schema-contract.md](schema-contract.md). The [capture queue](screenshots.md) maps every deferred result image to its instruction. The [stack handoff](../stack/README.md) describes template order, prerequisites, loader arguments and the later provisioning boundary.

Provisioning templates retain their original logic. Only the loader filename in adb.tf changes. No application source was supplied with this stack; it contains database setup and infrastructure templates. Workshop result captures must come from this revised schema, not an unrelated demo dataset.
