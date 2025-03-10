# Get Started

## Introduction

In this lab, you will configure, and then execute commands to start-up the HR Management application.

You have been provided with access to a Database Actions (*aka* SQL Developer Web), as well as a Jupyter Lab.

<!--Some experience in shell commands, react, JavaScript, and HTML are helpful but not necessary. Although, we've designed this workshop so even the beginner can complete it!-->

![ORDS, SQLcl, Database Actions](images/ords-sqlcl-sqldevweb.png " ")

**Estimated Lab Time:** 10 minutes

### **Objectives**

In this lab, you will:

* Sign in to Database Actions as the `DEV_USER` user <!--* Create your ORDS APIs with the provided scripts-->
* Add your ORDS APIs to your project's files
* Start-up the HR Management react application

### **Prerequisites**

* Access to a LiveLabs-provided sandbox environment
* Access to Database Actions
* Beginner-level experience in javascript, HTML, and Integrated Developer Environments

## Task 1: Get To Know Your Workshop Environment

Before diving into the workshop, take a moment to familiarize yourself with the tools and resources available.

1. Accessing Your Workshop Tools

   You have been provided various URLs. One for accessing Database Actions, and another one for accessing a Jupyter lab. First, navigate to Database Actions using the provided URL. You can find these details by clicking **View Login Info** near the top of the Workshop outline.

    ![View Login info.](images/workshop-login-info.png " ")

2. Workshop Credentials

   You’ve been provided with the necessary details for this workshop:

     * **JupyterLab:** Click the provided URL to access JupyterLab.
     * **ORDS Users:** The list of users we’ll be working with during the workshop.
     * **Password:** A single password used for all ORDS users.
     * **SQL Developer Web (Database Actions):** Click the provided URL to access Database Actions.

    ![Database Actions URI in Lab.](images/reservation-info.png " ")

## Task 2: Sign in Database Actions

1. Click the SQL Developer Web URL in the Reservation information to access it.

   ![Database Actions URI in Lab.](images/reservation-info.png " ")

2. Several users have been created for you, including a new `DEV_USER` user. Its schema has already been REST-enabled, meaning you will be able to Sign in to Database Actions.

    > **Note:** Depending on your lab configuration, you may be redirected to a SQL Developer Web Sign-in screen rather than the Oracle REST Data Services "landing page." In such cases, simply Sign in with the `DEV_USER` user's credentials.

    To Sign in, click the <button type="button" style="pointer-events: none;">Go</button> button under the SQL Developer Web card.

    ![Navigating to SQL Developer Web.](images/ords-signin.png " ")

    Once the Sign-in screen appears, enter the following credentials, and click the <button type="button" style="pointer-events: none;">Sign-in</button> button:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Username: `DEV_USER`
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Password: `[Can be found in your Reservation details - see image in Step 1 for reference]`

   >**Note:** If you're having trouble connecting to DEV\_USER, log in with Admin first. Then, open the hamburger menu, go to Database Users, and locate the DEV\_USER card in the bottom right. Click the icon to open the link, which will take you to a sign-in page where you can log in as DEV\_USER.
   Alternatively, simply modify the URL to include DEV\_USER in the path.

3. The Database Actions Launchpad will appear. Navigate to the `Development` category, then click `SQL`. A blank SQL Worksheet will appear.

   ![A new SQL Worksheet.](images/sql-database-actions.png " ")

      > **NOTE:** If this is your first time visiting the SQL Worksheet, a guided tour will appear. You may continue with the tour, or click the <button type="button" style="pointer-events: none;">X</button> (as seen in the image) to exit the tour.

4. You'll notice an `Employees` table has already been created for you. This table has also been pre-populated with DEV_USER data.

   To view a sample of the table's data<span class="fa fa-file-play" aria-hidden="true"></span> copy and paste the following SQL statement into the SQL Worksheet and click then `Run Statement` icon.

      ```sql
      <copy>
      SELECT * FROM EMPLOYEES FETCH FIRST 5 ROWS ONLY;
      </copy>
      ```

   You will see results similar to the following image:

   ![Reviewing the results.](images/run-select-from-employees.png " ")

5. You may notice the varied data types in this table. To take a closer look at how this `DEV_USER` table is structured, right-click on the `DEV_USER` table, then select `Edit...`. When the `Table Properties` slider appears, click `DDL`, then select the `Create` tab.  

   Note the data types:

   ![Reviewing the DEV_USER table properties.](images/show-employees-ddl.png " ")

      > **NOTE:** ORDS APIs will be able to handle all of these various data types and send them to your application.

6. Once you are satisfied, return to the Reservation information for this workshop.

   ![View Login info.](images/workshop-login-info.png " ")

## Task 3: Open Jupyter lab

1. Using the URL you were provided, log in to your Jupyter lab. *It is recommended you open the Juptyer Lab in a new tab or window.*

   ![Using the password from previous task.](images/jupyter-lab-uri.png " ")

   Use the same password from the previous task.

   ![Login to Jupyter lab.](images/jupyter-pwd.png " ")
  
2. Once logged in, you may see several directories. Navigate (i.e., a double or single click on the directory) to the `workshops` directory, then the `sqlcl-projects-react-app` directory.

   ![Navigating to SQLcl Projects react app directory.](images/go-to-app-folder.png " ")

<!--3. Next, navigate to the `scripts` directory, then open the `DEV_USERstream_resource_module_definitions.sql` file.  

    > **TIP:** You may open a file by clicking on the file name *or* right-clicking a file and choose to "Open with > Editor".  
    >
    > ![Option to right-click and open with editor.](images/right-click-file-for-editor-to-view-python-file.png " " )

   This file contains the definitions for your Resource Module, Templates, and Handlers, which are your ORDS APIs.  

   ![Reviewing the resource definitions file.](images/scripts-then-DEV_USERstream-sql.png " ")
   *Navigate to `sqlcl-projects-react-app` then `scripts` then `DEV_USERstream_resource_module_definitions.sql`*

4. Select all contents and copy the contents to your clipboard. Then, return to the SQL Worksheet.

    > **TIP:** Refer to Task 1, Step 1 for keyboard shortcuts for copy and paste actions.

   ![Copying contents of the DEV_USERstream module.](images/the-DEV_USERstream-resource-module.png " ")-->

## Task 4: Check Enabled ORDS Endpoints

<!--1. Navigate to the SQL Worksheet. Then paste (easily done with keyboard shortcuts) the contents of the `users.sql` file to the SQL Worksheet.
  
2. Click the `Run Script` icon. Upon completion, a `PL/SQL procedure successfully completed` message will appear in the `Script Output` tab.-->

1. We created for you the ORDS APIs for the `DEV_USER` user. To review the Resource Module, its Resource Templates and Resource Handlers, navigate to the REST Workshop.

    ![Employees table enabled icon](images/employees-rest-enabled-icon.png " ")

   Click the hamburger menu from the top of Database Actions, then click REST.  

      ![Navigating to the REST Workshop.](images/hamburger-rest.png " ")

2. You'll notice a single AUTOREST in the Workshop's Object panel. Click it.

   ![Navigating to the DEV_USERstream resource module.](images/autorest.png " ")

<!--5. Next, copy this URI's to your clipboard. In a few moments, you will return to the Jupyter lab to input this into the application code.

   ![Adding the ORDS URIs to the clipboard](images/copy-rest.png " ")-->

## Task 5: Prepare Your Application Environment Variables

In this task, you will navigate back to JupyterLab and locate the `sqlcl-projects-react-app` directory once again.

Next, you will modify the .env file, which is located in your application's root directory (`sqlcl-projects-react-app`). This file contains essential configuration variables required at runtime.

   >**Note:** The .env file is hidden by default because filenames that begin with a dot (.) are not displayed in the folder structure.

   Click on the triangle icon or **More** below for more insights.

   <details><summary>**More**</summary>

   Files and folders that start with a dot (.) in a computer system (especially in Linux, macOS, and other Unix-like operating systems) are called hidden files or dotfiles. For example **.gitconfig** file that stores settings for Git.

   **What Are They?**
      * These files and folders are not shown by default when you list files in a directory.
      * They are often used to store settings, configurations, and user preferences for different programs.

   **How to See Dotfiles?**

   By default, these files are hidden so you cannot see them explicitly in between your files or directories, but you can view them using:
            ```sh
         <copy>
            ls -la
         </copy>
         ```
   Otherwise, enable "Show hidden files" in File Explorer settings.

   **Why Are They Hidden?**
      * To keep the file system clean by hiding unnecessary details from users.
      * To prevent accidental modification of important configuration files.

   </details></br>

1. Open the terminal
   ![Open terminal](images/open-the-terminal.png " ")
      >**Tip:** You can reduce the font size by pressing **Ctrl + Minus (-)** on Windows/Linux or **Command (⌘) + Minus (-)** on Mac.

2. Edit the `.env` file with:
      ```sql
      <copy>
         vi .env
      </copy>
      ```
      ![Open .env file](images/vi-env.png " ")

3. Press Esc + I to enter insert mode.

4. Navigate to the placeholders and enter the variables.

5. Add the following variables, replacing placeholders with actual values:

      ```text
     VITE_BASE_URL=your_oci_url
     VITE_DB_USERNAME=DEV_USER
      ```

     * `VITE_BASE_URL`: This variable stores the base URL for your ORDS REST service endpoint.

     * `VITE_DB_USERNAME`: This variable stores the username for your development database user. Ensure this username matches the one you configured in the previous lab.

     ![Open the environment variable file](images/env-file-opened.png " ")

      >**Note:** In a React app using Vite, the **VITE_** prefix in environment variables is a Vite requirement to expose them to your front-end code.

      <details><summary>**More**</summary>

      Vite is a fast modern build tool and development server for JavaScript frameworks like React, Vue. It improves app performance with instant reloading and optimized production builds.

      **Explanation of VITE_ in .env**

      Vite automatically loads environment variables from a .env file only if they start with VITE_. This is a security measure to prevent unintended exposure of sensitive backend credentials.
      </details>

6. Press Esc, then type :wq to save and exit.

   > **Note:** This should be in the form of: `http://Your Lab's IP:Your Lab's Port Number/ords/DEV_USER`. Make sure you double-quote the URI; as can be seen in the image below.

## Task 6: Start Your React Application

1. From the Jupyter Launcher, open a new Terminal.

   ![Launching a new terminal.](images/launch-terminal.png " ")

   > **Note:** If a new Launcher window is not present, you can click the Blue Box (the box with the `+` inside) to open a new Launcher. Then you may open a new Terminal.

2. Verify you are in the correct directory by:

    ![Run the application](images/print-working-dir.png " ")

    >**Tip:** You can clear your terminal screen using **clear** command.
    ```sh
      <copy>clear</copy>
      ```

3. Next, issue the following command:

      ```sh
      <copy>npm run dev</copy>
      ```

    ![Run the application](images/npm-run-dev.png " ")
    *The React development server will start up.*

4. Your application will be available on port `5000`. However, you will need to open the application in a new tab. Modify the URL, so you are using the one provided to you for this lab *plus* port `5000`.  

   ![Workshop lab IP address.](images/copy-correct-portion-of-url-for-sample-app.png " ")  

   ![Navigating to the correct address plus port 5000.](images/your-virtual-labs-uri-for-app.png " ")
   *Open in a new tab or window.*

5. Navigate to the new tab and combine the lab's URI with port `5000`. Accept any warnings and your application will load.

   ![Navigating to your application.](images/secure-site-not-available-warning.png " ")

6. The HR application will load. Scroll right left or up down to see all the infos.

   ![HR application up and running.](images/application-up-and-running.png " ")

   ![Light mode vs dark mode](images/light-vs-dark-mode.png " ")

   ![Update records page](images/update-records-page.png " ")

   ![Departments page](images/departments-page.png " ")

<!--Oh, the departments page is missing! That's what will be the subject of the next lab. Let's jump to the next lab to implement this new feature. You may now [proceed to the next lab](#next).-->

<!--Oh no, the departments page is missing! But don’t worry—that’s exactly what we’ll tackle next. Get ready to dive into the [next lab](#next) and bring this feature to life!-->

<!--Wait… where’s the departments page? Looks like we’ve got some work to do! Jump into the [next lab](#next) and let’s unlock this new feature together!-->

Uh-oh! The departments page is missing! But here’s your chance to build it. Let’s dive into the [next lab](#next) and bring this feature to life!

## Learn More

* [Oracle REST Data Services (ORDS) Doc](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/24.4/orddg/introduction-to-Oracle-REST-Data-Services.html)
* [Oracle Database Actions (SQL Developer Web) Doc](https://docs.oracle.com/en/database/oracle/sql-developer-web/sdwad/sql-developer-web.html)
* [Vite guide](https://vite.dev/guide/)

## Acknowledgements

* **Author** - Fatima AOURGA & Abdelilah AIT HAMMOU, Junior Members of The Technical Staff, SQLcl
* **Created By/Date** - Fatima AOURGA, Junior Member of Technical Staff, SQLcl, February 2025