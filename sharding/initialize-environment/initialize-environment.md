# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

*Estimated Lab Time:* 10 Minutes.

Watch the video for a quick walk through of the Initialize Environment lab.

[](youtube:e3EXx3BMhec)

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

    - Oracle Sharding GSM  Container
    - Oracle Sharding Catalog container
    - Three Oracle shard Database containers
    - Nodejs eShop Application Container

2. On the *Web Browser* window on the right preloaded with *eShop Application*, click on the *Login* button to login the Application and select the saved credentials to login. These credentials have been saved within *Web Browser* and are provided below for reference

    ![](images/oracle-shading-noVnc.png " ")
    ```
    Username: <copy>demo@eshop.com</copy>
    ```

    ```
    Password: <copy>demo</copy>
    ```

    ![](images/application-login.png " ")

3. Confirm successful login. Please note that it takes about 2 minutes after instance provisioning for all processes to fully start.

    ![](images/application-demo.png " ")

    If successful, the page above is displayed and as a result your environment is now ready.  

    You may now proceed to the next lab.

4. If you are still unable to login or the login page is not functioning after reloading from the *Workshop Links* bookmark folder, open a terminal session and proceed as indicated below to validate the services.

    - Oracle Sharding container Details

        ```
        <copy>
        sudo docker ps -a
        </copy>
        ```
        ![](images/sharding-docker.png " ")

    - If a container is stopped and not in running state then try to restart it by using below docker command.

        ```
        <copy>
        sudo docker stop <container ID/NAME>
        </copy>
        <copy>
        sudo docker start <container ID/NAME>
        </copy>
        ```
    - For multiple containers, run the following to restart all at once:

        ```
        <copy>
        sudo docker container stop $(docker container list -qa)
        </copy>
        <copy>
        sudo docker container start $(docker container list -qa)
        </copy>
        ```

You may now proceed to the next lab.

## Acknowledgements
* **Authors** - Shailesh Dwivedi, Database Sharding PM , Vice President
* **Contributors** - Alex Kovuru, Nishant Kaushik, Ashish Kumar, Priya Dhuriya, Richard Delval, Param Saini,Jyoti Verma, Virginia Beecher, Rodrigo Fuentes
* **Last Updated By/Date** - Ashish Kumar, Solution Engineer - July 2021
