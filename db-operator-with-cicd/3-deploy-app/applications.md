# Deploy the Microservices App

## Introduction

<!-- This lab will demonstrate how to integrate Jenkins with GitHub and Oracle Cloud Infrastructure Services and build a pipeline.

GitHub provides webhook integration, so Jenkins starts running automated builds and tests after each code check-in. A sample web application Grabdish is modified and re-deployed as part of the CI/CD pipeline, which end users can access from the Container Engine for the Kubernetes cluster. -->

Estimated Time: XX minutes

### Objectives

<!-- * Execute GitHub Configuration
* Execute Jenkins Configuration
* Configure a Pipeline -->

### Prerequisites

* This lab presumes you have already completed the earlier labs.

## Task 1: Prepare for Application Deployment

1. Login to your tenancy's OCI Registry (OCIR) to authorize the pushing of application images to OCIR. For help on how to retrieve the information below on the console, click on the dropdown below. When prompted, provide the Auth token you copied earlier as the password.


     ```bash
     <copy>
     docker login <region-key>.ocir.io
     </copy>
     ```

     ```bash
     # Example
     docker login phx.ocir.io
     Username: tenancyObjectStorageNamespace/username
     Password: <auth-token>

     Login Succeeded
     ```

 ## How to Login to OCIR from the Docker CLI



## Task 2: Build and Deploy the applications

1. To build the front-end and back-end applications, you can simply run the following:

     ```bash
     <copy>
     (cd $CB_STATE_DIR ; ./cloudbank-build.sh)
     </copy>
     ```

2. Once the applicatoin successfully builds, deploy the application by running

     ```bash
     <copy>
     (cd $CB_STATE_DIR ; ./cloudbank-deploy.sh)
     </copy>
     ```

## Task 3: Navigate through the CloudBank Application

To view the application deployments, you can run:

```bash
<copy>
kubectl get all
</copy>
```

1. Retrieve the `EXTERNAL IP` by running the below command. Navigate to the address

     ```bash
     <copy>
     kubectl get svc frontend-service 
     </copy>
     ```

2. View the microservices website by navigating to
     ```bash
     <copy>
     https://<ip-address>
     </copy>
     ```

3. You will be prompted by a login modal. Use `cloudbank` as the username and the password you provided earlier on. 

     Username: `cloudbank`

     Password: `<your-frontend-login-password>`

4. Try out the application by making a transfer request. Copy the following request

    ![Cloudbank Application MAke Transfer](images/make-transfer-request.png " ")

    Click on `Submit Transfer`. This will result in the following response you see on the right.
    
    ![Cloudbank Application Make Transfer Response](images/transfer-request-response.png " ")

You may now **proceed to the next lab.**.

## Acknowledgements

* **Authors** - Irina Granat, Consulting Member of Technical Staff, Oracle MAA and Exadata; Norman Aberin, Member of Technical Staff
* **Last Updated By/Date** - Irina Granat, June 2022
