// Lab 7: seed 40 orders, deterministically (no randomness - reproducible in
// every sandbox). Heavy co-order signal: Classic Cheeseburger + French Fries.
// Line items SNAPSHOT the menu at order time (order = transaction truth):
// item 1000 at the current corporate price 1499.
const ORDERS_TOTAL = 40;
const orders = [];
for (let n = 1; n <= ORDERS_TOTAL; n++) {
  const id   = "ord_" + (8000 + n);
  const cust = "c_" + (((n - 1) % 10) + 1);
  const store = "s_10" + ((n - 1) % 5);
  let items;
  if (n <= 24) {
    items = [
      { item_id: 1000, name: "Classic Cheeseburger", price: 1499 },
      { item_id: 1002, name: "French Fries",         price: 499 } ];
  } else if (n <= 32) {
    items = [
      { item_id: 1000, name: "Classic Cheeseburger", price: 1499 },
      { item_id: 1003, name: "Garden Salad",         price: 899 } ];
  } else if (n <= 36) {
    items = [
      { item_id: 2001, name: "Szechuan Tofu Stir-Fry", price: 1199 },
      { item_id: 2002, name: "Beef Chow Fun",          price: 1399 } ];
  } else {
    items = [
      { item_id: 3001, name: "Carnitas Taco Plate", price: 1099 },
      { item_id: 1002, name: "French Fries",        price: 499 } ];
  }
  orders.push({
    _id: id, customer_id: cust, store_id: store, status: "closed",
    opened_at: "2026-07-20T12:" + String(n).padStart(2, "0") + ":00Z",
    items: items,
    total: items.reduce((s, i) => s + i.price, 0)
  });
}
db.orders.insertMany(orders);
print("orders inserted: " + db.orders.countDocuments({}));
