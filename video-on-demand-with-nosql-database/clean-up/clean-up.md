# Clean Up

## Introduction

This lab is finished. We wil delete all resources created.

## Task 1: Delete resources created using Cloud Shell

In this task we will deleted the resource created using the Cloud Shell.

1. Open the **Cloud Shell** in the top right menu.
to get the Cloud Shell started.

  ![Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png)

2. Execute the following in your Cloud Shell.

    ````
    <copy>
    source ~/video-on-demand-with-nosql-database/env.sh
    oci nosql table delete --compartment-id "$NOSQL_COMPID" --table-name-or-id stream_acct \
    --wait-for-state SUCCEEDED --wait-for-state FAILED
    </copy>
    ````
    ````
    <copy>
    cd $HOME
    rm -rf video-on-demand-with-nosql-database
    rm -rf video-on-demand-with-nosql-database.zip
    </copy>
    ````

3. Exit from Cloud Shell

## Task 2: Delete resources created using Console


This task deletes the resources that got created.

1. On the top left, go to menu, then Databases, then under Oracle NoSQL Database, hit 'Tables'
Set your compartment to 'demonosql'
Click on the Test table, which will bring up the table details screen.  Hit Delete.

  ![Table](./images/delete-test-table.png)

  Deleting tables is an async operation, so you will not immediately see the results on the OCI console.  Eventually the status of the tables will get changed to deleted.  

2. On the top left, go to menu, then Developer Services and then Containers & Artifacts - Container Instances.

   In the Container instance screen, click on the gateway with the name `Oracle NoSQL powers Video On-Demand applications`.
   Click on Delete

   ![Container Instance](./images/delete-ci.png)

   Wait until the status changed from Deleting to Deleted

   ![Container Instance](./images/delete-ci-2.png)

## Task 3: Delete resources created using Resource Manager - terraform


1.  Clean up from the deployment.   In the top left corner, hit the OCI drop down menu, then go to 'Developer Services' and then Stacks under Resource manager.

  ![Select Resource Manager Stacks](https://oracle-livelabs.github.io/common/images/console/developer-resmgr-stacks.png)

2.  In the Stacks screen, click on the stack with the name video-on-demand-with-nosql-database.zip-xxxxxx.

  ![Stack](./images/main-zip.png)

3.  This will bring you to the stacks detail page.  On that screen hit the 'Destroy' button.  This will then pop up another window where you will have to hit 'Destroy' again.    This process takes 1-2 minutes to run and clean everything up.  

  ![Destroy Stack](./images/destroy-stack.png)

4.  When the destroy task will show Succeeded, return to the stack page.

5. Click on more actions and delete stack  

    ![Delete Stack](./images/destroy-stack-2.png)

## Acknowledgements
* **Author** - Dario Vega, Product Manager, NoSQL Product Management and Michael Brey, Director, NoSQL Product Development
* **Last Updated By/Date** - Dario Vega, Product Manager, NoSQL Product Management, April 2023
