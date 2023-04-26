# Provision and Configure the Cloud Infrastructure

## Introduction

In this lab, we will create the Oracle Cloud Infrastructure (OCI) *Policies* required for least-privilege provisioning of the workshop infrastructure.  Additionally we will create an OCI *Compartment* to isolate the resources created during this workshop.

**If you are not in the OCI Administrators group,** please have an OCI Administrator perform these each task for you.  If you are in the Administrators group, Tasks 3 and 4 are optional.

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Ensure you have the correct OCI Policies
* Create an OCI Compartment

### Prerequisites

This lab assumes you have:

    An Oracle Cloud Paid Account
    You have completed:
        Get Started

## Task 1: Open the Cloud Shell

As a user in the Administrator group, log into the Oracle Cloud Console and open the *Cloud Shell*

![cloud-shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png)

## Task 2: Delete Compartment

In the *Cloud Shell*, run the following commands to delete the sub-*Compartment* used in the workshop:

    ```bash
    <copy>
    MY_COMPARTMENT=$(oci iam compartment list --name [](var:oci_compartment) | jq -r '.data[]."id"')

    oci iam compartment delete --compartment-id $MY_COMPARTMENT --force
    </copy>
    ```

## Task 3: Create a Group and Assign User

A *Group* is a collection of cloud users who all need the same type of access to a particular set of resources or compartment.  A *Group* is very similar to a database role, with a small twist of direction.  While a database role is granted to database users, a cloud user is assigned to a cloud *Group*.

In the *Cloud Shell*, run the following commands to create a *Group* and assign the cloud user to it:

    ```bash
    <copy>

    </copy>
    ```

## Task 4: Apply Compartment Policies to the Group

A *Policy* specifies who can access which OCI resources, and how.  A *Policy* simply allows a *Group* to work in certain ways with specific types of resources in a particular compartment.  In database terms, this is the process of granting privileges (*Policy*) to a role (*Group*) against a specific schema (*Compartment*).

In the *Cloud Shell*, run the following commands to assign *Policies* to the *Group* against the *Compartment*:

    ```bash
    <copy>
    allow group [](var:oci_group) to use cloud-shell in tenancy

    </copy>
    ```

## Learn More

* [OCI - Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
* [OCI - Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm)
* [OCI - Managing Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
* [OCI - Getting Started with Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
