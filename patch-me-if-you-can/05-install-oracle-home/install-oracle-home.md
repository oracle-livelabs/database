# Install Oracle Home

In this lab, you will install an Oracle home using AutoUpgrade. This method is simple and easy.

## Introduction

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* Install Oracle home using AutoUpgrade
* Understand patch files

### Prerequisites

This lab assumes:

* You have completed Lab 1: Initialize environment

This is an optional lab.

## Task 1: Install using AutoUpgrade

First, you will install an Oracle home the easiest way using AutoUpgrade.

1. Use the *yellow* terminal 🟨. Examine the following AutoUpgrade config file:

    ``` bash
    <copy>
    cd
    cat scripts/pt-05-install-oracle-home.cfg
    </copy>

    # Be sure to hit RETURN
    ```

    * `source_home` is an existing Oracle home that you will use as a template to install the new Oracle home. AutoUpgrade installs the new Oracle home using the same settings as this Oracle home.
    * `target_home` is where you want to install the new Oracle home.
    * `folder` is the location where AutoUpgrade can find and store patch files. Ideally, this location is a network share accessible to all your database hosts.
    * `patch` informs AutoUpgrade which patches you want to apply. You can specify a specific Release Update using the *RU* keyword with the Release Update specified after the colon. The keywords *OPATCH*, *OJVM* and *DPBP* installs the lastest version of OPatch and the OJVM and Data Pump bundle patches. *OCW* updates the OCW component in the Oracle home. In addition, you are also installing a one-off patch, *29213893*.
    * `download` tells whether AutoUpgrade should attempt to download the patches from My Oracle Support using your My Oracle Support credentials. This is not possible inside this lab environment, so all patches have been pre-downloaded.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat scripts/pt-05-install-oracle-home.cfg
    global.global_log_dir=/home/oracle/autoupgrade-patching/install-oracle-home/log
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/19_28_au
    patch1.folder=/home/oracle/patch-repo
    patch1.patch=RU:19.28,OPATCH,OJVM,DPBP,OCW,29213893
    patch1.download=no
    ```

    </details>

2. Start AutoUpgrade to create the Oracle home.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config scripts/pt-05-install-oracle-home.cfg -patch -mode create_home
    </copy>
    ```

    * It may stay a while on *Processing config file ...*, while AutoUpgrade reads and catalog the zip files on */home/oracle/patch-repo* folder.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ java -jar autoupgrade.jar -config scripts/pt-05-install-oracle-home.cfg -patch -mode create_home
    AutoUpgrade Patching 25.4.250730 launched with default internal options
    Processing config file ...
    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    Type 'help' to list console commands
    patch>
    ```

    </details>

3. You're now in the AutoUpgrade console. Monitor the progress.

    ``` bash
    <copy>
    lsj -a 10
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    patch> lsj -a 10
    patch> +----+-------------+-------+---------+-------+----------+-------+---------------------+
    |Job#|      DB_NAME|  STAGE|OPERATION| STATUS|START_TIME|UPDATED|              MESSAGE|
    +----+-------------+-------+---------+-------+----------+-------+---------------------+
    | 100|create_home_1|EXTRACT|EXECUTING|RUNNING|  08:04:08|33s ago|Extracting gold image|
    +----+-------------+-------+---------+-------+----------+-------+---------------------+
    Total jobs 1

    The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
    ```

    </details>

4. When you have an existing Oracle home specified using `source_home` parameter, AutoUpgrade checks the settings of the source Oracle home and creates the target Oracle home with the same settings.

    * You can override the Oracle home settings using config file parameters. For instance, you could enable the OLAP option by using `patch1.home_settings.binopt.olap=yes`.
    * Some prefer to give the Oracle home a custom name which you can do with `patch1.home_settings.home_name=your_custom_home_name`.

5. If you have a brand-new server with no existing Oracle home, you can still using `-mode create_home`. AutoUpgrade creates the Oracle home with the default settings rather than copying from a source Oracle home. In this case, you can specify most of the runInstaller settings using `patch1.home_settings`.

6. In this task, you installed a Release Update and additional patches. AutoUpgrade also allows you to install the recent-most Monthly Recommended Patches (MRP) of the specified Release Update. You can do that by adding *MRP* to the patch specification, `patch1.patch=RECOMMENDED,OCW,29213893,MRP`. AutoUpgrade automatically finds the appropriate patch and applies it. This is a simple way of getting the most-important one-off fixes for a given Release Update.

7. **It takes around 10 minutes to install a new Oracle home and patch it**. Leave AutoUpgrade running and move on to the next task.

## Task 2: Check patch files

While AutoUpgrade installs a new Oracle home, you can inspect some of the patch files.

1. Switch to the *blue* terminal 🟦. Extract one of the patch files.

    ``` bash
    <copy>
    cd /home/oracle/patch-repo
    unzip p37960098_190000_Linux-x86-64_dbru1928.zip -d ./37960098
    </copy>

    # Be sure to hit RETURN
    ```

    * Patch files comes from My Oracle Support as zip files.
    * The patch zip file you are extracting is the 19.28 Release Update.

2. Switch to the directory where you extracted the Release Update. Here you find the patch metadata stored in PatchSearch.xml

    ``` bash
    <copy>
    cd 37960098
    ll
    </copy>

    # Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd 37960098
    $ ll
    total 2328
    drwxr-xr-x. 5 oracle oinstall      81 Jul 15 11:45 37960098
    -rw-rw-r--. 1 oracle oinstall 2382992 Jul 15 20:46 PatchSearch.xml
    ```

    </details>

3. Examine the file.

    ``` bash
    <copy>
    head -n10 PatchSearch.xml
    </copy>
    ```

    * One of the XML elements contains the patch text, *DATABASE RELEASE UPDATE 19.28.0.0.0*.
    * The file contains a lot of metadata about the patch.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    <!-- This file contain patch Metadata -->
    <results md5_sum="39feeb0aebbbdf20a315af704d6ea304">
      <generated_date in_epoch_ms="1752612418000">2025-07-15 20:46:58</generated_date>
      <patch has_prereqs="n" has_postreqs="n" is_system_patch="n">
        <bug>
          <number>37960098</number>
          <abstract><![CDATA[DATABASE RELEASE UPDATE 19.28.0.0.0]]></abstract>
        </bug>
        <name>37960098</name>
        <type>Patch</type>
    ```

    </details>

4. Switch to the subdirectory to find the patch *README* file.

    ``` bash
    <copy>
    cd 37960098
    ll
    </copy>

    # Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cd 37960098
    $ ll
    total 104
    drwxr-x---.  3 oracle oinstall    21 Jul 15 11:49 custom
    drwxr-x---.  3 oracle oinstall    20 Jul 15 11:49 etc
    drwxr-x---. 48 oracle oinstall  4096 Jul 15 11:45 files
    -rw-r--r--.  1 oracle oinstall 97600 Jul 15 14:48 README.html
    -rw-r--r--.  1 oracle oinstall    21 Jul 15 11:49 README.txt
    ```

    </details>

5. Open the patch read me.

    ``` bash
    <copy>
    firefox README.html &
    </copy>
    ```

    * It takes a little while to open Firefox.
    * In section *1 Patch Information* you can find specific information about this patch.
    * It states that this patch is *RAC Rolling* and *Standby-First Installable*.
    * The file also contains installation instructions.

6. Close Firefox.

7. Find all the *bug apply scripts* in the Release Update.

    ``` bash
    <copy>
    find . -iname "bug*apply*sql*"
    </copy>
    ```

    * OPatch adds the apply scripts to the Oracle home as part of the patching process.
    * Later, Datapatch uses the apply scripts to make changes inside the database.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ find . -iname "bug*apply*sql*"
    ./files/rdbms/admin/bug31115653_postapply.sql
    ./files/rdbms/admin/bug29261906_apply.sql
    ./files/rdbms/admin/bug_35271571_apply.sql
    ./files/rdbms/admin/bug_32124176_apply.sql
    ./files/rdbms/admin/bug_29443559_apply.sql
    ....
    (output truncated)
    ....
    ./files/md/admin/bug_28134316_apply.sql
    ./files/md/admin/bug35999257_apply.sql
    ./files/md/admin/bug32425205_apply.sql
    ./files/md/admin/bug36357097_apply.sql
    ./files/md/admin/bug29357424_apply.sql
    ```

    </details>

8. Examine one of the apply scripts.

    ``` bash
    <copy>
    cat ./files/rdbms/admin/backport_files/bug_28971177_apply.sql
    </copy>
    ```

    * The apply script adds two indexes on `SYS.RECYCLEBIN$`.
    * The text on bug 28971177 states *Delete from recyclebin$ going for full table scan*.
    * The bug is solved by adding two indexes.
    * This illustrates how changes required by a bug fix gets into the database.
    * Also note how the backport is registered by inserting a row into `REGISTRY$BACKPORTS`.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat ./files/rdbms/admin/backport_files/bug_28971177_apply.sql
    Rem
    Rem $Header: rdbms/admin/backport_files/bug_28971177_apply.sql /st_rdbms_19/1 2022/09/21 16:37:52 skiyer Exp $
    Rem
    Rem bug_28971177_apply.sql
    Rem
    Rem Copyright (c) 2019, 2022, Oracle and/or its affiliates.
    Rem
    Rem    NAME
    Rem      bug_28971177_apply.sql - <one-line expansion of the name>
    Rem
    Rem    DESCRIPTION
    Rem      <short description of component this file declares/defines>
    Rem
    Rem    NOTES
    Rem      <other useful comments, qualifications, etc.>
    Rem
    Rem    BEGIN SQL_FILE_METADATA
    Rem    SQL_SOURCE_FILE: rdbms/admin/backport_files/bug_28971177_apply.sql
    Rem    SQL_SHIPPED_FILE: rdbms/admin/backport_files/bug_28971177_apply.sql
    Rem    SQL_PHASE: RDBMS_PREAPPLY
    Rem    SQL_STARTUP_MODE: NORMAL
    Rem    SQL_IGNORABLE_ERRORS: NONE
    Rem    END SQL_FILE_METADATA
    Rem
    Rem    MODIFIED   (MM/DD/YY)
    Rem    skiyer      11/05/19 - Bug28971177 add apply scripts
    Rem    skiyer      11/05/19 - Created
    Rem

    @@?/rdbms/admin/sqlsessstart.sql
    create index recyclebin$_purgeobj on recyclebin$(purgeobj);
    create index recyclebin$_bo on recyclebin$(bo);

    -- Record the fix for bug 28971177 into registry$backports
    INSERT /*+IGNORE_ROW_ON_DUPKEY_INDEX(registry$backports, registry_backports_pk)*/
    INTO sys.registry$backports (version_full, bugno)
    VALUES ((SELECT version_full FROM sys.v$instance),
            28971177);
    COMMIT;
    @?/rdbms/admin/sqlsessend.sql
    ```

    </details>

## Task 3: Check AutoUpgrade

Ensure that AutoUpgrade installed the Oracle home and perform a few checks.

1. Switch back to the *yellow* terminal 🟨. AutoUpgrade should be done by now. Otherwise, wait for it to complete. In the end, AutoUpgrade prints the following information and exists.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Job 100 completed
    ------------------- Final Summary --------------------
    Number of databases            [ 1 ]

    Jobs finished                  [1]
    Jobs failed                    [0]
    Jobs restored                  [0]
    Jobs pending                   [0]



    Please check the summary report at:
    /home/oracle/autoupgrade-patching/install-oracle-home/log/cfgtoollogs/patch/auto/status/status.html
    /home/oracle/autoupgrade-patching/install-oracle-home/log/cfgtoollogs/patch/auto/status/status.log
    ```

    </details>

2. Check the inventory and find the newly installed Oracle home.

    ``` bash
    <copy>
    cat /u01/app/oraInventory/ContentsXML/inventory.xml
    </copy>
    ```

    * You should be able to find the XML element matching the Oracle home you just installed. The Oracle home ends with *au*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ cat /u01/app/oraInventory/ContentsXML/inventory.xml
    <?xml version="1.0" standalone="yes" ?>
    <INVENTORY>
    <VERSION_INFO>
       <SAVED_WITH>12.2.0.7.0</SAVED_WITH>
       <MINIMUM_VER>2.1.0.6.0</MINIMUM_VER>
    </VERSION_INFO>
    <HOME_LIST>
    <HOME NAME="OraDB19Home1" LOC="/u01/app/oracle/product/19" TYPE="O" IDX="1"/>
    <HOME NAME="OraDB21Home1" LOC="/u01/app/oracle/product/21" TYPE="O" IDX="2"/>
    <HOME NAME="OraDB23Home1" LOC="/u01/app/oracle/product/23" TYPE="O" IDX="3"/>
    <HOME NAME="OraDB19Home2" LOC="/u01/app/oracle/product/19_28" TYPE="O" IDX="4"/>
    <HOME NAME="OraDB19Home3" LOC="/u01/app/oracle/product/19_28_au" TYPE="O" IDX="5"/>
    </HOME_LIST>
    <COMPOSITEHOME_LIST>
    </COMPOSITEHOME_LIST>
    </INVENTORY>
    ```

    </details>

3. Check the patches installed.

    ``` bash
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/19_28_au
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>

    # Be sure to hit RETURN
    ```

    * AutoUpgrade installed the Release Update you specified including the other patches. 
    * Notice how the OCW component has been updated as well. It is now on *19.28.0.0.0*. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ /u01/app/oracle/product/19_28_au/OPatch/opatch lspatches

    29213893;DBMS_STATS FAILING WITH ERROR ORA-01422 WHEN GATHERING STATS FOR USER$ TABLE
    37847857;OJVM RELEASE UPDATE: 19.28.0.0.250715 (37847857)
    37962946;OCW RELEASE UPDATE 19.28.0.0.0 (37962946)
    38170982;DATAPUMP BUNDLE PATCH 19.28.0.0.0
    37960098;Database Release Update : 19.28.0.0.250715 (37960098)

    OPatch succeeded.
    ```

    </details>

## Task 4: Optional: Use Gold Image

Gold images are a convenient way of installing Oracle homes on many different servers. You prepare and patch an Oracle home only once, and then distribute the patched Oracle home to all other servers.

1. **This is an optional lab that takes around 10 minutes**. If you are short on time, you can skip executing the commands, but do read on.

2. Still in the *yellow* terminal 🟨. Set the environment to the new Oracle home.

    ``` bash
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/19_28_au
    export PATH=$ORACLE_HOME/bin:$PATH
    </copy>

    # Be sure to hit RETURN
    ```

    * This is the Oracle home you created using AutoUpgrade.
    * The Oracle home is patched with Release Update 28.

3. Create the gold image.

    ``` bash
    <copy>
    $ORACLE_HOME/runInstaller -createGoldImage \
       -destinationLocation /home/oracle/patch-repo \
       -name goldImage_dbHome_19_28_0.zip \
       -silent
    </copy>
    ```

    * It takes a few minutes to create the gold image.
    * The installer puts the Oracle home into a zip file.
    * `destinationLocation` determines where the gold image is placed.
    * `name` tells the installer the name of the zip file.
    * While the installer creates a gold image, reflect on the differences between creating the new Oracle home using AutoUpgrade and manually?
    * You can move on with the next lab while the installer completes.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Launching Oracle Database Setup Wizard...

    Successfully Setup Software.
    Gold Image location: /home/oracle/patch-repo/goldImage_dbHome_19_28_0.zip
    ```

    </details>

4. Find the gold image.

    ``` bash
    <copy>
    ls -l /home/oracle/patch-repo/goldImage*
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    $ ls -l /home/oracle/patch-repo/goldImage*
    -rw-r--r--. 1 oracle oinstall 4625522638 Nov  5 11:43 /home/oracle/patch-repo/goldImage_dbHome_19_28_0.zip
    ```

    </details>

5. In this lab, you won't use the gold image. But you can review the commands needed to install it.

    ``` bash
    # Set environment to new Oracle home
    export ORACLE_HOME=/u01/app/oracle/product/19_28_gold

    # Extract gold image
    unzip /home/oracle/patch-repo/goldImage_dbHome_19_28_0.zip -d $ORACLE_HOME

    # Install the Oracle home
    export PATH=$ORACLE_HOME/bin:$PATH
    export ORAINVENTORY=/u01/app/oraInventory
    export ORACLE_BASE=/u01/app/oracle
    export CV_ASSUME_DISTID=OEL7.6
    cd $ORACLE_HOME
    ./runInstaller \
       -silent -ignorePrereqFailure -waitforcompletion \
       oracle.install.option=INSTALL_DB_SWONLY \
       UNIX_GROUP_NAME=oinstall \
       INVENTORY_LOCATION=$ORAINVENTORY \
       ORACLE_HOME=$ORACLE_HOME \
       ORACLE_BASE=$ORACLE_BASE \
       oracle.install.db.InstallEdition=EE \
       oracle.install.db.OSDBA_GROUP=dba \
       oracle.install.db.OSOPER_GROUP=dba \
       oracle.install.db.OSBACKUPDBA_GROUP=dba \
       oracle.install.db.OSDGDBA_GROUP=dba \
       oracle.install.db.OSKMDBA_GROUP=dba \
       oracle.install.db.OSRACDBA_GROUP=dba \
       SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
       DECLINE_SECURITY_UPDATES=true
    ```

    * Notice that you don't use the `-applyRU` or `-applyOneOffs` parameters.
    * The Oracle home is already patched, so you can skip that part.
    * OPatch is also already updated.
    * By using a gold image in your environment, you know that the same set of patches are in all of your databases.
    * You patch only once, then create a gold image, and use that to distribute to all systems.

What are you thoughts about installing a new Oracle home using AutoUpgrade? How do you think it compares to installing Oracle homes manually?

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, August 2025
