# Creating a Custom Database Software Image using OCI Console.

## Introduction
This lab walks you through creating a custom Database Software Image using the OCI Console.

Estimated Time: 30 min

### Objectives
In this lab, you will learn to :
* Create a custom Database Software Image using the OCI Console.

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account.
- IAM policies to create resources in the compartment.


## Task 1: Create a Custom Database Software Image using OCI Console.

1. Open the navigation menu in the OCI Console. Click **Oracle Database**, then click **Exadata on Oracle Public Cloud**.

  ![Navigate to Exadata on Oracle Public Cloud](./images/navigate_to_exacs_public_cloud.png "Navigate to Exadata on Oracle Public Cloud")


2. Choose your **compartment**.

  ![Compartment for DB Software image](./images/choose_compartment.png "Compartment for DB Software image")


3. Under **Resources**,

    * Click on **Database Software Images**.

    * Click on **Create Database Software Image**.

  ![DB Software image creation](./images/navigate_create_db_image.png "DB Software image creation")


4. Provide the below information for the database software image.

    * In the Display name field, provide your image a **Display name**. Avoid entering confidential information.

    * Choose your **compartment**.

    * Choose a **Shape Family**. A custom database software image is compatible with only one shape family. Available shape families for Exadata Cloud Services is **Exadata Shapes**.

    * Choose the **Database version** for your image. You can create a database software image using any supported Oracle Database release update (RU).

    * Choose the patch set update, proactive bundle patch, or release update.

    * Optionally, you can enter a comma-separated list of one-off (interim) patch numbers.

    * Click **Create Database Software Image**.

  ![DB Software image for ExaCS](./images/create_custom_db_image.png "DB Software image for ExaCS")


You may now **proceed to the next lab**.

## Learn More
- You can find more information about Managing Oracle Database Software Images [here](https://docs.oracle.com/en-us/iaas/exadatacloud/exacs/ecc-manage-images.html)


## Acknowledgements
* **Author** - Leona Dsouza, Senior Cloud Engineer, NA Cloud Engineering
* **Contributors** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Last Updated By/Date** - Leona Dsouza, Senior Cloud Engineer, NA Cloud Engineering, July 2022
