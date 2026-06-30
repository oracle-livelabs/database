# Getting Started

## Introduction

Before you inspect launch signals or AI workflows, confirm that SQL Worksheet is pointed at the correct schema. This lab gives learners one fast checkpoint so the rest of the workshop stays grounded in the Media LiveStack objects they are about to query.

### Operating Story

| Step | Workshop-entry focus |
| --- | --- |
| Business Problem | Learners need a clean, repeatable way to enter the Media LiveStack database workflow. |
| Technical Challenge | The SQL exercises only work when Database Actions opens against the workshop schema that owns the Media objects. |
| Persona Focus | Workshop learner, application developer, database developer, or technical presenter. |
| What You Will Prove | The current SQL Worksheet session is connected to the expected workshop schema and service. |
| Database Capability | Database Actions SQL Worksheet, schema context, and Oracle session metadata. |
| Outcome | You enter the rest of the workshop with the correct database context and a safe validation checkpoint. |
{: title="Workshop Entry Operating Story Table"}

Persona focus: this lab is for the learner who wants to avoid debugging the wrong schema before the real workshop begins.

### Objectives

In this lab, you will:

- Open Database Actions SQL Worksheet.
- Confirm the current database user, schema, and service.
- Verify that you are ready to run the Media LiveStack copy blocks.

Estimated Time: **5 minutes**

## Task 1: Confirm the workshop SQL context

Perform the following set of steps to confirm that SQL Worksheet is connected to the correct Media workshop schema before you run the later launch queries:

1. Open **Database Actions**, then open **SQL Worksheet**.
2. Run this query:

    ```sql
    <copy>
    SELECT
      USER AS current_user,
      SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS current_schema,
      CASE
        WHEN EXISTS (
          SELECT 1
          FROM user_views
          WHERE view_name = 'MEDIA_CONTENT_ASSETS_V'
        )
        THEN 'MEDIA_SCHEMA_READY'
        ELSE 'CHECK_SCHEMA'
      END AS workshop_status
    FROM dual;
    </copy>
    ```

    **Expected output:**

    | CURRENT_USER | CURRENT_SCHEMA | WORKSHOP_STATUS |
    | --- | --- | --- |
    | LLUSER | LLUSER | MEDIA_SCHEMA_READY |
    {: title="Workshop SQL Session Context Table"}

3. If your environment uses a different workshop login, the user can vary. The important check is that `WORKSHOP_STATUS` returns `MEDIA_SCHEMA_READY`, which means the session can see the Media LiveStack objects used in the next labs.

**Note:** Sample values may change after data refreshes or rebuilds. Focus on the expected result pattern and the business takeaway, not the exact values.

## Task 2: Keep the workflow aligned with the app

Perform the following set of steps to keep the app view and the SQL evidence aligned while you move through the workshop:

1. Keep SQL Worksheet open in one browser tab.
2. Keep the Seer Media LiveStack app open in another tab so you can compare what the app shows with what the database returns.

The app shows the workflow. SQL Worksheet shows the evidence behind it.

## Acknowledgements

* **Author** - Oracle LiveLabs Team
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
