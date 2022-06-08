# Creating SRDCs for Specific Events

## Introduction

Oracle Database enables the user to collect diagnostic files for an ORA-00600 error. This critical error is the result of a problem SQL statement. It is catchall message that indicates an error internal to the database code. It is signaled when a code check fails within the database. Oracle Database performs health checks on the information being used in internal processing and that the variables used are within a valid range. It studies that changes are being made in a consistent structure, while ensuring that the changes won't put a structure into an unstable state. This terminates the operation to protect the health of the database. 

Oracle Trace File Analyzer Service Request Data Collections (SRDCs) enable you to quickly collect the right diagnostic data. Oracle Support often asks the user to run a SDRC, which can be difficult to collect manually. Oracle Trace File Analyzer (TFA) can run SDRC collections with a single command. Oracle TFA is run through the command 'tfactl`. This daemon runs on a local node when installed as the "root" user on the server, which allows it to be a reactive tool. Each TFA collection produces a single zip file that can be uploaded to My Oracle Support (MOS).

MOS is the initial point of contact for all product support and training needs. MOS accepts manually uploading of the zip files produced by TFA by attaching it to your Service Request (SR). However, alternatively, TFA can upload it automatically and attaching it to the SR, which is enabled by providing the MOS credentials. This is accomplished through the command line or  through a secure wallet as the "root" user.

### Objectives

In this lab, you will:
* Install Trace File Analyzer (TFA)
* Verify TFA Collector is Runnning
* Collect all ORA-00600 Error using Service Request Data Collection (SRDC)

### Prerequisites

This lab assumes you have:
* Obtained and signed in to your `workshop-installed` compute instance.

## Overview

In this practice, you collect diagnostic files for an ORA-00600 error, and upload files directly to your service request.

## Task 1: Install Trace File Analyzer (TFA)

1.	Log in as root to the server and install Trace File Analyzer in $ORACLE_BASE/tfa.

      ```
      $ <copy>cd $HOME/u01/app/oracle</copy>

      ...

      $
      ```
     
      ```
      $ <copy>unzip $HOME/oracle/labs/19cnf/TFA-LINUX_v19.2.1.zip</copy>

      ...

      Archive:  /home/oracle/labs/19cnf/TFA-LINUX_v19.2.1.zip
      inflating: README.txt
      inflating: installTFA-LINUX
      $
      ```

      ```
      $ <copy>sudo ./installTFA-LINUX</copy>

      ...

      TFA Installation Log will be written to File : /tmp/tfa_install_6105_2018_10_15-11_55_44.log
     

      Starting TFA installation

      TFA Version: 183300 Build Date: 201810050542

      Enter a location for installing TFA (/tfa will be appended if not supplied) [/u01/app/oracle/tfa]:


      Running Auto Setup for TFA as user oracle...

      Would you like to do a [L]ocal only or [C]lusterwide installation ? [L|l|C|c] [C] : <code>L</code>
      Installing TFA now...

      Discovering Nodes and Oracle resources

      Starting Discovery...


      No Grid Infrastructure Discovered on this system . . . . .

      <your_hostname>
      Searching for running databases...
      1. ORCL


      Searching out ORACLE_HOME for selected databases...


      Getting Oracle Inventory...

      ORACLE INVENTORY: /u01/app/oraInventory


      Discovery Complete...


      TFA Will be Installed on edvmr1p0...

      TFA will scan the following Directories
      ++++++++++++++++++++++++++++++++++++++++++++

      .---------------------------------------------------------------
      |                                 edvmr1p0                                |
      +--------------------------------------------------------------| Trace Directory                                                | Resource |
      +--------------------------------------------------------------
      | /u01/app/oraInventory/ContentsXML                            | INSTALL  |
      | /u01/app/oraInventory/logs                                   | INSTALL  |
      | /u01/app/oracle/cfgtoollogs                                  | CFGTOOLS |
      | /u01/app/oracle//clients/user_oracle/host_3132364359_110 | DBCLIENT |
      | /u01/app/oracle//clients/user_oracle/host_3132364359_110 | DBCLIENT |
      | /u01/app/oracle//rdbms/cdb19/CDB19/cdump                 | RDBMS    |
      | /u01/app/oracle//rdbms/cdb19/CDB19/trace                 | RDBMS    |
      | /u01/app/oracle//rdbms/orcl/ORCL/cdump                   | RDBMS    |
      | /u01/app/oracle//rdbms/orcl/ORCL/trace                   | RDBMS    |
      | /u01/app/oracle//tnslsnr                                 | TNS      |
      | /u01/app/oracle//tnslsnr/hostname/listener/cdump         | TNS      |
      | /u01/app/oracle//tnslsnr/hostname/listener/trace         | TNS      |
      | /u01/app/oracle//tnslsnr/hostname/listener20181004112604 | TNS      |
      | /u01/app/oracle//tnslsnr/hostname/listener20181004112604 | TNS      |
      | /u01/app/oracle//tnslsnr/hostname/listener20181004114040 | TNS      |
      | /u01/app/oracle//tnslsnr/hostname/listener20181004114040 | TNS      |
      | /u01/app/oracle/product/19.1.0/dbhome_1/cfgtoollogs          | CFGTOOLS |
      | /u01/app/oracle/product/19.1.0/dbhome_1/install              | INSTALL  |
      | /u01/app/oracle/product/19.1.0/dbhome_1/rdbms/log            | RDBMS    |
      | /u01/app/oracle/product/19.1.0/dbhome_2/cfgtoollogs          | CFGTOOLS |
      | /u01/app/oracle/product/19.1.0/dbhome_2/install              | INSTALL  |
      '--------------------------------------------------------------
      Installing TFA on hostname:
      HOST: hostname TFA_HOME: /u01/app/oracle/tfa/hostname/tfa_home
      .---------------------------------------------------------------
      | Host     | Status of TFA | PID  | Port  | Version    | Build ID             |
      +----------+---------------+------+-------+------------+--------
      | hostname | RUNNING       | 7955 | 42182 | 18.3.3.0.0 | 18330020181005054218 |
      '----------+---------------+------+-------+------------+--------

      Running Inventory in All Nodes...

      Summary of TFA Installation:
      .-------------------------------------------------------------.
      |                           hostname                          |
      +---------------------+---------------------------------------+
      | Parameter           | Value                                 |
      +---------------------+---------------------------------------+
      | Install location    | /u01/app/oracle/tfa/hostname/tfa_home |
      | Repository location | /u01/app/oracle/tfa/repository        |
      | Repository usage    | 0 MB out of 10240 MB                  |
      '---------------------+---------------------------------------'

      TFA is successfully installed...

      Usage : /u01/app/oracle/tfa/bin/tfactl <command> [options]
         commands:collect|collection|analyze|ips|run|start|stop|enable|disable|status|print|access|purge|directory|host|receiver|set|toolstatus|uninstall|nosetfa|syncnodes|setupmos|upload|availability|rest|events|search|changes|isa
      For detailed help on each command use:
       /u01/app/oracle/tfa/bin/tfactl <command> -help


      $
      ```

## Task 2: Verify TFA Collector is Runnning

2.	Switch to oracle and check that the TFA Collector is running.

      ```
      $ <copy>$HOME/u01/app/oracle/tfa/bin/tfactl -help</copy>
     
      ...

      Usage : /u01/app/oracle/tfa/bin/tfactl <command> [options]
         commands:collect|collection|analyze|ips|run|start|stop|enable|disable|status|print|access|purge|directory|host|receiver|set|toolstatus|uninstall|nosetfa|syncnodes|setupmos|upload|availability|rest|events|search|changes|isa
      For detailed help on each command use:
      /u01/app/oracle/tfa/bin/tfactl <command> -help
      $
      ```

      ```
      $ <copy>cd /u01/app/oracle/tfa/bin</copy>

      ...

      $
      ``` 

      ```
      $ <copy>sudo ./tfactl status</copy>

      ...

      .---------------------------------------------------------------
      | Host     | Status of TFA | PID   | Port  | Version    | Build ID             | Inventory Status |
      +----------+---------------+-------+-------+------------+-------
      | hostname | RUNNING       | 28467 | 55757 | 18.3.3.0.0 | 18330020181005054218 | COMPLETE         |
      '----------+---------------+-------+-------+------------+-------
      $
      ```

## Task 3: Collect all ORA-00600 Error using Service Request Data Collection (SRDC)

3.	Start a Service Request Data Collection (SRDC) for all ORA-00600 errors that occurred in  ORCL.

      Q1/ How do you get the list of possible types of SRDC?

      ```
      $ <copy>./tfactl collect -srdc -help </copy>

      ...

      Service Request Data Collection (SRDC).

      Usage : /u01/app/oracle/tfa/bin/tfactl collect -srdc <srdc_profile> [-tag <tagname>] [-z <filename>] [-last <n><h|d>| -from <time> -to <time> | -for <time>] -database <database>
         -tag <tagname>  The files will be collected into tagname directory inside repository
         -z <zipname>    The collection zip file will be given this name within the TFA collection repository
         -last  <n><h|d> Files from last 'n' [d]ays or 'n' [h]ours
         -since Same as -last. Kept for backward compatibility.
         -from           "Mon/dd/yyyy hh:mm:ss"    From <time>
                        or "yyyy-mm-dd hh:mm:ss"
                        or "yyyy-mm-ddThh:mm:ss"
                        or "yyyy-mm-dd"
        -to             "Mon/dd/yyyy hh:mm:ss"    To <time>
                        or "yyyy-mm-dd hh:mm:ss"
                        or "yyyy-mm-ddThh:mm:ss"
                        or "yyyy-mm-dd"
        -for            "Mon/dd/yyyy"             For <date>.
                        or "yyyy-mm-dd"

         <srdc_profile> can be any of the following,
         Listener_Services    SRDC - Data Collection for TNS-12516 / TNS-12518 / TNS-12519 / TNS-12520.
         Naming_Services      SRDC - Data Collection for ORA-12154 / ORA-12514 / ORA-12528.
         ORA-00020            SRDC for database ORA-00020 Maximum number of processes exceeded
         ORA-00060            SRDC for ORA-00060. Internal error code.
         ORA-00600            SRDC for ORA-00600. Internal error code.
         ORA-00700            SRDC for ORA-00700. Soft internal error.
         ORA-01031            SRDC - How to Collect Standard Information for ORA - 1031 /ORA -1017 during SYSDBA connections
         ORA-01555            SRDC for database ORA-01555 Snapshot too Old problems
         ORA-01578            SRDC - Required diagnostic Data Collection for NOLOGGING ORA-1578/ORA-26040 DBV-00201.
         ORA-01628            SRDC for database ORA-01628 Snapshot too Old problems
         ORA-04030            SRDC for ORA-04030. OS process private memory was exhausted.
         ORA-04031            SRDC for ORA-04031. More shared memory is needed in the shared/streams pool.
         ORA-07445            SRDC for ORA-07445. Exception encountered, core dump.
         ORA-08102            SRDC - Required diagnostic Data Collection for ORA-08102.
         ORA-08103            SRDC - Required diagnostic Data Collection for ORA-08103.
         ORA-27300            SRDC for ORA-27300.  OS system dependent operation:open failed with status: (status).
         ORA-27301            SRDC for ORA-27301. OS failure message: (message).
         ORA-27302            SRDC for ORA-27302. failure occurred at: (module).
         ORA-29548            SRDC - Providing Supporting Information for Oracle JVM Issues (Doc ID 2175568.1)
         ORA-30036            SRDC for database ORA-30036 Unable to extend Undo Tablespace pproblems
         TNS-12154            SRDC - Data Collection for TNS-12154.
         TNS-12514            SRDC - Data Collection for TNS-12514.
         TNS-12516            SRDC - Data Collection for TNS-12516.
         TNS-12518            SRDC - Data Collection for TNS-12518.
         TNS-12519            SRDC - Data Collection for TNS-12519.
         TNS-12520            SRDC - Data Collection for TNS-12520.
         TNS-12528            SRDC - Data Collection for TNS-12528.
         dbasm                SRDC AUTOMATION: ENHANCE ASM/DBFS/DNFS/ACFS COLLECTIONS
         dbaudit              SRDC - How to Collect Standard Information for Database Auditing
         dbawrspace           SRDC for database AWR space problems
         dbblockcorruption    SRDC - Required diagnostic Data Collection for Alert Log Message "Corrupt block relative dba".
         dbdataguard          SRDC to capture diagnostic data for Data Guard issues
         dbexp                SRDC - How to Collect Information for Troubleshooting Export (EXP) Related Problems
         dbexpdp              SRDC - diagnostic Collection for DataPump Export Generic Issues
         dbexpdpapi           SRDC - diagnostic Collection for DataPump Export API Issues
         dbexpdpperf          SRDC - diagnostic Collection for DataPump Export Performance Issues
         dbexpdptts           SRDC - Data to supply for Transportable Tablespace Datapump and original EXPORT, IMPORT
         dbfs                 SRDC for dbfs.
         dbggclassicmode      SRDC for DOC ID 1913426.1, 1913376.1 and 1912964.1
         dbggintegratedmode   SRDC for GoldenGate extract/replicat abends problems.
         dbimp                SRDC - diagnostic Collection for Traditional Import Issues
         dbimpdp              SRDC - diagnostic Collection for DataPump Import (IMPDP) Generic Issues
         dbimpdpperf          SRDC - diagnostic Collection for DataPump Import (IMPDP) Performance Issues
         dbinstall            SRDC for Oracle RDBMS install problems.
         dbpartition          SRDC - Data to Supply for Create/Maintain Partitioned/Subpartitioned Table/Index Issues
         dbpartitionperf      SRDC - Data to Supply for Slow Create/Alter/Drop Commands Against Partitioned Table/Index
         dbpatchconflict      SRDC for Oracle RDBMS patch conflict problems.
         dbpatchinstall       SRDC for Single Instance Database Shutdown problems
         dbperf               SRDC for database performance problems.
         dbpreupgrade         SRDC for database preupgrade problems.
         dbrman                SRDC - Required diagnostic data collection for RMAN related issues, such as backup, maintenance, restore and recover, RMAN-08137 or RMAN-08120
         dbrman600            SRDC - Required diagnostic data collection for RMAN-00600 error (Doc ID 2045195.1).
         dbrmanperf           SRDC - Required diagnostic data collection for RMAN Performance(1671509.1).
         dbscn                SRDC for database SCN problems.
         dbshutdown           SRDC for Single Instance Database Shutdown problems
         dbsqlperf            SRDC - How to Collect Standard Information for a SQL Performance Problem Using TFA Collector.
         dbstartup            SRDC for Single Instance Database Startup problems
         dbtde                SRDC - How to Collect Standard Information for Transparent Data Encryption (TDE) (Doc ID 1905607.1)
         dbundocorruption     SRDC - Required diagnostic Data Collection for UNDO Corruption.
         dbunixresources      SRDC to capture diagnostic data for DB issues related to O/S resources
         dbupgrade            SRDC for database upgrade problems.
         dbxdb                SRDC for database XDB Installation and Invalid Object problems
         dnfs                 SRDC for DNFS.
         emagentperf          EM SRDC - Collect diagnostic Data for EM Agent Performance Issues.
         emcliadd             EM SRDC - Errors during the adding of a database/listener/ASM target via EMCLI.
         emclusdisc           EM SRDC - Cluster target, cluster (RAC) database or ASM target is not discovered.
         emdbsys              EM SRDC - Database system target is not discovered/detected/removed/renamed correctly.
         emdebugoff           SRDC for unsetting EM Debug.
         emdebugon            SRDC for setting EM Debug.
         emgendisc            EM SRDC - General error is received when discovering or removing a database/listener/ASM target.
         emmetricalert        SRDC for EM Metric Events not Raised and General Metric Alert Related Issues.
         emomscrash           SRDC - Collect diagnostic Data for all Enterprise Manager OMS Crash / Restart Performance Issues.
         emomsheap            SRDC - Collecting diagnostic Data for Enterprise Manager OMS Heap Usage Alert Performance Issues.
         emomshungcpu         SRDC - Collecting diagnostic Data for Enterprise Manager OMS hung or High CPU Usage Performance Issues.
         emprocdisc           EM SRDC - Database/listener/ASM target is not discovered/detected by the discovery process.
         emrestartoms         EM SRDC - Re-start OMS.
         emtbsmetric          SRDC for EM Tablespace Space Used Metric Issues.
         esexalogic           SRDC - Exalogic Full Exalogs Data Collection Information.
         ggintegratedmodenodb SRDC for GoldenGate extract/replicat abends problems.
         internalerror        SRDC for all other types of internal database errors.
       $ 
       ```

       A1/ The -help option is always useful in getting the possible values of options.

       a.	Collect diagnostic data for your service request SR12345 (this is a fake SR) for the ORA-00600 errors that occurred in Practice 6-1.
    
       ```    
       $ <copy>./tfactl collect -srdc ORA-00600 -sr SR12345</copy>

       ...

       MOS setup is not done. It is needed to upload collection to SR
       Run: tfactl setupmos
       $
       ```

       b.	Set the TEST MyOracleSupport (MOS) credentials within a wallet.

       ```
       $ <copy>./tfactl setupmos</copy>

       ...

       Access Denied: Only TFA Admin can run this command
       $
       ```

       The wallet file is secured to be read/write by the root user only. This is the reason you have to log on as root.
       ```
       $ <copy>cd /u01/app/oracle/tfa/bin</copy>

       ...

       $    
       ```
    

       ```
       $ <copy> sudo ./tfactl setupmos</copy>

       ...

       $
       ```

       ```
       Enter User Id: <copy>Test</copy>

       ...

       $
       ```

       ```
       Enter Password: <copy>Ora4U_1234</copy> 

       ...
     
       Wallet does not exist ... creating
       Wallet created successfully
       USER details added/updated in the wallet
       PASSWORD details added/updated in the wallet
       SUCCESS - CERTIMPORT - Successfully imported certificate
       $
       ```

       c.	Switch back to oracle and collect the diagnostic data related to the second occurrence of the ORA-00600 errors in ORCL for SR12345.
     
       ```
       $ <copy>cd $HOME/u01/app/oracle/tfa/bin</copy>

       ...

       $
       ```

       ```
       $ <copy>./tfactl collect -srdc ORA-00600 -sr SR12345</copy>

       ...

       Enter the time of the ORA-00600 [YYYY-MM-DD HH24:MI:SS,<RETURN>=ALL] :
       Enter the Database Name [<RETURN>=ALL] : ORCL

       1. Nov/12/2018 16:00:32 : [orcl] ORA-00600: internal error code, arguments: [13011], [72893], [4229649], [0], [4229649], [17], [], [], [], [], [], []

       Please choose the event : 1-1 [1] 
       Selected value is : 1 ( Nov/12/2018 16:00:32 )
       Scripts to be run by this srdc: ipspack rdahcve1210 rdahcve1120 rdahcve1110
       Components included in this srdc: OS CRS DATABASE NOCHMOS
       Collecting data for local node(s)
       Scanning files from Nov/12/2018 10:00:32 to Nov/12/2018 22:00:32
       WARNING: End time entered is after the current system time.

       Collection Id : 20181112171615hostname


       Detailed Logging at : /u01/app/oracle/tfa/repository/srdc_ora600_collection_Mon_Nov_12_17_16_15_UTC_2018_node_local/diagcollect_20181112171615_hostname.log
       2018/11/12 17:16:19 UTC : NOTE : Any file or directory name containing the string .com will be renamed to replace .com with dotcom
       2018/11/12 17:16:19 UTC : Collection Name : tfa_srdc_ora600_Mon_Nov_12_17_16_15_UTC_2018.zip
       2018/11/12 17:16:19 UTC : Scanning of files for Collection in progress...
       2018/11/12 17:16:19 UTC : Collecting additional diagnostic information...
       2018/11/12 17:16:24 UTC : Getting list of files satisfying time range [11/12/2018 10:00:32 UTC, 11/12/2018 17:16:19 UTC]
       2018/11/12 17:16:58 UTC : Collecting ADR incident files...
       2018/11/12 17:17:57 UTC : Completed collection of additional diagnostic information...
       2018/11/12 17:18:10 UTC : Completed Local Collection
       2018/11/12 17:18:10 UTC : Uploading collection to SR - SR12345
       2018/11/12 17:20:57 UTC : Failed to upload collection to SR
       .-----------------------------------------.
       |            Collection Summary           |
       +--------------+-----------+-------+------+
       | Host         | Status    | Size  | Time |
       +--------------+-----------+-------+------+
       | hostname     | Completed | 286MB | 111s |
       '--------------+-----------+-------+------'

       Logs are being collected to: /u01/app/oracle/tfa/repository/srdc_ora600_collection_Mon_Nov_12_17_16_15_UTC_2018_node_local
       /u01/app/oracle/tfa/repository/srdc_ora600_collection_Mon_Nov_12_17_16_15_UTC_2018_node_local/hostname.tfa_srdc_ora600_Mon_Nov_12_17_16_15_UTC_2018.zip
       $
       ```

       Do not pay attention to the “Failed to upload collection to SR” message. The SR is a fake one.

       Q2/ Which options would you use to upload the initialization parameter file to the SR in MOS?

       ```
       $ <copy>./tfactl upload -sr SR12345 -user TEST $ORACLE_HOME/dbs/initORCL.ora</copy>

       ...

       SR12345 is not a valid SR number.
       $
       ```

       A2/ The upload allows you to upload other files to your SR in MOS. The command above fails because the SR used is a fake one.


## Learn More

- [Troubleshooting Internal Errors](https://blogs.oracle.com/oraclemagazine/post/troubleshooting-internal-errors)
- [Oracle Trace File Analyzer Service Request Data Collections (SRDCs)](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/collecting-diagnostics-and-using-one-command-srdc.html
- [Trace File Analyzer](https://oracle-base.com/articles/misc/trace-file-analyzer-tfa)
  
## Acknowledgements

- **Author**- Dominique Jeunot, Consulting User Assistance Developer
- **Last Updated By/Date** - Nicholas Cusato, Santa Monica Specialists Hub, January 2022