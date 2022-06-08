# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

Estimated Time: 10 Minutes.

### Objectives

- Initialize the workshop environment.

### Prerequisites

This lab assumes you have:

- An Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup 
    - Lab: Environment Setup

## Task 1: Validate that required processes are up and running

*Note:* All screenshots for SSH terminal type tasks featured throughout this workshop were captured using the *MobaXterm* SSH Client as described in this step. As a result when executing such tasks from within the graphical remote desktop session you can skip steps requiring you to login as user *oracle* using *sudo su - oracle*, the reason being that the remote desktop session is under user *oracle*.

1. Now with access to your remote desktop session, proceed as indicated below to validate your environment before you start executing the subsequent labs. The following Processes should be up and running:

    - Database Listener
        - LISTENER
    - Database Server Instances
        - FTEX
        - DB12
        - CDB2

    You may test database connectivity clicking on the *+* sign next to each of the 3 Databases as shown below in the *SQL Developer Oracle Connections* panel.

    ![validate your environment](./images/19c_upgrade_landing.png " ")

2. Validate that expected processes are up. Please note that it may take up to 5 minutes after instance provisioning for all processes to fully start.

    ```
    <copy>
    ps -ef|grep LISTENER|grep -v grep
    ps -ef|grep ora_|grep pmon|grep -v grep
    systemctl status oracle-database
    </copy>
    ```

    ![Validate that expected processes are up](./images/check-tns-up.png " ")
    ![Validate that expected processes are up](./images/check-pmon-up.png " ")
    ![Validate that expected processes are up](./images/check-db-service-up.png " ")

    If all expected processes are shown in your output as seen above, then your environment is ready.

3. If you see questionable output(s), failure or down component(s), restart the service accordingly

    ```
    <copy>
    sudo systemctl restart oracle-database
    </copy>
    ```

You may now *proceed to the next lab*.

## Appendix 1: Managing startup services

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
* **Contributors** - Mike Dietrich, Database Product Management
* **Last Updated By/Date** - Rene Fontcha, LiveLabs Platform Lead, NA Technology, August 2021
