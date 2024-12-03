# Advanced Patching

## Introduction

In this lab, you will patch another Oracle Database using AutoUpgrade. Since you have already created a new Oracle home, you will use that. There is no need to create a separate Oracle home each database. 

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Assess the patch readiness of a database
* Patch a database

### Prerequisites

This lab assumes:

- You have completed Lab 3: Simple Patching With AutoUpgrade

## Task 1: Analyze database

You will use AutoUpgrade just like in lab 3. 

1. Use the *yellow* terminal 🟨. In this lab, you use a pre-created config file. Examine the config file.

    ```
    <copy>
    cd
    cat scripts/simple-patching-existing-home.cfg
    </copy>

    -- Be sure to hit RETURN
    ```

    * This config file is much simpler than the previous one from lab 3.
    * Since the Oracle home exists, the patch process becomes easier.
    * The *UPGR* database is not running ARCHIVELOG mode, so you must disable restoration.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat scripts/simple-patching-existing-home.cfg
    global.autoupg_log_dir=/home/oracle/autoupgrade-patching/simple-patching-existing-home/log
    patch1.source_home=/u01/app/oracle/product/19
    patch1.target_home=/u01/app/oracle/product/19_25
    patch1.sid=UPGR
    patch1.restoration=no
    ```
    </details>    








3. Current Java Version </br>
Check the current JDK version:

    ```
    <copy>
    $ORACLE_HOME/jdk/bin/java -version
    </copy>
    ```

    ![Java version output ](./images/java-version.png " ")


4. Current Perl Version <br>
Check the current PERL version:

    ```
    <copy>
    $ORACLE_HOME/perl/bin/perl -version
    </copy>
    ```


5. Current Time Zone </br> 
Then check the current time zone version in the container database. Open SQL*Plus:
    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

    ![Open SQL*Plus](./images/sqlplus-lab3.png " ")

    and execute the SQL:

    ```
    <copy>
    column VALUE$ format a8
    select VALUE$, CON_ID from containers(SYS.PROPS$) 
    where NAME='DST_PRIMARY_TT_VERSION' order by CON_ID;
    </copy>

    Hit ENTER/RETURN to execute ALL commands.
    ```

    ![Timezone of database](./images/dst-cdb.png " ")

    Currently, the database uses the default timezone version deployed with Oracle Database 19c.


    Exit from SQL*Plus:

    ```
    <copy>
    exit
    </copy>
    ```

    ![exit SQL*Plus](./images/exit-sqlplus.png " ")




```
      <copy>
      set line 200
      set pages 999
      col owner format a10
      col directory_name format a25
      col directory_path format a50
      select owner, directory_name , directory_path from dba_directories;
      </copy>

      Hit ENTER/RETURN to execute ALL commands.
```

```
      <copy>
      @$ORACLE_HOME/rdbms/admin/utlfixdirs.sql;
      </copy>

      Hit ENTER/RETURN to execute ALL commands.
```


1. Latest available Time Zone Version
    ```
    <copy>
    SELECT dbms_dst.get_latest_timezone_version from dual;
    </copy>
    ```


        ```
    <copy>
    select VALUE$, CON_ID from containers(SYS.PROPS$) where NAME='DST_PRIMARY_TT_VERSION' order by CON_ID;
    </copy>
    ```


You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, December 2024