# Prepare Your Tenancy

## Introduction

Use your own OCI tenancy and a dedicated compartment. Complete this preparation before Lab 1. Your tenancy administrator can complete IAM setup for you.

Estimated Time: 30-60 minutes, excluding account creation, limit increases, and capacity requests.

### Objectives

- Confirm tenancy access, capacity, permissions, and costs.
- Prepare local SSH access and obtain the workshop image.
- Record workshop resources for recovery and cleanup.

## Task 1: Confirm access and capacity

1. Sign in to [OCI Console](https://cloud.oracle.com/) using your tenancy name, identity domain, user credentials, and multifactor authentication.

1. Choose a commercial OCI region. Ask your administrator to create or approve a dedicated compartment such as `ol-migrate-workshop`. Record its name and OCID, the region identifier, and your availability domain. Use this same region and compartment throughout the workshop.

1. Open **Governance & Administration > Limits, Quotas and Usage**. Check available service limits and compartment quotas for the resources below. Limits, compartment quotas, and physical capacity are separate checks.

    | Resource | Workshop allowance |
    | --- | --- |
    | Compute | One `VM.Standard.E5.Flex` VM, 1 OCPU, 12 GB RAM, x86\_64 |
    | Boot storage | One boot volume, at least 50 GB or image minimum |
    | Custom images | Capacity to import one RHEL 9.8 image |
    | Networking | One VCN, public subnet, internet gateway, route table, security list, VNIC, and public IPv4 address |
    | VCN wizard extras | Capacity for any private subnet, NAT gateway, and service gateway that the wizard creates |
    | Optional recovery | One boot-volume backup and temporary restored volume or replacement VM |

1. Confirm that E5 capacity is available in the selected availability domain when launching in Lab 1. If capacity is unavailable, try another supported availability domain or ask the workshop owner for an image-compatible, tested x86\_64 alternative. Do not substitute an Arm shape for this x86\_64 image.

1. Confirm eligibility for OSMH and Ksplice before starting. OSMH is not available on Free Tier instances. A paid tenancy does not turn a Free Tier instance into a supported workshop target. Use the specified E5 VM and review [OSMH prerequisites](https://docs.oracle.com/en-us/iaas/osmh/doc/getstarted.htm) and [Ksplice on OCI BYOI](https://docs.oracle.com/en-us/iaas/oracle-linux/oci/install-ksplice.htm).

## Task 2: Confirm permissions with your administrator

1. Ask your administrator to complete [Administrator setup](../administrator-setup/administrator-setup.md). The workshop needs Compute, custom-image, networking, storage, OSMH, and agent-plugin permissions. A learner does not need permission to change tenancy IAM once an administrator has prepared it.

1. Confirm that you can select the dedicated compartment in Compute and Networking, view custom images, and open OSMH in the selected region. Resolve authorization errors with your administrator before provisioning resources.

1. Keep all resources in the dedicated compartment where possible. Reuse shared OSMH sources only with the administrator's approval. Record each resource name and OCID, its region, whether you created or reused it, and whether cleanup should delete or retain it.

## Task 3: Review costs

1. Review the [Oracle price list](https://www.oracle.com/cloud/price-list/) and [Cost Estimator](https://www.oracle.com/cloud/costestimator.html). This workshop uses billable resources in your tenancy. Record an estimate in your currency and review any organization-specific budget requirements.

1. Use this dated compute estimate as a starting point. On **November 8, 2026**, Oracle's public USD PAY_AS_YOU_GO catalog listed E5 at **$0.030 per OCPU-hour** and memory at **$0.002 per GB-hour**. For 1 OCPU and 12 GB RAM, compute is **$0.054 per hour**, or **$0.432 for eight hours**.

    Sources: [E5 OCPU catalog entry](https://apexapps.oracle.com/pls/apex/cetools/api/v1/products/?partNumber=B97384) and [E5 memory catalog entry](https://apexapps.oracle.com/pls/apex/cetools/api/v1/products/?partNumber=B97385).

    This is a compute-only list-price estimate, not the total workshop cost. Your currency, contract, region, credits, and taxes can affect billing. Include provisioning and recovery time.

1. For an illustrative 50 GB boot volume at Balanced performance, add storage at $0.0255 per GB-month and 10 performance units per GB at $0.0017 per unit-month. That is $2.125 per month, or about $0.023 for eight hours using 744 hours per month. Compute plus this boot-volume example is about **$0.455 for eight hours**, before other resources and taxes. Use the image minimum if it requires a larger volume. Rates checked November 8, 2026: [capacity](https://apexapps.oracle.com/pls/apex/cetools/api/v1/products/?partNumber=B91961) and [performance](https://apexapps.oracle.com/pls/apex/cetools/api/v1/products/?partNumber=B91962).

1. Add custom-image storage, optional backups, restored volumes, and any applicable Object Storage or transfer charges. Use actual image size and retention time in the estimator. Do not assume that free allowances cover your tenancy.

1. Plan to clean up after Lab 8. Storage, images, and backups can remain billable after a VM stops. Budget alerts can help track spending; they do not automatically stop workshop resources.

## Task 4: Prepare your computer and image access

1. Use a computer with a browser, OpenSSH `ssh`, `ssh-keygen`, and `scp`. Windows PowerShell with OpenSSH, macOS Terminal, or a Linux terminal can run the local access commands. Commands inside the VM use Bash. Each lab identifies where to run commands.

1. Confirm that your network or VPN permits SSH to TCP port 22 and browser HTTP to port 80 on the VM's public address. Use source CIDR `0.0.0.0/0` for the workshop SSH and HTTP ingress rules. The VM also needs outbound DNS and HTTPS access for software downloads and OCI services.

1. Obtain the prepared RHEL 9.8 image URL from the workshop owner through a private channel. Confirm that it refers to `rhel-9-8-apache-source-image-20261025-0915`. The image contains Apache and the workshop HTML application, with Red Hat registration removed. No Red Hat account is required.

1. If you cannot obtain or import the prepared image, stop before launching. Ask the workshop owner to confirm access and refresh an expired link. Do not replace it with a different image. Create your SSH key pair in Lab 1 and retain the private key until cleanup.

1. Keep a local notes file for resource identifiers and verification results. Do not save passwords, private keys, or token-bearing image URLs in shared notes or screenshots. Continue to Lab 1.

## Learn More

- [OCI service limits](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm)
- [Compartment quotas](https://docs.oracle.com/en-us/iaas/Content/Quotas/Concepts/resourcequotas.htm)
- [OCI budgets](https://docs.oracle.com/en-us/iaas/Content/Billing/Concepts/budgetsoverview.htm)

## Acknowledgements

- Perside Foster, Principal Solution Engineer, Oracle
- Rosario Spiezia, Principal Sales Consultant, Oracle
- Mitch Dsouza, Principal Presales Consultant, Oracle Cloud Infrastructure Software
- Nick Mader, Global Channel Enablement & Strategy Director, Open Source Solutions, Oracle
- Last Updated By/Date - Perside Foster, Nov 2026
