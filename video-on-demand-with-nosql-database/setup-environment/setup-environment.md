# Prepare Your Environment

## Introduction

This lab walks you through the steps necessary to create a proper operating environment.

_Estimated Time:_ 7 minutes


### Objectives

In this lab you will:
* Create a Compartment
* Download Code Bundle
* Deploy Infrastructure using Terraform
* Learn about Credentials, and Policies

### Prerequisites

This lab assumes you have:

* An Oracle Free Tier, Paid Account or Green Button


## Task 1: Create a Compartment

1. Log into the Oracle Cloud Console using your tenancy. Please make note of
what region you are at.

    ![Oracle Cloud Console](https://oracle-livelabs.github.io/common/images/console/home-page.png)

2. On left side drop down (left of Oracle Cloud banner), go to **Identity & Security**
and then **Compartments.**

    ![Identity & Security](https://oracle-livelabs.github.io/common/images/console/id-compartment.png)

3. Click **Create Compartment.** This opens up a new window.

  Enter **demonosql** as compartment **Name** field, enter some text into **Description**
  field and press **Create Compartment** button at bottom of window.
  The **Parent Compartment** field will display your current parent compartment --
  make sure this is your **root** compartment, whatever that is for your case.
  This HOL assumes the 'demonosql' compartment is a child of the root compartment.

    ![create-compartment](images/create-compartment.png)

## Task 2: Get Data and Code Bundle

In this task we will copy over a data bundle stored on object storage and
place that in the Cloud Shell.

1. Open the **Cloud Shell** in the top right menu. It can take about 2 minutes
to get the Cloud Shell started.

    ![Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png)

2. Execute the following in your Cloud Shell.

    ```shell
    <copy>
    cd $HOME
    rm -rf video-on-demand-with-nosql-database
    curl -L https://github.com/oracle/nosql-examples/raw/master/zips/video-on-demand-with-nosql-database.zip -o video-on-demand-with-nosql-database.zip
    unzip video-on-demand-with-nosql-database.zip
    cd ~/video-on-demand-with-nosql-database/data/
    sh unzip.sh
    cd $HOME
    </copy>
    ```

3. Exit from Cloud Shell

## Task 3: Deploy Infrastructure using Terraform

1. To deploy the application, we will use a terraform scripts provided for this Lab. Click on the 'Deploy to Oracle Cloud ' button.  This will create a new window in your browser.

  [![Deploy to Oracle Cloud - home](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle/nosql-examples/raw/master/zips/video-on-demand-with-nosql-database.zip)

2. After successfully hitting the 'Deploy to Oracle Cloud' button, you will be brought to a new screen.

  ![cloud-account-name](images/cloud-account-name.png)


3. Provide your **Cloud Account Name** (tenancy name, not your username or email) and click on Next.

  Log into your account using your credentials (system may have remembered this from a prior log in).  You will see the Create Stack screen below:

  ![create-stack](images/create-stack.png)

  Click on the box "I have reviewed and accept the Oracle Terms of Use."  After clicking this box, it will populate the stack information, the name and the description.  Check the 'Create in compartment' box and make sure it shows demonosql.   If it does not, change it to demonosql.  

4. Click on Next on bottom left of screen.  This will move you to the 'Configure Variables' screen. Configure the variables for the infrastructure resources that this stack needs prior to running the apply job.

  Choose demonosql as _Compartment_  from the drop down list.

  ![configure-var](images/configure-var.png)

5. Click on Next, which brings you to the 'Review' screen.  Click on Create.

  ![review-screen](images/review-screen.png)

  A job will run automatically. It takes approx 1 minute. Wait still "State" field becomes **Succeeded.**  While it is running you will see a new screen that has the status displayed.   

  ![stack-progress](images/stack-progress.png)

  While it is running, go ahead and start Task 4. Once it has succeeded you can sign out and  delete that window from your browser.

## Task 4: Understand Credentials, and Policies

  1. Read the following information.

    Oracle NoSQL Database Cloud Service uses Oracle Cloud Infrastructure Identity and Access Management which enables you to create user accounts and control access to cloud resources.  With respect to Oracle NoSQL, you can give users permission to inspect, read, use, or manage NoSQL tables.  There are 4 authentication methods available: API key-based, Session token-based (delegation tokens), Instance Principal and Resource Principal. The Oracle NoSQL Database SDKs allow you to provide the credentials for an application using any of these authentication methods. Credentials are typically associated with a specific user.

    Oracle NoSQL has SDKs in the following languages:  **Java, Node.js, Python, Go, Spring and C#.**

    The SDKs support a configuration file as well as API interfaces that allow direct specification of the credential information. You can use the SignatureProvider API to supply your API key-based credentials to NoSQL Database. The usual things provided include user OCID, tenancy OCID, private key, and fingerprint. The Session token-based approach is similar but it adds a temporary session token which usually expires in an hour.   This is useful when a temporary authentication is required.

    Another way to handle authentication is with Instance and Resource Principals.

    Resource principals allow you to authenticate and access Oracle Cloud Infrastructure resources.  A resource principal consists of a temporary session token (which typically is cached for 15 minutes) and secure credentials that enables the owner/user to authenticate to Oracle Cloud Infrastructure services. To use them you have to set up a dynamic group and create a policy that grants the dynamic group access to a resource.   These are typically used when authenticating into the NoSQL Cloud Service from functions (NoSQL Cloud Service would be the resource).

    Instance Principals is a capability in Oracle Cloud Infrastructure Identity and Access Management (IAM) that lets you make service calls from an instance. With instance principals, you don’t need to configure user credentials or rotate the credentials. Instances themselves are a principal type set up in IAM. You can think of them as an IAM service feature that enables instances to be authorized actors (or principals) to perform actions on service resources.

    Oracle NoSQL Database Cloud service has three different resource types, namely,`nosql-tables`, `nosql-rows`, and `nosql-indexes`. It also has one aggregate resource called `nosql-family`. Policies are created that allow a group to work in certain ways with resources such as `nosql-tables` in a particular compartment. All NoSQL tables belong to a defined compartment. In Task 1 of this Lab, we created the demonosql compartment and this is where we will create our tables.

    You can use Instance Principals to do the connection to NoSQL Cloud Service as shown below in the Node.js example instead of specifying the credentials. Once they are set up, they are simple to use because all you need to do is call the appropriate authorization constructor.

    **NoSQL Database Node.js SDK**

    ```node
    <copy>
    function createClientResource() {
      return new NoSQLClient({
        region: process.env.NOSQL_REGION ,
        compartment:process.env.NOSQL_COMPID,
          auth: {
            iam: {
              useInstancePrincipal: true
          }
        }
      });
    }
    </copy>
    ```

   Also in one of our next labs we are going to be running application code and we need an instance to run that from. We will run that application using Cloud Shell with a delegation token.

    ```node
    <copy>
    function createClientResource() {
      return new NoSQLClient({
        region: process.env.NOSQL_REGION ,
        compartment:process.env.NOSQL_COMPID,
        auth: {
          iam: {
              useInstancePrincipal: true,
              delegationTokenProvider: process.env.OCI_DELEGATION_TOKEN_FILE
          }
        }
      });
    }
    </copy>
    ```

   You may now **proceed to the next lab.**

## Learn More

* [About Identity and Access Management](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm)
* [About Managing User Credentials](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm)
* [About Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)


## Acknowledgements
* **Author** - Dario Vega, Product Manager, NoSQL Product Management
* **Last Updated By/Date** - Michael Brey, Director, NoSQL Product Development, July 2023
