# Serve the Casino App with JSON Relational Duality Views

## Introduction

In **Lab 1**, you built the Silverleaf Casino's database and loaded the night in one go. That load stood in for the records that came in all night from the tablets at the gaming tables and from the surveillance cameras. This lab connects two of the casino's apps to those tables, and they use the data in different ways. Players check their own night on the casino's website, and can change only their name and favorite game. Staff log every session on a tablet, so the tablets write. Vera can only trust the data if every record follows the same rules, however it arrives, so this lab also shows that the tablets' JSON gets the same checks as SQL. That finishes the build before the investigation starts in **Lab 3**.

Imagine the casino has a website. Players use it to check their loyalty tier, their floor host and their night at the tables. 

When a casino goer, Pablo Reyes, signs into the web app (pictured below), the website needs his profile as one document: his tier, his host's name, and every session with its table and dealer. Those facts live in five tables. Without help from the database, the website's own code would read the five tables and build the document. Or the casino would keep the documents in a separate document database, a second copy of the night that has to be kept in step with the tables.

Oracle AI Database 26ai does that work for you, with a **JSON Relational Duality View**. The view reads Pablo's rows from the five tables and hands the website one **JSON** document, the format most modern web apps send and receive data in. The document isn't stored anywhere, so there's nothing to keep in sync: the database builds it fresh from the tables you built in **Lab 1** each time it's read. The view is also updatable. When an app saves a document, the database writes the changes back to the tables, and every rule on them still applies. You decide what each app may do: only read, or also add, change and remove documents.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Create a duality view of player documents that leaves out the sensitive columns, and lets players change only their name and favorite game
* Read a player's night as a JSON document and as rows
* Update a document, and watch a **Lab 1** domain reject a bad value
* Create a duality view that lets the tablets at the gaming tables insert session records, but not change them
* Insert a JSON document and find it in the relational tables
* Check what each view allows, and watch it block the changes it doesn't allow
* Watch the **Lab 1** assertion reject a bad JSON write

### Prerequisites

This lab assumes you have:

* Completed **Get Started with LiveLabs** and opened the SQL worksheet as ADMIN
* Completed **Lab 1**

## Task 1: Serve player documents to the website

1. The website shows each player a profile with their tier, floor host and sessions, and it builds the whole page from one JSON document. Here is Pablo Reyes's page. Each color shows a different database table that part of the website comes from. As you read the view below, match each color to its table.

    ![The Players Club page for Pablo Reyes, outlined by source table: his name and member card from players, his floor host from casino_staff, and his sessions from play_sessions, with the Table column from gaming_tables and the Dealer column from dealers.](images/duality-views-player-map.png " ")

    This duality view builds that document from five tables. Also notice this duality view uses GraphQL syntax. GraphQL is a language for describing the shape of nested data, and Oracle supports a version of it for duality views. Clear the editor, paste the block, and click **Run Script** (F5).

    ```sql
    <copy>
    -- Player documents for the website: no sensitive columns, and players can change only their name and favorite game
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW player_dv AS
    players
    {
      _id          : player_id,
      name         : full_name @update,
      tier         : loyalty_tier,
      favoriteGame : favorite_game @update,
      casino_staff @unnest
      {
        host     : username,
        hostName : full_name
      },
      sessions : play_sessions
      [
        {
          sessionId : session_id,
          gaming_tables @unnest
          {
            tableId : table_id,
            table   : table_name,
            game    : game
          },
          dealers @unnest
          {
            dealerId : dealer_id,
            dealer   : full_name
          },
          startedAt : started_at,
          endedAt   : ended_at,
          buyIn     : buy_in,
          cashOut   : cash_out
        }
      ]
    };
    </copy>
    ```

    How the document is built:

    * `players` is the root, and `_id` holds the player ID. Every document in a duality view has an `_id` field, which identifies that document.
    * `casino_staff` adds the player's host from **Lab 1**. `@unnest` puts the host's fields, `host` and `hostName`, directly in Pablo's document next to his name and tier, instead of in a separate object. The website reads Nina's name the same way it reads Pablo's.
    * `sessions` is an array of the player's rows in `play_sessions`. Inside each session, `@unnest` brings the table and dealer fields up beside the session's own fields.
    * The four sensitive columns from **Lab 1** aren't listed, so they aren't in the document. The website can't read or write a column the view leaves out.
    * `@update` appears on two fields: `name` and `favoriteGame`. Those are the only things the website can change. The view has no `@insert` or `@delete`, so the website can't add or remove a player, and the tier, the host and every session stay read-only. Putting `@update` on single fields is the safe way to do this. Putting it on the whole table, as in `players @update`, would also let a player switch their floor host.
    * Without a duality view, the website's own code would decide which fields a player may change, and every other app would have to repeat that check. A regular view that builds JSON with SQL functions can show a profile, but it can't take a player's changes back.

2. Now fetch one document, the way the website does when a player signs in. Pablo Reyes is checking his profile. Look at what the document holds, and at what it leaves out. Clear the editor, paste the query, and click **Run Script**.

    ```sql
    <copy>
    -- Fetch the player document for Pablo Reyes
    SELECT JSON_SERIALIZE(data PRETTY) AS player_document
    FROM player_dv
    WHERE JSON_VALUE(data, '$.name') = 'Pablo Reyes';
    </copy>
    ```

    You should see one document. Pablo is `_id` 16, tier `STANDARD`, and his floor host is `nina`, with `hostName` `Nina Alvarez`. `favoriteGame` is null, because he hasn't picked one yet. He played five sessions, all at blackjack, and lost every one. Each session names its table, game and dealer, although `play_sessions` stores only their IDs.

    ![Script Output shows the player document for Pablo Reyes, with five blackjack sessions and no sensitive fields.](images/duality-views-01.png " ")

3. Because a duality view stores nothing and builds each JSON document from the relational tables, you can also query the same information in SQL directly from the tables. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Read Pablo Reyes's night as rows: one row per session, joined across five tables
    SELECT p.full_name    AS player,
           p.loyalty_tier AS tier,
           h.full_name    AS host_name,
           g.table_name,
           d.full_name    AS dealer,
           TO_CHAR(s.started_at, 'HH24:MI') AS started,
           TO_CHAR(s.ended_at, 'HH24:MI')   AS ended,
           s.buy_in,
           s.cash_out
    FROM players p
    JOIN casino_staff h  ON h.username  = p.host_username
    JOIN play_sessions s ON s.player_id = p.player_id
    JOIN gaming_tables g ON g.table_id  = s.table_id
    JOIN dealers d       ON d.dealer_id = s.dealer_id
    WHERE p.full_name = 'Pablo Reyes'
    ORDER BY s.started_at;
    </copy>
    ```

    You should see five rows, the same five blackjack sessions as in his document, from 20:07 to 03:39. Pablo's name, tier and host repeat on every row, because a query result is a flat grid: one row per session, with every column filled in. To show his profile from these rows, the website's own code would have to fold them into one document, with his details once and his sessions in a list. To save a document, as the tablets do in Task 2, the code would have to split it back into rows for each table. The duality view does both inside the database.

    Both results came from the same rows, and nothing was copied. The document and the rows are two ways to read one copy of the data, so SQL reports and the website always see the same night.

4. Duality views enable applications to insert and update data using JSON operations. Pablo opens his profile settings and picks craps as his favorite game. The website saves the change by updating his document. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Pablo sets his favorite game on the website
    UPDATE player_dv
    SET data = JSON_TRANSFORM(data, SET '$.favoriteGame' = 'Craps')
    WHERE JSON_VALUE(data, '$._id') = 16;
    COMMIT;
    </copy>
    ```

    Script Output shows one row updated, then the commit. The website sent a change to a JSON document, and the database turned it into an ordinary update of one column, `favorite_game`, in one row of `players`. The website never had to know which table or column holds a player's favorite game. It only ever worked with the document.

5. Look for the change in the `players` table. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Find Pablo's favorite game in the players table
    SELECT full_name, favorite_game
    FROM players
    WHERE player_id = 16;
    </copy>
    ```

    This is the heart of a duality view: it's a JSON view you can write through, not just read. The website saved a JSON document, and the change landed in the relational table, where every SQL report and every other app already sees it. There's only one copy of Pablo's data, so nothing has to be kept in sync.


6. Now Pablo tries to pick poker, a game the Silverleaf doesn't run. This statement should fail. Clear the editor, paste the statement, and click **Run Script**.

    ```sql
    <copy>
    -- Pablo tries to pick a game the casino doesn't run
    UPDATE player_dv
    SET data = JSON_TRANSFORM(data, SET '$.favoriteGame' = 'Poker')
    WHERE JSON_VALUE(data, '$._id') = 16;
    </copy>
    ```

    **Expected Result:** The update fails. Script Output shows `ORA-42692: Cannot update JSON Relational Duality View 'ADMIN'.'PLAYER_DV'`, and inside it `ORA-11534`, which names the `GAME_TYPE` domain. The website only sent JSON, but the rule from **Lab 1** still checked it. Pablo's favorite game is still craps.

## Task 2: Record a session as JSON

1. Another source of data is the staff and their devices at the gaming tables. They log a number of things, players give them their status cards to earn rewards which allows the casinos to track the player, table, dealer, times and chips. The tablet app sends each session record as a JSON document, so it needs a duality view it can write through. You name this view `rating_slip_dv`, because casinos call one session's record a rating slip. This time you write the view in SQL instead of GraphQL. Both create the same kind of view. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Session records for the tablets at the gaming tables: insert only
    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW rating_slip_dv AS
    SELECT JSON {'_id'       : s.session_id,
                 UNNEST (SELECT JSON {'playerId' : p.player_id,
                                      'player'   : p.full_name}
                         FROM players p
                         WHERE p.player_id = s.player_id),
                 UNNEST (SELECT JSON {'tableId' : g.table_id,
                                      'table'   : g.table_name}
                         FROM gaming_tables g
                         WHERE g.table_id = s.table_id),
                 UNNEST (SELECT JSON {'dealerId' : d.dealer_id,
                                      'dealer'   : d.full_name}
                         FROM dealers d
                         WHERE d.dealer_id = s.dealer_id),
                 'startedAt' : s.started_at,
                 'endedAt'   : s.ended_at,
                 'buyIn'     : s.buy_in,
                 'cashOut'   : s.cash_out}
    FROM play_sessions s WITH INSERT;
    </copy>
    ```

    What this view allows:

    * `WITH INSERT` on `play_sessions` lets the tablets add session records. There's no `UPDATE` or `DELETE`, so nobody can change or remove a session record through this view.
    * `players`, `gaming_tables` and `dealers` have no `WITH` clause, so they're read-only here. A session record can name an existing player, table and dealer, but can't create or change one.
    * Each `UNNEST` puts the player, table or dealer fields at the top level of the document.

2. Now insert a session the way a tablet does, as one JSON document. This one is Pablo Reyes at Craps 1 with dealer Aisha Bello, from 23:15 to 23:45. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- The Craps 1 tablet logs Pablo Reyes with Aisha Bello
    INSERT INTO rating_slip_dv VALUES ('{
      "_id"       : 217,
      "playerId"  : 16,
      "player"    : "Pablo Reyes",
      "tableId"   : 8,
      "table"     : "Craps 1",
      "dealerId"  : 8,
      "dealer"    : "Aisha Bello",
      "startedAt" : "2026-10-25T23:15:00",
      "endedAt"   : "2026-10-25T23:45:00",
      "buyIn"     : 200,
      "cashOut"   : 150
    }');
    COMMIT;
    </copy>
    ```

    The insert succeeds. The tablet sent one JSON document, and the database wrote it as one new row in `play_sessions`. The IDs come from the tablet's menus. Pablo is player 16, and Craps 1 and Aisha Bello are both number 8.


3. The tablet sent a JSON document, but the data now lives in the relational tables, so you can read it from either side. First, read the new session the relational way, as a row in `play_sessions`. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Read Pablo's craps session as a row in the play_sessions table
    SELECT session_id, player_id, table_id, dealer_id,
           TO_CHAR(started_at, 'HH24:MI') AS started,
           TO_CHAR(ended_at, 'HH24:MI')   AS ended,
           buy_in, cash_out
    FROM play_sessions
    WHERE session_id = 217;
    </copy>
    ```

    You should see one ordinary row, with the times and chips the tablet sent, and the player, table and dealer stored as IDs.

4. Now read the same session through the duality view, as a JSON document. Clear the editor, paste the query, and click **Run Script**.

    ```sql
    <copy>
    -- Read the same session as a JSON document through the tablets' view
    SELECT JSON_SERIALIZE(data PRETTY) AS session_document
    FROM rating_slip_dv
    WHERE JSON_VALUE(data, '$._id') = 217;
    </copy>
    ```

    ![Script Output shows Pablo Reyes's craps session as a JSON document from rating_slip_dv.](images/duality-views-02.png " ")

## Task 3: Check what each app is allowed to change

1. Each duality view decides what its app may do, and the database checks every write against the view. The website may change a player's name and favorite game, and nothing else. The tablets may add session records, and nothing else. These permissions are part of each view's definition, so the data dictionary records them like any other part of the schema.  Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- What each app may do through its view, table by table
    SELECT view_name, table_name, allow_insert, allow_update, allow_delete
    FROM user_json_duality_view_tabs
    ORDER BY view_name, root_table DESC, table_name;
    </copy>
    ```

    You should see nine rows, one for each table that each view reads. `PLAYER_DV` allows updates on `PLAYERS` only, and `RATING_SLIP_DV` allows inserts on `PLAY_SESSIONS` only. Every other value is false, so neither app can delete anything.

2. `PLAYERS` allows updates because two of its fields do. List the website's player fields one by one. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- The fields the website may change in a player document
    SELECT json_key_name AS field, column_name, allow_update
    FROM user_json_duality_view_tab_cols
    WHERE view_name = 'PLAYER_DV' AND table_name = 'PLAYERS'
    ORDER BY json_key_name;
    </copy>
    ```

    You should see five rows. `name` and `favoriteGame` can be updated, and `_id` and `tier` can't. The row with no field name is `HOST_USERNAME`, the link from a player to their floor host. It doesn't appear in the document, and it's locked too, so a player can't switch hosts.

3. Now test the rules. Pablo tries to make himself a VIP through the website. This statement should fail. Clear the editor, paste the statement, and click **Run Script**.

    ```sql
    <copy>
    -- Pablo tries to change his own loyalty tier
    UPDATE player_dv
    SET data = JSON_TRANSFORM(data, SET '$.tier' = 'VIP')
    WHERE JSON_VALUE(data, '$._id') = 16;
    </copy>
    ```

    **Expected Result:** The update fails with `ORA-40940: Cannot update field 'tier' corresponding to column 'LOYALTY_TIER' of table 'PLAYERS' in JSON Relational Duality View 'PLAYER_DV': Missing UPDATE annotation or NOUPDATE annotation specified.` The `tier` field has no `@update`, so the database refuses the change.

    > **Note:** In a duality view, `@insert`, `@update` and `@delete` are also called annotations, which is the word the error uses. They're different from the schema annotations in **Lab 1**: these set what a view allows.

4. The sessions inside Pablo's document are read-only too. Try to change the cash-out of his first session through his player document. This statement should fail. Clear the editor, paste the statement, and click **Run Script**.

    ```sql
    <copy>
    -- Try to change a session's cash-out through the player document
    UPDATE player_dv
    SET data = JSON_TRANSFORM(data, SET '$.sessions[0].cashOut' = 5000)
    WHERE JSON_VALUE(data, '$._id') = 16;
    </copy>
    ```

    **Expected Result:** The update fails with `ORA-40939: Cannot update table 'PLAY_SESSIONS' in JSON Relational Duality View 'PLAYER_DV': Missing UPDATE annotation or NOUPDATE annotation specified.` The website can show a session, but it can never change one.

5. The tablets' view allows inserts only, so the tablets can't remove a record. Try to delete Pablo's craps session through `rating_slip_dv`. This statement should fail. Clear the editor, paste the statement, and click **Run Script**.

    ```sql
    <copy>
    -- Try to delete session 217 through the insert-only view
    DELETE FROM rating_slip_dv
    WHERE JSON_VALUE(data, '$._id') = 217;
    </copy>
    ```

    **Expected Result:** The delete fails with `ORA-40938: Cannot delete from table 'PLAY_SESSIONS' in JSON Relational Duality View 'RATING_SLIP_DV': Missing DELETE annotation or NODELETE annotation specified.` Pablo's craps session is still there.

    Each app got exactly the permissions its view states, and nothing more. Without them, each app's own code would decide what it may change, and a bug or a new app could skip that check. The permissions live in the database, so they hold for every app that writes through these views, including apps the casino builds later.

## Task 4: Catch a bad session record written as JSON

1. At 23:25, the tablet at Baccarat 1 logs a session record for Gemma Doyle. Its dealer list is out of date and still shows the first shift, so the record names Kenji Mori. Kenji moved to Baccarat 2 at 22:00 and is dealing there now. This statement should fail. Clear the editor, paste the statement, and click **Run Script**.

    ```sql
    <copy>
    -- The Baccarat 1 tablet logs Gemma Doyle with last shift's dealer
    INSERT INTO rating_slip_dv VALUES ('{
      "_id"       : 218,
      "playerId"  : 7,
      "player"    : "Gemma Doyle",
      "tableId"   : 5,
      "table"     : "Baccarat 1",
      "dealerId"  : 5,
      "dealer"    : "Kenji Mori",
      "startedAt" : "2026-10-25T23:25:00",
      "endedAt"   : "2026-10-25T23:55:00",
      "buyIn"     : 1000,
      "cashOut"   : 600
    }');
    </copy>
    ```

    **Expected Result:** The insert fails. Script Output shows `ORA-42692: Cannot insert into JSON Relational Duality View 'ADMIN'.'RATING_SLIP_DV'`, and inside it the cause: `ORA-08601: Assertion (ADMIN.DEALER_ONE_TABLE_AT_A_TIME) violated.`

    Kenji has sessions at Baccarat 2 until 23:57, so this session would put him at two tables at once.

    The tablet never wrote SQL against `play_sessions`, and it doesn't know the rule exists. The duality view turned the document into a row, and the **Lab 1** assertion checked it. The rule lives in the database, so JSON apps can't get around it either. Had the tablets saved their records to a separate document database, Gemma's record would have gone in, because the assertion only checks the casino's tables.

    ![Script Output shows error ORA-08601 for the JSON session record that names Kenji Mori at Baccarat 1.](images/duality-views-03.png " ")

## Conclusion

The Silverleaf Casino's website and tablets now run on the tables you built in **Lab 1**. Pablo's profile came back as one JSON document built from five tables. His craps session went in as a JSON document and landed as one row. Neither app needed code to turn tables into documents or back, and there's no second copy of the night to keep in step.

Because the data is stored once, every app sees the same night. Each view also decides what its app may do. The website can change only a player's name and favorite game, and never sees the sensitive columns. The tablets can only add session records. The data dictionary lists those permissions, and every write that went past them failed. And every document carries an `etag`, so two people can't quietly overwrite each other's changes.

The rules held, too. Pablo's pick of poker broke the **Lab 1** `game_type` domain, and Gemma Doyle's record broke the **Lab 1** assertion. The database rejected both, even though the website and the tablet only ever sent JSON. That finishes the build: every way into the casino's data follows the same rules. In **Lab 3**, Vera starts investigating.

You may now **proceed to the next lab**.

## Learn More

* [CREATE JSON RELATIONAL DUALITY VIEW](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/create-json-relational-duality-view.html)
* [Creating Car-Racing Duality Views Using GraphQL](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/creating-car-racing-duality-views-using-graphql.html)
* [Annotations (NO)UPDATE, (NO)INSERT, (NO)DELETE, To Allow/Disallow Updating Operations](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/annotations-no-update-no-insert-no-delete-allow-disallow-updating-operations.html)
* [Inserting Documents/Data Into Duality Views](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/inserting-documents-data-duality-views.html)

## Acknowledgements
* **Author** - Killian Lynch, Oracle Database Product Management
* **Last Updated By/Date** - Killian Lynch, October 2026
