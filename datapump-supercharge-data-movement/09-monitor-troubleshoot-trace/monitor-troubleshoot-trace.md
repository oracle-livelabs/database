# Monitoring, Troubleshooting and Tracing

## Introduction

...

Estimated Time: 20 Minutes

### Objectives

In this lab, you will:

* ...

### Prerequisites

This lab assumes:

- You have completed Lab 3: Getting Started

## Task 1: ...

Oracle Database stores LOBs in two formats. *SecureFile LOBs* is the newest format with a lot of advantages over the older format, *BasicFile LOBs*. Oracle recommends that you store your LOBs in SecureFile format.

2. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-05-lob-basicfile.par
    </copy>
    ```

    * This is a simple import parameter file with nothing special.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    dumpfile=faster-import-lob.dmp
    logfile=faster-import-lob-basicfile.log
    metrics=yes
    logtime=all
    parallel=4    
    ```
    </details> 

You may now *proceed to the next lab*.

## Additional information

* Webinar, [Data Pump Best Practices and Real World Scenarios, LOB data and Data Pump and things to know](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1798s)
* Webinar, [Data Pump Best Practices and Real World Scenarios, Statistics and Data Pump](https://www.youtube.com/watch?v=960ToLE-ZE8&t=1117s)

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025