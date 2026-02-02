# Get Started

## Introduction

In this lab you'll undestand the high-level network and application architecture, and gather required data for installation on OCI through the OCI Marketplace. This lab uses OCI Generative AI Services as the "LLM provider".

> Note: Agent Factory can be installed on OCI, local computer/laptop, or other any other unix-based cloud compute instance. The Agent Factory aims to support you wherever your LLM: OCI, self-hosted (e.g. vLLM, or OLlama), or directly from a foundational lab (e.g. OpenAI, Google).

**Estimated time:** 5 minutes.

### Objectives
* Understand Agent Factory depoloyment architecture on OCI
* Understand pre-requesites and gather required information for installation

### Prerequisites
* Access to an **Oracle Cloud Infrastructure (OCI) tenancy** with compartment level admin privelages
* Basic familiarity with Oracle AI Database Autonomous AI Database
* Basic understanding of OCI Virtual Cloud Network (VCN)

## Task 1: Agent Factory High Level Architecture

## Task 2: Create and Configure VCN
1. Create VCN https://docs.oracle.com/en/learn/lab_virtual_network/index.html#create-your-vcn or use VCN Quick Create
2. Update security list to add ports 8080 and 1521 in the default security list

## Task 3: Create Oracle AI Database Autonomous AI Database
1. Refer to https://livelabs.oracle.com/ords/r/dbpm/livelabs/run-workshop?p210_wid=4276&session=105049282417815
2. Download Database wallet
3. (Optional) Create new user for Agent Factory 

## Task 4: Gather installation prerequesites for next lab
1. VCN Compartment, VCN Name, Public-subnet Name
2. ADB Instance or Regional Wallet
3. Database Username and Password for the 26ai DB from task-3
(Provide Example here)

You may now **proceed to the next lab**

## Acknowledgements

- **Authors** 
* Allen Hosler, Principal Product Manager, Database Applied AI
* Kumar Varun, Senior Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026
