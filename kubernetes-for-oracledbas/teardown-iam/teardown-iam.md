# Clean up OCI Tenancy

## Introduction

In this lab, you will clean up the Oracle Cloud Infrastructure (OCI) *Policies*, *Group*, and *Compartment* that were created during this workshop.

<if type="tenancy">**If you are not in the OCI Administrators group,** please have an OCI Administrator perform each of these tasks for you.</fi>

*Estimated Lab Time:* 2 minutes

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
POLICY_OCID=$(oci iam policy list \
    --compartment-id $OCI_TENANCY \
    --name [](var:oci_group)_POLICY | jq -r '.data[].id')

echo "Policy OCID: $POLICY_OCID"

if [[ ! -z $POLICY_OCID ]]; then
    oci iam policy delete \
        --policy-id $POLICY_OCID \
        --force
    if (( $? == 0)); then
        echo "Policy Deleted"
    fi
fi
</copy>
```

Press "return" to ensure commands have run.

## Task 3: Delete the Group

In the *Cloud Shell*, run the following commands to delete the *Group*:

1. Remove Users from Group

    ```bash
    <copy>
    GROUP_OCID=$(oci iam group list \
        --name [](var:oci_group) | jq -r '.data[].id')

    echo "Group OCID: $GROUP_OCID"

    if [[ ! -z $GROUP_OCID ]]; then
        for user_id in $(oci iam group list-users --group-id $GROUP_OCID | jq -r '.data[].id'); do
            echo "Removing $user_id from $GROUP_OCID"
            oci iam group remove-user \
                --group-id $GROUP_OCID \
                --user-id $user_id \
                --force
        done
    fi
    </copy>
    ```

    Press "return" to ensure commands have run.

2. Delete the Group

    ```bash
    <copy>
    GROUP_OCID=$(oci iam group list \
        --name [](var:oci_group) | jq -r '.data[].id')

    echo "Group OCID: $GROUP_OCID"

    if [[ ! -z $GROUP_OCID ]]; then
        oci iam group delete \
            --group-id $GROUP_OCID \
            --force
        if (( $? == 0)); then
            echo "Group Deleted"
        fi
    fi
    </copy>
    ```

    Press "return" to ensure commands have run.

## Task 4: Delete the Compartment

In the *Cloud Shell*, run the following commands to delete the sub-*Compartment* from the root *Compartment*:

```bash
<copy>
COMPARTMENT_OCID=$(oci iam compartment list \
    --name [](var:oci_compartment) | jq -r '.data[].id')

echo "Compartment OCID: $COMPARTMENT_OCID"

if [[ ! -z $COMPARTMENT_OCID ]]; then
    oci iam compartment delete \
        --compartment-id $COMPARTMENT_OCID \
        --force
    if (( $? == 0)); then
        echo "Compartment Scheduled for Deletion"
    fi
fi
</copy>
```

You may now **proceed to the next lab**

## Learn More

* [OCI - Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm "OCI - Cloud Shell")
* [OCI - Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm "OCI - Managing Compartments")
* [OCI - Managing Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm "OCI - Managing Groups")
* [OCI - Getting Started with Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm "OCI - Getting Started with Policies")

## Acknowledgements

* **Authors** - [](var:authors)
* **Contributors** - [](var:contributors)
* **Last Updated By/Date** - John Lathouwers, July 2023
