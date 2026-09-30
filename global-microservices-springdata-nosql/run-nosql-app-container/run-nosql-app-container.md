# Deploy the MovieStream Catalog Microservice with Container Instances

## Introduction

This lab picks up where lab 3 left off. We are going to explore in more detail
another possibility to deploy the application - use Container Instances.

Oracle Cloud Infrastructure (OCI) Container Instances is a serverless compute service
that enables you to quickly and easily run containers without managing any servers.
Container Instances runs your containers on serverless compute optimized for container
workloads that provides the same isolation as virtual machines.

Container Instances are suitable for containerized workloads that do not require a
container orchestration platform like Kubernetes. These use cases include: APIs,
web applications, build and deployment jobs in CI/CD pipelines, automation tasks for cloud operations, data/media processing jobs, development or test environments, and more.

_Estimated Time:_ 20 minutes

[Lab 4 Walkthrough](videohub:1_7yxajmgz)

### Objectives

* Deploy the application using Container Instances
* Read data with REST API deployed in the new Container Instances

### Prerequisites

* An Oracle Free Tier, Paid Account or Green Button
* Connection to the Oracle NoSQL Database Cloud Service
* Working knowledge of bash shell
* Working knowledge of SQL language


## Task 1: Review the code using OCI Code Editor

In this task we will review the code using OCI Code Editor.

1. Open the OCI Code Editor in the top right menu.

    ![Cloud Editor](https://oracle-livelabs.github.io/common/images/console/cloud-code-editor.png)


2. Go to the Code Editor, and open the file `AppConfig.java` in the following directory
`global-microservices-springdata-nosql/code-nosql-spring-sdk/src/main/java/com/oracle/nosql/springdatarestnosql` as shown in the screen-shot:

    ![Code](./images/appl-code-connection.png)

   Let's take a look at the class `AppConfig` again.  In the
   previous lab, we ran the application code using Cloud Shell and used
   **delegation tokens**.  In this lab, we are going to be running
   application using **Resource Principals**.

    * As discussed in the Lab 2 - Task 4: Understand Credentials, and Policies.
To use them you have to set up a dynamic group and create a policy that grants
the dynamic group access to a resource.
We did it for you in **Lab 2 - Task 3: Deploy Infrastructure using Terraform**.
Take a look at the `policy.tf` file in the following directory `global-microservices-springdata-nosql`.
    * In this Lab, we will use a container image that we deployed in GitHub Container Registry.
Take a look at the `Dockerfile` in the following directory `global-microservices-springdata-nosql/code-nosql-spring-sdk`, and [check here](https://github.com/oracle/nosql-examples/blob/master/.github/workflows/build-and-push-demo-movie-image.yml) to review the yml script used to build the container image.

    * Note: When deploying using OKE - see Lab 1, you will do the connection using **Instance Principals**. It is not the topic of this workshop but if you
want to learn more, then read the `oracle-app-ndcs-deployment.yaml` file in the following directory `global-microservices-springdata-nosql`. [Check here](https://github.com/oracle/nosql-examples/blob/master/.github/workflows/deploy-oke-oci-cli-demo-movie.yml) to learn how to deploy using GitHub Actions.

When you are done looking at code, go ahead and exit from the Code Editor.

## Task 2: Restart the Cloud Shell

1. Let's get back into the Cloud Shell. From the earlier lab, you may have
minimized it in which case you need to enlarge it. It is possible it may have
become disconnected and/or timed out. In that case, restart it.

    ![Cloud Shell](https://oracle-livelabs.github.io/common/images/console/cloud-shell.png)

2. Execute the following environment setup shell script in the Cloud Shell to
set up your environment. Please copy the values for `OCI_REGION(labeled: NOSQL_REGION)` and `OCI_NOSQL_COMPID.`

    ```shell
    <copy>
    source ~/global-microservices-springdata-nosql/env.sh
    </copy>
    ```
    ![Cloud Shell](./images/cloud-shell-result.png)

    Minimize the Cloud Shell.

## Task 3: Deploy Container Instances


 1. On left side drop down (under the Oracle Cloud banner), go to Developer Services and then Containers & Artifacts - Container Instances.

     ![Open Containers & Artifacts](images/menu-container-instance.png)

 2. Click on Create Container Instances. This opens up a new window.

   Enter **Creating Scalable, Global Microservices with OCI, Spring Data, and NoSQL** as the name.
   Other information does not need to be changed for this LiveLab. Please ensure the compartment is `demonosql.` Verify the 'Networking' section looks similar to the image below.  If not, make the necessary adjustments by opening the 'Networking' section, checking and then collapsing it. Click **Next.**

     ![Create Container Instances](images/create-container-instance-1.png)

    Enter **demo-nosql-movie-example-app** as the name.  Click on **select image**, and
    a new screen appears.  Choose **external registry**, and
    enter **ghcr.io** as Registry hostname, **oracle/demo-nosql-movie-example-app** as Repository and Click **Select Image** at bottom of screen.

       ![Create Container Instances](images/create-container-instance-2.png)

    Scroll down and add the following environment variables:
     - `NOSQL_SERVICETYPE` as a key and `useResourcePrincipal` as a value
     - `OCI_REGION` as a key and the value copied in Task 2 as a value
     - `OCI_NOSQL_COMPID` as a key and the value copied in Task 2 as a value

     ![Create Container Instances](images/create-container-instance-3.png)

   Click **Next.**

 3. Review and Click on create.

     ![Create Deployment](images/create-container-instance-4.png)

 4. Wait few second until the deployment is created - Status will change from **Creating** to **Active.**

     ![Create Deployment](images/create-container-instance-5.png)

   Please copy the Public IP address.


## Task 4: Read Data and Examine It

1. Execute the following environment setup shell script in the Cloud Shell to set up your environment.

    ```shell
    <copy>
    source ~/global-microservices-springdata-nosql/env.sh
    </copy>
    ```
Set the variable IP_CI with the Public IP address value copied in Task 3. Execute in the Cloud Shell.

    ```shell
    <copy>
    export IP_CI=<copied Public IP address>
    </copy>
    ```
    **Note:** The "movie stream catalog" application is running in the container.

2. Read back the data that we entered in the Lab 4 using the REST queries.
Execute in the Cloud Shell.

    ```shell
    <copy>
    curl  http://$IP_CI:8080/api/movie | jq
    </copy>
    ```

    This will display all the rows in the table currently. You can execute the same queries that we ran in the Lab 3.

Exit out of the Cloud Shell. You may now **proceed to the next lab.**

## Learn More


* [Oracle NoSQL Database Cloud Service page](https://www.oracle.com/database/nosql-cloud.html)
* [About Oracle NoSQL Database Cloud Service](https://docs.oracle.com/en/cloud/paas/nosql-cloud/index.html)
* [About Container Instances](https://docs.oracle.com/en-us/iaas/Content/container-instances/home.htm)


## Acknowledgements
* **Author** - Dario Vega, Product Manager, NoSQL Product Management; Michael Brey, Director, NoSQL Product Development, July 2024
