// Lab 7: seed 40 orders, deterministically.
//
// Customers belong to ORDERING COHORTS. GRAPH_TABLE matches co-orders through a
// shared CUSTOMER, not a shared order -- so if every customer cycled through
// every basket they would all end up ordering everything, and "people who
// ordered X also ordered Y" would collapse into "Y is the most popular item".
// Each cohort also only orders at stores that actually SELL its items.
const CATALOG = {
  "1000": {
    "name": "Classic Cheeseburger",
    "price": 1299
  },
  "1001": {
    "name": "Bacon Double Stack",
    "price": 1599
  },
  "1002": {
    "name": "French Fries",
    "price": 499
  },
  "1003": {
    "name": "Garden Salad",
    "price": 899
  },
  "1004": {
    "name": "Black Bean Chipotle Burger",
    "price": 1199
  },
  "1005": {
    "name": "Buffalo Chicken Sandwich",
    "price": 1349
  },
  "1006": {
    "name": "Chocolate Malt Shake",
    "price": 599
  }
};
const COHORTS = [
  {
    "name": "classic",
    "customers": [
      "c_1",
      "c_2",
      "c_3",
      "c_4"
    ],
    "stores": [
      "s_100",
      "s_101",
      "s_102",
      "s_104"
    ],
    "baskets": [
      [
        1000,
        1002
      ],
      [
        1000,
        1002
      ],
      [
        1000,
        1002
      ],
      [
        1000,
        1003
      ]
    ]
  },
  {
    "name": "veggie",
    "customers": [
      "c_5",
      "c_6",
      "c_7"
    ],
    "stores": [
      "s_101",
      "s_103"
    ],
    "baskets": [
      [
        1004,
        1003
      ],
      [
        1004,
        1003
      ],
      [
        1004,
        1003
      ],
      [
        1004,
        1002
      ]
    ]
  },
  {
    "name": "indulgent",
    "customers": [
      "c_8",
      "c_9",
      "c_10"
    ],
    "stores": [
      "s_100",
      "s_101"
    ],
    "baskets": [
      [
        1001,
        1006
      ],
      [
        1001,
        1006
      ],
      [
        1001,
        1006
      ],
      [
        1001,
        1002
      ]
    ]
  }
];

const orders = [];
let n = 0;
for (const co of COHORTS) {
  co.customers.forEach((cust, ci) => {
    co.baskets.forEach((basket, bi) => {
      n += 1;
      const store = co.stores[(ci + bi) % co.stores.length];
      const items = basket.map(id => ({ item_id: id, name: CATALOG[id].name, price: CATALOG[id].price }));
      orders.push({
        _id: "ord_" + (8000 + n), customer_id: cust, store_id: store,
        cohort: co.name, status: "closed",
        opened_at: "2026-07-20T12:" + String(n).padStart(2, "0") + ":00Z",
        items: items, total: items.reduce((s, i) => s + i.price, 0)
      });
    });
  });
}
db.orders.deleteMany({});
db.orders.insertMany(orders);
print("orders inserted: " + db.orders.countDocuments({}));
