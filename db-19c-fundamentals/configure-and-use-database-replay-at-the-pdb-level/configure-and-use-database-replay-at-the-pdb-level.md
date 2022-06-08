# Configure and use Database Replay at the PDB level

## Introduction

In this lab, you will learn how to capture a workload from PDB1 and replay the workload at the PDB level into PDB19. The Database Replay operations can be performed at the PDB level.

You can use Database Replay to capture a workload on the production system and replay it on a test system with the exact timing, concurrency, and transaction characteristics of the original workload. This enables you to test the effects of a system change without affecting the production system.

When workload capture is enabled, all external client requests directed to Oracle Database are tracked and stored in binary files—called capture files—on the file system. You can specify the location where the capture files will be stored. Once workload capture begins, all external database calls are written to the capture files. The capture files contain all relevant information about the client request, such as SQL text, bind values, and transaction information. Background activities and database scheduler jobs are not captured. These capture files are platform independent and can be transported to another system.
* `EXEC DBMS`: one of a set of Oracle Streams packages, provides subprograms for starting, stopping, and configuring a capture process. The source of the captured changes is the redo logs, and the repository for the captured changes is a queue.

After a captured workload has been preprocessed, it can be replayed on a test system. During the workload replay phase, Oracle Database performs the actions recorded during the workload capture phase on the test system by re-creating all captured external client requests with the same timing, concurrency, and transaction dependencies of the production system.

The workload capture report and workload replay report provide basic information about the workload capture and replay, such as errors encountered during replay and data divergence in rows returned by DML or SQL queries. A comparison of several statistics—such as database time, average active sessions, and user calls—between the workload capture and the workload replay is also provided.

Finally, A workload capture can be enabled and a workload replay can be started at the pluggable database (PDB) level.
* `wrc client`: The replay client is a multithreaded program (an executable named wrc located in the `$ORACLE_HOME/bin` directory) where each thread submits a workload from a captured session. Before replay begins, the database will wait for replay clients to connect. At this point, you need to set up and start the replay clients, which will connect to the replay system and send requests based on what has been captured in the workload.


Estimated Time: 25 minutes

### Objectives

In this lab, you will:
* Prepare your environment
* Start capturing data `workload.sh` from `PDB1` using the Database Replay Procedure
* Process the capture files in `PDB19` 
* Initialize and prepare the replay
* Replay the captured workload in `PDB19` using the `wrc` clients
* Verify that the captured workload is executing on `PDB19`
* Clean your environment

### Prerequisites

This lab assumes you have:
* Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

In this lab, you require two PDBs. The `workshop-installed` compute instance comes with a container database (CDB1) that has one PDB already created called PDB1. In this task, you will log in to PDB1 and create the logical directories where the replay capture files will be stored.

You will also be working in two seperate terminal windows labelled **session 1** and **session 2**, where you will capture the workload and run the workload respectively.

1. Open up the terminal window for **session 1**.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

3. Execute the `DBReplay.sh` shell script in session 1. The script re- creates `PDB1` and `PDB19`, removing any existing database replay files.

    ```
    $ <copy>$HOME/labs/19cnf/DBReplay.sh</copy>
    ```

4. In **session 1**, log in to `PDB19` and capture the workload data by using Database Replay.

    ```
    $ <copy>sqlplus system@PDB19</copy>
    
    Enter password: password

    SQL>
    ```
5. The Database Replay capture creates files in a directory. Create the directory for the captured files.

    ```
    SQL> <copy>HOST mkdir -p /home/oracle/PDB1/replay</copy>
    ```

6. Create the logical directory.

    ```
    SQL> <copy>CREATE OR REPLACE DIRECTORY oltp AS '/home/oracle/PDB1/replay';</copy>

    Directory created.
    ```

## Task 2: Start capturing data `workload.sh` from `PDB1` using the Database Replay Procedure

1. Start capturing data with the Database Replay procedure.
    
    ```
    SQL> <copy>EXEC DBMS_WORKLOAD_CAPTURE.START_CAPTURE ( -
        name => 'OLTP_peak', - 
        dir => 'OLTP')</copy>
    > >
    PL/SQL> procedure successfully completed.
    ```

2. Open another terminal window, **session 2**. 

3. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

4. During the capture, in **session 2** you will execute the workload on `PDB1` by executing the `$HOME/labs/19cnf/workload.sh` shell script.

    ```
    $ <copy>$HOME/labs/19cnf/workload.sh</copy>
    ```

5. When you think the workload is sufficient for replay testing, stop the capture in **session 1**.

    ```
    SQL> <copy>EXEC DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE ()</copy>

    PL/SQL> procedure successfully completed
    ```

5. Exit SQL*Plus in **session 1**. 

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 3: Process the capture files in `PDB19`

As in the normal process of Database Replay, after capturing the workload into files, you process the capture files. You will replay the capture files in `PDB19`.

1. Log into PDB19 as `system`.

    ```
    $ <copy>sqlplus system@PDB19</copy> 
    
    Enter password: password
    ```

2. Create the logical directory in `PDB19` for processing and initializing the capture files stored in `$HOME/labs/19cnf/PDB1/replay` to be replayed.

    ```
    SQL> <copy>CREATE OR REPLACE DIRECTORY oltp AS '/home/oracle/PDB1/replay';</copy>

    Directory created.
    ```

3. Process the capture files.

    ```
    SQL> <copy>EXEC DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE ( -
        capture_dir => 'OLTP')</copy>
    >
    PL/SQL> procedure completed successfully.
    ```

## Task 4: Initialize and prepare the replay

1. Initialize the replay.

    ```
    SQL> <copy>EXEC DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY ( -
        replay_name => 'R', replay_dir => 'OLTP')</copy>
    
    PL/SQL procedure successfully completed.
    ```

2. Prepare the replay.

    ```
    SQL> <copy>EXEC DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY ()</copy>

    PL/SQL> procedure successfully completed.
    ```

## Task 5: Replay the captured workload in `PDB19` using the `wrc` clients

You are ready to start workload clients to replay the captured workload in `PDB19` with `wrc` clients.

1. In **session 2**, if the workload is still not finished, interrupt the `$HOME/labs/19cnf/workload.sh` shell script using `ctrl + z`, quit the SQL*Plus session, and start the `wrc` process into `PDB19`.

    > **Note:** Replay time stamps may be different then the one's shown below.


2. Start the `wrc` process.
    ```
    $ <copy>wrc REPLAYDIR=/home/oracle/PDB1/replay USERID=system SERVER=PDB19</copy>

    ...
    password: password
    Wait for the replay to start (11:40:35)
    ```

3. The `wrc` client is waiting for Database Replay to start in the `PDB`. In **session 1**, execute the `START_REPLAY` procedure.

    ```
    SQL> <copy>exec DBMS_WORKLOAD_REPLAY.START_REPLAY ()</copy>

    PL/SQL> procedure successfully completed.

    SQL>
    ```
4. As soon as the Database Replay procedure is started in `PDB19`, the client starts replaying.

## Task 6: Verify that the captured workload is executing on `PDB19`

1. Meanwhile, in **session 1**, verify that the client is executing on `PDB19`.

    ```
    SQL> <copy>CONNECT system@PDB19</copy>
    
    Enter password: password
    
    Connected.
    ```

    ```
    SQL> <copy>SELECT username, con_id, module
        FROM  v$session
        WHERE username <> 'SYS' AND con_id <> 0;</copy>

    
    USERNAME     CON_ID      MODULE
    -----------  ----------  -----------------
    SYSTEM                5  WRC$
    SYSTEM                5  SQL*Plus
    ```

    ```
    SQL> <copy>EXIT</copy>
    ...
    $
    ```
## Task 7: Reset your environment

When the `wrc` client finally completes, `EXIT` out of **session2** and execute both the `$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh` and `$HOME/labs/19cnf/DBReplay.sh` shell script in **session 1** to drop and reset your `CDB1` as well as remove the Database Replay capture files.
1. Reset PDBs in CDB1.
    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

2. Remove Database Replay capture files.

    ```
    $ <copy>$HOME/labs/19cnf/DBReplay.sh</copy>
    ```

    You may now **proceed to the next lab**.


## Learn More

- [Introduction to Database Replay](https://docs.oracle.com/en/database/oracle/oracle-database/19/ratug/introduction-to-database-replay.html)
- [Replaying a Database Workload](https://docs.oracle.com/en/database/oracle/oracle-database/19/ratug/replaying-a-database-workload.html)

## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Contributor** - Ethan Shmargad, Santa Monica Specialist Hub
- **Last Updated By/Date** - Ethan Shmargad, Santa Monica Specialist Hub, November 2021

