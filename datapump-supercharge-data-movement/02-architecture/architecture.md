# Architecture

## Introduction

In this lab, you will have a look at the components making up Data Pump

Estimated Time: 5 Minutes

### Objectives

In this lab, you will:

* Familiarize yourself with Data Pump components

### Prerequisites

This lab assumes:

- You have completed Lab 1: Initialize Environment

This is an optional lab. You can skip it if you are already familiar with Data Pump architecture.

## Task 1: Check Data Pump objects

Data Pump is a server-side utility. Although you can start a job from a client, the job runs entirely on the database server. Data Pump unloads to and loads from a dump file on the server. This is in contrast to the classic export (`exp`) and import tool (`imp`) which ran on your client and exported to/imported from a local dump file. 

1. Use the *yellow* terminal 🟨. Set the environment to *FTEX* and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```
2. Describe the package `DBMS_DATAPUMP`.

    ```
    <copy>
    desc dbms_datapump
    </copy>
    ```

    * `DBMS_DATAPUMP` is the interface to Data Pump.
    * You can use other tools to start a Data Pump job, however, they all use `DBMS_DATAPUMP`. 
    * In a later lab, you'll try to create a job directly using `DBMS_DATAPUMP`.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> desc dbms_datapump
    PROCEDURE ADD_DEVICE
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ --------
     HANDLE                         NUMBER                  IN
     DEVICENAME                     VARCHAR2                IN
     VOLUMESIZE                     VARCHAR2                IN     DEFAULT
    PROCEDURE ADD_FILE
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ --------
     HANDLE                         NUMBER                  IN
     FILENAME                       VARCHAR2                IN
     DIRECTORY                      VARCHAR2                IN     DEFAULT
     FILESIZE                       VARCHAR2                IN     DEFAULT
     FILETYPE                       NUMBER                  IN     DEFAULT
     REUSEFILE                      NUMBER                  IN     DEFAULT

    (output truncated)

    PROCEDURE TRACE_ENTRY
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ --------
     FACILITY                       VARCHAR2                IN
     MSG                            VARCHAR2                IN
    PROCEDURE WAIT_FOR_JOB
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ --------
     HANDLE                         NUMBER                  IN
     JOB_STATE                      VARCHAR2                OUT   
    ```
    </details>    

3. Describe the package `DBMS_METADATA`.

    ```
    <copy>
    desc dbms_metadata
    </copy>
    ```

    * Data Pump uses `DBMS_METADATA` to extract the definition of objects during an export.
    * Data Pump stores the metadata information in an XML format in the dump file.
    * While importing metadata, Data Pump reads the XML from the dump file and translates that into DDL calls.
    * In a later lab, you'll try to extract metadata from the database.


    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> desc dbms_metadata
    FUNCTION ADD_TRANSFORM RETURNS NUMBER
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ ----------
     HANDLE                         NUMBER                  IN
     NAME                           VARCHAR2                IN
     ENCODING                       VARCHAR2                IN     DEFAULT
     OBJECT_TYPE                    VARCHAR2                IN     DEFAULT
    FUNCTION CHECK_CONSTRAINT RETURNS NUMBER
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ --------
     OBJ_NUM                        NUMBER                  IN

    (output truncated)

    PROCEDURE SET_XMLFORMAT
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ --------
     HANDLE                         NUMBER                  IN
     NAME                           VARCHAR2                IN
     VALUE                          BOOLEAN                 IN     DEFAULT
    PROCEDURE TRANSFORM_STRM
     Argument Name                  Type                    In/Out Default?
     ------------------------------ ----------------------- ------ --------
     INDOC                           CLOB                   IN
     OUTDOC                          CLOB                   IN/OUT
     MDVERSION                       VARCHAR2               IN     DEFAULT
    ```
    </details>  

4. Examine Data Pump processes.

    ```
    <copy>
    select pname from v$process where pname='DM00' or pname like 'DW%';
    </copy>
    ```

    * The query returns no rows because no Data Pump job is running.
    * *DM00* is the control process that coordinates the Data Pump jobs. 
    * The control process can start one or more worker processes. Those are named *DW00*, *DW01*, and so forth.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select pname from v$process where pname='DM00' or pname like 'DW%';
    
    no rows selected
    ```
    </details> 

5. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 2: Data Pump client

Normally, you start a Data Pump job using the command-line clients.

1. Find the Data Pump clients.

    ```
    <copy>
    ll $ORACLE_HOME/bin/*dp
    </copy>
    ```

    * There are two clients. `expdp` for exports, and `impdp` for imports.
    * You can also find the clients in a client installation. This allows you to start a Data Pump job remotely by just having a local client installation.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    -rwxr-x--x. 1 oracle oinstall 235128 May  2 19:09 /u01/app/oracle/product/19/bin/expdp
    -rwxr-x--x. 1 oracle oinstall 242992 May  2 19:09 /u01/app/oracle/product/19/bin/impdp
    ```
    </details> 


2. Examine the command line help.

    ```
    <copy>
    expdp -help
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 19.0.0.0.0 - Production on Fri Apr 25 07:17:10 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    
    The Data Pump export utility provides a mechanism for transferring data objects
    between Oracle databases. The utility is invoked with the following command:
    
    (output truncated)
    
    STOP_WORKER
    Stops a hung or stuck worker.
    
    TRACE
    Set trace/debug flags for the current job.
    ```
    </details>     


You may now *proceed to the next lab*.

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025