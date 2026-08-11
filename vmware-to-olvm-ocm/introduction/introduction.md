# VMware to OLVM Migration with Oracle Cloud Migrations

## Introduction

This workshop walks through a VMware to Oracle Linux Virtualization Manager (OLVM) migration by using Oracle Cloud Migrations (OCM). OCM supports VMware to Oracle Virtualization migrations, extending the service beyond migrations into OCI to include on-premises Oracle Virtualization targets. You will prepare the OCI tenancy and source VMs, configure OCM prerequisites, upload the VMware Virtual Disk Development Kit (VDDK), deploy and register the remote agent appliance, discover VMware and OLVM assets, create an OLVM migration project, replicate a selected VM, validate the migrated VM, and clean up temporary migration resources.

Before migration planning, prepare the selected source VMs for the OLVM target environment. For Windows VMs, download and install the required VirtIO network and storage drivers before migration. Missing VirtIO drivers can prevent a migrated Windows VM from booting in OLVM.

Estimated Workshop Time: 3 hours, plus replication and migration execution time

### Objectives

In this workshop, you will:

* Create a dedicated OCI compartment for migration activity.
* Prepare Windows and Linux source VMs with VirtIO driver readiness before replication.
* Deploy the OCM prerequisites Resource Manager stack.
* Upload and register the VDDK package as an agent dependency.
* Configure the VMware source environment and remote agent appliance.
* Discover VMware source VMs and OLVM target assets.
* Configure the OLVM target asset source.
* Create an OLVM migration project and migration plan.
* Replicate VM disk data directly to the OLVM target, migrate with limited application downtime, validate, cut over, and clean up a migrated VM.
* Review advanced scheduling, incremental replication, Windows driver readiness, and common troubleshooting steps.

### Prerequisites

The OLVM target environment must be fully configured and ready **before migration planning begins**. Confirm the following with the OLVM administrator:

* An OLVM cluster is available for the migrated VMs.
* Required storage domains are available for the migrated VM disks.
* Required VNIC profiles are configured for the target VM networks.
* Required VM templates are available for the migration operator or customer administrator to select during migration planning.

This workshop assumes you have:

* An OCI administrator or workshop operator with permission to manage compartments, IAM, Vault, Object Storage, Resource Manager, and Cloud Migrations.
* A VMware administrator who can deploy the remote agent appliance in vCenter. OCM uses a dedicated vCenter service account for source discovery and replication.
* An OLVM administrator who can confirm target readiness and provide the OLVM Manager URL, service-account credentials, and TLS certificate used by OCM.
* The VDDK package downloaded from the VMware portal.
* Windows source VMs prepared with the required VirtIO network and storage drivers before migration.
* A workstation that can reach OCI over HTTPS and the remote agent appliance registration endpoint.
* Network connectivity and firewall rules that permit communication between the workstation, remote agent appliance, VMware environment, OCI, and OLVM, as listed in the following section.
* Working knowledge of VMware vCenter and OLVM administration for the respective VMware and OLVM administrators.



## Required Network Connectivity

Before you deploy and register the remote agent appliance, confirm that the systems in the migration path can communicate with each other. The remote agent appliance is the system that connects the VMware source environment, OCI Cloud Migrations, and the OLVM target environment.

For this workshop, think about the network in three parts:

* The **user workstation** opens the remote agent registration page during setup.
* The **remote agent appliance** connects to VMware so OCM can discover and replicate source VMs.
* The **remote agent appliance and OCM** connect to OLVM so OCM can discover target resources and migrate the VM.

Read each row in the table as: **the system in the "Connection starts here" column must be able to connect to the system in the "Connection goes here" column by using the listed port.** If a connection fails, give that row to the network, VMware, OCI, or OLVM administrator listed in the last column.

The remote agent appliance normally needs two types of network access. Its VMware-facing network path talks to vCenter and ESXi hosts. Its OCI and OLVM-facing network path talks to OCI services and the OLVM target environment. In smaller lab environments, both paths may use the same network interface, but the required communication paths are still the same.

| Migration phase | Connection starts here | Connection goes here | Port and protocol | Plain-English purpose | Usually confirmed by |
| --- | --- | --- | --- | --- | --- |
| Agent setup | User workstation | Remote agent appliance external interface | TCP 3000 | Allows the workshop user to open the agent registration or reset page. | Workshop user / VMware admin |
| Basic appliance services | Remote agent appliance | DNS server | TCP/UDP 53 | Lets the agent resolve names for OCI, vCenter, ESXi hosts, and OLVM Manager. | Network admin |
| Basic appliance services | Remote agent appliance | DHCP server, if DHCP is used | TCP/UDP 67 and 68 | Lets the agent receive an IP address automatically. Not required if the appliance uses a static IP address. | Network admin |
| Basic appliance services | Remote agent appliance | NTP server | TCP/UDP 123 | Keeps the appliance clock synchronized. Incorrect time can cause certificate and secure connection failures. | Network admin |
| OCI registration and control | Remote agent appliance external interface | OCI endpoints in the `oraclecloud.com` domain | TCP 443 | Lets the agent securely connect to Oracle Cloud Migrations and other OCI services. | OCI admin / Network admin |
| VMware discovery | Remote agent appliance internal interface | vCenter | TCP 443 | Lets the agent connect to the vCenter management API to discover VMware inventory. | VMware admin |
| VMware discovery and replication | Remote agent appliance internal interface | vCenter and ESXi hosts | TCP/UDP 902 | Allows VMware VDDK connectivity so the agent can access VM disk data for discovery and replication. | VMware admin / Network admin |
| OLVM target discovery and control | OCM service and remote agent appliance | OLVM Manager | TCP 443 | Lets OCM and the agent discover OLVM target resources and manage migration activity. | OLVM admin / OCI admin / Network admin |
| OLVM replication | Remote agent appliance external interface | OLVM Manager | TCP 54323 | Sends replicated migration data from the remote agent appliance to the OLVM target environment. | OLVM admin / Network admin |

### Beginner checklist

Before continuing, use this checklist to confirm that the basic network path is ready. You do not need to memorize the port numbers; use the table above when you ask the responsible administrator to verify a failed check.

| Check | Question to answer |
| --- | --- |
| Workstation access | Can the user workstation open the remote agent registration page on TCP 3000? |
| DNS | Can the remote agent resolve OCI, vCenter, ESXi host, and OLVM Manager names? |
| Time sync | Can the remote agent synchronize time with an NTP server? |
| OCI access | Can the remote agent reach OCI endpoints over TCP 443? |
| VMware access | Can the remote agent reach vCenter on TCP 443 and vCenter/ESXi hosts on TCP/UDP 902? |
| OLVM access | Can the remote agent and OCM reach OLVM Manager on TCP 443? |
| Replication path | Can the remote agent reach OLVM Manager on TCP 54323? |

If one of these checks fails, fix the network path before continuing. Connectivity issues at this stage usually cause later discovery, registration, or replication steps to fail.

## Workshop Architecture

The workshop uses Oracle Cloud Migrations in OCI to coordinate a migration from a VMware vSphere source environment to an OLVM target environment. OCI provides the Cloud Migrations service, Object Storage for migration dependencies such as VDDK, and the service endpoints required by the remote agent appliance. VM disk data is replicated directly from the source environment to the OLVM target while OCM coordinates the migration workflow from OCI.

The remote agent appliance runs in the VMware environment and needs network access to vCenter, ESXi hosts, DNS, NTP, OCI service endpoints, and OLVM. OCM discovers VMware source VM metadata and Oracle Virtualization target resources such as storage domains, clusters, VNIC profiles, and templates. The user workstation is used only for registration and console-driven setup tasks.

![VMware to OLVM migration architecture](images/vmware-to-olvm-architecture.png "Show VMware to OLVM migration architecture")

## Workshop Flow

* Lab 1 creates the migration compartment.
* Lab 2 prepares Windows and Linux source VMs for OLVM migration.
* Lab 3 deploys the OCM prerequisites stack.
* Lab 4 uploads and registers the VDDK.
* Lab 5 sets up the VMware source environment and remote agent.
* Lab 6 discovers VMware source VMs.
* Lab 7 sets up the OLVM target environment.
* Lab 8 creates the OLVM migration project.
* Lab 9 replicates, migrates, validates, and cuts over the VM.
* Lab 10 marks the project complete and cleans up temporary resources.
* Lab 11 reviews advanced scheduling and common troubleshooting scenarios for field teams.

## Learn More

* [Oracle Cloud Migrations documentation](https://docs.oracle.com/en-us/iaas/Content/cloud-migration/home.htm)
* [Oracle Linux Virtualization Manager documentation](https://docs.oracle.com/en/virtualization/oracle-linux-virtualization-manager/)
* [OCI Resource Manager documentation](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/home.htm)
* [Oracle Cloud Migrations remote agent appliance network requirements](https://docs.oracle.com/en-us/iaas/Content/cloud-migration/cloud-migration-remote-agent-appliance.htm)
* [Oracle Cloud Migrations adds support for Oracle Virtualization](https://blogs.oracle.com/virtualization/oracle-cloud-migrations-adds-support-for-oracle-virtualization)

## Acknowledgements

* **Author** - Mark Atkinson, Evgeny Golenkov, Andrey Sokolov, Perside Foster
* **Contributor** - Keya Balutkar
* **Last Updated By/Date** - Perside Foster, July 2026
