# Shutdown the TimesTen cache and instance

## Introduction

In this final lab you will cleanly shutdown the Timesten cache and the TimesTen instance that manages it.

Estimated Time: **2 minutes**

### Objectives

- Stop the Cache Agent
- Stop the TimesTen instance

### Prerequisites

This lab assumes that you have:

- Completed all the previous labs in this workshop, in sequence.

## Task 1: Connect to the environment

If you do not already have an active terminal session, connect to the OCI compute instance and open a terminal session, as the user **oracle**. In that terminal session, connect to the TimesTen host (tthost1) using ssh.

## Task 2: Stop the cache agent

Check the current status of the TimesTen database:

**ttStatus**

```
[oracle@tthost1 livelab]$ ttStatus
TimesTen status report as of Mon Jun 13 13:33:24 2022

Daemon pid 256 port 6624 instance ttinst
TimesTen server pid 263 started on port 6625
------------------------------------------------------------------------
------------------------------------------------------------------------
Data store /tt/db/sampledb
Daemon pid 256 port 6624 instance ttinst
TimesTen server pid 263 started on port 6625
There are 20 connections to the data store
Shared Memory Key 0x03009db0 ID 2
PL/SQL Memory Key 0x02009db0 ID 1 Address 0x5000000000
Type            PID     Context             Connection Name              ConnID
Cache Agent     388     0x0000000001a1f040  Marker(139835503965952)           5
Cache Agent     388     0x00007f2de8020bf0  LogSpaceMon(139835506071296)      4
Cache Agent     388     0x00007f2df41497a0  Garbage Collector(139835502913    6
Cache Agent     388     0x00007f2df801f400  Timer                             3
Cache Agent     388     0x00007f2df8237990  Refresher(D,2000)                10
Cache Agent     388     0x00007f2df8378090  Refresher(S,2000)                 9
Cache Agent     388     0x00007f2e7401fbe0  BMReporter(139835497711360)       8
Cache Agent     388     0x00007f2e7807cec0  Handler                           2
Subdaemon       261     0x0000000002229fb0  Manager                        2047
Subdaemon       261     0x00000000022aaf30  Rollback                       2046
Subdaemon       261     0x0000000002329da0  Aging                          2041
Subdaemon       261     0x00007f8f58000b60  Checkpoint                     2042
Subdaemon       261     0x00007f8f5807ffb0  HistGC                         2039
Subdaemon       261     0x00007f8f60000b60  Monitor                        2044
Subdaemon       261     0x00007f8f6007ffb0  IndexGC                        2038
Subdaemon       261     0x00007f8f64000b60  Deadlock Detector              2043
Subdaemon       261     0x00007f8f6407ffb0  Log Marker                     2040
Subdaemon       261     0x00007f8f68000b60  Flusher                        2045
Subdaemon       261     0x00007f8f680a1bb0  XactId Rollback                2037
Subdaemon       261     0x00007f8fd40b6080  Garbage Collector              2036
Open for user connections
Replication policy  : Manual
Cache Agent policy  : Manual
Cache agent is running.
PL/SQL enabled.
------------------------------------------------------------------------
Accessible by group oinstall
End of report 
```

The database is active and is loaded in memory, because the cache agent is connected to it.

Stop the cache agent:

**ttAdmin -cacheStop sampledb**

```
[oracle@tthost1 livelab]$ ttAdmin -cacheStop sampledb
RAM Residence Policy            : inUse
Replication Agent Policy        : manual
Replication Manually Started    : False
Cache Agent Policy              : manual
Cache Agent Manually Started    : False
Database State                  : Open
```

Check the status again:

**ttStatus**

```
TimesTen status report as of Mon Jun 13 13:35:38 2022

Daemon pid 256 port 6624 instance ttinst
TimesTen server pid 263 started on port 6625
------------------------------------------------------------------------
------------------------------------------------------------------------
Data store /tt/db/sampledb
Daemon pid 256 port 6624 instance ttinst
TimesTen server pid 263 started on port 6625
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

## Task 3: Stop the TimesTen instance

Stop the TimesTen instance (i.e. stop the main daemon):

**ttDaemonAdmin -stop**

```
[oracle@tthost1 livelab]$ ttDaemonAdmin -stop
TimesTen Daemon (PID: 190, port: 6624) stopped.
```
## Task 4: Finally

Log out of the TimesTen host:

**exit**

```
[oracle@tthost1 livelab]$ exit
logout
Connection to tthost1 closed.
[oracle@ttlivelabvm:~]$
```

Congratulations, *you have completed the workshop*.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022

