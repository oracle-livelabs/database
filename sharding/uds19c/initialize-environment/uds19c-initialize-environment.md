# Initialize the Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

*Estimated Time:* 10 Minutes.

Watch the video for a quick walk through of the Initialize Environment lab.

[Initialize Environment lab](youtube:e3EXx3BMhec)

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup 
    - Lab: Environment Setup

## Task 1: Validate that required processes are up and running
1. With access to your remote desktop session, proceed as indicated below to validate your environment before you start running the subsequent labs. The following processes should be up and running:

    - Oracle Sharding GSM1  Container
    - Oracle Sharding GSM2  Container
    - Oracle Sharding Catalog container
    - Three Oracle shard Database containers
    - Appclient Container

2.  Open a terminal session and proceed as indicated below to validate the services.

    - Oracle Sharding container Details

        ```
        <copy>
        sudo docker ps -a
        </copy>
        ```
        ![sharding docker](images/uds19c-init-env-docker-containers-status.png " ")

    - If a container is stopped and not in running state then try to restart it by using the following Docker command.

        ```
        <copy>
        sudo docker stop <container ID/NAME>
        </copy>
        <copy>
        sudo docker start <container ID/NAME>
        </copy>
        ```
    - For multiple containers, run the following commands to restart all of them at once:

        ```
        <copy>
        sudo docker container stop $(sudo docker container list -qa)
        </copy>
        <copy>
        sudo docker container start $(sudo docker container list -qa)
        </copy>
        ```

You may now **proceed to the next lab**.

## Acknowledgements

* **Authors** - Ajay Joshi, Oracle Globally Distributed Database Product Management, Consulting Member of Technical Staff
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Jyoti Verma
* **Last Updated By/Date** - Ajay Joshi, Oracle Globally Distributed Database Product Management, Consulting Member of Technical Staff, October 2023