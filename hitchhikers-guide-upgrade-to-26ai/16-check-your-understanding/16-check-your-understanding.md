# Check Your Understanding

## Introduction

This lab reviews the main upgrade concepts from the workshop. Complete the scored questions to check your understanding of upgrade methods, supported source versions, architecture changes, and pre-upgrade checks.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Review the primary upgrade method for Oracle AI Database 26ai
* Confirm the supported direct upgrade source releases
* Check your overall understanding

### Prerequisites

Complete the earlier workshop labs, or review the workshop material before taking this quiz.

```quiz-config
passing: 75
badge: images/upgrade-badge.png
```

## Task 1: Complete the quiz

1. Review the questions before you submit your answers.

2. Complete the scored quiz blocks below. You need 75% or higher to pass. 

    ```quiz score
    Q: Which tool is recommended as the primary method to upgrade to Oracle AI Database 26ai?
    - Data Pump
    - SQL*Loader
    * AutoUpgrade
    - RMAN
    > Oracle recommends AutoUpgrade because it automates many upgrade tasks and checks.
    ```

    ```quiz score
    Q: Which database versions support a direct upgrade to Oracle AI Database 26ai?
    - 10g and 11g
    - 12c only
    * 19c and 21c
    - 18c only
    > Oracle supports a direct upgrade to Oracle AI Database 26ai from Oracle Database 19c and 21c.
    ```

    ```quiz score
    Q: What architecture is required in Oracle AI Database 26ai?
    - Single Instance only
    - Non-CDB architecture
    * Multitenant architecture (CDB/PDB)
    - Data Guard only
    > Oracle AI Database 26ai requires multitenant architecture. Oracle no longer supports non-CDB architecture.
    ```

    ```quiz score
    Q: What is the purpose of running AutoUpgrade in analyze mode?
    - To start the database upgrade
    * To check compatibility and detect issues before upgrading
    - To create backups
    - To run performance tests
    > Analyze mode checks readiness and detects issues before the actual upgrade starts.
    ```

    ```quiz score
    Q: Which upgrade method involves unplugging a PDB from one CDB and plugging it into another CDB?
    - Rolling upgrade
    * Unplug/Plugin upgrade
    - Data Pump migration
    - Logical standby upgrade
    > Unplug/plugin upgrade moves a PDB from one CDB to another by unplugging it from the source and plugging it into the target.
    ```

## Acknowledgements

* **Author** - Alex Zaballa, Linda Foinding
* **Last Updated By/Date** - Linda Foinding, March 2026
