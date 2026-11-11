# Build the Casino Floor with Domains, Annotations and Assertions

## Introduction

Surveillance at the Silverleaf Casino has a tip: someone on the floor is cheating, and they aren't working alone. Vera Lindqvist, the casino's surveillance investigator, needs the night's play in one database she can trust.

You build that database in this lab. The floor has 40 players, 8 dealers and 8 gaming tables. Four floor hosts look after the players: Nina Alvarez, Marco Bellini, Priya Raman and Owen Fitch.

Most apps keep their data rules in application code. A form checks that an amount is valid, and a service checks that a dealer is free. That works until another app, a script or an AI agent writes to the same tables and skips the check. In this lab, you put the rules in the database instead. The database enforces them for every writer, including apps you haven't built yet.

This lab uses three features of Oracle AI Database 26ai to do it:

* **Data use case domains.** A domain is a named data type with rules attached, such as a check constraint. You use the domain as a column's data type, and the column gets its rules. You write a rule once, and every column that uses the domain enforces it the same way. Before domains, you copied the same check constraint onto each column, and the copies could drift apart.
* **Annotations.** An annotation is a name and value label on a table, column or domain. The database stores it in the data dictionary, so any app or tool can query it. Annotations let the schema describe itself, such as which columns hold personal data. Comments could already hold notes, but a comment is one free-text string. A column can carry many annotations, and tools can look them up by name.
* **Assertions.** An assertion is a rule written as a query. It can compare many rows and tables, and the database rejects any change that breaks it. Before assertions, rules like this lived in application code or in triggers. Every app had to repeat the code, and triggers are hard to get right. Now you state the rule once, and the database enforces it for every app.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

* Create data use case domains, including an enumeration domain
* Build the casino tables and annotate the sensitive player columns
* Load one night of play
* Enforce a floor rule with an assertion and watch it reject a bad record

### Prerequisites

This lab assumes you have:

* Completed **Get Started with LiveLabs** and opened the SQL worksheet as ADMIN


## What are Data Use Case Domains?
Data Use Case Domains provide reusable data types with built-in constraints and validation rules. Unlike simple data types, domains can enforce complex business rules and provide consistent metadata across your entire schema, reducing development time and ensuring data quality.

Data Use Case Domains also provide consistent metadata for development, analytics, and ETL applications and tools, helping to ensure data consistency and validation throughout the schema.

### Understanding the Four Types of Data Use Case Domains

Before we build the casino floor, let's understand the four types of Data Use Case Domains available in Oracle AI Database 26ai:

#### 1. Single Column Domain
* **Purpose**: Applies constraints and validation rules to a single column across multiple tables.
* **Common Use Cases**: Email validation, price constraints, ID formats, status codes
* **Example Scenario**: A `price` domain that ensures all monetary values are positive numbers, used consistently across product tables, invoice tables, and pricing history tables.

#### 2. Multi-Column Domain
* **Purpose**: Applies constraints across multiple related columns, treating them as a logical unit.
* **Common Use Cases**: Address validation (street, city, state, zip), coordinate validation (latitude/longitude), date ranges (start/end dates), contact information (phone/email combinations)
* **Example Scenario**: A `coordinates` domain that ensures latitude is between -90 and 90 degrees and longitude is between -180 and 180 degrees, preventing invalid geographical data.

#### 3. Flexible Domain
* **Purpose**: Allows dynamic selection of different Data Use Case Domains based on specific conditions or context.
* **Common Use Cases**: Contact information that varies by type (personal vs. business), product specifications that differ by category, user profiles with role-based fields
* **Example Scenario**: A `contact_information` domain that applies different validation rules for personal contacts (requires name and phone) versus business contacts (requires company name, contact person, and phone).

#### 4. Enumeration Use Case Domain
* **Purpose**: Contains a predefined set of named values, optionally with corresponding numeric or string values.
* **Common Use Cases**: Order statuses, priority levels, user roles, product categories, workflow states
* **Example Scenario**: An `order_status` domain with values like 'pending', 'processing', 'shipped', 'delivered' that can have either auto-assigned numbers (1, 2, 3, 4) or custom values ('PEND', 'PROC', 'SHIP', 'DELV').

## What are Schema Annotations? 
Schema Annotations, as an extension of traditional comments, offer a more structured and versatile approach to database documentation. They allow us to associate name-value pairs with database objects, allowing us to describe, classify, and categorize them according to our specific requirements.

## What are Assertions?
An assertion is a rule written as a query that the database keeps true at all times. A check constraint can only look at one row, and a foreign key can only check that a matching row exists in another table. An assertion can compare many rows across many tables, and the database rejects any insert, update or delete that would break it.

Before assertions, rules like these lived in application code or in triggers. Every app had to repeat the check, and a script or a new app that skipped it could save bad data. Triggers are hard to write correctly, especially when two users change data at the same time. With an assertion, you state the rule once in the database, and every app, script and AI agent that writes to the tables follows it.

### Understanding the Three Ways to Write an Assertion

#### 1. Something Must Never Exist (`NOT EXISTS`)
* **Purpose**: Describes a situation that must never happen. The database rejects any change that would create it.
* **Common Use Cases**: Overlapping bookings, a person scheduled in two places at once, two active records where only one is allowed
* **Example Scenario**: A `no_double_booked_rooms` assertion that stops two bookings for the same meeting room at overlapping times.

#### 2. Something Must Always Exist (`EXISTS`)
* **Purpose**: Describes something that must always be present. The database rejects any change that would remove the last one.
* **Common Use Cases**: A company must have a president, a team must have a manager, a store must have at least one open checkout
* **Example Scenario**: A `company_must_have_a_president` assertion that stops anyone from deleting the only employee with the president job.

#### 3. Every Row Must Meet a Condition (`ALL ... SATISFY`)
* **Purpose**: Checks every row a query returns against a condition, and every row must pass. This often reads more naturally than a `NOT EXISTS` that looks for rows that fail.
* **Common Use Cases**: Each employee earns less than their manager, each shipment leaves after its order was placed, every department has at least one employee
* **Example Scenario**: A `staff_earn_less_than_manager` assertion that compares each employee's salary with their manager's salary, which is stored in a different row.

### When Does the Database Check an Assertion?
* **After each statement (the default)**: The database checks the rule at the end of every insert, update or delete. A change that breaks the rule fails right away.
* **At commit (deferred)**: Some changes break a rule for a moment. For example, a new department has no employees until you add the first one. A `DEFERRABLE INITIALLY DEFERRED` assertion waits until you commit, so the transaction as a whole must leave the rule true.

### Choosing the Right Rule
- **Check constraint**: The rule needs only one row, such as "the end time is after the start time"
- **Foreign key**: The rule is "this value must match a row in another table"
- **Assertion**: The rule compares several rows or tables, such as the dealer rule you build in Task 4: a dealer can't deal at two tables at the same time
- Assertions can't use `GROUP BY` or functions such as `COUNT` and `SUM`, so a rule like "no more than seven players at a table" still needs application code or a trigger

### Why Use Them Together?
The combination creates a data governance framework that benefits any organization:
- **Domains** enforce consistent data validation rules across all applications
- **Annotations** provide structured metadata for compliance, documentation, and automation
- **Assertions** enforce rules that compare rows and tables, so no app can save data that breaks them
- Together they create self-documenting database schemas that reduce maintenance overhead and improve data quality

## Task 1: Create domains for the casino floor

1. Start with the casino's fixed lists: the four games on the floor and the two staff jobs. An **enumeration domain** is a fixed list of names, each with a value. A column that uses it can only hold one of those values, so a typo such as `Blackjak` can't get in. Without enumeration domains, maybe you'd use a lookup table, which adds a table and a join. Or you'd use a check constraint with an `IN` list which can make it harder for apps to read. An enumeration domain needs neither. If a list changes often, a lookup table is still the better fit.

    Create two enumeration domains. Clear the editor, paste this block, and click **Run Script** (F5).

    ```sql
    <copy>
    -- Create two enumeration domains: the games and the staff jobs
    CREATE DOMAIN IF NOT EXISTS game_type AS ENUM (
      blackjack = 'Blackjack',
      baccarat  = 'Baccarat',
      roulette  = 'Roulette',
      craps     = 'Craps'
    );

    CREATE DOMAIN IF NOT EXISTS staff_role AS ENUM (
      surveillance = 'SURVEILLANCE',
      floor_host   = 'FLOOR_HOST'
    );
    </copy>
    ```

    Script Output confirms the two new domains:

    * `game_type` lists the four games. A column stores the value, such as `Blackjack`, and SQL can write it as `game_type.blackjack`.
    * `staff_role` lists the two staff jobs, `SURVEILLANCE` and `FLOOR_HOST`. The staff table uses it here, and the case files use it in **Lab 3**, so both columns share one list.

2. An enumeration domain also works as a lookup list that you can query like a table. An app can read the list straight from the database, for example to fill a drop-down, so the app and the data always agree. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- List the games in the enumeration domain
    SELECT enum_name, enum_value FROM game_type;
    </copy>
    ```

    You should see four rows, one per game. `ENUM_NAME` is the name you use in SQL. `ENUM_VALUE` is what a column stores, such as `Blackjack`.

    ![Query Result lists the four game_type names, such as BLACKJACK, next to their stored values.](images/domains-annotations-assertions-01.png " ")

3. A casino also records amounts of chips in many places: table limits, credit limits, and the chips each player starts and ends a session with. The smallest chip at the Silverleaf is $5, so every one of those amounts must be a multiple of $5. An amount like $7 can only be a typing mistake. Without domains, each of those columns needs its own copy of that rule. Copies drift: someone changes the rule on one column and forgets another, so a mistyped $7 is rejected in one column and saved in another. A domain keeps the data type and its rules in one place.

    Create two **single-column domains**. Each one is a data type with a check constraint attached, and every column that uses it gets the check. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Create two single-column domains, each with a check constraint
    CREATE DOMAIN IF NOT EXISTS chip_amount AS NUMBER(10)
      CONSTRAINT chip_amount_ck CHECK (chip_amount >= 0 AND MOD(chip_amount, 5) = 0)
      DISPLAY '$' || TO_CHAR(chip_amount, 'FM9,999,999,990')
      ANNOTATIONS (currency 'USD', smallest_chip '5');

    CREATE DOMAIN IF NOT EXISTS staff_username AS VARCHAR2(30)
      CONSTRAINT staff_username_ck CHECK (REGEXP_LIKE(staff_username, '^[a-z]+$'))
      ANNOTATIONS (description 'Staff sign-in name, lowercase letters only');
    </copy>
    ```

    Script Output confirms the two new domains:

    * `chip_amount` rejects negative amounts and anything that isn't a multiple of $5, the smallest chip the casino uses. Every column that uses it gets this check, plus its `currency` and `smallest_chip` annotations.
    * `chip_amount` also has a `DISPLAY` line, which says how to show an amount to people: a dollar sign, then the number with commas. You try it in Task 3, once the casino's data is loaded.
    * `staff_username` allows lowercase letters only.

4. Domains come with several SQL functions that make them easier to work with. One of them, `DOMAIN_CHECK`, tests a value against a domain's rules without inserting anything. An app can use it to check a form field before saving, with the same rule the database enforces. Without it, the app keeps its own copy of the rule, and the two copies can disagree. Clear the editor and run this query with **Run Statement**.

    ```sql
    <copy>
    -- Test four values against the domains
    SELECT DOMAIN_CHECK(chip_amount, 25)        AS chips_25,
           DOMAIN_CHECK(chip_amount, 7)         AS chips_7,
           DOMAIN_CHECK(staff_username, 'nina') AS nina_lower,
           DOMAIN_CHECK(staff_username, 'Nina') AS nina_capital;
    </copy>
    ```

    You should see TRUE, FALSE, TRUE and FALSE. No mix of Silverleaf chips adds up to $7, and `Nina` with a capital N isn't a valid username. These are the same checks that every column using these domains will run.

## Task 2: Build the casino tables and mark the sensitive data

1. Create the tables for the people on the floor: the staff and the players. Several columns use your domains as their data type.

    Four player columns also carry a `sensitive` annotation. An annotation is a name and value pair, such as `sensitive 'Government ID'`. One object can carry many annotations, and you can annotate many kinds of database objects, including tables, columns, views, indexes and domains.  Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Create the tables for the staff and the players
    CREATE TABLE IF NOT EXISTS casino_staff (
      username    staff_username PRIMARY KEY,
      full_name   VARCHAR2(60) NOT NULL,
      staff_role  staff_role NOT NULL
    )
    ANNOTATIONS (data_owner 'Casino Operations');

    CREATE TABLE IF NOT EXISTS players (
      player_id      NUMBER PRIMARY KEY,
      full_name      VARCHAR2(60) NOT NULL,
      loyalty_tier   VARCHAR2(10) NOT NULL
                     CONSTRAINT players_tier_ck CHECK (loyalty_tier IN ('STANDARD', 'GOLD', 'VIP')),
      host_username  staff_username NOT NULL REFERENCES casino_staff (username),
      favorite_game  game_type,
      government_id  VARCHAR2(20)  ANNOTATIONS (sensitive 'Government ID'),
      date_of_birth  DATE          ANNOTATIONS (sensitive 'Date of birth'),
      home_address   VARCHAR2(100) ANNOTATIONS (sensitive 'Home address'),
      credit_limit   chip_amount   ANNOTATIONS (sensitive 'Credit limit')
    )
    ANNOTATIONS (data_owner 'Player Services');
    </copy>
    ```

    A few things to notice:

    * Every player has a floor host. `host_username` uses the `staff_username` domain and references `casino_staff`, so it follows the same lowercase rule as the staff table's key.
    * `credit_limit` uses `chip_amount`, so a credit limit must be a multiple of $5.
    * `favorite_game` uses `game_type`, so it can only hold one of the four games. It starts empty. In **Lab 2**, players set it themselves on the casino's website.
    * `loyalty_tier` uses a plain check constraint, not a domain. The rule applies to one column in one table, so a check constraint is simpler. A domain pays off when several columns share a rule, or when apps need to read the list.
    * `government_id`, `date_of_birth`, `home_address` and `credit_limit` carry the `sensitive` annotation. An annotation is a name and an optional value, stored in the data dictionary.
    * Each table has a `data_owner` annotation that names the team responsible for its data. That team decides who can see the data and fixes it when it's wrong. When a row looks wrong or someone needs access, anyone can look up which team to ask.

2. Next, create the tables for the floor. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Create the tables for the dealers and the gaming tables
    CREATE TABLE IF NOT EXISTS dealers (
      dealer_id  NUMBER PRIMARY KEY,
      full_name  VARCHAR2(60) NOT NULL,
      hired_on   DATE NOT NULL
    )
    ANNOTATIONS (data_owner 'Table Games');

    CREATE TABLE IF NOT EXISTS gaming_tables (
      table_id    NUMBER PRIMARY KEY,
      table_name  VARCHAR2(30) NOT NULL UNIQUE,
      game        game_type NOT NULL,
      min_bet     chip_amount NOT NULL,
      max_bet     chip_amount NOT NULL,
      CONSTRAINT gaming_tables_bet_ck CHECK (max_bet > min_bet)
    )
    ANNOTATIONS (data_owner 'Table Games');
    </copy>
    ```

    What to notice:

    * `gaming_tables.game` uses `game_type`, so every table runs one of the four games. It's the same list that `players.favorite_game` uses.
    * `min_bet` and `max_bet` use `chip_amount`, like `credit_limit` in `players`. Three columns in two tables now share one rule, and you wrote it once.

3. Now create the tables for what happens on the floor. A play session is one player's stint at one table with one dealer. A chip transfer records chips that one player hands to another, as surveillance logs it from the cameras. Casinos watch for these handoffs because a team of cheats can pass chips around so that no single player wins enough to draw surveillance's attention. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Create the tables for what happens on the floor
    CREATE TABLE IF NOT EXISTS play_sessions (
      session_id  NUMBER PRIMARY KEY,
      player_id   NUMBER NOT NULL REFERENCES players (player_id),
      table_id    NUMBER NOT NULL REFERENCES gaming_tables (table_id),
      dealer_id   NUMBER NOT NULL REFERENCES dealers (dealer_id),
      started_at  TIMESTAMP NOT NULL,
      ended_at    TIMESTAMP NOT NULL,
      buy_in      chip_amount NOT NULL,
      cash_out    chip_amount NOT NULL,
      CONSTRAINT play_sessions_time_ck CHECK (ended_at > started_at)
    )
    ANNOTATIONS (data_owner 'Table Games', description 'One player at one table with one dealer');

    CREATE TABLE IF NOT EXISTS chip_transfers (
      transfer_id     NUMBER PRIMARY KEY,
      from_player_id  NUMBER NOT NULL REFERENCES players (player_id),
      to_player_id    NUMBER NOT NULL REFERENCES players (player_id),
      amount          chip_amount NOT NULL,
      transferred_at  TIMESTAMP NOT NULL,
      CONSTRAINT chip_transfers_amount_ck CHECK (amount > 0),
      CONSTRAINT chip_transfers_players_ck CHECK (from_player_id <> to_player_id)
    )
    ANNOTATIONS (data_owner 'Surveillance', description 'Chips passed from one player to another');
    </copy>
    ```

    `buy_in`, `cash_out` and `amount` also use `chip_amount`. Six columns across four tables now share one chip rule, defined in one place.


4. Annotations live in the data dictionary, so any tool or person can ask which columns are sensitive. A privacy tool, a reporting app or an AI agent can find personal data this way, without reading code or guessing from column names. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- List every column marked sensitive
    SELECT object_name      AS table_name,
           column_name,
           annotation_value AS holds
    FROM user_annotations_usage
    WHERE annotation_name = 'SENSITIVE'
    ORDER BY column_name;
    </copy>
    ```

    You should see four rows, all from `PLAYERS`: `CREDIT_LIMIT`, `DATE_OF_BIRTH`, `GOVERNMENT_ID` and `HOME_ADDRESS`.

    ![Query Result lists the four sensitive PLAYERS columns, with what each one holds.](images/domains-annotations-assertions-02.png " ")

## Task 3: Load a night of play

1. Load the cast, starting with the five staff members, eight dealers and eight gaming tables. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Load the staff, dealers and gaming tables
    DELETE FROM chip_transfers;
    DELETE FROM play_sessions;
    DELETE FROM players;
    DELETE FROM dealers;
    DELETE FROM gaming_tables;
    DELETE FROM casino_staff;

    INSERT INTO casino_staff (username, full_name, staff_role) VALUES
      ('vera',  'Vera Lindqvist', 'SURVEILLANCE'),
      ('nina',  'Nina Alvarez',   'FLOOR_HOST'),
      ('marco', 'Marco Bellini',  'FLOOR_HOST'),
      ('priya', 'Priya Raman',    'FLOOR_HOST'),
      ('owen',  'Owen Fitch',     'FLOOR_HOST');

    INSERT INTO dealers (dealer_id, full_name, hired_on) VALUES
      (1, 'Grace Liu',     DATE '2014-03-10'),
      (2, 'Omar Farouk',   DATE '2019-08-26'),
      (3, 'Elliot Shaw',   DATE '2023-06-12'),
      (4, 'Hannah Berg',   DATE '2017-01-09'),
      (5, 'Kenji Mori',    DATE '2012-05-21'),
      (6, 'Lucia Ferraro', DATE '2025-02-03'),
      (7, 'Tom Brennan',   DATE '2009-10-05'),
      (8, 'Aisha Bello',   DATE '2021-07-19');

    INSERT INTO gaming_tables (table_id, table_name, game, min_bet, max_bet) VALUES
      (1, 'Blackjack 1', game_type.blackjack,  25,  2500),
      (2, 'Blackjack 2', game_type.blackjack,  25,  2500),
      (3, 'Blackjack 3', game_type.blackjack,  50,  5000),
      (4, 'Blackjack 4', game_type.blackjack, 100, 10000),
      (5, 'Baccarat 1',  game_type.baccarat,  100, 10000),
      (6, 'Baccarat 2',  game_type.baccarat,  100, 10000),
      (7, 'Roulette 1',  game_type.roulette,   10,  1000),
      (8, 'Craps 1',     game_type.craps,      10,  1000);

    COMMIT;
    </copy>
    ```

2. Now load the 40 players. Each player gets a floor host and a loyalty tier of `STANDARD`, `GOLD` or `VIP`. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Load the 40 players
    INSERT INTO players (player_id, full_name, loyalty_tier, host_username,
                         government_id, date_of_birth, home_address, credit_limit) VALUES
      (1,  'Ava Brooks',    'VIP',      'marco', 'NV41007919', DATE '1959-04-19', '273 Lantern Way, Las Vegas, NV',  50000),
      (2,  'Ben Carter',    'STANDARD', 'priya', 'NV41015838', DATE '1960-05-24', '446 Mesa Dr, Las Vegas, NV',       2500),
      (3,  'Chloe Nguyen',  'GOLD',     'owen',  'NV41023757', DATE '1961-06-29', '619 Copper Ave, Las Vegas, NV',   10000),
      (4,  'Diego Santos',  'STANDARD', 'nina',  'NV41031676', DATE '1962-08-04', '792 Sage Ct, Las Vegas, NV',       2500),
      (5,  'Ella Fischer',  'STANDARD', 'marco', 'NV41039595', DATE '1963-09-09', '965 Juniper St, Las Vegas, NV',    2500),
      (6,  'Farid Rahman',  'GOLD',     'priya', 'NV41047514', DATE '1964-10-14', '1138 Lantern Way, Las Vegas, NV', 10000),
      (7,  'Gemma Doyle',   'STANDARD', 'owen',  'NV41055433', DATE '1965-11-19', '1311 Mesa Dr, Las Vegas, NV',      2500),
      (8,  'Hiro Tanaka',   'STANDARD', 'nina',  'NV41063352', DATE '1966-12-25', '1484 Copper Ave, Las Vegas, NV',   2500),
      (9,  'Isla McKenzie', 'GOLD',     'marco', 'NV41071271', DATE '1968-01-30', '1657 Sage Ct, Las Vegas, NV',     10000),
      (10, 'Jonah Weiss',   'VIP',      'priya', 'NV41079190', DATE '1969-03-06', '1830 Juniper St, Las Vegas, NV',  50000),
      (11, 'Keira Walsh',   'STANDARD', 'owen',  'NV41087109', DATE '1970-04-11', '2003 Lantern Way, Las Vegas, NV',  2500),
      (12, 'Liam Foster',   'GOLD',     'nina',  'NV41095028', DATE '1971-05-17', '2176 Mesa Dr, Las Vegas, NV',     10000),
      (13, 'Maya Patel',    'STANDARD', 'marco', 'NV41102947', DATE '1972-06-21', '2349 Copper Ave, Las Vegas, NV',   2500),
      (14, 'Noah Lindgren', 'STANDARD', 'priya', 'NV41110866', DATE '1973-07-27', '2522 Sage Ct, Las Vegas, NV',      2500),
      (15, 'Olivia Grant',  'GOLD',     'owen',  'NV41118785', DATE '1974-09-01', '2695 Juniper St, Las Vegas, NV',  10000),
      (16, 'Pablo Reyes',   'STANDARD', 'nina',  'NV41126704', DATE '1975-10-07', '2868 Lantern Way, Las Vegas, NV',  2500),
      (17, 'Quinn Harper',  'STANDARD', 'marco', 'NV41134623', DATE '1976-11-11', '3041 Mesa Dr, Las Vegas, NV',      2500),
      (18, 'Rosa Martins',  'GOLD',     'priya', 'NV41142542', DATE '1977-12-17', '3214 Copper Ave, Las Vegas, NV',  10000),
      (19, 'Samir Haddad',  'VIP',      'owen',  'NV41150461', DATE '1979-01-22', '3387 Sage Ct, Las Vegas, NV',     50000),
      (20, 'Tara Novak',    'STANDARD', 'nina',  'NV41158380', DATE '1980-02-27', '3560 Juniper St, Las Vegas, NV',   2500),
      (21, 'Daria Petrov',  'GOLD',     'marco', 'NV41166299', DATE '1981-04-03', '3733 Lantern Way, Las Vegas, NV', 10000),
      (22, 'Uma Desai',     'STANDARD', 'priya', 'NV41174218', DATE '1982-05-09', '3906 Mesa Dr, Las Vegas, NV',      2500),
      (23, 'Wes Turner',    'STANDARD', 'owen',  'NV41182137', DATE '1983-06-14', '4079 Copper Ave, Las Vegas, NV',   2500),
      (24, 'Yusuf Demir',   'GOLD',     'nina',  'NV41190056', DATE '1984-07-19', '4252 Sage Ct, Las Vegas, NV',     10000),
      (25, 'Zoe Adams',     'STANDARD', 'marco', 'NV41197975', DATE '1985-08-24', '4425 Juniper St, Las Vegas, NV',   2500),
      (26, 'Aaron Blake',   'STANDARD', 'priya', 'NV41205894', DATE '1986-09-29', '4598 Lantern Way, Las Vegas, NV',  2500),
      (27, 'Bianca Rossi',  'GOLD',     'owen',  'NV41213813', DATE '1987-11-04', '4771 Mesa Dr, Las Vegas, NV',     10000),
      (28, 'Victor Lang',   'VIP',      'nina',  'NV41221732', DATE '1988-12-09', '4944 Copper Ave, Las Vegas, NV',  50000),
      (29, 'Caleb Wright',  'STANDARD', 'marco', 'NV41229651', DATE '1990-01-14', '5117 Sage Ct, Las Vegas, NV',      2500),
      (30, 'Dana Kowalski', 'GOLD',     'priya', 'NV41237570', DATE '1991-02-19', '5290 Juniper St, Las Vegas, NV',  10000),
      (31, 'Felix Ortega',  'STANDARD', 'owen',  'NV41245489', DATE '1992-03-26', '5463 Lantern Way, Las Vegas, NV',  2500),
      (32, 'Greta Holm',    'STANDARD', 'nina',  'NV41253408', DATE '1993-05-01', '5636 Mesa Dr, Las Vegas, NV',      2500),
      (33, 'Hector Ruiz',   'GOLD',     'marco', 'NV41261327', DATE '1994-06-06', '5809 Copper Ave, Las Vegas, NV',  10000),
      (34, 'Ingrid Sato',   'STANDARD', 'priya', 'NV41269246', DATE '1995-07-12', '5982 Sage Ct, Las Vegas, NV',      2500),
      (35, 'Jasper Cole',   'STANDARD', 'owen',  'NV41277165', DATE '1996-08-16', '6155 Juniper St, Las Vegas, NV',   2500),
      (36, 'Kara Mensah',   'GOLD',     'nina',  'NV41285084', DATE '1997-09-21', '6328 Lantern Way, Las Vegas, NV', 10000),
      (37, 'Leo Marchetti', 'VIP',      'marco', 'NV41293003', DATE '1998-10-27', '6501 Mesa Dr, Las Vegas, NV',     50000),
      (38, 'June Calloway', 'STANDARD', 'priya', 'NV41300922', DATE '1999-12-02', '6674 Copper Ave, Las Vegas, NV',   2500),
      (39, 'Mila Horvat',   'GOLD',     'owen',  'NV41308841', DATE '2001-01-06', '6847 Sage Ct, Las Vegas, NV',     10000),
      (40, 'Nate Ellison',  'STANDARD', 'nina',  'NV41316760', DATE '2002-02-11', '7020 Juniper St, Las Vegas, NV',   2500);

    COMMIT;
    </copy>
    ```

3. Now load the night itself, from 8 PM on Sunday, October 25, 2026, until 4 AM. Dealers rotate tables every two hours, so each session records who was dealing. Player loyalty cards also track where players are playing and for how long. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Load the night of play: sessions from 20:00 to 04:00
    DELETE FROM play_sessions;

    INSERT INTO play_sessions (session_id, player_id, table_id, dealer_id,
                               started_at, ended_at, buy_in, cash_out)
    WITH seats AS (
      -- Regular play: up to one seat per player per hour, built from the player and hour numbers
      SELECT p.n AS player_id,
             h.n AS hour_no,
             CASE MOD(p.n, 5) WHEN 2 THEN 5 + MOD(p.n + h.n, 2)
                              WHEN 3 THEN 7
                              WHEN 4 THEN 8
                              ELSE 1 + MOD(p.n + h.n, 4) END AS table_id,
             h.n * 60 + MOD(p.n * 7 + h.n, 15) AS start_min,
             20 + MOD(p.n * 3 + h.n * 5, 26) AS minutes,
             20 * (1 + MOD(p.n * 3 + h.n, 4)) AS stake,
             MOD(p.n * 3 + h.n * 17, 20) AS luck
      FROM (SELECT LEVEL AS n FROM dual CONNECT BY LEVEL <= 40) p,
           (SELECT LEVEL - 1 AS n FROM dual CONNECT BY LEVEL <= 8) h
      WHERE MOD(p.n + 7 * h.n, 8) < 2 + MOD(5 * p.n, 7)
    ),
    night AS (
      SELECT s.player_id, s.hour_no, s.table_id, s.start_min, s.minutes,
             g.min_bet * s.stake AS buy_in,
             CASE WHEN s.luck < 6 THEN g.min_bet * s.stake * (6 + MOD(s.luck, 3)) / 4
                  WHEN s.luck = 6 THEN g.min_bet * s.stake * 3
                  ELSE g.min_bet * s.stake * MOD(s.luck, 4) / 4 END AS cash_out
      FROM seats s JOIN gaming_tables g ON g.table_id = s.table_id
      UNION ALL
      -- Sessions entered by hand: player, hour, table, start minute, minutes, buy_in, cash_out
      SELECT * FROM (VALUES
        (21, 0, 3,   4, 50,  500,  875), (28, 0, 3,   6, 48, 1000, 1500),
        (31, 0, 3,   5, 52,  500,  750), (38, 0, 3,   8, 45,  500,  875),
        (21, 1, 3,  63, 50,  500,  750), (28, 1, 3,  65, 46, 1000, 1750),
        (31, 1, 3,  62, 51,  500,  875), (38, 1, 3,  66, 47,  500,  750),
        (21, 2, 4, 128, 44, 1000, 1500), (28, 2, 4, 125, 50, 1000, 1750),
        (31, 2, 4, 127, 46, 1000, 1750), (38, 2, 4, 126, 48, 1000, 1500)
      ) v (player_id, hour_no, table_id, start_min, minutes, buy_in, cash_out)
    )
    SELECT ROW_NUMBER() OVER (ORDER BY start_min, table_id, player_id),
           player_id,
           table_id,
           -- Dealers rotate every two hours: 1-4 across the blackjack tables, 5-6 across baccarat
           CASE WHEN table_id <= 4 THEN 1 + MOD(table_id + 3 - TRUNC(hour_no / 2), 4)
                WHEN table_id <= 6 THEN 5 + MOD(table_id - 5 + TRUNC(hour_no / 2), 2)
                ELSE table_id END,
           TIMESTAMP '2026-10-25 20:00:00' + NUMTODSINTERVAL(start_min, 'MINUTE'),
           TIMESTAMP '2026-10-25 20:00:00' + NUMTODSINTERVAL(start_min + minutes, 'MINUTE'),
           buy_in,
           cash_out
    FROM night;

    COMMIT;
    </copy>
    ```

    Script Output shows 216 rows inserted. Every `buy_in` and `cash_out` amount in those sessions passed the `chip_amount` check on the way in.

4. The second source is the **chip transfers**, which come from surveillance. When a camera catches one player handing chips to another, surveillance logs who gave, who received, how much and when. Most handoffs are innocent, such as friends sharing chips. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- Load the chip handoffs surveillance logged from the cameras: transfer, from player, to player, amount, time
    DELETE FROM chip_transfers;

    INSERT INTO chip_transfers (transfer_id, from_player_id, to_player_id, amount, transferred_at) VALUES
      (1,  14, 18, 2000, TIMESTAMP '2026-10-25 20:16:00'),
      (2,  17, 20,  750, TIMESTAMP '2026-10-25 20:27:00'),
      (3,  14, 18, 2000, TIMESTAMP '2026-10-25 20:42:00'),
      (4,  17, 20,  750, TIMESTAMP '2026-10-25 20:53:00'),
      (5,  20, 22, 2500, TIMESTAMP '2026-10-25 21:04:00'),
      (6,  17, 20,  750, TIMESTAMP '2026-10-25 21:19:00'),
      (7,  20, 22, 2500, TIMESTAMP '2026-10-25 21:30:00'),
      (8,  23, 24, 1250, TIMESTAMP '2026-10-25 21:41:00'),
      (9,  20, 22, 2500, TIMESTAMP '2026-10-25 21:56:00'),
      (10, 23, 24, 1250, TIMESTAMP '2026-10-25 22:07:00'),
      (11, 23, 24, 1250, TIMESTAMP '2026-10-25 22:33:00'),
      (12, 26, 30, 3000, TIMESTAMP '2026-10-25 22:44:00'),
      (13, 28, 21, 1500, TIMESTAMP '2026-10-25 23:05:00'),
      (14, 26, 30, 3000, TIMESTAMP '2026-10-25 23:10:00'),
      (15, 21, 38, 1500, TIMESTAMP '2026-10-25 23:12:00'),
      (16, 38, 31, 1500, TIMESTAMP '2026-10-25 23:20:00'),
      (17, 29, 32, 1750, TIMESTAMP '2026-10-25 23:21:00'),
      (18, 31, 28, 1500, TIMESTAMP '2026-10-25 23:26:00'),
      (19, 29, 32, 1750, TIMESTAMP '2026-10-25 23:47:00'),
      (20, 32, 34,  500, TIMESTAMP '2026-10-25 23:58:00'),
      (21, 32, 34,  500, TIMESTAMP '2026-10-26 00:24:00'),
      (22, 35, 36, 2250, TIMESTAMP '2026-10-26 00:35:00'),
      (23, 35, 36, 2250, TIMESTAMP '2026-10-26 01:01:00'),
      (24,  2,  6, 1000, TIMESTAMP '2026-10-26 01:12:00'),
      (25, 28, 21, 1000, TIMESTAMP '2026-10-26 01:35:00'),
      (26,  2,  6, 1000, TIMESTAMP '2026-10-26 01:38:00'),
      (27, 21, 38, 1000, TIMESTAMP '2026-10-26 01:41:00'),
      (28, 38, 31, 1000, TIMESTAMP '2026-10-26 01:48:00'),
      (29,  5,  8, 2750, TIMESTAMP '2026-10-26 01:49:00'),
      (30, 31, 28, 1000, TIMESTAMP '2026-10-26 01:56:00'),
      (31,  5,  8, 2750, TIMESTAMP '2026-10-26 02:15:00'),
      (32,  8, 10, 1500, TIMESTAMP '2026-10-26 02:26:00'),
      (33,  8, 10, 1500, TIMESTAMP '2026-10-26 02:52:00'),
      (34, 11, 12,  250, TIMESTAMP '2026-10-26 03:03:00'),
      (35, 11, 12,  250, TIMESTAMP '2026-10-26 03:29:00'),
      (36, 14, 18, 2000, TIMESTAMP '2026-10-26 03:40:00');

    COMMIT;
    </copy>
    ```

5. Check the load by counting the rows in each table. Clear the editor, paste the query, and click **Run Script**.

    ```sql
    <copy>
    -- Count the rows in each casino table
    SELECT 'casino_staff' AS table_name, COUNT(*) AS row_count FROM casino_staff
    UNION ALL SELECT 'players',        COUNT(*) FROM players
    UNION ALL SELECT 'dealers',        COUNT(*) FROM dealers
    UNION ALL SELECT 'gaming_tables',  COUNT(*) FROM gaming_tables
    UNION ALL SELECT 'play_sessions',  COUNT(*) FROM play_sessions
    UNION ALL SELECT 'chip_transfers', COUNT(*) FROM chip_transfers;
    </copy>
    ```

    You should see 5 staff, 40 players, 8 dealers, 8 gaming tables, 216 play sessions and 36 chip transfers. 

    ![Script Output shows the row count for each of the six casino tables after the load.](images/domains-annotations-assertions-03.png " ")

6. In Task 1, you gave `chip_amount` a `DISPLAY` line, a rule for how to show an amount to people. Another domain function, `DOMAIN_DISPLAY`, applies that rule. The rule doesn't change what's stored or what ordinary queries return. The format appears only when you ask for it. Without a shared rule, every report, screen and app formats amounts in its own code, so one might show `$2,500` while another shows `2500.00`.

    Look at three players' credit limits, formatted by the domain. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Show credit limits the way the chip_amount domain formats them
    SELECT full_name,
           loyalty_tier,
           DOMAIN_DISPLAY(credit_limit) AS credit_limit_shown
    FROM players
    WHERE full_name IN ('Pablo Reyes', 'Liam Foster', 'Victor Lang')
    ORDER BY credit_limit;
    </copy>
    ```

    You should see three rows, with credit limits of `$2,500`, `$10,000` and `$50,000`. The dollar sign and commas come from the domain. The column itself still stores plain numbers, such as 2500. Every app that calls `DOMAIN_DISPLAY` shows chip amounts the same way.

## Task 4: Enforce a floor rule with an assertion

1. Every casino has this rule: a dealer can't deal at two tables at the same time. A check constraint can't enforce it, because a check constraint sees one row at a time. This rule compares rows. 

    Before assertions, you had two options:

    * **Application code.** Every app that writes sessions has to create a check.
    * **A trigger.** A trigger checks each session as it's saved, but it can't see a session that another tablet is saving at the same moment. So two tablets can seat the same dealer at two tables, and both saves go through.

    First, follow dealer Grace Liu through the night. Clear the editor, paste the query, and click **Run Statement**.

    ```sql
    <copy>
    -- Follow Grace Liu from table to table
    SELECT g.table_name,
           TO_CHAR(MIN(s.started_at), 'HH24:MI') AS first_seat,
           TO_CHAR(MAX(s.ended_at), 'HH24:MI')   AS last_seat,
           COUNT(*) AS sessions
    FROM play_sessions s
    JOIN dealers d       ON d.dealer_id = s.dealer_id
    JOIN gaming_tables g ON g.table_id = s.table_id
    WHERE d.full_name = 'Grace Liu'
    GROUP BY g.table_name
    ORDER BY MIN(s.started_at);
    </copy>
    ```

    You should see four rows. Grace dealt Blackjack 1 until 21:45, then Blackjack 2 from 22:02 to 23:27. After midnight she moved to Blackjack 3, and at 02:01 to Blackjack 4. Her times never overlap, so today's data follows the rule. Nothing stops a bad row from breaking it, though.

2. An **assertion** is a rule written as a query, and it can span many rows and tables. You state what must always be true, and the database checks it after every statement that changes the data. Nobody has to remember to call it. The database also catches two sessions that would break the rule together, the case that hand-written triggers miss. Use a check constraint when a rule needs only one row, and an assertion when it compares rows. Clear the editor, paste the block, and click **Run Script**.

    ```sql
    <copy>
    -- A dealer can deal at only one table at a time
    CREATE ASSERTION IF NOT EXISTS dealer_one_table_at_a_time
    CHECK (
      NOT EXISTS (
        SELECT 'a dealer at two tables at once'
        FROM play_sessions s1, play_sessions s2
        WHERE s1.dealer_id = s2.dealer_id
        AND s1.table_id <> s2.table_id
        AND s1.started_at < s2.ended_at
        AND s1.ended_at > s2.started_at
      )
    );
    </copy>
    ```

    How the rule reads:

    * The subquery looks for two sessions with the same dealer at different tables.
    * The two time conditions mean those sessions overlap.
    * `NOT EXISTS` says such a pair must never exist.

    Creating the assertion checked all 216 sessions you loaded, and none broke the rule. From now on, every change to `play_sessions` must keep it true.

3. Now a mistake arrives from the casino floor. A clerk's tablet seats Pablo Reyes at Roulette 1 at 23:15, with Grace Liu as the dealer. Grace is still dealing Blackjack 2. This statement should fail. Clear the editor, paste the statement, and click **Run Script**.

    ```sql
    <copy>
    -- Seat Pablo Reyes at Roulette 1 with Grace Liu as the dealer
    INSERT INTO play_sessions (session_id, player_id, table_id, dealer_id,
                               started_at, ended_at, buy_in, cash_out)
    SELECT 999,
           (SELECT player_id FROM players WHERE full_name = 'Pablo Reyes'),
           (SELECT table_id FROM gaming_tables WHERE table_name = 'Roulette 1'),
           (SELECT dealer_id FROM dealers WHERE full_name = 'Grace Liu'),
           TIMESTAMP '2026-10-25 23:15:00',
           TIMESTAMP '2026-10-25 23:45:00',
           200,
           150;
    </copy>
    ```

    **Expected Result:** The insert fails with error ORA-08601, and the message names the assertion `ADMIN.DEALER_ONE_TABLE_AT_A_TIME`. Grace has sessions at Blackjack 2 until 23:27, so a seat at Roulette 1 at 23:15 breaks the rule.

    Without the assertion, this row would have saved, and every report built on it would be wrong. The rule lives in the database, not in the tablet's app. Every app, script and person that writes to `play_sessions` gets the same check. In **Lab 2**, it stops a bad JSON write too.

    ![Script Output shows error ORA-08601 for the rejected insert, naming the DEALER_ONE_TABLE_AT_A_TIME assertion.](images/domains-annotations-assertions-04.png " ")

## Conclusion

You built the Silverleaf Casino floor and loaded a night of play. Along the way, you put four rules in the database instead of in application code.

Because these rules live in the database, every app, script and user gets them without extra code. That includes apps you add later, including an AI agent. In **Lab 2**, the same assertion stops a bad JSON write.

Vera's tip says someone is cheating. Before she digs in on Monday morning in **Lab 3**, **Lab 2** finishes the build. It connects two of the casino's apps to these tables: the website, where players read their own night, and the tablets at the gaming tables, which write every session under the same rules.

You may now **proceed to the next lab**.

## Learn More

* [Application Data Usage](https://docs.oracle.com/en/database/oracle/oracle-database/26/cncpt/application-data-usage.html)
* [CREATE DOMAIN](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/create-domain.html)
* [annotations_clause](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/annotations_clause.html)
* [CREATE ASSERTION](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/create-assertion.html)
* [How to optimize assertion performance](https://blogs.oracle.com/sql/how-to-optimize-assertion-performance)

## Acknowledgements
* **Author** - Killian Lynch, Oracle Database Product Management
* **Last Updated By/Date** - Killian Lynch, October 2026
