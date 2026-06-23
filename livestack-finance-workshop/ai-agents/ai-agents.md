# Ask data and automate governed actions

## Introduction

The Ask Data and Agent Console pages show how natural-language assistance and agent actions can sit beside governed Oracle data. You will inspect profiles, generated SQL flow, and audit logs without assuming optional cloud setup is present.

### Objectives

- Map Ask Data and Agent Console routes.
- Review generated SQL and execution routes.
- Inspect agent action history.
- Separate local assistant behavior from optional Select AI setup.

Estimated Time: 12 minutes

## Task 1: Map AI and agent routes

1. Review route groups in `api-map.md`.

    | Page | Route group | Role |
    | --- | --- | --- |
    | Ask Seer Equity Data | `/api/selectai/*` | Natural-language SQL helper and SQL execution |
    | Agent Console | `/api/agents/*` | Agent chat, profiles, actions, events, and summaries |

2. Open `backend-source/routes/selectai.js` and `backend-source/lib/ollamaAssistant.js`.

    The application layer uses a local assistant helper for natural-language SQL flow. The database source also includes optional `DBMS_CLOUD_AI` profiles for environments that support them.

## Task 2: Inspect optional AI profiles

1. Review profile names from the source.

    ```sql
    SELECT 'SC_COHERE_PROFILE' AS profile_name FROM dual
    UNION ALL SELECT 'SC_LLAMA_PROFILE' FROM dual
    UNION ALL SELECT 'SC_GROK42_PROFILE' FROM dual
    UNION ALL SELECT 'SC_VISION_PROFILE' FROM dual
    UNION ALL SELECT 'SC_EMBED_PROFILE' FROM dual;
    ```

## Task 3: Query agent actions

1. Inspect recent agent decisions.

    ```sql
    SELECT agent_name,
           action_type,
           entity_type,
           confidence,
           execution_status,
           created_at
    FROM agent_actions
    ORDER BY created_at DESC
    FETCH FIRST 10 ROWS ONLY;
    ```

## Task 4: Check your work

1. Confirm that optional Select AI setup requires credentials, packages, and network access.

2. Confirm that the workshop does not publish real OCI credentials.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
