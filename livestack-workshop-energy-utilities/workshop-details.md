# Workshop Details

Estimated Time: **5 minutes**

## Objectives

- Build a relational energy operations review query that connects service requests, reliability evidence, and field-logistics capacity.
- Inspect JSON Relational Duality documents, rank service descriptions with AI Vector Search, follow directed graph relationships, and compare site proximity.
- Evaluate a prepared demand-surge model on held-out labeled cases and build a demand and capacity watchlist.
- Review Select AI and operational review agent patterns, subject to platform prerequisites and pending live validation.

- **Title:** Build Connected Energy and Utilities Solutions with Oracle AI Database
- **Audience:** Database developers, architects, data engineers, AI engineers, and utility operations technologists
- **Duration:** 90 minutes
- **Delivery:** Oracle LiveLabs sandbox or tenancy
- **Database user:** LLUSER
- **Primary interface:** Database Actions SQL Worksheet

## Lab flow

1. **Build an Energy Operations Review Query:** Jessica connects operational evidence using relational SQL.
2. **Build a JSON Application Model:** Thomas reads prepared JSON Relational Duality documents and compares relational results; no document update is executed.
3. **Review a Semantic Risk Search:** Gilly ranks service descriptions related to operational concerns.
4. **Investigate an Operational Event Network:** Bob inspects directed, one-hop relationships and prepared findings.
5. **Rank Nearby Operations Sites for Review:** Moon compares straight-line geodetic proximity and capacity constraints, not routes or travel times.
6. **Build a Demand and Capacity Watchlist with Oracle Machine Learning:** Otto evaluates and uses a prepared model; learners do not train it.
7. **Ask Energy and Utilities Questions with Select AI:** Nina reviews generated SQL for site, service, and capacity questions when the environment is available.
8. **Build an Energy and Utilities Operational Review Agent:** Jessica configures learner-owned agent objects for an intended read-only workflow; enforcement and live behavior require validation.
9. Learners complete the scored quiz.

## Runtime requirements

- Oracle AI Database 26ai with JSON Relational Duality, AI Vector Search, SQL/PGQ, Spatial, OML, Select AI, and Select AI Agent enabled.
- The deterministic Energy and Utilities loader completed in LLUSER.
- Only for live Labs 7–8: an enabled, `LLUSER`-accessible, platform-owned `EU_GENAI` profile, an approved provider credential and model, provider connectivity, and governed context comprising `EU_FIELD_LOGISTICS_SITES_V`, `EU_ASSET_CAPACITY_V`, and `EU_UTILITY_SERVICES_V`.
- Labs 7–8 live execution remains environment-validation pending. The loader must not create or configure the profile or pre-create learner tools, agents, tasks, or teams.
- Prompts and applicable schema metadata/context may be sent to the configured provider; returned database values may also be sent for narration or agent processing. Learners must not include sensitive information.
- `object_list` supplies model context, not authorization. Database privileges, VPD, row-level security, and tool configuration govern access.

No credentials, wallet contents, or secrets belong in the workshop repository.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
