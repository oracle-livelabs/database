#!/usr/bin/env bash

declare -r NAME="K8S4DBAS"
declare -r DESCRIPTION="${NAME} LiveLabs"

POLICY_OCID=$(oci iam policy list \
    --compartment-id $OCI_TENANCY \
    --name ${NAME}_GROUP_POLICY | jq -r '.data[].id')

if [[ ! -z $POLICY_OCID ]]; then
    echo "Policy OCID: $POLICY_OCID"
    oci iam policy delete \
        --policy-id $POLICY_OCID \
        --force
fi

GROUP_OCID=$(oci iam group list --name ${NAME}_GROUP | jq -r '.data[].id')

if [[ ! -z $GROUP_OCID ]]; then
    echo "Group OCID: $GROUP_OCID"
    for user_id in $(oci iam group list-users --group-id $GROUP_OCID | jq -r '.data[].id'); do
        echo "Removing $user_id from $GROUP_OCID"
        oci iam group remove-user --group-id $GROUP_OCID --user-id $user_id --force
    done
    oci iam group delete --group-id $GROUP_OCID --force
fi

COMPARTMENT_OCID=$(oci iam compartment list \
    --name K8S4DBAS | jq -r '.data[].id')

if [[ ! -z $COMPARTMENT_OCID ]]; then
    echo "Compartment OCID: $COMPARTMENT_OCID"
    oci iam compartment delete \
        --compartment-id $COMPARTMENT_OCID \
        --force
fi