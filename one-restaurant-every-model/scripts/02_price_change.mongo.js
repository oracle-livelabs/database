// Lab 3: corporate raises the Classic Cheeseburger to $13.99 chain-wide.
// Expected: matchedCount: 5, modifiedCount: 4 - the string-typed copy in
// s_104 does not match the numeric arrayFilter. That miss IS the lesson.
db.stores.updateMany(
  {},
  { $set: { "menus.$[].categories.$[].items.$[i].price": 1399 } },
  { arrayFilters: [ { "i.item_id": 1000 } ] }
);
