# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

*Estimated Time:* 10 minutes.

<if type="nonsandbox">
Watch the video for a quick walk-through of Lab 3: Initialize Environment.
[Lab 3](videohub:1_y0sporip)
</if>

### Objectives
- Validate that the Primary database, True Cache, and application containers are available.

### Prerequisites
This lab assumes you have:
- A Free Tier, paid OCI, or LiveLabs Oracle Cloud account
- You have completed:
    - Lab 1: Prepare Setup (*Free Tier* and *paid tenancies* only)
    - Lab 2: Environment Setup (*Free Tier* and *paid tenancies* only)

## Task 1: Validate That Required Processes Are Up and Running.
0. If you cannot launch the remote desktop, select View Login Info in the upper-left corner, then select Open Link in the Terraform Outputs section.
    ![terraform url](https://oracle-livelabs.github.io/database/truecache/initialize-environment/images/terraformurl.png " ")
1. Access your remote desktop session and validate your environment before you start the subsequent labs. The following processes should be up and running:

    - Oracle primary database container
    - Oracle True Cache container
    - Client app container

2. Select Activities in the upper-left corner, then select the Terminal icon next to Chrome.

    ![activities_terminal_icon](images/activities_terminal_icon.png " ")

3. List the Podman containers.

        ```
        <copy>
        sudo podman ps -a
        </copy>
        ```
    ![podman containers](https://oracle-livelabs.github.io/database/truecache/initialize-environment/images/truecache-podman.png " ")

4. If a container is not running, start the pre-provisioned containers using the following command.

        ```
        <copy>
        sudo podman start prod truedb appclient
        </copy>
        ```
5. Verify that all containers are running.

        ```
        <copy>
        sudo podman ps --format 'table {{.Names}}\t{{.Status}}'
        </copy>
        ```

Wait until `prod` and `truedb` report **healthy** and all three containers are running. If a named container is missing from `sudo podman ps -a`, contact the lab administrator.

Continue to the next lab.

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
