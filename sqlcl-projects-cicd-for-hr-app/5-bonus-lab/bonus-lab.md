# Unveiling the Analytics Engine (Release 3.0)

## Introduction

You’ve just completed the "Departments" feature and deployed it successfully. But wait—it's time for an even bigger challenge: Unveiling the Analytics Engine!

In this bonus lab, you will release version 3 (V3) of the HR application, packed with the game-changing Analytics feature. This new feature will offer insights not only into employee and department data but also provide valuable analytics on attendance and performancereviews, giving you a complete picture of employee engagement and productivity.

**The Challenge**

While the Analytics feature was part of the original vision for the HR application, it wasn’t included in the initial release. Now, MoroccanTech Solutions is ready to take things to the next level by enabling this feature. Your mission is to uncover and activate the hidden Analytics functionality!

![Challenge picture](./images/challenge-pic.png " ")

### **Objectives**

* Enable the Analytics feature
* Release the version 3 of the database for the application

### **Prerequisites**

* Complete successfully the previous labs

**Estimated Workshop Time:** 14 minutes

Bring on the challenge! Let’s crush it!

## Challenge 1: Implement Analytics Page

Before making changes, we need to switch back to the development environment. To do this, update the **.env** file by changing PROD_USER to DEV_USER, ensuring the application connects to the development database.

Now, let's modify the application code to enable the Analytics page.

> **Challenge:** Identify and update the necessary code to bring the Analytics page to life.

<details><summary>**Hint**</summary>
    Remember where we made the change for the Departments page? Go to the same place—you’ll find the required change just below it, similar to what you did for Departments.
</details>

<details><summary>**Solution**</summary>

1. From the app folder, navigate to the pages

    ![Analytics code location](./images/analytics-code-location.png " ")

2. Double click on the pages folder then the 'HRPageContentSwitcher.tsx' file

3. Go to the line 72 where you will do the change

    ![Identify code change](./images/where-to-change-in-code.png " ")

4. Remove the PlaceHolder after return and replace it with '< AnalyticsPage />'

    ![Implement the change](./images/code-change-done.png " ")

5. Refresh the application and go to the Analytics section. It should appear now

    ![Analytics page appearing](./images/analytics-appears.png " ")

>**Note:** If you lost your application window, run it again as you did the first time.

As you can see, only the Employees per Department analytics is working—the others are not. This is because the performancereviews and attendance tables are missing and haven’t been created yet.

</details>

<!--* **Challenge:** Create the necessary database tables (`attendance` and `performancereviews`) to support the "Analytics" feature.
* **Hint:**
        * Use SQLcl to create the tables with appropriate columns and data types.
    ### `attendance` Table

    | Column Name      | Data Type       | Constraints             |
    |------------------|-----------------|------------------------|
    | ATTENDANCE_ID    | NUMBER(38)      | NOT NULL PRIMARY KEY   |
    | EMPLOYEE_ID      | NUMBER(38)      |                        |
    | CHECK_IN         | TIMESTAMP(6)    |                        |
    | CHECK_OUT        | TIMESTAMP(6)    |                        |
    | STATUS           | VARCHAR2(20)    |                        |
    * **`performancereviews` Table

    | Column Name         | Data Type       | Constraints            |
    |----------------------|-----------------|-----------------------|
    | REVIEW_ID           | NUMBER(38)      | NOT NULL PRIMARY KEY   |
    | EMPLOYEE_ID         | NUMBER(38)      |                        |
    | REVIEW_DATE         | DATE            |                        |
    | PERFORMANCE_SCORE   | NUMBER(3,2)     |                        |
    | GOALS_ACHIEVED      | VARCHAR2(255)   |                        |
    | AREAS_IMPROVEMENT   | VARCHAR2(255)   |                        |
    | REVIEWER_ID         | NUMBER(38)      |                        |
    | NEXTREVIEWDATE      | DATE            |                        |

     * Consider adding sample data to the tables to test the analytics functionality. 

    <details>
         <summary>Solution</summary>
    * **Step 1: Connect to DEV Schema**
        * **Using Named Connection:**
                ```sql
                connect <your_named_connection> 
                ```
        * **Using Wallet:**
                ```sql
                SQL> set cloudconfig directory/client_credentials.zip 
                Wallet Password:  **********
                ``` 
                ```sql
                SQL> connect username@servicename
                password
                ```
            * **Refer to the previous lab for detailed instructions on connecting to the database using a wallet.**

        * **Step 2: Create Tables**
            ```sql
            CREATE TABLE attendance (
                ATTENDANCE_ID NUMBER(38) NOT NULL PRIMARY KEY, 
                EMPLOYEE_ID NUMBER(38),
                CHECK_IN TIMESTAMP(6),
                CHECK_OUT TIMESTAMP(6),
                STATUS VARCHAR2(20)
            );

            CREATE TABLE performancereviews (
                REVIEW_ID NUMBER(38) NOT NULL PRIMARY KEY,
                EMPLOYEE_ID NUMBER(38),
                REVIEW_DATE DATE,
                PERFORMANCE_SCORE NUMBER(3,2),
                GOALS_ACHIEVED VARCHAR2(255),
                AREAS_IMPROVEMENT VARCHAR2(255),
                REVIEWER_ID NUMBER(38),
                NEXT_REVIEW_DATE DATE
            );
            ```
            -- Insert sample data into tables
            ```
            INSERT INTO attendance (EMPLOYEE_ID, CHECK_IN, CHECK_OUT, STATUS) VALUES (1, TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2024-07-01 17:00', 'YYYY-MM-DD HH24:MI'), 'Present'); 
            -- Insert more sample data as needed
            ```
        
    </details>-->

## Challenge 2: Apply Database Changes

Your task is to update the database by adding the performancereviews and attendance tables to DEV_USER.

<!-- In this challenge, you will apply new database changes by adding the performancereviews and attendance tables to DEV_USER. -->

> **Challenge:** Create the necessary database tables (`attendance` and `performancereviews`) to support the "Analytics" feature.

<details><summary>**Hint**</summary>

* Use SQLcl to create the tables with appropriate columns and data types.
    * **`attendance` Table**

    | Column Name      | Data Type       | Constraints             |
    |------------------|-----------------|------------------------|
    | ATTENDANCE_ID    | NUMBER(38)      | NOT NULL PRIMARY KEY   |
    | EMPLOYEE_ID      | NUMBER(38)      |                        |
    | CHECK_IN         | TIMESTAMP(6)    |                        |
    | CHECK_OUT        | TIMESTAMP(6)    |                        |
    | STATUS           | VARCHAR2(20)    |                        |
    
    * **`performancereviews` Table**

    | Column Name         | Data Type       | Constraints            |
    |----------------------|-----------------|-----------------------|
    | REVIEW_ID           | NUMBER(38)      | NOT NULL PRIMARY KEY   |
    | EMPLOYEE_ID         | NUMBER(38)      |                        |
    | REVIEW_DATE         | DATE            |                        |
    | PERFORMANCE_SCORE   | NUMBER(3,2)     |                        |
    | GOALS_ACHIEVED      | VARCHAR2(255)   |                        |
    | AREAS_IMPROVEMENT   | VARCHAR2(255)   |                        |
    | REVIEWER_ID         | NUMBER(38)      |                        |
    | NEXTREVIEWDATE      | DATE            |                        |

* Consider adding sample data to the tables to test the analytics functionality.
</details>

<details><summary>**Solution**</summary>

* **Step 1: Connect to DEV_USER**
    * **Using SQLcl:**
            ```sql
                connect DEV_USER/[PASSWORD]
                ```
    * **Using SQL Developer Web:**
    Signin with DEV_USER credentials

* **Step 2: Create Tables**

Copy and past this in the SQLcl or the SQL Developer Web sql worksheet.
            ```sql
            CREATE TABLE attendance (
                ATTENDANCE_ID NUMBER(38) NOT NULL PRIMARY KEY,
                EMPLOYEE_ID NUMBER(38),
                CHECK_IN TIMESTAMP(6),
                CHECK_OUT TIMESTAMP(6),
                STATUS VARCHAR2(20)
            );

            CREATE TABLE performancereviews (
                REVIEW_ID NUMBER(38) NOT NULL PRIMARY KEY,
                EMPLOYEE_ID NUMBER(38),
                REVIEW_DATE DATE,
                PERFORMANCE_SCORE NUMBER(3,2),
                GOALS_ACHIEVED VARCHAR2(255),
                AREAS_IMPROVEMENT VARCHAR2(255),
                REVIEWER_ID NUMBER(38),
                NEXT_REVIEW_DATE DATE
            );
            ```
            -- Insert sample data into tables
            ```
            INSERT INTO attendance (EMPLOYEE_ID, CHECK_IN, CHECK_OUT, STATUS) VALUES (1, TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2024-07-01 17:00', 'YYYY-MM-DD HH24:MI'), 'Present'); 
            -- Insert more sample data as needed
            ```

* **Step 3: Refresh the application**

Refresh the application window to view the Analytics page with the data.

</details>

<!--* **Challenge:** Your goal is to complete and activate the "Analytics" feature by identifying incomplete code sections, resolving placeholders, integrating missing components, and bringing the feature from a fragmented state to full functionality.

    <details> <summary>Hint</summary>
    * Create a new Git branch for the "Analytics" feature.
    * Look for comments within the code that mention or contain "TODO" "UNCOMPLETED" "Analytics," "charts," or similar terms.
    * Search for file or folder names that might contain "analytics" keywords.
    * Utilize your code editor's search functionality to locate relevant code sections.
    </details>
    <details> <summary>Solution</summary>
        * **Example Solution:**
        * check out to your feature branch :
        ```
          git checkout -b TICKET-2-Analytics
        ```
        * Search for files or folders with names like "analytics" or "Charts".
        * Use your code editor's search functionality to find code blocks that are commented out or appear to be incomplete.
        * **Specifically, look for comments like `// TODO: ANALYTICS FEATURE` and lines where placeholder values are used.**
        * look at the screenshots bellow and make the necessary changes to make your code work:
    ![charts](./images/placeholder.png " ")
    in line 73 , delete the place golder component "<PlaceHolder PlaceHolderName={'Analytics'}/>" and replace it with Analytics component <AnalyticsPage>.
    ![charts](./images/charts-files.png " ")
    there's also few changes to do in the charts components files ...
    ![charts](./images/attendanceChart.png " ")
    change the name of the Variable tableName with your new table name : Attendance.
    ![charts](./images/performance-chart.png)
    change the name of the Variable tableName with your new table name : PerformanceReview.

        Great , now run your application to see your changes, and Verify that the displayed analytics data is accurate and reflects the current state of the employee data.
         ```sql
         <copy>
         npm run dev
        </copy>
        ```
    </details>-->


## Challenge 3: Deploy The Database Changes To The Target Database

Our target database in this case is the PROD_USER schema (production database), though it could be any other database.

To deploy changes, we will follow the SQLcl Projects workflow, just like in the previous lab.

> **Challenge:** Apply SQLcl Projects workflow

<details><summary>**Hint**</summary>

1. Deploy the application to production by changing the user in the .env file to PROD_USER.
2. The Analytics page will not work if you refresh and check it, as PROD_USER doesn’t contain the two new tables.
3. In SQLcl, connect as DEV_USER and navigate to the application folder.
4. Create a new branch and check out to it for future changes
5. Export the new objects from DEV_USER.
6. Run the subsequent commands after the export, as in the previous lab, until you generate the artifact.
7. Connect to PROD_USER and run the deploy command to apply the changes.
8. Refresh the application. The Analytics page should work correctly.

<!--1. Deploy the application to production by changing the user in the .env file to PROD_USER
2. The Analytics page will not work now if you refresh and check it cause PROD_USER does't contain the two new tables
3. In SQLcl connect as DEV_USER and be in the application folder
4. Create a new branch and checkout to it for the future changes
5. Export from DEV_USER the new objects
6. Run the other commands that follows export as the previous lab until generating the artifact
7. Connect to PROD_USER and run deploy command to deploy the changes to it
8. Refresh the application. The Analytics page should work fine.-->

    ![Analytics page working](./images/analytics-page-works.png " ")

</details>

<details><summary>**Solution**</summary>
* Commit your changes:
            ```
            git add -A
            git commit -m "Added basic Analytics functionality"
            ```
* Make code changes and commit them:
            ```
            # Make necessary code changes (uncommenting, modifying, etc.)
            git add -A
            git commit -m "Added basic Analytics functionality"
            ```
* Export your database objects:
            ```
            project export -schemas DEV_USER
            ```
* Stage the changes:
            ```
            project stage
            ```
* Merge the "Analytics" branch into the main branch:
            ```
            git checkout main
            git merge TICKET-2-Analytics
            ```
            **Resolve any merge conflicts:** (If necessary)
* Release Changes:
            ```
            project release -version 3.0
            ```
* Generate your New release artifact:
        ```
            project gen-artifact  -v
            ```
* Connect to the PROD_USER:
            ```sql
            connect PROD_USER/[PASSWORD]
            ```
* Deploy to Production:
            ```
            project deploy -file [NameOfYourArtifact].zip
            ```

    ![Analytics page working](./images/analytics-page-works.png " ")

Congratulations, Developer! You've successfully navigated this challenging lab and created a valuable system for MoroccanTech Solutions. By completing the labs , you've demonstrated a strong understanding of database development, version control, and deployment practices. You've also gained valuable experience with SQLcl and its powerful project management capabilities.

This lab has equipped you with the essential skills to effectively develop and deploy database-driven features within a real-world application environment. Keep practicing and exploring new challenges, and continue to enhance your skills as a skilled developer.

</details>

<!--* **Challenge:** Go beyond the current implementation by exploring innovative database objects and advanced analytics capabilities:

    - Create additional tables that could enhance HR analytics
    - Develop database procedures or views to generate complex insights
    - Experiment with different database objects in SQLcl
    - Implement these new features in the frontend application

  <details>
      <summary>Hint</summary>
      * Consider creating tables like:
          - Skills inventory
          - Training and development records
          - Compensation and benefits tracking
      * Explore creating database views that aggregate complex employee data
      * Design stored procedures for advanced analytics calculations
      * Use SQLcl to implement and test your database objects
  </details>
  <details>
      <summary>Solution</summary>
        * **Creative Exploration:**
          * Design and implement additional database objects
          * Experiment with data analysis techniques
          * Integrate new database features into the application
          * Demonstrate innovative approaches to HR analytics
          * Consider using database queries to calculate the required metrics.
          * Utilize charting libraries to visualize the data effectively.
          * Explore options for exporting data to different formats (e.g., CSV, PDF).
  </details>-->

<!--## Challenge 4: Preparing for Release

* **Challenge:** Prepare the "Analytics" feature for release by following proper version control and staging procedures.
    * **Hint:**
        * Make sure you are on your feature branch.
        * Commit your code changes using Git.
        * Export your database objects 
        * Stage the changes using the project stage command.
        * Merge the "Analytics" branch into the main branch.

    <details>
    <summary>Solution</summary>
    - Commit your changes:
            ```
            git add -A
            git commit -m "Added basic Analytics functionality"
            ```
    - Make code changes and commit them:
            ```
            # Make necessary code changes (uncommenting, modifying, etc.)
            git add -A 
            git commit -m "Added basic Analytics functionality"
            ```
    - Export your database objects:
            ```
            project export 
            ```
    - Stage the changes:
            ```
            project stage
            ```
    -   Merge the "Analytics" branch into the main branch:
            ```
            git checkout main
            git merge TICKET-2-Analytics
            ```
            * **Resolve any merge conflicts:** (If necessary)
    </details>-->


<!--## Challenge 5: Creating a Release Artifact

  * **Challenge:** Create a release artifact containing the changes for the "Analytics" feature.
    * **Hint:**
        * Use the `project release` command to generate the release artifact.

    <details>
        <summary>Solution</summary>
        * **Release Changes:**
            ```
            project release -version 3.0
            ``` 
        * ** Generate your New release artifact:**
        ```
            project gen-artifact  -v
            ``` 
    </details>-->

<!--## Challenge 6: Deploying Analytics to Production

* **Challenge:** Deploy the "Analytics" feature to the production environment.
    * **Hint:**
        * **1. Connect to the Production schema:**
            ```sql
            connect <your_named_connection_to_PRODUSER> 
            ```
        * **2. Deploy to Production:** 
            ```
            project deploy -file NameOfyourArtifact.zip
            ``` -->

## Learn More

Click [here](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/24.3/sqcug/introduction.html?utm_source=pocket_shared) for documentation on using SQLcl Projects.

## Acknowledgements

* **Author** - Fatima AOURGA & Abdelilah AIT HAMMOU, Junior Members of The Technical Staff, SQLcl
* **Created By/Date** - Fatima AOURGA, Junior Member of Technical Staff, SQLcl, February 2025