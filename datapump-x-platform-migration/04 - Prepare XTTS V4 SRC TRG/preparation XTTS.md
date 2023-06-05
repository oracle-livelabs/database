# Prepare XTTS on Source and Target  

## Introduction

In this lab, you will unzip the XTTS V4 files on source/target and create the XTTS properties file required by the tool.

Estimated Time: 15 minutes

### Objectives

- Setup XTTS V4.


### Prerequisites

This lab assumes you have:

- Connected to the Hands On Lab
- A terminal window open on source.
- Another terminal window open on target

## Task 1: Source database terminal window

Click on the Terminal icon to open a second session
![terminal](./images/Terminal.png " ")

First set the source environment and start SQL*Plus

  ```
  <copy>
     cd /home/oracle/XTTS/SOURCE
     unzip ~/Desktop/rman_xttconvert_VER4.3.zip 
  </copy>
 ```

![Login to CDB3](./images/Source_UPGR_env_sqlplus.png " ")

## Task 2: Target database terminal window


  ```
    <copy>
     cd /home/oracle/XTTS/TARGET
     unzip ~/Desktop/rman_xttconvert_VER4.3.zip 
    </copy>
  ```


![Login to CDB3](./images/enable_archive_logging.png " ")





## Acknowledgements
* **Author** - Klaus Gronau
* **Contributors** -  
* **Last Updated By/Date** - Klaus Gronau, June 2023
