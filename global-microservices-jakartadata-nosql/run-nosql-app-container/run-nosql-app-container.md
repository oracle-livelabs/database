# Deploy the Book Management Catalog Microservice with Container Instances

## Introduction

This lab picks up where lab 3 left off. We will explore another deployment option using Container Instances.

Oracle Cloud Infrastructure (OCI) Container Instances is a serverless compute service that enables you to quickly and easily run containers without managing any servers. Container Instances provide serverless compute optimized for container workloads with the same isolation as virtual machines.

Container Instances are suitable for containerized workloads that do not require a container orchestration platform like Kubernetes. These use cases include APIs, web applications, CI/CD jobs, cloud operations automation, data/media processing, development or test environments, and more.

_Estimated Time:_ 20 minutes

### Objectives

* Deploy the application using Container Instances.
* Read data with REST API deployed in the new Container Instances.

### Prerequisites

* An Oracle Free Tier, Paid Account, or Green Button
* Connection to the Oracle NoSQL Database Cloud Service
* Working knowledge of bash shell
* Working knowledge of SQL language

## Task 1: Review the Code Using OCI Code Editor

In this task, we will review the code using the OCI Code Editor.

1. Open the OCI Code Editor in the top-right menu.

   ![Cloud Editor](https://oracle-livelabs.github.io/common/images/console/cloud-code-editor.png)

2. Open `microprofile-config.properties` in the directory `books-management/src/main/resources/META-INF/`. This file configures the database connection and deployment settings, providing flexibility for different environments.

   ![Code createTable](./images/appl-properties.png)

   Let us take a look at the class ` microprofile-config.properties` again. In the previous lab, we ran the application code using Cloud Shell and used delegation tokens.
   In this lab, we are going to be running application using Resource Principals.

    As discussed in the Lab 2 - Task 4: Understand Credentials, and Policies. To use them you have to set up a dynamic group and create a policy
    that grants the dynamic group access to a resource. We did it for you in Lab 2 - Task 3: Deploy Infrastructure using Terraform.
    Take a look at the policy.tf file in the following directory books-management.


    **Note**: When deploying using OKE - see Lab 1, you will connect using Instance Principals. This authentication procedure is beyond the scope of this workshop but if you want to learn more, then read the `oracle-app-ndcs-deployment.yaml`    

3. Review the `Dockerfile` in the `books-management` directory. This file defines the instructions for building the container image for the Book Management application.

    In this Lab, we will use a container image that we deployed in GitHub Container Registry

4. Review the GitHub Actions script used to build and push the container image to GitHub Container Registry.

    For details on container deployment, see [this GitHub link](https://github.com/oracle/nosql-examples/blob/master/.github/workflows/build-and-push-demo-book-image.yml).  

After reviewing the code, you can close the Code Editor.

## Task 2: Restart the Cloud Shell

1. Open the Cloud Shell. If you minimized it earlier, expand it. If it is disconnected or timed out, restart it.

   ![Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png)

2. Execute the following setup shell script in Cloud Shell to set up your environment. Please copy the values for `OCI_REGION` and `OCI_NOSQL_COMPID` (labeled `NOSQL_REGION` and `NOSQL_COMPID` in your environment):

    ```shell
    <copy>
    source ~/books-management/env.sh
    </copy>
    ```
   ![Cloud Shell](./images/cloud-shell-result.png)

   Minimize the Cloud Shell.

## Task 3: Deploy Container Instances

1. In the left side menu (under the Oracle Cloud banner), go to Developer Services and select **Containers & Artifacts** - **Container Instances**.

   ![Open Containers & Artifacts](images/menu-container-instance.png)

2. Click on **Create Container Instance**. In the new window, enter **Book Management Catalog with OCI and NoSQL** as the name. Ensure the compartment is `demonosql`. Verify the 'Networking' section as shown below. Click **Next**.

   ![Create Container Instances](images/create-container-instance-1.png)

3. Enter **demo-nosql-book-management-app** as the name. Click **Select Image**, choose **External Registry**, and enter:
    - **Registry hostname**: `ghcr.io`
    - **Repository**: `oracle/demo-nosql-book-example-app`

    Then, click **Select Image** at the bottom of the screen.

    ![Create Container Instances](images/create-container-instance-2.png)

4. Scroll down and add the following environment variables:
    - `NOSQL_DEPLOYMENT` as key and `CLOUD_RESOURCE_PRINCIPAL` as value
    - `OCI_REGION` as key with the value copied in Task 2
    - `OCI_NOSQL_COMPID` as key with the value copied in Task 2

    ![Create Container Instances](images/create-container-instance-3.png)

5. Click **Next**, review the setup, and then click **Create**.

   ![Create Deployment](images/create-container-instance-4.png)

6. Wait a few seconds for the deployment to complete. The status will change from **Creating** to **Active**.

   ![Create Deployment](images/create-container-instance-5.png)

7. Copy the Public IP address of the container instance.


## Task 4: Read Data and Examine It

1. Set up the Cloud Shell environment again.

    ```shell
    <copy>
    source ~/books-management/env.sh
    </copy>
    ```

2. Set the `IP_CI` environment variable to the Public IP address of the container instance.

    ```shell
    <copy>
    export IP_CI=<copied Public IP address>
    </copy>
    ```

3. Use the REST API to read data from the Book Management application running in the container:

    ```shell
    <copy>
    curl http://$IP_CI:8080/books | jq
    </copy>
    ```

   This will display all the rows in the table. You can execute additional queries as needed.

4. Exit the Cloud Shell

You may now **proceed to the next lab.**


## Learn More

* [Oracle NoSQL Database Cloud Service](https://www.oracle.com/database/nosql-cloud.html)
* [About Oracle NoSQL Database Cloud Service](https://docs.oracle.com/en/cloud/paas/nosql-cloud/index.html)
* [About Container Instances](https://docs.oracle.com/en-us/iaas/Content/container-instances/home.htm)

## Acknowledgements

* **Authors** - Dario Vega, Product Manager, NoSQL Product Management; Otavio Santana, Award-winning Software Engineer and Architect
