# Lab: QUALIFY Clause for Analytic Functions in Oracle AI Database 26ai

## Introduction

The QUALIFY clause is to analytic functions what HAVING is to GROUP BY - a way to filter results after calculations finish.

Traditionally, filtering analytic function results (like RANK() or ROW_NUMBER()) required wrapping queries in subqueries or Common Table Expressions. Oracle Database 26ai's QUALIFY clause lets you filter analytic function results directly in the same query.

Why does it matter?
- Fewer lines of code means fewer chance for bugs
- No nested queries means easier maintenance
- Direct filtering means better readability

In this lab, you'll look at a video game store's sales data to find some top-performing games, look at the outliers, and discover trends - all using QUALIFY to keep your queries clean and readable.

Estimated Lab Time: 15 minutes

### Objectives

In this lab you will:

- Filter analytic function results using the QUALIFY clause
- Use QUALIFY with ROW\_NUMBER(), RANK(), DENSE\_RANK(), and aggregate functions
- Reference column aliases in QUALIFY clauses for cleaner queries
- Compare QUALIFY with traditional subquery approaches

**What you'll learn:**
- Write queries in 5 lines instead of 15
- Eliminate confusing nested subqueries
- Make your analytic function queries readable by anyone on your team

### Prerequisites

- Access to Oracle AI Database 26ai
- Basic understanding of SQL and analytic functions
- Familiarity with PARTITION BY and ORDER BY concepts

## Task 1: Create the Game Sales Dataset

Imagine you manage sales data for a video game store. Your stakeholders ask questions like:
- "What are our top 3 games in each genre?"
- "Which games sell above their genre's average?"
- "Show me premium games in the top 5 by sales"

These questions all need analytic functions *and* filtering - exactly where QUALIFY shines.

1. Create and populate the game sales table.

    ```sql
    <copy>
    DROP TABLE IF EXISTS game_sales CASCADE CONSTRAINTS;

    CREATE TABLE game_sales (
        game_id NUMBER PRIMARY KEY,
        game_title VARCHAR2(100) NOT NULL,
        genre VARCHAR2(50) NOT NULL,
        release_year NUMBER NOT NULL,
        price NUMBER(6,2) NOT NULL,
        units_sold NUMBER NOT NULL,
        revenue NUMBER(10,2) NOT NULL
    );

    -- Insert sample game sales data across multiple genres
    INSERT INTO game_sales VALUES
        (1, 'Cosmic Raiders', 'Action', 2023, 59.99, 145000, 8698550.00),
        (2, 'Fantasy Quest VII', 'RPG', 2023, 69.99, 328000, 22956720.00),
        (3, 'Speed Demon Racing', 'Racing', 2024, 49.99, 89000, 4449110.00),
        (4, 'Mystery Manor', 'Adventure', 2023, 39.99, 76000, 3039240.00),
        (5, 'Battle Royale Legends', 'Action', 2024, 0.00, 2500000, 0.00),
        (6, 'Puzzle Paradise', 'Puzzle', 2024, 19.99, 156000, 3118440.00),
        (7, 'Dragon Age Chronicles', 'RPG', 2023, 69.99, 445000, 31145550.00),
        (8, 'Soccer Star 2024', 'Sports', 2024, 59.99, 234000, 14037660.00),
        (9, 'Space Survival', 'Action', 2024, 44.99, 167000, 7513330.00),
        (10, 'Card Master Pro', 'Puzzle', 2023, 9.99, 423000, 4225770.00),
        (11, 'Medieval Warfare', 'Strategy', 2024, 54.99, 198000, 10888020.00),
        (12, 'Dungeon Crawlers', 'RPG', 2024, 59.99, 287000, 17217130.00),
        (13, 'Street Racers', 'Racing', 2023, 49.99, 134000, 6698660.00),
        (14, 'Horror Nights', 'Adventure', 2024, 39.99, 112000, 4478880.00),
        (15, 'Tennis Championship', 'Sports', 2024, 39.99, 67000, 2679330.00),
        (16, 'Kingdom Builder', 'Strategy', 2023, 49.99, 245000, 12247550.00),
        (17, 'Ninja Warriors', 'Action', 2023, 59.99, 189000, 11337110.00),
        (18, 'Word Wizard', 'Puzzle', 2024, 14.99, 289000, 4332110.00),
        (19, 'Island Explorer', 'Adventure', 2024, 44.99, 156000, 7018440.00),
        (20, 'Empire Wars', 'Strategy', 2024, 59.99, 312000, 18716880.00);

    COMMIT;
    </copy>
    ```

    **What you should see:**
    - 20 games across 7 genres (Action, RPG, Racing, Adventure, Puzzle, Sports, Strategy)
    - Mix of free-to-play (Battle Royale Legends) and premium games ($9.99 to $69.99)
    - Different sales volumes from 67,000 to 2.5 million units

2. View the top revenue generators to understand the data.

    ```sql
    <copy>
    SELECT game_title, genre, price, units_sold, revenue
    FROM game_sales
    ORDER BY revenue DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```


    ![Top 5 games by revenue showing Dragon Age Chronicles at #1 with $31M](images/qualify.png =40%x*)


## Task 2: Find Top Performers with QUALIFY

QUALIFY filters analytic function results - it runs after RANK(), ROW_NUMBER(), etc. calculate their values. This eliminates the need for subqueries when filtering ranked data.

1. Find the top 2 best-selling games in each genre.

    ```sql
    <copy>
    SELECT
        game_title,
        genre,
        units_sold,
        RANK() OVER (PARTITION BY genre ORDER BY units_sold DESC) AS sales_rank
    FROM game_sales
    QUALIFY sales_rank <= 2
    ORDER BY genre, sales_rank;
    </copy>
    ```

    **What you should see:**
    - Top 2 games per genre by units sold
    - Battle Royale Legends dominates Action with 2.5M units (free-to-play)
    - Dragon Age Chronicles leads RPG with 445K units
    - No subquery needed - QUALIFY filters the RANK() results directly

2. Compare with the traditional subquery approach.

    ```sql
    <copy>
    -- Traditional approach requires nested query
    SELECT game_title, genre, units_sold, sales_rank
    FROM (
        SELECT
            game_title,
            genre,
            units_sold,
            RANK() OVER (PARTITION BY genre ORDER BY units_sold DESC) AS sales_rank
        FROM game_sales
    )
    WHERE sales_rank <= 2
    ORDER BY genre, sales_rank;
    </copy>
    ```

    **What you should see:**
    - Identical results but with extra nesting complexity
    - Must repeat column names in outer query
    - QUALIFY eliminates this wrapper entirely

    **Query Execution Flow:**
    ```
    FROM game_sales          ← Get the data
    WHERE (if present)       ← Filter rows
    RANK() OVER(...)         ← Calculate rankings
    QUALIFY sales_rank <= 2  ← Filter rankings
    ORDER BY                 ← Sort results
    ```

3. Use ROW_NUMBER() to get exactly 3 games per genre (no ties).

    ```sql
    <copy>
    SELECT
        game_title,
        genre,
        revenue,
        ROW_NUMBER() OVER (PARTITION BY genre ORDER BY revenue DESC) AS row_num
    FROM game_sales
    QUALIFY row_num <= 3
    ORDER BY genre, row_num;
    </copy>
    ```

    **What you should see:**
    - Exactly 3 games per genre (ROW_NUMBER breaks ties arbitrarily)
    - RANK() would return more than 3 if there were ties
    - Different use cases: ROW_NUMBER for "exactly N", RANK for "top N positions"

## Task 3: Filter with Aggregate Analytic Functions

You can use QUALIFY with aggregates like AVG() OVER() to find outliers or compare values against group statistics.

1. Find games priced above their genre's average price.

    ```sql
    <copy>
    SELECT
        game_title,
        genre,
        price,
        ROUND(AVG(price) OVER (PARTITION BY genre), 2) AS genre_avg_price,
        ROUND(price - AVG(price) OVER (PARTITION BY genre), 2) AS price_diff
    FROM game_sales
    QUALIFY price > genre_avg_price
    ORDER BY price_diff DESC;
    </copy>
    ```

    **What you should see:**
    - Games priced above their genre average
    - RPG games at $69.99 are premium priced (AAA titles)
    - QUALIFY references the genre\_avg\_price alias directly
    - No subquery needed to filter on calculated averages

2. Find games above average revenue AND ranking in top 3 for their genre.

    ```sql
    <copy>
    SELECT
        game_title,
        genre,
        revenue,
        ROUND(AVG(revenue) OVER (PARTITION BY genre), 2) AS genre_avg_revenue,
        RANK() OVER (PARTITION BY genre ORDER BY revenue DESC) AS genre_rank,
        ROUND((revenue / AVG(revenue) OVER (PARTITION BY genre)) * 100, 1) AS pct_of_avg
    FROM game_sales
    QUALIFY revenue > genre_avg_revenue AND genre_rank <= 3
    ORDER BY genre, genre_rank;
    </copy>
    ```

    **What you should see:**
    - Games that are both highly ranked AND above average
    - Multiple analytic functions (AVG and RANK) filtered in one QUALIFY clause
    - Dragon Age Chronicles at 131% of RPG average revenue
    - Battle Royale Legends excluded (free game skews the average)

3. Find genres where a game contributes more than 40% of total genre revenue.

    ```sql
    <copy>
    SELECT
        game_title,
        genre,
        revenue,
        SUM(revenue) OVER (PARTITION BY genre) AS genre_total_revenue,
        ROUND((revenue / SUM(revenue) OVER (PARTITION BY genre)) * 100, 1) AS pct_of_genre
    FROM game_sales
    QUALIFY pct_of_genre > 40
    ORDER BY pct_of_genre DESC;
    </copy>
    ```

    **What you should see:**
    - Dragon Age Chronicles dominates RPG genre with 43.7% of total revenue
    - Shows which games are single-handedly driving their genre's performance
    - SUM() with QUALIFY identifies market concentration without subqueries

## Task 4: Understanding Ties: RANK vs DENSE_RANK

When values tie, RANK() leaves gaps while DENSE_RANK() doesn't. QUALIFY works seamlessly with both.

1. Add games with duplicate revenue values to demonstrate tie handling.

    ```sql
    <copy>
    -- Add games with identical revenue to existing games
    INSERT INTO game_sales VALUES
        (21, 'Puzzle Quest', 'Puzzle', 2024, 19.99, 156000, 3118440.00),
        (22, 'Race Master', 'Racing', 2023, 49.99, 134000, 6698660.00);
    COMMIT;
    </copy>
    ```

2. Compare RANK() (with gaps) vs DENSE_RANK() (no gaps).

    ```sql
    <copy>
    -- RANK() leaves gaps after ties
    SELECT
        game_title,
        genre,
        revenue,
        RANK() OVER (PARTITION BY genre ORDER BY revenue DESC) AS rank_with_gaps
    FROM game_sales
    WHERE genre IN ('Puzzle', 'Racing')
    QUALIFY rank_with_gaps <= 4
    ORDER BY genre, rank_with_gaps, game_title;
    </copy>
    ```

    ```sql
    <copy>
    -- DENSE_RANK() has no gaps
    SELECT
        game_title,
        genre,
        revenue,
        DENSE_RANK() OVER (PARTITION BY genre ORDER BY revenue DESC) AS rank_no_gaps
    FROM game_sales
    WHERE genre IN ('Puzzle', 'Racing')
    QUALIFY rank_no_gaps <= 3
    ORDER BY genre, rank_no_gaps, game_title;
    </copy>
    ```

    **What you should see:**
    - **Puzzle genre**: Word Wizard (1), Card Master Pro (2), Puzzle Paradise (3), Puzzle Quest (3)
      - With RANK(): ranks are 1, 2, 3, 3 (no game with rank 4 in results)
      - With DENSE_RANK(): ranks are 1, 2, 3, 3 (same as RANK when ties are at end)
    - **Racing genre**: Race Master (1), Street Racers (1), Speed Demon Racing (3 with RANK, 2 with DENSE_RANK)
      - With RANK(): ranks are 1, 1, 3 (gap: no rank 2)
      - With DENSE_RANK(): ranks are 1, 1, 2 (no gap)
    - RANK() leaves gaps after ties, DENSE_RANK() doesn't
    - Choose RANK() for "top N positions", DENSE_RANK() for "top N distinct values"


## Learn More

- [Oracle Database SQL Language Reference - Analytic Functions](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/Analytic-Functions.html)
- [QUALIFY Clause in Oracle AI Database 26ai](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/SELECT.html#GUID-CFA006CA-6FF1-4972-821E-6996142A51C6__GUID-26AD2928-0111-4087-88A1-601C8037EF13)


## Acknowledgements

- **Author** - Killian Lynch, Oracle AI Database Product Manager
- **Last Updated By/Date** - Killian Lynch, December 2025
