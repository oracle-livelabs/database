# (Bonus) New SQL Features

## Introduction

It's Monday morning at the Silverleaf Casino. Vera Lindqvist's case file is safe, and she's writing her report for the casino's managers. First, she has a few follow-up questions about the night of play.

Oracle AI Database 26ai adds new SQL in its release updates. In this bonus lab, you answer Vera's questions with five additions from release updates 23.26.0 to 23.26.3. Each one makes a familiar query shorter or safer. Every query only reads data, so the numbers from earlier labs stay the same. You work as ADMIN, so the **Lab 5** data grants don't filter anything here.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Join tables through their foreign keys with `JOIN TO ONE`, and watch it stop a join that double counts
* Split one total into two with aggregation filters
* Find each floor host's top player with `QUALIFY`
* Measure and shift times with `DATEDIFF` and `DATEADD`

### Prerequisites

This lab assumes you have:

* Completed **Get Started with LiveLabs** and opened the SQL worksheet as ADMIN
* Completed **Lab 1**, **Lab 2** and **Lab 3**

## Task 1: Write safer joins with JOIN TO ONE

1. Vera starts with Victor Lang's night, one row per session. `play_sessions` stores only IDs, so the names come from three other tables. `JOIN TO ONE`, new in release update 23.26.2, joins them without a single `ON` clause. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Victor Lang's night, one row per session, with no join conditions
    SELECT TO_CHAR(s.started_at, 'HH24:MI') AS started,
           g.table_name,
           d.full_name AS dealer,
           s.buy_in,
           s.cash_out
    FROM play_sessions s
    JOIN TO ONE (players p, gaming_tables g, dealers d)
    WHERE p.full_name = 'Victor Lang'
    ORDER BY s.started_at;
    </copy>
    ```

    You should see five rows. Victor won three sessions at Elliot Shaw's tables, starting at 20:06. After 23:00, he lost twice at Roulette 1 with Tom Brennan. Across the five sessions, he's up $1,600.

    How the join works:

    * `play_sessions` comes first, so each result row is one session. Each table in the parentheses adds columns to that row.
    * **Lab 1** declared a foreign key from `play_sessions` to each of the three tables. `JOIN TO ONE` follows those keys, so you don't write `ON` clauses.
    * Before, you wrote out every join, such as `JOIN dealers d ON d.dealer_id = s.dealer_id`, once per table.

    ![Query Result lists Victor Lang's five sessions with table and dealer names, three of them at Elliot Shaw's tables.](images/sql-features-01.png " ")

2. `JOIN TO ONE` also makes a promise: each table in the parentheses adds at most one row to each session. Now break that promise. Vera asks for the chips Victor sent next to each session, and he sent chips twice. This statement should fail. Clear the editor, paste the query, and click **Run Statement**. Use **Run Statement** here: this error happens while rows are fetched, and **Run Script** doesn't show it.

    ```sql
    <copy>
    -- Add the chips Victor sent to each of his sessions
    SELECT TO_CHAR(s.started_at, 'HH24:MI') AS started,
           g.table_name,
           t.amount AS chips_sent
    FROM play_sessions s
    JOIN TO ONE (players p,
                 gaming_tables g,
                 chip_transfers t ON t.from_player_id = s.player_id)
    WHERE p.full_name = 'Victor Lang';
    </copy>
    ```

    **Expected Result:** The query fails with `ORA-18640: JOIN TO ONE reached multiple rows joining to "T", resulting in a non-unique join`. `T` is the alias for `chip_transfers`.

    No foreign key leads from a session to a transfer, so this join needs an `ON` clause. Each of Victor's sessions matches both of his transfers. A plain `JOIN` would return 10 rows, every session twice, with no warning. Add up his net win from those rows, and $1,600 becomes $3,200. `JOIN TO ONE` stops the query instead of returning numbers that only look right.

    ![Query Result shows error ORA-18640, saying JOIN TO ONE reached multiple rows joining to T.](images/sql-features-02.png " ")

## Task 2: Split totals with FILTER and pick winners with QUALIFY

1. In **Lab 1**, Elliot Shaw earned the house $17,375, more than any other dealer. Vera wants that number split in two: the ring's sessions and everyone else's. An aggregation filter, new in release update 23.26.1, gives one aggregate its own `WHERE` clause. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Split each dealer's house result: the ring versus everyone else
    SELECT d.full_name AS dealer,
           COUNT(*) AS sessions,
           COUNT(*) FILTER (WHERE s.cash_out > s.buy_in)                     AS player_wins,
           SUM(s.buy_in - s.cash_out) FILTER (WHERE cp.player_id IS NULL)     AS house_vs_others,
           SUM(s.buy_in - s.cash_out) FILTER (WHERE cp.player_id IS NOT NULL) AS house_vs_ring
    FROM play_sessions s
    JOIN TO ONE (dealers d,
                 case_players cp ON cp.case_id = 1 AND cp.player_id = s.player_id)
    GROUP BY d.full_name
    ORDER BY house_vs_ring NULLS LAST, dealer;
    </copy>
    ```

    You should see eight dealers, with Elliot Shaw first. The house won $21,750 from his other players and lost $4,375 to the ring. Together, those made the $17,375 that hid the ring in **Lab 1**.

    How the filters work:

    * `COUNT(*) FILTER (WHERE s.cash_out > s.buy_in)` counts only winning sessions. **Lab 3** counted wins with `SUM(CASE WHEN cash_out > buy_in THEN 1 ELSE 0 END)`.
    * `JOIN TO ONE` uses outer joins by default, so every session stays. Only the ring's sessions match `case_players`, so `cp.player_id` is NULL for everyone else.
    * Each `SUM` adds up only the rows its filter keeps. The ring never sat with Aisha Bello, Kenji Mori, Lucia Ferraro or Omar Farouk, so their `HOUSE_VS_RING` is NULL.

    ![Query Result splits each dealer's house result, with Elliot Shaw at 21750 from other players and -4375 to the ring.](images/sql-features-03.png " ")

2. Floor hosts like to thank their biggest winner of the night. Find each host's top player by net win. `QUALIFY`, new in release update 23.26.0, filters on a window function the way `HAVING` filters on an aggregate. Look at Nina's row. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Each floor host's biggest winner of the night
    SELECT p.host_username AS floor_host,
           p.full_name     AS top_player,
           p.loyalty_tier,
           SUM(s.cash_out - s.buy_in) AS net_win
    FROM play_sessions s
    JOIN TO ONE (players p)
    GROUP BY p.host_username, p.full_name, p.loyalty_tier
    QUALIFY RANK() OVER (PARTITION BY p.host_username
                         ORDER BY SUM(s.cash_out - s.buy_in) DESC) = 1
    ORDER BY floor_host;
    </copy>
    ```

    You should see four rows, one per host. Ben Carter tops Priya's list at $19,000. Nina's top player is Victor Lang, her VIP, at $1,600. If Nina thanked her biggest winner, she'd be thanking a member of the ring. That's why **Lab 5** keeps the case file from her.

    Without `QUALIFY`, you'd rank the players in an inline view, then filter outside it. The old shape was `SELECT * FROM (SELECT ..., RANK() OVER (...) AS rnk ...) WHERE rnk = 1`.

    ![Query Result lists each floor host's top player, with Victor Lang, a VIP, on Nina's row.](images/sql-features-04.png " ")

## Task 3: Measure time with DATEDIFF and DATEADD

1. Vera's report needs timing. How close together did the four sit down, and how long did all four play at once? `DATEDIFF`, new in release update 23.26.1, returns the difference between two datetimes in the unit you name. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- The three times all four sat at one table: how fast they arrived, how long they played
    SELECT g.table_name,
           TO_CHAR(MIN(s.started_at), 'HH24:MI')                  AS first_seated,
           DATEDIFF(MINUTE, MIN(s.started_at), MAX(s.started_at)) AS minutes_to_seat_all,
           DATEDIFF(MINUTE, MAX(s.started_at), MIN(s.ended_at))   AS minutes_all_four_played
    FROM play_sessions s
    JOIN TO ONE (gaming_tables g)
    WHERE s.player_id IN (SELECT player_id FROM case_players WHERE case_id = 1)
    GROUP BY g.table_name, TRUNC(s.started_at, 'HH')
    HAVING COUNT(*) = 4
    ORDER BY MIN(s.started_at);
    </copy>
    ```

    You should see three rows: Blackjack 3 at 20:04 and 21:02, then Blackjack 4 at 22:05. Each time, all four sat down within 4 minutes. Then all four played together for 44 or 45 minutes.

    How the query reads:

    * Each group is one table in one hour. `HAVING COUNT(*) = 4` keeps the groups where all four played.
    * From the last arrival, `MAX(started_at)`, to the first departure, `MIN(ended_at)`, all four were at the table.
    * Subtracting two timestamps gives an interval. Before `DATEDIFF`, turning it into minutes took `EXTRACT(HOUR FROM ...) * 60 + EXTRACT(MINUTE FROM ...)`.

    ![Query Result shows three sittings at Blackjack 3 and Blackjack 4, all four seated within 4 minutes each time.](images/sql-features-05.png " ")

2. Last, Vera asks the camera room for footage of the chip loop from **Lab 3**. She wants each lap, from 5 minutes before its first transfer to 5 minutes after its last. `DATEADD`, new in release update 23.26.3, adds or subtracts a number of units from a datetime. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Camera footage for each lap of the chip loop, with 5 minutes either side
    SELECT TO_CHAR(DATEADD(MINUTE, -5, MIN(t.transferred_at)), 'HH24:MI') AS footage_from,
           TO_CHAR(DATEADD(MINUTE, 5, MAX(t.transferred_at)), 'HH24:MI')  AS footage_to,
           DATEDIFF(MINUTE, MIN(t.transferred_at), MAX(t.transferred_at)) AS lap_minutes,
           SUM(t.amount) AS chips_moved
    FROM chip_transfers t
    WHERE t.from_player_id IN (SELECT player_id FROM case_players WHERE case_id = 1)
    GROUP BY TRUNC(t.transferred_at, 'HH')
    ORDER BY MIN(t.transferred_at);
    </copy>
    ```

    You should see two rows, one per lap. The footage runs from 23:00 to 23:31, then from 01:30 to 02:01. Both laps took 21 minutes. The first moved $6,000 in chips and the second $4,000.

    Each lap fits inside one clock hour, so grouping by the hour separates them. In **Lab 3**, the lap query wrote `t1.transferred_at + INTERVAL '1' HOUR`. `DATEADD(HOUR, 1, t1.transferred_at)` does the same, and it reads the same way for every unit, from years to nanoseconds.

## Conclusion

You answered Vera's follow-up questions with five additions to SQL. `JOIN TO ONE` followed the foreign keys and refused a join that would double count. `FILTER`, `QUALIFY`, `DATEDIFF` and `DATEADD` replaced CASE expressions, nested queries and interval arithmetic.

That completes the workshop. You built the Silverleaf Casino floor, served it as JSON, uncovered the collusion ring and protected the evidence. Every step ran in one Oracle AI Database 26ai.

## Learn More

* [SQL (Oracle AI Database New Features)](https://docs.oracle.com/en/database/oracle/oracle-database/26/nfcoa/appdev_sql.html)
* [Building Queries with Correct JOINS More Easily](https://docs.oracle.com/en/database/oracle/oracle-database/26/adfns/building-queries-correct-joins-more-easily.html)
* [Advanced SQL Extensions: Calendar Functions and Aggregation Filters](https://docs.oracle.com/en/database/oracle/oracle-database/26/adfns/advanced-sql-extensions-calendar-and-aggregation-filters.html)
* [DATEDIFF](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/datediff.html)

## Acknowledgements
* **Author** - Killian Lynch, Oracle Database Product Management
* **Last Updated By/Date** - Killian Lynch, October 2026
