# Generate Incidents for AHF to Detect and gather diagnostic collections for

## Introduction

Welcome to the "Generate Database and Clusterware Incidents" lab.  In this lab you will be guided through various tasks to generate incidents your Oracle RAC Database.  
You will then in later labs use AHF to gather diagnostics and/or triage those incidents.


Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Log in to the **oracle user** and confirm you environment is set up to connect to the database
* Connect to the Database and :-
	* Generate a dummy ORA-00600 Assert that will generate an ADR Incident.
	* Generate a dummy ORA-04030 Error that will generate an ADR Incident.
	* Change a database init parameter for AHF to discover


### Prerequisites
- You are connected to one of the DB System Nodes as described in **Lab 1: Connect to your DB System**

## Task 1: Reduce the time AHF waits to start an automatic collection after incident detection
AHF normally waits 5 minutes from the time an incident is detected to the time it starts the collection.  
This is done as often multiple errors are reported together and we want to ensure the collection gathers all the relevant information

1. Set the wait time for an auto collection to start to 60 seconds to reduce wait time in the lab.

	```
	<copy>
	tfactl set minTimeForAutoDiagCollection=60 -c
	</copy>
	```
	Example Command Output:
	<pre>
	Successfully set minTimeForAutoDiagCollection=60
	.--------------------------------------.
	|         lldbcs61                     |
	+------------------------------+-------+
	| Configuration Parameter      | Value |
	+------------------------------+-------+
	| minTimeForAutoDiagCollection | 60    |
	'------------------------------+-------'
	</pre>

## Task 2: Log in to the oracle user (if you are not already oracle) and confirm you environment is set up to connect to the database with `sqlplus`

1.	If you are not already the oracle user then you can `sudo su` from both "ops" and "root users"

	```
	<copy>
	sudo su - oracle
	</copy>
	```

3.	Check the oracle user environment is set up to access your database using **sqlplus**

	```
	<copy>
	env | grep ORA
	</copy>
	```
	Example Command Output:  
	<pre>
	ORACLE_UNQNAME=racUXBVI_ngt_lhr
	ORACLE_SID=racUXBVI1
	ORACLE_HOME=/u01/app/oracle/product/19.0.0.0/dbhome_1	
	</pre>

	You should see that the **ORACLE\_SID** and **ORACLE\_HOME** environment variables are set 

## Task 3: Connect to the database with `sqlplus` and generate some errors

1. Connect to the datase instance with **sqlplus** with sysdba role
	```
	<copy>
	sqlplus / as sysdba
	</copy>
	```
	
	Example Command Output:  
	<pre>
	SQL*Plus: Release 19.0.0.0.0 - Production on Fri Jul 12 03:37:16 2024
	Version 19.23.0.0.0

	Copyright (c) 1982, 2023, Oracle.  All rights reserved.


	Connected to:
	Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
	Version 19.23.0.0.0

	SQL>
	</pre>

2. Generate a dummy ORA-00600 Error

	At the SQL> prompt type ( Use the Copy )
	```
	<copy>
	exec dbms_system.ksdwrt(dbms_system.alert_file,'ORA-00600: internal error code, arguments: [kgb], [livelabs1], [17], [], [], [], [], [], [], [], [], []');
	</copy>
	```
	Example Command Output:  
	<pre>
	Statement processed.
	</pre>

3. Generate a Dummy ORA-04031 Error

	At the SQL> prompt type ( Use the Copy )
	```
	<copy>
	exec dbms_system.ksdwrt(dbms_system.alert_file,'ORA-04031: unable to allocate 90342 bytes of shared memory ("","","","")');
	</copy>
	```
	Example Command Output:  
	<pre>
	Statement processed.
	</pre>

4. Change a database init parameter
	At the SQL> prompt type
	```
	<copy>
	alter system set parallel_threads_per_cpu=4;
	</copy>
	```

	Example Command Output:  
	<pre>
	Statement processed.
	</pre>

5. Exit from sqlplus
	At the SQL> prompt type
	```
	<copy>
	exit
	</copy>
	```

	Example Command Output:  
	<pre>
	Disconnected from Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
	Version 19.24.0.0.0
	</pre>

6. Check that AHF detected the incidents using `tfactl events`  
	
	```
	<copy>
	tfactl events -last 1h -node local
	</copy>
	```
	Example Command Output:  

	<pre>
	<u>Output from host : lldbcs61</u>
	Event Summary:
	INFO    :2
	ERROR   :2
	WARNING :0

	Event Timeline:
	[Jul/12/2024 03:39:31.000 UTC]: [db.racuxbvi_ngt_lhr.racUXBVI1]: ORA-00600: internal error code, arguments: [kgb], [livelabs1], [17], [], [], [], [], [], [], [], [], []
	[Jul/12/2024 03:40:19.000 UTC]: [db.racuxbvi_ngt_lhr.racUXBVI1]: ORA-04031: unable to allocate  bytes of shared memory (,,,)
	</pre>

	
You may now [proceed to the next lab](#next).

## Acknowledgements
* **Authors** - Bill Burton, Troy Anthony
* **Contributors** - Nirmal Kumar, Robert Pastijn
* **Last Updated By/Date** - Bill Burton, July 2024
