# Ask Energy and Utilities Questions with Select AI

## Introduction

Nina Patel is an operations analyst at Seer Utility Network. Jessica has helped the team inspect service requests, operational relationships, nearby sites, and a demand watchlist. Nina now wants to ask follow-up questions without writing every SQL statement from scratch: **which active sites have the largest pending-request workload, and where do gas services have constrained supplies?**

Jessica introduces Select AI to help translate those questions into SQL. Nina supplies the business question; the configured AI model uses database context to generate a query. Jessica helps her check whether that query uses the intended views, filters, and calculations before interpreting the result.

This lab focuses on approved site, service, and capacity views. Site-level request counts provide workload context; they do not expose individual request details or the full reliability-signal history. Field-logistics capacity describes supplies available to support a response, not electrical generation capacity.

You work with Nina to inspect the prepared AI profile, generate SQL, review its logic, and explore execution and narration. The goal is a database-supported review list—not an automatic dispatch decision or an answer that should be trusted without checking.

![Jessica, DBA, and Nina, Operations Analyst, introduce asking operational questions, reviewing generated SQL, and checking results](images/nina.png " ")

<details>
<summary><strong>Key terms: Select AI, AI profile, object list, generated SQL, and narration</strong></summary>

- **Select AI** uses a configured AI model to help translate natural-language questions into SQL. The generated query still needs review for business meaning and correctness.

- An **AI profile** contains configuration such as the provider, model, credential reference, and database context. This lab uses the platform-managed `EU_GENAI` profile; you do not create or modify its configuration.

- An **object list**, configured through `object_list`, identifies database objects supplied as context for SQL generation. It does not grant database permissions. Do not assume that listing approved views alone establishes a complete access-control boundary; platform configuration and database privileges must also be verified.

- **Generated SQL** is the statement produced from a natural-language question. `SHOWSQL` displays generated SQL for inspection, while `RUNSQL` generates and executes SQL. A separate execution request should not be assumed to reuse exactly the statement previously displayed.

- **Narration** is an AI-generated explanation of query results. For natural-language-to-SQL use, `NARRATE` can send database result values to the configured provider. Its explanation must be checked against the underlying results.

</details>

### Objectives

- Inspect the platform-managed Select AI profile and approved database context without changing them.
- Generate SQL from an Energy and Utilities operations question.
- Review the generated query’s objects, joins, filters, and ordering.
- Execute and refine questions within the approved workshop environment.
- Compare any generated narration with database results.
- Explain the data-use and access-control boundaries of the workflow.

**Platform prerequisite — live validation pending**

Live execution requires an enabled, LLUSER-accessible `EU_GENAI` profile, an approved provider credential and model, working provider connectivity, and an `object_list` limited to the approved Energy and Utilities views used in this lab.

If the profile or required access is unavailable, stop after the prerequisite checks in Task 1 and tell the facilitator. The workshop loader does not create or modify the profile, credentials, provider-model settings, or connectivity.

**Data-use disclosure**

Prompts and applicable schema metadata or other configured context may be sent to the AI provider. Do not include passwords, credentials, personal data, confidential operational details, or other sensitive information in a prompt.

Narration can also send query-result values to the provider; review Task 6’s disclosure and proceed only with approved workshop data.

**Execution boundary**

Inspecting SQL with `SHOWSQL` is a review step, not an approval mechanism that binds a later `RUNSQL` or `NARRATE` call to that exact statement.

To execute precisely the SQL you reviewed, use that reviewed statement directly in SQL Worksheet within your authorized scope.
Estimated Time: **10 minutes**

<video controls width="100%">
  <source src="https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/livestack/Videos/Finance/07-Finance%20Workshop_LAB-7_with-CC.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

*The video uses a Finance example. Follow the E&U tasks below for this lab’s approved profile, views, and operational questions.*

### Hands-on Scenario

Jessica and Nina identify active field-logistics sites with the largest pending-request workload, then examine Gas Utility service/site rows with constrained supplies.

| Step | Energy & Utilities focus |
| --- | --- |
| Business Problem | Nina needs answers to operational follow-up questions without writing every SQL statement from scratch. |
| Technical Challenge | Translate business wording into queries that use the intended views, filters, and calculations. |
| Persona Focus | You work with Nina, the operations analyst, and Jessica, the DBA, to review generated SQL and its results. |
| What You Will Do | Inspect the prepared profile, generate and review SQL, refine questions, and compare narration with database evidence. |
| Database Capability | Select AI combines natural-language SQL generation with query execution and result narration. |
| Outcome | Produce a database-supported review list while recognizing that generated queries and explanations require verification. |

> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

## Task 1: Check the Select AI profile

Before Nina sends an operational question to Select AI, Jessica checks that the approved `EU_GENAI` profile is available to the learner account. This query reads profile metadata; it does not change the configuration or call the AI provider.

1. Run the profile inventory as `LLUSER`.

    ```sql
    <copy>
    SELECT profile_name, status, description
    FROM user_cloud_ai_profiles
    WHERE profile_name = 'EU_GENAI';
    </copy>
    ```

    **Expected output when the prerequisite is provisioned:** A row for `EU_GENAI` with status `ENABLED`. The description may vary.

2. Check the returned status.

    If no row appears, the status is not `ENABLED`, or the query fails, stop and tell the facilitator. Do not create, enable, modify, or substitute another profile.

> **Checkpoint:** An enabled profile is a prerequisite, not proof that provider connectivity, model access, or the approved object configuration works. Those still require verification before live execution.

## Task 2: Inspect the governed utility context

Before Nina asks an operational question, Jessica checks which database objects the approved profile supplies as context. This helps Nina understand which questions the lab is designed to answer.

1. Read only the profile’s object list. Do not change the profile or query credential attributes.

    ```sql
    <copy>
    SELECT profile_name, attribute_name, attribute_value
    FROM user_cloud_ai_profile_attributes
    WHERE profile_name = 'EU_GENAI'
      AND attribute_name = 'object_list';
    </copy>
    ```

    The `object_list` supplies schema metadata as context for natural-language SQL generation. It does not grant database access. The list alone does not prove that generated queries are restricted to those objects; database privileges and any configured enforcement must also be verified.

2. Confirm that the platform-approved context identifies the following views with owner `LLUSER`.

    | View | Questions supported in this lab |
    | --- | --- |
    | `EU_FIELD_LOGISTICS_SITES_V` | Active sites, pending-request counts, supply units, and alerts. |
    | `EU_ASSET_CAPACITY_V` | Service/site supplies, reservations, reorder points, and capacity status. |
    | `EU_UTILITY_SERVICES_V` | Service names, categories, descriptions, and operators or partners. |

    If the context is missing, includes unexpected objects, or differs from the approved configuration, stop and ask the facilitator to verify it before making an AI call. Do not add or remove objects yourself.

> **Checkpoint:** Nina’s questions must stay within the approved site, service, and capacity context. These views do not expose individual request details or the full reliability-signal history. This check also does not establish that Virtual Private Database (VPD) or other row-level policies are configured.

## Task 3: Ask a question and inspect the SQL

Nina starts with a focused operational question: **which active field-logistics sites have the largest pending-request workload?** Jessica helps her inspect the generated SQL before proceeding.

This lab uses `DBMS_CLOUD_AI.GENERATE` in Database Actions SQL Worksheet. Continue only after the profile and approved context checks in Tasks 1–2 pass.

1. Generate SQL without executing the generated statement.

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_FIELD_LOGISTICS_SITES_V, show the five active field-logistics sites with the highest pending_request_count. Include field_logistics_site_id, field_logistics_site_name, pending_request_count, capacity_supply_units, alert_count, and operational_status. Order by pending_request_count descending, then field_logistics_site_id ascending.',
             profile_name => 'EU_GENAI',
             action       => 'showsql'
           ) AS generated_sql
    FROM dual;
    </copy>
    ```

    `SHOWSQL` requests SQL from the configured AI provider. It does not execute that generated SQL, but it still makes an AI request using the prompt and configured context.

2. Review the generated statement against Nina’s question.

    | Check | What to verify |
    | --- | --- |
    | Source | Uses `EU_FIELD_LOGISTICS_SITES_V`. |
    | Filter | Selects active sites only. |
    | Columns | Includes the requested site identifiers, names, counts, supply units, alerts, and status. |
    | Row limit | Returns no more than five sites. |
    | Ordering | Sorts by pending-request count descending, then site ID ascending. |

    The view already aggregates request and supply evidence, so an additional join is not required. Its pending-request count covers requests with `pending`, `confirmed`, or `processing` status.

    If the SQL uses unexpected objects, omits a condition, or does not answer the question, refine the prompt and inspect the new statement before continuing.

> **Checkpoint:** SQL that runs successfully can still answer the wrong business question. Check its meaning, not only its syntax.

## Task 4: Run the reviewed question

Nina has reviewed how the question was translated into SQL. She now explores the database result using the same prompt.

1. Run the question within the approved workshop environment.

    `RUNSQL` is a separate generation-and-execution request. It does not guarantee execution of the identical statement displayed by `SHOWSQL`. If your process requires approval of an exact statement, stop here and use the approved SQL execution workflow instead.

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_FIELD_LOGISTICS_SITES_V, show the five active field-logistics sites with the highest pending_request_count. Include field_logistics_site_id, field_logistics_site_name, pending_request_count, capacity_supply_units, alert_count, and operational_status. Order by pending_request_count descending, then field_logistics_site_id ascending.',
             profile_name => 'EU_GENAI',
             action       => 'runsql'
           ) AS answer
    FROM dual;
    </copy>
    ```

2. Review the returned answer against the requested conditions.

    **Expected behavior to verify during live validation**

    | Check | Expected behavior |
    | --- | --- |
    | Scope | Active field-logistics sites only. |
    | Row limit | At most five sites. |
    | Ordering | Pending-request count descending; site ID ascending breaks ties. |
    | Evidence | Site identifiers, request counts, supply units, alerts, and operational status are included. |

    Treat the values as dynamic and verify that the answer uses the view’s existing counts. A busy site with alerts deserves investigation, but these aggregates do not establish that a particular request cannot be fulfilled.

## Task 5: Improve the business question

Nina now moves from site-level workload to a more specific question: **which Gas Utility service/site combinations have constrained supplies?**

1. Generate SQL for the capacity question before requesting execution.

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_ASSET_CAPACITY_V, show Gas Utility service/site rows whose capacity_status is AT_RISK or OUT_OF_STOCK. Include utility_service_id, utility_service_name, field_logistics_site_id, field_logistics_site_name, quantity_on_hand, quantity_reserved, reorder_point, and capacity_status. Order OUT_OF_STOCK before AT_RISK, then quantity_on_hand minus quantity_reserved ascending, then utility_service_id and field_logistics_site_id ascending.',
             profile_name => 'EU_GENAI',
             action       => 'showsql'
           ) AS generated_sql
    FROM dual;
    </copy>
    ```

2. Check the generated SQL.

    Confirm that it:

    - Uses `EU_ASSET_CAPACITY_V`.
    - Filters for the `Gas Utility` category.
    - Includes both `AT_RISK` and `OUT_OF_STOCK` capacity statuses.
    - Returns the requested service, site, and quantity columns.
    - Places `OUT_OF_STOCK` before `AT_RISK`.
    - Then sorts by quantity on hand minus quantity reserved, followed by service ID and site ID.

    The view already combines service, inventory, and site information. Additional joins are not required to answer this question.

3. Once the generated logic has been reviewed, change `showsql` to `runsql` and run the complete statement, subject to the separate-generation limitation in Task 4.

    Inspect the answer rather than assuming it matches the earlier SQL exactly.

> **Checkpoint:** A low net supply quantity identifies a service/site combination for review. It does not prove a service outage, allocate supplies to an individual request, or authorize a stock movement.

## Task 6: Explain the result

Nina wants a short explanation she can discuss with Jessica. Narration can help communicate a result, but the explanation must remain consistent with the database evidence.

1. Proceed only if sending the query-result values to the configured AI provider is approved.

    `NARRATE` can send returned database values to the provider. It produces a natural-language explanation, not an authoritative replacement for the underlying result. If approval is unavailable, skip this call and tell the facilitator.

    ```sql
    <copy>
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Using EU_FIELD_LOGISTICS_SITES_V, summarize the five active field-logistics sites with the highest pending_request_count. Cite site ID, site name, pending_request_count, capacity_supply_units, alert_count, and operational_status. Rank pending_request_count descending, then site ID ascending. Do not infer individual request outcomes.',
             profile_name => 'EU_GENAI',
             action       => 'narrate'
           ) AS explanation
    FROM dual;
    </copy>
    ```

2. Compare the narration with the Task 4 database result.

    Check the site identifiers, names, counts, supply units, alerts, and operational statuses. Look for unsupported conclusions about individual requests or the ability to dispatch resources.

    This is another provider call, not a guaranteed explanation of a cached Task 4 answer. If the results differ, investigate the generated query, data timing, and interpretation before relying on the explanation.

> **Checkpoint:** Generated SQL and narration can vary. Reviewing SQL and comparing results help detect mistakes, but they do not replace access controls. The object list provides context; effective database privileges and configured enforcement govern access.

**🎯 Interactive challenge:** Change Task 5’s service category from `Gas Utility` to `Water/Wastewater Utility`. Use `SHOWSQL` first. Which filter should change, and which status and ordering checks should stay the same?

<details>
<summary><strong>Challenge answer</strong></summary>

The category filter should change to the intended water/wastewater category. Verify its exact spelling against the available service data.

The following should remain unchanged:

- Both constrained-capacity statuses: `AT_RISK` and `OUT_OF_STOCK`.
- The requested service, site, and quantity columns.
- The priority of `OUT_OF_STOCK` before `AT_RISK`.
- The remaining ordering by net quantity, service ID, and site ID.

Review the generated SQL rather than assuming the model changed only the category. Individual request-status questions require context beyond these aggregate views and are outside this exercise.

</details>

## Conclusion: Ask, inspect, and refine

Jessica and Nina’s intended workflow is to ask a focused question, inspect the generated SQL, evaluate the database answer, and check any narration against the evidence.

Jessica reviews the approved context and query logic. Nina interprets the operational meaning without treating generated wording as proof or an instruction to act.

Live execution, generated SQL, result ordering, and provider behavior remain environment-validation pending until the approved `EU_GENAI` environment is available and these steps have been tested.

## Next Steps

In Lab 8, Jessica organizes operational questions into an agent workflow with a tool, task, and team intended for read-only review.

That intention must be verified against the actual tool configuration, execution path, and effective permissions. Describing an agent as read-only does not, by itself, enforce read-only behavior.

## Acknowledgements

* **Author** - Zileyah Onafowora
* **Last Updated By/Date** - Zileyah Onafowora, September 2026
