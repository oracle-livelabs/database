# Quiz: True Cache Fundamentals

```quiz-config
passing: 75
badge: images/badge.png
```

```quiz score
Q: Which challenge does Oracle True Cache solve in this workshop's architecture?
* It offloads read-mostly queries from the primary database, reducing contention on the OLTP instance.
- It replaces the primary database entirely so no standby is required.
- It stores application code closer to users to shorten network latency for writes.
- It automatically partitions transactional schemas without application changes.
> Oracle True Cache acts as a mostly diskless replica that serves read workloads, protecting the primary database from read-heavy traffic without re-architecting the application.

Q: Why must Lab 1 confirm that the primary database, True Cache, and client containers are running before later labs?
* Any missing container breaks the end-to-end flow, preventing schema creation, caching, or the demo app from succeeding.
- It guarantees podman images are the latest public release.
- It is required only to reclaim storage used by stopped containers.
> The workshop depends on all three services—database, cache, and client—to continue, so verifying they run avoids cascading failures in later tasks.

Q: After loading data in Lab 2, why is DBMS_CACHEUTIL.TRUE_CACHE_KEEP invoked for the ACCOUNTS table?
* It pins critical tables in the True Cache buffer cache so read-only queries stay cached for consistent performance tests.
- It truncates the table so True Cache can reload data from Object Storage.
- It grants extra privileges to the transactions user before running JDBC workloads.
> Keeping the table in the True Cache buffer ensures the workload hits cached data, demonstrating the cache benefits without eviction noise.

Q: What is the purpose of the warm-up phase in TransactionsApp.sh before the workload switches to True Cache?
* It identifies key tables and populates True Cache so the comparison reflects steady-state cached reads.
- It forces the application to run longer against the primary database to capture baselines.
- It disables True Cache connections so only the primary handles reads.
> Preloading True Cache primes the cache with relevant objects, making the subsequent True Cache run a fair measure of cached performance.

Q: How does the Oracle 23ai JDBC driver manage connections when the application targets True Cache?
* The application uses one logical service name while the driver maintains two physical connections and toggles read-only versus read-write calls.
- The driver opens separate JDBC URLs for read and write operations that the application must manage manually.
- The driver mirrors every statement to both databases to keep them synchronized without application input.
> The driver abstracts the split by keeping paired physical connections and letting the app flag when a request can be routed to True Cache.
```
