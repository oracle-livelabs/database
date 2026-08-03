# Instructor Setup: Build E5 OCI Prerequisites

## Introduction

Use this instructor-only setup guide before delivering the beginner OLVM on OCI E5 workshop. Learner Lab 1 is verification-only. The instructor, workshop owner, or automation owner must build the OCI objects described here before students begin.

This file is not included in the learner workshop manifest. It is a preparation checklist for workshop delivery.

Estimated Time: 60-120 minutes per environment, depending on OCI provisioning time and whether you build manually or with automation.

### Objectives

In this setup guide, you will:

- Build the OCI VCN, subnet, VLAN, gateway, route-table, and security prerequisites
- Create the OLVM manager and two KVM hosts on `VM.Standard.E5.Flex`
- Attach secondary VNICs for the private and VLAN networks
- Create two shared block volumes and attach them to both KVM hosts
- Prepare the `oracle` workshop user and SSH trust used by learner labs
- Validate the environment before learners start Lab 1

### Prerequisites

Before setup, confirm that you have:

- OCI permissions to create compute, networking, VLAN, public IP, and block volume resources
- Service limits for three `VM.Standard.E5.Flex` instances
- Capacity for two `1 TB` block volumes
- VLAN / Layer 2 network virtualization available in the target region
- A target compartment for the workshop
- An SSH public key for the workshop instances
- A secure way to provide learners with the matching private key, or a process for learners to provide public keys before class

## Task 1: Create the Network Foundation

1. Create the VCN.

    | Field | Value |
    |---|---|
    | Name | `OLV-VCN` |
    | CIDR Block | `10.0.0.0/16` |
    | DNS Label | `olv` |

2. Create the public subnet.

    | Field | Value |
    |---|---|
    | Name | `Public Subnet-OLV-VCN` |
    | CIDR Block | `10.0.0.0/24` |
    | DNS Label | `pub` |
    | Public IP Assignment | Allowed |

3. Create the private subnet.

    | Field | Value |
    |---|---|
    | Name | `Private Subnet-OLV-VCN` |
    | CIDR Block | `10.0.1.0/24` |
    | DNS Label | `priv` |
    | Public IP Assignment | Not allowed |

4. Create the VLAN.

    | Field | Value |
    |---|---|
    | Name | `VLAN-VMs` |
    | VLAN Tag | `1` |
    | CIDR Block | `10.0.10.0/24` |

## Task 2: Create Gateways, Routing, and Security

1. Create `Internet Gateway-OLV-VCN` and enable it.

2. Create `Service Gateway-OLV-VCN` for all services in Oracle Services Network.

3. Create or update the public route table.

    | Field | Value |
    |---|---|
    | Name | `Default Route Table for OLV-VCN` |
    | Route Rule | `0.0.0.0/0` through `Internet Gateway-OLV-VCN` |
    | Associate With | `Public Subnet-OLV-VCN` and `VLAN-VMs` |

4. Create or update the private route table.

    | Field | Value |
    |---|---|
    | Name | `Route Table for Private Subnet-OLV-VCN` |
    | Route Rule | Oracle Services Network through `Service Gateway-OLV-VCN` |
    | Associate With | `Private Subnet-OLV-VCN` |

5. Configure subnet security rules.

    | Direction | Source or Destination | Protocol |
    |---|---|---|
    | Egress | `0.0.0.0/0` | All protocols |
    | Ingress | `10.0.0.0/16` | All protocols |
    | Ingress | Learner or instructor client IP with `/32` | All protocols |

6. Create a network security group named `L2 Network`.

7. Add these rules to `L2 Network`.

    | Direction | Source or Destination | Protocol |
    |---|---|---|
    | Egress | `0.0.0.0/0` | All protocols |
    | Ingress | `10.0.0.0/16` | All protocols |

8. Associate `VLAN-VMs` with `L2 Network`.

## Task 3: Create the E5 Instances

1. Create the OLVM manager.

    | Field | Value |
    |---|---|
    | Name | `olvm` |
    | Image | Oracle Linux 8 |
    | Shape | `VM.Standard.E5.Flex` |
    | OCPUs | `2` |
    | Memory | `32 GB` |
    | Primary VNIC | `Public Subnet-OLV-VCN` |
    | Public IP | Yes |

2. Create the first KVM host.

    | Field | Value |
    |---|---|
    | Name | `olkvm01` |
    | Image | Oracle Linux 8 |
    | Shape | `VM.Standard.E5.Flex` |
    | OCPUs | `8` |
    | Memory | `64 GB` |
    | Primary VNIC | `Public Subnet-OLV-VCN` |
    | Public IP | Yes |

3. Create the second KVM host.

    | Field | Value |
    |---|---|
    | Name | `olkvm02` |
    | Image | Oracle Linux 8 |
    | Shape | `VM.Standard.E5.Flex` |
    | OCPUs | `8` |
    | Memory | `64 GB` |
    | Primary VNIC | `Public Subnet-OLV-VCN` |
    | Public IP | Yes |

4. Use the same workshop SSH public key on all three instances.

## Task 4: Attach Secondary VNICs

1. Attach one private-subnet VNIC to `olvm`.

    | Field | Value |
    |---|---|
    | VNIC Name | `vdsm` |
    | Network | `Private Subnet-OLV-VCN` |
    | Public IP | No |

2. Attach two secondary VNICs to `olkvm01`.

    | VNIC Name | Network | Public IP |
    |---|---|---|
    | `vdsm01` | `Private Subnet-OLV-VCN` | No |
    | `l2-vm-network` | `VLAN-VMs` | No |

3. Attach two secondary VNICs to `olkvm02`.

    | VNIC Name | Network | Public IP |
    |---|---|---|
    | `vdsm02` | `Private Subnet-OLV-VCN` | No |
    | `l2-vm-network` | `VLAN-VMs` | No |

4. Record the public IPs and private-subnet IPs for all three instances.

## Task 5: Configure Private VNICs in Oracle Linux

1. Connect to each instance as `opc`.

2. Run this command on `olvm`, `olkvm01`, and `olkvm02`.

    ```bash
    <copy>sudo oci-network-config configure
    ip -br addr</copy>
    ```

3. Confirm that each host has an address on `10.0.1.0/24`.

4. Do not manually configure the VLAN VNICs on the KVM hosts.

## Task 6: Create and Attach Shared Block Volumes

1. Create `amd-storage-domain-01`.

    | Field | Value |
    |---|---|
    | Size | `1 TB` |
    | Availability Domain | Same availability domain as the KVM hosts |

2. Create `amd-storage-domain-02`.

    | Field | Value |
    |---|---|
    | Size | `1 TB` |
    | Availability Domain | Same availability domain as the KVM hosts |

3. Attach both volumes to `olkvm01`.

    | Field | Value |
    |---|---|
    | Attachment Type | Paravirtualized |
    | Access | Read/write |
    | Shareable | Yes |

4. Attach both volumes to `olkvm02` using the same attachment values.

5. Do not format or mount the volumes from Linux.

## Task 7: Prepare Workshop SSH Access

1. Create the `oracle` workshop user on all three hosts.

    ```bash
    <copy>sudo id oracle >/dev/null 2>&1 || sudo useradd -m -G wheel oracle
    sudo mkdir -p /home/oracle/.ssh
    sudo cp /home/opc/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
    sudo chown -R oracle:oracle /home/oracle/.ssh
    sudo chmod 700 /home/oracle/.ssh
    sudo chmod 600 /home/oracle/.ssh/authorized_keys
    echo 'oracle ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/oracle
    sudo chmod 440 /etc/sudoers.d/oracle</copy>
    ```

2. On `olvm`, add short hostnames for both KVM hosts.

    ```bash
    <copy>sudo tee -a /etc/hosts <<'EOF'
    <olkvm01-primary-private-ip> olkvm01
    <olkvm02-primary-private-ip> olkvm02
    EOF</copy>
    ```

3. On `olvm`, generate an SSH key for the `oracle` user.

    ```bash
    <copy>ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
    cat ~/.ssh/id_rsa.pub</copy>
    ```

4. Add the generated public key to `/home/oracle/.ssh/authorized_keys` on `olkvm01` and `olkvm02`.

5. From `olvm`, verify SSH to both KVM hosts.

    ```bash
    <copy>ssh olkvm01 hostname -f
    ssh olkvm02 hostname -f</copy>
    ```

## Task 8: Pre-Class Validation

1. Run through learner Lab 1 once before class.

2. Confirm that every Lab 1 checkpoint passes.

3. Save these values for the instructor.

    | Value | Notes |
    |---|---|
    | Region |  |
    | Compartment |  |
    | `olvm` public IP |  |
    | `olvm` private subnet IP |  |
    | `olkvm01` public IP |  |
    | `olkvm01` private subnet IP |  |
    | `olkvm02` public IP |  |
    | `olkvm02` private subnet IP |  |

4. Confirm learners have the correct private key or approved SSH access method before class begins.

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Shawn Kelley, Perside Foster
- **Contributor** - Marvin Kim
- **Last Updated By/Date** - Perside Foster, June 9, 2026
