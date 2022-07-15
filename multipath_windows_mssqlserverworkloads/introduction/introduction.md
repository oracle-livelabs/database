# Introduction

## About this Workshop

This hands-on workshop provides users with step-by-step instructions on enabling Multipath-IO (MPIO) on Windows Server 2019 and attaching the Block Storage in Windows for **Microsoft SQL Server** workloads.

When you attach a volume configured for the Ultra High-Performance level, the volume attachment must be multipath-enabled to achieve optimal performance. The Block Volume service attempts to enable the attachment for multipath when the volume is being attached.

Current VM shapes configured for 16 cores or more support multipath-enabled attachments. See the [Link](https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumeperformance.htm#unique_1679934834) for performance characteristics of volumes attached to VMs with paravirtualized attachments. To verify that a shape supports multipath-enabled attachments, look for the value Yes in the Supports Ultra High Performance (UHP) column in the VM Shapes table.

Estimated Time: 1 Hour 30 min

**Workshop Objectives**
In this workshop, you will learn how to:
* Provision of the Windows Compute Instance
* Configure Multipath_IO (MPIO) on Windows Server 2019
* Provision of the Block storage
* Attach Block storage on Windows with Multipath_IO (MPIO) enabled

**Prerequisites**
* An Oracle Free Tier, Always Free, Paid, or LiveLabs Cloud Account
* Some understanding of cloud and security terms is helpful
* Familiarity with Oracle Cloud Infrastructure (OCI) is helpful
* Required Subnets: One public subnet for the Bastion host and three private subnets to host the Domain Controller, Microsoft SQL Server Nodes, and Quorum Server

## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Jitender Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, July 2022