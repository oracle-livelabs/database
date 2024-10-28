# Set up 21C Environment

## Introduction

In this lab, you will run the scripts to setup the environment for the Oracle Database 21c workshop.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:
* Define and test the connections
* Download scripts needed to run 21c labs
* Update scripts with the chosen password

### Prerequisites

* An Oracle Account
* Working knowledge of vi or nano
* SSH Keys
* Create a DBCS VM Database
* DBCS Public Address
* Database Unique Name

## Task 1: Server Setup

1. If you aren't still logged in, login to Oracle Cloud and re-start the Oracle Cloud Shell otherwise skip to Step 3.
2. In Cloud Shell or your terminal window, navigate to the folder where you created the SSH keys and enter this command, using your IP address:

    ```
    $ <copy>ssh -i <<sshkeyname>> opc@</copy>< your_IP_address >
    Enter passphrase for key './myOracleCloudKey':
    Last login: Tue Feb  4 15:21:57 2020 from < your_IP_address >
    [opc@tmdb1 ~]$
    ```

3. You will need to create the directories for the container database as well as the pluggable databases.

    ```
    <copy>
    sudo mkdir /u02/app/oracle/oradata/CDB21
    sudo chown oracle:oinstall /u02/app/oracle/oradata/CDB21
    sudo chmod 755 /u02/app/oracle/oradata/CDB21
    sudo mkdir /u02/app/oracle/oradata/pdb21
    sudo chown oracle:oinstall /u02/app/oracle/oradata/pdb21
    sudo chmod 755 /u02/app/oracle/oradata/pdb21
    sudo mkdir /u02/app/oracle/oradata/PDB21
    sudo chown oracle:oinstall /u02/app/oracle/oradata/PDB21
    sudo chmod 755 /u02/app/oracle/oradata/PDB21
    sudo mkdir /u02/app/oracle/oradata/toys_root
    sudo chown oracle:oinstall /u02/app/oracle/oradata/toys_root
    sudo chmod 755 /u02/app/oracle/oradata/toys_root
    sudo mkdir /u03/app/oracle/fast_recovery_area
    sudo chown oracle:oinstall /u03/app/oracle/fast_recovery_area
    sudo chmod 755 /u03/app/oracle/fast_recovery_area
    </copy>
    ```

4. Once connected, you can switch to the "oracle" OS user.

    ```
    [opc@tmdb1 ~]$ <copy>sudo su - oracle</copy>
  	```

5. The first step is to get all of the scripts needed to do this lab.

    ```
    <copy>
    cd /home/oracle
    wget https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/data-management-library-files/Cloud_21c_Labs.zip
    </copy>
    ```

6.  Unzip Cloud\_21c\_Labs.zip

    ```
    <copy>
    unzip Cloud_21c_Labs.zip
    </copy>
    ```

7. Make the script readable, writable, and executable by everyone.

    ```
    <copy>
    chmod 777 /home/oracle/labs/update_pass.sh
    </copy>
    ```

8. Execute the /home/oracle/labs/update\_pass.sh shell script. The shell script prompts you to enter the password\_defined\_during\_DBSystem\_creation and sets it in all shell scripts and SQL scripts that will be used in the practices.

    ```
    [oracle@da3 ~]$ <copy>/home/oracle/labs/update_pass.sh</copy>
    Enter the password you set during the DBSystem creation: WElcome123##
    ```

## Task 2: Database Create

1. Now to create the `CDB21` database. There is an existing database on this server but the `CDB21` was created with everything needed for this workshop.

    ```
    <copy>
    cd /home/oracle/labs/M104784GC10
    /home/oracle/labs/M104784GC10/create_CDB21.sh
    </copy>
    ```

2. Set your environment. At the prompt type in `CDB21`

    ```
    [oracle@db1 ~]$ <copy>. oraenv</copy>
    ORACLE_SID = [CDB21] ? CDB21
    The Oracle base remains unchanged with value /u01/app/oracle
    [oracle@db1 ~]$
    ```

3. Verify that your Oracle Database 21c `CDB21` and `PDB21` are created using the commands below.

    ```
    <copy>
    ps -ef|grep smon
    sqlplus / as sysdba
    </copy>
    ```

    ```
    <copy>
    show pdbs
    exit;
    </copy>
    ```

4. Ensure that the TNS alias have been created for `CDB21`, `PDB21` and `PDB21_2` in the tnsnames.ora file. If they are not there then you will need to add them. The file is located in `/u01/app/oracle/homes/OraDB21Home1/network/admin/tnsnames.ora`.

    ```
	  <copy>
	  cat /u01/app/oracle/homes/OraDB21Home1/network/admin/tnsnames.ora
	  </copy>
	  ```

5. Then entry for `CDB21` should have been created when the database was created. So for `PDB21` just copy the entry for `CDB21` and change the value `CDB21` to `PDB21` in both places. Repeat this for `PDB21_2`.

    ```
	  <copy>
	  vi /u01/app/oracle/homes/OraDB21Home1/network/admin/tnsnames.ora
	  </copy>
	  ```

6. There will be more in your tnsnames.ora but the for the three entries we care about should look like the entries below but with your hostname instead.

    ```
    CDB21 =
    (DESCRIPTION =
     (ADDRESS = (PROTOCOL = TCP)(HOST = db1.subnet11241424.vcn11241424.oraclevcn.com)(PORT = 1521))
     (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = CDB21)
     )
    )

    PDB21 =
    (DESCRIPTION =
     (ADDRESS = (PROTOCOL = TCP)(HOST = db1.subnet11241424.vcn11241424.oraclevcn.com)(PORT = 1521))
     (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDB21)
     )
    )

    PDB21_2 =
    (DESCRIPTION =
     (ADDRESS = (PROTOCOL = TCP)(HOST = db1.subnet11241424.vcn11241424.oraclevcn.com)(PORT = 1521))
     (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = PDB21_2)
     )
    )
    ```

7. Test the connection to CDB21.  Connect to CDB21 with SQL*Plus using the password **WElcome123##**.

    ```
	  <copy>
	  sqlplus sys@cdb21 AS SYSDBA
	  </copy>
	  ```

8. Verify that the container name is **CDB$ROOT**.

    ```
    <copy>
	  SHOW CON_NAME;
	  </copy>
	  ```

9. Test the connection to PDB21 using the same password used in the earlier step.

    ```
    <copy>
    CONNECT sys@PDB21 AS SYSDBA
    </copy>
    ```

10.  Show the container name. It should now display **PDB21**.

    ```
    <copy>
    SHOW CON_NAME;
    </copy>
    ```

11. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Acknowledgements

* **Author** - Donna Keesling, Database UA Team
* **Contributors** -  David Start, Kay Malcolm, Database Product Management
* **Last Updated By/Date** - Arabella Yao, Product Manager, Database Product Management, December 2021
