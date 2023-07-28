# Introduction

## About Oracle Shard Native Replication/RAFT Replication
Raft Replication is a built-in Oracle Sharding capability that integrates data replication with transaction execution in a sharded database. Raft replication enables fast automatic failover with zero data loss. If all shards are in the same data center, it is possible to achieve sub-second failover.
Raft replication is active/active; each shard can process reads and writes for a subset of data. This capability provides a uniform configuration with no primary or standby shards.

Raft replication is integrated with transaction execution and is completely transparent to users. There is no need to configure and manage Oracle Data Guard or Oracle GoldenGate to achieve high availability.
Raft replication automatically reconfigures replication in case of shard host failures or when shards are added or removed from the sharded database. 

*Estimated Workshop Time:*  1 hour

![RAFT introduction](images/RAFT_intro.png " ")

### Objectives
In this workshop, you will gain first-hand experience in utilizing the Shard Native Replication within Oracle Sharding, enabling participants to manage RAFT-enabled replication for robust distributed database solutions

Once you complete your setup, the next lab will cover:

- Exploring the dynamics of RAFT
- Running the workload

We will use Podman containers and demonstrate multiple use cases.

### Prerequisites
- An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported

*Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

You may now proceed to the next lab.

## Learn More
- [Oracle Sharding Raft Replication: Release 23 Internal link](https://docs-uat.us.oracle.com/en/database/oracle/oracle-database/23/shard/oracle-sharding-raft-replication.html#GUID-34651C7B-7799-4797-9A47-495B984A06CD)

## Acknowledgements
* **Authors** - Deeksha Sehgal, Oracle Database Sharding Product Management, Senior Product Manager
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Jyoti Verma
* **Last Updated By/Date** - Deeksha Sehgal, Oracle Database Sharding Product Management, Senior Product Manager, July 2023

