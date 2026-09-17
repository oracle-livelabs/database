# Check Your Understanding

## Introduction

This lab reviews the key upgrade concepts from the workshop. Complete the scored questions to test your understanding of upgrade methods, supported source versions, architecture changes, and pre-upgrade checks.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

* Review the primary recommended upgrade method for Oracle AI Database 26ai
* Confirm the source releases that support direct upgrades
* Assess your overall understanding

### Prerequisites

Complete the earlier workshop labs or review the workshop material before taking this quiz.

```quiz-config
passing: 75
badge: ../../09-check-your-understanding/images/upgrade-badge.png
```

## Task 1: Complete the quiz

1. Review the questions before submitting your answers.

2. Complete the scored quizzes below. You need a score of 75% or higher to pass. 

    ```quiz score
    Q: Which tool is recommended as the primary method to upgrade to Oracle AI Database 26ai?
    - Data Pump
    - SQL*Loader
    * AutoUpgrade
    - RMAN
    > Oracle recommends AutoUpgrade because it automates many upgrade tasks and checks.
    ```

    ```quiz score
    Q: Which database versions support direct upgrades to Oracle AI Database 26ai?
    - 10g and 11g
    - 12c only
    * 19c and 21c
    - 18c only
    > Oracle supports a direct upgrade to Oracle AI Database 26ai from Oracle Database 19c and 21c.
    ```

    ```quiz score
    Q: What architecture is required for Oracle AI Database 26ai?
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
    * Unplug-plug upgrade
    - Data Pump migration
    - Logical standby upgrade
    > Unplug/plugin upgrade moves a PDB from one CDB to another by unplugging it from the source and plugging it into the target.
    ```

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026