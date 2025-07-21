# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

*Estimated Lab Time:* 10 Minutes.

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup

## Task 1: Validate That Required Processes are Up and Running.
1. Now with access to your remote desktop session, proceed as indicated below to validate your environment before you start executing the subsequent labs. The following Processes should be up and running:

    - Oracle Sharding GSM1  Container
    - Oracle Sharding GSM2  Container
    - Oracle Sharding Catalog container
    - Three Oracle shard Database containers
    - Appclient Container

2.  Open a terminal session and proceed as indicated below to validate the services.

    - Oracle Sharding container Details

        ```
        <copy>
        sudo podman ps -a
        </copy>
        ```
        ![sharding docker](images/podman-containers.png " ")

    - If a container is stopped and not in running state then try to restart it by using below docker command.

        ```
        <copy>
        sudo podman stop <container ID/NAME>
        </copy>
        <copy>
        sudo podman start <container ID/NAME>
        </copy>
        ```
    - For multiple containers, run the following to restart all at once:

        ```
        <copy>
        sudo podman container stop $(sudo podman container list -qa)
        </copy>
        <copy>
        sudo podman container start $(sudo podman container list -qa)
        </copy>
        ```

You may now proceed to the next lab.

## Acknowledgements
* **Authors** - Deeksha Sehgal, Ajay Joshi, Oracle Globally Distributed Database Database, Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Jyoti Verma
* **Last Updated By/Date** - Ajay Joshi, Oracle Globally Distributed Database, Product Management, July 2025
