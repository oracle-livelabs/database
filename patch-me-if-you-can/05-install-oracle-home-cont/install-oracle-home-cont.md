# Install Oracle Home - Continued

In this lab, you will use a gold image to install an Oracle home.

## Introduction

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Check Oracle home
* Create Oracle home using gold image

### Prerequisites

This lab assumes:

* You have completed Lab 2: Install Oracle Home

## Task 1: Check AutoUpgrade

Ensure that AutoUpgrade installed the Oracle home and perform a few checks.

1. Switch back to the *yellow* terminal 🟨. AutoUpgrade should have completed by now. If not, wait for it to finish. In the end, AutoUpgrade prints the following information and exits.

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
    /home/oracle/logs/install-oracle-home/cfgtoollogs/patch/auto/status/status.html
    /home/oracle/logs/install-oracle-home/cfgtoollogs/patch/auto/status/status.log
    ```

    </details>

2. Check the inventory and find the newly installed Oracle home.

    ``` bash
    <copy>
    cat /u01/app/oraInventory/ContentsXML/inventory.xml
    </copy>
    ```

    * You should be able to find the XML element matching the Oracle home you just installed. The Oracle home ends with *au*.
    * Notice that the configuration file placeholders (`%RELEASE%` and `%UPDATE%`) were translated into the correct values, *19* and *32*.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    <?xml version="1.0" standalone="yes" ?>
    <! -- Copyright (c) 1999, 2026, Oracle and/or its affiliates.
    All rights reserved. -- >
    <! -- Do not modify the contents of this file by hand. -- >
    <INVENTORY>
    <VERSION_INFO>
       <SAVED_WITH>12.2.0.7.0</SAVED_WITH>
       <MINIMUM_VER>2.1.0.6.0</MINIMUM_VER>
    </VERSION_INFO>
    <HOME_LIST>
    <HOME NAME="OraDB19Home1" LOC="/u01/app/oracle/product/19" TYPE="O" IDX="1"/>
    <HOME NAME="OraDB19Home2" LOC="/u01/app/oracle/product/dbhome_19_32" TYPE="O" IDX="2"/>
    <HOME NAME="OraDB21Home1" LOC="/u01/app/oracle/product/21" TYPE="O" IDX="3"/>
    <HOME NAME="OraDB23Home1" LOC="/u01/app/oracle/product/26" TYPE="O" IDX="4"/>
    <HOME NAME="OraDB19Home3" LOC="/u01/app/oracle/product/dbhome_19_32_au" TYPE="O" IDX="5"/>
    </HOME_LIST>
    <COMPOSITEHOME_LIST>
    </COMPOSITEHOME_LIST>
    </INVENTORY>
    ```

    </details>

3. Check the patches installed.

    ``` bash
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32_au
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>

    # Be sure to press RETURN
    ```

    * Here is the patch specification from the AutoUpgrade config file: `patch=RECOMMENDED,OCW,JDK,SDOBP,29213893`.
    * When this lab was created, *19.32* was the latest Release Update, which AutoUpgrade installed because of the `RECOMMENDED` keyword.
    * Notice that the OCW component has been updated as well. It is now on *19.32.0.0.0*.
    * The *Fix for Bug* entries are patches from the MRP.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    29213893;DBMS_STATS FAILING WITH ERROR ORA-01422 WHEN GATHERING STATS FOR USER$ TABLE
    39692747;SPATIAL BUNDLE PATCH #1 ON DBRU 19.32.0.0.0
    39791916;JDK BUNDLE PATCH 19.0.0.0.260818
    39526364;OCW RELEASE UPDATE 19.32.0.0.0 (39526364)
    39779336;Fix for Bug 39779336
    39750798;Fix for Bug 39750798
    39661089;Fix for Bug 39661089
    39222882;OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)
    39657094;DATAPUMP BUNDLE PATCH 19.32.0.0.0
    39472050;Database Release Update : 19.32.0.0.260721 (39472050)

    OPatch succeeded.
    ```

    </details>

4. Find the gold image.

    ``` bash
    <copy>
    cd ~/patch-repo
    ll gold_image*
    </copy>

    # Be sure to press RETURN
    ```

    * In the AutoUpgrade config file, you selected to create a gold image of the new Oracle home using the parameter `create_gold_image`.
    * After creating the Oracle home, AutoUpgrade creates a gold image.
    * AutoUpgrade stores the gold image in the `download_folder` together with all the patches.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    -rw-r--r--. 1 oracle oinstall 5423128024 Sep  1 18:44 gold_image_dbhome_1932.zip
    ```

    </details>

## Task 2: Create Oracle Home Using a Gold Image

Gold images are a convenient way of installing Oracle homes on many different servers. You prepare and patch an Oracle home only once, and then distribute the patched Oracle home to all other servers.

1. Examine the precreated config file.

    ``` bash
    <copy>
    clear
    cat ~/scripts/pt-05-install-from-gold-image.cfg
    </copy>
    ```

    * The `patch` parameter specifies the gold image you created earlier. You do not specify which patches you want; you install what is included in the gold image.
    * In this lab, you do not use a `source_home` to copy settings from, so you must define the edition and Oracle base using `home_settings`. All other Oracle home settings remain at their default values. You can override the defaults using other `home_settings`.
    * You must define the `target_version` since it can't be deduced from the `patch` setting.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/install-from-gold-image
    patch1.target_home=/u01/app/oracle/product/dbhome_19_32_gold_image
    patch1.target_version=19
    patch1.download_folder=/home/oracle/patch-repo
    patch1.patch=GOLDIMAGE:gold_image_dbhome_1932.zip
    patch1.home_settings.edition=EE
    patch1.home_settings.oracle_base=/u01/app/oracle
    ```

    </details>

2. Start AutoUpgrade to create the Oracle home.

    ``` bash
    <copy>
    cd
    java -jar autoupgrade.jar -config scripts/pt-05-install-from-gold-image.cfg -patch -mode create_home
    </copy>

    # Be sure to press RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +-----------------------------------------+
    | Starting AutoUpgrade Patching execution |
    +-----------------------------------------+
    Type 'help' to list console commands
    patch>
    ```

    </details>

3. Monitor the progress

    ``` bash
    <copy>
    lsj -a 10
    </copy>
    ```

4. It takes a few minutes to extract and install the gold image. Leave AutoUpgrade running.

5. You can use the gold image created by AutoUpgrade many times on the same or different servers. The advantages of using gold images are:

    * You know all servers get the exact same Oracle home.
    * You can install faster because you do not need to apply all the patches.
    * They fit very well with automation.
    * They're easier to test and work well with configuration management.

6. You can also use the gold image created by AutoUpgrade to install a new Oracle home manually.

    * You unzip the gold image to the new Oracle home location.
    * Run the installer with appropriate settings.

7. What are your thoughts about installing a new Oracle home using AutoUpgrade? How do you think it compares to installing Oracle homes manually?

8. Wait for AutoUpgrade to complete the installation. When done, AutoUpgrade prints *Job 100 completed*.

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
    /home/oracle/logs/install-from-gold-image/cfgtoollogs/patch/auto/status/status.html
    /home/oracle/logs/install-from-gold-image/cfgtoollogs/patch/auto/status/status.log
    ```

    </details>

9. In Lab 2, you installed another Oracle home from scratch. Compare the time it took to use the gold image.

    ``` bash
    <copy>
    grep -ho "Total Job Time.*min" /home/oracle/logs/install-oracle-home/create_home_1/100/autoupgrade_patching_*.log | sed 's/^/From scratch: /'
    grep -ho "Total Job Time.*min" /home/oracle/logs/install-from-gold-image/create_home_1/100/autoupgrade_patching_*.log | sed 's/^/From gold image: /'
    </copy>

    # Be sure to press RETURN
    ```

    * You can find the AutoUpgrade job duration in the log files.
    * Installing the Oracle home from scratch and applying the Release Update and other patches takes 24 minutes. This includes the creation of the gold image so the installation time is probably around 18-20 minutes.
    * Installing from a gold image takes only two minutes.
    * Your numbers may vary.
    * It is *much faster* to install a gold image, than installing from scratch and applying all the patches.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    From scratch: Total Job Time    24 min
    From gold image: Total Job Time    2 min
    ```

    </details>

10. Check the patches installed.

    ``` bash
    <copy>
    export ORACLE_HOME=/u01/app/oracle/product/dbhome_19_32_gold_image
    $ORACLE_HOME/OPatch/opatch lspatches
    </copy>

    # Be sure to press RETURN
    ```

    * The Oracle home is fully up to date with the same patches as the original Oracle home.
    * At the creation of this lab, *19.32* was the latest Release Update.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    29213893;DBMS_STATS FAILING WITH ERROR ORA-01422 WHEN GATHERING STATS FOR USER$ TABLE
    39692747;SPATIAL BUNDLE PATCH #1 ON DBRU 19.32.0.0.0
    39791916;JDK BUNDLE PATCH 19.0.0.0.260818
    39526364;OCW RELEASE UPDATE 19.32.0.0.0 (39526364)
    39779336;Fix for Bug 39779336
    39750798;Fix for Bug 39750798
    39661089;Fix for Bug 39661089
    39222882;OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)
    39657094;DATAPUMP BUNDLE PATCH 19.32.0.0.0
    39472050;Database Release Update : 19.32.0.0.260721 (39472050)

    OPatch succeeded.
    ```

    </details>

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026
