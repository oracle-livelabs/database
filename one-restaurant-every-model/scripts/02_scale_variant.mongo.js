// Lab 3 stretch: the fleet at scale - COUNTS AND BYTES ONLY.
// Design rule: no wall-clock measurement on shared lab instances; timing
// receipts live in the published DocBench / sbe-cte-bench harnesses.
const clones = [];
const template = db.stores.findOne({ _id: "s_100" });
for (let i = 0; i < 4995; i++) {
  const doc = JSON.parse(JSON.stringify(template));
  doc._id = "sx_" + (1000 + i);
  clones.push(doc);
}
db.stores.insertMany(clones);
print("fleet size now: " + db.stores.countDocuments({}));

const res = db.stores.updateMany(
  {},
  { $set: { "menus.$[].categories.$[].items.$[i].price": 14.01 } },
  { arrayFilters: [ { "i.item_id": 1000 } ] }
);
print("matchedCount: "  + res.matchedCount);
print("modifiedCount: " + res.modifiedCount + "  <- full-document rewrites to move one number");

// Clean up the clones and restore the 13.99 state the later labs expect
db.stores.deleteMany({ _id: { $regex: "^sx_" } });
db.stores.updateMany(
  {},
  { $set: { "menus.$[].categories.$[].items.$[i].price": 13.99 } },
  { arrayFilters: [ { "i.item_id": 1000 } ] }
);
print("restored fleet: " + db.stores.countDocuments({}) + " stores, price back to 13.99");
