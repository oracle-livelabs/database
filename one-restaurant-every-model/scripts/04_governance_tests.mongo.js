// Lab 5 Task 4: governance probes through the document door.
// Expected outcomes are printed inline - capture exact error text at build time.

// 1. Location manager tries to change the corporate price via the location view
//    -> REJECTED: price is corporate-owned (@noupdate on the root item table)
try {
  db.location_item_dv.updateOne({ _id: 1000 }, { $set: { price: 99 } });
  print("probe 1: UNEXPECTED SUCCESS - governance annotation missing?");
} catch (e) {
  print("probe 1 (corp field): rejected as expected -> " + e.message);
}

// 2. Location manager edits the field they own -> succeeds, decomposes to a
//    relational row in item_override (verify from SQL afterwards)
db.location_item_dv.updateOne(
  { _id: 1000 },
  { $set: { "override.0.name": "Lunch Classic Special" } }  // override is a 1-element ARRAY (validated on 26ai)
);
print("probe 2 (override): location-owned edit accepted");

// 3. Negative price through the UPDATABLE menu view -> reaches the canonical
//    table and hits CHECK (price > 0): the SAME ORA-02290 the SQL insert got.
try {
  db.store_menu_dv.updateOne(
    { _id: "s_100" },
    { $set: { "menus.0.categories.0.items.0.price": -1 } }
  );
  print("probe 3: UNEXPECTED SUCCESS - CHECK constraint missing?");
} catch (e) {
  print("probe 3 (negative price): rejected as expected -> " + e.message);
}
