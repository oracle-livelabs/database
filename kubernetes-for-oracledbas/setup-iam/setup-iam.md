# Prepare the OCI Tenancy

"How often is happiness destroyed by preparation, foolish preparation!"
\- Jane Austen, Emma

## Introduction

In this lab, you will create the Oracle Cloud Infrastructure (OCI) *Policies* required for least-privilege provisioning of the workshop infrastructure.  Additionally you will create an OCI *Compartment* to isolate the resources created during this workshop.

<if type="tenancy">**If you are not in the OCI Administrators group,** please have an OCI Administrator perform each of these tasks for you.</fi>

*Estimated Lab Time:* 2 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Create an OCI Compartment
* Ensure you have the correct OCI Policies

### Prerequisites

This lab assumes you have:

* An Oracle Cloud Paid or Free-Tier Account
* You are logged into OCI as illustrated in **Get Started**

## Task 1: Open the Cloud Shell

*Cloud Shell* is a web browser-based terminal accessible from the Oracle Cloud Console. *Cloud Shell* is free to use (within monthly tenancy limits), and provides access to a Linux shell, with a pre-authenticated OCI CLI, a pre-authenticated Ansible installation, Terraform and other useful tools.

<if type="tenancy">As a user in the **Administrator** group, open the *Cloud Shell*</fi>
<if type="free-tier">Open the *Cloud Shell*</fi>

![Open Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png "Open Cloud Shell")

## Task 2: Create a Compartment

A *Compartment* is a collection of cloud assets, including Databases, Oracle Kubernetes Clusters, Compute Instances, Load Balancers and so on.

You can think of a *Compartment* much like a database schema: a collection of tables, indexes, and other objects isolated from other schemas.  By default, a root *Compartment* (think SYSTEM schema) was created for you when your tenancy was established.  It is possible to create everything in the root *Compartment*, but Oracle recommends that you create sub-*Compartments* to help manage your resources more efficiently.

In the *Cloud Shell*, run the following commands to create a sub-*Compartment* to the root *Compartment* for holding all the resources created by the Workshop:

```bash
<copy>
oci iam compartment create \
    --name [](var:oci_compartment) \
    --description "[](var:description)" \
    --compartment-id $OCI_TENANCY
</copy>
```

## Task 3: Create a Group

A *Group* is a collection of cloud users who all need the same type of access to a particular set of resources or compartment.  A *Group* is very similar to a database role, with a small twist of direction.  While a database role is granted to database users, a cloud user is assigned to a cloud *Group*.

In the *Cloud Shell*, run the following commands to create a *Group*:

```bash
<copy>
oci iam group create \
    --name [](var:oci_group) \
    --description "[](var:description)"
</copy>
```

## Task 4: Assign User to Group

Assign the *User* who will be carrying out the remaining Labs to the *Group* created in Task 3.  This could be yourself!

1. Assign a variable with the OCID of the user performing the rest of the Live Lab workshop.

    Replace `<username>` with the OCI username:

    ```bash
    USER_OCID=$(oci iam user list --name <username> | jq -r '.data[].id')
    ```

    For example:

    ```bash
    USER_OCID=$(oci iam user list --name first.last@url.com | jq -r '.data[].id')
    ```

    You can get a list of usernames by running:

    ```bash
    <copy>
    oci iam user list --all --query 'data[].name'
    </copy>
    ```

2. Assign the User to the Group

    ```bash
    <copy>
    GROUP_OCID=$(oci iam group list --name [](var:oci_group) | jq -r .data[].id)
    echo "Group OCID: $GROUP_OCID"
    echo "User OCID:  $USER_OCID"
    oci iam group add-user --group-id $GROUP_OCID --user-id $USER_OCID
    </copy>
    ```

    Press "return" to ensure commands have run.

## Task 4: Apply Policies to the Group

A *Policy* specifies who can access which OCI resources, and how.  A *Policy* simply allows a *Group* to work in certain ways with specific types of resources in a particular compartment.  In database terms, this is the process of granting privileges (*Policy*) to a role (*Group*) against a specific schema (*Compartment*).

In the *Cloud Shell*, run the following commands to create a *Policy* statement and assign *Policies* to the *Group* against the *Compartment*:

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

## Learn More

* [OCI - Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
* [OCI - Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm)
* [OCI - Managing Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
* [OCI - Getting Started with Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023