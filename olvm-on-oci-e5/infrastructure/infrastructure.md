# Verify E5 OCI Network Prerequisites

## Introduction

In this lab, you will verify that your OCI environment is ready for the OLVM workshop on `VM.Standard.E5.Flex`.

This is a beginner workshop. You are not expected to design or troubleshoot OCI networking in this lab. The instructor or workshop owner should prepare the OCI resources before the workshop starts. Your job is to confirm that the required resources exist, record the values you need later, and test SSH access.

If a required resource is missing, stop and ask the instructor or workshop owner before continuing.

Estimated Time: 20-30 minutes

### Objectives

In this lab, you will:

- Review the required E5 OCI layout
- Verify the VCN, subnets, VLAN, gateways, route tables, and security rules
- Verify the OLVM manager and KVM host instances
- Verify the secondary VNICs required by E5 networking
- Verify shared block volume attachments
- Test SSH access used by later labs
- Record IP addresses and host details

### Prerequisites

This lab assumes you have:

- Access to the OCI tenancy and compartment used for the workshop
- An instructor-provided or workshop-owner-provided E5 OCI environment
- A local private key named `olvm-cluster-id_rsa`
- A local Windows PowerShell terminal
- Your assigned region and compartment name

> **Important:** Do not continue to Lab 2 until every checkpoint item in this lab is complete.

## Task 0: Review What Should Already Exist

1. Review the network resources that should already exist.

    | Resource | Expected Value |
    |---|---|
    | VCN | `OLV-VCN`, `10.0.0.0/16` |
    | Public subnet | `10.0.0.0/24` |
    | Private subnet | `10.0.1.0/24` |
    | VLAN | `VLAN-VMs`, VLAN tag `1`, `10.0.10.0/24` |
    | Internet gateway | Used by the public subnet and VLAN |
    | Service gateway | Used by the private subnet |

2. Review the compute resources that should already exist.

    | Host | Shape | Primary Network | Extra Network Attachments |
    |---|---|---|---|
    | `olvm` | `VM.Standard.E5.Flex`, `2 OCPUs`, `32 GB` memory | Public subnet | Private subnet |
    | `olkvm01` | `VM.Standard.E5.Flex`, `8 OCPUs`, `64 GB` memory | Public subnet | Private subnet, VLAN |
    | `olkvm02` | `VM.Standard.E5.Flex`, `8 OCPUs`, `64 GB` memory | Public subnet | Private subnet, VLAN |

3. Review the storage resources that should already exist.

    | Volume | Size | Expected Attachment |
    |---|---|---|
    | `amd-storage-domain-01` | `1 TB` | Attached to `olkvm01` and `olkvm02` |
    | `amd-storage-domain-02` | `1 TB` | Attached to `olkvm01` and `olkvm02` |

## Task 1: Find Your Workshop VCN

1. Sign in to the OCI Console.

2. Confirm that you are in the region assigned by your instructor.

3. Confirm that you are viewing the compartment assigned by your instructor.

4. Open the navigation menu and go to **Networking -> Virtual Cloud Networks**.

5. Find and open `OLV-VCN`.

6. Confirm the VCN CIDR block is `10.0.0.0/16`.

7. If `OLV-VCN` is missing or has a different CIDR block, stop and ask the instructor for help.

## Task 2: Verify the Network Resources

1. In `OLV-VCN`, confirm the subnets.

    | Resource | Expected CIDR |
    |---|---|
    | `Public Subnet-OLV-VCN` | `10.0.0.0/24` |
    | `Private Subnet-OLV-VCN` | `10.0.1.0/24` |

2. In `OLV-VCN`, open **VLANs** and confirm `VLAN-VMs`.

    | Field | Expected Value |
    |---|---|
    | VLAN Tag | `1` |
    | CIDR Block | `10.0.10.0/24` |

3. Confirm the gateways.

    | Gateway | Expected Status |
    |---|---|
    | `Internet Gateway-OLV-VCN` | Available and enabled |
    | `Service Gateway-OLV-VCN` | Available |

4. Confirm the public subnet route table.

    - In `OLV-VCN`, click **Subnets**.
    - Click `Public Subnet-OLV-VCN`.
    - In the subnet details page, find the **Route Table** field.
    - Confirm the route table is `Default Route Table for OLV-VCN`.
    - Click the route table name.
    - Confirm it has this route rule:

        | Destination | Target |
        |---|---|
        | `0.0.0.0/0` | `Internet Gateway-OLV-VCN` |

5. Confirm the VLAN route table.

    - Return to `OLV-VCN`.
    - Click **VLANs**.
    - Click `VLAN-VMs`.
    - In the VLAN details page, find the **Route Table** field.
    - Confirm the route table is `Default Route Table for OLV-VCN`.
    - Click the route table name.
    - Confirm it has this route rule:

        | Destination | Target |
        |---|---|
        | `0.0.0.0/0` | `Internet Gateway-OLV-VCN` |

6. Confirm the private subnet route table.

    - Return to `OLV-VCN`.
    - Click **Subnets**.
    - Click `Private Subnet-OLV-VCN`.
    - In the subnet details page, find the **Route Table** field.
    - Confirm the route table is `Route Table for Private Subnet-OLV-VCN`.
    - Click the route table name.
    - Confirm it has a route rule for Oracle Services Network through `Service Gateway-OLV-VCN`.

    | Resource | Expected Route |
    |---|---|
    | Public subnet | `0.0.0.0/0` through `Internet Gateway-OLV-VCN` |
    | `VLAN-VMs` | `0.0.0.0/0` through `Internet Gateway-OLV-VCN` |
    | Private subnet | Oracle Services Network through `Service Gateway-OLV-VCN` |

7. Confirm the security rules.

    | Direction | Source or Destination | Protocol |
    |---|---|---|
    | Egress | `0.0.0.0/0` | All protocols |
    | Ingress | `10.0.0.0/16` | All protocols |
    | Ingress | Your client public IP with `/32` | All protocols |

8. Confirm that `VLAN-VMs` is associated with a network security group named `L2 Network`.

9. If any network item is missing or does not match the table, stop and ask the instructor for help.

## Task 3: Verify the E5 Instances and VNICs

1. Open the navigation menu and go to **Compute -> Instances**.

2. Confirm the three workshop instances are running.

    | Instance | Shape | Expected State |
    |---|---|---|
    | `olvm` | `VM.Standard.E5.Flex` | Running |
    | `olkvm01` | `VM.Standard.E5.Flex` | Running |
    | `olkvm02` | `VM.Standard.E5.Flex` | Running |

3. Open `olvm` and confirm its VNICs.

    | VNIC | Network | Public IP |
    |---|---|---|
    | Primary VNIC | `Public Subnet-OLV-VCN` | Yes |
    | `vdsm` | `Private Subnet-OLV-VCN` | No |

4. Open `olkvm01` and confirm its VNICs.

    | VNIC | Network | Public IP |
    |---|---|---|
    | Primary VNIC | `Public Subnet-OLV-VCN` | Yes |
    | `vdsm01` | `Private Subnet-OLV-VCN` | No |
    | `l2-vm-network` | `VLAN-VMs` | No |

5. Open `olkvm02` and confirm its VNICs.

    | VNIC | Network | Public IP |
    |---|---|---|
    | Primary VNIC | `Public Subnet-OLV-VCN` | Yes |
    | `vdsm02` | `Private Subnet-OLV-VCN` | No |
    | `l2-vm-network` | `VLAN-VMs` | No |

6. Record the public IP address for each instance.

7. Record the private IP address for each private-subnet VNIC.

## Task 4: Verify Linux Sees the Private VNICs

The private-subnet VNICs must be visible inside Oracle Linux before OLVM can use them.

1. From Windows PowerShell, connect to `olvm`:

    ```powershell
    <copy>ssh -i C:\Users\<you>\.ssh\olvm-cluster-id_rsa opc@<olvm-public-ip></copy>
    ```

2. Check the network interfaces:

    ```bash
    <copy>ip -br addr</copy>
    ```

3. Confirm that `olvm` has an IP address in `10.0.1.0/24`.

    The IP address may appear on a physical interface such as `enp1s0`, or on an OLVM-managed bridge such as `ovirtmgmt`. Either is acceptable as long as one interface shows an address in `10.0.1.0/24`.

4. Repeat this check on `olkvm01`.

5. Repeat this check on `olkvm02`.

6. If a host does not show an address in `10.0.1.0/24`, run this command on that host:

    ```bash
    <copy>sudo oci-network-config configure
    ip -br addr</copy>
    ```

7. If the host still does not show an address in `10.0.1.0/24`, stop and ask the instructor for help.

8. Do not manually configure the VLAN VNIC.

    OLVM uses the VLAN VNIC later when you create the virtual machine logical network.

## Task 5: Verify Shared Block Volumes

1. In the OCI Console, open **Storage -> Block Storage -> Block Volumes**.

2. Open `amd-storage-domain-01`.

3. Confirm it is attached to both KVM hosts.

    | Host | Expected Access |
    |---|---|
    | `olkvm01` | Read/write and shareable |
    | `olkvm02` | Read/write and shareable |

4. Open `amd-storage-domain-02`.

5. Confirm it is attached to both KVM hosts.

    | Host | Expected Access |
    |---|---|
    | `olkvm01` | Read/write and shareable |
    | `olkvm02` | Read/write and shareable |

6. Do not format or mount these volumes from Linux.

    OLVM configures them later as shared storage. Formatting or mounting them manually can damage the lab environment.

7. If a volume is missing or not attached to both KVM hosts, stop and ask the instructor for help.

## Task 6: Verify Workshop SSH Access

Later labs use the `oracle` user and short hostnames such as `olkvm01`.

1. From Windows PowerShell, verify that you can connect to `olvm` as `oracle`:

    ```powershell
    <copy>ssh -i C:\Users\<you>\.ssh\olvm-cluster-id_rsa oracle@<olvm-public-ip> "hostname -f"</copy>
    ```

2. Connect to `olvm` as `oracle`:

    ```powershell
    <copy>ssh -i C:\Users\<you>\.ssh\olvm-cluster-id_rsa oracle@<olvm-public-ip></copy>
    ```

3. From the `olvm` terminal, verify passwordless SSH to `olkvm01`:

    ```bash
    <copy>ssh olkvm01 hostname -f</copy>
    ```

4. From the `olvm` terminal, verify passwordless SSH to `olkvm02`:

    ```bash
    <copy>ssh olkvm02 hostname -f</copy>
    ```

5. If any SSH test fails, stop and ask the instructor for help.

## Task 7: Record Your Lab Values

1. Fill in this table before continuing.

    | Value | Your Environment |
    |---|---|
    | Region |  |
    | Compartment |  |
    | `olvm` public IP |  |
    | `olvm` private subnet IP |  |
    | `olkvm01` public IP |  |
    | `olkvm01` private subnet IP |  |
    | `olkvm02` public IP |  |
    | `olkvm02` private subnet IP |  |
    | `amd-storage-domain-01` attached to both hosts | Yes / No |
    | `amd-storage-domain-02` attached to both hosts | Yes / No |

2. Keep these values available for later labs.

## Setup OLVM Infrastructure Checkpoint

At this point, you should have verified:

- VLAN support is available in the region
- `OLV-VCN` exists with the expected CIDR block
- Public subnet, private subnet, and VLAN exist
- Internet gateway, service gateway, route tables, and security rules match the expected layout
- Three E5 instances are running: `olvm`, `olkvm01`, and `olkvm02`
- Required secondary VNICs are attached
- Private secondary VNICs are visible inside Oracle Linux
- Two shared `1 TB` block volumes are attached to both KVM hosts
- SSH from your workstation to `olvm` as `oracle` works
- SSH from `olvm` to both KVM hosts works
- IP addresses are recorded for later labs

You are ready for Lab 2 only after all checkpoint items above are complete.

You may now **proceed to the next lab**

## Learn More

- Oracle Linux Virtualization Manager install lab (official): https://docs.oracle.com/en/learn/olvm-install/index.html
- OCI secondary VNICs: https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingVNICs.htm
- OCI route tables: https://docs.oracle.com/iaas/Content/Network/Tasks/managingroutetables.htm
- Attaching a block volume to multiple instances: https://docs.public.content.oci.oraclecloud.com/iaas/Content/Block/Tasks/attachingvolumetomultipleinstances.htm

## Acknowledgements

- **Author** - Shawn Kelley, Perside Foster
- **Contributor** - Marvin Kim
- **Last Updated By/Date** - Perside Foster, June 9, 2026
