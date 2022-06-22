# Initialize the Workshop Environment

## Introduction

In this lab we will startup all the components required to successfully run the rest of the labs making up this workshop.

The workshop uses an Oracle database which runs in its own container (dbhost). A second container (tthost1) provides the TimesTen environment. These containers, and the host system (ttlivelabvm), are all connected using a custom Docker network. This setup provides a realistic multi-host environment with the cionvenience of just a single compute instance.

Estimated Time: 10 minutes.

### Objectives

- Initialize the workshop environment.

### Prerequisites

This lab assumes that you have:

- Completed all the previous labs in this workshop, in sequence.

## Task 1: Connect to the environment

Connect to the OCI compute instance and open a terminal session, as the user **oracle**,  using an appropriate method as discussed in the previous lab.

## Task 2: Initialize and startup the lab components

Change to the 'lab' directory:

`[oracle@ttlivelabvm ~] cd ~/lab`

Execute the labSetup.sh script as shown below:

```
[oracle@ttlivelabvm ~] labSetup.sh cache-intro
info: setting up workshop 'cache-intro', this will take several minutes...
info: starting hosts: OK
info: host initialization: OK
info: resetting Oracle Database state, please be patient...
info: Oracle Database state successfully reset
info: starting Oracle Database: OK
```

This command will take between 5 and 8 minutes to complete. Once the setup has completed successfully, *proceed to the next lab*. You can keep your terminal session open ready for the next lab.

### Starting over from the beginning

If at any point you want to start the whole workshop again from the beginning, just go the the **lab** directiry and run the script **labReset.sh**. The script will take 5-8 minutes to run and it will reset everything back to the way it was after this lab completed.


## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022

