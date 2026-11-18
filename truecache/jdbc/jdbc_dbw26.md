# Use True Cache through JDBC

## Introduction

This lab uses one logical JDBC connection for Primary and True Cache. When True Cache is configured and the work is marked read-only, eligible read-only work can be routed to True Cache, while read-write work remains on Primary. The lab compares read latency, with TPS as a supporting metric, observes replication statistics while Primary receives updates, and verifies that True Cache can continue serving eligible reads while Primary is stopped.

Estimated Time: 30 minutes.

Use one shell for each container session. After entering a container, run the commands for that section directly in that shell. Host-level start and stop commands are labeled separately.

## Objectives

- Validate JDBC read routing.
- Compare Primary and True Cache read latency, with transactions per second (TPS) as a supporting throughput metric.
- Observe transport lag, apply lag, cache hit ratios, and fetch latency.
- Verify True Cache availability while Primary is stopped.
- Continue to the separate New Feature: Semantic Cache with Vector Search lab.

## Application Container Session

From the desktop Terminal, load the lab environment and open the application container once. The environment file contains the generated Transactions password used by the lab services. Do not use the VNC password or a sample password.

~~~text
<copy>
source /home/opc/.truecache_lab_env
sudo podman exec -e DB_PASS="$DB_PASS" -it appclient /bin/bash
</copy>
~~~

At the `appclient` container prompt, move to the client application directory:

~~~text
<copy>
cd /stage/clientapp
</copy>
~~~

Keep this application shell open throughout the remainder of this lab.

If `prod` or `truedb` was restarted after Initialize Environment, verify the database services before running the application. The proxy normally performs this reconciliation automatically; use these idempotent commands only when the service query is empty.

Primary service recovery from the host terminal, only if the service query is empty:

~~~text
<copy>
sudo podman exec -it prod /bin/bash
</copy>
~~~

At the `prod` container prompt, run the following commands:

~~~text
<copy>
export ORACLE_SID=ORCLCDB
sqlplus / as sysdba
alter session set container=ORCLPDB1;
begin
  dbms_service.start_service('SALES1');
end;
/
select name, network_name from v$services where upper(name) = 'SALES1';
exit
exit
</copy>
~~~

True Cache service recovery from the host terminal, only if the service query is empty:

~~~text
<copy>
sudo podman exec -it truedb /bin/bash
</copy>
~~~

At the `truedb` container prompt, run the following commands:

~~~text
<copy>
export ORACLE_SID=TRUEDB
sqlplus / as sysdba
alter session set container=ORCLPDB1;
begin
  dbms_service.start_service('SALES1_TC');
end;
/
select name, network_name from v$services where upper(name) = 'SALES1_TC';
exit
exit
</copy>
~~~

If either service-start block reports `ORA-44305`, that service is already running; continue with the service query.

## Task 1: Validate JDBC Routing

Run the supplied BasicApp from the application container:

~~~text
<copy>
cd /stage/clientapp/BasicApp
/stage/jdk-17.0.6/bin/java -cp ojdbc8.jar:. TrueCache 172.20.1.2:1521/sales1 transactions "$DB_PASS"
cd /stage/clientapp
</copy>
~~~

The result identifies the database role used by the read-only operation. When True Cache is configured and the work is marked read-only, the JDBC driver can route eligible read-only queries to True Cache; read-write operations remain on the Primary database.

## Task 2: Compare Primary and True Cache Performance and Lag

In a separate desktop Terminal window, open the Primary container once and start three bounded, update-only workers. Each worker performs a fixed number of updates and exits automatically. Keep this container shell open until you run the cleanup command below in case you interrupt the workers:

~~~text
<copy>
sudo podman exec -it prod /bin/bash
</copy>
~~~

At the `prod` container prompt, run the worker commands:

~~~text
<copy>
export ORACLE_SID=ORCLCDB
: > /tmp/tcwrite.pids

update_accounts() {
  printf '%s\n' \
    "alter session set container=ORCLPDB1;" \
    "update transactions.accounts set balance=balance+1,last_modified_utc=systimestamp where account_id between $1 and $2;" \
    "commit;" \
    "exit" | sqlplus -s / as sysdba >/dev/null 2>&1
}

for worker in 1 2 3; do
  (
    start_id=$((1 + (worker - 1) * 2500))
    end_id=$((worker * 2500))
    for iteration in $(seq 1 20); do
      update_accounts "$start_id" "$end_id"
      sleep 0.15
    done
  ) &
  echo $! >> /tmp/tcwrite.pids
done
cat /tmp/tcwrite.pids
</copy>
~~~

These workers update existing `ACCOUNTS` rows for 20 iterations. They do not add rows to the dataset and stop automatically when the fixed iteration count completes.

From the application-container shell, run the Primary read baseline. This is the reference read-latency measurement for the same workload; TPS is reported as a supporting metric:

~~~text
<copy>
cd /stage/clientapp
READ_ONLY_WORKLOAD=true DIRECT_READ_ONLY=true DISABLE_TRUECACHE_PROPERTY=true URL=172.20.1.2:1521/sales1 THREADS=10 DURATION=30 METRICS_PORT=9092 ./TransactionsApp.sh primary
</copy>
~~~

Run the same read workload directly against True Cache:

~~~text
<copy>
READ_ONLY_WORKLOAD=true DIRECT_READ_ONLY=true DISABLE_TRUECACHE_PROPERTY=true ALLOW_DIRECT_FALLBACK=true DIRECT_FALLBACK_URL=172.20.1.98:1521/SALES1_TC URL=172.20.1.98:1521/SALES1_TC THREADS=10 DURATION=30 METRICS_PORT=9093 ./TransactionsApp.sh truecache
</copy>
~~~

Run both read paths in parallel:

~~~text
<copy>
pkill -f '[T]ransactions_TrueCache' || true
READ_ONLY_WORKLOAD=true DIRECT_READ_ONLY=true DISABLE_TRUECACHE_PROPERTY=true URL=172.20.1.2:1521/sales1 THREADS=10 DURATION=60 METRICS_PORT=9092 ./TransactionsApp.sh primary >/tmp/primary-read.log 2>&1 &
PRIMARY_PID=$!
sleep 2
READ_ONLY_WORKLOAD=true DIRECT_READ_ONLY=true DISABLE_TRUECACHE_PROPERTY=true ALLOW_DIRECT_FALLBACK=true DIRECT_FALLBACK_URL=172.20.1.98:1521/SALES1_TC URL=172.20.1.98:1521/SALES1_TC THREADS=10 DURATION=60 METRICS_PORT=9093 ./TransactionsApp.sh truecache >/tmp/truecache-read.log 2>&1 &
TRUECACHE_PID=$!
wait "$PRIMARY_PID" "$TRUECACHE_PID"
grep -E 'ReadTPS|Read TPS|readNode' /tmp/primary-read.log /tmp/truecache-read.log | tail -20
</copy>
~~~

While the comparison runs, open another desktop Terminal window and enter the True Cache container once. Then run the following diagnostics. They capture replication lag, cache-hit ratios, and fetch latency while the read workload is active:

~~~text
<copy>
sudo podman exec -it truedb /bin/bash
</copy>
~~~

At the `truedb` container prompt, run the diagnostics:

~~~text
<copy>
export ORACLE_SID=TRUEDB
sqlplus / as sysdba
alter session set container=ORCLPDB1;
set pages 100 lines 240
select name, value from v$dataguard_stats where lower(name) in ('transport lag','apply lag') order by name;
select name, value, unit from v$true_cache_stat where lower(name) in ('true cache hit ratio','ram buffer hit ratio','flash buffer hit ratio','prewarm progress','apply finish time','apply lag','transport lag','estimated startup time','single block fetch latency','multiblock fetch latency','list of blocks fetch latency') order by name;
exit
exit
</copy>
~~~

Expected output: `v$dataguard_stats` reports the transport and apply lag values, while `v$true_cache_stat` reports cache-hit ratios, prewarm progress, apply timing, and single-block, multiblock, and list-of-blocks fetch latency. The exact values vary with the workload; the important result is that the queries return current statistics while the read paths are active.

Stop the update workers in the original Primary container shell:

~~~text
<copy>
kill $(cat /tmp/tcwrite.pids) 2>/dev/null || true
rm -f /tmp/tcwrite.pids
exit
</copy>
~~~

If you interrupted the worker command, return to the Primary-container shell and run the cleanup command before starting the next task.

The workload output reports read latency, read TPS, and the last read node. The Primary run should identify Primary as its read node, and the direct True Cache run should identify True Cache. The diagnostics show the replication and cache values used to interpret the comparison.

![Full LiveLab performance and lag](images/full-livelab-performance.png " ")

## Task 3: Verify Availability: True Cache Can Continue Serving Eligible Reads During Primary Downtime

Use the application-container shell to start both read paths:

~~~text
<copy>
cd /stage/clientapp
pkill -f '[T]ransactions_TrueCache' || true
READ_ONLY_WORKLOAD=true DIRECT_READ_ONLY=true DISABLE_TRUECACHE_PROPERTY=true URL=172.20.1.2:1521/sales1 THREADS=10 DURATION=120 METRICS_PORT=9092 ./TransactionsApp.sh primary >/tmp/availability-primary.log 2>&1 &
PRIMARY_PID=$!
sleep 2
READ_ONLY_WORKLOAD=true DIRECT_READ_ONLY=true DISABLE_TRUECACHE_PROPERTY=true ALLOW_DIRECT_FALLBACK=true DIRECT_FALLBACK_URL=172.20.1.98:1521/SALES1_TC URL=172.20.1.98:1521/SALES1_TC THREADS=10 DURATION=120 METRICS_PORT=9093 ./TransactionsApp.sh truecache >/tmp/availability-truecache.log 2>&1 &
TRUECACHE_PID=$!
pgrep -af '[T]ransactions_TrueCache'
</copy>
~~~

From the host terminal, stop Primary:

~~~text
<copy>
sudo podman stop --time 3 prod
sudo podman ps --format 'table {{.Names}}\t{{.Status}}'
</copy>
~~~

From the host terminal, open the True Cache container once:

~~~text
<copy>
sudo podman exec -it truedb /bin/bash
</copy>
~~~

At the `truedb` container prompt, verify its role and read service:

~~~text
<copy>
export ORACLE_SID=TRUEDB
sqlplus / as sysdba
set pages 100 lines 180
select database_role, open_mode from v$database;
alter session set container=ORCLPDB1;
select name, network_name from v$services where upper(name) = 'SALES1_TC';
exit
exit
</copy>
~~~

Review the True Cache read workload from the application container shell:

~~~text
<copy>
grep -E 'ReadTPS|Read TPS|readNode' /tmp/availability-truecache.log | tail -20
</copy>
~~~

Restore Primary from the host terminal:

~~~text
<copy>
sudo podman start prod
for attempt in $(seq 1 36); do
  status=$(sudo podman inspect --format '{{.State.Status}}|{{.State.Health.Status}}' prod 2>/dev/null || true)
  echo "prod: $status"
  if [ "$status" = "running|healthy" ]; then
    break
  fi
  sleep 5
done
if [ "$status" != "running|healthy" ]; then
  echo "prod did not become healthy within 3 minutes; do not continue."
  exit 1
fi
sudo podman ps --format 'table {{.Names}}\t{{.Status}}'
</copy>
~~~

Wait for `prod` to report `running|healthy` before continuing. The database may need several minutes to complete startup after the container is restored.

From the host terminal, open the Primary container once:

~~~text
<copy>
sudo podman exec -it prod /bin/bash
</copy>
~~~

At the `prod` container prompt, verify its role and service:

~~~text
<copy>
export ORACLE_SID=ORCLCDB
sqlplus / as sysdba
set pages 100 lines 180
select database_role, open_mode from v$database;
alter session set container=ORCLPDB1;
declare
  l_active number;
begin
  select count(*) into l_active from v$active_services where upper(name) = 'SALES1';
  if l_active = 0 then
    dbms_service.start_service('SALES1');
  end if;
end;
/
select name, network_name from v$services where upper(name) = 'SALES1';
exit
exit
</copy>
~~~

The SQL block starts `SALES1` only when it is not already active, then verifies the service row. Continue only when the query returns `SALES1`.

After Primary is healthy again, return to the application-container shell, wait for both read processes to finish, and review their final read-node output before closing the shell:

~~~text
<copy>
wait "$PRIMARY_PID" "$TRUECACHE_PID"
exit
</copy>
~~~

While the True Cache container and read service remain available and replicated data has been applied, the True Cache process should report eligible reads while Primary is stopped. The Primary process should resume after Primary is restored.

![Full LiveLab availability test](images/full-livelab-availability.png " ")

## Next Lab

Continue to [New Feature: Semantic Cache with Vector Search](../vector-search/vector-search_dbw26.md) for the native vector table, deterministic payment feature vectors, vector index, and payment-investigation queries.

## Learn More

[Oracle True Cache documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/odbtc/using-oracle-true-cache-your-applications.html)

## Acknowledgements

* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
