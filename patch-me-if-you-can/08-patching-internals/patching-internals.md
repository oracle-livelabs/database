# Patching Internals

## Introduction

This lab allows you to patch *backwards*. In other words, going to a previous Release Update. Only in the rare cases that you find a critical issue in a newer Release Update, would you go back to a previous one. After go-live you can no longer use Flashback Database, so you need to use the rollback capabilities in Datapatch. Also, you learn how to enable certain optimizer fixes.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Perform a manual rollback
* Enable optimizer fixes
* Check other software components

### Prerequisites

This lab assumes:

- You have completed Lab 3: Simple Patching With AutoUpgrade

## Task 1: Examine Datapatch tables
check REGISTRY$SQLPATCH_RU_INFO 
check REGISTRY$SQLPATCH
## Task 2: Examine Datapatch logs
Check sqlpatch_invocation-lgo
-recomp_threshold => always recompiles all invalidated objects. The threshold governs how many invalidates there must be, before we log it to the console.
Datapatch is a wrapper for sqlpatch
## Task 3: Patch storage
check .patch_storage
./opatch util deleteinactivepatches
## Task 4: Data Collection
SRDC - Data Collection for Datapatch issues (Doc ID 1965956.1)


You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, December 2024