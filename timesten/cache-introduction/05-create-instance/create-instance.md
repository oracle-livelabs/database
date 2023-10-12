# Create a TimesTen instance

## Introduction

In this lab, you create a TimesTen instance to host your TimesTen cache database, start the instance, and execute a few simple TimesTen commands.

**Estimated Lab Time:** 6 minutes.

### Objectives

- Create a TimesTen instance.
- Start the instance.
- Run some TimesTen commands.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH.

## Task 1: Connect to the TimesTen host

1. In the terminal session, use ssh to connect to the TimesTen host (**tthost1**):

```
<copy>
ssh tthost1
</copy>
```

```
Your current directory is:  /tt/livelab
[oracle@tthost1 livelab]$
```
2. Review the directory contents:

```
<copy>
ls -l
</copy>
```

```
total 16
drwxr-xr-x. 2 oracle oinstall   22 May 26 13:10 bin
drwxr-xr-x. 2 oracle oinstall 4096 May 26 13:10 queries
drwxr-xr-x. 2 oracle oinstall 4096 May 26 13:10 scripts
-rw-r--r--. 1 oracle oinstall  316 May 10 12:55 tables_appuser.sql
-rw-r--r--. 1 oracle oinstall 3879 May 10 14:31 tables_oe.sql
```

## Task 2: Create a TimesTen instance

A TimesTen _installation_ is comprised of the TimesTen software components. An installation is created by unzipping the TimesTen software distribution media into a suitable location. For this workshop, the TimesTen software distribution media has already been unzipped into the directory **/shared/sw** to create a TimesTen installation named **tt22.1.1.18.0**.

1. List the top level software directory.

```
<copy>
ls -l /shared/sw
</copy>
```

```
total 0
dr-xr-x---. 17 oracle oinstall 277 May  5 22:20 tt22.1.1.18.0
```

2. List the contents of the TimesTen installation top level directory.

```
<copy>
ls -l /shared/sw/tt22.1.1.18.0
</copy>
```

```
total 244
dr-xr-x---. 3 oracle oinstall     89 Sep  7 17:47 3rdparty
dr-xr-x---. 2 oracle oinstall   4096 Sep  7 17:47 bin
dr-xr-x---. 4 oracle oinstall     31 Sep  7 17:47 grid
dr-xr-x---. 3 oracle oinstall    240 Sep  7 17:47 include
dr-xr-x---. 2 oracle oinstall    167 Sep  7 17:47 info
dr-xr-x---. 2 oracle oinstall     26 Sep  7 17:47 kubernetes
dr-xr-x---. 3 oracle oinstall   4096 Sep  7 17:47 lib
dr-xr-x---. 3 oracle oinstall     19 Sep  7 17:47 network
dr-xr-x---. 3 oracle oinstall     18 Sep  7 17:47 nls
dr-xr-x---. 2 oracle oinstall    274 Sep  7 17:47 oraclescripts
dr-xr-x---. 4 oracle oinstall     40 Sep  7 17:47 PERL
dr-xr-x---. 7 oracle oinstall     68 Sep  7 17:47 plsql
-r--r-----. 1 oracle oinstall 241352 Sep  7 17:47 README.html
dr-xr-x---. 2 oracle oinstall     54 Sep  7 17:47 startup
dr-xr-x---. 2 oracle oinstall    103 Sep  7 17:47 support
dr-xr-x---. 3 oracle oinstall     54 Sep  7 17:47 ttoracle_home

```

You can create one or more TimesTen _instances_ from an installation. A TimesTen instance consists of various configuration files, log files and other files that together let you create and manage TimesTen databases. An instance is linked to the installation used to create it, so the installation must not be removed, renamed or modified in any way otherwise the operation of all linked instances will be affected.

When it is operational, a TimesTen instance also includes a set of associated processes that cooperate to manage the TimesTen databases that are owned by the instance.

3. Use the **ttInstanceCreate** command, located in the installation’s **bin** directory, to create a TimesTen instance called **ttinst**:

```
<copy>
/shared/sw/tt22.1.1.18.0/bin/ttInstanceCreate -location /tt/inst -name ttinst -tnsadmin /shared/tnsadmin
</copy>
```

```
Creating instance in /tt/inst/ttinst ...

NOTE: The TimesTen daemon startup/shutdown scripts have not been installed.

The startup script is located here :
	'/tt/inst/ttinst/startup/tt_ttinst'

Run the 'setuproot' script :
	/tt/inst/ttinst/bin/setuproot -install
This will move the TimesTen startup script into its appropriate location.

The 22.1 Release Notes are located here :
  '/shared/sw/tt22.1.1.18.0/README.html'

Instance created successfully.

```

4. Copy the predefined **sys.odbc.ini** configuration file (more on that later) to the instance, overwriting the existing template file:

```
<copy>
cp scripts/sys.odbc.ini /tt/inst/ttinst/conf/sys.odbc.ini
</copy>
```

## Task 3: Start the instance

Whenever you work with TimesTen, it is _essential_ that you have the correct environment. Source the environment file provided within the instance:

```
<copy>
source /tt/inst/ttinst/bin/ttenv.sh
</copy>
```

```
NOTE: TNS_ADMIN is already set in environment - /shared/tnsadmin

LD_LIBRARY_PATH set to /tt/inst/ttinst/install/lib:/tt/inst/ttinst/install/ttoracle_home/instantclient

PATH set to /tt/inst/ttinst/bin:/tt/inst/ttinst/install/bin:/tt/inst/ttinst/install/ttoracle_home/instantclient:/tt/inst/ttinst/install/ttoracle_home/instantclient/sdk:.:/home/oracle/bin:/usr/java/default/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

CLASSPATH set to /tt/inst/ttinst/install/lib/ttjdbc8.jar:/tt/inst/ttinst/install/lib/orai18n.jar:/tt/inst/ttinst/install/lib/timestenjmsxla.jar:/tt/inst/ttinst/install/3rdparty/jms1.1/lib/jms.jar:.

TIMESTEN_HOME set to /tt/inst/ttinst
```

**Note:** The value of the **TIMESTEN_HOME** environment variable determines which TimesTen instance you are working with. 

Start the instance (start the main daemon) so that the instance is usable:

```
<copy>
ttDaemonAdmin -start
</copy>
```

```
TimesTen Daemon (PID: 706, port: 6624) startup OK.
```

You now have an operational TimesTen instance that can host TimesTen databases.

## Task 4: View the database configuration file (sys.odbc.ini)

Examine the database configuration file sys.odbc.ini. This file is the main configuration file for the instance and defines all the databases that will be managed by the instance along with parameters used for connecting to them:

```
<copy>
cat $TIMESTEN_HOME/conf/sys.odbc.ini
</copy>
```

```
[ODBC Data Sources]
sampledb=TimesTen 22.1 Driver
sampledbcs=TimesTen 22.1 Client Driver

[sampledb]
DataStore=/tt/db/sampledb
PermSize=1024
TempSize=256
LogBufMB=256
LogFileSize=256
DatabaseCharacterSet=AL32UTF8
ConnectionCharacterSet=AL32UTF8
OracleNetServiceName=ORCLPDB1

[sampledbcs]
TTC_SERVER_DSN=SAMPLEDB
TTC_SERVER=tthost1-ext/6625
ConnectionCharacterSet=AL32UTF8
```

- The file defines **sampledb** and **sampledbcs** ODBC Data Source Names (DSNs). ODBC is TimesTen’s native API, though TimesTen also provides, or supports, many other commonly used database APIs such as JDBC, Oracle Call Interface, ODP.NET, cx_Oracle (for Python) and node-oracledb (for Node.js).

- The **sampledb** DSN is a _direct mode_, or _server DSN_. It defines the parameters and connectivity for a database hosted by this TimesTen instance. Tools, utilities, and applications running on this host (tthost1) can connect via this DSN using TimesTen’s low latency ‘direct mode’ connectivity mechanism. This database is also accessible remotely using TimesTen’s client-server connectivity.

- The **sampledbcs** DSN is a _client DSN_. It defines connectivity parameters for a server DSN that tools, utilities, and applications can connect to using TimesTen’s client-server connectivity mechanism. In this example, the DSN defines client-server access for the local **sampledb** server DSN.

- All TimesTen APIs support both direct mode and client-server mode and, with some minor exceptions, the functionality is identical regardless of the type of connectivity that you are using.

## Task 5: Run some TimesTen commands

One of the simplest TimesTen utilities is **ttVersion**. This provides basic information about the TimesTen instance:

```
<copy>
ttVersion
</copy>
```

```
TimesTen Release 22.1.1.18.0 (64 bit Linux/x86_64) (ttinst:6624) 2023-09-07T15:13:39Z
  Instance admin: oracle
  Instance home directory: /tt/inst/ttinst
  Group owner: oinstall
  Daemon home directory: /tt/inst/ttinst/info
  PL/SQL enabled.
```
  
Another TimesTen utility is **ttStatus**, which displays information about the instance’s processes and any databases that it hosts:

```
<copy>
ttStatus
</copy>
```

```
TimesTen status report as of Thu May 26 14:02:13 2022

Daemon pid 706 port 6624 instance ttinst
TimesTen server pid 713 started on port 6625
------------------------------------------------------------------------
------------------------------------------------------------------------
Accessible by group oinstall
End of report
```

Currently, there is not much to observe other than the process ids and port numbers used by the instance Daemon and Server processes.

You can now **proceed to the next lab**. 

Keep your terminal session to tthost1 open ready for the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, October 2023

