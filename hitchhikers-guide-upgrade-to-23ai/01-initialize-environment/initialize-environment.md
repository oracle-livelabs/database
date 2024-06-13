# Initialize Environment

## Introduction

In this lab, you will review and startup all components required to successfully run this workshop.

Estimated Time: 5 Minutes.

### Objectives

In this lab, you will:

* Familiarize yourself with the workshop environment
* Initialize the workshop environment

## Task 1: Familiarize yourself with the workshop environment

1. The easiest way to complete the lab is to copy/paste the lab instructions directly into a terminal. Be sure to execute all commands in a code block. After pasting you must hit *RETURN*.

2. Before copy/pasting take notice of the commands that you execute. It is important to understand what the commands will do.

3. You can use any terminal to run the lab. The lab sets the environment when appropriate.

4. In the upper-left corner, click *Activities*. 

![Click Activities to start a terminal](./images/initialize-environment-click-activities.png " ")

5. Then click on the *terminal* icon.

![Click the terminal icon to start a new terminal](./images/initialize-environment-click-terminal.jpeg)    

6. When the terminal opens, it says *Database ENV is not set*. You can disregard that message. All labs starts by setting the appropriate environment.

7. In the terminal, you can zoom in to make the text larger. Press *CTRL* and *+* or select *Zoom In*.

![Zoom in to make the text larger in the terminal](./images/initialize-environment-zoom-in.png)    

8. If you need another terminal, either start a brand new one, or open a new tab in the existing terminal.    

![Open a new tab in the existing terminal](images/initialize-environment-new-tab.png)

9. As explained in the introduction, you can run some of the labs in parallel. When doing so, it might be useful to use multiple *desktops*. Then, you can run each lab on its own desktop. To switch between desktops click *Activities* and select the desktop in the right side. 

![Switch between desktops to run each lab on a separate desktop](images/initialize-environment-new-desktop.jpeg)

10. Throughout the labs you will open HTML documents in Firefox browser. If the text in the documents is too small, you can zoom in.

![Zoom in in Firefox to make text bigger](images/initialize-environment-firefox-zoom.png)

## Task 2: Initialize the workshop environment

1. Open a terminal or use an existing one. When you start the lab, the following components should be started.

    - Database Listener
        - LISTENER
    - Database Server Instances
        - FTEX
        - UPGR
        - CDB23

2. Ensure the listener is started.

    ```
    <copy>
    ps -ef | grep LISTENER | grep -v grep
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ps -ef | grep LISTENER | grep -v grep
    oracle    2333     1  0 11:40 ?        00:00:00 /u01/app/oracle/product/19/bin/tnslsnr LISTENER -inherit
    ```
    </details>

3. Ensure that the databases (*FTEX*, *UPGR* and *CDB23*) are started.

    ```
    <copy>
    ps -ef | grep ora_ | grep pmon | grep -v grep
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ps -ef | grep ora_ | grep pmon | grep -v grep
    oracle      3851       1  0 20:19 ?        00:00:00 ora_pmon_UPGR
    oracle      5110       1  0 20:19 ?        00:00:00 ora_pmon_FTEX
    oracle      5345       1  0 20:19 ?        00:00:00 ora_pmon_CDB23
    ```
    </details>

4. Occasionally, the *UPGR* database fails to register with the listener. Set the environment and connect to *UPGR*.

    ```
    <copy>
    . upgr
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

5. Restart *UPGR*.

    ```
    <copy>
    startup force
    </copy>
    ```

6. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, June 2024
