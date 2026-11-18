# Lab 5: Build a Movie Agent

## Introduction

A movie fan may remember a theme before a title: "heroes working together against an alien threat." In Lab 4, you searched for requests like this through `MOVIES_DV`. Now you will build an assistant that finds relevant movies and explains its recommendations in everyday language.

Two models support the assistant. `MULTILINGUAL_E5_BASE` turns the question into a vector. A database function uses that vector to retrieve matching movie documents through the duality view. The generative model configured in Select AI uses those documents to write an answer. You will register the function as a tool and instruct an agent to use it. Then you will inspect the history to see which documents supported the response.

In your own tenancy, you first configure the OCI credential and Select AI profile. You will check model availability in your region and compartment before choosing the profile's generative model.

Estimated Time: 30 minutes

### Objectives

- Configure an OCI Generative AI profile for Select AI.
- Expose semantic search over `MOVIES_DV` as an agent tool.
- Create an agent, task, and team that use the tool.
- Ask movie questions and trace the answers back to retrieved documents.

### Prerequisites

- Completed Labs 1 through 4, including the populated E5-base embeddings and `MOVIES_DV`.
- A database with Select AI Agent available and permission to create PL/SQL functions.
- Access to an OCI API signing key and a compartment with an approved Generative AI chat model.

If your administrator has already prepared a profile, use its name wherever `OCI_AI_PROFILE` appears and continue at Task 1, Step 5.

## Task 1: Configure Select AI in your tenancy

1. Confirm the Select AI package privileges (optional when running as `ADMIN`).

    If you are connected as `ADMIN`, continue at Step 2. For another workshop user, ask your database administrator to grant any missing package privileges to your workshop schema. The administrator runs these statements:

    ```sql
    GRANT EXECUTE ON DBMS_CLOUD TO <WORKSHOP_USER>;
    GRANT EXECUTE ON DBMS_CLOUD_AI TO <WORKSHOP_USER>;
    GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO <WORKSHOP_USER>;
    ```

2. Create an OCI API signing-key credential if `OCI_GENAI_CREDS` does not already exist.

    Replace the placeholders with your OCI user OCID, tenancy OCID, API signing private key, and key fingerprint. Use a private key without a passphrase. Provide the key body on one line, without the PEM `BEGIN` and `END` lines. Retain any trailing `=` padding in the key body and keep the real values out of shared workshop files.

    ```sql
    BEGIN
      DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'OCI_GENAI_CREDS',
        user_ocid       => '<OCI_USER_OCID>',
        tenancy_ocid    => '<OCI_TENANCY_OCID>',
        private_key     => '<OCI_PRIVATE_KEY>',
        fingerprint     => '<OCI_KEY_FINGERPRINT>'
      );
    END;
    /
    ```

3. Check which OCI Generative AI chat models are available for your region and compartment.

    In the OCI Console, select your region and open **Analytics & AI** > **Generative AI**. Select your compartment, open **Playground** > **Chat**, and check the model list. Availability depends on the region, compartment, and tenancy access. The preferred models for this workshop are:

    - `xai.grok-4.7`
    - `google.gemini-2.5-pro`

    Choose an available preferred model that supports tool calling for Select AI Agent. See Oracle's [Playground instructions](https://docs.oracle.com/en-us/iaas/Content/generative-ai/use-playground-chat.htm) and [model availability by region](https://docs.oracle.com/en-us/iaas/Content/generative-ai/model-endpoint-regions.htm). If neither preferred model is listed, ask your administrator which available model to use.

4. Create the OCI Generative AI profile used by the movie agent.

    Replace the placeholders before running the block:

    | Placeholder | Value |
    | --- | --- |
    | `<OCI_GENERATIVE_AI_MODEL>` | Exact model identifier confirmed in the Playground. |
    | `<OCI_REGION>` | OCI region containing the available model. |
    | `<OCI_COMPARTMENT_OCID>` | Compartment where you can use the model. |
    | `<WORKSHOP_SCHEMA>` | Database schema containing `MOVIES_DV`. |
    | `<OCI_GENERATIVE_AI_ENDPOINT>` | Generative AI inference endpoint for your region. |

    The `provider_endpoint` attribute is optional for the default public endpoint. Supply your regional endpoint or remove that attribute.

    The `object_list` supplies `MOVIES_DV` as database context for SQL generation. Database privileges control access to the data. The view exposes movie JSON under `movie` and the E5-base vector under `embedding`.

    ```sql
    BEGIN
      DBMS_CLOUD_AI.CREATE_PROFILE(
        profile_name => 'OCI_AI_PROFILE',
        attributes   => '{
          "provider": "oci",
          "provider_endpoint": "<OCI_GENERATIVE_AI_ENDPOINT>",
          "credential_name": "OCI_GENAI_CREDS",
          "region": "<OCI_REGION>",
          "model": "<OCI_GENERATIVE_AI_MODEL>",
          "conversation": "true",
          "comments": true,
          "oci_compartment_id": "<OCI_COMPARTMENT_OCID>",
          "object_list": [
            {"owner": "<WORKSHOP_SCHEMA>", "name": "MOVIES_DV"}
          ],
          "annotations": true,
          "temperature": 0.4,
          "additional_instructions": "Use the movie property in MOVIES_DV for movie facts. The embedding property is an E5-base retrieval vector, not movie content; do not describe or return vector values."
        }'
      );
    END;
    /
    ```

    For OCI Generative AI on Autonomous Database, a network ACL grant is not required. See [Oracle's Select AI profile guidance](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/manage-ai-profiles.html). The `oci_apiformat` attribute is omitted for the standard on-demand model-name configuration; use it only when required by the selected OCI chat model or endpoint.

5. Set the profile for the current session and test that Select AI can call its configured generative model.

    ```sql
    EXEC DBMS_CLOUD_AI.SET_PROFILE('OCI_AI_PROFILE');

    SELECT AI "Tell me about movies with superheroes saving others";
    ```

    Continue when you receive a response. This checks the profile before you build the custom movie-search tool. In Task 4, you will route the question through the agent and inspect its tool calls. If this check fails, verify the endpoint, credential, model availability, compartment, and required privileges with your administrator.

## Task 2: Create the movie-search tool

1. Create a function that embeds a movie question with E5-base and searches the duality view.

    The function searches the view's `embedding` field, which maps to `MOVIES.EMBEDDING_E5_BASE`. It returns up to five `movie` objects as newline-delimited JSON. These documents supply the agent's context; the vector values stay out of the response.

    ```sql
    CREATE OR REPLACE FUNCTION search_movies (
      p_query IN CLOB
    ) RETURN CLOB
    AUTHID DEFINER
    IS
      l_context CLOB;
    BEGIN
      DBMS_LOB.CREATETEMPORARY(l_context, TRUE);

      FOR movie_row IN (
        SELECT JSON_QUERY(m.data, '$.movie' RETURNING CLOB) AS movie_document
        FROM movies_dv m
        ORDER BY VECTOR_DISTANCE(
                   JSON_VALUE(
                     m.data,
                     '$.embedding'
                     RETURNING VECTOR
                   ),
                   VECTOR_EMBEDDING(
                     MULTILINGUAL_E5_BASE
                     USING p_query AS data
                   ),
                   COSINE
                 )
        FETCH FIRST 5 ROWS ONLY
        WITH TARGET ACCURACY 90
      ) LOOP
        DBMS_LOB.APPEND(l_context, movie_row.movie_document);
        DBMS_LOB.WRITEAPPEND(l_context, 1, CHR(10));
      END LOOP;

      RETURN l_context;
    END;
    /
    ```

2. Register the function as a Select AI Agent tool.

    Registering `SEARCH_MOVIES` makes it available to the agent as `MOVIE_SEARCH_TOOL`. The instruction describes when to use it and tells the agent to pass the complete movie request to `p_query`.

    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
        tool_name   => 'MOVIE_SEARCH_TOOL',
        attributes  => '{
          "instruction": "Retrieve the five most relevant movie documents from MOVIES_DV. Pass the complete natural-language movie request in the p_query argument.",
          "function": "SEARCH_MOVIES"
        }',
        description => 'Semantic movie retrieval over the MOVIES_DV duality view.'
      );
    END;
    /
    ```

3. Inspect the registered tool before the agent uses it.

    Inspect the tool definition and check that its input schema includes `P_QUERY`. This is the argument the agent will populate with the movie question.

    ```sql
    SELECT DBMS_CLOUD_AI_AGENT.DESCRIBE_TOOL(
             tool_name => 'MOVIE_SEARCH_TOOL'
           ) AS tool_definition
    FROM dual;
    ```

## Task 3: Create the movie agent and team

The agent defines the assistant's role, the task tells it how to answer, and the team connects the two. This lab uses one agent and one task.

1. Create an agent that uses the Select AI profile and bases its answers on retrieved movie documents.

    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
        agent_name  => 'MOVIE_ANALYST',
        attributes  => '{
          "profile_name": "OCI_AI_PROFILE",
          "role": "You are a movie search assistant. Use MOVIE_SEARCH_TOOL to ground every movie fact. Do not invent titles, years, genres, or subjects. If the retrieved documents do not answer the question, say that no matching movie was found."
        }',
        description => 'Answers movie questions using semantic retrieval from MOVIES_DV.'
      );
    END;
    /
    ```

2. Create a task that calls the retrieval tool before writing the answer.

    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TASK(
        task_name  => 'ANSWER_MOVIE_TASK',
        attributes => '{
          "instruction": "Answer the user movie question: {query}. First call MOVIE_SEARCH_TOOL with p_query set to the complete user question. Use only the returned movie documents as factual context. State the best matching title and briefly explain why it matches. If no movie is relevant, say that no matching movie was found.",
          "tools": ["MOVIE_SEARCH_TOOL"],
          "enable_human_tool": "false"
        }'
      );
    END;
    /
    ```

3. Create a sequential team that assigns the task to the movie agent.

    ```sql
    BEGIN
      DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
        team_name  => 'MOVIE_AGENT_TEAM',
        attributes => '{
          "agents": [
            {"name": "MOVIE_ANALYST", "task": "ANSWER_MOVIE_TASK"}
          ],
          "process": "sequential"
        }'
      );
    END;
    /
    ```

4. Confirm that the team is discoverable.

    ```sql
    SELECT DBMS_CLOUD_AI_AGENT.LIST_TEAMS() AS teams
    FROM dual;
    ```

## Task 4: Ask the movie agent

1. Set the agent team and ask a natural-language question with Select AI.

    The `AGENT` action sends the question to the team you select with `SET_TEAM`. Its task instructs the agent to call `MOVIE_SEARCH_TOOL` and use the returned movie documents to answer.

    ```sql
    EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('MOVIE_AGENT_TEAM');

    SELECT AI AGENT "Tell me about movies with superheroes saving others";
    ```

    Check that the answer names a retrieved movie and explains why it fits the question. You will inspect the supporting documents in Task 5. Rankings and wording can vary with the embedding and generative models.

    If the tool retrieves `The Avengers`, an answer might read:

    ```text
    The Avengers (2012) is a match. A team of superheroes works together
    to protect others from an alien invasion.
    ```

## Task 5: See the movie agent in action

1. Ask the agent questions that require semantic retrieval rather than an exact title match.

    Run each query separately after setting the team in Task 4. Observe how the same `MOVIE_SEARCH_TOOL` handles different natural-language requests.

    ```sql
    SELECT AI AGENT "Which movie is about a rescue mission during an invasion?";
    ```

    ```sql
    SELECT AI AGENT "Which movie features a group of heroes working together against an alien threat?";
    ```

    Compare the recommendations. Does each answer reflect the theme of its question? The next step lets you check the movie documents the tool actually returned.

2. Inspect the tool history to confirm that the agent applied the created retrieval tool.

    ```sql
    SELECT team_exec_id,
           tool_name,
           agent_name,
           task_name,
           task_order,
           start_date,
           end_date,
           input,
           output
    FROM user_ai_agent_tool_history
    WHERE tool_name = 'MOVIE_SEARCH_TOOL'
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    ```

    Find the tool call for your latest question. `INPUT` shows the value passed to `p_query`; `OUTPUT` contains the retrieved movie JSON. Compare those documents with the answer and note the `TEAM_EXEC_ID` so you can identify the same run below. If there is no corresponding tool call, the response has not demonstrated use of your retrieval tool.

3. Inspect the team and task history for the same runs.

    ```sql
    SELECT team_exec_id,
           team_name,
           start_date,
           end_date,
           state
    FROM user_ai_agent_team_history
    WHERE team_name = 'MOVIE_AGENT_TEAM'
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    ```

    ```sql
    SELECT team_exec_id,
           agent_name,
           task_name,
           task_order,
           state,
           result
    FROM user_ai_agent_task_history
    WHERE task_name = 'ANSWER_MOVIE_TASK'
    ORDER BY start_date DESC
    FETCH FIRST 5 ROWS ONLY;
    ```

    Match the `TEAM_EXEC_ID` across the three views. A completed run should have a `SUCCEEDED` state, a call to `MOVIE_SEARCH_TOOL`, and an answer supported by the tool output. These records trace the question through the team, search function, and final response.

You have built a movie assistant over the same JSON and relational embeddings used in the earlier labs. The duality view supplies the movie documents and retrieval vectors through one interface; the tool makes that search available to the agent.

## Learn More

- [Select AI Agent concepts](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/select-ai-agents-concepts.html)
- [DBMS_CLOUD_AI_AGENT package reference](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-agent-package.html)
- [Agent execution history views](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-views-history.html)

## Acknowledgements

* **Author** - Gael Palomino
* **Last Updated By/Date** - Gael Palomino, November 2026
