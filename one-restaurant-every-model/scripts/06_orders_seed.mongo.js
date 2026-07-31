// Lab 7: seed 40 orders, deterministically (no randomness - reproducible in
// every sandbox).
//
// Customers belong to CUISINE COHORTS. This matters more than it looks:
// GRAPH_TABLE matches co-orders through a shared *customer*, not a shared
// order. If every customer cycles through every basket, all ten of them
// eventually order everything, and "people who ordered X also ordered Y"
// degenerates into "Y is the most popular item on the menu" - which is how an
// earlier version of this seed had the Szechuan Tofu Stir-Fry recommending a
// cheeseburger. Real diners have habits; the graph is only interesting if they
// do.
//
// Line items SNAPSHOT the menu at order time (order = transaction truth):
// item 1000 at the current corporate price 1499.
const MENU = {
  1000: { name: "Classic Cheeseburger",   price: 1499 },
  1002: { name: "French Fries",           price: 499  },
  1003: { name: "Garden Salad",           price: 899  },
  2001: { name: "Szechuan Tofu Stir-Fry", price: 1199 },
  2002: { name: "Beef Chow Fun",          price: 1399 },
  3001: { name: "Carnitas Taco Plate",    price: 1099 }
};

// Ten customers, four orders each = 40. Each cohort works through its own
// basket rotation, so the co-order neighbourhoods stay cuisine-coherent.
const COHORTS = [
  { name: "noodle", customers: ["c_1", "c_2", "c_3"],
    baskets: [[2001, 2002], [2001, 2002], [2001, 2002], [2002, 1003]] },
  { name: "burger", customers: ["c_4", "c_5", "c_6", "c_7"],
    baskets: [[1000, 1002], [1000, 1002], [1000, 1002], [1000, 1003]] },
  { name: "taco",   customers: ["c_8", "c_9", "c_10"],
    baskets: [[3001, 1002], [3001, 1002], [3001, 1003], [3001, 1002]] }
];

const ORDERS_TOTAL = 40;
const orders = [];
let n = 0;
for (const cohort of COHORTS) {
  for (const customer of cohort.customers) {
    for (const basket of cohort.baskets) {
      n += 1;
      const items = basket.map(id => ({
        item_id: id, name: MENU[id].name, price: MENU[id].price
      }));
      orders.push({
        _id: "ord_" + (8000 + n),
        customer_id: customer,
        store_id: "s_10" + ((n - 1) % 5),
        cohort: cohort.name,
        status: "closed",
        opened_at: "2026-07-20T12:" + String(n).padStart(2, "0") + ":00Z",
        items: items,
        total: items.reduce((s, i) => s + i.price, 0)
      });
    }
  }
}
// Re-run safe: fixed _id values would collide on a second run.
db.orders.deleteMany({});
db.orders.insertMany(orders);
print("orders inserted: " + db.orders.countDocuments({}) + " (of " + ORDERS_TOTAL + ")");
