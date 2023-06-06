# Run an XA sample application

## Introduction

Run the XA sample application to transfer an amount from one department to another and to understand how you can use Transaction Manager for Microservices (MicroTx) to coordinate XA transactions.

The sample application code is available in the MicroTx distribution. The MicroTx library files are already integrated with the sample application code.

Estimated Lab Time: *20 minutes*

### About XA Sample Application

The following figure shows a sample XA application, which contains several microservices.
![Microservices in the XA sample applications](./images/stock_broker_xa_app.png)

The sample application demonstrates how you can develop microservices that participate in XA transactions while using MicroTx to coordinate the transactions. When a user purchases stocks using the Stock Broker service, it withdraws money from the Core Banking Service and deposits an equivalent amount of stocks by creating an XA transaction. Within the XA transaction, all actions such as purchase, sale, withdraw, and deposit either succeed, or they all are rolled back in case of a failure of any one or more actions.

### Objectives

In this lab, you will:

* Build container images for each microservice from the XA sample application code. After building the container images, the images are available in your Minikube container registry.
* Update the `values.yaml` file, which contains the deployment configuration details for the XA sample application.
* Install the Sample XA Application. While installing the sample application, Helm uses the configuration details you provide in the `values.yaml` file.
* Deploy Kiali and Jaeger in your minikube cluster (Optional and if not already deployed)
* Run an XA transaction to withdraw an amount from Department A and deposit it in Department B.
* View service graph of the mesh and distributed traces to track requests (Optional)
* View source code of the sample application (Optional)

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account.
* Successfully completed the previous labs:
  * Get Started
  * Lab 1: Prepare setup
  * Lab 2: Environment setup
  * Lab 4: Provision an Oracle Autonomous Database for use as resource manager
* Logged in using remote desktop URL as an `oracle` user. If you have connected to your instance as an `opc` user through an SSH terminal using auto-generated SSH Keys, then you must switch to the `oracle` user before proceeding with the next step.

  ```text
  <copy>
  sudo su - oracle
  </copy>
  ```

## Task 1: Configure Minikube and Start a Tunnel

Before you start a transaction, you must start a Minikube tunnel.

1. Ensure that the minimum required memory and CPUs are available for Minikube.
    ```text
    <copy>
    minikube config set memory 32768
    </copy>
    ```

2. Start Minikube.
    ```text
    <copy>
    minikube start
    </copy>
    ```

3. Run the following command in a new terminal to start a tunnel. Keep this terminal window open.

    ```text
    <copy>
    minikube tunnel
    </copy>
    ```

4. Enter the password to access your local machine if you are prompted to enter your password.

5. In a new terminal, run the following command to note down the external IP address of the Istio ingress gateway.

    ```text
    <copy>
    kubectl get svc istio-ingressgateway -n istio-system
    </copy>
    ```

    From the output note down the value of `EXTERNAL-IP`, which is the external IP address of the Istio ingress gateway. You will provide this value in the next step.

    **Example output**

    ![Public IP address of ingress gateway](./images/ingress-gateway-ip-address.png)

    Let's consider that the external IP in the above example is 192.0.2.117.

6. Store the external IP address of the Istio ingress gateway in an environment variable named `CLUSTER_IPADDR` as shown in the following command.

    ```text
    <copy>
    export CLUSTER_IPADDR=192.0.2.117
    </copy>
    ```

    Note that, if you don't do this, then you must explicitly specify the IP address in the commands when required.


## Task 2: Configure Keycloak

1. Run the following command to note down the external IP address and port to access Keycloak.

    ```text
    <copy>
    kubectl get svc -n keycloak
    </copy>
    ```

    From the output note down the value of `EXTERNAL-IP` and `PORT(S)`, which is the external IP address and port of Keycloak. You will provide this value in the next step.

    **Example output**

    ![Public IP address of Keycloak](./images/keycloak-ip-address.png)

    Let's consider that the external IP in the above example is 198.51.100.1 and the IP address is 8080.

2. Sign in to Keycloak. In a browser, enter the IP address and port number that you have copied in the previous step. The following example provides sample values. Provide the values based on your environment.

    ```text
    http://198.51.100.1:8080
    ```

3. Click **Administration Console**.

4. Sign in to Keycloak with the initial administrator username `admin` and password `admin`. After logging in, reset the password for the `admin` user. For information about resetting the password, see the Keycloak documentation.

6. Select the **MicroTx-BankApp** realm, and then click **Users** to view the list of users in the `MicroTx-BankApp` realm. The `MicroTx-BankApp` realm is preconfigured with these default user names.
   ![Dialog box to view the list of Users](./images/keycloak-users.png)

7. Set the password for each user. For information about providing credentials for users, see the Keycloak documentation.

8. Click **Clients**, and then click **microtx-bankapp** in the **Clients list** tab.
    ![Dialog box to Create a Realm](./images/keycloak-select-client.png)

    Details of the `microtx-bankapp` client are displayed.

9. In the **Settings** tab, under **Access settings**, enter the external IP address of Istio ingress gateway for the **Root URL**, **Valid redirect URIs**, **Valid post logout redirect URIs**, and **Admin URL** fields. Provide the IP address of Istio ingress gateway that you have copied earlier.
    ![Access Settings group in the Settings tab](./images/keycloak-client-ip.png)

10. Click **Save**.

11. Click the **Credentials** tab, and then note down the value of the **Client-secret**. You'll need to provide this value later.
    ![Access Settings group in the Settings tab](./images/keycloak-client-secret.png)

12. Click **Realm settings**, and then in the **Frontend URL** field of the **General** tab, enter the external IP address and port of the Keycloak server which you have copied in a previous step. For example, `http://198.51.100.1:8080`.
    ![General Realm Settings](./images/keycloak-url.png)

13. In the **Endpoints** field, click the **OpenID Endpoint Configuration** link. Configuration details are displayed in a new tab.

14. Note down the value of the **issuer** URL. It is in the format, `http://<keycloak-ip-address>:<port>/realms/<name-of-realm-you-have-created>`. For example, `http://198.51.100.1:8080/realms/MicroTx-Bankapp`. You'll need to provide this value later.

15. Click **Save**.

16. Open the `values.yaml` file, which is located in the `/home/oracle/microtx/otmm-22.3.2/samples/xa/java/bankapp/Helmcharts` folder. This file contains sample values. Enter the values that you have noted down for the following fields under `security` in `UserBanking`.

    * `clientSecret`: Enter the value of the client secret value that you had copied in step 11.
    * `issuerURL`: Enter the URL that you had copied in step 14.
    * `logoutRedirectURL`: Enter the URL in the format, `http://$CLUSTER_IPADDR/bankapp`. Where, `CLUSTER_IPADDR` is the external IP address of the Istio ingress gateway that you have noted down in Task 1. For example, `http://192.0.2.117/bankapp`.

17. Save the changes you have made to the `values.yaml` file.

## Task 3: Build the Container Images for Sample XA Applications

The code for the XA sample application is available in the installation bundle in the `/home/oracle/microtx/otmm-22.3.2/samples/xa/java/bankapp` folder. Build container images for each microservice in the XA sample application.

To build container images for each microservice in the sample:

1. Run the following commands to build the container image for the Branch Banking service.

    ```text
    <copy>
    cd /home/oracle/microtx/otmm-22.3.2/samples/xa/java/bankapp/BranchBanking
    </copy>
    ```

    ```text
    <copy>
    minikube image build -t branch-banking:1.0 .</copy>
    ```

   When the image is successfully built, the following message is displayed.

   **Successfully tagged branch-banking:1.0**

2. Run the following commands to build the container image for the Core Banking service.

    ```text
    <copy>
    cd /home/oracle/microtx/otmm-22.3.2/samples/xa/java/bankapp/CoreBanking
    </copy>
    ```

    ```text
    <copy>
    minikube image build -t core-banking:1.0 .
    </copy>
    ```

   When the image is successfully built, the following message is displayed.

   **Successfully tagged core-banking:1.0**

3. Run the following commands to build the Docker image for the Stock Broker service.

    ```text
    <copy>
    cd /home/oracle/microtx/otmm-22.3.2/samples/xa/java/bankapp/StockBroker
    </copy>
    ```

    ```text
    <copy>
    minikube image build -t stockbroker:1.0 .
    </copy>
    ```

   When the image is successfully built, the following message is displayed.

   **Successfully tagged stockbroker:1.0**

The container images that you have created are available in your Minikube container registry.

## Task 4: Update the values.yaml File

The sample application files also contain the `values.yaml` file. This is the manifest file, which contains the deployment configuration details for the XA sample application.

The `values.yaml` file provides details about the Docker images of each microservice, the credentials to use when pulling the Docker images, and details to access the resource managers. While installing the sample application, Helm uses the values you provide to pull the sample application images from the Minikube container registry.

To provide the configuration and environment details in the `values.yaml` file:

1. Open the `values.yaml` file, which is located in the `/home/oracle/microtx/otmm-22.3.2/samples/xa/java/bankapp/Helmcharts` folder, in any code editor. This file contains sample values. Replace these sample values with values that are specific to your environment.

2. Under `StockBroker`, set `deploymentEnabled` to `true`. You must set this flag to true before deploying the Stock Broker service.

3. Save your changes.

## Task 5: Install the Sample XA Application

Install the XA sample application in the `otmm` namespace, where you have installed MicroTx. While installing the sample application, Helm uses the configuration details you provide in the values.yaml file.

1. Run the following commands to install the XA sample application.

    ```text
    <copy>
    cd /home/oracle/microtx/otmm-22.3.2/samples/xa/java/bankapp/Helmcharts
    </copy>
    ```

    ```text
    <copy>
    helm install bankapp --namespace otmm bankapp/ --values bankapp/values.yaml
    </copy>
    ```

   Where, `bankapp` is the name of the application that you want to install. You can provide another name to the installed application.

   In the output, verify that the `STATUS` of the `bankapp` is `deployed`.

   **Example output**

    ```text
    NAME: bankapp
    LAST DEPLOYED: TUe May 23 10:52:14 2023
    NAMESPACE: otmm
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```

2. If you don't need to make any changes to the `values.yaml` file, skip this step and go to the next step. If you need to modify the `values.yaml` file, then uninstall `bankapp`. Update the `values.yaml` file, and then reinstall `bankapp`. Perform step 1 as described in this task again to reinstall `bankapp`.

    ```text
    <copy>
    helm uninstall sample-xa-app --namespace otmm
    </copy>
    ```

3. Verify that all resources, such as pods and services, are ready. Proceed to the next step only when all resources are running. Run the following command to retrieve the list of resources in the namespace `otmm` and their status.

    ```text
    <copy>
    kubectl get pods -n otmm
    </copy>
    ```
    The following image shows a sample output.
   ![Get details of the pods and services](./images/get-pods-details.png)

## Task 6: Deploy Kiali and Jaeger (Optional)

Optionally, you can use Kiali and Jaeger to track and trace distributed transactions in MicroTx through visualization. Use distributed tracing to track how requests flow between MicroTx and the microservices.

Run the following commands to deploy Kiali and Jaeger in a Minikube cluster.

1. Deploy Kiali.

    ```text
    <copy>
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/kiali.yaml
    </copy>
    ```

2. Deploy Prometheus. To use Kiali, you must deploy Prometheus and Kiali in the same cluster.

    ```text
    <copy>
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/prometheus.yaml
    </copy>
    ```

3. Deploy Jaeger.

    ```text
    <copy>
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/jaeger.yaml
    </copy>
    ```

4. Start the Kiali Dashboard. Run the following command in a new terminal. Ensure that you leave this terminal open. If a new browser opens, close the browser.

    ```text
    <copy>
    istioctl dashboard kiali
    </copy>
    ```

   From the output, note down the URL. This is the URL on which you can access the Kiali dashboard in a browser. For example, `http://localhost:20001/kiali`.

5. Start the Jaeger Dashboard. Run the following command in a new terminal. Ensure that you leave this terminal open. If a new browser opens, close the browser.

    ```text
    <copy>
    istioctl dashboard jaeger
    </copy>
    ```

   From the output, note down the URL. This is the URL on which you can access the Jaeger dashboard in a browser. For example, `http://localhost:16686`.

## Task 7: Run an XA Transaction

Run an XA transaction When you run the Teller application, it withdraws money from one department and deposits it to another department by creating an XA transaction. Within the XA transaction, all actions such as withdraw and deposit either succeed, or they all are rolled back in case of a failure of any one or more actions.

1. Access the bank application. In a browser, type `192.0.2.117/bankapp`, where `192.0.2.117` is the external IP address of the Istio ingress gateway which you have noted down in Task 1.
    The Keycloak login page is displayed.

2. Enter the username and password to access the Keycloak instance which you have configured in Task 2.
    The Bank and Trading application's Console is displayed as shown in the following figure.
    ![Microservices in the XA sample applications](./images/stock_broker_app_landingpage.png)

3.  Click **Trading**.
    The Stock Trading page is displayed as shown in the following image.
    ![Microservices in the XA sample applications](./images/stock_broker_app_tradepage.png)

4. Click **Buy Stocks**.



Before you start the transaction, run the following commands to check the balance in Department 1 and Department 2 accounts.

    **Example command to check balance in Department 1**

    ```text
    <copy>
    curl --location \
    --request GET http://$CLUSTER_IPADDR/dept1/account1 | jq
    </copy>
    ```

   **Example command to check balance in Department 2**

    ```text
    <copy>
    curl --location \
    --request GET http://$CLUSTER_IPADDR/dept2/account2 | jq
    </copy>
    ```

2. Transfer an amount of 50 from Department 1, account1 to Department 2, account2.

    **Example command**

    ```text
    <copy>
    curl --location \
    --request POST http://$CLUSTER_IPADDR/transfers \
    --header 'Content-Type: application/json' \
    --data-raw '{"from" : "account1", "to" : "account2", "amount" : 50}'
     </copy>
    ```

    HTTP status 200 in the response indicates that the transfer was successfully completed.

3. Check balances in Department 1, account1 and Department 2, account2 to verify that the amounts reflect correctly after the transaction. Run the following commands to confirm the transaction.

    **Example command to check balance in Department 1**

    ```text
    <copy>
    curl --location \
    --request GET http://$CLUSTER_IPADDR/dept1/account1 | jq
    </copy>
    ```

    **Example command to check balance in Department 2**

    ```text
    <copy>
    curl --location \
    --request GET http://$CLUSTER_IPADDR/dept2/account2 | jq
    </copy>
    ```

4. Transfer an amount of 50 from Department 1, account1 to an account that does not exist in Department 2, such as account7. Since account7 does not exist, the deposit fails and MicroTx rolls back the withdraw action.

    **Example command**

    ```text
    <copy>
    curl --location \
    --request POST http://$CLUSTER_IPADDR/transfers \
    --header 'Content-Type: application/json' \
    --data-raw '{"from" : "account1", "to" : "account7", "amount" : 50}'
    </copy>
    ```

5. Check the balance in Department 1, account 1 to verify that the account balance is correct, and no amount was withdrawn.

   **Example command**

    ```text
    <copy>
    curl --location \
    --request GET http://$CLUSTER_IPADDR/dept1/account1 | jq
    </copy>
    ```
## Task 8: View Service Mesh graph and Distributed Traces (Optional)

You can perform this task only if you have deployed Kiali and Jaeger in your cluster.
To visualize what happens behind the scenes and how a trip booking request is processed by the distributed services, you can use the Kiali and Jaeger Dashboards that you started in Task 3.

1. Open a new browser tab and navigate to the Kiali dashboard URL - http://localhost:20001/kiali
2. Select Graph for the otmm namespace.
3. Open a new browser tab and navigate to the Jaeger dashboard URL - http://localhost:16686
4. In the **Service** drop-down list, select **istio-ingressgateway**. A list of traces is displayed where each trace represents a request.
5. Select a trace to view it.

## Task 9: View Source Code of the Sample Application (Optional)
The source code of the sample application is present in folder: /home/oracle/OTMM/otmm-22.3.2/samples/xa/java/bankapp
- Teller Service Source code: /home/oracle/OTMM/otmm-22.3/samples/xa/java/teller
- Department 1 Service Source code: /home/oracle/OTMM/otmm-22.3/samples/xa/java/department-helidon
- Department 2 Service Source code: /home/oracle/OTMM/otmm-22.3/samples/xa/java/department-spring

You can use the VIM editor to view the source code files. You can also use the Text Editor application to view the source code files.
To bring up the Text Editor, click on Activities (top left) -> Show Applications -> Text Editor. Inside Text Editor, select Open a File and browse to the source code files in the folders shown above.


## Learn More

* [Develop Applications with XA](http://docs.oracle.com/en/database/oracle/transaction-manager-for-microservices/22.3/tmmdg/develop-xa-applications.html#GUID-D9681E76-3F37-4AC0-8914-F27B030A93F5)

## Acknowledgements

* **Author** - Sylaja Kannan, Principal User Assistance Developer
* **Contributors** - Brijesh Kumar Deo, Bharath MC
* **Last Updated By/Date** - Sylaja, June 2023
