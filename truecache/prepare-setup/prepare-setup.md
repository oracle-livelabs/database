# Prepare Setup

## Introduction
This lab shows you how to download the Oracle Resource Manager (ORM) stack zip file needed to set up the resources for this workshop. This workshop requires a compute instance running the Oracle Database Sharding Marketplace image and an Oracle Cloud Infrastructure (OCI) virtual cloud network (VCN).

*Estimated Time:* 10 minutes

Watch the video for a quick walk-through of the Prepare Setup lab.

[Prepare Lab Setup](youtube:DTIGmlj7Y3I)

### Objectives
-   Download ORM stack
-   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack zip file
1. Click on the link below to download the validated Resource Manager zip file you need to build your environment: [true-cache.zip](https://oracle-livelabs.github.io/database/truecache/prepare-setup/files/true-cache.zip)

2. Save the file in your Downloads folder.

We strongly recommend using this stack to create a dedicated, self-contained VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you prefer to use an existing VCN, continue to Task 2 to add the required ingress rules.

## Task 2: Adding Security Rules to an Existing VCN   
This workshop requires inbound access on the ports listed below. The default ORM stack creates a dedicated VCN with these rules. If you use an existing VCN, add the following ports to its ingress rules:

| Port           |Description                            |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 80             | noVNC through NGINX                   |
| 6080           | noVNC Remote Desktop                  |

1. Go to *Networking >> Virtual Cloud Networks*
2. Choose your network
3. Under Resources, select Security Lists
4. Under Resources, select Security Lists, then select the default security list for the VCN.
5. Select Add Ingress Rule.
6. Enter the following:
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Enter the port listed in the preceding table.*
7. Select Add Ingress Rules.

## Task 3: Setup Compute   
Using the details from the two tasks above, continue to *Environment Setup* to provision your workshop environment by using Oracle Resource Manager (ORM) and one of the following options:
-  Create Stack:  *Compute + Networking*
-  Create Stack:  *Compute Only*, using an existing VCN whose security lists you updated in Task 2

For this True Cache workshop, use the following minimum recommended capacity:
- Recommended memory: 48 GB
- Recommended CPU: 6 OCPUs

Continue to the next lab.

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
