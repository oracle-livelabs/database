# Pluggable Database for Development Agility

## Introduction
In this lab you will assume the role of a development team member, and you will leverage Oracle Multitenant to perform tasks similar to what might be performed in a development and testing role.  The tasks in this lab include:

- Creating your pluggable database (PDB) in a matter of seconds.
- Unplugging your database into a portable archive that could later be plugged in the same CDB or another CDB.
- Plug your unplugged database into a different CDB. 
- Creating copies of your database using PDB cloning.
- Cloning your "production" PDB to a "test" PDB to use as a master copy for the test/development teams.
- Creating thin "snapshot" copies of the test master for use by the test/development teams.

Estimated Time to Complete This Workshop: 90 minutes


### Prerequisites

This lab assumes you have:
- A Free Tier or paid OCI account, or that you are running this lab in a LiveLabs OCI sandbox
- Completed the following labs:
    - Lab: Prepare Setup (*Free Tier* and *Paid Tenancies* only)
    - Lab: Environment Setup

In the following labs, instead of SQL\*Plus you will use **Oracle SQL Developer Command Line (SQLcl)**.  Oracle **SQLcl** is the modern, command line interface to the Database. **SQLcl** has many key features that add to the value of the utility, including command history, in-line editing, auto-complete using the TAB key and more. You can learn more about **SQLcl** [at the Oracle SQLcl website](https://www.oracle.com/database/technologies/appdev/sqlcl.html).

If you accidentally exit the SQLcl client during a lab exercise, the client can be launched using the command **sql /nolog** .

**NOTE:** *When doing Copy/Paste using the convenient* **Copy** *function used throughout the guide, you must hit the* **ENTER** *key after pasting. Otherwise the last line will remain in the buffer until you hit* **ENTER**!

**Please run all workshop tasks in the order in which they appear in this guide.**

## Task 1: Log in and create the application database

In this first task, you will create and explore a new pluggable database **HRAPPDB** in the container database **CDBTEST**.  Typically, the database administrators would provide the developers with the appropriate privileges to allow self-service database provisioning, cloning, de-provisioning and other tasks that DevOps requires.  For the sake of simplicity, you will use the database superuser privilege SYSDBA to perform many of these tasks throughout this workshop. 


1.  Connect to **CDBTEST** using SQLcl. The database **CDBTEST** is a container database, or CDB.  The CDB contains the root of the database, and is also associated with the database memory (SGA, PGA, etc.) and background processes on the system that are part of the Oracle Database instance.

    ```
    <copy>
    sql sys/Oracle_4U@localhost:1521/CDBTEST as sysdba
    </copy>
    ```

    
    ![Output shows the SQLcl connection to CDBTEST container database. ](./images/task1.1-connectcdbtest.png " ")

2. It is common for application development teams to have to wait for a new database when they need one.  The process might be to submit a formal request for a new database, wait for approval, and then wait some more while an environment and database are provisioned.  Depending on the organization and the available infrastructure, that's a process that could take hours, days, or maybe even longer!  However, in a modern, data-driven environment, developers need the ability to quickly create and manage data stores in order to keep pace with rapidly evolving business needs.  Oracle Multitenant makes it easy to enable a "self-service" database environment for the development team.  Not only is database creation self-service and easy, it is also incredibly fast to stand up a new Oracle Database. 

    In this task, you'll examine the container database **CDBTEST** by listing the pluggable databases already in the container; since this is a new CDB the only database plugged into it is the SEED database.  You will create the pluggable database **HRAPPDB**.  Note that the database is created and ready for use in a matter of seconds.

    ```
    <copy>
    show pdbs
    </copy>
    ```

    ```
    <copy>
    set timing on
    create pluggable database HRAPPDB admin user PDB_Admin identified by Oracle_4U;
    set timing off

    alter pluggable database HRAPPDB open;
    alter pluggable database HRAPPDB save state; /* The "save state" command will enable the PDB to open automatically with the CDB */
    show pdbs
    </copy>
    ```

    ![New pluggable database HRAPPDB is created in around 10 seconds!](./images/task1.2-createhrappdb.png " ")


2. Change your SQLcl session to point to the database you just created, **HRAPPDB**.  Then you will grant privileges to the database user **PDB\_ADMIN**. You will leverage user PDB_ADMIN's privileges later on in this workshop.

    ```
    <copy>
    alter session set container = HRAPPDB;

    grant DBA to PDB_ADMIN;
    grant CREATE PLUGGABLE DATABASE to PDB_ADMIN;  
    
    create bigfile tablespace USERS;
        
    alter database default tablespace USERS;
    
    exit

    </copy>
    ```
    ![Grants are issued and USERS tablespace is created.](./images/task1.3-grantpdbadminprivs.png " ")
    
3. For this workshop, you'll use the Oracle HR Sample Schema.  So, you've exited SQLcl to run some OS commands to download and then install the sample schema into the **HRAPPDB** PDB using SQL*Plus.
    ```
    <copy>
    cd /home/oracle
    wget -O db-sample-schemas.zip    https://github.com/oracle-samples/db-sample-schemas/archive/refs/tags/v21.1.zip
    unzip -o db-sample-schemas.zip
    cd db-sample-schemas-21.1
    perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat
    ls
    
    </copy>
    ```
    ![Database sample schemas are downloaded and unzipped.](./images/task1.3-downloadsampleschemahr.png " ")
    
    ```
    <copy>
    cd human_resources

    sqlplus sys/Oracle_4U@localhost:1521/hrappdb as sysdba

    @hr_main Oracle_4U USERS TEMP Oracle_4U /home/oracle/logs/ localhost:1521/hrappdb
    
    </copy>
    ```

     ![Database sample schemas are downloaded and the HR demo schema is loaded.](./images/task1.3-installsampleschemahr.png " ")


4. Launch SQLcl and connect as the database user **HR** to **HRAPPDB**, and verify that the sample schema objects have been created.


    ```
    <copy>
    exit
    cd /home/oracle 
    sql hr/Oracle_4U@localhost:1521/HRAPPDB
    </copy>
    ```

    ```
    <copy>
    select object_type, count(*) from user_objects group by object_type;

    </copy>
    ```

   ![The output shows a summary of schema HR's objects.](./images/task1.4-hrobjectcounts.png " ")

5. Connect again in SQLcl as **SYS** to the container database **CDBTEST** and view the tablespaces and datafiles created, plus the container (PDB or CDB) to which each datafile belongs.

    ```
    <copy>
    connect sys/Oracle_4U@localhost:1521/CDBTEST as sysdba

    with Containers as (
      select PDB_ID Con_ID, PDB_Name Con_Name from DBA_PDBs
      union
      select 1 Con_ID, 'CDB$ROOT' Con_Name from Dual)
    select
      Con_ID,
      Con_Name "Con_Name",
      Tablespace_Name "T'space_Name",
      File_Name "File_Name"
    from CDB_Data_Files inner join Containers using (Con_ID)
    union
    select
      Con_ID,
      Con_Name "Con_Name",
      Tablespace_Name "T'space_Name",   
      File_Name "File_Name"
    from CDB_Temp_Files inner join Containers using (Con_ID)
    order by 1, 3
    /
    </copy>
    ```

    ![Datafiles for HRAPPDB are located under the CDB datafiles, in a sub-folder named with the PDBs UUID.](./images/task1.5-viewdbfiles.png " ")

## Task 2: Unplug your PDB from the Container Database
A capability of Oracle Multitenant that adds to development agility is the ability to unplug a database from a CDB, and then plug it in elsewhere.  Unplugging a database into a PDB Archive creates a portable collection of everything the makes up the database; it's easy to share that PDB archive with others, and that archive can then be plugged in to other Oracle container databases (CDBs).  

Let's assume that you have completed your initial development work on the database **HRAPPDB** and now you want to share it with other teams.  These teams want to perform testing and make additional changes to the database, and they want to do so in their own database environments.   To accomplish this, you will unplug the PDB into an archive, and then make that archive available to others.

You should still be connected to the SQLcl client and see a "SQL>" prompt.  If not, enter the command **sql /nolog** to start the SQLcl client.

First, you'll unplug **HRAPPDB** from **CDBTEST** into a ".pdb" compressed archive.


1. While still in the SQLcl client, connect to the container **CDBTEST** as the superuser SYSDBA.

    ```
    <copy>connect sys/Oracle_4U@localhost:1521/CDBTEST as sysdba</copy>
    ```

2. A PDB must first be closed before it can be unplugged.  Connect as SYSDBA and close the pluggable database **HRAPPDB**.  Then, unplug **HRAPPDB** from **CDBTEST**.  

    ```
    <copy>
    show pdbs
    alter pluggable database HRAPPDB close immediate;
    </copy>
    ```

    ```
    <copy>
    alter pluggable database HRAPPDB
    unplug into '/u01/app/oracle/archive/HRAPPDB.pdb';
    </copy>
    ```


   ![The PDB HRAPPDB is closed and unlpugged into a ".pdb" archive file.](./images/task2.2-unplughrappdb.png " ")

3. After unplugging the database, you will cleanup the container database by dropping all references to the unplugged PDB.  

    ```
    <copy>
    show pdbs
    drop pluggable database HRAPPDB including datafiles;
    show pdbs
    </copy>
    ```

   ![The unplugged PDB shows as still in MOUNTED status until it is dropped.](./images/task2.3-drophrappdb.png " ")

4. Now, query the datafiles that are part of **CDBTEST**.  You can see in the results that the datafiles for **HRAPPDB** are no longer part of the container database.
    
    ```
    <copy>
    with Containers as (
      select PDB_ID Con_ID, PDB_Name Con_Name from DBA_PDBs
      union
      select 1 Con_ID, 'CDB$ROOT' Con_Name from Dual)
    select
      Con_ID,
      Con_Name "Con_Name",
      Tablespace_Name "T'space_Name",
      File_Name "File_Name"
    from CDB_Data_Files inner join Containers using (Con_ID)
    union
    select
      Con_ID,
      Con_Name "Con_Name",
      Tablespace_Name "T'space_Name",
      File_Name "File_Name"
    from CDB_Temp_Files inner join Containers using (Con_ID)
    order by 1, 3
    /
    </copy>
    ```

    ![The datafiles associated with HRAPPDB are no longer present in the CDB](./images/task2.4-cdbtestdbfiles.png " ")

5. The unplugged PDB archive has been stored on the local filesystem.  It contains the entire pluggable database in a compressed format. This makes it easy to share the unplugged PDB with other teams, partners, and/or customers.  This file can be used by others and plugged into their Oracle container databases.  When plugging a PDB into a container database, there are some restrictions regarding the CDB into which the PDB will be plugged in, including: 

    - The CDB must be at least at the same release and patch level as the source.
    - The CDB can be on an OS that is different from that of the source CDB, but the OS has to be the same endian format.
    - The database options installed on the source CDB must be the same as, or a subset of, the database options installed on the target CDB.

  

## Task 3: Plug the unplugged database HRAPPDB into the CDB
In this task, you will connect to container database, **CDBPROD**, and plug the archived PDB **HRAPPDB** into this CDB. 

   You should still be connected to the SQLcl client and see a "SQL>" prompt.  If not, enter the command **sql /nolog** to start the SQLcl client.

1. In the SQLcl client, connect to the container database **CDBPROD** as database superuser SYS as SYSDBA.
    ```
    <copy>
    connect sys/Oracle_4U@localhost:1521/CDBPROD as sysdba
    </copy>
    ```
    ```
    <copy>
    show pdbs
    </copy>
    ```

    ![Container CDBPROD only contains the $SEED database and no other PDBs.](./images/task3.1-connectcdbprod.png " ")

2. Check the compatibility of the unplugged **HRAPPDB** with **CDBPROD**.  If there are no errors output from the PL/SQL block then the PDB is compatible with the CDB, so you should be able to plug-in the PDB without issue.

    ```
    <copy>
    begin
      if not
        Sys.DBMS_PDB.Check_Plug_Compatibility
        ('/u01/app/oracle/archive/HRAPPDB.pdb')
      then
        Raise_Application_Error(-20000, 'Incompatible');
      end if;
    end;
    /
    </copy>
    ```

    ![The PDB plug-in compatibility check succeeds with no errors.](./images/task3.2-pdbcompatible.png " ")

3. Plug the database **HRAPPDB** into container database **CDBPROD**, using the name **HRAPP** for the PDB.   

    ```
    <copy>
    create pluggable database HRAPP
    using '/u01/app/oracle/archive/HRAPPDB.pdb';
    </copy>
    ```

    ```
    <copy>
    alter pluggable database HRAPP open;
    alter pluggable database HRAPP save state;
    show pdbs
    </copy>
    ```

    ![The PDB archive is now plugged in as database HRAPP and is in OPEN status.](./images/task3.3-pluginhrapp.png " ")

4. The newly plugged-in database has the same objects, data, local database users and permissions as it did at the time it was unplugged.  Log into the new database using the previously-created **PDBADMIN** credentials, and observe that the table and data you created in the **HRAPPDB** pluggable database are present in the PDB that was created using the archive.

    ```
    <copy>
    connect hr/Oracle_4U@localhost:1521/hrapp
    select object_type, count(*) from user_objects group by object_type;
    </copy>
    ```

    ![The SQL SELECT statement shows that the HR user owns the same objects as when it did when it was previously unplugged. ](./images/task3.4-appdbselect.png " ")



## Task 4: PDB Cloning
The ability to unplug, move, and plug in a database makes it easy to move databases around as needed.  However, Oracle Multitenant also provides an easy way to create copies, or clones, of your databases while they are running and servicing applications and users.  As long as you have the appropriate database privileges, PDB cloning is accomplished using a single SQL statement.  The cloning operation can be performed when the source database is open or closed, so there is complete freedom to create PDB clones as you need them.  The PDB clones can be created in the same CDB, or you can clone to a different CDB on the same host, to a CDB on a different host, and you can even clone to a CDB in the cloud - each time just using a single SQL statement to perform the cloning operation.   

In this task, you will clone your running pluggable database to a new PDB located in the same container database, CDBPROD.  

You should still be connected to the SQLcl client and see a "SQL>" prompt.  If not, enter the command **sql /nolog** to start the SQLcl client.


Clone the pluggable database **HRAPP** to a new PDB named **HRAPP2**.
    
1. First, connect to the **HRAPP** database and verify some information about the **HR** schema.  You will verify later on that the same output is shown for the PDB clone that you will create. 

    ```
    <copy>
    connect hr/Oracle_4U@localhost:1521/hrapp 
    select table_name, num_rows from user_tables order by 1;
    </copy>
    ```

    ![User HR owns 7 database tables, each containing multiple rows of data.](./images/task4.1-hrapptablerows.png " ")

2. Connect to the container **CDBPROD**.

    ```
    <copy>
    connect sys/Oracle_4U@localhost:1521/CDBPROD as sysdba
    </copy>
    ```

3. Create pluggable database **HRAPP2** as a clone of pluggable database **HRAPP**.

    ```
    <copy>
    show pdbs

    create pluggable database HRAPP2 from HRAPP;
    alter pluggable database HRAPP2 open;
    show pdbs
    </copy>
    ```
    ![The pluggable database HRAPP is successfully cloned as PDB HRAPP2.](./images/task4.3-clonehrapp.png " ")

4. Connect to the new PDB **HRAPP2**.  Since this is an exact copy of the PDB **HRAPP**, you can connect with the credentials for user HR and check the tables and row counts; it's an exact duplicate of the original **HRAPP** database.


    ```
    <copy>
    connect hr/Oracle_4U@localhost:1521/hrapp2
    select table_name, num_rows from user_tables order by 1;
    </copy>
    ```
   ![The same tables and row counts exist for the HR user in the cloned HRAPP2 database.](./images/task4.4-hrapp2tabrows.png " ")

## Task 5: Clone the HRAPP database to the TEST database instance.

In the previous step, you cloned your HRAPP database to another database in the same container database.  What if you wanted to clone the database into a different CDB?  This alternate CDB could be on a different host, and maybe located in a different data center or in the cloud.  Oracle Multitenant makes it easy to clone the database between different environments with just a single SQL statement.  

PDB cloning from one CDB to another can be accomplished using a database link.  This database link must connect to the source PDB, and the database link must connect as a user that has the CREATE PLUGGABLE DATABASE system privilege.  You may remember that you granted the CREATE PLUGGABLE DATABASE to user PDB_ADMIN in your database.  You will create a database link from **CDBTEST** to the **HRAPP** PDB so that you can clone the remotely.

You should still be connected to the SQLcl client and see a "SQL>" prompt.  If not, enter the command **sql /nolog** to re-start the SQLcl client.

1. Connect to the **CDBTEST** container database.

    ```
    <copy>
    connect sys/Oracle_4U@localhost:1521/CDBTEST as sysdba
    </copy>
    ```

2. Create a database link named **hr_prod** from CDBTEST to the HRAPP database that is running in the CDBPROD container database.

    ```
    <copy>
    drop database link hr_prod;
    create database link hr_prod connect to pdb_admin identified by Oracle_4U using 'localhost:1521/hrapp';
    </copy>
    ```
    ![PDB HRTEST is successfully cloned from PDB HRAPP at CDBPROD and opened.](./images/task5.2-hrtestlink.png " ")

3. Create a new database **HRTEST** in the CDBTEST container database by cloning the **HRAPP** PDB that is plugged in to the CDBPROD container database.

    ```
    <copy>
    show pdbs
    create pluggable database HRTEST from HRAPP@hr_prod;
    alter pluggable database HRTEST open;
    show pdbs
    </copy>
    ```
    ![PDB HRTEST is successfully cloned from PDB HRAPP at CDBPROD and opened.](./images/task5.3-hrtest.png " ")

4. Connect to the newly-created HRTEST PDB and verify that database schema HR's exist - of course they do because this PDB is an exact clone of the source **HRAPP** database.

    ```
    <copy>
    connect hr/Oracle_4U@localhost:1521/hrtest

    select table_name, num_rows from user_tables order by 1;
    </copy>
    ```
   ![A query of user_tables by user HR in PDB HRTEST returns the exact output as the same query against the source HRAPP PDB.](./images/task5.4-hrtestrows.png " ")

## Task 6: Create a refreshable clone of the production HRAPP database, making it easy to update the test database with the latest data from production
In the previous task, you cloned a PDB from the PROD to the TEST environment.  Since our example database is small, this copy created quickly. However, what if the source database was much larger, maybe a terabyte or more? What if the requirement was to have a fresh clone weekly? When dealing with larger databases, those requirements result in a large amount of data having to flow across the network, and a longer time needed for the refreshes to complete. Oracle Multitenant solves these challenges with refreshable PDBs. Refreshable PDB clones allow the copy to be updated with only the database changes that have taken place since the previous copy was done. Typically, this would mean only a fraction of the source data needs to be copied during each refresh. 
    
In this task, you will create a refreshable "test master" PDB named **HRTESTMASTER** which will be used to support test and development team activity.

You should still be connected to the SQLcl client and see a "SQL>" prompt.  If not, enter the command **sql /nolog** to start the SQLcl client.


1. As you did in the previous lab task, you'll create a clone of the product HRAPP database, this time making that clone refreshable on-demand.  Connect to **CDBTEST** in SQLcl as superuser SYSDBA.
    
    
    ```
    <copy>
    connect sys/Oracle_4U@localhost:1521/CDBTEST as sysdba 
    </copy>
    ```

2. Create the test master database as a refreshable clone from the HRAPP production database.  Since the new database is a refreshable PDB clone, it can only be opened read-only.

    ```
    <copy>
    show pdbs
    create pluggable database HRTESTMASTER from HRAPP@hr_prod refresh mode manual;
    alter pluggable database HRTESTMASTER open read only;
    show pdbs
    </copy>
    ```
    ![Refreshable PDB HRTESTMASTER is successfully created and opened in READ ONLY mode.](./images/task6.2-hrtestmaster.png " ")

3. Connect to the production **HRAPP** database as user HR, and insert a couple of new rows into the JOBS table.
    
    ```
    <copy>
    connect hr/Oracle_4U@localhost:1521/hrapp
    
    select count(*) from jobs;

    insert into jobs values ('MK_ANALYST', 'Marketing Analyst',7000,11000);
    insert into jobs values ('IT_DATASCI','Data Scientist',8000,15000);
    commit;

    select count(*) from jobs;
        
    </copy>
    ```
    ![Two rows are inserted into the HR.JOBS table, for a total of 21 rows in the table.](./images/task6.3-hrjobsupdate.png " ")
    
4. Connect to the **HRTESTMASTER** database and count the rows in the HR.JOBS table: the two newest rows are not there...yet.

    ```
    <copy> 
    connect hr/Oracle_4U@localhost:1521/hrtestmaster
    select count(*) from jobs;
    </copy>
    ```
    ![The row count from the HR.JOBS table in the HRTESTMASTER database is 19 rows.](./images/task6.4-hrjobsnotupdatedtest.png " ")

5. Update the test master database by executing a PDB REFRESH and pulling the changes from the HRAPP source database. The HRTESTMASTER database must be closed prior to the refresh of the PDB.

    ```
    <copy>
    connect sys/Oracle_4U@localhost:1521/CDBTEST as sysdba
    alter pluggable database HRTESTMASTER close immediate;
    alter pluggable database HRTESTMASTER refresh;
    alter pluggable database HRTESTMASTER open read only;
    connect hr/Oracle_4U@localhost:1521/hrtestmaster
    select count(*) from jobs;
    </copy>
    ```
    Note that the additional rows in the JOBS table are now in the HRTESTMASTER database.
    
    ![The HRTESTMASTER PDB is refreshed and opened in READ ONLY mode.  A row count from HR.JOBS now shows 21 rows.](./images/task6.5-refreshedtestmaster.png " ")

## Task 7: Create multiple, thin copies of the Test Master refreshable pdb to support test and development teams
In the previous task, you created a refreshable copy of the production HRAPP database.  By rule, a refreshable PDB can only be opened read-only.  So, how is this read-only database useful to testing and development teams that want to work with that latest data from production?  As you've seen in earlier tasks, it is easy to create PDB copies using the "CREATE PLUGGABLE DATABASE..." SQL statement.  In this lab, the example databases are small so making full copies takes little time, and little disk space.  So you could easily create full clones of the **HRTESTMASTER** PDB for any development or testing team that needed their own copy.  However, if the **HRTESTMASTER** database was a very large database, terabytes in size or more, making full copies could take a long time and consume a large amount disk space - so it's not very practical to do so.   Oracle Multitenant offers a solution here, also: "thin", copy-on-write clones known as PDB Snapshot Copies.
In this task, you will create thin copies of **HRTESTMASTER** for the development and testing teams.

You should still be connected to the SQLcl client and see a "SQL>" prompt.  If not, enter the command **sql /nolog** to start the SQLcl client.

1. Connect to **CDBTEST** in SQLcl as supersuser SYSDBA.
    
    
    ```
    <copy>
    connect sys/Oracle_4U@localhost:1521/CDBTEST as sysdba
    </copy>
    ```

2. The test teams need their own copies because they want to modify the database and the data within as part of their functional testing.  You can provide these teams with what they need by creating PDB snapshot copies that are thin, copy-on-write clones of the master.  Each of the snapshot copy PDBs will be read-write, and will be a fraction of the size of the master copy.  In this step, you will create 3 PDB snapshot copies, one for each of the testing teams.  PDB snapshot copies will work on a standard file system as long as the database parameter CLONEDB=TRUE.

    ```
    <copy>
    create pluggable database HRAPPTEST1 from HRTESTMASTER snapshot copy;
    create pluggable database HRAPPTEST2 from HRTESTMASTER snapshot copy;
    create pluggable database HRAPPTEST3 from HRTESTMASTER snapshot copy;

    alter pluggable database HRAPPTEST1 open;
    alter pluggable database HRAPPTEST2 open;
    alter pluggable database HRAPPTEST3 open;

    show pdbs
    </copy>
    ```
   
    ![The three PDB snapshot copy databases are created from the HRTESTMASTER database.](./images/task7.2-testsnapclones.png " ")

3. Now use SQL to generate OS commands that you can use to demonstrate that the HRAPPTEST snapshot PDBs use only a fraction of the space compared to the source **HRTESTMASTER** database.

    ```
    <copy>
    select distinct 'host du -h '||SUBSTR(NAME,1,INSTR(NAME,'datafile')+8 ) du_output
     from v$datafile  
     where con_id in
     (select con_id from v$pdbs where name in ('HRTESTMASTER','HRAPPTEST1','HRAPPTEST2','HRAPPTEST3'));
    </copy>
    ```
    ![The SQL statement produces host "du" commands that will be copied and pasted at the command line. ](./images/task7.3-ducommands.png " ")

4. Copy and paste each of the "host" commands in order to compare the disk space used between the master clone and the snapshot copy PDBs.  The row with the largest size value will be the HRTESTMASTER database.  Notice that the thin, snapshot copy databases are just a small fraction of the size of the master.


    
    ![The disk usage command output shows the snapshot copy PDBS are a fraction of the size of HRTESTMASTER.](./images/task7.4-execducommands.png " ")


Note: when a PDB Snapshot Copy is created, the permissions for the datafiles of the source database are changed to read-only at the file system level.  When this change is made, any attempt to execute the PDB refresh on the source will fail with an error.  In order to refresh the HRTESTMASTER PDB, the following steps would have to be performed in this order:

    1. Drop all snapshot copy PDBs based on the refreshable PDB HRTESTMASTER.
    2. Change the datafile permissions for the PDB HRTESTMASTER to read/write by executing the following: 
        DBMS_DNFS.RESTORE_DATAFILE_PERMISSIONS('HRTESTMASTER').
    3. Execute the PDB refresh of HRTESTMASTER.
    4. Create new PDB Snapshot Copies if desired.

Now you've had a chance to try out Oracle Multitenant. Hopefully you've realized the value that Oracle Multitenant can bring to your organization:
- Oracle Multitenant made it easy for you to create a new database in just seconds.  
- You were able to unplug your database for sharing with others, and plug in a database that was shared with your team.
- The workshop tasks also showed how Oracle Multitenant makes it easy to:
    - clone databases 
    - create refreshable clones
    - create thin database copies - allowing each test team to have their own copies of the database while minimizing the cost of storage space used.  
    
Thank you for participting in this Oracle LiveLabs workshop!

## APPENDIX: Lab Cleanup and Reset
If you'd like to run through this lab again on this same image, execute the following in order to clean up the environment before starting again.

**NOTE** exit from SQLcl before running the following code.
    
   ```
   <copy>
   cd /home/oracle/labs
   sh mt_agility_cleanup.sh     
   </copy>
   ```
   ![The cleanup shell scripts drops all the PDBs and removes the PDB archive file. ](./images/appendix-agilitycleanup.png " ")




## Acknowledgements

- **Author** - Joseph Bernens, Principal Solution Engineer
- **Contributors** -  Vasavi Nemani, Patrick Wheeler
- **Last Updated By/Date** - Joseph Bernens, Principal Solution Engineer, Oracle NACI Solution Engineering / July 2024
