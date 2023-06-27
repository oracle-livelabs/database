# Lab 2 - Installation and Patching

## Introduction 

In this lab exercise you will install Oracle Database 19.19.0 into a separate home and patch it fully unattended in one single operation. Out-of-place patching is the preferred method, not only for the Database home but also for the Grid Infrastructure Home.

**This is the list of software and patches you are going to install now:**
19.3.0 base release
New opatch version
19.19.0 Release Update
19.19.0 Oracle JVM Bundle
19.19.0 Data Pump Bundle Patch
19.19.0.0.230516 Monthly Recommended Patch 1 for 19.19.0

## Task 1 - Base Release Installation
Create now the new Oracle Home for 19.19.0, unzip the base release and refresh opatch. 

Start by **double-clicking at the "patching" icon** on the desktop (add screenshot). It will open an xterm (Terminal Window) with two open tabs.

Switch to your designated environment. All variables will be set automatically.
  ```
    <copy>
     . cdb1919
    </copy>
  ```

Create the new Oracle Home directory

  ```
    <copy>
     mkdir 1919
    </copy>
  ```
and change into it

  ```
    <copy>
     cd 1919
    </copy>
  ```

As next step, unzip the 19.3.0 base image from the staging location into this directory.

  ```
    <copy>
     unzip /home/oracle/stage/LINUX.X64_193000_db_home.zip -d /u01/app/oracle/product/1919
    </copy>
  ```

Then remove the OPatch directory 

  ```
    <copy>
      rm -rf OPatch
    </copy>
  ```

and unzip the new OPatch from staging into this new Oracle Home. This step is important since older OPatch versions won't have the features we are using today.

  ```
    <copy>
     unzip /home/oracle/stage/p6880880_210000_Linux-x86-64.zip -d /u01/app/oracle/product/1919/
    </copy>
  ```

## Task 2 - Patch Installation

The patches you are going to install are all unpacked into separate directories.

<details>
 <summary>*click here to see the patch file structure*</summary>

  ``` text
/home/oracle/stage
├── dpbp
│   ├── 35261302
│   └── PatchSearch.xml
├── mrp
│   ├── 35333937
│   │   ├── 34340632
│   │   ├── 35012562
│   │   ├── 35037877
│   │   ├── 35116995
│   │   └── 35225526
│   └── PatchSearch.xml
├── ojvm
│   ├── 35050341
│   └── PatchSearch.xml
└── ru
    ├── 35042068
    └── PatchSearch.xml
  ```
</details>

To install all the patches in one single action, you will use the `-applyRU` and `-applyOneOffs` option of the Oracle Universal Installer. Since MRPs were unknown to the OUI a while ago you need to call every included patch separately.

You can either copy & paste the entire command or call the script below:

<details>
 <summary>*click here if you want to copy & paste the command*</summary>

  ``` text
      <copy>
    ./runInstaller -applyRU /home/oracle/stage/ru/35042068  \
 -applyOneOffs /home/oracle/stage/ojvm/35050341,/home/oracle/stage/dpbp/35261302,/home/oracle/stage/mrp/35333937/34340632,/home/oracle/stage/mrp/35333937/35012562,/home/oracle/stage/mrp/35333937/35037877,/home/oracle/stage/mrp/35333937/35116995,/home/oracle/stage/mrp/35333937/35225526 \
   -silent -ignorePrereqFailure -waitforcompletion \
    oracle.install.option=INSTALL_DB_SWONLY \
    UNIX_GROUP_NAME=oinstall \
    INVENTORY_LOCATION=/u01/app/oraInventory \
    ORACLE_HOME=/u01/app/oracle/product/1919 \
    ORACLE_BASE=/u01/app/oracle \
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
  ```
</details>

```
./runInstaller -applyRU /home/oracle/stage/ru/35042068  \
 -applyOneOffs /home/oracle/stage/ojvm/35050341,/home/oracle/stage/dpbp/35261302,/home/oracle/stage/mrp/35333937/34340632,/home/oracle/stage/mrp/35333937/35012562,/home/oracle/stage/mrp/35333937/35037877,/home/oracle/stage/mrp/35333937/35116995,/home/oracle/stage/mrp/35333937/35225526 \
   -silent -ignorePrereqFailure -waitforcompletion \
    oracle.install.option=INSTALL_DB_SWONLY \
    UNIX_GROUP_NAME=oinstall \
    INVENTORY_LOCATION=/u01/app/oraInventory \
    ORACLE_HOME=/u01/app/oracle/product/1919 \
    ORACLE_BASE=/u01/app/oracle \
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

<details>
 <summary>*Or click here to copy the script command*</summary>

  ``` text
    <copy>
     /home/oracle/patch/install_patch.sh
    </copy>
  ```
</details>


The installation will take approximately 10 minutes. 

Once the installation is completed, you will need to execute `root.sh` at the end of the following lab.


You may now *proceed to the next lab*





