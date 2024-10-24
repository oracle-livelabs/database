# Introduction

## About this workshop
This workshop introduces you to Oracle Database backup and recovery with the Recovery Manager (RMAN). After completing this workshop, you will be familiar with the basic concepts of Oracle Database backup and recovery operations, know how to implement a disk-based backup strategy, and recover database.

Estimated Workshop Time: 2 hours

### Objectives
In this workshop, you will learn to perform the following Oracle Database activities:
-   Configure recovery settings
-   Configure backup settings
-   Perform and schedule backups
-   Manage backups
-   Restore database
-   Rewind a table using the Flashback Table
-   Recover a dropped table using Flashback Drop

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Installed Oracle Database


## Appendix 1: Overview of Oracle database backup and recovery
Oracle Database backup and recovery operations focus on the physical backup of database files, which permits you to reconstruct your Oracle Database in case of a failure or corruption.

Oracle recommends Recovery Manager (RMAN), a command-line tool, to back up and recover your Oracle Database efficiently. The RMAN backup and recovery feature protects data files, control files, server parameter files, and archived redo log files. With these files, you can reconstruct your Oracle Database. RMAN communicates with the server to detect block-level corruption during backup and restore. RMAN optimizes performance and space consumption during backup with file multiplexing and backup set compression and integrates with leading storage devices. The backup mechanisms work at the physical level to protect against file damage, such as the accidental deletion of a data file or the failure of a storage device. RMAN can also be used to perform point-in-time recovery to recover from logical failures when other techniques, such as flashback, cannot be used.

The Oracle Flashback feature provides a range of physical and logical data recovery tools as efficient, easy-to-use alternatives to physical and logical backups. The Oracle Flashback features enable you to reverse the effects of unwanted database changes without restoring data files from backup.


Click on the next lab to **Get Started**.


## Learn More

[Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/index.html)

[Oracle Cloud Infrastructure Documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm)


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, October 2024
