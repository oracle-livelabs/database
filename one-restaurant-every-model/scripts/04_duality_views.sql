CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW "store_menu_dv" AS
store @insert @update @delete
{
  _id   : store_id
  name  : merchant_name
  menus : menu @insert @update
  [ {
      _id  : menu_id
      name : menu_name
      categories : category @insert @update
      [ {
          _id   : category_id
          name  : category_name
          items : menu_item @insert @update @delete
          [ {
              menu_id : menu_id
              _id     : item_id
              price   : price
              display : display_name
              item @unnest @noinsert @noupdate @nodelete
              {
                item_id     : item_id
                name        : item_name
                description : description
                base_price  : base_price
              }
          } ]
      } ]
  } ]
};

-- REST-enable the schema (no-op if already enabled) and the menu view.
BEGIN
  ORDS.ENABLE_SCHEMA;
  ORDS.ENABLE_OBJECT(p_object => 'store_menu_dv', p_object_type => 'VIEW');
END;
/

-- STATE CHECK: the view returns one document per store
SELECT COUNT(*) AS store_docs FROM "store_menu_dv";
