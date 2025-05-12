# AHF Common Commands 

## Introduction

Welcome to the "Try out some commonly used AHF commands" lab.

In this lab you will be guided through various common AHF tasks.

Estimated Lab Time: 5 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 2: Generate Database and Clusterware Incidents for AHF to Detect and take Action on

## Task 1: Check out some of the AHF DBA tools

When a problem occurs in one of your normally stable database systems the first question you ask is 'What has changed ?'.
AHF keeps track of changes and Events on the system and provides a simple command line interface to view those.
The Insights report will bring all this information in to a dynamic html report which can easily be viewed to help with problem diagnosis.

1. See what has changed in the system in the last hour
    ```
    <copy>
    tfactl changes -last 1h -node local
    </copy>
    ```
    Example Command Output:
    <pre>
    Generating System Changes From 08/08/2024 17:47:05.947 To 08/08/2024 18:47:05.950

    Snapshot Timestamp for Changes:2024-08-08 20:47:05.000000
    Duration for Changes: 1 Hours

    Change Records for host: lldbcs61
[   2024-08-08 18:23:45.000000]: [ racximwm_8wz_bom: racXIMWM1]: Database Parameter parallel_threads_per_cpu Changed From 2 To 4
    </pre>

2. Check the values for some database init parameters across your databases

    ```
    <copy>
    tfactl param -parameter pga
    </copy>
    ```
    Example Command Output:
    <pre>
    .----------------------------------------------------------------------------------------------.
    | Database Parameters                                                                          |
    +------------------+--------------------------------+-----------+----------------------+-------+
    | DATABASE         | HOST                           | INSTANCE  | PARAM                | VALUE |
    +------------------+--------------------------------+-----------+----------------------+-------+
    | raclzhlm_dhh_bom | lldbcs62                       | racLZHLM2 | pga_aggregate_limit  | 6912M |
    | raclzhlm_dhh_bom | lldbcs62                       | racLZHLM2 | pga_aggregate_target | 3456M |
    | raclzhlm_dhh_bom | lldbcs61                       | racLZHLM1 | pga_aggregate_target | 3456M |
    | raclzhlm_dhh_bom | lldbcs61                       | racLZHLM1 | pga_aggregate_limit  | 6912M |
    '------------------+--------------------------------+-----------+----------------------+-------'
    </pre>
    >Note: The parameter option can take a partial string but AHF only knows about parameters that are set at Database startup or are changed from default.

    AHF can also help you check on your major log locations, view or tail those logs and even analyze them.

3.  List out all the major logs AHF has discovered

    ```
    <copy>
    tfactl ls alert
    </copy>
    ```
    Example Command Output:

    <pre>
    <u>Output from host : lldbcs61</u>
    
    /u01/app/grid/diag/asm/+asm/+ASM1/trace/alert_+ASM1.log
    /u01/app/grid/diag/apx/+apx/+APX1/trace/alert_+APX1.log
    /u01/app/oracle/diag/rdbms/racqyfvz_jnq_gru/racQYFVZ1/trace/alert_racQYFVZ1.log
    /u01/app/grid/diag/crs/lvracdb-s01-2024-08-07-2205191/crs/trace/alert.log


    <u>Output from host : lldbcs62</u>
    
    /u01/app/grid/diag/asm/+asm/+ASM2/trace/alert_+ASM2.log
    /u01/app/grid/diag/apx/+apx/+APX2/trace/alert_+APX2.log
    /u01/app/grid/diag/crs/lvracdb-s01-2024-08-07-2205192/crs/trace/alert.log
    /u01/app/oracle/diag/rdbms/racqyfvz_jnq_gru/racQYFVZ2/trace/alert_racQYFVZ2.log
    </pre>

4.  Check the latest entries (tail) from one or more of those logs

    > Note: If the complete name is not given then any matching logs entries are shown as below.

    ```
    <copy>
    tfactl tail alert
    </copy>
    ```
    Example Command Output:
    <pre>
    <u>Output from host : lvracdb-s01-2024-08-08-1452081</u>
    
    ==> /u01/app/grid/diag/asm/+asm/+ASM1/trace/alert_+ASM1.log <==
    2024-08-08T16:27:59.575756+00:00
    NOTE: Flex client id 0x0 [racXIMWM1:racXIMWM_8wz_bom:dbSyspq5vby3q] attempting to connect
    NOTE: registered owner id 0x902e0265f5a567ac for racXIMWM1:racXIMWM_8wz_bom:dbSyspq5vby3q
    NOTE: Flex client racXIMWM1:racXIMWM_8wz_bom:dbSyspq5vby3q registered, osid 16868, mbr 0x0, asmb 16858 (reg:3872158049)
    2024-08-08T16:28:03.259166+00:00
    NOTE: m-asmb client racXIMWM1:racXIMWM_8wz_bom:dbSyspq5vby3q assigned CGID 0x1000e for group 2
    NOTE: client racXIMWM1:racXIMWM_8wz_bom:dbSyspq5vby3q mounted group 2 (RECO)
    2024-08-08T16:28:08.336845+00:00
    NOTE: m-asmb client racXIMWM1:racXIMWM_8wz_bom:dbSyspq5vby3q assigned CGID 0x1000f for group 1
    NOTE: client racXIMWM1:racXIMWM_8wz_bom:dbSyspq5vby3q mounted group 1 (DATA)

    ==> /u01/app/grid/diag/crs/lvracdb-s01-2024-08-08-1452081/crs/trace/alert.log <==
    2024-08-08 15:47:01.090 [OCTSSD(54322)]CRS-2401: The Cluster Time Synchronization Service started on host lvracdb-s01-2024-08-08-1452081.
    2024-08-08 15:47:06.666 [ORAROOTAGENT(53589)]CRS-5019: All OCR locations are on ASM disk groups [DATA], and none of these disk groups are mounted. Details are at "(:CLSN00140:)" in "/u01/app/grid/diag/crs/lvracdb-s01-2024-08-08-1452081/crs/trace/ohasd_orarootagent_root.trc".
    2024-08-08 15:47:28.393 [CRSD(54477)]CRS-8500: Oracle Clusterware CRSD process is starting with operating system process ID 54477
    2024-08-08 15:47:32.266 [CRSD(54477)]CRS-1012: The OCR service started on node lvracdb-s01-2024-08-08-1452081.
    2024-08-08 15:47:32.362 [CRSD(54477)]CRS-1201: CRSD started on node lvracdb-s01-2024-08-08-1452081.
    2024-08-08 15:47:32.990 [ORAAGENT(54600)]CRS-8500: Oracle Clusterware ORAAGENT process is starting with operating system process ID 54600
    2024-08-08 15:47:33.115 [ORAROOTAGENT(54610)]CRS-8500: Oracle Clusterware ORAROOTAGENT process is starting with operating system process ID 54610
    2024-08-08 15:47:35.285 [ORAAGENT(54796)]CRS-8500: Oracle Clusterware ORAAGENT process is starting with operating system process ID 54796
    2024-08-08 16:19:48.268 [ORAAGENT(7675)]CRS-8500: Oracle Clusterware ORAAGENT process is starting with operating system process ID 7675
    2024-08-08 16:27:46.329 [ORAAGENT(16607)]CRS-8500: Oracle Clusterware ORAAGENT process is starting with operating system process ID 16607

    ==> /u01/app/oracle/diag/rdbms/racximwm_8wz_bom/racXIMWM1/trace/alert_racXIMWM1.log <==
    2024-08-08T17:08:46.408401+00:00
    ALTER SYSTEM SET _ipddb_enable=TRUE SCOPE=MEMORY SID='racXIMWM1';
    2024-08-08T18:23:20.786149+00:00
    ORA-00600: internal error code, arguments: [kgb], [livelabs1], [17], [], [], [], [], [], [], [], [], []
    2024-08-08T18:23:31.277794+00:00
    ORA-04031: unable to allocate 90342 bytes of shared memory ("","","","")
    2024-08-08T18:23:45.626550+00:00
    ALTER SYSTEM SET parallel_threads_per_cpu=4 SCOPE=BOTH;
    2024-08-08T19:08:10.824330+00:00
    Resize operation completed for file# 3, fname +DATA/RACXIMWM_8WZ_BOM/DATAFILE/sysaux.269.1176480723, old size 1075200K, new size 1085440K

    ==> /u01/app/grid/diag/apx/+apx/+APX1/trace/alert_+APX1.log <==
    NOTE: Assigning number (1,0) to disk (/dev/DATADISK3)
    NOTE: Assigning number (1,2) to disk (/dev/DATADISK1)
    SUCCESS: mounted group 1 (DATA)
    NOTE: grp 1 disk 3: DATA_0003 path:/dev/DATADISK4
    NOTE: grp 1 disk 1: DATA_0001 path:/dev/DATADISK2
    NOTE: grp 1 disk 0: DATA_0000 path:/dev/DATADISK3
    NOTE: grp 1 disk 2: DATA_0002 path:/dev/DATADISK1
    2024-08-08T15:49:39.997021+00:00
    NOTE: volume resource ora.DATA.COMMONSTORE.advm is online
    NOTE: volume resource ora.DATA.COMMONSTORE.advm requested to start globally

    ==> /u01/app/grid/diag/asmtool/user_root/host_1565551139_110/trace/alert.log <==
    afdt_errorsLEM: start
    afdt_errorsLEM: end
    2024-08-08T20:34:07.611255+00:00
    afdt_check_syntax: start
    afdt_check_syntax: end
    afdt_libinit: start
    Unable to open file /opt/oracle/extapi/64/asm
    Failed to load AFD library.
    afdt_errorsLEM: start
    afdt_errorsLEM: end


    <u>Output from host : lvracdb-s01-2024-08-08-1452082</u>
    
    ==> /u01/app/grid/diag/asm/+asm/+ASM2/trace/alert_+ASM2.log <==
    NOTE: Flex client id 0x0 [racXIMWM2:racXIMWM_8wz_bom:dbSyspq5vby3q] attempting to connect
    NOTE: registered owner id 0x4fe14b9819501bcf for racXIMWM2:racXIMWM_8wz_bom:dbSyspq5vby3q
    NOTE: Flex client racXIMWM2:racXIMWM_8wz_bom:dbSyspq5vby3q registered, osid 85462, mbr 0x0, asmb 85452 (reg:3733961839)
    NOTE: m-asmb client racXIMWM2:racXIMWM_8wz_bom:dbSyspq5vby3q assigned CGID 0x10004 for group 2
    NOTE: client racXIMWM2:racXIMWM_8wz_bom:dbSyspq5vby3q mounted group 2 (RECO)
    2024-08-08T16:28:03.692522+00:00
    NOTE: m-asmb client racXIMWM2:racXIMWM_8wz_bom:dbSyspq5vby3q assigned CGID 0x10005 for group 1
    NOTE: client racXIMWM2:racXIMWM_8wz_bom:dbSyspq5vby3q mounted group 1 (DATA)
    2024-08-08T20:02:24.284130+00:00
    NOTE: cleaning up empty system-created directory '+DATA/dbSyspq5vby3q/OCRBACKUP/19948076.277.1176494541'

    ==> /u01/app/oracle/diag/rdbms/racximwm_8wz_bom/racXIMWM2/trace/alert_racXIMWM2.log <==
    Pluggable database PDB$SEED opened read only
    2024-08-08T16:42:59.987176+00:00
    Control autobackup written to DISK device

    handle '+RECO/RACXIMWM_8WZ_BOM/AUTOBACKUP/2024_08_08/s_1176482579.266.1176482579'

    2024-08-08T17:08:46.336888+00:00
    ALTER SYSTEM SET _ipddb_enable=TRUE SCOPE=MEMORY SID='racXIMWM2';
    2024-08-08T17:08:46.410308+00:00
    ALTER SYSTEM SET _ipddb_enable=TRUE SCOPE=MEMORY SID='racXIMWM2';

    ==> /u01/app/grid/diag/apx/+apx/+APX2/trace/alert_+APX2.log <==
    NOTE: Assigning number (1,2) to disk (/dev/DATADISK1)
    NOTE: Assigning number (1,0) to disk (/dev/DATADISK3)
    </pre>

5.  Analyze the logs for most Common Errors

    > Note: This command shows analysis for logs on each node. The below is just showing one node.

    ```
    <copy>
    tfactl analyze -last 1d
    </copy>
    ```
    Example Command Output:

    ![TFA Analyze](./images/tfactl-analyze-1.png =130%x*)
    
6.  Run the Real time Database top consumer monitor 'oratop'  
    oratop gathers wait and usage metrics from the database and displays them by top session similar to the 'O/S' top command.
    > Note: hit the 'h' key to get help on the various options  

    >       hit 'q' to either exit the help or monitor itself when not in help.


    ```
    tfactl oratop -database <your database name>>
    ```
    
    You can use the **srvctl** command to get your database name if you do not have it handy as there is only one database configured.

    ```
    <copy>
    tfactl oratop -database `srvctl config database`
    </copy>
    ```

    Example Command Output:
    ![Oratop Screenshot](./images/oratop-1.png =50%x*)
        

You may now [proceed to the next lab](#next).  

## Acknowledgements
* **Authors** - Bill Burton
* **Contributors** - Troy Anthony, Gareth Chapman
* **Last Updated By/Date** - Bill Burton, July  2024
