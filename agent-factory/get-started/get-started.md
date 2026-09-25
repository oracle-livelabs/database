# Get Started

## Introduction

In this lab you'll gather required data for installing the Agent Factory in OCI through the OCI Marketplace. This lab uses OCI Generative AI Services as the "LLM provider".

> Note: Agent Factory can be installed on OCI, local computer/laptop, or any other unix-based cloud compute instance. The Agent Factory aims to support you wherever your LLM: OCI, self-hosted (e.g. vLLM, or OLlama), or directly from a foundational model provider (e.g. OpenAI, Google).

**Estimated time:** 5 minutes.

### Objectives
* Understand prerequisites and gather required information for installation

### Prerequisites
* Access to an **Oracle Cloud Infrastructure (OCI) tenancy** with compartment level admin privileges
* Basic familiarity with the Oracle AI Autonomous Database
* Basic understanding of OCI Virtual Cloud Network (VCN)

## Task 1: Create and Configure VCN
1. [Refer to the VCN creation guide](https://docs.oracle.com/en/learn/lab_virtual_network/index.html#create-your-vcn) or use the VCN Setup Wizard.
2. Update the default security list to open ports 8080 and 1521.

## Task 2: Create Oracle AI Autonomous Database
1. [Refer to the Autonomous Database creation guide](https://livelabs.oracle.com/ords/r/dbpm/livelabs/run-workshop?p210_wid=4276&session=105049282417815)
2. Download a Database wallet
3. Create a dedicated database user for Agent Factory using the following SQL statements:

    ```sql
    <copy>
    CREATE USER <db_user> IDENTIFIED BY <password> DEFAULT TABLESPACE USERS QUOTA unlimited ON USERS;

    GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE TYPE, CREATE PROCEDURE, CREATE VIEW, CREATE SYNONYM TO <db_user>;

    GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO <db_user>;

    GRANT SELECT ON V_$PARAMETER TO <db_user>;

    CREATE USER AAI_RO_<db_user> IDENTIFIED BY <same_password_as_db_user> ACCOUNT UNLOCK;

    GRANT CREATE SESSION TO AAI_RO_<db_user>;
    </copy>
    ```

> **Note:** Replace <db_user> and <password> with values appropriate for your environment. The read-only user (AAI_RO_<db_user>) should use the same password as the primary Agent Factory database user.
>
> In some database configurations, depending on the database version and privileges available to the administrator user, the following statement may fail: `GRANT SELECT ON V_$PARAMETER TO <db_user>;`. If this occurs, use the following alternative statement instead: `GRANT SELECT ON V$PARAMETER TO <db_user>;`.

## Task 3: Gather installation prerequisites for next lab
1. Your VCN Compartment, VCN name, and public subnet name
2. Your Autonomous Database Instance or Regional Wallet
3. Your Autonomous Database Username and Password for the 26ai Database from Task 3.


You may now **proceed to the next lab**

## Acknowledgements

**Authors** 

* Allen Hosler, Principal Product Manager, Database Applied AI
* Kumar Varun, Senior Principal Product Manager, Database Applied AI

**Last Updated Date** - June, 2026
