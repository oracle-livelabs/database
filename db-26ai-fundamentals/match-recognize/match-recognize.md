# Lab: Row Pattern Matching with MATCH_RECOGNIZE

## Introduction

Some questions aren't about rows, they're about *shapes across rows*. "Find every time the price dipped and recovered." "Show me sessions where a user failed login three times then succeeded." Writing that with self-joins or window functions turns into a wall of CASE expressions.

MATCH\_RECOGNIZE treats ordered rows like text and your business pattern like a regular expression. You name the row types (a DOWN day, an UP day), give each a condition, and write the shape you're hunting for as a pattern: `DOWN+ UP+`. The database finds every match.

(this is not actually a new feature...) it has been in the database since 12c, but it remains one of the most powerful and least-known tools in SQL, and it pairs naturally with the analytic features elsewhere in this workshop.

Why does it matter?
- Patterns that take pages of self-joins become a few readable lines
- The pattern language is a regex over rows: `+`, `*`, `?`, alternation all work
- One pass over the data, no matter how complex the shape

In this lab, you'll find every "V-shaped dip" which is a price drop, followed by a recovery, in a month of stock prices.

Estimated Lab Time: 10 minutes

### Objectives

In this lab you will:

- Define row classifications with DEFINE conditions
- Express a row pattern with regex-style quantifiers
- Summarize each match with MEASURES and ONE ROW PER MATCH
- Expand matches row by row with ALL ROWS PER MATCH and CLASSIFIER()

### Prerequisites

- Access to Oracle AI Database 26ai
- Basic understanding of SQL; window functions help but aren't required

## Task 1: Create the Price History

1. Create twelve days of closing prices. Read the numbers and you can see the story: a climb to 52, a slide to 44, a recovery to 53, then a second smaller dip and rebound to 55.

    ```sql
    <copy>
    DROP TABLE IF EXISTS mr_prices CASCADE CONSTRAINTS;

    CREATE TABLE mr_prices (
        symbol      VARCHAR2(10) NOT NULL,
        price_date  DATE         NOT NULL,
        close_price NUMBER(8,2)  NOT NULL
    );

    INSERT INTO mr_prices VALUES
        ('ORCL', DATE '2026-06-01', 50),
        ('ORCL', DATE '2026-06-02', 52),
        ('ORCL', DATE '2026-06-03', 51),
        ('ORCL', DATE '2026-06-04', 48),
        ('ORCL', DATE '2026-06-05', 45),
        ('ORCL', DATE '2026-06-06', 44),
        ('ORCL', DATE '2026-06-07', 47),
        ('ORCL', DATE '2026-06-08', 50),
        ('ORCL', DATE '2026-06-09', 53),
        ('ORCL', DATE '2026-06-10', 52),
        ('ORCL', DATE '2026-06-11', 49),
        ('ORCL', DATE '2026-06-12', 55);

    COMMIT;
    </copy>
    ```

## Task 2: Find Every Dip in One Query

1. Hunt for the V shape. Read it from the bottom up: DEFINE says what DOWN and UP days *are*, PATTERN says a dip is "a starting row, then one or more DOWN days, then one or more UP days", and MEASURES picks what each found dip should report.

    ```sql
    <copy>
    SELECT *
    FROM mr_prices MATCH_RECOGNIZE (
        PARTITION BY symbol
        ORDER BY price_date
        MEASURES
            STRT.price_date          AS dip_started,
            STRT.close_price         AS price_before,
            LAST(DOWN.price_date)    AS bottom_date,
            LAST(DOWN.close_price)   AS bottom_price,
            LAST(UP.price_date)      AS recovered_on,
            LAST(UP.close_price)     AS recovery_price
        ONE ROW PER MATCH
        AFTER MATCH SKIP TO LAST UP
        PATTERN (STRT DOWN+ UP+)
        DEFINE
            DOWN AS close_price < PREV(close_price),
            UP   AS close_price > PREV(close_price)
    )
    ORDER BY dip_started;
    </copy>
    ```

    **What you should see:**

    | SYMBOL | DIP_STARTED | PRICE_BEFORE | BOTTOM_DATE | BOTTOM_PRICE | RECOVERED_ON | RECOVERY_PRICE |
    | --- | --- | --- | --- | --- | --- | --- |
    | ORCL | 02-JUN-26 | 52 | 06-JUN-26 | 44 | 09-JUN-26 | 53 |
    | ORCL | 09-JUN-26 | 53 | 11-JUN-26 | 49 | 12-JUN-26 | 55 |

    - Two dips, each summarized in one row: where it started, the bottom, and the recovery
    - `AFTER MATCH SKIP TO LAST UP` restarts the search at each recovery peak, which is why June 9 ends the first dip and starts the second

## Task 3: See Which Role Each Row Played

1. Sometimes you want the matched rows themselves, not a summary. ALL ROWS PER MATCH returns every row in every match, and CLASSIFIER() labels each row with the pattern variable it satisfied.

    ```sql
    <copy>
    SELECT price_date, close_price, day_role, match_no
    FROM mr_prices MATCH_RECOGNIZE (
        PARTITION BY symbol
        ORDER BY price_date
        MEASURES
            CLASSIFIER()    AS day_role,
            MATCH_NUMBER()  AS match_no
        ALL ROWS PER MATCH
        AFTER MATCH SKIP TO LAST UP
        PATTERN (STRT DOWN+ UP+)
        DEFINE
            DOWN AS close_price < PREV(close_price),
            UP   AS close_price > PREV(close_price)
    )
    ORDER BY price_date;
    </copy>
    ```

    **What you should see:**
    - All 12 trading days tagged STRT, DOWN, or UP with their match number (1 or 2)
    - June 9 appears twice: it's the recovery peak of match 1 *and* the starting row of match 2
    - June 1 appears in no match - the pattern starts with the first local peak

2. Clean up.

    ```sql
    <copy>
    DROP TABLE IF EXISTS mr_prices CASCADE CONSTRAINTS;
    </copy>
    ```

    The same pattern grammar handles richer shapes: `DOWN{3,}` for at least three consecutive drops, `(DOWN | FLAT)+` for slides that include sideways days, or W-shape double dips - all in the PATTERN clause.

## Learn More

- [SQL for Pattern Matching - Data Warehousing Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/dwhsg/sql-pattern-matching-data-warehouses.html)

## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, June 2026
