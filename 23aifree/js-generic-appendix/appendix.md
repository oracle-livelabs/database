# Instructions for setup, tear-down and backup

## Introduction

This final lab contains instructions on how to perform the following tasks:

- Create the `emily` account
- Remove all traces of the lab from the database
- Back up the `emily` schema for later use

Estimated Lab Time: 10 minutes

### Prerequisites

This lab assumes you have:

- An Oracle Database 23ai Free - Developer Release environment available to use

## Task 1: Recreate the EMILY account

Use the following snippet to create the EMILY account.

> **Note:** the account will be dropped as part of the script's execution!

Make sure you are connected as `SYS` to `freepdb1` before executing the script.

```sql
<copy>
connect / as sysdba
alter session set container = freepdb1;

set echo on
drop user if exists emily cascade;

create user emily identified by &secretpassword
default tablespace users quota unlimited on users;

grant create session to emily;
grant db_developer_role to emily;
grant execute on javascript to emily;

host mkdir /home/oracle/hol23c 2> /dev/null || echo "directory exists"

drop directory if exists javascript_src_dir;
create directory javascript_src_dir as '/home/oracle/hol23c';
grant read, write on directory javascript_src_dir to emily;

exit
</copy>
```

Please remember to take a note of the password, you will need it later.

## Task 2: Tearing down

If you would like to start from scratch again, or otherwise remove any traces of this lab from your environment, execute the following snippet as `SYS` while connected to `freepdb1`:

```sql
<copy>
drop user emily cascade;
drop directory javascript_src_dir;
</copy>
```

## Task 3: Create a backup of your progress

You can use Data Pump to export the schema for later reference. The following command exports the `emily` schema to the `/home/oracle/hol23c`. Please adjust the password to match yours:

```bash
<copy>
export HISTCONTROL=ignoreboth
  expdp emily/yourSecretPassword@localhost/freepdb1 \
    directory=JAVASCRIPT_SRC_DIR \
    logfile=backup.log \
    dumpfile=backup.dmp
</copy>
```

The export shouldn't take long, the output should resemble this:

```
Export: Release 23.0.0.0.0 - Developer-Release on Tue May 2 10:47:00 2023
Version 23.2.0.0.0

Copyright (c) 1982, 2023, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 23ai Free, Release 23.0.0.0.0 - Developer-Release
Starting "EMILY"."SYS_EXPORT_SCHEMA_01":  emily/********@localhost/freepdb1 directory=JAVASCRIPT_SRC_DIR logfile=backup.log dumpfile=backup.dmp 
Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
Processing object type SCHEMA_EXPORT/TABLE/TABLE
Processing object type SCHEMA_EXPORT/TABLE/COMMENT
Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
Master table "EMILY"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
******************************************************************************
Dump file set for EMILY.SYS_EXPORT_SCHEMA_01 is:
  /home/oracle/hol23c/backup.dmp
Job "EMILY"."SYS_EXPORT_SCHEMA_01" successfully completed at Tue May 2 10:47:37 2023 elapsed 0 00:00:34
```

The last line is the most important one, it should read `Job ... successfully completed at ...`

> **Note:** setting `HISTCONTROL` to `ignoreboth` should hide the command from the bash history

## Task 4: Restore your progress to a previous state

If you would like to restore your progress from an earlier state you can do so as follows.

1. Re-create the `emily` account with the correct permissions

    Follow the instructions shown in task 1 to create the `emily` account in the database.

2. Import the Data Pump export file

    Assuming you followed the instructions in task 3 you can restore your status as follows:

    ```bash
    <copy>
    export HISTCONTROL=ignoreboth
      impdp emily/yourSecretPassword@localhost/freepdb1 \
        directory=JAVASCRIPT_SRC_DIR \
        logfile=import.log \
        dumpfile=backup.dmp
    </copy>
    ```

    As before you should see a success message after a short while:

    ```
    Import: Release 23.0.0.0.0 - Developer-Release on Tue May 2 10:54:49 2023
    Version 23.2.0.0.0

    Copyright (c) 1982, 2023, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 23ai Free, Release 23.0.0.0.0 - Developer-Release
    Master table "EMILY"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    Starting "EMILY"."SYS_IMPORT_FULL_01":  emily/********@localhost/freepdb1 directory=javascript_src_dir logfile=import.log dumpfile=backup.dmp 
    Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    Job "EMILY"."SYS_IMPORT_FULL_01" successfully completed at Tue May 2 10:54:55 2023 elapsed 0 00:00:03
    ```

## Acknowledgements

- **Author** - Martin Bach, Senior Principal Product Manager, ST & Database Development
- **Contributors** -  Lucas Braun, Sarah Hirschfeld
- **Last Updated By/Date** - Martin Bach 02-MAY-2023
