# Advanced Topics and Troubleshooting

## Introduction

This lab covers advanced operational topics that field teams should understand before helping customers execute VMware to OLVM migrations with Oracle Cloud Migrations (OCM). Use this lab as a review section after the standard migration flow or as a checklist during customer planning.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

* Review when to use manual or scheduled discovery.
* Review replication schedules and incremental replications.
* Confirm Windows VirtIO driver readiness before migration.
* Triage common pre-migration and post-migration issues.

## Task 1: Review Discovery Schedules

Discovery refreshes the OCM inventory for source VMware assets and target OLVM assets. The migration team should decide whether discovery is manual or scheduled before creating migration projects.

1. Use manual discovery for the first workshop run or first customer test wave.

    Manual discovery gives the migration operator control over when OCM refreshes inventory and makes it easier to correlate discovery results with a known source and target state.

2. Use scheduled discovery only when the migration runbook requires repeated inventory refreshes.

    Scheduled discovery can help during longer migration waves where source VMs, target clusters, templates, storage domains, or VNIC profiles may change before cutover.

3. Rerun discovery after any meaningful source or target change.

    Examples include adding source VMs, changing vCenter permissions, changing OLVM cluster placement, adding templates, changing VNIC profiles, or resolving a network or credential issue.

4. Do not create the migration project until both VMware and OLVM discovery complete successfully.

5. Record the discovery decision in the migration worksheet.

    ```text
    <copy>VMware discovery mode: Manual/Scheduled
    OLVM discovery mode: Manual/Scheduled
    Last VMware discovery work request:
    Last OLVM discovery work request:
    Discovery blockers:</copy>
    ```

## Task 2: Review Replication Schedules and Incremental Replications

Replication copies source VM disk data into the OCI replication location used by OCM. The replication schedule and bucket selection should be confirmed before the first replication run.

1. Use manual replication for the first test migration.

    Manual replication is easier for workshop delivery and early customer testing because the migration operator can start replication after readiness checks are complete.

2. Use a replication schedule when the migration runbook requires repeated replication before a later cutover window.

3. Confirm the replication location before the first replication:

    * Replication availability domain
    * Replication compartment
    * Replication bucket
    * Migration project and migration plan

4. If the replication schedule or replication location is wrong, update it before running the first replication.

5. After the first successful full replication, run incremental replications to capture later source VM changes.

6. For production cutover, shut down the source VM, run a final incremental replication, and then run the migration plan again.

7. Record the replication decision in the migration worksheet.

    ```text
    <copy>Replication mode: Manual/Scheduled
    Replication bucket:
    First full replication work request:
    Latest incremental replication work request:
    Final cutover replication completed: Yes/No</copy>
    ```

## Task 3: Confirm Source Windows VM Driver Readiness

Windows VMs require VirtIO drivers before migration to OLVM. This check should happen before replication, not after the VM fails to boot in the target environment.

1. Identify every Windows source VM in the migration wave.

2. Confirm that the required VirtIO network and storage drivers are installed in each Windows source VM.

3. Confirm that the customer application owner or Windows administrator has validated the driver installation.

4. If VirtIO drivers are missing, install them before replication and cutover.

5. If the migration wave includes only Linux source VMs, record that Windows VirtIO preparation is not applicable.

    ```text
    <copy>Windows VMs in wave: Yes/No
    VirtIO network drivers installed: Yes/No/Not applicable
    VirtIO storage drivers installed: Yes/No/Not applicable
    Owner who confirmed readiness:</copy>
    ```

## Task 4: Troubleshoot Common Pre-Migration Issues

Use this table to identify common failure patterns before migration execution.

| Symptom | Likely area to check | Basic troubleshooting step |
| --- | --- | --- |
| Prerequisites stack fails with an invalid tag error | OCI tag propagation | Wait a few minutes, then apply the same Resource Manager stack again. |
| Prerequisites stack fails while creating the OCM Vault key | Vault endpoint propagation | Wait 5 to 10 minutes, then apply the same stack again. |
| Remote agent registration endpoint is unreachable | Workstation-to-agent access | Confirm the appliance IP, HTTPS URL, TCP 3000 access, browser certificate warning, and firewall rules. |
| Remote agent is unhealthy or has no heartbeat | Agent connectivity | Confirm the appliance is powered on, DNS and NTP work, OCI endpoints are reachable over TCP 443, and vCenter is reachable. |
| VDDK dependency fails validation | VDDK package | Confirm that the uploaded package is a supported Linux VDDK tarball and re-create the dependency if needed. |
| VMware discovery fails or source VMs are missing | vCenter access | Confirm the vCenter endpoint, Vault secret, service account permissions, remote agent health, DNS, TCP 443, and TCP/UDP 902 to ESXi hosts. |
| OLVM discovery fails or target values are missing | OLVM readiness | Confirm OLVM Manager reachability, credentials, certificate secret, cluster, VNIC profiles, templates, and storage domains. |
| Replication fails | Data path and permissions | Check the remote agent, VDDK dependency, vCenter permissions, ESXi connectivity, Object Storage bucket access, and replication work request details. |
| Migration stack fails | Target configuration | Review Resource Manager job logs, OCM work requests, OLVM target cluster, VNIC profile, template, and storage placement values. |

## Task 5: Troubleshoot Common Post-Migration Issues

Use this checklist after a VM is created in OLVM but before marking the migration complete.

1. If a migrated Windows VM fails to boot, confirm that VirtIO storage and network drivers were installed before migration.

2. If the VM boots but has no network access, confirm the OLVM VNIC profile, guest network configuration, DHCP or static IP settings, and any old MAC-address-specific configuration.

3. If disks are missing or filesystems do not mount, confirm that all expected disks are attached and that guest mount configuration is valid.

4. If applications do not start, review application dependencies, service status, firewall rules, DNS, and database or middleware connectivity.

5. If validation results differ from the source VM, record the difference, owner, and required fix before marking the migration complete.

6. Capture work request IDs, screenshots, and runbook notes for any issue that must be escalated.

    ```text
    <copy>VM boots successfully: Yes/No
    Network validated: Yes/No
    Disks and filesystems validated: Yes/No
    Applications validated: Yes/No
    Issues requiring escalation:
    Work request IDs:</copy>
    ```

You may now **proceed to the next lab**

## Learn More

* [Oracle Cloud Migrations documentation](https://docs.oracle.com/en-us/iaas/Content/cloud-migration/home.htm)
* [Oracle Linux Virtualization Manager documentation](https://docs.oracle.com/en/virtualization/oracle-linux-virtualization-manager/)
* [Oracle Cloud Migrations remote agent appliance network requirements](https://docs.oracle.com/en-us/iaas/Content/cloud-migration/cloud-migration-remote-agent-appliance.htm)

## Acknowledgements

* **Author** - Mark Atkinson, Evgeny Golenkov, Andrey Sokolov, Perside Foster
* **Contributor** - Keya Balutkar
* **Last Updated By/Date** - Perside Foster, July 2026
