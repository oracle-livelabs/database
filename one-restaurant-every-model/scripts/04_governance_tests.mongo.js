// Lab 5: governance the engine enforces, probed through the MongoDB API.
// The franchise rule: a LOCATION owns its display name and its price; it does
// NOT own the chain catalog. That rule lives in the duality view annotations,
// below every API - not in application code.

// 1. The location changes its own local price - ALLOWED (@update on menu_item)
db.store_menu_dv.updateOne(
  { _id: "s_102" },
  { $set: { "menus.0.categories.0.items.0.price": 1350 } }
);
print("local price change: accepted");

// 2. The location tries to rewrite the CHAIN CATALOG name - REJECTED
try {
  db.store_menu_dv.updateOne(
    { _id: "s_102" },
    { $set: { "menus.0.categories.0.items.0.name": "Hijacked Burger" } }
  );
  print("catalog write: UNEXPECTEDLY ACCEPTED");
} catch (e) { print("catalog write: " + e.message); }

// 3. Negative price through the document API - meets the CHECK constraint
try {
  db.store_menu_dv.updateOne(
    { _id: "s_102" },
    { $set: { "menus.0.categories.0.items.0.price": -1 } }
  );
  print("negative price: UNEXPECTEDLY ACCEPTED");
} catch (e) { print("negative price: " + e.message); }
