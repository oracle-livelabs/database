# Lab 1: Start the Jupyter Lab Environment

## Introduction

**(Refer to 'Lab 1' of the Jupyter notebook as go through this lab)** 

This lab guide will walk you through starting up Jupyter Lab notebook, which is the development environment we will explore Oracle AI Database AI capabilities.

Estimated Time: 10 minutes

### Objectives

* Start the Jupyter Lab server and open the development notebook.

### Prerequisites

* Access to the virtual environment generated for this lab
* Basic Linux, Python and SQL knowledge

## Task 1: Open the remote Jupyter Lab environment

On your browser, enter the following URL:

```python
<copy>
http://147.224.148.50/livelabs/vnc.html?password=LiveLabs.Rocks_99&resize=scale&quality=9&autoconnect=true&reconnect=true
</copy>
```

![Jupyter server start](images/jupyter01.png)

If you have downloaded this workshop to your own tenancy, to execute locally, you may chose to run the jupyter directly in your browser using the following URL:

```python
<copy>
http://147.224.148.50:8888/lab/workspaces/auto-h/tree/oracleai_demo.livelab.code.local.ipynb
</copy>
```

![Jupyter launcher](images/jupyter02.png)

**NOTE** - To get a larger view of an image, float your cursor over the image and when **'magnifying glass'** appears as the cursor, click it and a **full-screen** view of the image appears.  A second click returns the image to its original dimensions.

## Task 2: Verify the valid setup of the workshop environment

 (switch to browser) [Lab1 Task2:]&nbsp;&nbsp;&nbsp;The next two notebook cells introduce the workshop and provide an overview of the goals and expectations.  When ready, press 'Shift-Enter' or click the 'Run Cell' icon( ![CellRun icon](images/run-cell-icon.png) ) in each cell to continue.
 
![Oracle AI Database introduction](images/workshop-intro-overview.png)

The next cell verifies and resets the workshop environment. These tasks include:

* Setting fine-grained network access control entries (ACEs) for Access Control Lists (ACLs)
* Creating OCI credentials
* Granting access to the database data pump directory
* Removing previously deployed sentence transformer models

**(jupyter notebook) -->**  [Lab1 Task2:]&nbsp;&nbsp;&nbsp;When ready, press 'Shift-Enter' or click the 'Run Cell' icon( ![CellRun icon](images/run-cell-icon.png) ) to reset the workshop.

When the following output is successfully displayed, the workshop has been reset and you may move on to the next Lab.
NOTE: This cell may be rerun until all output is displayed

![python code example of workshop reset](images/reset.png)

You may now **proceed to the next lab**

## Acknowledgements

**Author** - Gary McKoy, Master Principal Solution Architect, Data Platform Infrastructure, NACI

**Contributors** -

* Eileen Beck, Cloud Solution Engineer, Data Platform Infrastructure, NACI
* Sania Bolla, Cloud Solution Engineer, Data Platform Infrastructure, NACI
* Abby Mulry, Cloud Solution Engineer, Data Platform Infrastructure, NACI
* Richard Piantini Cid, Cloud Solution Engineer, Data Platform Infrastructure, NACI

**Last Updated By/Date** -  Gary McKoy, March 2026