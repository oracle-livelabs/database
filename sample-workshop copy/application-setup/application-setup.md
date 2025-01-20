# Getting Started With The Application

## Introduction

Welcome aboard! As a talented developer at MoroccanTech Solutions in Casablanca city, you've been entrusted with a crucial mission: developing the "Departments" feature for our HR application. Before diving into the code, let's get acquainted with the existing application.

Our Story

The MoroccanTech Solutions as a tech company in Casablanca. Their HR systems, once sufficient for a small startup, are struggling to keep pace with the company's growth and multiple departments. This is where you come in! Your task is to build a Department Management system that brings order and efficiency to their employee structure.

The Challenge

There's a catch, though. The "Departments" feature depends on critical database changes that require careful handling. To ensure a smooth and successful deployment, we'll leverage the power of SQLcl CI/CD practices.

Throughout this lab, you'll:

- Explore the current HR application to understand its functionalities and identify areas where the "Departments" feature is missing.
- Utilize SQLcl's project feature to accelerate the development and deployment process.
- Gain hands-on experience with automating database changes and managing them within the PROJECT CICD in sqlcl.

By the end of this lab, you'll be equipped to effectively develop and deploy the "Departments" feature, ensuring a seamless integration with the existing HR application.

>**Note:** The technology used doesn't matter. The goal of the workshop is not learning you how to develop an application but is to get you now how to develop using SQLcl and Project CICD commands workflow, whatever the technology used.

**Estimated Workshop Time:** 10 minutes

### Objectives

By the end of this lab, you will be able to:

* **Successfully implement and deploy new features:**
    * Develop and integrate the "Departments" feature into the existing HR application.
    * Make coordinated changes to both the application code and the underlying database schema.
    * Utilize SQLcl's project feature to manage and version database changes effectively.
* **Master core CI/CD concepts:** 
    * Understand the importance of development, testing, and production environments.
    * Learn how to automate database deployments using SQLcl.
    * Experience the benefits of integrating database CICD.
* **Gain practical skills:**
    * Set up and run the application locally.
    * Explore and understand the application's components and architecture.
    * Analyze application requirements and design database solutions accordingly.
    * Troubleshoot and resolve common issues encountered during development and deployment.

### Prerequisites

* Completion of Lab 1 and Lab 2 
* Basic understanding of Git 

## Task 1: Understanding Environments and Database CI/CD Challenges

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

In this lab, you'll leverage the power of SQLcl's project feature to streamline the development and deployment of the "Departments" feature. By using SQLcl and CI/CD practices, you'll achieve several benefits:

* **Efficient deployments:** Successfully deploy the "Departments" feature to production with minimal risk and maximum efficiency.
* **Reduced manual effort:** Automate repetitive database deployment tasks, freeing you to focus on development and innovation.
* **Consistent deployments:** Minimize errors and inconsistencies across environments (Dev and Prod) for a stable and reliable production environment.
* **Faster development cycles:** Speed up delivery of new features to users, enabling MoroccanTech Solutions to adapt to changing business needs.
* **Hands-on CI/CD experience:** Gain practical experience implementing and managing database changes within a controlled and automated framework, preparing you for real-world database development projects.

By the end of this lab, you'll have a solid understanding of how to use SQLcl's project feature effectively within a CI/CD pipeline. This knowledge will empower you to implement similar practices in your own projects and contribute to the success of future database-driven applications.

**Want to learn more about SQLcl Project and CI/CD?**

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
            ```npm install```
 
    * **Start the Development Server:**
        * Now that the database connection is set up, run the following command to launch the application in development mode:
            <copy>npm run dev</copy>
        * This will typically start a local development server and open the application in your web browser.
        * **You are now interacting with the V1 of the HR application.**
* **Explore the Application:**
    ![Application](../application-setup/images/application.png " ")
    * **Interact with the application:** Navigate through the different pages and sections of the application.
    * **Look for employee-related features:** Examine features related to employee profiles, employee lists, and any existing team assignments.
    * **Identify missing "Departments" functionality:**
        * Are there any options to create, view, or manage departments?

**Troubleshooting:**

* **Incorrect OCI URL:** Double-check that you've copied and pasted the OCI URL from the previous lab accurately. Ensure it includes the correct hostname, port, and path to your ORDS endpoint.
* **Database Configuration Mismatch:** Verify that the `DB_USERNAME` variable in your `.env` file matches the username you configured for your development database in the previous lab.

## Task 3: Implementing the Departments Feature with SQLcl and CICD

### 3.1 Getting Started

* **Starting Point:** Our first task is to implement the "Departments" feature. This involves adding a new "Departments" table to the database and updating the application code to interact with this new table.

* **Project Initialization:**
    * Begin by initializing a new SQLcl project:
        <copy>project init</copy>
    * This command creates a basic project structure within your current directory. 
    * The `project init` command initializes a new SQLcl project, setting up the necessary directories and files for managing your database objects and changes.

* **Version Control:**
    * Create a new Git branch for this feature:
        <copy>git checkout -b TICKET-1-Departments</copy> 
    * This creates a new branch named "TICKET-1-Departments" where you will develop and test the "Departments" feature.

* **Project Structure:**
    * SQLcl Projects use a specific folder structure to manage database objects and changes. 
    * Key folders include:
        * **`.dbtools`:** This folder contains project configuration files, filters, and formatting rules.
        * **`src`:** This folder stores exported objects from the database, organized by schema and object type.
        * **`dist`:** This folder is used to store release artifacts generated by the `project stage` and `project release` commands.

### 3.2 Database Changes

* **Unlock the "Departments" Feature:**
    * Locate the relevant code section in the application where the "Departments" feature is currently disabled (e.g., commented out code, placeholders).
    * **Uncomment or modify the code:** Enable the necessary code blocks to activate the "Departments" functionality. This might involve changing variable names, adjusting logic, or removing temporary placeholders.

* **Create the "Departments" Table:**
    * **Option 1: Using SQLcl:**
        * Open an SQLcl session.
        * Write and execute the following SQL statement to create the "Departments" table:
            ```sql
            CREATE TABLE Departments (
                department_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                department_name VARCHAR2(255) NOT NULL
            );
            ```
    * **Option 2: Using OCI (if applicable):**
        * Use your preferred OCI client or tool to connect to the database and execute the same SQL statement.

* **Insert Initial Data:**
    * **Option 1: Using SQLcl:**
        * Execute the following SQL statement to insert some initial data into the "Departments" table:
            ```sql
            INSERT INTO Departments (department_name) VALUES ('Engineering');
            INSERT INTO Departments (department_name) VALUES ('Marketing');
            INSERT INTO Departments (department_name) VALUES ('Sales');
            ```
    * **Option 2: Using OCI (if applicable):**
        * Use your OCI client to execute the necessary INSERT statements.

### 3.3 Exporting Database Changes with SQLcl

* **Export Database Objects:**
    * Execute the following command to export the newly created "Departments" table and any other relevant database objects:
        <copy>project export</copy>
    * This command will analyze the database, identify the specified objects, and generate Liquibase change sets that describe the desired changes.
    * The exported objects will be placed within the `src` folder of your SQLcl project.

### 3.4 Testing the Application

* **Test the Application:** 
    * Restart the application to ensure that the database changes are reflected in the application's behavior.
    * Thoroughly test the application to verify that the "Departments" feature is working as expected. 
    * Check if you can view, add, or modify department information within the application.

### 3.5 Staging and Releasing Changes

* **Stage Changes:**
    * Execute the following command to stage the changes for release:
        <copy>project stage</copy> 
    * This command prepares the staged changes for release by creating a release artifact in the `dist` folder.

* **Commit and Merge Changes:**
    * **Commit your changes:**
        <copy>git add -A</copy> 
        <copy>git commit -m "Added Departments feature"</copy>
    * **Push your changes to the remote repository:**
        <copy>git push origin TICKET-1-Departments</copy>
    * **Create a pull request:** Create a pull request to merge your changes into the main branch.

* **Release Changes:**
    * Once your changes are reviewed and approved, execute the following command to create a release artifact:
        <copy>project release</copy> 
    * This command creates a compressed release artifact that can be easily deployed to other environments.

* **Generate Release Artifact:**
    * The `project gen-artifact` command can be used to create a deployable artifact for your database changes. This artifact can then be easily deployed to different environments.

**In the next section, we will learn how to deploy these changes to the production environment using SQLcl and explore advanced CI/CD concepts.**

This section provides a high-level overview of the steps involved in implementing the "Departments" feature using SQLcl and CI/CD practices. In the following sections, we will delve deeper into each of these steps and explore them in more detail.
