# Provisioning an Autonomous JSON Database

## Introduction

This lab walks you through the steps to get started using the Oracle Autonomous JSON Database [AJD] on Oracle Cloud. In this lab, you will provision a new AJD instance and connect to the Autonomous Database using JSON.

Watch this video for an overview of how to provision an Oracle Autonomous JSON Database.

[This video shows an overview of the steps in this lab.](youtube:Hgyg5VJEfk0)

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Learn how to provision a new Autonomous Database
* Connect to your Autonomous Database using JSON

### Prerequisites

* Be logged into your Oracle Cloud Account

## Task 1: Choose AJD from the Services Menu

1. Login to the Oracle Cloud.

<if type="freetier">

2. If you are using a Free Trial or Always Free account, and you want to use Always Free Resources, you need to be in a region where Always Free Resources are available. You can see your current default **Region** in the top, right-hand corner of the page.

    ![Select region on the far upper-right corner of the page.](./images/region.png " ")

</if>
<if type="livelabs">

2. If you are using a LiveLabs account, you need to be in the region your account was provisioned in. You can see your current default **Region** in the top, right-hand corner of the page. Make sure that it matches the region on the LiveLabs Launch page.

    ![Select region on the far upper-right corner of the page.](./images/region.png " ")

</if>

3. Click the navigation menu in the upper left to show top-level navigation choices.

    ![Oracle home page.](./images/navigation.png " ")

4. Click on **Oracle Database** and choose **Autonomous JSON Database**.

    ![Click Autonomous JSON Database](./images/adb-json.png " ")

5. Use the __List Scope__ drop-down menu on the left to select a compartment. Make sure your workload type is __JSON Database__. <if type="livelabs">Enter the first part of your user name, for example `LL185` in the Search Compartments field to quickly locate your compartment.

    ![Check the workload type on the left.](images/livelabs-compartment.png " ")

</if>
<if type="freetier">
    ![Check the workload type on the left.](./images/compartments.png " ")
</if>
    ![workload type](./images/workload-type.png " ")

<if type="freetier">
   > **Note:** Avoid the use of the ManagedCompartmentforPaaS compartment as this is an Oracle default used for Oracle Platform Services.
</if>

## Task 2: Create the AJD Instance

1. Click **Create Autonomous Database** to start the instance creation process.

    ![Click Create Autonomous Database.](./images/create-adb.png " ")

2.  This brings up the __Create Autonomous Database__ screen where you will specify the configuration of the instance.

3. Provide basic information for the autonomous database:

<if type="freetier">
    - __Choose a compartment__ - Select a compartment for the database from the drop-down list.
</if>
<if type="livelabs">
    - __Choose a compartment__ - Use the default compartment that includes your user id.
</if>
    - __Display Name__ - Enter a memorable name for the database for display purposes. For this lab, use __JSONDB__.
<if type="freetier">
    - __Database Name__ - Use letters and numbers only, starting with a letter. Maximum length is 14 characters. (Underscores not initially supported.) For this lab, use __JSONDB__.

    ![Enter the required details.](./images/adb-info.png " ")
</if>
<if type="livelabs">
    - __Database Name__ - Use letters and numbers only, starting with a letter. Maximum length is 14 characters. (Underscores not initially supported.) For this lab, use __JSONDB__ and append you LiveLabs user id. For example, __JSONDB7199__.

    ![adb info livelabs](./images/adb-info-livelabs.png)
</if>

4. Choose a workload type: Select the workload type for your database from the choices:

    - __JSON__ - For this lab, choose __JSON__ as the workload type.

    ![Choose a workload type.](./images/workload-type2.png " ")

5. Choose a deployment type: Select the deployment type for your database from the choices:

    - __Shared Infrastructure__ - For this lab, choose __Shared Infrastructure__ as the deployment type.
    - __Dedicated Infrastructure__ - Alternatively, you could have chosen Dedicated Infrastructure as the deployment type.

    ![Choose a deployment type.](./images/deployment-type.png " ")

6. Configure the database:

    <if type="freetier">
    - __Always Free__ - If your Cloud Account is an Always Free account, you can select this option to create an always free autonomous database. An always free database comes with 1 CPU and 20 GB of storage. For this lab, we recommend you leave Always Free unchecked.
    </if>
    <if type="livelabs">
    - __Always Free__ - For this lab, we recommend you leave Always Free unchecked.
    </if>
    - __Choose database version__ - Select 19c from the database version. Note: This lab should work on 21c AJD database as well.
    - __OCPU count__ - Number of OCPUs for your service. For this lab, leave the default __1 OCPU__. If you choose an Always Free database, it comes with 1 OCPU.
    - __Storage (TB)__ - Select your storage capacity in terabytes. For this lab, leave the default __1 TB__ of storage. If you choose an Always Free database, it comes with 20 GB of storage.
    - __Auto Scaling__ - For this lab, keep auto scaling enabled, to allow the system to automatically use up to three times more CPU and IO resources to meet workload demand.

    *Note: You cannot scale up/down an Always Free autonomous database.*

    ![Choose the remaining parameters.](./images/configuration.png " ")

7. Create administrator credentials:

    - __Password and Confirm Password__ - Specify the password for ADMIN user of the service instance and confirm the password.

    The password must meet the following requirements:
    - The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character.
    - The password cannot contain the username.
    - The password cannot contain the double quote (") character.
    - The password must be different from the last 4 passwords used.
    - The password must not be the same password that is set less than 24 hours ago.
    - Re-enter the password to confirm it. Make a note of this password.

    Later stages of this LiveLab will be easier if you avoid any of the characters / : ? # [ ] and @ in your password.
    
    ![Enter password and confirm password.](./images/administration.png " ")

8. Set network access:

    In order to use the Database API for MongoDB, you must set the database up with an access control rule. So choose __Secure access from allowed IPs and VCNs only__.

    We will then set a CIDR block to allow access from any IP address. This should *never* be done for a production database, but makes it simpler for our database to be accessed from Cloud Shell in the next lab.

    ![network access](./images/network-access.png " ")

    Now under __IP notation type__ select "CIDR Block". Under __Values__ enter "0.0.0.0/0".

    ![network cidr](./images/network-cidr.png " ")


9. Choose a license type:

    For Autonomous JSON Database, only __License Included__ is available. For other Autonomous Database workloads, you have these options:
    - __Bring Your Own License (BYOL)__ - Select this type when your organization has existing database licenses.
    - __License Included__ - Select this type when you want to subscribe to new database software licenses and the database cloud service.

    ![license type](./images/license-type.png " ")

10. Click __Create Autonomous Database__.

    ![Click Create Autonomous Database.](./images/create-adb-final.png " ")

11.  Your instance will begin provisioning. In a few minutes, the state will turn from Provisioning to Available. At this point, your Autonomous JSON database is ready to use! Have a look at your instance's details here including the Database Name, Database Version, OCPU Count, and Storage.

    ![Database instance homepage.](./images/provisioning.png " ")

## Task 3: Check the URL for the Database API for MongoDB


1. On the Autonomous Database Details page, click on the Service Console button.

    ![service console](./images/service-console.png)

2. On the Service Console, click on __Development__ on the left-hand side

    ![service console dev](./images/service-console-dev.png)

3. Scroll down to the bottom of the Development page, and you should see a card titled Oracle Database API for MongoDB (if you don't, it's possible you didn't set up secure access to your database). There are two URLs listed, copy the first one and save it in a text file somewhere for later use.

    ![mongo urls](./images/mongo-urls.png)

Again, make sure you have saved these URLs for the next lab.

You may now **proceed to the next lab**.

## Learn More

* [Provision Autonomous JSON Database](https://docs.oracle.com/en/cloud/paas/autonomous-json-database/ajdug/autonomous-provision.html#GUID-0B230036-0A05-4CA3-AF9D-97A255AE0C08)

## Acknowledgements

- **Author** - Roger Ford, Principal Product Manager, Oracle Database
- **Contributors** - Kamryn Vinson, Andres Quintana
- **Last Updated By/Date** - Roger Ford, March 2022
