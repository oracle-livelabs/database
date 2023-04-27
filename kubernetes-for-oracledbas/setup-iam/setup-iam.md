# Setup OCI Tenancy

## Introduction

In this lab, we will create the Oracle Cloud Infrastructure (OCI) *Policies* required for least-privilege provisioning of the workshop infrastructure.  Additionally we will create an OCI *Compartment* to isolate the resources created during this workshop.

<if type="tenancy">

**If you are not in the OCI Administrators group,** please have an OCI Administrator perform these each task for you.

</fi>

*Estimated Lab Time:* 2 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Create an OCI Compartment
* Ensure you have the correct OCI Policies

### Prerequisites

This lab assumes you have:

* An Oracle Cloud Paid Account
* You have completed:
  * Get Started

## Task 1: Open the Cloud Shell

*Cloud Shell* is a web browser-based terminal accessible from the Oracle Cloud Console. *Cloud Shell* is free to use (within monthly tenancy limits), and provides access to a Linux shell, with a pre-authenticated OCI CLI, a pre-authenticated Ansible installation, Terraform and other useful tools.

<if type="tenancy">

As a user in the **Administrator** group, log into the Oracle Cloud Console and open the *Cloud Shell*

</fi>

<if type="freetier">

Log into the Oracle Cloud Console and open the *Cloud Shell*

</fi>

![cloud-shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png)

## Task 2: Create a Compartment

A *Compartment* is a collection of cloud assets, including Databases, Oracle Kubernetes Clusters, Compute Instances, Load Balancers and so on.

You can think of a *Compartment* much like a database schema: a collection of tables, indexes, and other objects isolated from other schemas.  By default, a root *Compartment* (think SYSTEM schema) was created for you when you created your tenancy.  It is possible to create everything in the root *Compartment*, but Oracle recommends that you create sub-*Compartments* to help manage your resources more efficiently.

In the *Cloud Shell*, run the following commands to create a sub-*Compartment* to the root *Compartment*:

    ```bash
    <copy>
    LL_COMPARTMENT=$(oci iam compartment create --name [](var:oci_compartment) --description "[](var:description)" --compartment-id $OCI_TENANCY --query data.id --raw-output)
    echo "Compartment OCID: $LL_COMPARTMENT"
    </copy>
    ```

## Task 3: Create a Group and Assign User

A *Group* is a collection of cloud users who all need the same type of access to a particular set of resources or compartment.  A *Group* is very similar to a database role, with a small twist of direction.  While a database role is granted to database users, a cloud user is assigned to a cloud *Group*.

In the *Cloud Shell*, run the following commands to create a *Group* and assign the cloud user to it:

1. Create a Group

    ```bash
    <copy>
    LL_GROUP=$(oci iam group create --description "[](var:description)" --name [](var:oci_group) --query data.id --raw-output)
    echo "Group OCID: $LL_GROUP"
    </copy>
    ```

2. Assign a variable with the OCID of the user performing the rest of the Live Lab workshop.
    Replace `<username>` with the OCI username:

   ```bash
   LL_USER=$(oci iam user list --name <username> | jq -r '.data[].id')
   ```

    For example:

    ```bash
    LL_USER=$(oci iam user list --name first.last@url.com | jq -r '.data[].id')`
    ```

    You can get a list of usernames by running:

    ```bash
    <copy>
    oci iam user list --all --query 'data[].name'`
    </copy>
    ```

3. Assign the User to the Group

    ```bash
    <copy>
    LL_GROUP=$(oci iam group list --name [](var:oci_group) --query data.id --raw-output)
    oci iam group add-user --group-id $LL_GROUP --user-id $LL_USER
    </copy>
    ```

## Task 4: Apply Compartment Policies to the Group

A *Policy* specifies who can access which OCI resources, and how.  A *Policy* simply allows a *Group* to work in certain ways with specific types of resources in a particular compartment.  In database terms, this is the process of granting privileges (*Policy*) to a role (*Group*) against a specific schema (*Compartment*).

In the *Cloud Shell*, run the following commands to create a *Policy* statement and assign *Policies* to the *Group* against the *Compartment*:

1. Create the *Policy* statement file:

    ```bash
    <copy>
    cat > [](var:oci_group)_policies.json < EOF
    allow group [](var:oci_group) to use cloud-shell in tenancy
    EOF
    </copy>
    ```

2. Create the *Policy*:

    ```bash
    <copy>
    LL_COMPARTMENT=$(oci iam compartment list --name [](var:oci_compartment) | jq -r '.data[].id')
    oci iam policy create --compartment-id $LL_COMPARTMENT --description "[](var:description)" --name [](var:oci_group)_POLICY --statements file://[](var:oci_group)_policies.json
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
