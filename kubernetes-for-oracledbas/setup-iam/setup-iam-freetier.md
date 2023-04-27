# Provision and Configure the Cloud Infrastructure

## Introduction

In this lab, we will create a *Compartment* to isolate the Oracle Cloud Infrastructure (OCI) resources created during this workshop.  <if type="tenancy">Additionally we will create OCI *Policies* required for least-privilege provisioning of the workshop infrastructure.</fi>

<if type="tenancy">

**If you are not in the OCI Administrators group, please have an OCI Administrator perform:**

* Task 1. Configure Policies
* Task 2. 

</fi>

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Ensure you have the correct OCI Policies
* Create an OCI Compartment

### Prerequisites

This lab assumes you have:

    An Oracle Cloud Paid Account
    You have completed:
        Get Started

## Task 1: Open the Cloud Shell

## Task 2: Create a Compartment

A compartment is a collection of cloud assets, like Databases, Oracle Kubernetes Clusters, and so on. By default, a root compartment was created for you when you created your tenancy (for example, when you registered for the trial account). It is possible to create everything in the root compartment, but Oracle recommends that you create sub-compartments to help manage your resources more efficiently.

In 

## Task 3: Configure Policies


## Learn More

* [OCI - Managing Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
* [OCI - Getting Started with Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm)
* [OCI - Managing Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
