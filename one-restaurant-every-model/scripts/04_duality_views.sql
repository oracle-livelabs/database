-- Lab 5: the duality views, with explicit updatability annotations.
-- Duality views are READ-ONLY BY DEFAULT - granting writes per table IS the
-- governance posture. Quoted-lowercase names so mongosh's db.store_menu_dv /
-- db.location_item_dv bind exactly (Mongo collection names are case-sensitive).

CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW "store_menu_dv" AS
store @insert @update @delete
{
  _id   : store_id,
  name  : merchant_name,
  menus : menu @insert @update
  [ {
      _id        : menu_id,
      name       : menu_name,
      categories : category @insert @update
      [ {
          _id   : category_id,
          name  : category_name,
          items : item @insert @update
          [ {
              _id   : item_id,
              name  : item_name,
              price : price,
              desc  : description
          } ]
      } ]
  } ]
};

CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW "location_item_dv" AS
item @noinsert @noupdate @nodelete
{
  _id   : item_id,
  name  : item_name,
  price : price,
  desc  : description,
  override : item_override @insert @update @delete
  {
    _id    : item_id,
    store  : store_id,
    name   : override_name,
    active : override_active,
    sort   : override_sort_id
  },
  schedule : item_special_hours @insert @update @delete
  [ {
    _id   : item_special_hours_id,
    day   : day_index,
    start : start_time,
    end   : end_time
  } ]
};

-- REST-enable the schema (no-op if already enabled) and the menu view.
BEGIN
  ORDS.ENABLE_SCHEMA;
  ORDS.ENABLE_OBJECT(p_object => 'store_menu_dv', p_object_type => 'VIEW');
END;
/

-- STATE CHECK: both views should return documents, not null
SELECT (SELECT COUNT(*) FROM "store_menu_dv")    AS store_docs,
       (SELECT COUNT(*) FROM "location_item_dv") AS item_docs
FROM   dual;
