# Build a JSON Application Model

## Introduction

> **Screenshot update note:** JSON screenshots should show a Midnight Harbor viewing-session or campaign-request document and the matching relational projection.

Thomas Brune is an application developer at Seer Media. He and his team are building a new web and mobile application for viewers. The team wants a faster viewer experience, with fewer round trips and payloads that match the screens and services they are building.

Thomas needs viewing-session data as a JSON payload that a web or mobile application can consume directly. One payload can group viewer, session-status, viewing-event, and optional app-specific attributes. JSON lets him evolve that payload as a title launch changes. The data already lives in Oracle AI Database, so his question is how to use JSON without giving up relational keys, SQL, viewing sessions, and database controls.

Thomas asks Jessica, the DBA, to walk through three ways to work with JSON in Oracle AI Database. They start with a JSON value in a relational table, then a collection of JSON documents, and finally a JSON Relational Duality View over existing relational rows. The goal is to choose the right approach for each application feature without creating a second copy of viewer data.

![thomas](images/thomas.png)

<details>
<summary><strong>Key terms: JSON columns, JSON collections, and JSON Relational Duality</strong></summary>

> - A **JSON column** stores a JSON value in a relational table alongside normal typed columns, keys, and constraints. Thomas can use it for optional or changing application attributes without turning every new attribute into a schema change.
>
> - A **JSON collection** is a special table or view that provides a set of JSON documents through one `JSON`-typed `DATA` column. Each document can have a top-level `_id` used to identify it.
>
> - **JSON Relational Duality** lets Oracle Database expose relational data as JSON documents without copying it into a separate document database. The application gets the document shape Thomas wants for its API. The database keeps the relational rows and controls.
>

</details>

Thomas's application needs a payload with the viewing session and its line items together, such as this:

```json
{
  "_id": 513063,
  "viewerId": 687,
  "status": "confirmed",
  "items": [
    { "titleId": 1, "watch_minutes": 2, "unitPrice": 12.50 }
  ]
}
```

The application uses this document shape, while the database keeps the viewing session and line items in relational form. In this lab, you build and read this type of payload in three ways.

### Objectives

- Store flexible application attributes as JSON in a relational table.
- Create and query a JSON Collection Table of viewing session documents.
- Read and update relational viewing session data through `VIEWING_SESSIONS_DV`.
- Compare the three JSON approaches and choose the right one for an application feature.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step | Media & Entertainment focus |
| --- | --- |
| Business Problem | Thomas's team needs flexible JSON payloads for a new viewer web and mobile application. |
| Technical Challenge | The team needs application-friendly documents while the database keeps relational keys, joins, and controls. |
| Persona Focus | Thomas tests JSON storage, collections, and duality with Jessica's database guidance. |
| What You Will See | One Oracle AI Database supports several JSON access patterns over the media data. |
| Database Capability | Native JSON, SQL/JSON functions, and JSON Relational Duality work together. |
| Outcome | Thomas can choose an application shape without creating a second viewer-data store. |

Persona focus: You are Thomas, working with Jessica to decide how the new application should store, assemble, and read viewer viewing session data.

### Thomas's three JSON choices

Thomas does not need one JSON pattern for every feature. A JSON column holds optional application attributes in a relational table. A JSON Collection Table holds documents owned by the application. A duality view assembles a document from existing relational tables. Thomas uses the document shape in the application, while Jessica works with the underlying rows using SQL.

This keeps the viewing session in one database and avoids complex, expensive integration between separate systems. Thomas gets the document shape his application needs, and Jessica keeps the relational rows, SQL access, and database controls.

> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step guide on how to run SQL statements.

## Task 1: Store flexible application data as JSON

Thomas starts with data that belongs to the application but does not need its own relational columns. The workshop database already contains the viewing session rows. He adds a small application-data table with a native `JSON` column for optional screen and viewer-experience settings.

1. Create the application-data table and add one sample payload.

    ```sql
    <copy>
    CREATE TABLE thomas_app_data (
        session_id  NUMBER PRIMARY KEY,
        app_data  JSON NOT NULL
    );

    INSERT INTO thomas_app_data (session_id, app_data)
    SELECT session_id,
           JSON_OBJECT(
               'screen'    VALUE 'viewing session-detail',
               'showTotal' VALUE 'true' FORMAT JSON,
               'features'  VALUE JSON_ARRAY('live-status', 'saved-recipient')
               RETURNING JSON
           )
    FROM (
        SELECT session_id
        FROM viewing_sessions
        ORDER BY session_id
        FETCH FIRST 1 ROW ONLY
    );

    COMMIT;
    </copy>
    ```

2. Read values from the JSON column.

    ```sql
    <copy>
    SELECT session_id,
           JSON_VALUE(app_data, '$.screen') AS screen_name,
           JSON_VALUE(app_data, '$.showTotal' RETURNING BOOLEAN) AS show_total,
           JSON_QUERY(app_data, '$.features') AS app_features
    FROM thomas_app_data;
    </copy>
    ```

    `SESSION_ID` remains a relational key. `APP_DATA` can change as the application changes. Thomas can query both with SQL in one table.

## Task 2: Create a JSON Collection Table

Thomas now needs a collection of application documents. Unlike the JSON column in Task 1, this object is a JSON Collection Table: each row is a document, the document is stored in `DATA`, and `_id` identifies the document.

1. Create the collection and add the sample viewing session document.

    ```sql
    <copy>
    CREATE JSON COLLECTION TABLE thomas_viewing_session_docs
    WITH ETAG;

    INSERT INTO thomas_viewing_session_docs (data)
    SELECT JSON_OBJECT(
               '_id'        VALUE o.session_id,
               'viewerId' VALUE o.viewer_id,
               'status'     VALUE o.session_status,
               'items'      VALUE (
                   SELECT JSON_ARRAYAGG(
                              JSON_OBJECT(
                                  'eventId'    VALUE oi.event_id,
                                  'titleId' VALUE oi.title_id,
                                  'watch_minutes'  VALUE oi.watch_minutes,
                                  'unitPrice' VALUE oi.revenue_per_view
                                  RETURNING JSON
                              ) ORDER BY oi.event_id RETURNING JSON
                          )
                   FROM viewing_events oi
                   WHERE oi.session_id = o.session_id
               ) FORMAT JSON
               RETURNING JSON
           )
    FROM viewing_sessions o
    JOIN thomas_app_data t ON t.session_id = o.session_id;

    COMMIT;
    </copy>
    ```

    `WITH ETAG` adds an `_metadata.etag` value to each document. Oracle changes the tag whenever the document changes. Thomas's application can send the tag it last read when it updates a document. If the tag no longer matches, the application knows that someone else changed the document first and can avoid overwriting the newer version. This protects viewer data when web and mobile requests try updating the same document at the same time.

2. Query the collection as documents.

    ```sql
    <copy>
    SELECT JSON_SERIALIZE(data PRETTY) AS viewing_session_document
    FROM thomas_viewing_session_docs
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) =
          (SELECT session_id FROM thomas_app_data);
    </copy>
    ```

    Thomas now has a document collection that a document API can access, and SQL can query the same `DATA` column. The collection stores the documents; it is separate from the relational `VIEWING_SESSIONS` and `VIEWING_EVENTS` tables.

## Task 3: Read a viewer document from relational data

Thomas now tests the document shape his application can consume directly.

1. Run this query:



    This query selects the JSON `DATA` column from `VIEWING_SESSIONS_DV` so Thomas can inspect the document shape in SQL Worksheet.

    <details>
    <summary><strong>Why this matters to Thomas</strong></summary>

    > Thomas can use a JSON Collection Table when the application owns the document. But the viewing session already has relational tables that Jessica and other teams rely on.
    > The duality view gives Thomas a document over those existing rows. He can choose the application shape without copying the viewing session into another store.

    </details>

    ```sql
    <copy>
    SELECT data AS viewing_session_document
    FROM viewing_sessions_dv
    FETCH FIRST 1 ROW ONLY;
    </copy>
    ```

    **Expected output:**

    ![SQL Worksheet showing the viewing session document returned by the duality view](images/jsondv-result.jpg " ")

2. Expand the document in SQL Worksheet.
    The query reads the duality view as a document source. Oracle constructs the JSON shape from relational data, so the application gets a viewing session payload without a second copy of the viewing session record.

    The \_id value appears in the JSON document while the source data remains relational. The payload includes `viewerId`, `status`, totals, timestamps, and line items. The application gets these fields without a second viewing session store.

    The same viewing session now has two useful forms: API-ready JSON for the application and relational rows for analysis.

    > **Note:** Look for `_metadata.etag` in the document. The ETAG changes when the document changes, so Thomas's application can detect a newer version before updating the viewing session and avoid overwriting another request.

## Task 4: Enable document inserts and updates

The existing `VIEWING_SESSIONS_DV` lets an application update an existing viewing session document. In this task, you extend that contract so the application can also create one. The database continues to control the relational tables, keys, and constraints. The duality view can also act as a security boundary. Thomas's application receives only the document fields and write operations exposed by the view, without direct access to the underlying tables.

1. Check the current document-write capabilities.

    ```sql
    <copy>
    SELECT view_name,
           allow_insert,
           allow_update,
           allow_delete
    FROM user_json_duality_views
    WHERE view_name = 'VIEWING_SESSIONS_DV';
    </copy>
    ```

    **Expected output: Current Document Capabilities**

    ![json contract](images/jsondv-contract.jpg)

    The view currently allows updates but not new top-level documents. The root `VIEWING_SESSIONS` table controls document insertion. The nested `VIEWING_EVENTS` rows must also allow inserts so the document can include line items.

2. Enable insert and update for the document and its line items.

    You are changing the duality-view definition, not creating a second API store. The two `WITH INSERT UPDATE` clauses allow developers to create and update the JSON document. Oracle still enforces the relational keys and data types.

    ```sql
    <copy>
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW viewing_sessions_dv AS
    SELECT JSON {
        '_id'         : o.session_id,
        'viewerId'  : o.viewer_id,
        'hubId'       : o.hub_id,
        'sessionStartedOn' : o.session_started_on,
        'sessionEndedOn'   : o.session_ended_on,
        'status'      : o.session_status,
        'sessionRevenue' : o.session_revenue,
        'advertisingRevenue': o.advertising_revenue,
        'demandScore' : o.demand_score,
        'createdAt'   : o.created_at,
        'items' : [
            SELECT JSON {
                'eventId'    : oi.event_id,
                'titleId' : oi.title_id,
                'watchMinutes'  : oi.watch_minutes,
                'revenuePerView' : oi.revenue_per_view
            }
            FROM viewing_events oi WITH INSERT UPDATE
            WHERE oi.session_id = o.session_id
        ]
    }
    FROM viewing_sessions o WITH INSERT UPDATE;
    </copy>
    ```

    This duality view uses two relational tables. `VIEWING_SESSIONS` provides the document root. Related `VIEWING_EVENTS` rows become the nested `items` collection. The `WITH INSERT UPDATE` clauses let Thomas write the complete JSON document while Oracle maintains the rows and relationships.

    **Expected output: View Definition Updated**

    Oracle created or replaced the duality view. Verify the new capabilities in the next step.

2. Run the capability query again.

    ```sql
    <copy>
    SELECT view_name,
           allow_insert,
           allow_update,
           allow_delete
    FROM user_json_duality_views
    WHERE view_name = 'VIEWING_SESSIONS_DV';
    </copy>
    ```

    **Expected output: Document Capabilities Enabled**

    ![insert json](images/jsondv-insert.jpg)

    The view can now receive a new JSON viewing session document and apply a document update. Thomas has a document API over the existing relational viewing session data. He can use it for a viewer feature such as submitting a new viewing session. The application sends one document, and the database writes the viewing session and its line items to the relational tables.

## Task 5: Create and update a JSON viewing session

Thomas now tests a complete viewer viewing session. He creates it as one nested JSON document, then confirms that Jessica can immediately see the same data as structured relational rows.

1. Insert the supplied workshop viewing session document.

    The `INSERT` targets `VIEWING_SESSIONS_DV`, the JSON Relational Duality View, rather than the underlying `VIEWING_SESSIONS` or `VIEWING_EVENTS` tables. The database uses the view definition to write the document to those relational tables. The document uses viewing session ID `900001`, viewer `1`, and title `1`. It includes one nested line item. The statement is safe to run again: after the viewing session exists, it inserts zero rows and preserves the existing record. The workshop schema requires date-only session boundaries and an end date after the start date, so this example creates a confirmed two-day session.

    ```sql
    <copy>
    INSERT INTO viewing_sessions_dv (data)
    SELECT JSON(
      '{
        "_id": 900001,
        "viewerId": 1,
        "hubId": 1,
        "sessionStartedOn": "2026-09-26",
        "sessionEndedOn": "2026-09-27",
        "status": "confirmed",
        "sessionRevenue": 25.00,
        "advertisingRevenue": 0,
        "createdAt": "2026-09-26",
        "items": [
          {
            "eventId": 990001,
            "titleId": 1,
            "watchMinutes": 2,
            "revenuePerView": 12.50
          }
        ]
      }'
    )
    WHERE NOT EXISTS (
      SELECT 1
      FROM viewing_sessions
      WHERE session_id = 900001
    );

    COMMIT;
    </copy>
    ```

    **Expected output: Viewing Session Document Created**

    On the first run, you insert one document. On later runs, the `NOT EXISTS` check returns zero rows because the workshop viewing session is already present.

2. Confirm the JSON document became relational rows.

    >**Note**: We are querying here the relational tables `VIEWING_SESSIONS` and `VIEWING_EVENTS`!

    ```sql
    <copy>
    SELECT o.session_id AS viewing_session_id,
           o.session_status AS viewing_session_status,
           c.email AS viewer_email,
           oi.event_id,
           p.title_name,
           oi.watch_minutes,
           oi.revenue_per_view,
           oi.line_total
    FROM viewing_sessions o
    JOIN viewers c ON c.viewer_id = o.viewer_id
    JOIN viewing_events oi ON oi.session_id = o.session_id
    JOIN titles p ON p.title_id = oi.title_id
    WHERE o.session_id = 900001;
    </copy>
    ```

    **Expected output: Created Viewing Session Rows**

    ![json success](images/json-success.jpg)

3. Update the document status through the duality view.

    This update changes JSON data through `VIEWING_SESSIONS_DV`. The allowed modification here is the document's `status` field, which Oracle maps to `VIEWING_SESSIONS.SESSION_STATUS`; Thomas's application is not given unrestricted updates to the underlying tables. He does not need application-side parsing or a second viewing session store.

    ```sql
    <copy>
    UPDATE viewing_sessions_dv
    SET data = JSON_TRANSFORM(data, SET '$.status' = 'confirmed')
    WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 900001;

    COMMIT;
    </copy>
    ```

    **Expected output: Viewing Session Status Updated**

    Oracle updates one document. The following query confirms that the relational viewing-session row now has status `confirmed`.

4. Verify the updated relational status.

    ```sql
    <copy>
    SELECT o.session_id AS viewing_session_id,
           o.session_status AS viewing_session_status,
           oi.event_id,
           p.title_name,
           oi.watch_minutes,
           oi.line_total
    FROM viewing_sessions o
    JOIN viewing_events oi ON oi.session_id = o.session_id
    JOIN titles p ON p.title_id = oi.title_id
    WHERE o.session_id = 900001;
    </copy>
    ```

    **Expected output: Updated Viewing Session Rows**

    ![json update](images/json-update-confirm.jpg)

## Task 6: Project JSON fields with SQL

Thomas has confirmed that the application can display and update the document. Jessica now checks the same viewing session with SQL before the feature goes live. She uses the relational tables for normal reporting and analysis. Here, she queries `VIEWING_SESSIONS_DV` to verify the exact JSON contract that Thomas's application receives. She can also project fields from the document to test viewer-service searches and status filters. In this context, "project" means pulling selected values out of the JSON document and displaying them as SQL result columns.

1. Run this SQL/JSON projection query:

    Thomas's document is still available for SQL analysis. The same viewing session shape can be queried, filtered, and joined to relational viewer data.

    The SQL uses `JSON_VALUE` to extract viewing session fields from the duality document. That is the projection step. It returns the viewing session ID and status, reads the embedded viewer identifier, joins that identifier to `VIEWERS`, and viewing_sessions the result for review.

    Thomas does not need to hand-build this document in the application or copy the viewing session to a separate document store. The application gets JSON, while Jessica still has SQL access to the same viewing session rows.

    ```sql
    <copy>
    SELECT JSON_VALUE(od.data, '$._id' RETURNING NUMBER) AS viewing_session_id,
           JSON_VALUE(od.data, '$.status') AS viewing session_status,
           c.email AS viewer_email
    FROM viewing_sessions_dv od
    JOIN viewers c
      ON c.viewer_id = JSON_VALUE(od.data, '$.viewerId' RETURNING NUMBER)
    WHERE JSON_VALUE(od.data, '$._id' RETURNING NUMBER) = 900001;
    </copy>
    ```

    **Expected output: JSON Field Projection**

    ![project json](images/json-project.jpg)

2. Run the equivalent query against the relational tables.

    ```sql
    <copy>
    SELECT o.session_id AS viewing_session_id,
           o.session_status AS viewing_session_status,
           c.email AS viewer_email
    FROM viewing_sessions o
    JOIN viewers c
      ON c.viewer_id = o.viewer_id
    WHERE o.session_id = 900001;
    </copy>
    ```

    ![project relational](images/json-relational.jpg)

    Compare the result with the previous query. The viewing session ID, status, and client email should match. Thomas's application is reading the JSON document, while Jessica's relational query reads the underlying rows.

## Conclusion: Choose the right JSON approach

Thomas does not have to choose one JSON model for the whole application. He can choose based on who owns the data and whether the application needs a document over existing relational rows.

| Approach                          | Use it when                                                                                 | Example in Thomas's application                                                                            | Where the data lives                                                                                           |
| -----------------------------------| ---------------------------------------------------------------------------------------------| ------------------------------------------------------------------------------------------------------------| ----------------------------------------------------------------------------------------------------------------|
| JSON column in a relational table | A relational record needs optional or changing attributes.                                  | Store screen settings or viewer experience options alongside a viewing session key.                          | A normal relational table with a native `JSON` column.                                                         |
| JSON Collection Table             | The application owns a set of JSON documents and needs document-style access.               | Store saved checkout drafts that may change as viewers add or remove items.                              | A JSON Collection Table with one document in each `DATA` row.                                                  |
| JSON Relational Duality View      | The data already belongs in relational tables, but the application needs one JSON document. | Return a viewer viewing session with its status and line items, or accept a new viewing-session document from the app. | Relational tables such as `VIEWING_SESSIONS` and `VIEWING_EVENTS`; the duality view defines the JSON shape for Thomas' app. |

For Thomas, `VIEWING_SESSIONS_DV` is the right choice for the viewing session feature because `VIEWING_SESSIONS` and `VIEWING_EVENTS` already hold governed media data. The application gets the JSON payload it needs, while Jessica keeps SQL, relational constraints, and controlled access to the same data.


## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano
* **Last Updated By/Date** - Oracle Database Product Management, August 2026
