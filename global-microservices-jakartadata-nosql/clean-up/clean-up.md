# Clean Up

## Introduction

This lab is completed. We will delete all resources created.

_Estimated Time:_ 5 minutes

## Task 1: Delete resources created using Cloud Shell

In this task we will delete the resource created using the Cloud Shell.

1. Open the **Cloud Shell** in the top-right menu to get the Cloud Shell started.

  ![Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png)

2. Execute the following in your Cloud Shell.  This is issuing a **table delete** command to delete the Movie table.

    ```
    <copy>
    source ~/books-management/env.sh
    oci nosql table delete --compartment-id "$OCI_NOSQL_COMPID" --table-name-or-id books \
    --wait-for-state SUCCEEDED --wait-for-state FAILED
    </copy>
    ```
    ```
    <copy>
    cd $HOME
    rm -rf books-management  
    rm -rf books-management.zip  
    rm -rf jdk-21.0.5
    </copy>
    ```

3. Exit from Cloud Shell.

## Task 2: Delete resources created using Console


This task deletes the resources that got created.

1. On the Oracle Cloud Infrastructure menu drop-down on the top left corner, go to **Databases**, then under Oracle NoSQL Database, hit 'Tables',
set your compartment to 'demonosql', click on the Test table, which will bring up the table details screen.  Click Delete.

  ![Table](./images/delete-test-table.png)

  Deleting tables is an async operation, so you will not immediately see the results on the OCI console.  Eventually the status of the table will get changed to deleted.  

2. On the Oracle Cloud Infrastructure menu drop-down on the top left corner, go to **Developer Services** and then Containers & Artifacts - Container Instances.

   In the Container instance screen, click on the container with the name `Book Management Catalog with OCI and NoSQL`. Under 'More actions' click on Delete.

   ![Delete Container Instance](./images/delete-ci.png)

   Wait until the status changed from 'Deleting' to 'Deleted'.

   ![Delete Container Instance](./images/delete-ci-2.png)

## Task 3: Delete resources created using Resource Manager - Terraform


1.  Clean up from the deployment.   In the top left corner, hit the OCI drop-down menu, then go to 'Developer Services' and then Stacks under Resource manager.

  ![Select Resource Manager Stacks](https://oracle-livelabs.github.io/common/images/console/developer-resmgr-stacks.png)

2.  In the Stacks screen, click on the stack with the name global-microservices-springdata-nosql.zip-xxxxxx.

  ![Stack](./images/main-zip.png)

3.  This will bring you to the stacks detail page.  On this screen, click the 'Destroy' button.  This will then pop up another window where you will have to hit 'Destroy' again.    This process takes 1-2 minutes to run and clean everything up.  

  ![Destroy Stack](./images/destroy-stack.png)

4.  When the "destroy-job" task shows Succeeded, return to the stack page.

5. Click on more actions and delete stack.  

    ![Delete Stack](./images/destroy-stack-2.png)

## Task 4: Delete the compartment created

1. Remove the 'demonosql' compartment. On the Oracle Cloud Infrastructure menu drop-down on the top left corner, go to **Identity and Security** then **Compartments** under 'Identity.'

    ![Delete Compartment](https://oracle-livelabs.github.io/common/images/console/id-compartment.png)

2. The 'Compartments' screen appears. Click the **demonosql** compartment

    ![Select demo NoSQL table](./images/select-demonosql.png)

3. Press the **Delete** button. This will fire off a job that runs asynchronously. It takes a while.

    ![Delete NoSQL Table](./images/delete-demonosql.png)


## Acknowledgements
* **Author** - Dario Vega, Product Manager, NoSQL Product Management
