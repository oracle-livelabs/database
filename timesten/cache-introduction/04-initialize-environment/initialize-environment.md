# Initialize the workshop environment

## Introduction

In this lab, you will start up all the components required to run the labs making up this workshop.

The workshop uses an Oracle database which runs in its own container (**dbhost**). A second container (**tthost1**) provides the TimesTen environment. These containers, and the host system (**ttlivelabvm**), are all connected using a custom Docker network. This setup provides a realistic multi-host environment with the convenience of just a single compute instance.

**Estimated Lab Time:** 10 minutes.

### Objectives

- Initialize the workshop environment.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH. Use **oracle** (in lowercase) as the user.

### Start over from the beginning

Once you have successfully completed this lab, if at any point you want to start the whole workshop again from the beginning, just go to the **~/lab** directory and run the script **labReset.sh**. That script will take 5-8 minutes to run and it will reset everything back to the way it will be after this lab is completed.

## Task 1: Initialize and startup the lab components

1. In the terminal session, change to the **lab** directory:

```
<copy>
cd ~/lab
</copy>
```

2. Initialize the workshop:

```
<copy>
labSetup.sh cache-intro
</copy>
```

```
info: setting up workshop 'cache-intro', this will take several minutes...
info: starting hosts: OK
info: host initialization: OK
info: resetting Oracle Database state, please be patient...
info: Oracle Database state successfully reset
info: starting Oracle Database: OK
```

This command will take between 5 and 8 minutes to complete. Once the setup script has completed successfully, **proceed to the next lab**. 

Keep your terminal session open ready for the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, October 2023

