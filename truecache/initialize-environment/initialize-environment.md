# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

*Estimated Time:* 10 Minutes.

Watch the video for a quick walk through of the Initialize Environment lab.

[Initialize Environment lab](youtube:e3EXx3BMhec)

Watch the video for a quick walk through of the Lab1.
[Lab1](videohub:1_2ee2tbuw) 

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup(*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup((*Free-tier* and *Paid Tenants* only))

## Task 1: Validate That Required Processes Are Up and Running.
1. With access to your remote desktop session, validate your environment before you start the subsequent labs. The following processes should be up and running:

    - Oracle primary database container
    - Oracle True Cache  container
    - Client app container

2.  Click on Activities (shown on top left corner) >> Terminal icon (shown on the bottom of the screen which is next to Chrome icon) to Launch the Terminal and follow these steps to validate the services.

![activities_terminal_icon](images/activities_terminal_icon.png " ")

3. Log in to Podman and check for podman containers.

        ```
        <copy>
        sudo podman ps -a
        </copy>
        ```
    ![podman containers](https://oracle-livelabs.github.io/database/truecache/initialize-environment/images/truecache-podman.png " ")

4. If a container is stopped and not in running state then try to restart it.

        ```
        <copy>
        sudo podman stop <container ID/NAME>
        </copy>
        ```
        ```
        <copy>
        sudo podman start <container ID/NAME>
        </copy>
        ```
5. For multiple containers, run the following to restart all at once.

        ```
        <copy>
        sudo podman container stop $(sudo podman container list -qa)
        </copy>
        ```
        ```
        <copy>
        sudo podman container start $(sudo podman container list -qa)
        </copy>
        ```

You may now proceed to the next lab.

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Ilam Siva
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Aug 2025

