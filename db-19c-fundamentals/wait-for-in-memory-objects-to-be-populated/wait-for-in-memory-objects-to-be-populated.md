# Apply Oracle Database 19c New Features: Wait for In-Memory Objects to be Populated

## About this Workshop

This workshop shows you how to allow applications to take advantage of the complete population of tables into the In-Memory Column Store (IMCS).

Oracle Database 19c introduces the `DBMS_INMEMORY_ADMIN.POPULATE_WAIT` function, which will return a value that indicates the status of an eligible object's population.

The possible return values are:

  * 0: All in-memory segments are fully populated.
  * 1: Not all in-memory segments are fully populated due to IMCS lack of space.
  * 2: There are no segments to populate.
  * 3: The IMCS size is configured to 0.

You can write a wrapper package that invokes the function at startup. Based on the value returned, the package can start the application's services, send messages to the application tier, or even open the database if it was opened in restricted mode.

Estimated Time: 15 minutes

### Objectives

In this workshop, you will learn how to:
- Prepare your environment
- Configure the IMCS and create In-Memory Tables.
- Wait for In-Memory segments to be populated
- Wait for In-Memory segments to be populated with other return codes
- Display meaningful messages returned by the function.
- Clean your environment

### Prerequisites

This lab assumes you have:
* Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

1. Open a terminal session.

2. Set the Oracle environment variables.

    ```
    $ <copy>. oraenv</copy>
    ```

3. If PDB1 is not open, open it. First, log into CDB1

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

4. Open PDB1.

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE PDB1 OPEN;</copy>
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT;</copy>
    ```

## Task 2: Configure the IMCS and create the In-Memory tables

1. Execute the `$HOME/labs/19cnf/im_tables.sh` shell script to set the IMCS size to 800 MB and create the in-memory tables: `OE.CUSTOMER`, `OE.LINEORDER`, `OE.DATE`, `OE.SUPPLIER`, and `OE.PART`. 

    ```
	$ <copy>$HOME/labs/19cnf/IM_tables.sh</copy>
    ```

2. Log in to CDB1.

    ```
    $ <copy>sqlplus / as SYSDBA</copy>
    ```

3. Verify that the IMCS is set to 800 MB.

    ```
	SQL> <copy>SHOW PARAMETER INMEMORY_SIZE</copy>

     NAME                    TYPE        VALUE
    ----------------------- ----------- --------------------
    inmemory_size           big integer 800M						
    ```			

4. Display the population stats of the in-memory tables.

    ```
 	SQL> <copy>SELECT segment_name, bytes, inmemory_size, bytes_not_populated, populate_status
     FROM v$im_segments; </copy>

    2
    no rows selected
    ```

## Task 3: Wait for In-Memory segments to be populated

1. Open a new terminal session, this will be called **session 2**.

2. In **session 2**, set the Oracle environment variables.

    ```
	$ <copy>. oraenv</copy>
	CDB1
	```

3. In **session 2**, log in as `SYSTEM` in PDB1.

    ```
	<copy>sqlplus system@PDB1</copy>
    Enter password: password
    ```

4. Execute the function to get information about the status of the population of in-memory tables at the percentage of 100.

    ```
	SQL> <copy>SELECT DBMS_INMEMORY_ADMIN.POPULATE_WAIT(PRIORITY=>'NONE',
            PERCENTAGE=>100, TIMEOUT => 180) 
     FROM  dual;</copy>
	 2
	DBMS_INMEMORY_ADMIN.POPULATE_WAIT(PRIORITY=>'NONE',PERCENTAGE=>100,T

	```

	After some time, the code returned from the function is 1, which means that the in-memory objects are not fully populated into the In-Memory Column Store because of the lack of space in the IMCS.

5. Exit SQL*Plus in **session 2**.

    ```
	SQL> <copy>EXIT</copy>
	```

6. Verify this assumption on **session 1**. Notice the **OUT OF MEMORY** under **LINEORDER**.

    ```
	SQL> <copy>SELECT segment_name, bytes, inmemory_size, bytes_not_populated, populate_status FROM	v$im_segments;</copy>
	```

7. In **session 1**, increase the IMCS size to 1 GB and the SGA_TARGET to 1.5 GB.

    ```
	SQL> <copy>CONNECT / AS SYSDBA</copy>
    ```

    ```
	SQL> <copy>ALTER SYSTEM SET inmemory_size=1G SCOPE=SPFILE;</copy>
    ```

    ```
	SQL> <copy>ALTER SYSTEM SET sga_target=1500M SCOPE=SPFILE;</copy>
    ```

8. In **session 1**, stop the instance and database.

    ```
	SQL> <copy>SHUTDOWN IMMEDIATE</copy>
    ```

9. In **session 1**, start the database. 
    ```
	SQL> <copy>STARTUP</copy>
    ```

10. Open the pluggable database.

    ```
	SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 OPEN;</copy>
    ```

11. In **session 2**, reconnect as `SYS`.

    ```
    $ <copy>sqlplus sys@PDB1 AS SYSDBA</copy>
    Enter password: password
	```

12. In **session 2**, execute the function that waits until in-memory tables are populated into the IMCS to the specified percentage of 100.

    ```
	<copy>SELECT DBMS_INMEMORY_ADMIN.POPULATE_WAIT('NONE', 100, 180) POP_STATUS FROM dual;</copy>

     POP_STATUS
     ----------
            0
    ```

	The query does not give any result until the population of the segments is 100% complete. When the population is complete, the return code is 0. The code returned means that the all in-memory objects are fully populated into the IMCS. You can therefore allow your application to query the tables, because you know that the tables queried are fully populated into the IMCS. A wrapper package invoking the function at instance startup would be beneficial.

13. In **session 2**. observe the population progress.

    ```
	<copy>SELECT segment_name, bytes, inmemory_size, bytes_not_populated, populate_status FROM   v$im_segments;</copy>
    ```

## Task 4: Wait for In-Memory segments to be populated with other return codes

1. In **session 2**, execute the `$HOME/labs/alter_OE.sql` SQL script that modifies the in-memory attribute of the `OE` tables.

    ```
	SQL> <copy>@$HOME/labs/19cnf/alter_OE.sql</copy>
    ```

2. Exit SQL*Plus in **session 2**.

    ```
	SQL> <copy>EXIT</copy>
    ```

3. In **session 1**, restart PDB1 so that `OE` tables are no longer populated into the IMCS.

    ```
	SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 CLOSE;</copy>
    ```

4. In **session 1**, open PDB1.

    ```
	SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 OPEN;</copy>
    ```

5. In **session 2**, reconnect as `SYS`.

    ```
	$ <copy>sqlplus sys@PDB1 AS SYSDBA</copy>
	Enter password: password
    ```
	
6. In **session 1**, execute the function that waits until in-memory tables are populated into the IMCS to the specified percentage of 100 and a timeout set to one minute.

    ```
	SQL> <copy>SELECT DBMS_INMEMORY_ADMIN.POPULATE_WAIT('NONE', 100, 60) POP_STATUS FROM dual;</copy>

	POP_STATUS
	----------
	        2
    ```

7. Observe the population progress in **session 1**.

    ```
	SQL> <copy>SELECT segment_name, bytes, inmemory_size, bytes_not_populated, populate_status
	FROM   v$im_segments;</copy>
 		2
	no rows selected
    ```

## Task 5: Display meaningful messages returned by the function

1. In **session 1**, execute the function after setting output to `ON`.

    ```
	SQL> <copy>SET SERVEROUTPUT ON</copy>

	SQL> <copy>SELECT DBMS_INMEMORY_ADMIN.POPULATE_WAIT('NONE', 100, 60) POP_STATUS FROM dual;</copy>
    ```

2. In **session 2**, update the priority NONE to HIGH for two of the in-memory tables.

    ```
	SQL> <copy>ALTER TABLE oe.lineorder INMEMORY PRIORITY HIGH;</copy>

	SQL> <copy>ALTER TABLE oe.date_dim INMEMORY PRIORITY HIGH;</copy>
    ```

3. Exit SQL*Plus in **session 2**.

    ```
	SQL> <copy>EXIT</copy>
    ```

4. In **session 1**, close PDB1.

    ```
	SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 CLOSE;</copy>
    ```

5. In **session 1**, Open PDB1.
    ```
	SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 OPEN;</copy>
    ```


6. In **session 2**, reconnect as SYS.

    ```
    $ <copy>sqlplus sys@PDB1 AS SYSDBA</copy>
    Enter password: password
    ```

7. In **session 2**, execute the function that waits until in-memory tables are populated into the IMCS to the specified percentage of 100 and a timeout set to one minute.

    ```
	SQL> <copy>SET SERVEROUTPUT ON;</copy>

	SQL> <copy>SELECT DBMS_INMEMORY_ADMIN.POPULATE_WAIT('HIGH', 100, 60) POP_STATUS FROM dual;</copy>
    ```

8. Exit SQL*Plus in **session 2**.

    ```
	SQL> <copy>EXIT</copy>
    ```

## Task 6: Clean up your environment

1. In **session 1**, reset the IMCS size to 0.

    ```
    SQL> <copy>ALTER SYSTEM SET inmemory_size=0 SCOPE=SPFILE;</copy>
	```

2. In **session 1**, stop the database instance.

    ```
    SQL> <copy>SHUTDOWN</copy>
	```

3. In **session 1**, start the database instance.

    ```
    SQL> <copy>STARTUP</copy>
    ```

4. Open `PDB1`.

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE pdb1 OPEN;</copy>
	```

5. Verify the return status of the function after the cleanup completed.

    ```
    SQL> <copy>SET SERVEROUTPUT ON</copy>

    SQL> <copy>SELECT DBMS_INMEMORY_ADMIN.POPULATE_WAIT('HIGH', 100, 60)
    POP_STATUS FROM dual;</copy>

    POP_STATUS
    ----------
            3

    SQL> <copy>POPULATE ERROR, INMEMORY_SIZE=0</copy>
	```

    The message is more meaningful than the return code error 3.

6. Exit SQL*Plus in **session 1**.

    ```
    SQL> <copy>EXIT</copy>
    ```

7. Cleanup PDBs in CDB1.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy> 
    ```

8. You may exit the terminal session in **session 2**.

    You may now **proceed to the next lab**.

## Acknowledgements
* **Author** - Dominique Jeunot, Consulting User Assistance Developer
* **Contributor** - Andrew Selius, Solution Engineer, Oracle Santa Monica Hub
* **Last Updated By/Date** - Andrew Selius, January 12, 2021
