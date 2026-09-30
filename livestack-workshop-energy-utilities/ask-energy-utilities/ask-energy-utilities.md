# Ask Energy and Utilities Questions with Select AI

## Introduction

Jessica has helped the operations team inspect requests, related reliability evidence, nearby sites, and a demand watchlist in Labs 1–6. Nina Patel, an operations analyst, now needs to ask follow-up questions without starting every time with a blank SQL statement. Jessica helps Nina review how a natural-language question becomes a database query.

This lab focuses on the approved site, service, and capacity views. Site-level request counts help prioritize operational review; they do not expose individual request details or the full reliability-signal history. Field-logistics capacity describes supplies available to support a response, not electrical generation capacity.

Nina follows a deliberate pattern: ask, inspect the generated SQL, run it only when it makes sense, refine the question, and compare any narration with the database result.

Estimated Time: **10 minutes**

### Objectives

- Inspect the platform-owned Select AI profile and its model context without changing it.
- Generate SQL from a utility operations question.
- Run and refine the question.
- Explain why generated SQL and narration still require review.

### Hands-on Scenario

Jessica and Nina need to identify active field-logistics sites with the largest pending-request workload, then inspect Gas Utility service/site rows with constrained supplies. Their outcome is a review list supported by governed database evidence—not an automatic dispatch decision.

> **SQL Worksheet reminder:** Return to [Getting Started Task 2](?lab=getting-started#Task2:OpenSQLWorksheet) if you need the launch and execution steps.
>
> **Platform prerequisite — live validation pending:** Live execution requires an enabled, LLUSER-accessible `EU_GENAI` profile, an approved provider credential and model, working provider connectivity, and an `object_list` limited to the governed Energy and Utilities views used in this lab. If the profile is unavailable, stop after Task 1 and tell the facilitator. The workshop loader does not create or modify this profile, provider credentials, provider-model settings, or provider connectivity.
>
> **Data-use disclosure:** Prompts and applicable schema metadata or other configured context may be sent to the configured AI provider. Do not include passwords, credentials, personal data, confidential operational details, or other sensitive information in a prompt. Task 6 separately explains when returned database values may also be sent to the provider.

## Task 1: Check the Select AI profile

1. Run the profile inventory.

    <copy>
    ```sql
    SELECT profile_name, status, description
    FROM user_cloud_ai_profiles
    WHERE profile_name = 'EU_GENAI';
    ```
    </copy>

2. Confirm the profile is enabled. If it is missing, stop and tell the facilitator; do not substitute an unapproved profile.

## Task 2: Inspect the governed utility context

1. Read only the profile's object list. Do not change the profile or query credential attributes.

    <copy>
    ```sql
    SELECT profile_name, attribute_name, attribute_value
    FROM user_cloud_ai_profile_attributes
    WHERE profile_name = 'EU_GENAI'
      AND attribute_name = 'object_list';
    ```
    </copy>

    The `object_list` supplies a limited set of schema metadata as model context for natural-language SQL generation. It does not grant access and is not an authorization boundary. The LLUSER session privileges and database security controls, including Virtual Private Database (VPD) or row-level policies, remain the enforcement controls.

2. Confirm that the platform-approved context contains the LLUSER views below. If the context is missing or different, ask the facilitator to verify it before making an AI call; do not add objects yourself.

    | View | Questions supported in this lab |
    | --- | --- |
    | `EU_FIELD_LOGISTICS_SITES_V` | Active sites, pending-request counts, supply units, and alerts. |
    | `EU_ASSET_CAPACITY_V` | Service/site supplies, reservations, reorder points, and capacity status. |
    | `EU_UTILITY_SERVICES_V` | Service names, categories, descriptions, and operators or partners. |

## Task 3: Ask a question and inspect the SQL

Database Actions SQL Worksheet uses `DBMS_CLOUD_AI.GENERATE` rather than the `SELECT AI` convenience command.

1. Generate SQL without executing it.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_FIELD_LOGISTICS_SITES_V, show the five active field-logistics sites with the highest pending_request_count. Include field_logistics_site_id, field_logistics_site_name, pending_request_count, capacity_supply_units, alert_count, and operational_status. Order by pending_request_count descending, then field_logistics_site_id ascending.',
             profile_name => 'EU_GENAI',
             action       => 'showsql'
           ) AS generated_sql
    FROM dual;
    ```
    </copy>

2. Check the view name, active-site filter, requested columns, five-row limit, and both ordering keys. This view already aggregates request and supply evidence; an extra join is not required. Its pending-request count covers pending, confirmed, and processing requests. If the SQL does not answer the question, refine the prompt and inspect it again before continuing.

## Task 4: Run the reviewed question

1. After reviewing the generated SQL, run the same question. `RUNSQL` is a separate generation/execution request; it does not promise to execute the identical SQL displayed by `SHOWSQL`. Where exact-statement approval is required, have the reviewed SQL approved and executed through the governed SQL workflow instead.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_FIELD_LOGISTICS_SITES_V, show the five active field-logistics sites with the highest pending_request_count. Include field_logistics_site_id, field_logistics_site_name, pending_request_count, capacity_supply_units, alert_count, and operational_status. Order by pending_request_count descending, then field_logistics_site_id ascending.',
             profile_name => 'EU_GENAI',
             action       => 'runsql'
           ) AS answer
    FROM dual;
    ```
    </copy>

2. Treat the rows as dynamic. Check that there are no more than five active sites and that the answer uses the view's existing counts. A busy site with alerts deserves investigation, but these aggregates do not establish that a particular request cannot be fulfilled.

    **Expected output pattern**

    | Check | Expected behavior |
    | --- | --- |
    | Row limit | At most five sites. |
    | Ordering | Pending-request count descending; site ID ascending breaks ties. |
    | Evidence | Request counts, supply units, alerts, and operational status support review. |

## Task 5: Improve the business question

1. Ask for capacity-at-risk services and inspect the SQL first.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_ASSET_CAPACITY_V, show Gas Utility service/site rows whose capacity_status is AT_RISK or OUT_OF_STOCK. Include utility_service_id, utility_service_name, field_logistics_site_id, field_logistics_site_name, quantity_on_hand, quantity_reserved, reorder_point, and capacity_status. Order OUT_OF_STOCK before AT_RISK, then quantity_on_hand minus quantity_reserved ascending, then utility_service_id and field_logistics_site_id ascending.',
             profile_name => 'EU_GENAI',
             action       => 'showsql'
           ) AS generated_sql
    FROM dual;
    ```
    </copy>

2. Check that the SQL uses the capacity view, filters `Gas Utility` and both requested statuses, and orders by status priority, net units, service ID, and site ID. The view already combines service, inventory, and site information; do not require unnecessary joins. Then change `showsql` to `runsql` and run it, subject to the separate-generation caveat in Task 4.

    **Interpret the result:** A low net supply count identifies a service/site pair for review. It does not prove a service outage, allocate stock to an individual request, or authorize a stock movement.

## Task 6: Explain the result

1. Use narration only for data approved for the configured provider. `NARRATE` can send returned database values to that provider and produces prose, not a structured or authoritative result.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_FIELD_LOGISTICS_SITES_V, summarize the five active field-logistics sites with the highest pending_request_count. Cite site ID, site name, pending_request_count, capacity_supply_units, alert_count, and operational_status. Rank pending_request_count descending, then site ID ascending. Do not infer individual request outcomes.',
             profile_name => 'EU_GENAI',
             action       => 'narrate'
           ) AS explanation
    FROM dual;
    ```
    </copy>

2. Compare every number in the narration with the Task 4 database result. This is another provider call, not a guaranteed explanation of a cached Task 4 answer. Investigate differences; do not treat fluent prose as additional database evidence.

> **Checkpoint:** AI wording and generated SQL are dynamic. `SHOWSQL`, database privileges, the profile metadata scope, and result comparison keep the operation reviewable. The object list improves relevance; database security controls authorization.

> **🎯 Interactive challenge:** Change Task 5's service category from Gas Utility to Water/Wastewater Utility. Use `SHOWSQL` first. Which filter should change, and which ordering and status checks should stay the same?

<details>
<summary><strong>Challenge answer</strong></summary>

The category filter should change. Both constrained-capacity statuses, requested columns, and ordering keys should remain. Check the category spelling against the available service data. Individual request-status questions require context beyond these aggregate views and are not part of this exercise.

</details>

## Conclusion: Ask, inspect, and refine

The intended workflow is to ask, inspect, run, and compare. Jessica verifies context and SQL meaning; Nina interprets the operational evidence. Live execution, generated SQL, result ordering, and provider behavior remain environment-validation pending until the approved `EU_GENAI` environment is available and these steps are tested.

## Next Steps

In Lab 8, Jessica organizes the same questions into an agent, tool, task, and team intended for read-only operational review. The platform must verify that intention against the actual execution path and permissions.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
