# Instructor Companion for OLVM on OCI E5 Beginner Workshop

## Introduction

Use this companion when delivering the beginner Oracle Linux Virtualization Manager (OLVM) on OCI E5 workshop. It is a short delivery checklist for instructors, workshop owners, and enablement leads who need to keep the class synchronized and avoid known E5 networking pitfalls.

The learner workshop is the source of truth. Use this file only for pacing, setup decisions, checkpoints, and recovery guidance.

Estimated Time: 8 hours

### Objectives

In this instructor companion, you will:

- Choose the right OCI setup path before class
- Keep the beginner workshop aligned with the tested E5 flow
- Verify the required checkpoints at the end of each lab
- Avoid advanced E5 networking workarounds during beginner delivery
- Preserve the multi-tier application and live migration outcomes

## Task 1: Confirm the Delivery Path

1. Use the beginner workshop path for learners.

    | Lab | Title | Required |
    | --- | --- | --- |
    | Lab 1 | Build E5 OCI Infrastructure with Ansible | Yes, unless the environment is already provided |
    | Lab 2 | Deploy OLVM Engine | Yes |
    | Lab 3 | Configure KVM Cluster | Yes |
    | Lab 4 | Set Up Networking, Storage, and VM | Yes |
    | Lab 5 | Deploy Multi Tier Application | Yes |
    | Lab 6 | Perform Live Migration | Yes |

2. If each learner builds their own OCI environment, have them start with Lab 1.

3. If the instructor or workshop owner provides a prebuilt OCI environment, have learners skip Lab 1 and start with Lab 2.

4. Do not add the NAT gateway, users, or advanced networking labs to the beginner delivery unless you intentionally extend the workshop.

## Task 2: Verify the Environment Before Class

1. Confirm the OCI environment uses E5 flexible shapes.

2. Confirm these OCI resources exist:

    - One VCN for the workshop
    - One public subnet for the primary VNICs
    - One private subnet for the OLVM management network
    - One VLAN for VM traffic
    - Two KVM hosts
    - Shared block storage attached to both KVM hosts

3. Confirm the bootstrap or setup process created the expected hosts:

    | Role | Hostname |
    | --- | --- |
    | OLVM engine | `olvm` |
    | KVM host 1 | `olkvm01` |
    | KVM host 2 | `olkvm02` |

4. Confirm learners can SSH to the OLVM engine public IP.

5. Confirm the OLVM engine can SSH to both KVM hosts by hostname.

6. Confirm the KVM hosts are added to OLVM with the private VDSM hostnames:

    | KVM host | Use this hostname in OLVM |
    | --- | --- |
    | `olkvm01` | `vdsm01.priv.olv.oraclevcn.com` |
    | `olkvm02` | `vdsm02.priv.olv.oraclevcn.com` |

7. Do not use the public hostnames when adding KVM hosts to OLVM. Public hostnames can cause non-responsive hosts and default-route warnings.

## Task 3: Use These Lab Checkpoints

1. Check Lab 1 completion.

    Expected result: Ansible creates the OCI network, instances, VNICs, VLAN attachment, storage, and host preparation needed for the workshop.

2. Check Lab 2 completion.

    Expected result: The OLVM Administration Portal opens and learners can sign in.

3. Check Lab 3 completion.

    Expected result: both KVM hosts are `Up` in OLVM.

4. Check Lab 4 completion.

    Expected result: shared storage is active, `l2-vm-network` exists on both KVM hosts, and the test VM is reachable through its KVM host.

5. Check Lab 5 completion.

    Expected result: the database VM and web application VM are both running on the same KVM host, the database query works, and the Employee Directory application opens through the SSH tunnel.

6. Check Lab 6 completion.

    Expected result: the standalone `ol9-vm1` test VM migrates between KVM hosts and remains reachable from the destination host.

## Task 4: Keep the E5 Networking Rule Simple

1. For the beginner workshop, keep the Employee Directory database VM and web application VM on the same KVM host.

2. Use `Run Once` in OLVM when needed to place both application VMs on the same host.

3. Do not troubleshoot cross-host guest-to-guest application traffic during beginner delivery.

4. Use the standalone `ol9-vm1` VM for live migration in Lab 6.

    This keeps the beginner path reliable while still proving the important OLVM concepts: shared storage, common logical networks, VM import, application validation, and live migration.

## Task 5: Manage Timing

1. Use this pacing target for a one-day delivery.

    | Segment | Target Time |
    | --- | --- |
    | Welcome and access check | 20 minutes |
    | Lab 1 | 45-60 minutes |
    | Lab 2 | 45-60 minutes |
    | Lab 3 | 45-60 minutes |
    | Lab 4 | 75-90 minutes |
    | Lab 5 | 45-60 minutes |
    | Lab 6 | 30-45 minutes |
    | Review and cleanup | 20-30 minutes |

2. If the room falls behind, shorten explanations and keep the hands-on checkpoints.

3. Do not skip Lab 5 or Lab 6. Those labs prove that the OLVM environment is useful, not just installed.

## Task 6: Use These Recovery Rules

1. If a KVM host is non-responsive, confirm it was added with the private VDSM hostname.

2. If `l2-vm-network` does not work on a KVM host, return to **Compute**, **Hosts**, select the host, open **Network Interfaces**, and use **Setup Host Networks**.

3. If an application VM cannot be reached, confirm which KVM host it is running on and connect through that host.

4. If the web application cannot reach the database, confirm both application VMs are running on the same KVM host.

5. If live migration is being tested, migrate only the standalone test VM used in Lab 6.

6. If a learner has a local SSH tunnel problem, verify the OLVM public IP, the SSH key path, and the KVM host name used by the tunnel command.

## Acknowledgements

- **Author** - Shawn Kelley, Perside Foster
- **Contributor** - Marvin Kim
- **Last Updated By/Date** - Perside Foster, June 10, 2026
