# Title of the Lab

## Introduction

*Describe the lab in one or two sentences, for example:* This lab walks you through the steps to ...

Estimated Time: 20 minutes

### About Oracle True Cache
Modern applications often require massive scalability in terms of both the number of connections and the amount of data that can be cached.

A popular approach is to place caches in front of the database. Those caches rely on the fact that applications often don't need to see the most current data. For example, when someone browses a flight reservation system, the system can show flight data that's one second old. When someone reserves a flight, then the system shows the most current data.

Oracle True Cache satisfies queries by using only data from its buffer cache. Like Oracle Active Data Guard, True Cache is a fully functional, read-only replication of the primary database, except that it's mostly diskless.

### Objectives

*List objectives for this lab using the format below*

In this lab, you will:
* Find how to create a  schema in in the newly created env, create tables.
* Upload data to those tables

### Prerequisites (Optional)

*List the prerequisites for this lab using the format below. Fill in whatever knowledge, accounts, etc. is needed to complete the lab. Do NOT list each previous lab as a prerequisite.*

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed


*Below, is the "fold"--where items are collapsed by default.*

## Task 1: Create user and tables

(optional) Task 1 opening paragraph.

1.

	![Image alt text](images/sample1.png)

Open a terminal window and execute below as opc user.

<copy>
sudo podman ps -a
</copy>
2. Connect podman primary image (dbmc)

<copy>
podman exec -it dbmc /bin/bash
</copy>

3. Execute step1 as the sysdba user.

4. Run the step2 and step3 as transaction user.

## Task 2: Load data into tables

1. Run step4 as the transaction user

  Use tables sparingly:

  | Column 1 | Column 2 | Column 3 |
  | --- | --- | --- |
  | 1 | Some text or a link | More text  |
  | 2 |Some text or a link | More text |
  | 3 | Some text or a link | More text |


You may now proceed to the next lab.

## Learn More

-  **Oracle True Cache ** 
[True Cache documentation for internal purposes] (https://docs-uat.us.oracle.com/en/database/oracle/oracle-database/23/odbtc/oracle-true-cache.html#GUID-147CD53B-DEA7-438C-9639-EDC18DAB114B)

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Thirumalai Thathachary
* **Last Updated By/Date** - Vivek Vishwanathan ,Software Developer, Oracle Database Product Management, August 2023
