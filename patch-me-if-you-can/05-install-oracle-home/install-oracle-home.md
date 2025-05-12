# Install Oracle Home

In this lab, you will install an Oracle home in two different ways. The easy, automated approach using AutoUpgrade and, for comparison, a manual installation.


## Introduction

Estimated Time: 30 Minutes

### Objectives

In this lab, you will:

* Install Oracle home using AutoUpgrade
* Install Oracle home manually

### Prerequisites

This lab assumes:

- You have completed Lab 1: Initialize environment

This is an optional lab. 

## Task 1: Install using AutoUpgrade

First, you will install an Oracle home the easiest way using AutoUpgrade. 

1. Use the *yellow* terminal 🟨. Examine the following AutoUpgrade config file:

    ```
    <copy>
    cd
    cat scripts/install-oracle-home.cfg
    </copy>

    -- Be sure to hit RETURN
    ```

    * `source_home` is an existing Oracle home that you will use as a template to install the new Oracle home. AutoUpgrade installs the new Oracle home using the same settings as this Oracle home. 
    * `target_home` is where you want to install the new Oracle home.
    * `folder` is the location where AutoUpgrade can find and store patch files. Ideally, this location is a network share accessible to all your database hosts. 
    * `patch` informs AutoUpgrade which patches you want to apply. *RECOMMENDED* means the recent-most OPatch and Release Update plus matching OJVM and Data Pump bundle patches. In addition, you are also installing a one-off patch, *29213893*.
    * `download` tells whether AutoUpgrade should attempt to download the patches from My Oracle Support using your My Oracle Support credentials. This is not possible inside this lab environment, so all patches have been pre-downloaded.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat scripts/install-oracle-home.cfg
    global.global_log_dir=/home/oracle/autoupgrade-patching/install-oracle-home/log
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/19_25_au
    patch1.folder=/home/oracle/patch-repo
    patch1.patch=RECOMMENDED,29213893
    patch1.download=no
    ```
    </details>    

2. Start AutoUpgrade to create the Oracle home.

    ```
    <copy>
    java -jar autoupgrade.jar -config scripts/install-oracle-home.cfg -patch -mode create_home
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ java -jar autoupgrade.jar -config scripts/install-oracle-home.cfg -patch -mode create_home
    AutoUpgrade Patching 24.8.241119 launched with default internal options
    Processing config file ...
    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    Type 'help' to list console commands
    patch>
    ```
    </details>    

3. You're now in the AutoUpgrade console. Monitor the progress.
  
    ```
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

4. It takes around 10 minutes to install a new Oracle home and patch it. Leave AutoUpgrade running and move on to the next task.

## Task 2: Check patch files

While AutoUpgrade installs a new Oracle home, you can inspect some of the patch files. 

1. Switch to the *blue* 🟦 terminal. Extract the patch files that you are installing.

    ```
    <copy>
    cd /home/oracle/patch-repo
    unzip p36912597_190000_Linux-x86-64.zip -d ./36912597
    unzip p37056207_1925000DBRU_Generic.zip -d ./37056207
    unzip p36878697_190000_Linux-x86-64 -d ./36878697
    unzip p29213893_1925000DBRU_Generic.zip -d ./29213893
    </copy>

    -- Be sure to hit RETURN
    ```

    * Patch files comes from My Oracle Support as zip files.
    * The patch zip files are the 19.25 Release Update, Data Pump bundle patch, OJVM bundle patch, and a one-off patch.
    
2. Switch to the directory where you extracted the Release Update. Here you find the patch metadata stored in PatchSearch.xml

    ```
    <copy>
    cd 36912597
    ll
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd 36912597
    $ ll
    total 1992
    drwxr-xr-x. 5 oracle oinstall      81 Nov  5 13:09 36912597
    -rw-rw-r--. 1 oracle oinstall 2038582 Oct 15 14:35 PatchSearch.xml
    ```
    </details>       

3. Examine the file.

    ```
    <copy>
    head -n10 PatchSearch.xml
    </copy>
    ```

    * One of the XML elements contains the patch text, *DATABASE RELEASE UPDATE 19.25.0.0.0*.
    * The file contains a lot of metadata about the patch. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    <!-- This file contain patch Metadata -->
    <results md5_sum="5bf0a12bccfd23b199291f7a140df9f3">
      <generated_date in_epoch_ms="1729002935000">2024-10-15 14:35:35</generated_date>
      <patch has_prereqs="n" has_postreqs="n" is_system_patch="n">
        <bug>
          <number>36912597</number>
          <abstract><![CDATA[DATABASE RELEASE UPDATE 19.25.0.0.0]]></abstract>
        </bug>
        <name>36912597</name>
        <type>Patch</type>    
    ```
    </details>     

4. Switch to the subdirectory to find the patch *read me* file.    

    ```
    <copy>
    cd 36912597
    ll
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd 36912597
    $ ll
    total 96
    drwxr-x---.  3 oracle oinstall    21 Oct 11 06:50 custom
    drwxr-x---.  3 oracle oinstall    20 Oct 11 06:50 etc
    drwxr-x---. 46 oracle oinstall  4096 Oct 11 06:47 files
    -rw-r--r--.  1 oracle oinstall 88918 Oct 14 10:01 README.html
    -rw-r--r--.  1 oracle oinstall    21 Oct 11 06:50 README.txt
    ```
    </details>     

5. Open the patch read me.

    ```
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

    ```
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
    ./files/rdbms/admin/bug_32218552_apply.sql
    ./files/rdbms/admin/bug29394140_apply.sql
    ./files/md/admin/bug35161422_apply.sql
    ./files/md/admin/bug32425205_apply.sql
    ./files/md/admin/bug29357424_apply.sql
    ```
    </details>   

8. Examine one of the apply scripts.

    ```
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

## Task 3: Install manually

Install an Oracle manually. This allows you to compare the two methods.

1. Still in the *blue* 🟦 terminal. Create a directory for the new Oracle home.

    ```
    <copy>
    cd
    export ORACLE_HOME=/u01/app/oracle/product/19_25_man
    mkdir -p $ORACLE_HOME
    </copy>

    -- Be sure to hit RETURN
    ```

2. Unzip the Oracle Database 19.3 base release into the new Oracle home.

    ```
    <copy>
    unzip /home/oracle/patch-repo/LINUX.X64_193000_db_home.zip -d $ORACLE_HOME
    </copy>
    ```

    * Oracle recommends that you always start with the base release when you install a new Oracle home.
    * Oracle does not recommend using the same, cloned Oracle home over and over again. Over time, the Oracle home might become bloated.
    * You can download the base release from www.oracle.com.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ unzip /home/oracle/patch-repo/LINUX.X64_193000_db_home.zip -d $ORACLE_HOME
    Archive:  /home/oracle/patch-repo/LINUX.X64_193000_db_home.zip
       creating: /u01/app/oracle/product/19_25_man/drdaas/
       creating: /u01/app/oracle/product/19_25_man/drdaas/admin/
      inflating: /u01/app/oracle/product/19_25_man/drdaas/admin/drdasqtt_translator_setup.sql
      inflating: /u01/app/oracle/product/19_25_man/drdaas/admin/drdapkg_db2.sql
    ...
    (output truncated)  
    ...
      /u01/app/oracle/product/19_25_man/javavm/lib/security/cacerts -> ../../../javavm/jdk/jdk8/lib/security/cacerts
      /u01/app/oracle/product/19_25_man/javavm/lib/sunjce_provider.jar -> ../../javavm/jdk/jdk8/lib/sunjce_provider.jar
      /u01/app/oracle/product/19_25_man/javavm/lib/security/README.txt -> ../../../javavm/jdk/jdk8/lib/security/README.txt
      /u01/app/oracle/product/19_25_man/javavm/lib/security/java.security -> ../../../javavm/jdk/jdk8/lib/security/java.security
      /u01/app/oracle/product/19_25_man/jdk/jre/lib/amd64/server/libjsig.so -> ../libjsig.so
    ```
    </details>  

3. Update OPatch.

    ```
    <copy>
    cd $ORACLE_HOME
    mv OPatch OPatch.old
    unzip /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip -d $ORACLE_HOME
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd $ORACLE_HOME
    $ mv OPatch OPatch.old
    $ unzip /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip -d $ORACLE_HOME
    Archive:  /home/oracle/patch-repo/p6880880_190000_Linux-x86-64.zip
       creating: /u01/app/oracle/product/19_25_man/OPatch/
      inflating: /u01/app/oracle/product/19_25_man/OPatch/opatchauto
       creating: /u01/app/oracle/product/19_25_man/OPatch/ocm/
       creating: /u01/app/oracle/product/19_25_man/OPatch/ocm/doc/
    ...
    (output truncated)  
    ...
      inflating: /u01/app/oracle/product/19_25_man/OPatch/modules/features/com.oracle.orapki.jar
      inflating: /u01/app/oracle/product/19_25_man/OPatch/modules/features/com.oracle.glcm.patch.opatch-common-api-classpath.jar
      inflating: /u01/app/oracle/product/19_25_man/OPatch/modules/com.sun.org.apache.xml.internal.resolver.jar
      inflating: /u01/app/oracle/product/19_25_man/OPatch/modules/com.sun.xml.bind.jaxb-jxc.jar
      inflating: /u01/app/oracle/product/19_25_man/OPatch/modules/javax.activation.javax.activation.jar
    ```
    </details>  

4. Next step is to start the installer. However, only one installer can be active at the same time. Let's check AutoUpgrade and the first Oracle home.

## Task 4: Check AutoUpgrade

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

    ```
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
    <HOME NAME="OraDB19Home2" LOC="/u01/app/oracle/product/19_25" TYPE="O" IDX="4"/>
    <HOME NAME="OraDB19Home3" LOC="/u01/app/oracle/product/19_25_au" TYPE="O" IDX="5"/>
    </HOME_LIST>
    <COMPOSITEHOME_LIST>
    </COMPOSITEHOME_LIST>
    </INVENTORY>
    ```
    </details> 

3. Check the patches installed.

    ```
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/19_25_au
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>

    -- Be sure to hit RETURN
    ```

    * Because the config file contained `patch=RECOMMENDED` AutoUpgrade installed the recent-most Release Update and matching OPatch and bundle patches.
    * The config file also specified a one-off patches, which AutoUpgrade installed as well.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ /u01/app/oracle/product/19_25_au/OPatch/opatch lspatches
    29213893;DBMS_STATS FAILING WITH ERROR ORA-01422 WHEN GATHERING STATS FOR USER$ TABLE
    36878697;OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
    37056207;DATAPUMP BUNDLE PATCH 19.25.0.0.0
    36912597;Database Release Update : 19.25.0.0.241015 (36912597)
    29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    
    OPatch succeeded.
    ```
    </details> 

## Task 5: Install manually, continued

Now that AutoUpgrade has created the first Oracle home, you can start the installer to install the second Oracle home. 

1. Switch to the *blue* 🟦 terminal. Start the installer to attach the Oracle home and apply the patches at the same time.

    ```
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/19_25_man
    export PATH=$ORACLE_HOME/bin:$PATH
    export ORAINVENTORY=/u01/app/oraInventory
    export ORACLE_BASE=/u01/app/oracle
    export CV_ASSUME_DISTID=OEL7.6
    cd $ORACLE_HOME
    ./runInstaller \
       -silent -ignorePrereqFailure -waitforcompletion \
       -applyRU /home/oracle/patch-repo/36912597/36912597  \
       -applyOneOffs /home/oracle/patch-repo/37056207/37056207,/home/oracle/patch-repo/36878697/36878697,/home/oracle/patch-repo/29213893/29213893 \
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
    </copy>

    -- Be sure to hit RETURN
    ```

    * Set the environment before starting the installer.
    * Oracle Database 19c didn't support Oracle Linux 8 to begin with. When installing the base release on this platform, the installer fails because the operating system is not supported. You can avoid that with the environment variable `CV_ASSUME_DISTID`.
    * Notice the `-applyRU` and `-ApplyOneOffs` parameters which instructs the installer to apply the patches to the Oracle home as part of the process.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Preparing the home to patch...
    Applying the patch /home/oracle/patch-repo/36912597/36912597...
    Successfully applied the patch.
    Applying the patch /home/oracle/patch-repo/37056207/37056207...
    Successfully applied the patch.
    Applying the patch /home/oracle/patch-repo/36878697/36878697...
    Successfully applied the patch.
    Applying the patch /home/oracle/patch-repo/29213893/29213893...
    Successfully applied the patch.
    The log can be found at: /u01/app/oraInventory/logs/InstallActions2024-11-05_09-48-23AM/installerPatchActions_2024-11-05_09-48-23AM.log
    Launching Oracle Database Setup Wizard...
    
    The response file for this session can be found at:
     /u01/app/oracle/product/19_25_man/install/response/db_2024-11-05_09-48-23AM.rsp
    
    You can find the log of this install session at:
     /u01/app/oraInventory/logs/InstallActions2024-11-05_09-48-23AM/installActions2024-11-05_09-48-23AM.log
    
    As a root user, execute the following script(s):
    	1. /u01/app/oracle/product/19_25_man/root.sh
    
    Execute /u01/app/oracle/product/19_25_man/root.sh on the following nodes:
    [holserv1]
    
    
    Successfully Setup Software.
    ```
    </details>  

5. It takes around 10 minutes to install the Oracle home. Leave the process running. You can start on the next lab, *Lab 6: Manual patching of a container database*, and return to this lab after a while.

## Task 6: Check manual installation

1. Still in the *blue* 🟦 terminal. 

2. The manual installation should be done by now. The installer should have exited with the message `Successfully Setup Software.`

3. Check the patches in the new Oracle home.

    ```
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/19_25_man
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ $ORACLE_HOME/OPatch/opatch lspatches
    29213893;DBMS_STATS FAILING WITH ERROR ORA-01422 WHEN GATHERING STATS FOR USER$ TABLE
    36878697;OJVM RELEASE UPDATE: 19.25.0.0.241015 (36878697)
    37056207;DATAPUMP BUNDLE PATCH 19.25.0.0.0
    36912597;Database Release Update : 19.25.0.0.241015 (36912597)
    29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
    
    OPatch succeeded.
    ```
    </details> 

4. In this lab, you can't run `root.sh` because of missing privileges. 


## Task 7: Use Gold Image

Gold images are a convenient way of installing Oracle homes on many different servers. You prepare and patch an Oracle home only once, and then distribute the patched Oracle home to all other servers.

1. This is an optional lab that takes around 10 minutes. If you are short on time, you can skip executing the commands, but do read on. 

2. Still in the *blue* 🟦 terminal. Set the environment to the new Oracle home.

    ```
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/19_25_au
    export PATH=$ORACLE_HOME/bin:$PATH
    </copy>

    -- Be sure to hit RETURN
    ```

    * This is the Oracle home you created using AutoUpgrade.
    * The Oracle home is patched with Release Update 25.

3. Create the gold image.

    ```
    <copy>
    $ORACLE_HOME/runInstaller -createGoldImage \
       -destinationLocation /home/oracle/patch-repo \
       -name goldImage_dbHome_19_25_0.zip \
       -silent
    </copy>
    ```

    * The installer puts the Oracle home into a zip file.
    * `destinationLocation` determines where the gold image is placed.
    * `name` tells the installer the name of the zip file.
    * It takes a few minutes to create the gold image.
    * While the installer creates a gold image, reflect on the differences between creating the new Oracle home using AutoUpgrade and manually?
    * You can move on with the next lab while the installer completes.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Launching Oracle Database Setup Wizard...
    
    Successfully Setup Software.
    Gold Image location: /home/oracle/patch-repo/goldImage_dbHome_19_25_0.zip
    ```
    </details> 

4. Find the gold image.

    ```
    <copy>
    ls -l /home/oracle/patch-repo/goldImage*
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ls -l /home/oracle/patch-repo/goldImage*
    -rw-r--r--. 1 oracle oinstall 4625522638 Nov  5 11:43 /home/oracle/patch-repo/goldImage_dbHome_19_25_0.zip
    ```
    </details> 

5. In this lab, you won't use the gold image. But you can review the commands needed to install it.

    ```
    # Set environment to new Oracle home    
    export ORACLE_HOME=/u01/app/oracle/product/19_25_gold

    # Extract gold image
    unzip /home/oracle/patch-repo/goldImage_dbHome_19_25_0.zip -d $ORACLE_HOME

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

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, January 2025