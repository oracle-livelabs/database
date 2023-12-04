# Measure OLTP performance improvement

## Introduction

In this lab, you use a benchmark program to run a (read-only) OLTP workload against the TimesTen cache and against the Oracle database to illustrate the performance benefit of TimesTen.

You will use a standard TimesTen benchmark program, tptbmOCI, that connects to the target database using the Oracle Call Interface (OCI) API. The program can run against either TimesTen or Oracle and performs the same operations in both cases. For those who may be interested, the source code for the tptbmOCI program is available in the _host VM_ in the directory **~/lab/src**.

**Estimated Lab Time:** 6 minutes

**IMPORTANT:** The following information is presented for you to understand the different pieces around the benchmark for this lab. You don't need to run any commands listed below. The commands to run are from Task 1. 

There is a single table used for this benchmark, APPUSER.VPN_USERS. Here is the definition of the table as it exists in the Oracle database:

```
CREATE TABLE vpn_users
    ( vpn_id             NUMBER(5) NOT NULL
    , vpn_nb             NUMBER(5) NOT NULL
    , directory_nb       CHAR(10 BYTE) NOT NULL
    , last_calling_party CHAR(10 BYTE) NOT NULL
    , descr              CHAR(100 BYTE) NOT NULL
    , PRIMARY KEY (vpn_id, vpn_nb)
    ) ;
```

This table has already been created and populated with 1,000,000 rows of data:

```

Command> select count(*) from vpn_users;
< 1000000 >
1 row found.
Command> select first 10 * from vpn_users;
< 0, 0, 5500      , 000000000 , <placeholderfordescriptionofVPN0extension0>                            >
< 0, 1, 5501      , 000000000 , <placeholderfordescriptionofVPN0extension1>                            >
< 0, 2, 5502      , 000000000 , <placeholderfordescriptionofVPN0extension2>                            >
< 0, 3, 5503      , 000000000 , <placeholderfordescriptionofVPN0extension3>                            >
< 0, 4, 5504      , 000000000 , <placeholderfordescriptionofVPN0extension4>                            >
< 0, 5, 5505      , 000000000 , <placeholderfordescriptionofVPN0extension5>                            >
< 0, 6, 5506      , 000000000 , <placeholderfordescriptionofVPN0extension6>                            >
< 0, 7, 5507      , 000000000 , <placeholderfordescriptionofVPN0extension7>                            >
< 0, 8, 5508      , 000000000 , <placeholderfordescriptionofVPN0extension8>                            >
< 0, 9, 5509      , 000000000 , <placeholderfordescriptionofVPN0extension9>                            >
10 rows found.
```

In the previous labs you creatd a TimesTen readonly cache group for this table and loaded the table rows from Oracle into the cached table.

The benchmark workload (in this case) is 100% read and consists of repeated executions of this SELECT statement:

```
SELECT directory_nb, last_calling_party, descr FROM vpn_users WHERE vpn_id = :id AND vpn_nb= :nb
```

The input values, *id* and *nb*, are randomly generated for each execution of the statement such that they fall within the range of the values in the table. Each execution of the statement retrieves a randomly chosen row.

You will run the benchmark using the following **/tt/livelab/bin/runBenchmark** script:

```
#!/bin/bash

declare -r tptbm=/tt/livelab/bin/tptbmOCI
declare -r bmparams="-nobuild -read 100 -key 1000 -proc 1 -user appuser -xact 1000000 -service"
declare -r oraservice="orclpdb1"
declare -r ttservice="sampledb"

declare usrpwd="appuser"
declare -i ret=0

usage()
{
    echo "usage: runBenchmark { -oracle | -timesten }"
    exit 100
}

runBM()
{
    echo "${tptbm} $*"
    echo ${usrpwd} | ${tptbm} $* | sed -e 's/Enter password for appuser : //'
    return $?
}

if [[ $# -ne 1 ]]
then
    usage
fi

case "$1" in
    "-oracle")
        runBM ${bmparams} ${oraservice}
        ret=$?
        ;;
    "-timesten")
        runBM ${bmparams} ${ttservice}
        ret=$?
        ;;
    *)
        usage
        ;;
esac

exit ${ret}
```

When run using this script, the tptbmOCI program will perform 1,000,000 SELECT operations against random rows. You will run the program twice, once against Oracle and once against the TimesTen cache. The only difference between the two runs is the database service name to connect to, which is defined in the **\$TNS_ADMIN/tnsnames.ora** file (shown below). The service name **ORCLPDB1** connects the program to the Oracle database while **SAMPLEDB** connects it to the local TimesTen cache.

```
ORCLPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dbhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLPDB1)
    )
  )

SAMPLEDB =
  (DESCRIPTION =
    (CONNECT_DATA =
      (SERVER = timesten_direct)
      (SERVICE_NAME = sampledb)
    )
  )

SAMPLEDBCS =
  (DESCRIPTION =
    (CONNECT_DATA =
      (SERVER = timesten_client)
      (SERVICE_NAME = sampledbcs)
    )
  )
```

### Objectives

- Run OLTP workload against Oracle database and measure the throughput.
- Run the same workload against TimesTen and measure the throughput.
- Compare the throughput and latency measurements.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH, and that session is logged into the TimesTen host (tthost1).


## Task 1: Run the benchmark against the Oracle database

Run the program against the Oracle database (this will take a minute or so). Note the throughput achieved (transactions/second):

```
<copy>
/tt/livelab/bin/runBenchmark -oracle
</copy>
```

```
/tt/livelab/bin/tptbmOCI -nobuild -read 100 -key 1000 -proc 1 -user appuser -xact 1000000 -service orclpdb1

Run 1000000 txns with 1 process: 100% read, 0% update, 0% insert, 0% delete

Transactions:          1000000 <1> SQL operations per txn
Elapsed time:             51.2 seconds
Transaction rate:      19523.6 transactions/second
Transaction rate:    1171417.4 transactions/minute
```

## Task 2: Run the benchmark against the TimesTen cache

Run the program against the TimesTen cache and note the throughput achieved:

```
<copy>
/tt/livelab/bin/runBenchmark -timesten
</copy>
```

```
/tt/livelab/bin/tptbmOCI -nobuild -read 100 -key 1000 -proc 1 -user appuser -xact 1000000 -service sampledb

Run 1000000 txns with 1 process: 100% read, 0% update, 0% insert, 0% delete

Transactions:          1000000 <1> SQL operations per txn
Elapsed time:              4.8 seconds
Transaction rate:     206739.7 transactions/second
Transaction rate:   12404382.9 transactions/minute
```

## Task 3: Compare the results

In this example, TimesTen achieved a throughput that was **~10.6x greater** than Oracle database (your results _will_ vary).

As this benchmark used one thread with one connection it is easy to translate the throughput results to average latency values: latency (in seconds) = 1 / TPS. In this case, the average latency for Oracle database was **~51.2 microseconds** and for TimesTen it was **~4.8 microseconds**.

You can now **proceed to the next lab**. 

Keep your primary session open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, October 2023

