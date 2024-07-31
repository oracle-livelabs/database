# Prepare your environment for the workshop 

## Introduction

This lab provides a step-by-step guide to help you get started with the JSON Duality LiveLab. In this lab, you will create the necessary schema and tables need for the following labs.

In this lab, we will be installing Swingbench, a powerful performance testing tool for Oracle databases. Swingbench allows you to simulate realistic workloads, measure system performance, and evaluate scalability. It assists in load testing, stress testing, and benchmarking Oracle environments, helping you identify bottlenecks, optimize configurations, and ensure the efficiency and reliability of Oracle-based applications. We will focus on the Oracle MovieStreams schema, which creates the required tablespace, users, and tables for this lab.

Estimated Time: 15 minutes

[Lab 1](videohub:1_3rgp8l51)

### Objectives

In this lab, you will:
* Install Swingbench
* Create the schema
* Start up Oracle REST Data Services (ORDS)
* Connect to SQL Developer Web via the browser

### Prerequisites

This lab assumes you have:
* Oracle Database 23ai Free Developer Release installed
* Terminal or console access to the database
* Internet access

## Task 1: Install Swingbench

1. The first step is to open a command prompt. If you are running in a Sandbox environment, click on **Activities** and then select **Terminal**.

  ![Open a new terminal](images/open-terminal.png " ")

2. Next, set your environment. The `oraenv` command will set all the environment variables based on your database. When prompted, type "FREE" for the database name. If you supplied a different database name during installation, use that instead.

    ```
    <copy>
    . oraenv
    </copy>
	```

    ![Set environment](images/oraenv.png " ")


3. Next click [here](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/swingbench15082023_jdk11.zip) to download the latest version of Swingbench.

4. Once the download is complete, open a terminal or command prompt on your computer and navigate to the location where the file was saved.

    ```
    <copy>
    unzip ~/Downloads/swingbench15082023_jdk11.zip -d ~/Downloads
    </copy>
	```
    ![unzip swingbench](images/downloadswing.png " ")

5. Navigate to the directory where Swingbench is installed. If Swingbench is installed in the "swingbench" folder within your home directory, you can use the following command:

    ```
    <copy>
    cd Downloads/swingbench/bin
    </copy>

	```

  ![Change to Swingbench directory](images/swingnav.png " ")

6. Once you are in the "swingbench/bin" directory, run the following command to execute the Movie Stream Install Wizard:

    ```
    <copy>
    ./moviewizard
    </copy>
    ```

    This command starts the Movie Stream Install Wizard, which guides you through the installation and configuration process for the Movie Stream workload.
    ![Connect to the database](images/moviewizard.png " ")

7. When the Movie Stream wizard opens, click **Next** to get started.

8. Make sure the **Create the Movie Stream Schema** box is checked and click **Next**.

    ![Showing the swingbench UI](images/create-schema.png " ")

9. Under the "Connect string" box, copy (Ctrl + V) or type the following:

    ```
    <copy>
    //hol23cfdr.livelabs.oraclevcn.com:1521/FREEPDB1
    </copy>
    ```
    ![Showing the swingbench UI](images/movie-connect.png " ")

11. In the Administrator Password box, copy and paste or type the following password:

    ```
    <copy>
    Welcome123#
    </copy>
    ```
    Once finished press **Next**
    
    ![Showing the swingbench UI](images/movie-pass.png " ")


12. Change the username to **movie** and leave the default password of movie, then click **Next** 

    ![Showing the swingbench UI](images/movie.png " ")

13. Accept the defaults for the "Database Options" page and click **Next**

    ![Showing the swingbench UI](images/default.png " ")

14. Change the size of the benchmark using the "User Defined Scale" option to 0.5 and click **Next**

    ![Showing the swingbench UI](images/movie-size.png " ")

15. Accept the default **Level of Parallelism** at 8 and click **Finish**

    ![Showing the swingbench UI](images/parallelism.png " ")

16. This step may take approximately 1-2 minutes to complete. You can continue to the next section while this process runs in the background.

    ![Showing the swingbench UI](images/completing.png " ")

17. To make this workshop as realistic as possible, let's introduce the business scenario you will be working with - **Oracle MovieStream**.

    ![Logo graphic of Oracle MovieStream](images/moviestream-logo.jpeg)

    * Oracle MovieStream is a fictitious online movie streaming company. Customers log into Oracle MovieStream using their computers, tablets, and phones, where they are presented with a personalized list of movies based on their viewing history. The company is now looking for better, smarter ways to track performance, identify customers for targeted campaigns promoting new services and movies, and improve the streaming platform. The scenarios in this workshop are based on challenges that companies face in their businesses. We hope that the labs and workshops will provide you with insights into how Oracle can help you solve these common everyday business and technical challenges.

    * During this workshop, we will primarily focus on three key tables: `genres`, `movie_details`, and `movies_genre_map`. As we progress through the upcoming labs, we will explore the creation of duality views spanning across these tables. Additionally, we will explore techniques for efficiently adding, updating, and manipulating the underlying data within these tables using the duality views.

## Task 2: Start ORDS

1. Open a new tab in the terminal by selecting **File** and **New Tab** 

    ![Opening a new terminal](images/new-tab.png " ")

2. Now you will need the Movie Schema to finish creating. Once its done, to enable the RESTful services for the new movie schema, sign into SQL*Plus using the newly created movie user. Once logged in, copy the following command into the terminal:


    ```
    <copy>
    sqlplus movie/movie@//localhost:1521/FREEPDB1
    </copy>
    ```
    ![Showing the terminal](images/sql-login.png " ")

3. Run the following command in SQL*Plus:

    ```
    <copy>
    BEGIN
        ORDS.ENABLE_SCHEMA(p_enabled => TRUE, p_schema => 'MOVIE');
        END;
        /
    </copy>
    ```
    ![Showing the terminal](images/ords-enable.png " ")

4. Exit SQL*Plus by running the following command:

    ```
    <copy>
    exit
    </copy>
    ```
    ![Showing the terminal](images/exit1.png " ")

5. To start ORDS, enter the following command in the same command prompt window:

    ```
	<copy>
    ords serve &
    </copy>
	```
    ![Showing the terminal](images/ords-serve.png " ")
    ![Showing the terminal](images/ords-serve-message.png " ")

6. If Google Chrome isnt running, go to **Activities** and then click on the Google Chrome symbol. If a new window doesn't appear, click **Google Chrome** and **New Window** at the top. 

    ![opening a new chrome window](images/google.png " ")
    ![opening a new chrome window](images/new-chrome-window.png " ")


7. Copy and paste the following address into the browser. This is the address for SQL Developer Web on your machine. Note: If you did not start ORDs, ORDs stopped working or you closed that terminal in the previous lab, go back and complete the steps in that lab to start ORDs otherwise it will not be running to login here.

    ```
    <copy>
    http://localhost:8080/ords/sql-developer
    </copy>
    ```

8. Sign in to SQL Developer Web using the movie schema with the username movie and password movie.

    ![Ords login](images/ords-url.png " ")

Congratulations! You have finished the setup for this workshop. You may now **proceed to the next lab** 


## Learn More

* [Introducing Oracle Database 23ai Free – Developer Release](https://blogs.oracle.com/database/post/oracle-database-23c-free)

## Acknowledgements
* **Author** - Killian Lynch, Oracle Database Product Management, Product Manager
* **Contributors** - Dominic Giles, Oracle Database Product Management, Distinguished Product Manager
* **Last Updated By/Date** - Killian Lynch, Oracle Database Product Management, Product Manager, May 2023
