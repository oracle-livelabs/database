// Lab 3: top-10 most expensive items across all stores - the document way.
// Three $unwind stages explode every store document to answer a ten-row question.
db.stores.aggregate([
  { $unwind: "$menus" },
  { $unwind: "$menus.categories" },
  { $unwind: "$menus.categories.items" },
  { $sort:  { "menus.categories.items.price": -1 } },
  { $limit: 10 },
  { $project: { _id: 0,
                store: "$name",
                item:  "$menus.categories.items.name",
                price: "$menus.categories.items.price" } }
]);
