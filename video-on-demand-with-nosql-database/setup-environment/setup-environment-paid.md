# Prepare Your Environment

## Introduction

This lab walks you through the steps necessary to create a proper operating environment.

Estimated Lab Time:_ 5 minutes

### Objectives

In this lab you will:
* Create a compartment
* Create API Key
* Download Code Bundle
* Learn about Credentials, and Policies
* Set up Cloud Shell

### Prerequisites

This lab assumes you have:

* An Oracle Free Tier, Paid Account or Green Button


## Task 1: Create a Compartment

1. Log into the Oracle Cloud Console using your tenancy. Please make note of what region you are at.

    ![](images/console-image.png)

2. On left side drop down (left of Oracle Cloud banner), go to **Identity & Security** and then **Compartments.**

    ![](images/identity-security-compartment.png)

3. Click **Create Compartment.** This opens up a new window.

  Enter **demonosql** as compartment **Name** field, enter some text into **Description** field and press **Create Compartment** button at bottom of window. The **Parent Compartment** field will display your current parent compartment -- make sure this is your **root** compartment, whatever that is for your case. This HOL assumes the 'demonosql' compartment is a child of the root compartment.

    ![](images/create-compartment.png)


## Task 2: Get Data and Code Bundle

In this task we will copy over a data bundle stored on object storage and place that in the Cloud Shell.

1. Execute the following in your Cloud Shell.

    ````
    <copy>
      cd $HOME
      rm -rf demo-tv-streaming-app
      git clone https://github.com/dario-vega/demo-tv-streaming-app.git
      cp ~/demo-tv-streaming-app/env-freetier.sh ~/demo-tv-streaming-app/env.sh
    </copy>
    ````

2. Exit from Cloud Shell

## Task 3: Understand Credentials, and Policies

**Oracle NoSQL Database Cloud Service uses Oracle Cloud Infrastructure Identity and Access Management to provide secure access to Oracle Cloud.** Oracle Cloud Infrastructure Identity and Access Management enables you to create user accounts and give users permission to inspect, read, use, or manage tables. Credentials are used for connecting your application to the service and are associated with a specific user.

The Oracle NoSQL Database SDKs allow you to provide the credentials to an application in multiple ways. The SDKs support a configuration file as well as one or more interfaces that allow direct specification of the information. You can use the SignatureProvider API to supply your credentials to NoSQL Database. Oracle NoSQL has SDKs in the following languages:  Java, Node.js, Python, Go, Spring and C#.

Another way to handle authentication is with Instance and Resource Principals. The Oracle NoSQL SDKs support both of them. Resource principals are primarily used when authenticating from functions.

Instance Principals is a capability in Oracle Cloud Infrastructure Identity and Access Management (IAM) that lets you make service calls from an instance. With instance principals, you don’t need to configure user credentials or rotate the credentials. Instances themselves are a principal type in IAM and are set up in IAM. You can think of them as an IAM service feature that enables instances to be authorized actors (or principals) to perform actions on service resources.

Oracle NoSQL Database Cloud service has three different resource types, namely, nosql-tables, nosql-rows, and nosql-indexes. It also has one aggregate resource called nosql-family. Policies are created that allow a group to work in certain ways with specific types of resources such as nosql-tables in a particular compartment. All NoSQL tables belong to a defined compartment. In Task 1 of this Lab, we created the demonosql compartment and this is where we will create our tables.

You can use **Instance Principals** to do the connection to NoSQL Cloud Service as shown below in the Node.js example instead of specifying the credentials. Once they are set up, they are simple to use because all you need to do is call the appropriate authorization constructor.

**NoSQL Database Node.js SDK**
```
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
```
In the next labs we are going to be running application code and we need an instance to run that from. We will run this application using Cloud Shell using another way called delegation token

```
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
```

## Task 4: Move to Phoenix

Oracle NoSQL Always Free tables are available only in the Phoenix region. If Phoenix is **not** your home region then we need to move there. Skip this Task if Phoenix is your home region.

1. Check to see if Phoenix shows up in your region drop down list. Click the down **arrow** by the region.

    ![](images/no-phoenix.png)

2. If it is there, **click it** and move your tenancy to Phoenix and **proceed to the next lab.**

    ![](images/phoenix.png)

3. Since it is not there, please subscribe to Phoenix Region. Click the drop down by your region and click **Manage Regions.**

    ![](images/manage-regions.png)

4. This will bring up a list of regions. Look for Phoenix and press **Subscribe**.

    ![](images/capturesuscribe.png)

5. If you haven't been moved to Phoenix, then click **Phoenix** to move your tenancy.

    ![](images/phoenix.png)


You may now **proceed to the next lab.**

## Learn More

* [About Identity and Access Management](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm)
* [About Managing User Credentials](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm)
* [About Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)


# Acknowledgements
* **Author** - Dario Vega, Product Manager, NoSQL Product Management
* **Last Updated By/Date** - Dario Vega, Product Manager, NoSQL Product Management, August 2022
