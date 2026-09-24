# Media platform preparation

This facilitator guide documents the supplied handoff loader. It is separate from the participant lab sequence.

Estimated Time: **15–30 minutes**, plus loader execution time.

## Loader and prerequisites

The workshop includes an unchanged copy of [media-platform-handoff-loader.sql](getting-started/files/media-platform-handoff-loader.sql). Its SHA-256 is `c76e0d3f4edc8ac7e051d2f54ddd6f9a2c19f72f11629c9f5e62714fa6175bb0`.

Use the dedicated workshop Autonomous Database 26ai environment with an existing `LLUSER`. The loader starts as `ADMIN`. It resets the `LLUSER` password using its first SQLcl argument and grants privileges. It then reconnects as `LLUSER` and replaces the named workshop objects and data. It requires the preloaded `ADMIN.ALL_MINILM_L12_V2` ONNX embedding model. It does not create that model or provision a database. Review the reset operations before using the script on an existing environment.

The script's second SQLcl argument is the connection identifier. Supply the arguments through the platform's approved SQLcl credential handling. Keep real credentials out of these workshop files. For this revision, the LLUSER portion was separated from the ADMIN account operations, loaded into the dedicated database, and checked against the fixed seed. Do not rerun it to configure Select AI.

## Data and naming contract

| Media concept | Loader objects | Media semantic view |
| --- | --- | --- |
| Content assets, studios and labels | `PRODUCTS`, `BRANDS` | `MEDIA_CONTENT_ASSETS_V` |
| Campaign orders, audience accounts and line items | `ORDERS`, `CUSTOMERS`, `ORDER_ITEMS` | `MEDIA_CAMPAIGN_ORDERS_V` |
| Audience signals and creator activity | `SOCIAL_POSTS`, `POST_PRODUCT_MENTIONS`, `INFLUENCERS` | `MEDIA_AUDIENCE_SIGNALS_V` |
| Distribution hubs and capacity | `FULFILLMENT_CENTERS`, `INVENTORY`, `DEMAND_FORECASTS` | `MEDIA_DISTRIBUTION_CAPACITY_V` |
| Creator connections and studio partnerships | `INFLUENCER_CONNECTIONS`, `BRAND_INFLUENCER_LINKS` | `MEDIA_CREATOR_RELATIONSHIPS_V` |

The loader intentionally retains shared LiveStack physical names. Do not rename those objects in lab SQL. `ORDERS_DV` retains `_id`, `customerId`, `status`, `total`, `shippingCost`, `demandScore`, `createdAt`, and nested `items` with `itemId`, `productId`, `quantity`, and `unitPrice`. Lab 2 enables inserts on that view for its campaign-order exercise.

The fixed seed contains 187 content assets, 50 studios and labels, 483 creators, 2,000 audience accounts, 3,000 orders, 8,981 line items, 5,000 social posts, 30 hubs, and 20 demand regions. The seed anchor is May 5, 2026. Content asset 1 is **Midnight Harbor Premiere Window**, supplied by **Aurora Studios**, with a campaign-value proxy of 24.99.

`INFLUENCER_NETWORK` is the SQL property graph. Its vertex labels are `influencer`, `brand`, `product`, and `social_post`; edge labels are `connects_to`, `promotes`, and `mentions_product`. The loader does not create viewer/device graph entities.

`OML_DEMAND_TRAINING_V` supplies the `SURGE`/`STABLE` classification target. The loader builds `DEMAND_SURGE_MODEL`, `CUSTOMER_SEGMENT_MODEL`, `REVENUE_PREDICT_MODEL`, and `PRODUCT_CLUSTER_MODEL`. The loader derives these labels from seed activity. Scores on those rows demonstrate classification; they do not validate future retention or audience outcomes.

## Hosted services

Enable Database Actions, Graph Studio, and OML UI access for the workshop user. The loader's grants alone do not establish every hosted UI session.

Before the optional AutoML exercise, connect as `ADMIN` and grant the OML developer role to the dedicated workshop schema:

```sql
GRANT OML_DEVELOPER TO LLUSER;
```

The unchanged handoff loader does not include this role. The live workshop setup applied the same grant. Reconnect as `LLUSER` after the grant and confirm that `OML_DEVELOPER` appears in `SESSION_ROLES` before opening Machine Learning. Oracle documents this role as an [OML UI access prerequisite](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/omlug/dsa-prerequisites.html).


Labs 7 and 8 require an enabled Select AI profile with working provider credentials. Grant `EXECUTE` on `DBMS_CLOUD`, `DBMS_CLOUD_AI`, and `DBMS_CLOUD_AI_AGENT`. The data loader does not supply the hosted AI configuration. Natural-language instructions and a profile object list are not a database read-only security boundary: `LLUSER` has write and DDL privileges for the hands-on exercises.

Use this OCI Generative AI setup when existing policy authorizes the database resource principal in the selected compartment:

1. Check the existing OCI policy and model availability. The policy must cover the database resource principal and the compartment used by the profile. The setup scripts make no IAM changes. Oracle documents [resource principal authorization](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/resource-principal.html) and [OCI GenAI permissions](https://docs.oracle.com/en-us/iaas/Content/generative-ai/model-permissions.htm).
2. Run [media-selectai-admin.sql](getting-started/files/media-selectai-admin.sql) as `ADMIN`. It enables `OCI$RESOURCE_PRINCIPAL` if absent and grants `LLUSER` usage without delegation privileges. The credential remains owned by `ADMIN`.
3. Open [media-selectai-profile.sql](getting-started/files/media-selectai-profile.sql). Replace `<GENAI_COMPARTMENT_OCID>` with the authorized compartment OCID. Confirm that `meta.llama-3.3-70b-instruct` is available in `us-chicago-1`, or use the facilitator's approved OCI region/model. Run the file as `LLUSER`. It creates `SEER_MEDIA_PROFILE` with all five Media views, object-list enforcement, and comments enabled. It refuses to replace an existing profile.
4. Compare the file's direct content count with its `showsql` and `runsql` responses. Profile creation alone does not prove provider access. These calls consume OCI Generative AI usage. Database Actions uses `DBMS_CLOUD_AI.GENERATE` with an explicit profile name.

Live checks verified the resource principal grant, enabled profile, and initial `showsql`/`runsql` requests. The returned content count was 187, matching direct SQL. Each lab still requires its own result checks. An empty `USER_CREDENTIALS` result is expected when only the ADMIN-owned resource principal is used; check the `ALL_TAB_PRIVS` grant in Lab 7 instead.

You can also use an existing approved profile for another provider. Keep its credential and network configuration, and substitute its name consistently in Labs 7 and 8. See [Oracle Select AI provider setup](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/use-select-ai-ai-providers.html). Do not store API keys in workshop SQL files.

## Readiness and screenshots

Run [media-readiness-check.sql](getting-started/files/media-readiness-check.sql) as `LLUSER` after the loader completes. Require the expected objects to exist with valid status, non-null vectors, the expected model, and both OML classes. Run this baseline before Lab 2 inserts its additional row.

Capture Database Actions, Graph Studio, OML, and Select AI screenshots against this prepared environment. Do not present the prior screenshots' schema names, prediction metrics, rankings, or graph results as evidence from this loader. See the screenshot inventory under `../output/screenshots/media-loader-alignment` for the capture states needed by each lab.

## Acknowledgements

* **Source** - User-supplied Media platform handoff loader and Oracle LiveLabs workshop.
* **Last Updated By/Date** - Workshop maintenance, September 2026
