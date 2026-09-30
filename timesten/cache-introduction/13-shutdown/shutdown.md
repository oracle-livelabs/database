# Shut down the TimesTen cache and instance

## Introduction

In this final lab, you cleanly shut down the TimesTen cache and the TimesTen instance that manages it.

**Estimated Lab Time:** 3 minutes

### Objectives

- Stop the cache agent.
- Stop the TimesTen instance.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH, and that session is logged into the TimesTen host (tthost1).

## Task 1: Stop the cache agent

1. Check the current status of the TimesTen database:

```
<copy>
ttStatus
</copy>
```

```
TimesTen status report as of Wed Oct 11 23:36:38 2023

Daemon pid 407 port 6624 instance ttinst
TimesTen server pid 414 started on port 6625
------------------------------------------------------------------------
------------------------------------------------------------------------
Data store /tt/db/sampledb
Daemon pid 407 port 6624 instance ttinst
TimesTen server pid 414 started on port 6625
There are 20 connections to the data store
Shared Memory Key 0x0f00307d ID 8
PL/SQL Memory Key 0x0e00307d ID 7 Address 0x5000000000
Type            PID     Context             Connection Name              ConnID
Cache Agent     1146    0x00007f9314021020  Marker(140272157079296)           5
Cache Agent     1146    0x00007f9314254300  LogSpaceMon(140272159184640)      6
Cache Agent     1146    0x00007f9320149ae0  Garbage Collector(140270040340    4
Cache Agent     1146    0x00007f932401f740  Timer                             3
Cache Agent     1146    0x00007f93242ac230  Refresher(D,2000)                10
Cache Agent     1146    0x00007f932799e6a0  Refresher(S,2000)                 9
Cache Agent     1146    0x00007f93a001ff20  BMReporter(140270035138304)       8
Cache Agent     1146    0x00007f93a407d5c0  Handler                           2
Subdaemon       411     0x0000000002666fc0  Manager                        2047
Subdaemon       411     0x0000000002708200  Rollback                       2046
Subdaemon       411     0x00000000027a7330  XactId Rollback                2037
Subdaemon       411     0x00007f5bd4000b60  Monitor                        2043
Subdaemon       411     0x00007f5bd40a0400  Garbage Collector              2036
Subdaemon       411     0x00007f5bdc000b60  Checkpoint                     2042
Subdaemon       411     0x00007f5be0000b60  Deadlock Detector              2044
Subdaemon       411     0x00007f5be4000b60  Flusher                        2045
Subdaemon       411     0x00007f5be40c2410  Aging                          2041
Subdaemon       411     0x00007f5c50000df0  HistGC                         2040
Subdaemon       411     0x00007f5c541e54a0  Log Marker                     2039
Subdaemon       411     0x00007f5c58048860  IndexGC                        2038
Open for user connections
Replication policy  : Manual
Cache Agent policy  : Manual
Cache agent is running.
PL/SQL enabled.
------------------------------------------------------------------------
Accessible by group oinstall
End of report

```

The database is active and is loaded in memory because the cache agent is connected to it.

2. Stop the cache agent:

```
<copy>
ttAdmin -cacheStop sampledb
</copy>
```

```
RAM Residence Policy            : inUse
Replication Agent Policy        : manual
Replication Manually Started    : False
Cache Agent Policy              : manual
Cache Agent Manually Started    : False
Database State                  : Open
```

3. Check the status again:

```
<copy>
ttStatus
</copy>
```

```
TimesTen status report as of Wed Oct 11 23:37:45 2023

Daemon pid 407 port 6624 instance ttinst
TimesTen server pid 414 started on port 6625
------------------------------------------------------------------------
------------------------------------------------------------------------
Data store /tt/db/sampledb
Daemon pid 407 port 6624 instance ttinst
TimesTen server pid 414 started on port 6625
There are no connections to the data store
Open for user connections
Replication policy  : Manual
Cache Agent policy  : Manual
PL/SQL enabled.
------------------------------------------------------------------------
Accessible by group oinstall
End of report
```

The database has been unloaded from memory and is now shut down.

## Task 2: Stop the TimesTen instance

Stop the TimesTen instance (the main daemon):

```
<copy>
ttDaemonAdmin -stop
</copy>
```

```
TimesTen Daemon (PID: 407, port: 6624) stopped.
```

## Task 3: Log out of the TimesTen host

Log out of the TimesTen host:

```
<copy>
exit
</copy>
```

```
logout
Connection to tthost1 closed.
```

You can now **proceed to the Wrap Up**.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, October 2023

