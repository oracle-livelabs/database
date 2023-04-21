# Get started with JavaScript using a community module

## Introduction

Before jumping into the description of JavaScript features and all their details let's begin with a practical example. Enhancing data quality is a focus area for many businesses. Data quality that is lacking prevents analysts from making correct decisions, and it all starts at the source system. In this lab you can read about validating email addresses, a common scenario in many applications. Validating email addresses isn't a new problem, and there are plenty of solutions available. In this post you can learn about the open source `validator.js` module's `isEmail()` function and how to use it in your application.

> If you intend to use `validator.js` in your own project please refer to [validator's GitHub project site](https://github.com/validatorjs/validator.js) for more details about the project's license and implications of use. 

Estimated Time: 10 minutes


### Objectives

In this lab, you will:

- Create a schema to store the JavaScript module
- Download the ECMAScript version of the `validator.js` module
- Create a MLE module in the database
- Expose the module to PL/SQL and SQL
- Validate email addresses

### Prerequisites

This lab assumes you have:

- Oracle Database 23c Free - Developer Release
- All previous labs successfully completed

## Task 1: Create a schema to store the JavaScript module

All the steps in this lab can either be completed in `sqlplus` or `sqlcl`. The instructions refer to `sqlplus` but apart from the initial connection they are identical between the two.

1. Start by connecting to the database as `SYS`

	```sql
	$ <copy>sqlplus / as sysdba</copy>
	```

	Should you get a message `connected to an idle instance` or `sqlplus: command not found` you need to source the correct environment variables first:

	```bash
	$ <copy>ORACLE_SID=FREE ORAENV_ASK=NO source oraenv</copy>
	```

	Verify the success by echoing both `ORACLE_SID` and `ORACLE_HOME`:

	```bash
	$ <copy>echo "ORACLE_SID is set to ${ORACLE_SID} for ORACLE_HOME ${ORACLE_HOME}"</copy>
	```

	If you see the following output on your screen you are all set:

	```
	ORACLE_SID is set to FREE for ORACLE_HOME /opt/oracle/product/23c/dbhomeFree
	```

2. Once you are successfully connected to the database, switch to the pre-created Pluggable Database (PDB) `freepdb1`

	```sql
	SQL> <copy>alter session set container = freepdb1;</copy>
	```

3. Create the new user in freepdb1

	Create the new user while you are still connected as `SYS`. The following snippet will prompt you for a password to be assigned to the user. Please remember the password, you will need it later.

	```sql
	<copy>drop user if exists jstest cascade;

	create user jstest identified by &secretpassword
	default tablespace users quota unlimited on users;

	grant create session to jstest;
	grant db_developer_role to jstest;
	grant execute on javascript to jstest;

	host mkdir /home/oracle/hol23c

	drop directory if exists javascript_src_dir;
	create directory javascript_src_dir as '/home/oracle/hol23c';
	grant read on directory javascript_src_dir to jstest;

	exit</copy>
	```

## Task 2: Get the ECMAScript version of the validator.js module

The `validator` module can be downloaded from multiple sources, as long as you pick a trustworthy one it doesn't really matter where the file originates from. You need to ensure that you get the ECMA Script (ESM) version of the module from your preferred CDN as they are the only ones supported in Oracle. The file necessary has been staged on Object Storage and can be copied to the directory pointed at by `javascript_src_dir` as follows:

```bash
echo TODO
```

## Task 3: Create the MLE module in the database

JavaScript in Oracle Database 23c Free - Developer Release allows you to load JavaScript modules using the `BFILE` clause, specifying a directory object and file name. You prepared for the `create mle module` command in the previous step, now it's time to execute the command:

1. Connect to the database as the `jstest` user:

	```bash
	<copy>sqlplus jstest/yourNewPasswordGoesHere@localhost/freepdb1</copy>
	```

2. With the session established you create the module as follows:

	```sql
	<copy>
	create  mle module validator
	language javascript
	using bfile (javascript_src_dir, 'validator.min.js');
	/
	</copy>
	```

3. Verify the module has been created:

	```sql
	<copy>
	col MODULE_NAME for a30
	col LANGUAGE_NAME for a30

	select 
		module_name, 
		language_name 
	from 
		user_mle_modules
	where
		module_name = 'VALIDATOR';</copy>
	```

	The query should return exactly 1 row as shown here:

	```
	MODULE_NAME                    LANGUAGE_NAME
	------------------------------ ------------------------------
	VALIDATOR                      JAVASCRIPT
	```

You can read more about creating JavaScript modules in Oracle Database 23c Free - Developer release in [chapter 2 of the JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/mle-js-modules-and-environments.html#GUID-32E2D1BB-37A0-4BA8-AD29-C967A8CA0CE1).

## Task 4: Expose the module's functionality to PL/SQL and SQL

With the module successfully created in the schema the hardest part is completed. The Validator module exposes quite a few string validators for any purpose imaginable, the [project's GitHub page](https://github.com/validatorjs/validator.js#validators) lists them all. As per the introduction to this post, the project requires validation of an email address. A PL/SQL call specification links the module's JavaScript functions to SQL and PL/SQL. In this simple case a stand-alone function does the trick:

```sql
create or replace function isEmail(
  p_str varchar2
) return boolean
as mle module validator
signature 'default.isEmail(string)';
/
```

In case where multiple JavaScript functions are made available to PL/SQL and SQL you should probably encapsulate them in a package.

Please refer to [chapter 5 in the JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/calling-mle-js-functions.html#GUID-55400971-3660-47D7-B60C-D2F76EE0FD42) for more information about call specifications and module calls.

## Task 5: Validate email addresses

After the JavaScript module has been created in the schema and exposed to SQL and PL/SQL it can be used like any other PL/SQL code unit. Go ahead and validate a few email addresses:

```sql
<copy>
select isEmail('user-no-domain');
select isEmail('@domain.but.no.user');
select isEmail('user@example.com');
</copy>
```

## Learn More

- [JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/index.html)
- [Application Programming Interface (API) Reference](https://oracle-samples.github.io/mle-modules/)

## Acknowledgements

- **Author** - Martin Bach, Senior Principal Product Manager, ST & Database Development
- **Contributors** -  Lucas Braun, Sarah Hirschfeld
- **Last Updated By/Date** - Martin Bach APRIL 2023
