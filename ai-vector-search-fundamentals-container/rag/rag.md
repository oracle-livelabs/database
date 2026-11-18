# Retrieval-Augmented Generation with Private AI Services Container

## Introduction

Retrieval-augmented generation (RAG) adds relevant private data to a prompt before sending it to a large language model. The retrieved context helps the model answer questions about information that was not part of its training data.

This lab keeps both AI operations on the Private AI Services Container. The `all-minilm-l12-v2` service generates vectors for retrieval, and the `Ministral-3-3B-Reasoning-2512-Q8_0` service generates the final response. Autonomous AI Database Serverless stores the support data, runs the similarity search, builds the grounded prompt, and calls the container through PL/SQL.

Estimated Time: 25 minutes

### About This Lab

The `INCIDENT` schema contains 500 synthetic support incidents. Each record describes a problem and, for closed or resolved incidents, the resolution. You will retrieve relevant resolutions and add them to the prompt so the model can answer from the support data.

The container exposes both services through the same HTTP endpoint:

* `/v1/embeddings` for vector generation
* `/v1/chat/completions` for text generation

No OCI Generative AI credential is required for this private HTTP configuration. The database network ACL and endpoint access are prepared by the workshop environment.

### Objectives

In this lab, you will:

* Verify the support incident vector column
* Generate incident embeddings through the container
* Call the container-hosted LLM from PL/SQL
* Retrieve similar resolved incidents
* Build a grounded prompt and generate a RAG response
* Explore the Support Incidents APEX application

### Prerequisites

This lab assumes you have:

* Completed the Vector Embeddings lab
* Completed the Generate Text with the Container LLM lab
* A healthy Private AI Services Container endpoint
* Access to the `INCIDENT` database user

## Task 1: Prepare the Incident Data

1. Open Database Actions SQL Worksheet and connect as `INCIDENT`.

    Use the password provided in the workshop login information.

2. Verify the 384-dimensional vector column prepared by the workshop environment.

    ```sql
    <copy>
    SELECT column_name, data_type
    FROM user_tab_columns
    WHERE table_name = 'SUPPORT_INCIDENTS'
      AND column_name = 'INCIDENT_VECTOR';
    </copy>
    ```

    The result contains one `INCIDENT_VECTOR` column with data type `VECTOR`. The environment populates this column before handoff so the APEX application is ready to use; the next task regenerates the vectors so you can run the complete workflow yourself.

    ![Support incident vector column](images/incident-vector-column.png " ")

## Task 2: Generate Incident Embeddings

Each support incident is sent to `all-minilm-l12-v2`. The returned vector is stored with the incident and can then be searched entirely inside the database.

1. Generate an embedding for every incident.

    ```sql
    <copy>
    BEGIN
      UTL_HTTP.set_transfer_timeout(120);
    END;
    /

    UPDATE support_incidents s
    SET incident_vector = (
      SELECT DBMS_VECTOR.UTL_TO_EMBEDDING(
               s.incident_text,
               JSON_OBJECT(
                 'provider' VALUE 'privateai',
                 'credential_name' VALUE NULL,
                 'url' VALUE c.config_value || '/v1/embeddings',
                 'host' VALUE 'local',
                 'model' VALUE 'all-minilm-l12-v2'
                 RETURNING JSON
               )
             )
      FROM nationalparks.private_ai_config c
      WHERE c.config_name = 'HTTP_ENDPOINT'
    );

    COMMIT;
    </copy>
    ```

    Use **Run Script** and allow the update to complete. The first request can take longer while the model is loaded.

    ![All support incident embeddings generated and committed](images/incident-embeddings-populated.png " ")

2. Verify the result.

    ```sql
    <copy>
    SELECT COUNT(*) AS embedded_incidents,
           MIN(VECTOR_DIMENSION_COUNT(incident_vector)) AS min_dimensions,
           MAX(VECTOR_DIMENSION_COUNT(incident_vector)) AS max_dimensions
    FROM support_incidents
    WHERE incident_vector IS NOT NULL;
    </copy>
    ```

    The expected result is 500 rows with 384 dimensions.

    ![Support incident embedding count and dimensions](images/incident-embedding-count.png " ")

## Task 3: Retrieve Similar Incidents

Generate the question embedding in an uncorrelated scalar subquery. Oracle evaluates the scalar subquery once and uses that vector while searching the incident rows.

1. Retrieve the five closest resolved incidents.

    ```sql
    <copy>
    SELECT s.incident_text,
           s.resolution_notes,
           VECTOR_DISTANCE(
             s.incident_vector,
             (
               SELECT DBMS_VECTOR.UTL_TO_EMBEDDING(
                        'The Camera App times out during authentication',
                        JSON_OBJECT(
                          'provider' VALUE 'privateai',
                          'credential_name' VALUE NULL,
                          'url' VALUE c.config_value || '/v1/embeddings',
                          'host' VALUE 'local',
                          'model' VALUE 'all-minilm-l12-v2'
                          RETURNING JSON
                        )
                      )
               FROM nationalparks.private_ai_config c
               WHERE c.config_name = 'HTTP_ENDPOINT'
             ),
             COSINE
           ) AS distance
    FROM support_incidents s
    WHERE s.status IN ('Closed', 'Resolved')
      AND s.resolution_notes IS NOT NULL
    ORDER BY distance
    FETCH EXACT FIRST 5 ROWS ONLY;
    </copy>
    ```

    These results contain actual resolutions from the synthetic company dataset rather than general knowledge from the LLM.

    ![Resolved support incidents retrieved by vector similarity](images/container-similar-incidents.png " ")

## Task 4: Generate a Grounded Answer

The RAG block retrieves the three nearest incidents, turns their resolutions into a compact context, appends the user question and response instructions, and sends the completed prompt to the container-hosted LLM. Keeping the context concise leaves the included reasoning model enough of its generation budget to return a final answer within the database request timeout.

1. Run the grounded generation block.

    ```sql
    <copy>
    SET SERVEROUTPUT ON

    DECLARE
      l_endpoint      VARCHAR2(1000);
      l_params        JSON;
      l_context       CLOB := TO_CLOB('');
      l_prompt        CLOB;
      l_response      CLOB;
      l_query_vector  VECTOR;
      l_user_question VARCHAR2(1000) :=
        'The Camera App times out during authentication';
    BEGIN
      SELECT config_value
      INTO l_endpoint
      FROM nationalparks.private_ai_config
      WHERE config_name = 'HTTP_ENDPOINT';

      l_query_vector := DBMS_VECTOR.UTL_TO_EMBEDDING(
        l_user_question,
        JSON_OBJECT(
          'provider' VALUE 'privateai',
          'credential_name' VALUE NULL,
          'url' VALUE l_endpoint || '/v1/embeddings',
          'host' VALUE 'local',
          'model' VALUE 'all-minilm-l12-v2'
          RETURNING JSON
        )
      );

      FOR r IN (
        SELECT s.resolution_notes,
               VECTOR_DISTANCE(s.incident_vector, l_query_vector, COSINE) AS distance
        FROM support_incidents s
        WHERE s.status IN ('Closed', 'Resolved')
          AND s.resolution_notes IS NOT NULL
        ORDER BY distance
        FETCH EXACT FIRST 3 ROWS ONLY
      ) LOOP
        l_context := l_context ||
          '- ' || r.resolution_notes || CHR(10);
      END LOOP;

      l_prompt :=
        'Answer the support question using only the retrieved resolutions. ' ||
        'Return one concise final answer and do not show reasoning. ' ||
        'If the resolutions are insufficient, say what information is missing.' ||
        CHR(10) || CHR(10) ||
        'Question: ' || l_user_question || CHR(10) || CHR(10) ||
        'Retrieved resolutions:' || CHR(10) || l_context;

      l_params := JSON_OBJECT(
        'provider' VALUE 'privateai',
        'url' VALUE l_endpoint || '/v1/chat/completions',
        'host' VALUE 'local',
        'model' VALUE 'Ministral-3-3B-Reasoning-2512-Q8_0',
        'temperature' VALUE 0,
        'max_tokens' VALUE 256,
        'transfer_timeout' VALUE 120
        RETURNING JSON
      );

      l_response := DBMS_VECTOR_CHAIN.UTL_TO_GENERATE_TEXT(
        l_prompt,
        l_params
      );

      DBMS_OUTPUT.put_line(DBMS_LOB.substr(l_response, 32000, 1));
    END;
    /
    </copy>
    ```

    The grounded response should reflect the resolutions retrieved from `SUPPORT_INCIDENTS`, unlike the general model answers generated in the previous lab.

    ![Grounded support answer generated by the container LLM](images/container-grounded-rag-response.png " ")

## Task 5: Open the Support Incidents Application

The workshop environment includes an APEX application that applies the same retrieval and generation flow.

1. Open the **RAG Demo** URL from the workshop login information.

    ![Support Incidents RAG application](images/container-rag-apex-initial.png " ")

2. Ask the application:

    ```text
    The Camera App times out during authentication
    ```

3. Compare its response with the SQL result from Task 4.

    ![Grounded answer returned by the Support Incidents application](images/container-rag-apex-response.png " ")

The application uses a schema function that performs the same embedding, retrieval, prompt construction, and text-generation steps as the SQL exercises. The page sends one grounded user prompt to the container because the included model accepts user messages rather than a separate system-message role.

## Learn More

* [Use the Private AI Services Container LLM Service with HTTP in PL/SQL](https://blogs.oracle.com/coretec/how-to-use-the-oracle-private-ai-services-container-llm-service-with-http-in-pl-sql)
* [DBMS_VECTOR_CHAIN](https://docs.oracle.com/en/database/oracle/oracle-database/26/arpls/dbms_vector_chain1.html)
* [Oracle AI Vector Search User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/index.html)
* [Oracle Private AI Services Container User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/prvai/)

## Acknowledgements

* **Author** - Andy Rivenes, Product Manager, AI Vector Search
* **Contributors** - David Start
* **Last Updated By/Date** - David Start, August 2026
