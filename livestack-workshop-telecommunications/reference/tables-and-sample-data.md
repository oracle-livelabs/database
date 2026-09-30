# SEER Telecomms tables and sample data

The main loader is [telecommunications-platform-handoff-loader.sql](../stack/load_data/telecommunications-platform-handoff-loader.sql). This document describes the table definitions and sample data used in the labs.

## Model and accounting rules

- NETWORK_SITES represents synthetic access infrastructure, with WGS84 point geometry, capacity in Mbps and utilization in percent. These are snapshots; nearest-site distance does not prove coverage or available throughput.
- SERVICE_PLANS contains variants for each site’s service area of mobile, fixed wireless, fiber and IoT plans. Technology is 5G, GPON or NB-IoT. Download speed is Mbps; data allowance is GB, with NULL meaning unlimited. A plan is a commercial service variant associated with a workshop service area, not a radio-attachment rule.
- SUBSCRIBERS holds synthetic contacts, customer segment, service-address geometry and JSON preferences for Wi-Fi calling, eSIM and contact channel.
- SERVICE_ORDERS covers one initial monthly period. SERVICE_ORDER_LINES records simultaneous connections and the agreed monthly fee. LINE_TOTAL is generated as CONNECTION_COUNT × MONTHLY_FEE. Quantity is unrelated to period length. ORDER_TOTAL equals summed lines plus ACTIVATION_FEE. The sample data spans [2026-09-01, 2026-10-01); it excludes taxes and proration.
- Contracted monthly charges include confirmed, active and completed orders. They exclude cancelled, pending and failed_activation orders, and exclude activation fees. This is not cash collection, recognized revenue, or a measure of the installed subscriber base.
- SUBSCRIBER_REPORTS combines synthetic support text with diagnostics from distinct observation intervals. Reports are linked to plans through REPORT_PLAN_MENTIONS. Per-report affected-subscriber counts can overlap; summing them does not count distinct people.
- ACTIVATION_ENTITIES links service orders, network sites, shared activation devices, IP/contact identifiers and tokenized payment references. Case membership and directed evidence edges support review; scores are not proof of fraud.
- PREPAID_ACCOUNTS and AIRTIME_TRANSFERS model sample transfers of prepaid voice minutes. They preserve the optional PGX algorithms; they are not a cash ledger or a stored balance calculation.

## Ownership and lab readiness

LLUSER owns the workshop objects. ADMIN.ALL_MINILM_L12_V2 is the shared 384-dimensional embedding model. GENAI is an enabled provider profile prepared before loading; its provider, credentials and region remain controlled by setup. The loader changes only its object list to SERVICE_PLANS, SERVICE_ORDERS, SERVICE_ORDER_LINES and SUBSCRIBERS.

Before Lab 1, the loader creates reporting views, SERVICE_ORDERS_DV and PLAN_EMBEDDINGS. The embedding text is plan name, category and subcategory, identical to Lab 3. SERVICE_PLANS.PLAN_EMBEDDING remains absent until the learner adds it.

The initial duality view permits UPDATE on root and child. Lab 2 changes both to INSERT UPDATE, creates THOMAS_APP_DATA and THOMAS_ORDER_DOCS, inserts order 900001 and line 990001, then confirms the order. Subscriber 1, site 1 and plan 1 exist; plan 1 costs USD 125. Two connections produce USD 250 and activation fee zero. The JSON keys are `_id`, `subscriberId`, `siteId`, `periodStart`, `periodEnd`, `status`, `total`, `activationFee`, `demandScore`, `createdAt`, and `items[{orderLineId,planId,connectionCount,monthlyFee}]`.

Lab 6 creates OTTO_PLAN_DEMAND_SETTINGS, OTTO_PLAN_DEMAND_SURGE_MODEL and OTTO_PLAN_DEMAND_SCORING_DATA. Lab 8 creates NINA_TELECOM_SQL_TOOL, NINA_TELECOM_AGENT, NINA_TELECOM_TASK and NINA_TELECOM_TEAM. These learner-owned objects are not precreated.

Cross-table totals and site consistency are checked for the sample data by the loader. They are not enforced for arbitrary later writes by a cross-table CHECK constraint. An application must check those rules within the transaction that writes the data. The same limitation applies to the intended one-month period for later orders.

## Training view

OML_PLAN_DEMAND_TRAINING_V has one row per active plan. The inputs are CATEGORY, MONTHLY_FEE, TOTAL_REPORTS, AVG_SENTIMENT, DROPPED_SESSIONS, OUTAGE_MINUTES, DATA_VOLUME_GB, AVG_UTILIZATION_PCT, CONGESTED_INTERVALS, BUSY_INTERVALS, CONNECTIONS_ORDERED and MONTHLY_CHARGES. PLAN_ID is the case identifier. SURGE_LABEL is the target.

Both support observations and accepted orders use September 2026. Orders and reports are aggregated separately to avoid multiplying rows. A congested interval has utilization >=80%; a busy interval has utilization >=60% and <80%. SURGE requires at least 45 ordered connections and at least two busy or congested intervals. The sample data has 96 SURGE and 96 STABLE examples. The label is calculated from the same month’s inputs. This demonstrates how to train and call a classification model, not how accurately it predicts future demand. The twelve modified rows used for predictions are not independent test data.

## Graph sample data

ACTIVATION_FRAUD_NETWORK is created by the loader using the same DDL as the lab appendix. ORD-8841, ORD-5077 and ORD-1190 reference existing sample order rows and share DEV-fp-91a7. The sample data supports one-through-four-hop paths and six shared-identifier pairs under the lab's filters. TOKEN-REUSED-017 is a synthetic token, not a card number; IP-198.51.100.44 belongs to a documentation range.

AIRTIME_GRAPH is a separate PGQL object. Run the optional setup block after loading, then use `session.read_graph_by_name("AIRTIME_GRAPH", "pg_pgql")`. Account IDs 534, 597, 934, 387 and 406 support degree, cycles, PageRank, shortest paths, personalized PageRank and hop-distance exercises. Four- and five-hop cycles and a six-hop path from 934 are present.

GENAI_AGENT is prepared by the loader for agent reasoning using GENAI's OCI authentication and compartment.

## Sample-data inventory

| Table | Rows |
| --- | ---: |
| `NETWORK_SITES` | 16 |
| `SERVICE_PLANS` | 192 |
| `SUBSCRIBERS` | 1,024 |
| `SERVICE_ORDERS` | 3,843 |
| `SERVICE_ORDER_LINES` | 3,843 |
| `SUBSCRIBER_REPORTS` | 1,152 |
| `REPORT_PLAN_MENTIONS` | 1,152 |
| `NETWORK_REGIONS` | 2 |
| `ACTIVATION_ENTITIES` | 12 |
| `ACTIVATION_RELATIONSHIPS` | 24 |
| `ACTIVATION_CASES` | 2 |
| `ACTIVATION_CASE_ENTITIES` | 10 |
| `PREPAID_ACCOUNTS` | 105 |
| `AIRTIME_TRANSFERS` | 114 |
| `PLAN_EMBEDDINGS` | 0 |

PLAN_EMBEDDINGS receives 192 rows through VECTOR_EMBEDDING during loading, in addition to the 11,491 explicit seed inserts. The loader requires 3,843 initial duality documents. The optional PGQL graph is not created by the SQLcl run.

## Tables and columns

### NETWORK_SITES

| Column | DDL type and constraints |
| --- | --- |
| `SITE_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `SITE_NAME` | `VARCHAR2(120) NOT NULL` |
| `CITY` | `VARCHAR2(100) NOT NULL` |
| `STATE_PROVINCE` | `VARCHAR2(100) NOT NULL` |
| `LATITUDE` | `NUMBER NOT NULL` |
| `LONGITUDE` | `NUMBER NOT NULL` |
| `LOCATION` | `MDSYS.SDO_GEOMETRY NOT NULL` |
| `CAPACITY_MBPS` | `NUMBER NOT NULL` |
| `UTILIZATION_PCT` | `NUMBER NOT NULL` |
| `IS_ACTIVE` | `NUMBER(1) NOT NULL` |

### SERVICE_PLANS

| Column | DDL type and constraints |
| --- | --- |
| `PLAN_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `SITE_ID` | `NUMBER NOT NULL` |
| `PLAN_NAME` | `VARCHAR2(160) NOT NULL` |
| `SERVICE_TYPE` | `VARCHAR2(80) NOT NULL` |
| `ACCESS_TECHNOLOGY` | `VARCHAR2(30) NOT NULL` |
| `DOWNLOAD_MBPS` | `NUMBER NOT NULL` |
| `DATA_ALLOWANCE_GB` | `NUMBER` |
| `BILLING_MODEL` | `VARCHAR2(80) NOT NULL` |
| `CATEGORY` | `VARCHAR2(100) NOT NULL` |
| `SUBCATEGORY` | `VARCHAR2(100) NOT NULL` |
| `MONTHLY_FEE` | `NUMBER(12,2) NOT NULL` |
| `IS_ACTIVE` | `NUMBER(1) NOT NULL` |

### SUBSCRIBERS

| Column | DDL type and constraints |
| --- | --- |
| `SUBSCRIBER_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `FIRST_NAME` | `VARCHAR2(80) NOT NULL` |
| `LAST_NAME` | `VARCHAR2(80) NOT NULL` |
| `EMAIL` | `VARCHAR2(200) NOT NULL` |
| `CUSTOMER_SEGMENT` | `VARCHAR2(30) NOT NULL` |
| `LOCATION` | `MDSYS.SDO_GEOMETRY NOT NULL` |
| `PREFERENCES` | `JSON NOT NULL` |

### SERVICE_ORDERS

| Column | DDL type and constraints |
| --- | --- |
| `ORDER_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `SUBSCRIBER_ID` | `NUMBER NOT NULL` |
| `SITE_ID` | `NUMBER NOT NULL` |
| `PERIOD_START` | `DATE NOT NULL` |
| `PERIOD_END` | `DATE NOT NULL` |
| `ORDER_STATUS` | `VARCHAR2(30) NOT NULL` |
| `ORDER_TOTAL` | `NUMBER(12,2) NOT NULL` |
| `ACTIVATION_FEE` | `NUMBER(12,2) NOT NULL` |
| `DEMAND_SCORE` | `NUMBER` |
| `CREATED_AT` | `TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL` |

### SERVICE_ORDER_LINES

| Column | DDL type and constraints |
| --- | --- |
| `ORDER_LINE_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `ORDER_ID` | `NUMBER NOT NULL` |
| `PLAN_ID` | `NUMBER NOT NULL` |
| `CONNECTION_COUNT` | `NUMBER NOT NULL` |
| `MONTHLY_FEE` | `NUMBER(12,2) NOT NULL` |
| `LINE_TOTAL` | `GENERATED ALWAYS AS (connection_count * monthly_fee) VIRTUAL` |

### SUBSCRIBER_REPORTS

| Column | DDL type and constraints |
| --- | --- |
| `REPORT_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `SUBSCRIBER_ID` | `NUMBER` |
| `REPORT_TEXT` | `VARCHAR2(4000) NOT NULL` |
| `SENTIMENT` | `NUMBER NOT NULL` |
| `DROPPED_SESSIONS` | `NUMBER NOT NULL` |
| `OUTAGE_MINUTES` | `NUMBER NOT NULL` |
| `DATA_VOLUME_GB` | `NUMBER NOT NULL` |
| `UTILIZATION_PCT` | `NUMBER NOT NULL` |
| `SEVERITY_SCORE` | `NUMBER NOT NULL` |
| `AFFECTED_SUBSCRIBERS` | `NUMBER NOT NULL` |
| `SERVICE_CASES_OPENED` | `NUMBER NOT NULL` |
| `REPORTED_AT` | `TIMESTAMP DEFAULT TIMESTAMP '2026-09-15 12:00:00' NOT NULL` |

### REPORT_PLAN_MENTIONS

| Column | DDL type and constraints |
| --- | --- |
| `REPORT_ID` | `NUMBER NOT NULL` |
| `PLAN_ID` | `NUMBER NOT NULL` |

### PLAN_EMBEDDINGS

| Column | DDL type and constraints |
| --- | --- |
| `PLAN_ID` | `NUMBER NOT NULL` |
| `EMBEDDING` | `VECTOR(384) NOT NULL` |

### NETWORK_REGIONS

| Column | DDL type and constraints |
| --- | --- |
| `REGION_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `REGION_NAME` | `VARCHAR2(120) NOT NULL` |
| `DEMAND_INDEX` | `NUMBER NOT NULL` |
| `BOUNDARY` | `MDSYS.SDO_GEOMETRY NOT NULL` |

### ACTIVATION_ENTITIES

| Column | DDL type and constraints |
| --- | --- |
| `ENTITY_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `ENTITY_KEY` | `VARCHAR2(100) NOT NULL` |
| `DISPLAY_NAME` | `VARCHAR2(160) NOT NULL` |
| `ENTITY_TYPE` | `VARCHAR2(30) NOT NULL` |
| `RISK_SCORE` | `NUMBER NOT NULL` |
| `RISK_LEVEL` | `VARCHAR2(20) NOT NULL` |
| `CHANNEL` | `VARCHAR2(30) NOT NULL` |
| `TOTAL_AMOUNT` | `NUMBER(12,2) NOT NULL` |
| `EVENT_COUNT` | `NUMBER NOT NULL` |
| `IS_CONFIRMED_FRAUD` | `NUMBER(1) NOT NULL` |
| `ORDER_ID` | `NUMBER` |
| `SITE_ID` | `NUMBER` |

### ACTIVATION_RELATIONSHIPS

| Column | DDL type and constraints |
| --- | --- |
| `RELATIONSHIP_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `FROM_ENTITY` | `NUMBER NOT NULL` |
| `TO_ENTITY` | `NUMBER NOT NULL` |
| `RELATIONSHIP_TYPE` | `VARCHAR2(60) NOT NULL` |
| `STRENGTH` | `NUMBER NOT NULL` |
| `EVENT_COUNT` | `NUMBER NOT NULL` |
| `TOTAL_AMOUNT` | `NUMBER(12,2) NOT NULL` |

### ACTIVATION_CASES

| Column | DDL type and constraints |
| --- | --- |
| `CASE_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `CASE_REF` | `VARCHAR2(80) NOT NULL` |
| `CASE_TYPE` | `VARCHAR2(40) NOT NULL` |
| `STATUS` | `VARCHAR2(30) NOT NULL` |
| `RISK_SCORE` | `NUMBER NOT NULL` |
| `LOSS_AMOUNT` | `NUMBER(12,2) NOT NULL` |
| `EVENT_COUNT` | `NUMBER NOT NULL` |

### ACTIVATION_CASE_ENTITIES

| Column | DDL type and constraints |
| --- | --- |
| `CASE_ENTITY_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `CASE_ID` | `NUMBER NOT NULL` |
| `ENTITY_ID` | `NUMBER NOT NULL` |
| `ROLE` | `VARCHAR2(40) NOT NULL` |
| `EVIDENCE_SCORE` | `NUMBER NOT NULL` |

### PREPAID_ACCOUNTS

| Column | DDL type and constraints |
| --- | --- |
| `ACCOUNT_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `SUBSCRIBER_ID` | `NUMBER NOT NULL` |
| `NAME` | `VARCHAR2(160) NOT NULL` |

### AIRTIME_TRANSFERS

| Column | DDL type and constraints |
| --- | --- |
| `TRANSFER_ID` | `NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH 1000000) NOT NULL` |
| `FROM_ACCOUNT_ID` | `NUMBER NOT NULL` |
| `TO_ACCOUNT_ID` | `NUMBER NOT NULL` |
| `MINUTES` | `NUMBER NOT NULL` |
| `DESCRIPTION` | `VARCHAR2(200) NOT NULL` |

## Foreign keys

| Child | Parent |
| --- | --- |
| `SERVICE_PLANS.SITE_ID` | `NETWORK_SITES.SITE_ID` |
| `SERVICE_ORDERS.SUBSCRIBER_ID` | `SUBSCRIBERS.SUBSCRIBER_ID` |
| `SERVICE_ORDERS.SITE_ID` | `NETWORK_SITES.SITE_ID` |
| `SERVICE_ORDER_LINES.ORDER_ID` | `SERVICE_ORDERS.ORDER_ID` |
| `SERVICE_ORDER_LINES.PLAN_ID` | `SERVICE_PLANS.PLAN_ID` |
| `SUBSCRIBER_REPORTS.SUBSCRIBER_ID` | `SUBSCRIBERS.SUBSCRIBER_ID` |
| `REPORT_PLAN_MENTIONS.REPORT_ID` | `SUBSCRIBER_REPORTS.REPORT_ID` |
| `REPORT_PLAN_MENTIONS.PLAN_ID` | `SERVICE_PLANS.PLAN_ID` |
| `PLAN_EMBEDDINGS.PLAN_ID` | `SERVICE_PLANS.PLAN_ID` |
| `ACTIVATION_ENTITIES.ORDER_ID` | `SERVICE_ORDERS.ORDER_ID` |
| `ACTIVATION_ENTITIES.SITE_ID` | `NETWORK_SITES.SITE_ID` |
| `ACTIVATION_RELATIONSHIPS.FROM_ENTITY` | `ACTIVATION_ENTITIES.ENTITY_ID` |
| `ACTIVATION_RELATIONSHIPS.TO_ENTITY` | `ACTIVATION_ENTITIES.ENTITY_ID` |
| `ACTIVATION_CASE_ENTITIES.CASE_ID` | `ACTIVATION_CASES.CASE_ID` |
| `ACTIVATION_CASE_ENTITIES.ENTITY_ID` | `ACTIVATION_ENTITIES.ENTITY_ID` |
| `PREPAID_ACCOUNTS.SUBSCRIBER_ID` | `SUBSCRIBERS.SUBSCRIBER_ID` |
| `AIRTIME_TRANSFERS.FROM_ACCOUNT_ID` | `PREPAID_ACCOUNTS.ACCOUNT_ID` |
| `AIRTIME_TRANSFERS.TO_ACCOUNT_ID` | `PREPAID_ACCOUNTS.ACCOUNT_ID` |

## Reporting views

| View | Projected columns |
| --- | --- |
| `SERVICE_PLANS_V` | `PLAN_CATEGORY`, `PLAN_ID`, `PLAN_NAME`, `SITE_ID` |
| `NETWORK_SITES_V` | `CITY`, `SITE_ID`, `SITE_NAME`, `STATE_PROVINCE` |
| `SERVICE_ALERTS_V` | `AFFECTED_SUBSCRIBERS`, `ALERT_ID`, `SERVICE_CASES_OPENED`, `SEVERITY_SCORE` |
| `SERVICE_ORDERS_DV` | `DATA` |
