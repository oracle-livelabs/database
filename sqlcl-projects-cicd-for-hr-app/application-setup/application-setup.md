# Getting Started With The Application

**Introduction**

Welcome aboard! You're about to embark on an exciting project: developing the "Departments" feature for the growing HR application at MoroccanTech Solutions in Casablanca. 

**The Challenge**

MoroccanTech Solutions is a thriving company experiencing rapid growth. Their current HR systems, while sufficient in the past, are now struggling to keep up with the increasing number of employees and departments. To address this, they need a robust Department Management system to improve efficiency and organization.

**Your Mission**

Before we dive into the code, let's explore the existing HR application. In this lab, you'll:

* **Understand the Current System:** Examine the application to understand its current functionalities and identify areas where the "Departments" feature is needed.
* **Learn SQLcl and CI/CD:** Utilize SQLcl's project feature to streamline the development and deployment process. You'll also gain hands-on experience with automating database changes and managing them within a CI/CD pipeline.

By the end of this lab, you'll have the skills and knowledge to effectively develop and deploy the "Departments" feature, ensuring a smooth and seamless integration with the existing HR application.

**Focus on the Process**

Remember, the primary goal of this lab is to learn the principles of database development and deployment using SQLcl and CI/CD practices. The specific technology used in the application itself is not the main focus.


**Estimated Workshop Time:** 14 minutes


## Objectives

By the end of this lab, you will be able to:

* **Successfully implement and deploy new features:**
    * Develop and integrate the "Departments" feature into the existing HR application.
    * Make coordinated changes to both the application code and the underlying database schema.
    * Utilize SQLcl's project feature to manage and version database changes effectively.
* **Master core CICD concepts:** 
    * Understand the importance of development, testing, and production environments.
    * Learn how to automate database deployments using SQLcl.
    * Experience the benefits of integrating database CICD.
* **Gain practical skills:**
    * Set up and run the application locally.
    * Explore and understand the application's components and architecture.
    * Analyze application requirements and design database solutions accordingly.
    * Troubleshoot and resolve common issues encountered during development and deployment.
    ![the goal of the lab ](../application-setup/images/before-and-after.png " ")

### Prerequisites

* Completion of Lab 1 and Lab 2 
* Basic understanding of Git 

## Task 1: Understanding Environments and Database CICD Challenges

##### Introduction to Development, Testing, and Production Environments: 

In this lab, we will focus on two environments:

* **Development (Dev):** 
    * This is where **you** will work on implementing the new "Departments" and "Analytics" features for our HR application. 
    * In the Dev environment, the application may have incomplete features, bugs, or unstable behavior as they are still under development.
* **Production (Prod):** 
    * This is the live environment where the final, polished version of the application will be available to our company's HR department. 
    * The application in the Prod environment should be stable, fully functional, and free of major bugs. 
    * **Our goal in this lab is to successfully deploy the “Departments” and “Analytics” features to the Prod environment.** 

**Note:** To simplify this lab, we will primarily focus on the Development (Dev) and Production (Prod) environments. 


### Bottlenecks of Traditional Database Deployments
In traditional database deployments, especially in a manual process, several challenges arise:

- Manual Interventions: Deploying database changes often involves manual steps, such as executing SQL scripts, creating database objects, and migrating data. This manual process is prone to human error, time-consuming, and can introduce inconsistencies between environments.
- Lack of Automation: Without automation, it becomes difficult to consistently and reliably deploy changes across different environments (Dev, Test, Prod) in a timely manner. This can significantly slow down the development cycle and hinder the rapid delivery of new features to our users.
- Increased Risk of Errors: Manual deployments increase the risk of introducing bugs, data corruption, or unintended side effects in the production environment. This can lead to downtime, data loss, and negatively impact the user experience.
Our Goal:

This is where our journey with SQLcl Project CICD begins. **You**, faced with the challenges of managing database changes for your new features, will leverage the power of SQLcl to automate deployments, track changes, and ensure a smooth and reliable release process.

## Why are we using Project sqlcl and Project CICD ?
Database Application Continuous Integration and Continuous Delivery (CI/CD) represents a transformative approach in modern database management and application development. This methodology seamlessly integrates database changes into the development pipeline while ensuring swift and secure deployment to production environments. By combining the rapid feedback mechanisms of Continuous Integration with the streamlined deployment processes of Continuous Delivery, Database CI/CD addresses the critical need for agility and reliability in today's fast-paced software development landscape.

 ![Database CI/CD](./images/cicd.png " " )
At its core, Database CI/CD aims to:

* Accelerate time-to-market for new features and updates.
* Maintain a consistently high quality of code and database schema.
* Facilitate immediate issue detection and resolution.
* Ensure that both application and database components are always in a deployable state.
This approach not only enhances development efficiency but also significantly improves the end-user experience through frequent, reliable releases.

In this lab, you'll leverage the power of SQLcl's project feature to show the development and deployment of the "Departments" feature. By using SQLcl PROJECT CICD practices, you'll achieve several benefits:

* **Efficient deployments:** Successfully deploy the "Departments" feature to production with minimal risk and maximum efficiency.
* **Reduced manual effort:** Automate repetitive database deployment tasks, freeing you to focus on development and innovation.
* **Consistent deployments:** Minimize errors and inconsistencies across environments (Dev and Prod) for a stable and reliable production environment.
* **Faster development cycles:** Speed up delivery of new features to users.
* **Hands-on CICD experience:** Gain practical experience implementing and managing database changes within a controlled and automated framework, preparing you for real-world database development projects.

By the end of this lab, you'll have a solid understanding of how to use SQLcl's project feature effectively within a CICD pipeline. This knowledge will empower you to implement similar practices in your own projects and contribute to the success of future database-driven applications.

**Want to learn more about SQLcl Project and CICD?**

Check out this resource: https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.3/sqcug/introduction.html?utm_source=pocket_shared


## Task 2: Exploring the Initial Application
### Getting Started With The Application

Youssef, the HR director of MoroccanTech Solutions, has a vision: to streamline employee management by implementing a  "Departments" feature. Before diving into development, you'll need to thoroughly understand the existing HR application. 

**Your Mission:**

* **Run the application locally.** 
* **Identify existing features.** 
* **Pinpoint missing functionality.** 
 
By carefully analyzing the application, you'll gain valuable insights that will inform the development of the "Departments" feature, ensuring a smooth and seamless integration with the existing HR system.
 
**Let's begin!** 
 
**Access the Application:** 
    * **Log in to the virtual machine.** 
    * **Navigate to the application directory:** Use the command line to navigate to the directory where the application code is located (e.g., `cd /path/to/hr-application`).
 
* **Run the Application:**
 
    * **Set Up Database Connection:**
        * **Create a `.env` file:** In the root directory of your application, create a file named `.env`. This file is used to store sensitive configuration variables that the application can access during runtime. It's important to **not** commit this file to version control, as it may contain sensitive credentials.
        * **Obtain OCI URL:** Refer to the **"Setting Up the ORDS REST Service"** section of the previous lab to retrieve the Object Cloud Infrastructure (OCI) URL for your database instance. 
        * **Add Environment Variables:** Edit the `.env` file and add the following variables, replacing the placeholders with your actual values:
            ```
            BASE_URL=your_oci_url (e.g.,(https://123-databasename.adb.eu-amsterdam.oraclecloudapps.com/ords/)
            DB_USERNAME=DEVUSER
            ```
            * `BASE_URL`: This variable stores the base URL for your ORDS REST service endpoint.
            * `DB_USERNAME`: This variable stores the username for your development database user. Ensure this username matches the one you configured in the previous lab.
 
    * **Install Dependencies:**
        * With the `.env` file properly configured, execute the following command to install the necessary project dependencies:
            ```
        <copy> 
            npm install
        </copy>
            ```
 
    * **Start the Development Server:**
        * Now that the database connection is set up, run the following command to launch the application in development mode:
                ```
        <copy> 
            npm run dev
        </copy>
            ```
        * This will typically start a local development server and open the application in your web browser.
        * **You are now interacting with the V1 of the HR application.**
* **Explore the Application:**
    ![Application](../application-setup/images/application.png " ")
    * **Interact with the application:** Navigate through the different pages and sections of the application.
    * **Look for employee-related features:** Examine features related to employee profiles, employee lists, and any existing team assignments.
    * **Identify missing "Departments" functionality:**
        * Are there any options to create, view, or manage departments?
    ![the goal of the lab ](../application-setup/images/placeholder.png " ")

**Troubleshooting:**

* **Incorrect OCI URL:** Double-check that you've copied and pasted the OCI URL from the previous lab accurately. Ensure it includes the correct hostname, port, and path to your ORDS endpoint.
* **Database Configuration Mismatch:** Verify that the `DB_USERNAME` variable in your `.env` file matches the username you configured for your development database in the previous lab.

## Task 3: Implementing the Departments Feature with SQLcl and PROJECT CICD

### 3.1 Getting Started

* **Starting Point:** Our first task is to implement the "Departments" feature. This involves adding a new "Departments" table to the database and updating the application code to interact with this new table.

* **Project Initialization:**
    * Begin by initializing a new SQLcl project:
      ```
      <copy>
      project init
      </copy>
      ```
     The `project init` command initializes a new SQLcl PROJECTS project, setting up the necessary directories and files for managing your database objects and changes within your current directory.

    <details>  <summary> **Screenshots:**</summary>
    ![ init ](./images/project-init-output.png " ")
    </details>

    * Create a new Git branch for this feature:
        ```
        <copy>
        git checkout -b TICKET-1-Departments
        </copy>
        ```
     This creates a new branch named "TICKET-1-Departments" where you will develop and test the "Departments" feature.
    

* **Project Structure:**
    * SQLcl Projects use a specific folder structure to manage database objects and changes. 
    * Key folders include:
        * **`.dbtools`:** This folder contains project configuration files, filters, and formatting rules.
        * **`src`:** This folder stores exported objects from the database, organized by schema and object type.
        * **`dist`:** This folder is used to store release artifacts generated by the `project stage` and `project release` commands.


    ```text
──.dbtools
│   ├── filters
│   │   └── project.filters
│   ├── project.config.json
│   └── project.sqlformat.xml
├── dist
│   ├── README.md
│   └── install.sql
└── src
    ├── README.md
    └── database
        ├── README.md
        └── hr
    ```


### 3.2 Database Changes
* **Work on the New Feature:**  **Activate the "Departments" Feature:**

    * **Locate the Placeholder Component:** 
    * **Challenge:** 
        * Examine the application code to locate the placeholder component for the "Departments" section. This might be a simple message, a loading indicator, or a basic UI element. 
        * **Hint:** 
            * Look for comments in the code related to the "Departments" feature (e.g., "TODO: Implement Departments", "Departments feature not yet implemented").
            * Search for component names or file names that might relate to the "Departments" functionality (e.g HRPageContent...).
            * Inspect the application's UI for any areas where the "Departments" feature is expected to be displayed.

    <details>  <summary> **Solution:**</summary>
      
       * Find the placeholder component within the application's code, and replace it with Department implementation.
       * **Go to : `/Livelab-APP/src/components/pages/HRPageContentSwitcher.tsx`**
       * **Go to line 66**
       * **Implement Department by adding `<DepartmentPage />` and delete the placeholder component**
       ![Application](../application-setup/images/unlock-departement-code.png " ")
    </details>

* **Create the "Departments" Table:**
    * **Option 1: Using HR application:**
        * Go to the update Records page , and do your inserts: 
            ![the goal of the lab ](../application-setup/images/inserts-in-application.png " ")

    * **Option 2: Using SQLcl:**
        * Open SQLcl with your connection.
        * Write and execute the following SQL statement to create the "Departments" table:
            ```sql
           -- Create Departments table:
            CREATE TABLE Abdelilah.Departments (
                department_id INT PRIMARY KEY,
                name VARCHAR2(50),
                description VARCHAR2(255),
                location VARCHAR2(100)
            );
            ```
        * **Insert Initial Data:**
         ```sql
           -- Create Departments table:
           INSERT INTO DevUSER.Departments (department_id, name, description, location)
            VALUES (1, 'HR', 'Human Resources Department', 'New York');

            INSERT INTO DevUSER.Departments (department_id, name, description, location)
            VALUES (2, 'IT', 'Information Technology Department', 'San Francisco');

            INSERT INTO DevUSER.Departments (department_id, name, description, location)
            VALUES (3, 'Finance', 'Finance and Accounting Department', 'Chicago');

            ```
    * **Option 3: Using OCI :**
        * In your OCI home page, go to **Oracle Database** -> **Autonomous Database**.
        * Click on your available Autonomous Database.
        * In the **Database Actions** section, click on **SQL**.
         ![OCI page](../application-setup/images/oci-SQL.png " ")
        * This will open the SQL Database Actions page where you can directly execute your SQL query.
         ![OCI page](../application-setup/images/insert-oci-sql.png " ")
        * Write and execute the same SQL statements in the option 1.

### 3.3 Exporting Database Changes with SQLcl

* **Export Database Objects:**
    * Execute the following command to export the newly created "Departments" table to the application folder:
        ```
    <copy>
     project export -schemas DEVUSER -verbose
    </copy>
        ```
    ![the goal of the lab ](../application-setup/images/project-export-output.png " ")
    ![the goal of the lab ](../application-setup/images/project-export-editor-output.png " ")

* This command **exports database objects** into your repository. 
*  more explination : ? 
* **Now that we have made the database changes, we export our objects to have them included in our project folders.**
  
 * **Test the Application:** 
    * **In the Development Environment:** 
        * Restart the application to ensure that the database changes and code modifications are reflected in the application's behavior.
        * Thoroughly test the application to verify that the "Departments" feature is working as expected. 
        * Check if you can view, add, or modify department information within the application.

### 3.5 Staging and Releasing Changes

* **Stage Changes:**
    * Execute the following command to stage the changes for release:
        ```
    <copy> 
        project stage
    </copy> 
        ```
    * This command prepares the staged changes for release by creating a release artifact in the `dist` folder.
    ![the goal of the lab ](../application-setup/images/project-stage-commit.png " ")


* **Commit and Merge Changes:**
       *  ```
    <copy>
    git add -A
    git commit -m "Added Departments feature"
    </copy>
    ```
    * **Merge to main branch:**
    ```
     <copy>
    git checkout main
    git merge TICKET-1-Departments
    </copy>
    ```
    * **Resolve any merge conflicts:** (If necessary)


* **Release Changes:**
    * Once your changes are merged into the main branch, execute the following command to create a release artifact:
        <copy>project release -version 2.0 </copy> 
    * This command creates a compressed release artifact that can be easily deployed to other environments.


* **Generate Release Artifact:**
    * The `project gen-artifact` command can be used to create a deployable artifact for your database changes. This artifact can then be easily deployed to different environments.
        ![the goal of the lab ](../application-setup/images/project-gen-artf-and-output.png " ")


**In the next section, we will learn how to deploy these changes to the production environment using SQLcl and explore advanced CICD concepts.**


## Task 4: Deploying to Production

### 4.1 Preparing for Production Deployment

* **Connect to the Development Database:** 
    * Establish a connection to the development database using SQLcl. 
    * You can use the `connect` command to connect to the database using your development credentials.

* **Deploy Changes to Development:**
    * Execute the following command to deploy the staged changes to the development database:
        ```
    <copy>
     project deploy -file artifact/HrManager-2.0.zip  -verbose 
    </copy>
    ```
    * This command applies the changes defined in the release artifact to the development database.

### 4.2 Preparing for Production

* **Update Environment Variables:**
    * Modify the `.env` file to use the production database credentials:
        ```
        BASE_URL=your_oci_url_prod
        DB_USERNAME=PRODUSER 
        ```
    * Replace `your_oci_url_prod` with the actual OCI URL for your production database.

### 4.3 Deploying to Production

* **Connect to the Production Database:**
    * Establish a connection to the production database using SQLcl.
    * Use the `connect` command with the `PRODUSER` credentials.

* **Deploy Changes to Production:**
    * **Check the `project.config.json` file:**
        * Locate the `emitSchema` property within the `project.config.json` file in '.dbtools' folder.
        * Verify that the `emitSchema` property is set to `false`. 
        * If it's set to `true`, modify the `project.config.json` file to set `emitSchema` to `false`.

    * Execute the following command to deploy the changes to the production database:
        ```
    <copy>
    project deploy -file artifact/HrManager-2.O.zip  -verbose
    </copy>
    ```
    * This command applies the changes defined in the release artifact to the production database without recreating existing schema objects.

### 4.4 Testing in Production

* **Run the Production Application:**
    * Restart the application using the production environment variables.
    * Verify that the "Departments" feature is functioning correctly in the production environment. 
    * Perform thorough testing to ensure that all aspects of the feature are working as expected.

**Congratulations!** You have successfully implemented and deployed the "Departments" feature using SQLcl and CICD practices. You have gained valuable experience in managing database changes, automating deployments, and working with a CICD pipeline.


## Learn More

Here are some useful links if you want to know more about Oracle Cloud :
* [Oracle Cloud Doc](https://www.oracle.com/cloud/)

## Acknowledgements

* **Author** -  Abdelilah AIT HAMOU, Junior Member of Technical Staff, SQLcl
* **Created By/Date** -  Junior Member of Technical Staff, SQLcl, December 2024

