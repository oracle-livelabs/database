# Check Your Understanding

## Introduction

This lab reviews the key patching concepts from the workshop. Complete the scored questions to test your understanding of patching methods and procedures.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

* Assess your overall understanding
* Review key patching information

### Prerequisites

Complete the earlier workshop labs or review the workshop material before taking this quiz.

```quiz-config
passing: 75
badge: ../09-check-your-understanding/images/upgrade-badge.png
```

## Task 1: Complete the quiz

1. Review the questions before submitting your answers.

2. Complete the scored quizzes below. You need a score of 75% or higher to pass. 

    ```quiz score
    Q: What is the recommended patching concept?
    - In-place patching
    * Out-of-place patching
    - Over-the-patching
    - All of them
    > Oracle recommends out-of-place patching because it reduces downtime and complexity and facilitates easy rollback.
    ```

    ```quiz score
    Q: Does AutoUpgrade download patches?
    * Yes
    - No
    - Only Release Updates
    > AutoUpgrade is an easy and convenient way of downloading patches. Supply your MOS credentials and decide which patches to download and AutoUpgrade takes care of the rest. 
    ```

    ```quiz score
    Q: What are the advantages of using gold images?
    - They contain fewer bugs
    - They are platform independent
    - They are required in Oracle AI Database 26ai
    * They install faster
    > You can install a gold image faster because you can avoid applying patches. They are not required in 26ai, but made available for download.
    ```

    ```quiz score
    Q: What is the purpose of running AutoUpgrade in analyze mode?
    - To start the database patching
    * To check for patching readiness
    - To create backups
    - To run performance tests
    > Analyze mode checks readiness and detects issues before the actual upgrade starts.
    ```

    ```quiz score
    Q: How can you add Monthly Recommended Patches (MRP) to your Oracle home?
    - MRPs don't apply to a database Oracle home
    - You must add those manually using OPatch
    - By using a Datapatch command line option
    * Using the "MRP" keyword in the "patch" config file entry
    > AutoUpgrade can find the correct MRP when you use the appropriate keyword in the `patch` config file entry.
    ```

    ```quiz score
    Q: Which statement about container database patching is true?
    - You must call Datapatch once per PDB
    - OPatch patches CDBs and Datapatch is for non-CDBs.
    * Only open PDBs are patched
    - Datapatch never touches the root container (CDB$ROOT)
    > OPatch updates and patches the files in the Oracle home. Datapatch works only inside the database. OUI is used to attach the Oracle home to the local inventory and do installation tasks only.
    ``` 

    ```quiz score
    Q: Which tool is responsible for patching the Oracle home?
    - Datapatch
    * OPatch
    - Datapatch and OPatch in combination
    - Oracle Universal Installer (runInstaller)
    > OPatch updates and patches the files in the Oracle home. Datapatch works only inside the database. OUI is used to attach the Oracle home to the local inventory and do installation tasks only.
    ```    

    ```quiz score
    Q: Where does Datapatch store information?
    * In the tables REGISTRY$SQLPATCH and REGISTRY$SQLPATCH_RU_INFO
    - In the hidden .patch_storage directory in the Oracle home
    - In XML files in diagnostic destination
    - Datapatch never stores information, just log files in $ORACLE_BASE
    > Datapatch stores patching related information and rollback scripts inside the database in the data dictionary. 
    ```    

    ```quiz score
    Q: Which of the following statements is incorrect?
    * AutoUpgrade only patches the database to an existing Oracle home
    - AutoUpgrade can download patches
    - AutoUpgrade works on all platforms
    - AutoUpgrade can install Oracle homes and create gold images
    > AutoUpgrade can patch a database to a new or existing Oracle home. You can create a new Oracle home separately and later patch the database.
    ``` 

    ```quiz score
    Q: What license is required for using AutoUpgrade?
    - Enterprise Edition
    - Database Lifecycle Management Pack
    - Fleet Patching Option
    * No separate license needed
    > There is no separate license requirement for AutoUpgrade. It may be used by all users of Oracle AI Database.
    ```

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, September 2026