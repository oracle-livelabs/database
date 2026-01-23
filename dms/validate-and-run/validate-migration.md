# Validate Migration

## Introduction

This lab walks you through the steps to validate a migration prior to running it. Before you can run a job with a migration resource in OCI Database Migration, the migration resource must be validated. The validation job will check that all associated database environments are correctly set up.

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:
* Validate a migration
* Run a migration

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported
* This lab requires completion of the preceding labs in the Contents menu on the left.


## Task 1: Validate Migration

1. In the OCI Console Menu ![hamburger icon](images/hamburger.png =22x22), go to **Migration & Disaster Recovery > Database Migration > Migrations**

    ![create migration navigation](images/migration-create.png =50%x*)
    
2. Select **TestMigration**

  ![Screenshot of select testmigration](images/select-testmigration.png =50%x*)

3. If Migration is still being created, wait until Lifecycle State is Active

4. Press **Validate** button

  ![Screenshot of press validate](images/press-validate.png =50%x*)

5. Click on the **Jobs** tab to display the existing jobs:

  ![Screenshot of click jobs](images/click-jobs.png =50%x*)

6. Click on most recent Evaluation Job

7. Click on **Phases** tab to list the job phases
  
8. Phases will be shown, and status will be updated as phases are completed. It can take 2 minutes before the first phase is shown.

![Screenshot of click phases](images/click-phases.png =50%x*)
    
9. If a phase has failed, it will show with the status **Failed**. Press **Actions**/**Download Log** to learn more about the reason for failure. 

  ![Screenshot of phases with updated status](images/job-details.png =50%x*)

10. In this case **Validate premigration advisor** phase has failed.CPAT is a tool that will assess your source database instance, checking for potentially problematic content and other factors that could impede a successful migration. If you click on the link it will take you to a summary view. 

  ![Screenshot of CPAT summary](images/media-types.png =50%x*)

11. You can click on every check and access to the check details. You will be presented with a description of the issue, the impact and a recommended action. You can mark the check to be excluded from the migration.

  ![Screenshot of check exclusion](images/exclude-check.png =50%x*)

12. Since we took care of the problematic finding the validation Job can be run again. This process should be repeated until “Validate premigration advisor” phase completes with no error.

  ![Screenshot of successful validation](images/job-details-succeeded.png =50%x*)

13. Once all phases show complete, move to the next step.

## Task 2: Run Migration

 1. In the OCI Console Menu ![hamburger icon](images/hamburger.png =22x22), go to **Migration & Disaster Recovery > Database Migration > Migrations**

    ![create migration navigation](images/migration-create.png =50%x*)

  2. Select **TestMigration**

    ![Screenshot of select testmigration](images/select-testmigration.png =50%x*)

  3. Press **Start** to begin the Migration. The confirmation window is displayed, you can select if the migration needs to stop in a specific phase, by default it will complete all phases. Click **Start** again.

    ![Screenshot of start migration](images/monitor-replication-lag.png =50%x*)

  4. Click on the **Jobs** tab to see the list of jobs

  5. Click on the most recent Migration Job

  6. Click on the **Phases** tab to see the list of phases

  7. Job phases are updated as the migration progresses

  8. Wait till **Cleanup** phase completes.

  ![Screenshot of completed phases](images/monitor-lag-waiting.png =50%x*)

 
13. When the cleanup phase completes the job will change to Succeeded:
    The migration should also show as succeeded now.
![Screenshot of succeeded Migration](./images/succeeded.png =50%x*)

## Learn More

* [Managing Migration Jobs](https://docs.oracle.com/en-us/iaas/database-migration/doc/managing-migration-jobs.html)

## Acknowledgments
* **Author** - Alex Kotopoulis, Director, Product Management
* **Contributors** -  Kiana McDaniel, Hanna Rakhsha, Killian, Lynch, Solution Engineers, Austin Specialist Hub
* **Last Updated By/Date** - Jorge Martinez, Product Management, May 2025
