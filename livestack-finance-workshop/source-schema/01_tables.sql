/*
 * 01_tables.sql
 * Core relational tables for Finance-Aware Client Service
 * Oracle AI Database 26ai Free
 *
 * Run as: ADMIN or a dedicated schema owner (e.g., LIVESTACK)
 */

-- ============================================================
-- BRANDS
-- ============================================================
CREATE TABLE brands (
    brand_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_name        VARCHAR2(200)  NOT NULL,
    brand_slug        VARCHAR2(100)  NOT NULL UNIQUE,
    brand_category    VARCHAR2(100),
    headquarters_city VARCHAR2(100),
    headquarters_lat  NUMBER(10,7),
    headquarters_lon  NUMBER(11,7),
    founded_year      NUMBER(4),
    annual_revenue    NUMBER(15,2),
    social_tier       VARCHAR2(20) DEFAULT 'standard'
                      CHECK (social_tier IN ('emerging','standard','premium','luxury')),
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE products (
    product_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_id          NUMBER NOT NULL REFERENCES brands(brand_id),
    sku               VARCHAR2(50)  NOT NULL UNIQUE,
    product_name      VARCHAR2(300) NOT NULL,
    description       CLOB,
    category          VARCHAR2(100),
    subcategory       VARCHAR2(100),
    unit_price        NUMBER(10,2)  NOT NULL,
    unit_cost         NUMBER(10,2),
    weight_kg         NUMBER(8,3),
    is_active         NUMBER(1) DEFAULT 1,
    launch_date       DATE,
    tags              VARCHAR2(1000),  -- comma-separated for simple querying
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at        TIMESTAMP DEFAULT SYSTIMESTAMP
) INMEMORY MEMCOMPRESS FOR QUERY HIGH;

CREATE INDEX idx_products_brand    ON products(brand_id);
CREATE INDEX idx_products_category ON products(category, subcategory);
CREATE INDEX idx_products_active   ON products(is_active);

-- ============================================================
-- FULFILLMENT CENTERS (warehouses / drop-ship locations)
-- ============================================================
CREATE TABLE fulfillment_centers (
    center_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    center_name       VARCHAR2(200)  NOT NULL,
    center_type       VARCHAR2(30)   DEFAULT 'warehouse'
                      CHECK (center_type IN ('warehouse','distribution','micro','drop_ship','store')),
    address_line1     VARCHAR2(300),
    city              VARCHAR2(100),
    state_province    VARCHAR2(100),
    postal_code       VARCHAR2(20),
    country           VARCHAR2(3) DEFAULT 'US',
    latitude          NUMBER(10,7) NOT NULL,
    longitude         NUMBER(11,7) NOT NULL,
    capacity_units    NUMBER(10) DEFAULT 100000,
    current_load_pct  NUMBER(5,2) DEFAULT 0,
    is_active         NUMBER(1) DEFAULT 1,
    operating_hours   VARCHAR2(50) DEFAULT '06:00-22:00',
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- ============================================================
-- INVENTORY (product capacity at each branch service center)
-- ============================================================
CREATE TABLE inventory (
    inventory_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id        NUMBER NOT NULL REFERENCES products(product_id),
    center_id         NUMBER NOT NULL REFERENCES fulfillment_centers(center_id),
    quantity_on_hand  NUMBER(10) DEFAULT 0,
    quantity_reserved NUMBER(10) DEFAULT 0,
    quantity_incoming NUMBER(10) DEFAULT 0,
    reorder_point     NUMBER(10) DEFAULT 50,
    reorder_qty       NUMBER(10) DEFAULT 200,
    last_restock_date DATE,
    updated_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT uq_inventory UNIQUE (product_id, center_id)
);

CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_center  ON inventory(center_id);

-- ============================================================
-- CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    customer_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email             VARCHAR2(300)  NOT NULL UNIQUE,
    first_name        VARCHAR2(100),
    last_name         VARCHAR2(100),
    city              VARCHAR2(100),
    state_province    VARCHAR2(100),
    postal_code       VARCHAR2(20),
    country           VARCHAR2(3) DEFAULT 'US',
    latitude          NUMBER(10,7),
    longitude         NUMBER(11,7),
    location          SDO_GEOMETRY,
    customer_tier     VARCHAR2(20) DEFAULT 'standard'
                      CHECK (customer_tier IN ('new','standard','preferred','vip')),
    lifetime_value    NUMBER(12,2) DEFAULT 0,
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- ============================================================
-- ORDERS
-- ============================================================
CREATE TABLE orders (
    order_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id       NUMBER NOT NULL REFERENCES customers(customer_id),
    order_status      VARCHAR2(30) DEFAULT 'pending'
                      CHECK (order_status IN ('pending','confirmed','processing',
                             'routed','completed','cancelled','returned')),
    order_total       NUMBER(12,2),
    shipping_cost     NUMBER(8,2) DEFAULT 0,
    fulfillment_center_id NUMBER REFERENCES fulfillment_centers(center_id),
    shipping_lat      NUMBER(10,7),
    shipping_lon      NUMBER(11,7),
    estimated_delivery DATE,
    actual_delivery    DATE,
    social_source_id   NUMBER,         -- FK to social_posts if order was influenced
    demand_score       NUMBER(5,2),    -- AI-computed demand urgency
    created_at         TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at         TIMESTAMP DEFAULT SYSTIMESTAMP
) INMEMORY MEMCOMPRESS FOR QUERY HIGH;

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status   ON orders(order_status);
CREATE INDEX idx_orders_center   ON orders(fulfillment_center_id);
CREATE INDEX idx_orders_created  ON orders(created_at);

-- ============================================================
-- ORDER ITEMS
-- ============================================================
CREATE TABLE order_items (
    item_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id          NUMBER NOT NULL REFERENCES orders(order_id),
    product_id        NUMBER NOT NULL REFERENCES products(product_id),
    quantity          NUMBER(6)  NOT NULL,
    unit_price        NUMBER(10,2) NOT NULL,
    line_total        NUMBER(12,2) GENERATED ALWAYS AS (quantity * unit_price) VIRTUAL,
    fulfilled_from    NUMBER REFERENCES fulfillment_centers(center_id)
) INMEMORY MEMCOMPRESS FOR QUERY HIGH;

CREATE INDEX idx_oitems_order   ON order_items(order_id);
CREATE INDEX idx_oitems_product ON order_items(product_id);

-- ============================================================
-- SOCIAL INFLUENCERS
-- ============================================================
CREATE TABLE influencers (
    influencer_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    handle            VARCHAR2(200) NOT NULL UNIQUE,
    display_name      VARCHAR2(200),
    platform          VARCHAR2(50) DEFAULT 'instagram'
                      CHECK (platform IN ('instagram','tiktok','twitter','youtube','threads')),
    follower_count    NUMBER(12) DEFAULT 0,
    engagement_rate   NUMBER(5,4) DEFAULT 0,   -- e.g. 0.0345 = 3.45%
    influence_score   NUMBER(5,2) DEFAULT 0,   -- computed 0-100
    niche             VARCHAR2(100),
    city              VARCHAR2(100),
    region            VARCHAR2(100),            -- state / province for VPD
    country           VARCHAR2(3) DEFAULT 'US',
    is_verified       NUMBER(1) DEFAULT 0,
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_influencers_platform ON influencers(platform);
CREATE INDEX idx_influencers_score    ON influencers(influence_score DESC);

-- ============================================================
-- SOCIAL POSTS (relational metadata — JSON payload stored separately)
-- ============================================================
CREATE TABLE social_posts (
    post_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    influencer_id     NUMBER REFERENCES influencers(influencer_id),
    platform          VARCHAR2(50),
    external_post_id  VARCHAR2(200),
    post_text         CLOB,
    posted_at         TIMESTAMP NOT NULL,
    likes_count       NUMBER(10) DEFAULT 0,
    shares_count      NUMBER(10) DEFAULT 0,
    comments_count    NUMBER(10) DEFAULT 0,
    views_count       NUMBER(12) DEFAULT 0,
    sentiment_score   NUMBER(4,3),       -- -1.0 to 1.0
    virality_score    NUMBER(5,2),       -- computed 0-100
    detected_products VARCHAR2(2000),    -- comma-separated product IDs matched
    momentum_flag     VARCHAR2(20) DEFAULT 'normal'
                      CHECK (momentum_flag IN ('normal','rising','viral','mega_viral')),
    processed_at      TIMESTAMP,
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
) INMEMORY MEMCOMPRESS FOR QUERY HIGH;

CREATE INDEX idx_social_influencer ON social_posts(influencer_id);
CREATE INDEX idx_social_posted     ON social_posts(posted_at DESC);
CREATE INDEX idx_social_momentum   ON social_posts(momentum_flag);
CREATE INDEX idx_social_virality   ON social_posts(virality_score DESC);

-- ============================================================
-- SOCIAL POST ↔ PRODUCT MENTIONS (many-to-many)
-- ============================================================
CREATE TABLE post_product_mentions (
    mention_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id           NUMBER NOT NULL REFERENCES social_posts(post_id),
    product_id        NUMBER NOT NULL REFERENCES products(product_id),
    confidence_score  NUMBER(4,3) DEFAULT 1.0,  -- semantic match confidence
    mention_type      VARCHAR2(30) DEFAULT 'direct'
                      CHECK (mention_type IN ('direct','semantic','hashtag','visual','inferred')),
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT uq_post_product UNIQUE (post_id, product_id)
);

CREATE INDEX idx_mentions_product ON post_product_mentions(product_id);
CREATE INDEX idx_mentions_post    ON post_product_mentions(post_id);

-- ============================================================
-- DEMAND FORECASTS
-- ============================================================
CREATE TABLE demand_forecasts (
    forecast_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id        NUMBER NOT NULL REFERENCES products(product_id),
    region            VARCHAR2(100),
    forecast_date     DATE NOT NULL,
    predicted_demand  NUMBER(10) NOT NULL,
    confidence_low    NUMBER(10),
    confidence_high   NUMBER(10),
    social_factor     NUMBER(5,2) DEFAULT 1.0,  -- signal multiplier
    model_version     VARCHAR2(50),
    explanation       CLOB,    -- JSON with explainable factors
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_forecast_product ON demand_forecasts(product_id, forecast_date);

-- ============================================================
-- SHIPMENTS
-- ============================================================
CREATE TABLE shipments (
    shipment_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id          NUMBER NOT NULL REFERENCES orders(order_id),
    center_id         NUMBER NOT NULL REFERENCES fulfillment_centers(center_id),
    carrier           VARCHAR2(100),
    tracking_number   VARCHAR2(200),
    ship_status       VARCHAR2(30) DEFAULT 'preparing'
                      CHECK (ship_status IN ('preparing','picked','packed','routed',
                             'in_transit','out_for_delivery','completed','exception')),
    distance_km       NUMBER(8,2),
    estimated_hours   NUMBER(6,2),
    ship_cost         NUMBER(8,2),
    routed_at        TIMESTAMP,
    completed_at      TIMESTAMP,
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_shipments_order  ON shipments(order_id);
CREATE INDEX idx_shipments_center ON shipments(center_id);

-- ============================================================
-- AGENT ACTIONS LOG (audit trail for AI agent decisions)
-- ============================================================
CREATE TABLE agent_actions (
    action_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_name        VARCHAR2(100) NOT NULL,
    action_type       VARCHAR2(100) NOT NULL,
    entity_type       VARCHAR2(50),      -- 'product','order','inventory','shipment'
    entity_id         NUMBER,
    decision_payload  CLOB,              -- JSON: reasoning, factors, outcome
    confidence        NUMBER(4,3),
    execution_status  VARCHAR2(30) DEFAULT 'proposed'
                      CHECK (execution_status IN ('proposed','approved','executing',
                             'completed','failed','rolled_back')),
    executed_at       TIMESTAMP,
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_agent_actions_type   ON agent_actions(action_type);
CREATE INDEX idx_agent_actions_entity ON agent_actions(entity_type, entity_id);

-- ============================================================
-- APP USERS & ROLES (for RBAC demo)
-- ============================================================
CREATE TABLE app_users (
    user_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username          VARCHAR2(100) NOT NULL UNIQUE,
    password_hash     VARCHAR2(500) NOT NULL,
    full_name         VARCHAR2(200),
    email             VARCHAR2(300),
    role              VARCHAR2(30) NOT NULL
                      CHECK (role IN ('admin','analyst','fulfillment_mgr',
                             'merchandiser','viewer')),
    region            VARCHAR2(100),
    is_active         NUMBER(1) DEFAULT 1,
    last_login        TIMESTAMP,
    created_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- ============================================================
-- ACTIVE DATASET STATE
-- ============================================================
CREATE TABLE app_dataset_state (
    state_id          NUMBER(1) PRIMARY KEY
                      CHECK (state_id = 1),
    active_source     VARCHAR2(20) NOT NULL
                      CHECK (active_source IN ('demo','custom')),
    active_label      VARCHAR2(100) NOT NULL,
    active_version    VARCHAR2(20),
    updated_at        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

COMMIT;

-- Summary
SELECT 'Tables created successfully' AS status FROM dual;
