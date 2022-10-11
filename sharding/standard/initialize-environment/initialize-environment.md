# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

*Estimated Lab Time:* 30 Minutes.

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER!**

## Task 1: Validate That Required Processes are Up and Running.

**NOTE:** NoVNC remote desktop is active on all 4 hosts that are part of your environment. While you are provided with a single remote desktop URL for *cata* host, you can access other hosts with the same URL after replacing the IP address in the URL with the respective Public IP of the target host.

  ![Remote Desktop Landing Page](./images/remote_desktop_landing1.png "Remote Desktop Landing Page")

1. Now with access to your remote desktop session(s), proceed as indicated below to validate your environment before you start executing the subsequent labs. The following Processes should be up and running:

    - Database Listeners
        - LISTENER (1521)
    - Database Server Instances (see below)

    | Public IP       | Private IP   | Hostname | CDB Name | PDB Name |Listener port|
    | --------------- |  :--------:  | -------- | -------- | -------- |  :-------:  |
    | xxx.xxx.xxx.xxx | 10.0.0.151   | cata     | cata     | catapdb  | 1521        |
    | xxx.xxx.xxx.xxx | 10.0.0.152   | shd1     | shd1     | shdpdb1  | 1521        |
    | xxx.xxx.xxx.xxx | 10.0.0.153   | shd2     | shd2     | shdpdb2  | 1521        |
    | xxx.xxx.xxx.xxx | 10.0.0.154   | shd3     | shd3     | shdpdb3  | 1521        |
    {: title="Summary of Databases and Listeners by Host"}


2. Click the *SQL Developer* icon on the desktop to Launch the application, then Click on the *+* sign next to database connection listed under Oracle Connections

    ![Launch SQL Developer #1](./images/launch_sql_developer1.png "Launch SQL Developer #1")

    If all expected Databases are running as shown below, then your environment is ready for the next task.  

    ![Launch SQL Developer #2](./images/launch_sql_developer2.png "Launch SQL Developer #2")

3. If you are unable to connect to any of the PDBs or CDB shown on the list, connect to the respective host and restart the DB service accordingly via a Terminal session

    ```
    <copy>
    sudo systemctl restart oracle-database
    </copy>
    ```

You may now proceed to the next lab

## Appendix 1: Managing Startup Services

1. Database service (All databases and Standard Listener).

    - Start

    ```
    <copy>
    sudo systemctl start oracle-database
    </copy>
    ```
    - Stop

    ```
    <copy>
    sudo systemctl stop oracle-database
    </copy>
    ```

    - Status

    ```
    <copy>
    systemctl status oracle-database
    </copy>
    ```

    - Restart

    ```
    <copy>
    sudo systemctl restart oracle-database
    </copy>
    ```


## Acknowledgements
* **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
* **Contributors** - Rene Fontcha, Shefali Bhargava, DB Sharding Product Management
* **Last Updated By/Date** - Shefali Bhargava, DB Sharding Product Management, October 2022
