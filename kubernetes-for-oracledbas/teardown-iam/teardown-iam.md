# Clean up OCI Tenancy

"Be careless in your dress if you must, but keep a tidy ~~soul~~ [tenancy]."
\- Mark Twain

## Introduction

In this lab, we will clean up the Oracle Cloud Infrastructure (OCI) *Policies*, *Group*, and *Compartment* that were created during this workshop.

<if type="tenancy">**If you are not in the OCI Administrators group,** please have an OCI Administrator perform each of these tasks for you.</fi>

*Estimated Lab Time:* 2 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Leave no trace of the Workshop

## Task 1: Open the Cloud Shell

*Cloud Shell* is a web browser-based terminal accessible from the Oracle Cloud Console. *Cloud Shell* is free to use (within monthly tenancy limits), and provides access to a Linux shell, with a pre-authenticated OCI CLI, a pre-authenticated Ansible installation, Terraform and other useful tools.

<if type="tenancy">As a user in the **Administrator** group, log into the Oracle Cloud Console and open the *Cloud Shell*</fi>
<if type="free-tier">Log into the Oracle Cloud Console and open the *Cloud Shell*</fi>

![Open Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png "Open Cloud Shell")

## Task 2: Delete the Policies

In the *Cloud Shell*, run the following commands to delete the *Policy*:

```bash
<copy>
LL_POLICY=$(oci iam policy list --compartment-id $OCI_TENANCY --name [](var:oci_group)_POLICY | jq -r '.data[].id')
echo "$LL_POLICY"
if [[ ! -z $LL_POLICY ]]; then
    oci iam policy delete --policy-id $LL_POLICY --force
fi
</copy>
```

Press "return" to ensure commands have run.

## Task 3: Delete the Group

In the *Cloud Shell*, run the following commands to delete the *Group*:

1. Remove Users from Group

    ```bash
    <copy>
    LL_GROUP=$(oci iam group list --name [](var:oci_group) | jq -r '.data[].id')
    echo "Group OCID: $LL_GROUP"
    if [[ ! -z $LL_GROUP ]]; then
        for user_id in $(oci iam group list-users --group-id $LL_GROUP | jq -r '.data[].id'); do
            echo "Removing $user_id from $LL_GROUP"
            oci iam group remove-user --group-id $LL_GROUP --user-id $user_id --force
        done
    fi
    </copy>
    ```

    Press "return" to ensure commands have run.

2. Delete the Group

    ```bash
    <copy>
    LL_GROUP=$(oci iam group list --name [](var:oci_group) | jq -r '.data[].id')
    echo "Group OCID: $LL_GROUP"
    if [[ ! -z $LL_GROUP ]]; then
        oci iam group delete --group-id $LL_GROUP --force
    fi
    </copy>
    ```

    Press "return" to ensure commands have run.

## Task 4: Delete the Compartment

In the *Cloud Shell*, run the following commands to delete the sub-*Compartment* from the root *Compartment*:

```bash
<copy>
LL_COMPARTMENT=$(oci iam compartment list --name [](var:oci_compartment) | jq -r '.data[].id')
echo "Compartment OCID: $LL_COMPARTMENT"
if [[ ! -z $LL_COMPARTMENT ]]; then
    oci iam compartment delete --compartment-id $LL_COMPARTMENT --force
fi
</copy>
```

## Learn More

* [OCI - Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm "OCI - Cloud Shell")
* [OCI - Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm "OCI - Managing Compartments")
* [OCI - Managing Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm "OCI - Managing Groups")
* [OCI - Getting Started with Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm "OCI - Getting Started with Policies")

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
