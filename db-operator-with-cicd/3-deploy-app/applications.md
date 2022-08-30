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

1. Login to your tenancy's OCI Registry (OCIR) to authorize the pushing of application images to OCIR. For help on how to retrieve the information below on the console, click on the dropdown below. When prompted for the password, retrieve and provide from your notes the Auth token you copied earlier as the password.


     ```bash
     <copy>
     docker login <region-key>.ocir.io
     </copy>
     ```

     ```bash
     # Example Output
     docker login phx.ocir.io
     Username: your_tenancy_namespace/labuserexample
     Password: <auth-token>
     ...

     Login Succeeded
     ```

  ## How to get the region key
     
     The region key is a shortened form of your region. For example, the region us-phoenix-1 will have a region key of PHX; the region us-ashburn-1 will have a region key of IAD. You can view the list of regions and their keys [here](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#About:~:text=and%20Availability%20Domains-,About%20Regions%20and%20Availability%20Domains,-Fault%20Domains). 

     Alternatively, you can also run the following command which leverages the OCI CLI on Cloud Shell:

     ```bash
     <copy>
     oci iam region list | jq -r --arg REGION $(state_get .lab.region.identifier) '.data[] | select (.name == $REGION) | .key '
     </copy>
     ```
     <strong style="color: #C74634">Note</strong>: Region Keys should be lowercase when running `docker login.`

  ## How to get the tenancy namespace

     The tenancy namespace is not always the same as the tenance name. To retrieve it, on the OCI Console, you can click on your Profile (top-right user icon) and navigate to `Tenancy: <your_tenancy>`. This will open the Tenancy page on the console, from which you can copy the Object Storage namespace.

     ![Get Tenancy Namespace](./images/get-tenancy-namespace.png)

     Alternatively, you can also run the following command which leverages the OCI CLI on Cloud Shell:

     ```bash
     <copy>
     oci os ns get | jq -r .data
     </copy>
     ```

  ## How to get your username
     
     To retrieve your username, on the OCI Console, click on your your Profile (top-right user icon) and click on your username. Your username should then be displayed at the top.

     ![Get Username](./images/get-username.png)

     <strong style="color: #C74634">Note</strong>: Your username will include oracleidentitycloudservice if you are logged in as a federated user. Include this part as your username along with the forward slash.

     Alternatively, you can also run the following command which leverages the OCI CLI on Cloud Shell:

     ```bash
     <copy>
     oci iam user get --user-id $(state_get .lab.ocid.user) | jq -r .data.name
     </copy>
     ```

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
kubectl get deploy
</copy>
```
The above command will give an output similar to what is shown in the below image:

![Kubectl Get Deploy](./images/kubectl-get-deploy.png)

1. Retrieve the `EXTERNAL IP` by running the below command. This will show a table of values for the frontend-service of type LoadBalancer. Copy the value under `EXTERNAL-IP`.

     ```bash
     <copy>
     kubectl get svc frontend-service 
     </copy>
     ```

2. View the microservices app by navigating to the website with the IP address
     ```bash
     <copy>
     https://<ip-address>
     </copy>
     ```

3. You will be prompted by the application to login. Use `cloudbank` as the username and the password you provided earlier on during setup. 

     Username: `cloudbank`

     Password: `<your-frontend-login-password>`

4. Try out the application by making a transfer request. Copy the following request

    ![Cloudbank Application MAke Transfer](images/make-transfer-request.png " ")

    Click on `Submit Transfer`. This will result in the following response you see on the right.
    
    ![Cloudbank Application Make Transfer Response](images/transfer-request-response.png " ")

You may now **proceed to the next lab.**.

## Acknowledgements

* **Authors** - Norman Aberin, Developer Advocate
* **Last Updated By/Date** - Developer Advocate, August 2022
