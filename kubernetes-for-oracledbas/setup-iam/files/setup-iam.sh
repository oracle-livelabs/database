#!/usr/bin/env bash

declare -r NAME="K8S4DBAS"
declare -r DESCRIPTION="${NAME} LiveLabs"

# If assigning to a different user than running this script; pass in username
if [[ -z $1 ]]; then
    USER=${OCI_CS_USER_OCID#*/}
else
    USER=$1
fi

process_error () {
    local ERROR=$1

    FAILURE=$(echo ${ERROR#*:} | jq -r '.code')
    if [[ $FAILURE == *AlreadyExists ]]; then
        return 0
    else
        echo "Unable to continue:"
        echo $ERROR
        exit 1
    fi
}

echo "Creating Compartment: $NAME ($DESCRIPTION)"
CREATE_COMPARTMENT=$(oci iam compartment create \
    --name $NAME \
    --description "$DESCRIPTION" \
    --compartment-id $OCI_TENANCY 2>&1)
if (( $? > 0 )); then
    process_error "$CREATE_COMPARTMENT"
fi

echo "Creating Group: ${NAME}_GROUP ($DESCRIPTION)"
CREATE_GROUP=$(oci iam group create --name ${NAME}_GROUP --description "$DESCRIPTION" 2>&1)
if (( $? > 0 )); then
    process_error "$CREATE_GROUP"
fi
GROUP_OCID=$(oci iam group list --name ${NAME}_GROUP | jq -r .data[].id)

USER_OCID=$(oci iam user list --name $USER | jq -r '.data[].id')
if [[ -z $USER_OCID ]]; then
    # Try with IAM
    USER="oracleidentitycloudservice/$USER"
    USER_OCID=$(oci iam user list --name $USER | jq -r '.data[].id')
    if [[ -z $USER_OCID ]]; then
        echo "Unable to find OCID for $USER"
        exit 1
    fi
fi

echo "Assigning $USER to ${NAME}_GROUP"
ASSIGN_GROUP=$(oci iam group add-user --group-id $GROUP_OCID --user-id $USER_OCID 2>&1)

POLICY_FILE=$(mktemp -p ~/)
echo "Writing Policy file: ${POLICY_FILE}.json"
cat > ${POLICY_FILE}.json << EOF
[
    "Allow group ${NAME}_GROUP to use cloud-shell in tenancy",
    "Allow group ${NAME}_GROUP to use tag-namespaces in tenancy",
    "Allow group ${NAME}_GROUP to read objectstorage-namespaces in tenancy",
    "Allow group ${NAME}_GROUP to inspect buckets in tenancy",
    "Allow group ${NAME}_GROUP to inspect dynamic-groups in tenancy",
    "Allow group ${NAME}_GROUP to inspect tenancies in tenancy",
    "Allow group ${NAME}_GROUP to inspect compartments in tenancy where target.compartment.name = '${NAME}'",
    "Allow group ${NAME}_GROUP to manage dynamic-groups in tenancy where request.permission = 'DYNAMIC_GROUP_CREATE'",
    "Allow group ${NAME}_GROUP to manage dynamic-groups in tenancy where target.group.name = /*-worker-nodes-dyngrp/",
    "Allow group ${NAME}_GROUP to read load-balancers in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage autonomous-database-family in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage cluster-family in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage instance-family in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage orm-stacks in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage orm-jobs in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage policies in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage tag-namespaces in compartment ${NAME}",
    "Allow group ${NAME}_GROUP to manage virtual-network-family in compartment ${NAME}",
]
EOF

echo "Creating Policy ${NAME}_GROUP_POLICY"
CREATE_POLICY=$(oci iam policy create \
    --compartment-id $OCI_TENANCY \
    --description "${NAME} LiveLabs" \
    --name ${NAME}_GROUP_POLICY \
    --statements file://${TEMPFILE}.json 2>&1)
if (( $? > 0 )); then
    process_error "$CREATE_GROUP"
fi

rm ${POLICY_FILE}.json