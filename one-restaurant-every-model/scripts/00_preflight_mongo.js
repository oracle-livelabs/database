// PREFLIGHT (Lab 1): connectivity check only. Reads nothing, writes nothing.
// Goes one better than a ping: it proves the MongoDB API can reach the database
// AND run SQL through it, and prints the version you are actually connected to.
db.aggregate([{$sql:`select banner from v$version`}])
