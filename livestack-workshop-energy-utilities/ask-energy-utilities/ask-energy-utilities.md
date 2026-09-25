# Ask Energy and Utilities Questions with Select AI

## Introduction

Nina Patel is an operations analyst. She knows the business question she wants to ask, but she does not want every answer to begin with finding the right view, column, join, and filter. Jessica has configured a Select AI profile for the governed Energy and Utilities query surfaces.

Nina follows a deliberate pattern: ask, inspect the generated SQL, run it only when it makes sense, refine the question, and compare any narration with the database result.

Estimated Time: **10 minutes**

### Objectives

- Check the Select AI profile and permitted objects.
- Generate SQL from a utility operations question.
- Run and refine the question.
- Explain why generated SQL and narration still require review.

### Hands-on Scenario

Nina needs the five field operations sites with the most open requests, plus the capacity evidence needed for an operations review.

> **SQL Worksheet reminder:** Return to [Getting Started Task 2](?lab=getting-started#Task2:OpenSQLWorksheet) if you need the launch and execution steps.

> **Platform prerequisite — live validation pending:** Live execution requires an enabled, LLUSER-accessible `EU_GENAI` profile, an approved provider credential and model, working provider connectivity, and an `object_list` limited to the governed Energy and Utilities views used in this lab. If the profile is unavailable, stop after Task 1 and tell the facilitator. The workshop loader does not create or modify profiles, credentials, models, or provider connectivity.

> **Data-use disclosure:** Select AI sends the learner's prompt and applicable schema metadata or other configured context to the AI provider. Do not include passwords, credentials, personal data, confidential operational details, or other sensitive information in a prompt. Task 6 separately explains when returned database values may also be sent to the provider.

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

## Task 2: Add the governed utility views

1. Set a narrow list of business-facing views for this lab. This changes only the Energy and Utilities profile context used by these exercises.

    <copy>
    ```sql
    BEGIN
      DBMS_CLOUD_AI.SET_ATTRIBUTE(
        profile_name    => 'EU_GENAI',
        attribute_name  => 'object_list',
        attribute_value =>
          '[{"owner":"' || USER || '","name":"EU_FIELD_LOGISTICS_SITES_V"},' ||
           '{"owner":"' || USER || '","name":"EU_ASSET_CAPACITY_V"},' ||
           '{"owner":"' || USER || '","name":"EU_UTILITY_SERVICES_V"}]'
      );
    END;
    /
    ```
    </copy>

2. Verify the setting without exposing credentials.

    <copy>
    ```sql
    SELECT profile_name, attribute_name, attribute_value
    FROM user_cloud_ai_profile_attributes
    WHERE profile_name = 'EU_GENAI'
      AND attribute_name = 'object_list';
    ```
    </copy>

    The `object_list` supplies a limited set of schema metadata as model context for natural-language SQL generation. It does not grant access and is not an authorization boundary. The LLUSER session privileges and database security controls, including Virtual Private Database (VPD) or row-level policies, remain the enforcement controls.

## Task 3: Ask a question and inspect the SQL

Database Actions SQL Worksheet uses `DBMS_CLOUD_AI.GENERATE` rather than the `SELECT AI` convenience command.

1. Generate SQL without executing it.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Which five field operations sites have the most open utility service requests? Include the site name, site type, current load percentage, open request count, and a capacity alert count where quantity on hand is at or below the reorder point.',
             profile_name => 'EU_GENAI',
             action       => 'showsql'
           ) AS generated_sql
    FROM dual;
    ```
    </copy>

2. Check that the generated statement uses only permitted objects, orders by open work descending, and limits the result to five rows.

## Task 4: Run the reviewed question

1. After reviewing the generated SQL, run the same question.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Which five field operations sites have the most open utility service requests? Include the site name, site type, current load percentage, open request count, and a capacity alert count where quantity on hand is at or below the reorder point.',
             profile_name => 'EU_GENAI',
             action       => 'runsql'
           ) AS answer
    FROM dual;
    ```
    </copy>

2. Treat the rows as dynamic. Confirm that there are no more than five sites and that each count comes from request or inventory rows.

    **Expected output pattern**

    | Check | Expected behavior |
    | --- | --- |
    | Row limit | At most five sites. |
    | Ordering | Sites with more open requests appear first. |
    | Evidence | Site type, load, open work, and capacity alerts support the review. |

## Task 5: Improve the business question

1. Ask for capacity-at-risk services and inspect the SQL first.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Show Gas Utility services with capacity at risk. Include the service name, field logistics site, quantity on hand, quantity reserved, reorder point, and capacity status. Order the most constrained rows first.',
             profile_name => 'EU_GENAI',
             action       => 'showsql'
           ) AS generated_sql
    FROM dual;
    ```
    </copy>

2. Check that the SQL joins service, inventory, and site data; filters Gas Utility records; and orders constrained capacity sensibly. Then change `showsql` to `runsql` and run it.

## Task 6: Explain the result

1. Use narration only for data approved for the configured provider. `NARRATE` can send returned database values to that provider and produces prose, not a structured or authoritative result.

    <copy>
    ```sql
    SELECT DBMS_CLOUD_AI.GENERATE(
             prompt       => 'Summarize the five field operations sites with the most open utility service requests. Cite the site name, site type, open request count, capacity alert count, and current load percentage.',
             profile_name => 'EU_GENAI',
             action       => 'narrate'
           ) AS explanation
    FROM dual;
    ```
    </copy>

2. Compare every number in the narration with the Task 4 database result.

> **Checkpoint:** AI wording and generated SQL are dynamic. `SHOWSQL`, database privileges, the profile metadata scope, and result comparison keep the operation reviewable. The object list improves relevance; database security controls authorization.

> **🎯 Interactive challenge:** Add a request-status constraint to the prompt. Inspect the generated SQL and identify the predicate that implements it before you run the query.

<details>
<summary><strong>Challenge answer</strong></summary>

The exact SQL can vary. It should include a clear status predicate, use only permitted objects, preserve the requested columns, and retain the five-row limit.

</details>

## Conclusion: Ask, inspect, and refine

Nina asked in ordinary language without giving up SQL visibility. She inspected the query, bounded the object list, ran an approved question, and checked the explanation against database evidence.

## Next Steps

In Lab 8, Nina and Jessica place the same read-only data access behind an explicit agent tool, task, and team.

## Acknowledgements

* **Author** - Oracle Database Product Management
* **Last Updated By/Date** - Oracle Database Product Management, September 2026
