-- Lab 5 stretch: the READ-ONLY computed POS view - what a duality view
-- deliberately won't do (COALESCE, filters), a plain view does freely.
-- The clock is PINNED to 13:00 so every attendee sees the Lunch menu
-- regardless of conference timezone.
CREATE OR REPLACE VIEW pos_menu_v AS
SELECT JSON {
         '_id'  : s.store_id,
         'name' : s.merchant_name,
         'menu' : ( SELECT JSON {
                      '_id'   : m.menu_id,
                      'name'  : m.menu_name,
                      'items' : [ SELECT JSON {
                                    '_id'    : i.item_id,
                                    'name'   : COALESCE(ov.override_name, i.item_name),
                                    'active' : COALESCE(ov.override_active, i.active),
                                    'price'  : i.price }
                                  FROM item i
                                  LEFT JOIN item_override ov
                                         ON ov.item_id = i.item_id
                                        AND ov.store_id = s.store_id
                                  JOIN category c ON c.category_id = i.category_id
                                  WHERE c.menu_id = m.menu_id ]
                    }
                    FROM menu m
                    WHERE m.store_id = s.store_id
                    AND   m.active
                    AND   '13:00' BETWEEN m.start_time AND m.end_time )
       } AS json_doc
FROM   store s;

-- What the POS sees at 13:00 for Burger Palace: override applied, computed, read-only
SELECT json_serialize(p.json_doc PRETTY) FROM pos_menu_v p
WHERE  json_value(p.json_doc, '$._id') = 's_100';
