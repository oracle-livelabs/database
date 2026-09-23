-- Corrected chain model (approved by Hermann).
-- item is the CHAIN CATALOG (no parent). menu_item is the missing many-to-many:
-- which store's menu offers which chain item, on what local terms.
DROP VIEW  IF EXISTS "store_menu_dv";
DROP VIEW  IF EXISTS pos_menu_v;
DROP TABLE IF EXISTS item_option        CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS extra              CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item_special_hours CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS menu_item          CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS category           CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS menu               CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item               CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS store              CASCADE CONSTRAINTS;

CREATE TABLE store (
  store_id      VARCHAR2(10)  PRIMARY KEY,
  merchant_name VARCHAR2(100) NOT NULL,
  timezone      VARCHAR2(40)  DEFAULT 'America/Los_Angeles' NOT NULL
);

-- CHAIN CATALOG: an item belongs to the chain, not to a store.
CREATE TABLE item (
  item_id     NUMBER        PRIMARY KEY,
  item_name   VARCHAR2(100) NOT NULL,
  description VARCHAR2(400),
  base_price  NUMBER        NOT NULL CHECK (base_price > 0),
  active      BOOLEAN       DEFAULT TRUE NOT NULL
);

CREATE TABLE menu (
  menu_id    NUMBER       PRIMARY KEY,
  store_id   VARCHAR2(10) NOT NULL REFERENCES store,
  menu_name  VARCHAR2(50) NOT NULL,
  active     BOOLEAN      DEFAULT TRUE NOT NULL,
  start_time VARCHAR2(5)  DEFAULT '00:00' NOT NULL,
  end_time   VARCHAR2(5)  DEFAULT '23:59' NOT NULL
);

CREATE TABLE category (
  category_id   NUMBER       PRIMARY KEY,
  menu_id       NUMBER       NOT NULL REFERENCES menu,
  category_name VARCHAR2(50) NOT NULL
);

-- THE JUNCTION. display_name/price NULL => inherit from the chain catalog.
CREATE TABLE menu_item (
  menu_id      NUMBER        NOT NULL REFERENCES menu,
  item_id      NUMBER        NOT NULL REFERENCES item,
  category_id  NUMBER        NOT NULL REFERENCES category,
  display_name VARCHAR2(100),
  price        NUMBER        CHECK (price > 0),
  active       BOOLEAN,
  sort_id      NUMBER,
  CONSTRAINT menu_item_pk PRIMARY KEY (menu_id, item_id)
);
CREATE INDEX menu_item_item_ix ON menu_item (item_id);
CREATE INDEX menu_item_cat_ix  ON menu_item (category_id);

CREATE TABLE extra (
  extra_id   NUMBER       PRIMARY KEY,
  item_id    NUMBER       NOT NULL REFERENCES item,
  extra_name VARCHAR2(50) NOT NULL
);

CREATE TABLE item_option (
  option_id   NUMBER       PRIMARY KEY,
  extra_id    NUMBER       NOT NULL REFERENCES extra,
  option_name VARCHAR2(50) NOT NULL,
  price_delta NUMBER       DEFAULT 0 NOT NULL
);

CREATE TABLE item_special_hours (
  item_special_hours_id NUMBER      PRIMARY KEY,
  item_id               NUMBER      NOT NULL REFERENCES item,
  day_index             NUMBER(1)   NOT NULL,
  start_time            VARCHAR2(5) NOT NULL,
  end_time              VARCHAR2(5) NOT NULL
);
