# Initialize Environment

## Introduction

Check the pre-provisioned containers and database services before starting the detailed labs. The schema and sample data are already installed.

*Estimated Time:* 10 minutes.

### Objectives

- Check the three lab containers.
- Verify the Primary and True Cache database roles and active services.

### Prerequisites

Open the remote-desktop link supplied with your workshop. For a sandbox reservation, select **View Login Info**, then the remote-desktop **Open Link**. You do not need to create a stack or load data for this pre-provisioned environment.

## Task 1: Check the Containers

1. In the remote desktop, select **Activities**, then **Terminal**. This is the host terminal. You can maximize the window by double-clicking its title bar. If **Activities** is hidden because Chrome is full-screen, press **Alt+F2**, enter `gnome-terminal`, and press Enter.

    ![Open Terminal from Activities](images/activities_terminal_icon.png)

2. List the containers.

    ```bash
    <copy>
    sudo podman ps -a
    </copy>
    ```

    **Expected:** `prod` and `truedb` are running and healthy; `appclient` is running. If a container is stopped, use **Troubleshooting** below. If it is starting, wait and repeat the check.

    The detailed labs use Terminal. To open FastLab instead, launch **Activities > Google Chrome** and visit `http://127.0.0.1:8080/`. Do not run FastLab workloads while performing the detailed exercises.

## Task 2: Check Primary

1. Enter the Primary container from the host terminal.

    ```bash
    <copy>
    sudo podman exec -it prod /bin/bash
    </copy>
    ```

2. At the container prompt, open SQL*Plus.

    ```bash
    <copy>
    ORACLE_SID=ORCLCDB sqlplus / as sysdba
    </copy>
    ```

3. At `SQL>`, check the role and active service.

    ```sql
    <copy>
    select database_role, open_mode from v$database;
    alter session set container=ORCLPDB1;
    select name from v$active_services where upper(name) = 'SALES1';
    </copy>
    ```

    **Expected:** `PRIMARY`, `READ WRITE`, and an active `SALES1` service. An empty service result needs the conditional service-start step under **Troubleshooting**; it is not a successful check.

4. Type `exit` at `SQL>` to leave SQL*Plus, then `exit` at the container prompt to return to the host.

## Task 3: Check True Cache

1. Enter True Cache from the host terminal.

    ```bash
    <copy>
    sudo podman exec -it truedb /bin/bash
    </copy>
    ```

2. At the container prompt, open SQL*Plus.

    ```bash
    <copy>
    ORACLE_SID=TRUEDB sqlplus / as sysdba
    </copy>
    ```

3. At `SQL>`, check the role and active read service.

    ```sql
    <copy>
    select database_role, open_mode from v$database;
    alter session set container=ORCLPDB1;
    select name from v$active_services where upper(name) = 'SALES1_TC';
    </copy>
    ```

    **Expected:** `TRUE CACHE`, `READ ONLY WITH APPLY`, and an active `SALES1_TC` service.

4. Type `exit` to leave SQL*Plus, then `exit` to return to the host.

## Completion

All three containers are running, both database roles are correct, and both services are active. Continue to [Prepare and Warm True Cache](../data-load/data-load_dbw26.md).

## Troubleshooting

**A container is stopped:** run this at the host prompt, then repeat Task 1. Database startup can take several minutes.

```bash
<copy>
sudo podman start prod truedb appclient
</copy>
```

If a named container is missing, or remains unhealthy, stop and contact the lab administrator at [LiveLabs Help](mailto:livelabs-help-db_us@oracle.com). Do not recreate the database or containers.

**The Primary service query is empty:** in the Primary SQL*Plus session, after selecting `ORCLPDB1`, run:

```sql
<copy>
execute dbms_service.start_service('SALES1');
select name from v$active_services where upper(name) = 'SALES1';
</copy>
```

**The True Cache service query is empty:** in the True Cache SQL*Plus session, after selecting `ORCLPDB1`, run:

```sql
<copy>
execute dbms_service.start_service('SALES1_TC');
select name from v$active_services where upper(name) = 'SALES1_TC';
</copy>
```

If a service-start command reports that it is already running, repeat the active-service query. Continue only when the service appears. Other Oracle errors require investigation; do not treat them as a pass.

## Acknowledgements

* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
