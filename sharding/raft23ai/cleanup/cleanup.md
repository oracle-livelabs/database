# Clean-up ORM Stack and instances

## Introduction

You can permanently delete (terminate) instances that you no longer need. This can be achieved by using the Destroy job on the Stack in Resource Manager, that you created in the Environment Setup Lab. This job  will tear down the resources/instances and clean up your tenancy.
We recommend running a destroy job before deleting a stack to release associated resources first. When you delete a stack, its associated state file is also deleted; therefore, you lose track of the state of its associated resources. Cleaning up resources associated with a deleted stack can be difficult without the state file, especially when those resources are spread across multiple compartments. To avoid difficult cleanup later, we recommend that you release associated resources first by running a destroy job.
Data cannot be recovered from destroyed resources.

This lab walks you through the steps to running a Destroy Job

Estimated Time - 5 minutes

### Objectives

- Terminate and tear down all resources/instances used in the Oracle Sharding Lab.

### Prerequisites

- You should have provisioned the **Use Raft Replication with Distributed Database for Resilient Never-Down Apps** workshop using a terraform stack

- To provision this workshop, there are detailed instructions in Lab 1 of [Use Raft Replication with Distributed Database for Resilient Never-Down Apps](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=3772&clear=RR,180&session=107115107642748) workshop.

## Task 1: Terminate a Provisioned Oracle Instance

1. Login to Oracle cloud

2. Open the navigation menu and click **Developer Services**. Under **Resource Manager**, click **Stacks**.
  ![stack](./images/stack.png " ")

3. Choose the compartment that you chose in Lab 1 to install your stack (on the left side of the page).

4. Click the name of the stack that you created in Lab 1.The Stack details page opens.

5. Click **Destroy**.

6. In the Destroy panel that is presented, fill in the Name field with Name of the destroy job.

7. Click **Destroy**.

8. The destroy job is created. The new job is listed under **Jobs**. Your instance and all resources used by it will begin to terminate

9. After a few minutes, once the instance is terminated, the Lifecycle state will change from Terminating to Terminated.

You have successfully cleaned up your  instance.

## Learn More

-  **Raft Replication** 
[Raft Replication Documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/23/shard/raft-replication.html#GUID-AF14C34B-4F55-4528-8B28-5073A3BFD2BE)

## Acknowledgements
* **Authors** - Deeksha Sehgal, Ajay Joshi, Oracle Globally Distributed Database Database, Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Jyoti Verma
* **Last Updated By/Date** - Ajay Joshi, Oracle Globally Distributed Database, Product Management, July 2025