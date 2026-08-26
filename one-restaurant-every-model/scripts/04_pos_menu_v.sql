-- Lab 5 stretch: the READ-ONLY computed POS view - what a duality view
-- deliberately won't do (COALESCE, filters), a plain view does freely.
-- With the chain model the COALESCE is the real franchise rule:
-- local value if the location set one, otherwise the corporate catalog value.
CREATE OR REPLACE VIEW pos_menu_v AS
SELECT JSON {
         '_id'  : s.store_id,
         'name' : s.merchant_name,
         'menu' : ( SELECT JSON {
                      '_id'   : m.menu_id,
                      'name'  : m.menu_name,
                      'items' : [ SELECT JSON {
                                    '_id'    : i.item_id,
                                    'name'   : COALESCE(mi.display_name, i.item_name),
                                    'price'  : COALESCE(mi.price,        i.base_price),
                                    'active' : COALESCE(mi.active,       i.active) }
                                  FROM menu_item mi
                                  JOIN item i ON i.item_id = mi.item_id
                                  WHERE mi.menu_id = m.menu_id ]
                    }
                    FROM menu m
                    WHERE m.store_id = s.store_id
                    AND   m.active
                    AND   '13:00' BETWEEN m.start_time AND m.end_time )
       } AS json_doc
FROM   store s;

-- What the POS sees for the Downtown location: the LOCAL name applied
SELECT json_serialize(p.json_doc PRETTY) FROM pos_menu_v p
WHERE  json_value(p.json_doc, '$._id') = 's_100';
