# Lab 1: Schema & Data

## Introduction

This lab creates the database objects and seed data used by the rest of the FreeSQL workshop.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:
- Create core relational tables used by the application.
- Seed representative commerce, social, fulfillment, and agent data.
- Validate that downstream labs can run without schema changes.

## Task 1: Create and Seed the Workshop Schema

This task creates the baseline data model the demo relies on. You are building the same core entities used across the app tabs, so every later query has a consistent source of truth.

1. Run the setup script in FreeSQL using **Run Script (F5)**.

    <details>
    ```
    <copy>
BEGIN
  FOR t IN (
    SELECT table_name FROM user_tables
    WHERE table_name IN (
      'AGENT_ACTIONS','INVENTORY','INFLUENCER_CONNECTIONS',
      'SOCIAL_POSTS','INFLUENCERS','ORDER_ITEMS','ORDERS','CUSTOMERS',
      'FULFILLMENT_CENTERS','PRODUCTS','BRANDS'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

CREATE TABLE brands (brand_id NUMBER PRIMARY KEY, brand_name VARCHAR2(60));
CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  brand_id NUMBER REFERENCES brands(brand_id),
  product_name VARCHAR2(120),
  category VARCHAR2(40),
  unit_price NUMBER(10,2)
);
CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(80),
  city VARCHAR2(40),
  state_province VARCHAR2(40),
  latitude NUMBER(10,7),
  longitude NUMBER(11,7),
  location SDO_GEOMETRY
);
CREATE TABLE influencers (influencer_id NUMBER PRIMARY KEY, handle VARCHAR2(80));
CREATE TABLE social_posts (
  post_id NUMBER PRIMARY KEY,
  influencer_id NUMBER REFERENCES influencers(influencer_id),
  post_text CLOB,
  posted_at TIMESTAMP,
  likes_count NUMBER,
  shares_count NUMBER,
  views_count NUMBER,
  virality_score NUMBER(5,2),
  momentum_flag VARCHAR2(20)
);
CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_status VARCHAR2(20),
  order_total NUMBER(10,2),
  social_source_id NUMBER,
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);
CREATE TABLE order_items (
  item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER,
  line_total NUMBER(10,2)
);
CREATE TABLE fulfillment_centers (
  center_id NUMBER PRIMARY KEY,
  center_name VARCHAR2(80),
  city VARCHAR2(40),
  state_province VARCHAR2(40),
  latitude NUMBER(10,7),
  longitude NUMBER(11,7),
  location SDO_GEOMETRY,
  is_active NUMBER(1)
);
CREATE TABLE inventory (
  inventory_id NUMBER PRIMARY KEY,
  center_id NUMBER REFERENCES fulfillment_centers(center_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity_on_hand NUMBER,
  quantity_reserved NUMBER
);
CREATE TABLE influencer_connections (
  from_influencer NUMBER REFERENCES influencers(influencer_id),
  to_influencer NUMBER REFERENCES influencers(influencer_id),
  connection_type VARCHAR2(30),
  strength NUMBER(4,3),
  CONSTRAINT influencer_connections_pk PRIMARY KEY (from_influencer,to_influencer)
);
CREATE TABLE agent_actions (
  action_id NUMBER PRIMARY KEY,
  agent_name VARCHAR2(50),
  action_type VARCHAR2(60),
  execution_status VARCHAR2(20),
  confidence NUMBER(4,3),
  executed_at TIMESTAMP
);

INSERT ALL
  INTO brands VALUES (1,'UrbanPulse')
  INTO brands VALUES (2,'TechNova')
  INTO brands VALUES (3,'PeakForm')
  INTO brands VALUES (4,'TrailBlaze')
SELECT 1 FROM dual;

INSERT ALL
  INTO products VALUES (101,1,'Neon Grid Hoodie','Fashion',89.99)
  INTO products VALUES (102,2,'AirBud Elite TWS','Electronics',199.99)
  INTO products VALUES (103,2,'NovaWatch Ultra','Electronics',449.99)
  INTO products VALUES (104,3,'FlexBand Pro Set','Fitness',49.99)
  INTO products VALUES (105,3,'Yoga Mat Premium','Fitness',89.99)
  INTO products VALUES (106,4,'Summit 65L Backpack','Outdoor',229.99)
  INTO products VALUES (107,4,'AllTerrain Hiking Boots','Outdoor',189.99)
SELECT 1 FROM dual;

INSERT ALL
  INTO customers VALUES (1,'Mia Brooks','Miami','Florida',25.7617,-80.1918,NULL)
  INTO customers VALUES (2,'Liam Carter','Austin','Texas',30.2672,-97.7431,NULL)
  INTO customers VALUES (3,'Sofia Nguyen','Seattle','Washington',47.6062,-122.3321,NULL)
  INTO customers VALUES (4,'Noah Patel','Denver','Colorado',39.7392,-104.9903,NULL)
SELECT 1 FROM dual;

INSERT ALL
  INTO influencers VALUES (301,'@fashionista_sarah')
  INTO influencers VALUES (302,'@techwithmark')
  INTO influencers VALUES (303,'@fitmaya')
  INTO influencers VALUES (304,'@trailkai')
SELECT 1 FROM dual;

INSERT ALL
  INTO social_posts VALUES (2001,301,'Neon Grid Hoodie is trending again',SYSTIMESTAMP-INTERVAL '48' HOUR,32000,5200,540000,88.2,'viral')
  INTO social_posts VALUES (2002,302,'AirBud Elite TWS review after one month',SYSTIMESTAMP-INTERVAL '36' HOUR,12000,2100,180000,74.9,'rising')
  INTO social_posts VALUES (2003,303,'FlexBand Pro Set works for hotel workouts',SYSTIMESTAMP-INTERVAL '24' HOUR,9100,1200,99000,67.3,'rising')
  INTO social_posts VALUES (2004,304,'Summit 65L Backpack survived heavy rain',SYSTIMESTAMP-INTERVAL '18' HOUR,7600,950,82000,61.8,'normal')
SELECT 1 FROM dual;

INSERT ALL
  INTO orders VALUES (1001,1,'delivered',289.98,2001,SYSTIMESTAMP-INTERVAL '6' DAY)
  INTO orders VALUES (1002,2,'shipped',249.98,NULL,SYSTIMESTAMP-INTERVAL '5' DAY)
  INTO orders VALUES (1003,3,'delivered',189.99,2002,SYSTIMESTAMP-INTERVAL '4' DAY)
  INTO orders VALUES (1004,4,'processing',279.98,NULL,SYSTIMESTAMP-INTERVAL '3' DAY)
SELECT 1 FROM dual;

INSERT ALL
  INTO order_items VALUES (1,1001,101,2,179.98)
  INTO order_items VALUES (2,1001,104,1,49.99)
  INTO order_items VALUES (3,1002,102,1,199.99)
  INTO order_items VALUES (4,1002,104,1,49.99)
  INTO order_items VALUES (5,1003,107,1,189.99)
  INTO order_items VALUES (6,1004,106,1,229.99)
  INTO order_items VALUES (7,1004,105,1,49.99)
SELECT 1 FROM dual;

INSERT ALL
  INTO fulfillment_centers VALUES (401,'West Hub','Los Angeles','California',34.0522,-118.2437,NULL,1)
  INTO fulfillment_centers VALUES (402,'Central Hub','Dallas','Texas',32.7767,-96.7970,NULL,1)
  INTO fulfillment_centers VALUES (403,'East Hub','Newark','New Jersey',40.7357,-74.1724,NULL,1)
SELECT 1 FROM dual;

INSERT ALL
  INTO inventory VALUES (5001,401,101,120,10)
  INTO inventory VALUES (5002,401,102,70,5)
  INTO inventory VALUES (5003,402,103,80,4)
  INTO inventory VALUES (5004,402,104,140,12)
  INTO inventory VALUES (5005,403,106,45,3)
  INTO inventory VALUES (5006,403,107,65,5)
SELECT 1 FROM dual;

INSERT ALL
  INTO influencer_connections VALUES (301,302,'follows',0.780)
  INTO influencer_connections VALUES (302,303,'collaborates',0.740)
  INTO influencer_connections VALUES (303,304,'follows',0.690)
  INTO influencer_connections VALUES (304,301,'tagged',0.660)
SELECT 1 FROM dual;

INSERT ALL
  INTO agent_actions VALUES (9001,'TrendAgent','detect_trending_products','completed',0.942,SYSTIMESTAMP-INTERVAL '8' HOUR)
  INTO agent_actions VALUES (9002,'FulfillmentAgent','route_order','completed',0.903,SYSTIMESTAMP-INTERVAL '6' HOUR)
  INTO agent_actions VALUES (9003,'InventoryAgent','check_stock_risk','review',0.712,SYSTIMESTAMP-INTERVAL '5' HOUR)
  INTO agent_actions VALUES (9004,'RiskAgent','flag_anomaly','failed',0.441,SYSTIMESTAMP-INTERVAL '2' HOUR)
SELECT 1 FROM dual;

UPDATE customers
SET location = SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(longitude,latitude,NULL),NULL,NULL)
WHERE longitude IS NOT NULL;

UPDATE fulfillment_centers
SET location = SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(longitude,latitude,NULL),NULL,NULL)
WHERE longitude IS NOT NULL;


COMMIT;
    </copy>
    ```
    </details>

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F81ZW3OqShZ%252Bz6%252FoN7SK7ZGLopU6VQeVJM6oWIA7kyeqg61SIp2BJtmZ2j9%252BVjcCakRNnYeZB0lDr%252F76W5dea0EG1uN4dofQg%252B0ghsYz1IAbhFxrYg09xPBrRPwY7wh6cOwpylKS%252BOJhKsSenyzHOpQqARCSzEdr5vnm0BvbM1eSpfHsJzywnRcxfpgsrNnQcvyhPZtZhVCx1rWHY3Piz23Xc4%252FE%252BZ3tjGDd2LOm5R0fDBeuZ0%252FFuIB5WEwexpPJlBMZwiUXnDv2aDEUwAPHnI1cScg34dpEE9uei1vrX9Zw4VloPJ1ao7EJI2nk2HPkmYMJjH%252F%252FZq1K8d%252B%252FJTQ03aE5shAo5HqOOZ55LpovnEdLugdAazYS2Pd3MLq%252F%252B%252BPubuhYHDXHe01wvExRQ%252Fz1wyWaLaYDy0FzZzw1nRf0T%252BtFzoVyQ%252F80neGT6aiNbrvZvD%252FGekvoMgtYKlyxv6mBBIHTHR3rAZwKtnb3pEpOTfkA75iForbFbIAZWdPks5rR84ksDpn%252FloQB2e%252FTUNqy2rw75R5kKaM7kuTki7t69qXEMZ%252Fenk7IvlJJGZAELvQ9jAPyZTrCLGTZ8pCnkU%252FQeH08o5QzoHdIY%252BSObP%252FRgiD0nJcvqoXxKsoIbMmVq27qnL0Bo0fHKp0ipjQIceS%252F0bRwNozqbXV2zwN3HxA85pc7nmMz8ouh4cQeFE%252FI0scMeeOp5XrmdC6sEW5J6gc0i9l%252BE2H1DU7OPH4Pyce5pwmOwHd%252BGtCktHcHAobP7sDhMct2%252FirC68pAEIJfbE6TZRFLYnhDIJ01TRmWjQM5QSaH5TGVpUdcqklGGY6Owl4YJHdeSrMkINWugktC8Kll0ch6MBcTD7kvbvnwvL5%252ByMguV5qP6nU%252BNcmBwrnhGoXE0dE%252Fu6BIOo1KSiz6d4Zjxo9hpV4UxuSMUb4os8qiVRhF3Nl%252BAJcyK4jxBVfm8%252F93GUGcwdTHAQvfqyXNM4niHTTgWVS4sLi7qvBZv5wxYqOU%252F%252Ftu9Wns80x14N5yCs47Sd5JMXchIUICiGMScIvlLl4lFOK2nP92smL076yu2Pjs8%252B0gILQiXhISr9mm8KEua%252BJ5VflrdPPftoe%252BQ40TPeUj3l8jA6%252B5G%252FGBofJxfWjkK46PQifXAp%252FTsJvPkV8kyMR0TWYDpVbhktM8NUK%252B9CR7cU3uxjPXcjxkTiYgBkayi67npwndnYsaiiwtklccz7MoJVKzRkqVJY8Emxl9x7UyGnR5BG8faLKrldEBJ8FhNIjwf%252Fhu%252B55XyVvdZYajs5zL7qpk3VZkYD4jcNwfE%252FDEE6XLkEB3%252BYDTDdhQknv9Vr%252FfvICgyqCVGSaDbIksqHwEec%252B8P7UiiJyExmGQSrLSvwajcRhumGfMgg1aRCzBpyi6fg0FPAncI%252FJrwA%252F2PKHIJYyrE7KYpBziGkKHI7zQNUZTiIJ5QnZhtjtEuGqQrgzucbPdLmSo25mgAQ62b%252FDjDX%252FGlpQmkqyq11AMjmJGkUcS8HSMnsJtGK%252FRgFKWHiIpez43hkDVpB5E7jTEaJBQuuXIcLMLucIRhYgAH6idltFVDPlHr91S%252BkpPni0mk2Y9IPhxAhhoiBNI1YBkgkgIoQSx%252FwvDFlq7pXYNVf7RN1qGrinXAMEhLl0Bx9k6%252ByQcyIUmg0U8Tp95nEJC46GqG61uuwu4iqq2NE29CqzziMMbNIcaGgHYiEDB4oyHFJTHSwpc%252By1D63PMtg52hjDNMW8092HjXKoDh076a5UfsBCSlJ%252FiBG%252Bqw35%252BEZj1LwbJ4yNkmx1OttfkNb5JyHb4E18T1Tk0zydbHN6eTY5a%252BNL5bdBOaHiaVKB%252FQLz4LHkY4zXmEXHYEP4Y85dcwEGS3pPQk71wZA3g2nJH5Re9zce9XgsMIZrsSqs6JqoszHaanFBCeO%252BO8AriE9GYQFses00tHa27p6MIOqoCF6Un6BgQFLKUhCkodZ2PJgu3nOYn9EGTbYpWNEEbCpEo7mnGz3kNI1XfM%252BoLLtw%252BEJtw7Rot7XY%252BkC3b53MVSrPkPeQN0Ibg90%252BUXHKXUrjL6HIiHfCSMFRXafVkKYZCJpx1Y1jt33uqTJjXqCWJgE9ClpCQeMrrySLUaiiBx0bmS7MeU1QtOIFvbwJRF4j8aNchdq4harxwHLDME7MswrAuzq9h6rwIQHEIoPJwj8qqcZWotgf9jrn3r11VScitDj9VVsSWzUvyaiGvg6eOK%252Bw5cU0WDuCtg3LaGZyT1wv52%252BA7svAGL6FKWR4vyHdlYWleuJXTwnxO3ijkOxWdG4197rWw1JInzWeSMvSUvUINmtAUmfGaRIRX5SGOQkgQcQgFWdNb7Y7Ka5IC2VDXjDwelOZt20DgD%252BEhZND9TiMcRbwul%252FVZbRlGFwp%252Bv9sy%252Bkb7e%252FBwCixcajEjH7xWiQH6B0iSTyjUbSiqHdgA0qdiqHq5wc1VtXjLLH3O40%252FfxyzkQ%252FjbvCit7qVVGfTrXJbVZF2Enyb32rJ%252BWVbfy0J86DwzX5buyLqIVGgZoe%252B8LNvdyxpyt8MZf7sDOXpTPWxGRJFc0SiiH%252BB98E2v3bx5uZrXtACW41domhjJMfRvYGh5HTqg0O1%252FY7meNxwMr9c88cJqeBW81T7H76UFaJ%252FHE7xjQbticgGJp3bovphftDB%252B0bNLXPndWwTTYvO%252BXpvv93WyeXVv8MdDdcgKBgn0BMQXKenLpmDD%252BlJ426bgxXEReMWWwYYEW3iRpnCFroIf5Lx5Ej5W1AvV8rZNwe0O4Bb78c%252BiPo4pdAyf%252FBZ60lxBXa%252Bt9Wqx11mPL%252BYj%252FhGibP5Byqu%252Bcf159JUr7151Te3K%252FPHchk1872VuNcrPZXLxRS1%252FD8gzV%252F5KkP9HqfqwNnbRzPYQn6x4nMmd%252FytGd0N7Oh179%252F8Fqn76YkgbAAA%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Confirm the script completes successfully before continuing.


## Task 2: Validate Core Table Readiness

This validation step confirms your core tables are populated before you move forward. Catching gaps here prevents confusing failures in later dashboard, graph, fulfillment, and orders tasks.

1. Run this validation SQL.

    ```
    <copy>
    SELECT 'BRANDS' AS table_name, COUNT(*) AS rows_count FROM brands
    UNION ALL
    SELECT 'PRODUCTS', COUNT(*) FROM products
    UNION ALL
    SELECT 'CUSTOMERS', COUNT(*) FROM customers
    UNION ALL
    SELECT 'ORDERS', COUNT(*) FROM orders
    UNION ALL
    SELECT 'SOCIAL_POSTS', COUNT(*) FROM social_posts
    UNION ALL
    SELECT 'INFLUENCER_CONNECTIONS', COUNT(*) FROM influencer_connections
    UNION ALL
    SELECT 'AGENT_ACTIONS', COUNT(*) FROM agent_actions
    ORDER BY table_name;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F32RzYrDIBRG9%252FMUd5dpmTeYlTW2BKwWfxazEmvsEEi1qGFev2mgEGjH5f245%252FBxLwCAJJRgBc1OINbKBpCEYs%252BjN8Fe%252FRdgrpn63G4eeYp%252F2bg4hQJ7wY9wTjb0%252BWOWgGYdZ4AoXaan8yR4q7GSzcqzkLcU%252B8mVGou1VPxIxCvsplzi1acazUX7Do2pr3OS4w5Rc%252BLyTesc3WBHc4u52rxje6oJw0QYzBmbs3nr1TaEyzj54HyabxqCd2WIoeZFB8KUQf%252Fo7K8PxdiVZbkB7H5W%252F%252Fy%252BA%252F5fYDryAQAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Confirm each table returns non-zero rows.

## Task 3: Validate Join Paths Used in the App

This query validates the join paths used by demo analytics. It shows how products, brands, and order lines combine to power revenue views in the application.

1. Run this SQL to validate product and brand revenue rollups.

    ```
    <copy>
    SELECT p.product_name,
           b.brand_name,
           COUNT(oi.item_id) AS lines_sold,
           ROUND(SUM(oi.line_total), 2) AS revenue
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN brands b ON b.brand_id = p.brand_id
    GROUP BY p.product_name, b.brand_name
    ORDER BY revenue DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F2WQQW%252FCIBiG7%252FsV77Emppm7Lh62ljoXLQbamJ5IKxxIammg%252BvsH6KZObh88L9%252FzfQDAyYZkFcZ0tEaeDpMY2qOav%252BB2urSz7SCfHzJal1VidKondRRazvDB0etBOeFMLx9Y5tk84fU28IERk5nafjbHW4xZdVbDScVIwegWxkplRfjZweh4%252F03XJa6aDiNoeaetJZYevKtvmejv0IXE7zSRH%252F%252BKCK%252B85Q6fzf9tPKwgkpTlhAXy6o2c8OwiT6rsC8Wa8QqLVz%252F3nvu2m%252Bb9B34s4u1tAQAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Record the top 3 products by revenue.

## Task 4: Check Your Understanding

Use this quick checkpoint to confirm you understand why setup quality matters. A clean schema start is what makes every later lab deterministic.

```quiz
Q: Why run schema and seed SQL before downstream analytics labs?
* It guarantees all downstream queries run against known tables and data.
- It improves dashboard styling.
- It removes the need for joins.
> Correct. The setup step prevents avoidable runtime errors in later labs.

Q: Why validate core table row counts after seeding?
* Later dashboard, graph, fulfillment, and orders queries depend on ready core tables.
- Table row counts are only useful for UI styling.
- Validation can be skipped when inserts complete.
> Correct. Core table readiness prevents downstream query failures and debugging churn.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
