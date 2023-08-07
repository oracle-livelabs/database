# Prepare the OCI Tenancy

## Introduction

In this lab, you will create the Oracle Cloud Infrastructure (OCI) *Policies* required for least-privilege provisioning of the workshop infrastructure.  Additionally you will create an OCI *Compartment* to isolate the resources created during this workshop.

<if type="tenancy">**If you are not in the OCI Administrators group,** please have an OCI Administrator perform each of these tasks for you.</fi>

*Estimated Time:* 2 minutes

### Objectives

* Create an OCI Compartment
* Ensure you have the correct OCI Policies

### Prerequisites

This lab assumes you have:

* An Oracle Cloud Paid or Free-Tier Account
* You are logged into OCI as illustrated in [Get Started](https://oracle-livelabs.github.io/common/labs/cloud-login/cloud-login.md "Get Started")

## Task 1: Open the Cloud Shell

*Cloud Shell* is a web browser-based terminal accessible from the Oracle Cloud Console. *Cloud Shell* is free to use (within monthly tenancy limits), and provides access to a Linux shell, with a pre-authenticated OCI CLI, Ansible installation, Terraform and other useful tools.

1. Open the *Cloud Shell*

    ![Open Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png "Open Cloud Shell")

## Task 2: Create a Compartment

A *Compartment* is a collection of cloud assets, including Databases, the Oracle Kubernetes Engine (OKE), Compute Instances, Load Balancers and so on.

In the *Cloud Shell*, run the following commands to create a sub-*Compartment* to the root *Compartment* for holding all the resources created by the Workshop:

1. Create Compartment

    ```bash
    <copy>
    oci iam compartment create \
        --name [](var:oci_compartment) \
        --description "[](var:description)" \
        --compartment-id $OCI_TENANCY
    </copy>
    ```

You can think of a *Compartment* much like a database schema: a collection of tables, indexes, and other objects isolated from other schemas.  By default, a root *Compartment* (think SYSTEM schema) was created for you when your tenancy was established.  It is possible to create everything in the root *Compartment*, but Oracle recommends that you create sub-*Compartments* to help manage your resources more efficiently.

## Task 3: Create a Group

A *Group* is a collection of cloud users who all need the same type of access to a particular set of resources or compartment.

1. In the *Cloud Shell*, run the following commands to create a *Group*:

    ```bash
    <copy>
    oci iam group create \
        --name [](var:oci_group) \
        --description "[](var:description)"
    </copy>
    ```

A *Group* is very similar to a database role.  Privileges, or in the case of OCI, *Policies* will be granted to the *Group* and cloud users can then be assigned to the cloud *Group* to inherit those *Policies*.

## Task 4: Assign User to Group

Assign the cloud *User* who will be carrying out the remaining Labs to the *Group* created in Task 3.  This could be yourself!

1. Find the users OCID (**Optional**):

    **Skip this Step if you are setting this up for yourself, if you are an Administrator setting this up for another user:**

    Replace `<username>` with the OCI username:

    ```text
    USER_OCID=$(oci iam user list --name <username> | jq -r '.data[].id')
    ```

    For example:

    ```text
    USER_OCID=$(oci iam user list --name first.last@url.com | jq -r '.data[].id')
    ```

    If you don't know the username, you can get a list by running:

    ```bash
    <copy>
    oci iam user list --all --query 'data[].name'
    </copy>
    ```

2. Get the *Group* OCID:

    ```bash
    <copy>
    GROUP_OCID=$(oci iam group list --name [](var:oci_group) | jq -r .data[].id)

    echo "Group OCID: $GROUP_OCID"
    </copy>
    ```

3. Assign the *User* to the *Group*:

    ```bash
    <copy>
    echo "User OCID:  ${USER_OCID:-$OCI_CS_USER_OCID}"

    oci iam group add-user --group-id $GROUP_OCID --user-id ${USER_OCID:-$OCI_CS_USER_OCID}
    </copy>
    ```

## Task 5: Apply Policies to the Group

A *Policy* specifies who can access which OCI resources, and how.  A *Policy* simply allows a *Group* to work in certain ways with specific types of resources in a particular compartment.  In database terms, this is the process of granting privileges (*Policy*) to a role (*Group*) against a specific schema (*Compartment*).

In the *Cloud Shell*, run the following commands to create a *Policy* statement file and assign *Policies* to the *Group* against the *Compartment*:

1. Create the *Policy* statement file:

    ```bash
    <copy>
    cat > [](var:oci_group)_policies.json << EOF
    [
        "Allow group [](var:oci_group) to use cloud-shell in tenancy",
        "Allow group [](var:oci_group) to use tag-namespaces in tenancy",
        "Allow group [](var:oci_group) to read objectstorage-namespaces in tenancy",
        "Allow group [](var:oci_group) to inspect buckets in tenancy",
        "Allow group [](var:oci_group) to inspect dynamic-groups in tenancy",
        "Allow group [](var:oci_group) to inspect tenancies in tenancy",
        "Allow group [](var:oci_group) to inspect compartments in tenancy where target.compartment.name = '[](var:oci_compartment)'",
        "Allow group [](var:oci_group) to manage dynamic-groups in tenancy where request.permission = 'DYNAMIC_GROUP_CREATE'",
        "Allow group [](var:oci_group) to manage dynamic-groups in tenancy where target.group.name = /*-worker-nodes-dyngrp/",
        "Allow group [](var:oci_group) to read load-balancers in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage autonomous-database-family in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage cluster-family in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage instance-family in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage orm-stacks in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage orm-jobs in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage policies in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage tag-namespaces in compartment [](var:oci_compartment)",
        "Allow group [](var:oci_group) to manage virtual-network-family in compartment [](var:oci_compartment)",
    ]
    EOF
    </copy>
    ```

    Press "return" to ensure commands have run.

2. Create the *Policy*:

    ```bash
    <copy>
    oci iam policy create \
        --compartment-id $OCI_TENANCY \
        --description "[](var:description)" \
        --name [](var:oci_group)_POLICY \
        --statements file://[](var:oci_group)_policies.json
    </copy>
    ```

    When you create a *Policy*, make changes to an existing *Policy*, or delete a *Policy*, your changes go into effect typically within 10 seconds.

You may now **proceed to the next lab**

## Learn More

* [OCI - Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
* [OCI - Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm)
* [OCI - Managing Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
* [OCI - Getting Started with Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm)

## Acknowledgements

* **Authors** - [](var:authors)
* **Contributors** - [](var:contributors)
* **Last Updated By/Date** - John Lathouwers, July 2023
