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

1. Run the setup script in FreeSQL using **Run Script (F5)**.

    ```
    <copy>
BEGIN
  FOR t IN (
    SELECT table_name FROM user_tables
    WHERE table_name IN (
      'PRODUCT_EMBEDDINGS','AGENT_ACTIONS','INVENTORY','INFLUENCER_CONNECTIONS',
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


-- Ensure the embedding model exists before creating PRODUCT_EMBEDDINGS
DECLARE
  l_model_count NUMBER;
  l_model_uri   CONSTANT VARCHAR2(1000) := 'https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/iPX9W0MZeRkwJKWdFmdJCemmN-iKAl_bFvNGYLW7YqIrw4kKsukL24J2q93Beb9S/n/adwc4pm/b/OML-ai-models/o/all_MiniLM_L12_v2.onnx';
BEGIN
  SELECT COUNT(*)
  INTO l_model_count
  FROM user_mining_models
  WHERE model_name = 'ALL_MINILM_L12_V2';

  IF l_model_count = 0 THEN
    DBMS_VECTOR.LOAD_ONNX_MODEL_CLOUD(
      model_name => 'ALL_MINILM_L12_V2',
      credential => NULL,
      uri        => l_model_uri,
      metadata   => JSON('{"function":"embedding","embeddingOutput":"embedding","input":{"input":["DATA"]}}')
    );
  END IF;
END;
/

COMMIT;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F81ZWXPiSBJ%252B96%252Bo8AuwITA6uNoxGyNA2HQLiZBEu70bG4oCCtAiJFqHj52e%252F75ZpQOBuRzzsNsRjUuqrC%252FPyswqdZWHoXaD0EA3UISGGirDA0Kmoio9C0V46hLbwxuCBoY%252BQnFIApu9DBnZ06NiKEWqHACh0tjQ%252B5OeZSujrtLvD7UHs8SV5AdFs2y5Zw11jT4Pte%252FwQjee2XigThStpxh2T9c0JSPKAE29N5RVe6yblrlHTp90ow%252FrhpYyyp%252FooDcxLX3ExhnMYKIOhqo6ooL04CchTKWlw64ha32zxOgr8FtBqq6P2aPyQ%252BlNLAUNRyOlP5RhVOob%252BhhZcleF8a9fUW1njV%252B%252FSqgnmz25ryBQyLQMeahZJhpPjAeldA%252BAitZn2Pc3MLq%252Fubu56RkKRU3wpgH25iEqs7%252B2M0faBGxpoLExHMnGM%252FqmPHMJUWL977LRe5QNodysVyr3%252B1jbwJ%252FHsyhk%252FkkfTkACwSFHQxmAp8HWZipULlOFK%252BDtS8ELdTY7wxFZ%252BsH7bkZKJmLPiext4MxIyqfM1zmhcnMo%252BywOI39DgkT47Om09DnFvjztVBwn%252BihKGIGQIIv%252F4ngz8mHaxZETxfOinK1kwveW%252BzN8PgN6O76HzL5uPygQhJbx%252FEE1x1u4MQGWVLndwylnr8Do7r5Kh4ihP3Owa2%252F9MHM2jE7b6ijPgrsLAu7LlzieYkfkLUI9Ve9mb8jcxhGyhiPFtOTRmFnDWZPQnvmxF6VMmNVXODjy%252BsUhr8feBtgF39nhzA9yezcgYOjsBhzuRfHGXrh4uTMQhOAHm%252FvBPIslNrwikI6aJg%252FLcoGOCZPA0piKwz1ZdpORH2F3L%252ByZQRLnhX4czMiOK5MlIPjQsqivDOSJaiHz2cxfHtfXdiKySZSmo9M6H5qkoHBiuHJGsbf1jy7Ikk55R8UW%252FYyxF9FtuFPPdTxyxCgflFnE7sJxXepsewY%252FeVZg4zOuTOb%252F7zIC24OhjWeR87JbUjmSKF5AA5pFmQuzp4sKH%252FXLESOWc%252Fq%252F7lbb92yaqQruzadgv5PghWRzZxIiJADPIzNqscTFi8CHuM3nP52sIv%252BvrN5JY0fv20JAiFm8BMRbRqvMhxInsve7yn9CN3u7LvoOlQ%252F05Pbk%252FhgZeEndiAuGSsanQyNZsb8VGokW%252BJiGzWSOvJFZzKZPZDZQauHMqZiHRkiWHmQvqsnNUDMVw0KyqgIZGEnPup7vMnR3JirzXGkSTLE3jt2QlConqASuZJHZSvNf8EkaEbo8gtcDP9icpJEAJ8CO23Xxfyi3tBHmk%252F53HmP3qMx5d5VLXec5kFwjsN0fAvDEo%252B%252FPHQLd5QCHK7BhiWt3ap1O5QyCwIFWshN04zlSoPIRZD3R%252FlRxIXIC33NmYYnjO5dgRApDDfOEo9kKTdwowIcoknQJBTwJsrvkrUs39jjwkUkiqo4TeSSkEJcQGhTh2V9iNIIoGAdk48SbIsJFgzQ5cI8ZbzZOhJoNFXXxbL2F%252F7Thj6O57wclThAuobQoiuy6FgnA0x56dNaOt0Rd34%252FCIhKfynNlCOya1ELkjhyMuoHvrykyPGwcqrDrQ0SAD4RGrdXkW1y1Xa%252FxHb7NaRNVrZwGBD%252BqgIF6OIBUTU9TQOJAKEHsv2FgIdZrQrMlcNVOq9aSRP4SIDjE9Bcgo7aM3wkFMqHJiFwap080TiGh0VCVWrVmvQm4vCDURFG4CCzRiMMrNIYa6gJYn0DBohL3fFAez32QtVNriR2KWZfAzhCmCeaV5i42zrk6sOlKvy%252BSDeZAkrJDHODVbrMfXwRm%252FT2C5PHqRKsNDtaX6EXKxIk2%252BB1fIpUoNM0na%252Bxcn032Wvjc%252BXXQjml4mFSgf0C0%252BMxpGOMlphFRbAirQ3rIBRxUktol9KhPDE4EuDrXEOiPVKfjdrsGhmBN9k6rU5IIHDPbYXJCAaG9O8ILiE%252FkewTaci9anRRHbKbi8EwcgYcfvs3EaUFQcKXACUGpy%252FKIHHPLYX5Cr36wDtHCD9DKh0hkz35M9%252FkJiQQplajDZKH2gdiE32arJl4vD2TL%252BvFchcI4eHFoA7Qi%252BOUdBefcxWfuajWpIA3wEjNUk6%252B1uZIHhYw568qwSs89u0yY1Kg5cUGegMwhIdGU1%252BZYqJ0QCTzWl58rpzFZ1YIduN0yRIkh0q19CrFxCVGkhaMgZZKYORaGp%252BL8EqZEiwAUhxlUHupRTmhdFFRMQT9j7vTYtSsJidXhv8DxjGXlHL2Q0Uvgqf0Ke4xc5JgDaOvAH3YGx%252BiljP46%252BAbHvEFLKJ%252BXxzP0TY5ZmhZu%252FrAwH6NvZfSNnThXGvvYsTDXkibNJxJG6DGeQg1S%252FRDJ3pK4hFblHnYdSBCeAwVZlGr1hkBrEg%252FZUBJbSTzwlevYQOD34CVk0JRTH7surct5fRZqrVYTCn6nWWt1WvXPwcMuUHCuhUZeaa1iA%252FQVKMk7FOo6FNUGMID0ybcEKWdwdVXNTpm5z2n8SWnMQj6Ev5Wz1EJKLXCgX%252BM8rchJLPxErl3npPO0UkoL8SHRzHyeusFJLFKhZYS%252B8zxtM6Vtcc0GlfjTHcjeSbXYjLAiufBd138F74Nv2vXK1cuFpKbNYDmeQtMUkQRD%252BgSGmNShggjNzieWS0nDEeHlkiZeWA1HwWvts38uzUA7NJ7gjAXtikwJSjS1Q%252FcV2VkLY2c9e4kqv9m6MM2Yd6ST%252BT6tk5WLvMEfg90myyQIoCcgNktJH5iCDU%252BXwuuYgheHWeBlLGcrMlvDQdqHX%252Bgq6EZOmifmY144Uy2vYwpuNwA340evRW3s%252BdAxvNNH6EkTBSXpZK0XMl5HPT4Z9%252BklRN78A5W1u%252BP6be%252BWK%252BleJVFocvT1WAcmtvU8Vsr5dRmX3agl54AkcyVHguQz0%252B5ibWgiTbcQndzJcSR3%252Fq8kuqlWkeJBo0dQtCKIbKZkzprzjQ9tDCJvDm0Xp2RB77HZvS6d%252FPi97Kav9FTZUOjdoc3W7l2K3xfex4GD0rsmWbMK32CgXaygL7%252Bh0iqKtuGXuzs8f51J203Nn%252F4bdh34LoAQqsVhFY5N0zjwqnwNmtpa5tYqe%252FA3d9s7Z%252Fyj81Qf%252FYMY69ev357mg838a49sNlrV%252BSa79nTwoj08q0%252Bt55%252FD4FVafwvjtSpIX4WfHbFLph3zzsuY303v9JFaxU6VSR%252Fe%252BXdQKe2R4znqyFZ5wX4RapCR3kr3N930C2Uagz19olnlv%252BXxv2cY%252BiEz%252F065ATTIJgmHm%252BxjZULN7r7AKJCu7NFQG6ZcvwvAkCIPDgz%252BG6oj61HR2EfAfndk2t9BGN2oqbrct3VN%252B2GP9L6i2j1Vn%252FSzT6BFXn8%252Fxiz7JgkxMIeQhaMEJWRxls4kfmX%252FYKbg7YxgQyI8xxFOCL6aulYu%252FXG7iD2WEW6%252F3ObRd8vtxnocbePoYNbx2Ls%252FssE%252Fb2Fjybf%252F%252BvNPduBBqJJ9sxwOCl8s9dFoaN3%252FFyrSJ%252FxJHgAA&code_language=PL_SQL&code_format=false"
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


## Task 2: Create PRODUCT_EMBEDDINGS

1. Run this SQL in FreeSQL using **Run Script (F5)**.

    ```
    <copy>
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE product_embeddings CASCADE CONSTRAINTS PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE product_embeddings AS
SELECT p.product_id,
       VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING p.product_name||' '||p.category AS DATA) AS embedding
FROM products p;

ALTER TABLE product_embeddings ADD CONSTRAINT product_embeddings_pk PRIMARY KEY (product_id);
ALTER TABLE product_embeddings ADD CONSTRAINT product_embeddings_fk FOREIGN KEY (product_id) REFERENCES products(product_id);

COMMIT;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F6VQTW%252FCMAy951d4p4K0Ma3aZap2CIlbouWjJIHBqWK0QwgBFbDDpP74pUgwpn1c5oNl%252BdnvPbuPmdAEACfIRh5BKIVc0FBF3JocPO1LhHq3Ld%252Fmh6Jav1Rludws9sCoY5QjMKOdt1Ro7yAf2QyjhOCEYe6FaYmfB6jB%252BAFaByG3LQCRghtKZsL%252B1SPcPNzHRwwCj8MEUPMwEng0T8gtIcxi6%252BhXL9QRhxKZh7p3gpfl9VEqxDggxhao%252Bsi50FmHSlkooYVUhbyLi3EMIxf6F9ub2bpqmgiipql789mhWmx370EHOPW02xZneZJao06u9lAnhFDp0f5hl%252FOLt%252F0wUdQryK1Q1E7hCafQ%252BTyqm%252Fyf%252FXUFqbEoMv2NHSymaFEzdOeTvqoTZpQSPvkA%252BmiGyDkCAAA%253D&code_language=PL_SQL&code_format=false"
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

## Task 3: Validate Core Table Readiness

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
    SELECT 'PRODUCT_EMBEDDINGS', COUNT(*) FROM product_embeddings
    UNION ALL
    SELECT 'AGENT_ACTIONS', COUNT(*) FROM agent_actions
    ORDER BY table_name;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F42SwWrEIBCG7%252FsUc0tbuk%252FQkzHuEkh0UXPoSYzaJZDoooa%252BftNAIbC7occZ5vv4%252BRkAAEEagiUUJUe0EgUgAVn3o1NeT%252B4dMOuofHl7%252Fd3H8J2UCbPPcOKshT5qb9NhkUBHa0YBNc06%252FTkvnFUdlqLYeFbyFoOdTd5jcSckawm%252Fh82ccphc3KMZrx6hIdp9TjBco0ZdmHiQOgUz6FHdQtpNXtNT0xGKCVeYUbrslqt72%252BC%252Fxtl54%252BLSqffO5CH4f7SpSFuSqqrp%252BWmvyk29s3bw1z0fOhMqFXoST1%252Bdz0pvUq2dQvm5%252BY%252BPw%252FFIGP4BouMcBEgCAAA%253D&code_language=SQL&code_format=false"
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

## Task 4: Validate Join Paths Used in the App

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
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F2WQzW4CIRRG9z7Ft9REJ9pt46JlsNro0MAYMysyU1iQjMMExj6%252FQG39Y3fhfNxzLwAIuqWkRJ%252F1zqrT9yC7%252BqinI1xPkzWu7tTzA2H7ohxbk5lBH6VRE7wJtKbTXnrbqjuWBzYfi%252F0u8pGRgx3qdjLFS4o5%252FaO7k06RFWc7WKe0k%252FFnD2vS%252FSfbFLhoevRgxY22UVgG8Ka%252BZpK%252FRxMTf9Mkvv8vEvwRLL%252FwXj1u424FiWQ8pzySF2%252FkVJBfeVqSNVYbLkos5mHugwhtt9XraDajjJwBrHZgfXMBAAA%253D&code_language=SQL&code_format=false"
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

## Task 5: Check Your Understanding

```quiz
Q: Why run schema and seed SQL before KPI or vector labs?
* It guarantees all downstream queries run against known tables and data.
- It improves dashboard styling.
- It removes the need for joins.
> Correct. The setup step prevents avoidable runtime errors in later labs.

Q: Why include product_embeddings in the seed workflow?
* Later vector retrieval depends on a ready embedding table.
- Embeddings are only used for UI themes.
- Embeddings replace relational keys.
> Correct. Lab 3 depends on product_embeddings being present and populated.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
