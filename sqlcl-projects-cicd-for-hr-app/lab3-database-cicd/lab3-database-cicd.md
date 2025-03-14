# CI/CD for Database Deployments

## Introduction

Welcome aboard! You're about to embark on an exciting project: developing the "Departments" feature for the growing HR application.

The SQLcl Project feature contains many commands: we will explore them all in this lab.

### **The Challenge**

The Tech Solutions Company is a thriving company experiencing rapid growth. Their current HR systems, while sufficient in the past, are now struggling to keep up with the increasing number of employees and departments. To address this, they need a Department Management system to improve efficiency and organization.

![Database cicd](./images/database-cicd.png " ")

### **Your Mission**

Before we dive into the code, let's explore the existing HR application. In this lab, you'll:

* **Understand the Current System:** Understand existing functionalities and where the "Departments" feature fits.
* **Learn SQLcl and CI/CD:** Use SQLcl's project feature for the development and deployment process.

### **Focus on the Process**

Remember, the primary goal of this lab is to learn the principles of database development and deployment using SQLcl and CI/CD practices. The specific technology used in the application itself is not the main focus.

Estimated Lab Time: 14 minutes

### **Objectives**

By the end of this lab, you will be able to:

* Add the new feature to the application with database and code changes.
* Use SQLcl to manage and deploy database changes.
* Practice and apply SQLcl project commands through hands-on exploration.
* Experience and understand the benefits of database CICD.

### **Prerequisites**

* Completion of previous labs
* Basic understanding of Git

## Task 1: Export Database Changes (project export)

Before exporting, create a new git branch and switch to it for this feature:
    ```sql
    <copy>
        !git checkout -b Ticket-1-Departments
    </copy>
    ```
    ![Checkout first branch](./images/checkout-first-branch.png " ")

<!--For exporting, we have two options:

1. Export the entire schema, including all its objects, using the -schemas option, which accepts a list of schemas to export (in our case, just one: "DEV_USER").
2. Export specific objects using the -objects option.

Since we only need the departments table from "DEV_USER", we will use the -objects option.

>**Note:** Use `help project export` for more details on the export command.
    ```sql
    <copy>
     help project export
    </copy>
    ```

**Export Database Objects:**

To see what's happen when exporting the whole schema drop down **Export schema** just below. But for this task you will not export the whole schema, you will export just the departments object.
    <details><summary>**Export schema**</summary>
        * Execute the following command to export the newly created "Departments" table to the application folder:
            ```sql
        <copy>
        project export -schemas DEV_USER -verbose
        </copy>
            ```
        ![Run project export command](./images/project-export.png " ")
        This command **exports database objects** into your repository.
    </details>

* Execute the following command to export the newly created "Departments" table to the application folder:
            ```sql
        <copy>
            project export -objects DEPARTMENTS -verbose
        </copy>
            ```
        ![Run project export command](./images/project-export-object.png " ")
        This command **exports database objects** into your repository.

>**Note:** In the export command the object is not fully qualified (DEV_USER.DEPARTMENTS) since you are currently connected to its schema (DEPARTMENTS).

* Locate the exported object files in the database folder

    ![Exported Objects](./images/database-folder-location.png " ")

* Double click on the 'departments.sql' to see its content

    ![Departments.sql content](./images/departments-sql-content.png " ")

* **Now we have made the database changes, we export our objects to have them included in our project folders.**-->

**Export Database Objects:**

1. Execute the following command to export the departments table database object to the application folder:

    ```sql
    <copy>
        project export -schemas DEV_USER -verbose
    </copy>
    ```

    ![Exported schema](./images/export-devuser-schema.png " ")
    <!--![Exported schema](./images/export-dev-user-schema.png " ")-->
    <!--![Exported schema without hist](./images/export-dev-user.png " ")-->
    <!--![Run project export command](./images/project-export-object.png " ")-->

    This command **exports database objects** into your repository.

2. Find the exported schema folder and its database object files inside the database folder under src.

    ![Database folder location](./images/database-schema-location.png " ")
    <!--![Database folder location](./images/database-schema-folder.png " ")-->
    <!--![Database folder location](./images/database-folder-location.png " ")-->

3. Double click on the 'departments.sql' to see its content.

    ![Departments.sql content](./images/departments-sql-file.png " ")
    <!--![Departments.sql content](./images/departments-sql-file-content.png " ")-->
    <!--![Departments.sql content](./images/departments-sql-content.png " ")-->

4. Now we have made the database changes, we export our objects to have them included in our project folders.

## Task 4: Stage Changes (project stage)

* **Stage Changes:**

    * Add and commit changes before stage

        ```sql
        <copy>
            !git status
        </copy>
        ```

        ```sql
        <copy>
            !git add --all
        </copy>
        ```

        ```sql
        <copy>
            !git status
        </copy>
        ```

        ```sql
        <copy>
            !git commit -m "Export dev_user schema"
        </copy>
        ```

        ![Add and commit changes](./images/git-commit-changes.png " ")
        <!--![Add and commit changes](./images/git-add-commit-changes.png " ")-->

    * Execute the following command to stage the changes for release
        ```sql
        <copy>
            project stage -verbose
        </copy>
        ```
        ![project stage](./images/project-stage-command.png " ")
        <!--![project stage](./images/project-stage-cmd.png " ")-->
        <!--![project stage](./images/project-stage.png " ")-->

        This command prepares the staged changes for release by creating a release artifact in the `dist` folder.

* **Add custom scripts**

    You can add custom scripts using the **add-custom** sub-command of the stage command

    * Add the custom file to the stage
        ```sql
        <copy>
            project stage add-custom -file-name dept-data.sql -verbose
        </copy>
        ```
        ![project stage add-custom](./images/project-stage-add-custom.png " ")

        A custom folder will be added to the dist folder containing the created custom sql file

    * Navigate to the scripts folder

        ![Go to scripts folder](./images/scripts-folder.png " ")
    
    * Copy the insert statements from `departments_table.sql`

        ![Copy inserts](./images/copy-inserts.png " ")

    * Locate the newly created dept_data.sql file

        The file can be found at:`sqlcl-projects-react-app/dist/releases/next/changes/Ticket-1-Departments/_custom`

        ![Custom file location](./images/custom-file-location.png " ")

    * Open the dept_data.sql file and paste the insert statements

        Double-click the file and paste the copied inserts inside and save it (Command + S or Ctrl + S).

        ![Insert data in the custom script](./images/insert-into-custom.png " ")

        <!--TODO: add commit-->

* **Merge to main branch:**
        ```sql
    <copy>
        !git checkout main
    </copy>
        ```
        ```sql
    <copy>
        !git merge Ticket-1-Departments
    </copy>
        ```
    ![Merge branch with main ](./images/merge-to-main.png " ")
    <!--![Merge branch with main ](./images/merge-branch-to-main.png " ")-->

## Task 5: Release Changes (project release)

* Once your changes are merged into the main branch, execute the following command to create a release:
        ```sql
    <copy>
        project release -version 2.0.0 -verbose
    </copy>
        ```
    ![Project release](./images/project-release.png " ")

    This command creates a release folder with the specified version.

## Task 6: Generate Deployable Artifact (project gen-artifact)

Before generating the artifact, you need to return the install.sql file to its initial state containing **lb update**.

* Open the dist/install.sql file

    ![Open install.sql](./images/navigate-to-install-sql-file.png " ")

* Go to line 17 and replace **lb update** with **lb changelog-sync** 

    <!--![Replace lb update with lb changelog-sync](./images/lb-update-to-lb-changelog-syn.png " ")-->
    ![Replace lb update with lb changelog-sync](./images/lb-changelog-sync-to-update.png " ")

* Save the **install.sql** file by pressing **Cmd + S** on Mac or **Ctrl + S** on Windows/Linux.

* Run `project gen-artifact`
    ```sql
    <copy>
        project gen-artifact -verbose
    </copy>
    ```

    ![Project gen-artifact](./images/project-genartifact-cmd.png " ")
    <!--![Project gen-artifact](./images/project-genartifact.png " ")-->
    <!--![Project gen-artifact](./images/project-gen-artifact.png " ")-->

* If you go back to the **artifact** folder, you will find a new artifact generated.

    ![Artifact folder](./images/artifact-folder.png " ")

## Task 7: Deploying to Production (project deploy)

* **Connect to the Production Database:**
    * Establish a connection to the production database using SQLcl.
    * Use the `connect` command with the `PROD_USER` credentials.

        ```sql
    <copy>
        connect PROD_USER/[PASSWORD]
    </copy>
        ```
    ![Connect to prod](./images/connect-to-production.png " ")

* **Deploy Changes to Production:**

    * Execute the following command to deploy the changes to the production database:
        ```sql
        <copy>
            project deploy -file artifact/HrManager-2.O.zip  -verbose
        </copy>
        ```
        <!--![project deploy ](./images/project-deploy-cmd.png " ")-->
        ![project deploy ](./images/project-deploy.png " ")

    * This command applies the changes defined in the release artifact to the production database without recreating existing schema objects.

    * If you check now you find the departments table in the PROD_USER. But what are the other tables ?

        ![Departments table in PROD_USER ](./images/departments-prod-user.png " ")

    <!--The other three created tables are liquibase tables. Liquibase is the engine of the SQLcl Projects tool that apply its command 'liquibase update' behiend scens to check if there is any differences between the source and target database, if they are it apply the changes to get them synched, if they are not, it does't do anything. So it checks that there are diffs before doing anything.-->

* **Enable REST Endpoints**

    To expose the Departments table in PROD\_USER as a REST endpoint, follow the same steps you performed for DEV\_USER in **Lab 1 → Task 4**.

    1. Open Database Actions
    2. Connect as PROD_USER
    3. Locate the Departments table, right-click on it.
    4. Select REST, then click Enable.

    </br>

* **Run the Production Application:**

    1. Restart the application using the production environment variables.
    2. Verify that the "Departments" feature is functioning correctly in the production environment.
    3. Perform thorough testing to ensure that all aspects of the feature are working as expected.

    </br>

* **The department section, should locks like this:**

    ![Departments data working in the app](./images/departments-data-appearing-in-the-app.png " ")

**You did it!** You have successfully implemented and deployed the "Departments" feature and release the version 2 of the application using SQLcl and CICD practices. You have gained valuable experience in managing database changes, automating deployments, and working with a CICD pipeline.

After you gain this some experience, it's time for a new challenge! Head to the [**next lab**](#next) and take your skills to the next level!

## Learn More

* [Oracle SQLcl Doc](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.3/sqcug/working-sqlcl.html)
* [Oracle SQLcl Project & CI/CD Docs](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.3/sqcug/database-application-ci-cd.html#GUID-6A942F42-A365-4FF2-9D05-6DC2A0740D24)
* [Oracle SQLcl Liquibase Docs](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.3/sqcug/using-liquibase.html)
* [Video overview and demonstration for SQLcl Projects](https://youtu.be/qCc-f24HLCU?si=3z-aRBdzu_QhixJ9&t=182)

## Acknowledgements

* **Author** - Fatima AOURGA & Abdelilah AIT HAMMOU, Junior Members of The Technical Staff, Database Tooling, SQLcl developers
* **Created By/Date** - Fatima AOURGA, Junior Member of The Technical Staff, Database Tooling, SQLcl developer, February 2025
