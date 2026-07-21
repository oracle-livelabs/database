-- SQL twin of 01_seed_stores.mongo.js — identical five documents, identical
-- invariants (drifted string item_id in s_104; prices start at 1299).
-- For attendees whose mongosh connection is blocked. Run as a script.
CREATE JSON COLLECTION TABLE IF NOT EXISTS "stores";
DELETE FROM "stores";

INSERT INTO "stores" (data) VALUES
('{"_id":"s_100","name":"Burger Palace","menus":[{"menu_id":10,"name":"Lunch Menu","categories":[{"category_id":100,"name":"Burgers","items":[{"item_id":1000,"name":"Lunch Classic","description":"Char-grilled smash patty, aged cheddar, brioche bun","price":1299,"active":true},{"item_id":1002,"name":"French Fries","description":"Twice-fried golden potato fries with sea salt","price":499,"active":true}]}]}]}');
INSERT INTO "stores" (data) VALUES
('{"_id":"s_101","name":"Burger Palace Uptown","menus":[{"menu_id":11,"name":"Lunch Menu","categories":[{"category_id":110,"name":"Burgers","items":[{"item_id":1000,"name":"Classic Cheeseburger","description":"Char-grilled smash patty, aged cheddar, brioche bun","price":1299,"active":true},{"item_id":1003,"name":"Garden Salad","description":"Crisp greens, heirloom tomato, house vinaigrette","price":899,"active":true}]}]}]}');
INSERT INTO "stores" (data) VALUES
('{"_id":"s_102","name":"Noodle House","menus":[{"menu_id":12,"name":"All Day Menu","categories":[{"category_id":120,"name":"Wok","items":[{"item_id":2001,"name":"Szechuan Tofu Stir-Fry","description":"Crispy tofu, fiery chili-garlic sauce, seasonal vegetables, no meat","price":1199,"active":true},{"item_id":2002,"name":"Beef Chow Fun","description":"Wide rice noodles, wok-seared beef, scallion","price":1399,"active":true},{"item_id":1000,"name":"Classic Cheeseburger","description":"Char-grilled smash patty, aged cheddar, brioche bun","price":1299,"active":true}]}]}]}');
INSERT INTO "stores" (data) VALUES
('{"_id":"s_103","name":"Taco Verde","menus":[{"menu_id":13,"name":"Lunch Menu","categories":[{"category_id":130,"name":"Tacos","items":[{"item_id":3001,"name":"Carnitas Taco Plate","description":"Slow-braised pork, salsa verde, corn tortillas","price":1099,"active":true},{"item_id":1000,"name":"Classic Cheeseburger","description":"Char-grilled smash patty, aged cheddar, brioche bun","price":1299,"active":true}]}]}]}');
INSERT INTO "stores" (data) VALUES
('{"_id":"s_104","name":"Burger Palace Airport","menus":[{"menu_id":14,"name":"All Day Menu","categories":[{"category_id":140,"name":"Burgers","items":[{"item_id":"1000","name":"Classic Cheeseburger","description":"Char-grilled smash patty, aged cheddar, brioche bun","price":1299,"active":true},{"item_id":1002,"name":"French Fries","description":"Twice-fried golden potato fries with sea salt","price":499,"active":true}]}]}]}');
COMMIT;

-- STATE CHECK
SELECT COUNT(*) AS stores_seeded FROM "stores";
