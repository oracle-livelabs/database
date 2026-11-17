# Prepare the RHEL Migration Environment: Instructor Workshop

## Introduction

Prepare the reusable RHEL 9.8 Apache image before students begin the migration workshop. This instructor workshop contains two image-preparation labs. Students use their own OCI tenancy. They begin with Introduction and the shared Get Started page, then continue to Student Lab 1. In Student Lab 1, they create their own VCN and launch the prepared image.

Obtain an authorized RHEL KVM guest image, import it into OCI, register and update the preparation VM, install Apache, remove registration, then capture and export the image. Supply the object-read PAR URL privately to authorized participants. This workshop does not provide a RHEL image or grant redistribution rights.

Estimated Time: 1 hour 45 minutes (105 minutes), including 10 minutes of orientation; additional provisioning and pilot-testing time is required

### Objectives

- Obtain and import an authorized RHEL 9.8 x86\_64 KVM guest image.
- Launch and update a preparation VM and install the workshop Apache application.
- Remove Red Hat registration and disable subscription-management plugins before image capture.
- Capture `rhel-9-8-apache-source`, export it in OCI format, and create an object-read PAR.
- Verify the student starting point and provide the image and OCI access instructions before class.

### Prerequisites

- An authorized Red Hat account with RHEL 9.8 x86\_64 KVM guest image access and Simple Content Access for package installation.
- Permission under your organization's process to use the prepared image for the intended participants.
- A preparation OCI environment with permissions for compartments, networking, private Object Storage, custom images, Compute, and object-read PARs.
- Quota and capacity for `VM.Standard.E5.Flex` with 1 OCPU and 12 GB memory, or a tested compatible x86\_64 alternative, and a boot volume of at least 50 GB or the image minimum.
- A local computer with at least 15 GB of temporary free space, an SSH client, a browser, and a reliable image-upload connection.
- Students with their own OCI tenancy, a selected region, a dedicated workshop compartment, and the required permissions and quotas. Ask each tenancy administrator to complete [Administrator setup](../administrator-setup/administrator-setup.md). Students create their own destination networks in Student Lab 1.

## Preparation Flow

```text
Authorized RHEL 9.8 KVM guest image
        |
        | Instructor Lab 1: download, upload, import QCOW2
        v
Custom image: rhel-9-8-migration-import
        |
        | Instructor Lab 2: launch rhel-9-8-source
        | register, update, install Apache, remove registration
        v
Prepared custom image: rhel-9-8-apache-source
        |
        | export OCI object and create object-read PAR
        v
Private instructor handoff to the student tenancy workshop
```

## Workshop Conventions

- Lab 1 and Lab 2 in this workshop refer to instructor labs. References prefixed with Student refer to the separate student workshop.
- The preparation VM is `rhel-9-8-source`. Students use `ol-migrate-rhel-source` in their destination environments.
- Keep the raw image, prepared image, export object, and PAR under instructor control.
- Protect Red Hat credentials, private keys, and PAR URLs. Hide them in screenshots and shared output.
- Remove Red Hat registration before capture. Students verify the cleanup and never register the destination VM.
- The preparation network does not supply student networking. Each student follows the complete network setup in Student Lab 1.
- Resource deletion is not required for instructor completion. Retain preparation and reusable assets until you decide they are no longer needed.

## Workshop Schedule

| Session | Minutes |
| --- | ---: |
| Orientation | 10 |
| Lab 1: Acquire and Import the RHEL Source Image | 45 |
| Lab 2: Prepare and Export the RHEL Application Image | 50 |
| **Total** | **105** |

Image transfers, updates, export, and test launches can require additional time. Complete preparation before the class begins.

## Student Handoff

Give each authorized student the following before the student workshop:

- The [student workshop entry page](../workshops/tenancy/index.html). Start with Introduction and the shared Get Started page, then continue to Student Lab 1.
- A readiness checklist for each student's own tenancy: region, dedicated compartment, networking, image import, Compute, OSMH permissions, and quotas. Confirm the E5 shape with 1 OCPU and 12 GB memory and a boot volume of at least 50 GB or the image minimum.
- The complete object-read PAR URL for the validated artifact `rhel-9-8-apache-source-image-20261025-0915`, with an expiration that covers the planned imports. Send it privately for Student Lab 1, Task 5. Students import it as the custom image `rhel-9-8-apache-source`.
- Confirmation that the export contains RHEL 9.8 x86\_64, an enabled and active Apache application serving `MIGRATION_WORKLOAD_OK`, no Red Hat registration certificates, and both subscription plugins disabled.
- The tested shape and sizing, plus a contact if the PAR expires or an import or capacity check fails.

Instructor Lab 2 produces a new candidate export named `rhel-9-8-apache-source.oci`. That filename does not identify the existing tested artifact. Keep the validated artifact above for current delivery. Before using a replacement, pilot Student Labs 1 through 8, with Lab 2 optional. Record the candidate object name, checksum, test results, and approval. Then update the expected artifact in Student Lab 1 and the instructor handoff together. Do not relabel a new build as the October 25 tested artifact.

Before teaching, complete the student entry pages and Student Lab 1 with a permitted test account in a learner-owned tenancy to verify that students can create a network, import the export, launch the image, and pass the application and registration checks. A successful export alone does not verify this student path.

Pilot Student Labs 4 and 5 on a disposable VM from the prepared image before class. Verify that the migrated Oracle RHCK has actual Ksplice updates available and that they can be applied. Students complete Ksplice on RHCK in Lab 5 before installing UEK in Lab 6. Patch availability changes, so the earlier test's patch count is not a guarantee for a later class.

## Required OSMH and Automation Engine Preparation

Student Lab 7 is required and uses the same migrated VM. Student Lab 8 is also required and depends on Labs 6 and 7. Only Student Lab 2 is optional. An independent OSMH exercise does not replace Student Lab 7.

Ask the learner's tenancy administrator to complete [Administrator setup](../administrator-setup/administrator-setup.md) before the workshop. Confirm OSMH user and instance permissions, vendor-source access, and permission to configure Oracle Cloud Agent plugins.

Pilot Labs 6 through 8 on the exact candidate image after migration. Verify UEK 8, Oracle Cloud Agent 1.40 or later, Active OSMH registration, and visible package inventory. The Oracle Linux 9 x86\_64 profile must attach these four sources:

- `ol9_baseos_latest-x86_64`
- `ol9_appstream-x86_64`
- `ol9_uekr8-x86_64`
- `ol9_oci_included-x86_64`

Verify a suitable package update when available and confirm that Apache still serves `MIGRATION_WORKLOAD_OK`. If no suitable update is available, record that outcome without claiming an update was applied. Keep AppStream attached for the required Automation Engine installation in Lab 8.

Complete Lab 8's automated Oracle Linux 9.8, UEK, Apache, and application checks twice. Save the playbook recap and reports before following the learner cleanup steps. Those steps remove learner resources; retain instructor image assets only while needed and account for their storage costs.

## Learn More

- [Monitor and Update Oracle Linux with Oracle OS Management Hub](https://docs.oracle.com/en/learn/osmh-monitor/index.html): additional OSMH learning with its own prerequisites.

- [Student workshop](../workshops/tenancy/index.html)
- [Importing custom Linux images](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/importingcustomimagelinux.htm)
- [Exporting a custom image](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/custom-images-export.htm)
- [Object Storage pre-authenticated requests](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/usingpreauthenticatedrequests.htm)

## Acknowledgements

- **Author** - Perside Foster, Principal Solution Engineer, Oracle
- Last Updated By/Date - Perside Foster, Nov 2026
