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

1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration > Database Migration > Migrations**

  ![Screenshot of migration navigation](images/migration-navigation.png =90%x*)

2. Select **TestMigration**

  ![Screenshot of select testmigration](images/select-testmigration.png =90%x*)

3. If Migration is still being created, wait until Lifecycle State is Active

4. Press **Validate** button

  ![Screenshot of press validate](images/press-validate.png =90%x*)

5. Press **Validate** button to confirm   

![Screenshot of confirm validate](images/press-validate-again.png =40%x*)

6. Click on **View Details** in the information box above the validate button. You can also navigate to the Jobs resources of this migration.

  ![Screenshot of click jobs](images/migration-view-details.png)

7. Phases will be shown, and status will be updated as phases are completed. It can take 2 minutes before the first phase is shown.
    ![Screenshot of phases with updated status](images/pump.png =90%x*)

8. If a phase has failed, it will show with the status **Failed**. In this case, press on the phase name to learn more about the reason for failure. Resolve the issue described and rerun the validation by pressing the Validate button again.

  ![Screenshot of dowload log](images/job-error.png =90%x*)

9. Once all phases show complete, move to the next step.

## Task 2: Run Migration

  1. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration > Database Migration > Migrations**

    ![Screenshot of migration navigation](images/migration-navigation.png =90%x*)

  2. Select **TestMigration**

    ![Screenshot of select testmigration](images/select-testmigration.png =90%x*)

  3. Press **Start** to begin the Migration. The Start Migration dialog is shown. Select the default phase: **Monitor replication lag**.This will cause the replication to run continuously until the Migration is resumed. 

    ![Screenshot of start migration](images/monitor-replication-lag.png =50%x*)

  4. Click on **View Details** in the information box above the validate button. You can also navigate to the Jobs resources of this migration.

  ![Screenshot of click jobs](images/runmigration-view-details.png)

  5. Job phases are updated as the migration progresses

  6. Wait till **Monitor replication lag** phase completes and migration goes into **Waiting** state

  ![Screenshot of completed phases](images/monitor-lag-waiting.png =90%x*)

 Data replication is in progress and is capturing all transactions since start of the migration. 
  
  7. Open the Cloud Shell by pressing the icon ![](images/cloudshell.png =22x22) and enter the following command to run SQL*Plus:
    ```
    <copy>
    sqlplus system/<admin_password>@<dbcs_public_ip>:1521/<dbcs_pdb_service>
    </copy>
    ```

    Please replace the following placeholders withe the actual values from terraform output:
    * <admin\_password\>
    * <dbcs\_public\_ip\>
    * <dbcs\_pdb\_service\>

    ![Screenshot of Cloud Shell and SQLPlus](images/cloudshell_sqlplus.png =90%x*)

    In the SQL*Plus prompt please enter the following command:

    ```
    <copy>
    INSERT INTO "HR01"."EMPL" (COL1, COL2, COL3, COL4) VALUES ('99999', 'Joe', 'Smith', CURRENT_TIMESTAMP); 
    </copy>
    ``` 

    ```
    <copy>
    commit;
    </copy>
    ``` 
    This will insert a record into the source database simulating new transactions which GoldenGate will identify and replicate to the target database.
    You can close the Cloud Shell window now.

 8. Let's review the migrated data in the autonomous database.
    In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Oracle Database > Autonomous Database**

    ![Screenshot of migration navigation](images/adb-navigation.png =90%x*) 

 9. In the list of autonomous databases, click on the entry TargetADB#####.   

    ![Screenshot of ADB list](images/adb-list.png =90%x*) 

 10. Click on the **Database Actions** button. If you browser blocks the popup, change it to allow popups from Oracle cloud. 

    ![Screenshot of ADB list](images/db-actions.png =90%x*) 

 11. In **Database Actions**, click on the **SQL** tile. Close any popup dialogs.

    ![Screenshot of ADB list](images/db-actions-sql.png =50%x*) 
 
 12. On the left side, change the user to **EMPL01** and right-click on the table **EMPL** to select **Open**.

    ![Screenshot of ADB list](images/db-actions-empl.png =40%x*)

 13. On the right side, select the tab **Data**. All entries of the test data table EMPL will show. Click on the filter icon and fill in a search condition for col1 equals 99999. The entry for Joe Smith should appear, which got replicated in real-time by GoldenGate.

    ![Screenshot of ADB list](images/db-actions-data.png =40%x*) 

 14. You can close the Database Actions window and go back to OCI.

 15. In the OCI Console Menu ![](images/hamburger.png =22x22), go to **Migration > Database Migration > Migrations**

    ![Screenshot of migration navigation](images/migration-navigation.png =90%x*)

 16. Select **TestMigration**

    ![Screenshot of select testmigration](images/select-testmigration.png =90%x*)

 17. Click on **View Details** in the information box above the validate button. You can also navigate to the Jobs resources of this migration. 

    ![Screenshot of View Details ](images/waiting-migration-viewdetails.png =90%x*)    

 18. This is the point where a migration user would stop the source application so that no more transactions are applied to the source DB. You can now press **Resume** on the job to complete replication. In the Resume Job dialog, chose the **Switchover App** phase and press **Resume**. The Switchover App phase will gracefully stop replication and signal the target application to initiate transactions to the target DB.
    ![Screenshot of resume job switchover](./images/resume-job-switchover.png " ")

 19. After Job resumes and changes the status to WAITING after Switchover App phase, press Resume. Select the last phase Cleanup and press Resume:
    ![Screenshot of resume job cleanup](./images/resume-job-cleanup.png " ")

 20 . The migration runs the final cleanup phases and shows as Succeeded when finished:
    ![Screenshot of resume job cleanup completed](./images/cleanup-completed.png " ")
    ![Screenshot of succeeded Migration](./images/succeeded.png " ")

## Learn More

* [Managing Migration Jobs](https://docs.oracle.com/en-us/iaas/database-migration/doc/managing-migration-jobs.html)

## Acknowledgments
* **Author** - Alex Kotopoulis, Director, Product Management
* **Contributors** -  Kiana McDaniel, Hanna Rakhsha, Killian, Lynch, Solution Engineers, Austin Specialist Hub
* **Last Updated By/Date** - Killian Lynch, Kiana McDaniel, Hanna Rakhsha, Solution Engineers, July 2021
