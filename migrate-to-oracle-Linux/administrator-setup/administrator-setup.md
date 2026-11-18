# Administrator Setup for the Workshop

## Introduction

A tenancy administrator completes this guide before learners start Lab 1. It prepares permissions for one dedicated workshop compartment. It is linked from Lab 1 and does not add a numbered lab.

Estimated Time: 30-60 minutes, plus IAM propagation and capacity requests.

### Objectives

- Grant learner access to workshop resources.
- Prepare OCI instance permissions for OSMH.
- Validate readiness and identify resources to retain during cleanup.

## Task 1: Prepare the compartment and learner group

1. Create or approve a dedicated workshop compartment. Identify the learner's identity domain and group. Record the compartment name and OCID and the tenancy OCID. Keep existing shared IAM resources in place.

1. Prepare policy statements in a policy attached to the root or another ancestor that can grant access to the target compartment. Replace `IDENTITY_DOMAIN`, `WORKSHOP_LEARNERS`, and `WORKSHOP_COMPARTMENT` before saving. For a group in the default domain, you can use its group name alone. These statements provide practical workshop administration access within the dedicated compartment:

    ```text
    <copy>
    Allow group 'IDENTITY_DOMAIN'/'WORKSHOP_LEARNERS' to manage instance-family in compartment WORKSHOP_COMPARTMENT
    Allow group 'IDENTITY_DOMAIN'/'WORKSHOP_LEARNERS' to manage volume-family in compartment WORKSHOP_COMPARTMENT
    Allow group 'IDENTITY_DOMAIN'/'WORKSHOP_LEARNERS' to manage virtual-network-family in compartment WORKSHOP_COMPARTMENT
    </copy>
    ```

    `instance-family` includes custom-image operations. `volume-family` covers boot-volume backup and restore. Networking access covers the VCN wizard and ingress rules. Review [Core Services IAM details](https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/corepolicyreference.htm) if your organization requires narrower permissions.

1. Confirm that the learner can update the workshop VM's Oracle Cloud Agent plugin configuration and view work requests. The Compute permissions above support instance operations. Do not grant tenancy-wide resource management merely to complete the workshop.

1. If your organization restricts compartment discovery, grant the read access needed to select the workshop compartment. Creating a compartment, group, dynamic group, or policy remains an administrator task.

1. Importing the owner's URL does not require learners to manage the owner's bucket. If learners instead stage an export in their own Object Storage bucket, grant separate scoped bucket and object permissions and include those objects in cleanup. Staging is outside the required path.

## Task 2: Define the OSMH instance dynamic group

1. In the appropriate identity domain, create or reuse a dynamic group for workshop OCI instances. Set this matching rule, replacing the example OCID:

    ```text
    <copy>
    ALL {instance.compartment.id = 'WORKSHOP_COMPARTMENT_OCID'}
    </copy>
    ```

    This includes instances in the named compartment. Dynamic-group rules do not automatically include child compartments. Use only the dedicated workshop compartment for this exercise.

1. Record the dynamic-group name and domain. Allow IAM changes to propagate. Do not create non-OCI Management Agent install keys or a management station for this OCI-only workshop.

## Task 3: Grant OSMH access

1. Add these statements after replacing the identity domain, group names, compartment name, and tenancy OCID. The first statement lets workshop instances access their own OSMH managed-instance resource. The remaining statements let learners manage workshop OSMH resources and read root-compartment sources and profiles:

    ```text
    <copy>
    Allow dynamic-group 'IDENTITY_DOMAIN'/'WORKSHOP_INSTANCES' to {OSMH_MANAGED_INSTANCE_ACCESS} in compartment WORKSHOP_COMPARTMENT where request.principal.id = target.managed-instance.id
    Allow group 'IDENTITY_DOMAIN'/'WORKSHOP_LEARNERS' to manage osmh-family in compartment WORKSHOP_COMPARTMENT
    Allow group 'IDENTITY_DOMAIN'/'WORKSHOP_LEARNERS' to read osmh-profiles in tenancy where target.profile.compartment.id = 'TENANCY_OCID'
    Allow group 'IDENTITY_DOMAIN'/'WORKSHOP_LEARNERS' to read osmh-software-sources in tenancy where target.softwareSource.compartment.id = 'TENANCY_OCID'
    </copy>
    ```

    These follow Oracle's [manual compartment-level OSMH policies](https://docs.oracle.com/en-us/iaas/osmh/doc/policies-manually-create.htm). Review domain syntax for your tenancy. The root-source read statements do not grant learners permission to create or delete root sources.

1. In the workshop region, confirm access to these Oracle Linux 9 x86\_64 vendor sources:

    | Software source | Purpose |
    | --- | --- |
    | `ol9_baseos_latest-x86_64` | Base operating system |
    | `ol9_appstream-x86_64` | Application packages and Automation Engine |
    | `ol9_uekr8-x86_64` | UEK Release 8 |
    | `ol9_oci_included-x86_64` | OCI packages including Oracle Cloud Agent |

1. If adding or replicating sources requires root-level actions in your tenancy, have an authorized OSMH administrator perform those actions. Make the required sources usable from the workshop compartment. Record ownership so learners do not delete shared sources during cleanup.

1. To let OSMH disable its plugin when learners unregister the VM during cleanup, add this instance-principal statement. Keep it scoped to the workshop compartment:

    ```text
    <copy>
    Allow dynamic-group 'IDENTITY_DOMAIN'/'WORKSHOP_INSTANCES' to {INSTANCE_UPDATE} in compartment WORKSHOP_COMPARTMENT
    </copy>
    ```

    See [OSMH unregister policy requirements](https://docs.oracle.com/en-us/iaas/osmh/doc/unregister-instance.htm). Keep this policy until unregistering completes.

1. Let learners create the Oracle Linux 9, x86\_64, OCI software-source profile in Lab 7. Confirm that it can use the four sources above. Keep the profile and VM in the same workshop region. Do not substitute UEK R7 or the Oracle Software source for the specified sources.

## Task 4: Validate readiness

1. Have the learner confirm access to Compute, custom images, Networking, and OSMH in the target compartment and region. Resolve required authorization failures before Lab 1.

1. Check 1 E5 OCPU, 12 GB RAM, boot-storage allowance, custom-image allowance, networking limits, and optional backup capacity. Verify physical E5 capacity separately. OSMH requires an eligible OCI instance; do not use a Free Tier instance.

1. After migration, Lab 7 verifies Oracle Cloud Agent 1.40 or later, its OSMH plugin, the four sources, registration, and inventory. An imported RHEL image can lack the agent initially. Do not enable registration against a mismatched RHEL profile before migration.

1. If the Console cannot confirm policies, inspect its details and validate the actual required access. Do not tell learners to ignore a warning. Fix missing dynamic-group membership, domain references, scope, or source permissions before dependent actions.

1. Preserve the public subnet's internet-gateway route and working egress. The required path does not need a management station, private connectivity, or a new service-gateway route on the public route table.

1. Record which IAM and software-source objects are workshop-only. Only those objects are eligible for removal during Lab 8 cleanup after dependencies are gone.

## Learn More

- [OSMH prerequisites](https://docs.oracle.com/en-us/iaas/osmh/doc/getstarted.htm)
- [OSMH policies](https://docs.oracle.com/en-us/iaas/osmh/doc/policies-manually-create.htm)
- [Managing custom images and IAM requirements](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managingcustomimages.htm)
- [Registering an existing OCI instance](https://docs.oracle.com/en-us/iaas/osmh/doc/register-oci-instance.htm)

## Acknowledgements

- Perside Foster, Principal Solution Engineer, Oracle
- Rosario Spiezia, Principal Sales Consultant, Oracle
- Mitch Dsouza, Principal Presales Consultant, Oracle Cloud Infrastructure Software
- Nick Mader, Global Channel Enablement & Strategy Director, Open Source Solutions, Oracle
- Last Updated By/Date - Perside Foster, Nov 2026
