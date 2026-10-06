# Performance Comparison and Lag Observability

## Introduction

Compare read latency on Primary and True Cache using the same 10-thread, 30-second workload. Use TPS as a supporting measure, then inspect replication and cache statistics.

This baseline does not start background write or read-pressure jobs. The optional exercise at the end makes one small, committed Primary update so you can inspect its replication separately.

*Estimated Time:* 15 minutes.

### Objectives

- Compare read latency and throughput with consistent run settings.
- Identify which database served each run.
- Inspect transport lag, apply lag, and True Cache statistics.

### Prerequisites

Complete the JDBC lab and cache warmup. Start with a host terminal. Let any FastLab or earlier workload finish before starting this comparison.

## Task 1: Set the Run Options

1. Load the database credentials and enter the application container.

    ```bash
    <copy>
    source /home/opc/.truecache_lab_env
    sudo podman exec -e DB_PASS="$DB_PASS" -it appclient /bin/bash
    </copy>
    ```

2. At the application-container prompt, set the shared options once for this session.

    ```bash
    <copy>
    cd /stage/clientapp
    export THREADS=10 DURATION=30
    export READ_ONLY_WORKLOAD=true DIRECT_READ_ONLY=true
    export DISABLE_TRUECACHE_PROPERTY=true
    </copy>
    ```

    These runs compare direct read connections to the two services. The previous JDBC lab demonstrates automatic driver routing; this exercise deliberately isolates each target.

## Task 2: Run Primary, Then True Cache

1. Run the Primary baseline and wait for completion.

    ```bash
    <copy>
    URL=172.20.1.2:1521/sales1 METRICS_PORT=9092 \
      ./TransactionsApp.sh primary
    </copy>
    ```

    **Expected:** the output identifies the Primary read node. Record read p50, p95, p99, and TPS from the completed run.

2. Run the same workload on True Cache and wait for completion.

    ```bash
    <copy>
    URL=172.20.1.98:1521/SALES1_TC METRICS_PORT=9093 \
    ALLOW_DIRECT_FALLBACK=true DIRECT_FALLBACK_URL=172.20.1.98:1521/SALES1_TC \
      ./TransactionsApp.sh truecache
    </copy>
    ```

    **Expected:** the output identifies the True Cache read node. Record the same four metrics. The direct-connection flags are retained from the current guide for compatibility with the supplied client.

3. Compare your results. Lower latency is better; higher TPS indicates greater throughput for this workload.

    | Metric | Primary | True Cache |
    | --- | --- | --- |
    | Read p50 (ms) | Record your result | Record your result |
    | Read p95 (ms) | Record your result | Record your result |
    | Read p99 (ms) | Record your result | Record your result |
    | Read TPS | Record your result | Record your result |

    Keep sub-millisecond precision when the application reports it. Results depend on cache state, shared CPU resources, and other activity; a fixed improvement is not a pass criterion. Do not compare runs with different thread counts or background loads as an equivalent baseline.

4. Type `exit` to return to the host. This also discards the session's exported run options.

## Task 3: Inspect Lag and Cache Statistics

1. From the host terminal, enter True Cache.

    ```bash
    <copy>
    sudo podman exec -it truedb /bin/bash
    </copy>
    ```

2. At the container prompt, open SQL*Plus.

    ```bash
    <copy>
    ORACLE_SID=TRUEDB sqlplus / as sysdba
    </copy>
    ```

3. At `SQL>`, inspect the current statistics.

    ```sql
    <copy>
    alter session set container=ORCLPDB1;
    select name, value from v$dataguard_stats
    where lower(name) in ('transport lag', 'apply lag')
    order by name;
    select name, value, unit from v$true_cache_stat order by name;
    </copy>
    ```

    **Expected:** current replication and cache statistics. Zero lag can be normal after the workload finishes. An empty or unavailable value is not proof of zero lag.

4. For the optional exercise below, keep this session open. Otherwise, type `exit` to leave SQL*Plus and `exit` to return to the host.

## Optional Exercise: Observe a Primary Update

This changes the balance of one sample account by 1 and commits it. Use only the disposable lab data. It is a replication demonstration, not a sustained write-pressure benchmark.

Open a second desktop Terminal window and enter Primary.

```bash
<copy>
sudo podman exec -it prod /bin/bash
</copy>
```

At the container prompt, open SQL*Plus.

```bash
<copy>
ORACLE_SID=ORCLCDB sqlplus / as sysdba
</copy>
```

At `SQL>`, update and inspect the sample row.

```sql
<copy>
alter session set container=ORCLPDB1;
update transactions.accounts
set balance = balance + 1, last_modified_utc = systimestamp
where account_id = 1;
commit;
select account_id, balance, last_modified_utc
from transactions.accounts where account_id = 1;
</copy>
```

**Expected:** one row updated. Return to the True Cache SQL*Plus session and inspect that row and the lag values.

```sql
<copy>
select account_id, balance, last_modified_utc
from transactions.accounts where account_id = 1;
select name, value from v$dataguard_stats
where lower(name) in ('transport lag', 'apply lag')
order by name;
</copy>
```

The row should eventually match Primary. A single update may apply before you can observe nonzero lag; that is normal. Do not infer replication delay from how long it takes to switch windows. If it does not converge, record the output and investigate before continuing.

Leave SQL*Plus and then the container in both windows with `exit` at each prompt. No background workers were started, so there are no worker processes to clean up.

## Completion

Both read runs reached the intended database, and you recorded comparable latency/TPS results and inspected the statistics. Continue to [Availability and Failover](../availability/availability_dbw26.md).

## Acknowledgements

* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
