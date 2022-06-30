# Setting the Default Tablespace Encryption Algorithm

## Introduction

This lab shows how the passwords in the password files in Oracle Database 21c are case-sensitive. In earlier Oracle Database releases, password files by default retain their original case-insensitive verifiers. The parameter to enable or disable password file case sensitivity `IGNORECASE` is removed. All passwords in new password files are case-sensitive.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Setup the environment

### Prerequisites

* An Oracle Account
* SSH Keys
* Create a DBCS VM Database
* 21c Setup

## Task 1: Set the default tablespace encryption algorithm

1. Connect to the CDB root and display the default tablespace encryption algorithm.

	```
	$ <copy>sqlplus / AS SYSDBA</copy>
	Connected to:

	Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
	Version 21.2.0.0.0
	```

	```
	SQL> <copy>SHOW PARAMETER TABLESPACE_ENCRYPTION_DEFAULT_ALGORITHM</copy>

	NAME                                       TYPE   VALUE
	------------------------------------------ ------ -----------------------
	tablespace_encryption_default_algorithm    string AES128

	SQL>
	```

2. Change the tablespace encryption algorithm.

	```
	SQL> <copy>ALTER SYSTEM SET TABLESPACE_ENCRYPTION_DEFAULT_ALGORITHM=AES192;</copy>
	System altered.

	SQL> <copy>EXIT</copy>

	$
	```

3. Connect to the PDB and create a new tablespace in `PDBTEST`.

	```
	$ <copy>sqlplus sys@PDB21 AS SYSDBA</copy>
	Enter password: <b><i>WElcome123##</i></b>

	Connected.
  ```

  ```
	SQL> <copy>CREATE TABLESPACE tbstest DATAFILE '/u02/app/oracle/oradata/pdb21/test01.dbf' SIZE 2M;</copy>
	Tablespace created.

	SQL>
	```

## Task 2: Verify the tablespace encryption algorithm used

1. Verify the tablespace encryption algorithm used.

	```
	SQL> <copy>SELECT name, encryptionalg
				FROM v$tablespace t, v$encrypted_tablespaces v
				WHERE t.ts#=v.ts#;</copy>

	NAME                           ENCRYPT
	------------------------------ -------
	USERS                          AES128
	TBSTEST                        AES192

	SQL> <copy>EXIT</copy>

	$
	```

## Acknowledgements

* **Author** - Donna Keesling, Database UA Team
* **Contributors** -  David Start, Kay Malcolm, Database Product Management
* **Last Updated By/Date** -  David Start, December 2020
