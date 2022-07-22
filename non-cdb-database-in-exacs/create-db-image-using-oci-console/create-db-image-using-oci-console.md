# ???

## Introduction
This lab walks you through creating a custom database software image using OCI console.

Estimated Time: 30 min

### Objectives
In this lab, you will learn to :
* Create a custom DB software image using OCI console.

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account.
- IAM policies to create resources in the compartment.
- Network setup for Exadata Cloud Infrastructure.
- Exadata Cloud Infrastructure Deployment.


## Task 1: Create custom DB software image using OCI console.

1. Open the navigation menu in OCI console. Click **Oracle Database**, then click **Exadata on Oracle Public Cloud**.

  ![DB Software image for ExaCS](./images/navigate_to_exacs_public_cloud.png "DB Software image for ExaCS")


2. Choose your **Compartment**.

  ![DB Software image for ExaCS](./images/choose_compartment.png "DB Software image for ExaCS")


3. Under **Resources**,

    * Click on **Database Software Images**.

    * Click on **Create Database Software Image**.

  ![DB Software image for ExaCS](./images/navigate_create_db_image.png "DB Software image for ExaCS")


4. Provide the below information for the database software image.

    * In the Display name field, provide a **display name** for your image. Avoid entering confidential information.

    * Choose your **Compartment**.

    * Choose a **Shape family**. A custom database software image is compatible with only one shape family. Available shape families for Exadata Cloud Services is **Exadata Shapes**.

    * Choose the **Database version** for your image. You can create a database software image using any supported Oracle Database release update (RU).

    * Choose the patch set update, proactive bundle patch, or release update.

    * Optionally, you can enter a comma-separated list of one-off (interim) patch numbers.

    * Click **Create Database Software Image**.

  ![DB Software image for ExaCS](./images/create_custom_db_image.png "DB Software image for ExaCS")


You may now **proceed to the next lab**.

## Learn More
- You can find more information about Launching a Windows Instance [here](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/launchinginstanceWindows.htm)


## Acknowledgements
* **Author** - Leona Dsouza, Senior Cloud Engineer, NA Cloud Engineering
* **Contributors** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Last Updated By/Date** - Leona Dsouza, Senior Cloud Engineer, NA Cloud Engineering, July 2022
