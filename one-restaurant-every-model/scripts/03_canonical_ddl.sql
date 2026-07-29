-- Lab 4: the canonical restaurant schema - seven core entities plus the
-- optional 1:1 item_override extension = 8 tables, 3NF.
-- The Ask Tom entity `option` is named item_option: OPTION is reserved in Oracle SQL.
-- Idempotent: views that depend on these tables are dropped first.

DROP VIEW  IF EXISTS "store_menu_dv";
DROP VIEW  IF EXISTS "location_item_dv";
DROP VIEW  IF EXISTS pos_menu_v;
DROP TABLE IF EXISTS item_option        CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS extra              CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item_special_hours CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item_override      CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS item               CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS category           CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS menu               CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS store              CASCADE CONSTRAINTS;

CREATE TABLE store (
  store_id      VARCHAR2(10)  PRIMARY KEY,
  merchant_name VARCHAR2(100) NOT NULL,
  timezone      VARCHAR2(40)  DEFAULT 'America/Los_Angeles' NOT NULL
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

CREATE TABLE item (
  item_id     NUMBER        PRIMARY KEY,
  category_id NUMBER        NOT NULL REFERENCES category,
  item_name   VARCHAR2(100) NOT NULL,
  description VARCHAR2(400),
  price       NUMBER        NOT NULL CHECK (price > 0),
  active      BOOLEAN       DEFAULT TRUE NOT NULL
);

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

CREATE TABLE item_override (
  item_id          NUMBER       PRIMARY KEY REFERENCES item,
  store_id         VARCHAR2(10) NOT NULL REFERENCES store,
  override_name    VARCHAR2(100),
  override_active  BOOLEAN,
  override_sort_id NUMBER
);

-- STATE CHECK: expect 8
SELECT COUNT(*) AS application_tables
FROM   user_tables
WHERE  table_name IN ('STORE','MENU','CATEGORY','ITEM','EXTRA',
                      'ITEM_OPTION','ITEM_SPECIAL_HOURS','ITEM_OVERRIDE');
