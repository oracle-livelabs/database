# Listener Operations

## Introduction

This lab shows how to perform listener operations, such as starting and stopping the listener, checking the listener status, and so on, using the listener control utility.

Estimated Time: 10 minutes

### Objectives

Check the listener status, stop the listener, restart the listener, and view listener configuration from the command line. 

### Prerequisites

This lab assumes you have -
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup

## Task 1: Set the Environment

To connect to Oracle Database and run SQL commands, set the environment first.

1. Log in to your host as *oracle*, the user who can perform database administration.

1. Open a terminal window and run the command *oraenv* to set the environment variables.

	```
	$ <copy>. oraenv</copy>
	```

1. Enter the Oracle SID, for this lab it is *CDB1*.

	```
	ORACLE_SID = [oracle] ? <copy>CDB1</copy>
	The Oracle base has been set to /opt/oracle
	```

	This command also sets the Oracle home path to `/opt/oracle/product/21c/dbhome_1`.

	> **Note:** Oracle SID is case sensitive.  

1. Change the current working directory to `$ORACLE_HOME/bin`. This is the directory where the listener control utility is located.

	```
	$ <copy>cd /opt/oracle/product/21c/dbhome_1/bin</copy>
	```

You have set the environment variables for the active terminal session. You can now connect to Oracle Database and run the commands.

> **Note:** Every time you open a new terminal window, you must set the environment variables to connect to Oracle 	Database from that terminal. Environment variables from one terminal do not apply automatically to other terminals.

Alternatively, you may run the script file `.set-env-db.sh` from the home location and enter the number for `ORACLE_SID`. It sets the environment variables automatically.

## Task 2: View the Listener Configuration

Run the `lsnrctl status` command to check whether the listener is up and running and to view the listener configuration. 

1. From `$ORACLE_HOME/bin`, view the listener configuration and the status. 

	```
	$ <copy>./lsnrctl status</copy>
	```

	## Output

	The values may differ depending on the system you are using.

	```
	LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 17-FEB-2022 14:07:14

	Copyright (c) 1991, 2021, Oracle.  All rights reserved.

	Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost.example.com)(PORT=1521)))
	STATUS of the LISTENER
	------------------------
	Alias                     LISTENER
	Version                   TNSLSNR for Linux: Version 21.0.0.0.0 - Production
	Start Date                15-FEB-2022 19:44:25
	Uptime                    1 days 18 hr. 22 min. 48 sec
	Trace Level               off
	Security                  ON: Local OS Authentication
	SNMP                      OFF
	Listener Parameter File   /opt/oracle/homes/OraDB21Home1/network/admin/listener.ora
	Listener Log File         /opt/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
	Listening Endpoints Summary...
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost.example.com)(PORT=1521)))
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=localhost.example.com)(PORT=5506))(Security=(my_wallet_directory=/opt/oracle/admin/CDB1/xdb_wallet))(Presentation=HTTP)(Session=RAW))
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=localhost.example.com)(PORT=5507))(Security=(my_wallet_directory=/opt/oracle/admin/CDB1/xdb_wallet))(Presentation=HTTP)(Session=RAW))
	Services Summary...
	Service "CDB1" has 1 instance(s).
	  Instance "CDB1", status READY, has 1 handler(s) for this service...
	Service "CDB1XDB" has 1 instance(s).
	  Instance "CDB1", status READY, has 1 handler(s) for this service...
	Service "cd8d29dc40fd7370e0533800000ab923" has 1 instance(s).
	  Instance "CDB1", status READY, has 1 handler(s) for this service...
	Service "pdb1" has 1 instance(s).
	  Instance "CDB1", status READY, has 1 handler(s) for this service...
	The command completed successfully
	```

	> The Listener Control Utility displays a summary of listener configuration settings, listening protocol addresses, and the services registered with the listener.

If Oracle Database has configured the PDB, you will see a service for each PDB running on the Oracle Database instance.

## Task 3: Stop and Start the Listener

The listener starts automatically when the host system turns on. If a problem occurs in the system or if you manually stop the listener, then you can start the listener again from the command line. 

1. From `$ORACLE_HOME/bin`, stop the listener first, if it is already running. 

	```
	$ <copy>./lsnrctl stop</copy>
	```

	## Output

	The values may differ depending on the system you are using.

	```
	LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 17-FEB-2022 14:12:41

	Copyright (c) 1991, 2021, Oracle.  All rights reserved.

	Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost.example.com)(PORT=1521)))
	The command completed successfully
	```

	Now that you have stopped the listener, run the following steps to check if you can still connect to your Oracle Database.

1. From `$ORACLE_HOME/bin`, log in to SQL Plus as the *SYSTEM* user using the service name *CDB1*.

	```
	$ <copy>./sqlplus system@CDB1</copy>
	```

	## Output

	```
	SQL*Plus: Release 21.0.0.0.0 - Production on Thu Feb 17 14:20:00 2022
	Version 21.4.0.0.0

	Copyright (c) 1982, 2021, Oracle.  All rights reserved.

	Enter password:
	ERROR:
	ORA-12541: TNS:no listener
	```

	This error indicates that the listener is not running. You can exit the prompt by pressing **Ctrl + C** followed by **Enter**. 

	> **Note:** If the listener is not running on the host, Oracle Enterprise Manager Cloud Control (Oracle EMCC) returns an I/O error indicating failure to establish connection with your Oracle Database.

1. Start the listener again from the $ORACLE_HOME/bin directory.

	```
	$ <copy>./lsnrctl start</copy>
	```

	## Output

	The values may differ depending on the system you are using.

	```
	LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 17-FEB-2022 14:23:59

	Copyright (c) 1991, 2021, Oracle.  All rights reserved.

	Starting /opt/oracle/product/21c/dbhome_1/bin/tnslsnr: please wait...

	TNSLSNR for Linux: Version 21.0.0.0.0 - Production
	System parameter file is /opt/oracle/homes/OraDB21Home1/network/admin/listener.ora
	Log messages written to /opt/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
	Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost.example.com)(PORT=1521)))
	Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

	Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost.example.com)(PORT=1521)))
	STATUS of the LISTENER
	------------------------
	Alias                     LISTENER
	Version                   TNSLSNR for Linux: Version 21.0.0.0.0 - Production
	Start Date                17-FEB-2022 14:23:59
	Uptime                    0 days 0 hr. 0 min. 0 sec
	Trace Level               off
	Security                  ON: Local OS Authentication
	SNMP                      OFF
	Listener Parameter File   /opt/oracle/homes/OraDB21Home1/network/admin/listener.ora
	Listener Log File         /opt/oracle/diag/tnslsnr/localhost/listener/alert/log.xml
	Listening Endpoints Summary...
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost.example.com)(PORT=1521)))
	  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
	The listener supports no services
	The command completed successfully
	```

	You have started the listener on the host again.

	> **Note:** To access Oracle Database, the listener must be up and running. 

1. Check the status of the listener as explained in *Task 2: View the Listener Configuration* of this lab.

	```
	$ <copy>./lsnrctl status</copy>
	```

	You will see an output indicating that the listener service is running.

1. Once again log in to SQL Plus as *SYSTEM* using the password and service name.   
   For this lab, the password is *Ora_DB4U* and the service name is *CDB1*.

	```
	$ <copy>./sqlplus system/Ora_DB4U@CDB1</copy>
	```

	## Output

	The values may differ depending on the system you are using.

	```
	SQL*Plus: Release 21.0.0.0.0 - Production on Thu Feb 17 14:33:21 2022
	Version 21.4.0.0.0

	Copyright (c) 1982, 2021, Oracle.  All rights reserved.

	Enter password:
	Last Successful login time: Thu Feb 17 14:07:14 +00:00

	Connected to:
	Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
	Version 21.4.0.0.0
	```

Verify that you can now connect to your Oracle Database.

Congratulations! You have successfully completed this workshop on *Network Environment Configuration for Oracle Database 21c*. 

In this workshop, you have learned how to configure the https port for CDB and PDB, start and stop the listener, and view the listener configuration. 

## Acknowledgements

- **Author**: Manish Garodia, Principal User Assistance Developer, Database Technologies

- **Contributors**: Suresh Rajan, Prakash Jashnani, Malai Stalin, Subhash Chandra, Dharma Sirnapalli, Subrahmanyam Kodavaluru, Manisha Mati

- **Last Updated By/Date**: Manish Garodia, February 2022


 
