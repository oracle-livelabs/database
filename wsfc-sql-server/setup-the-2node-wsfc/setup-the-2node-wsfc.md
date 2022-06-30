# In Compute Instance, create a two-node Windows Server Failover Cluster.

## Introduction

This lab walks you through the steps to create a Windows Server Failover Cluster.

A Failover Cluster is a group of independent computers that work together to increase the availability and scalability of clustered roles.

Estimated Time:  1 hour

### Objectives
In this lab, you will learn to :
* How to install the Failover Clustering features on the Windows server
* How to create the Private secondary IPs for Computer Instance VNICS
* How to configure the two-node Windows Failover Cluster

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment

##  Task 1: Install Failover Clustering features in Node1

1. Open the Remote Desktop client on the Bastion host and connect to the Node1 server using the private IP address using the **opc** user.

2. Click the **search button** in the taskbar, search for Server Manager, and then click on Server Manager.

  ![Windows command Search server manager](./images/windows-command-search.png "Windows command Search server manager")

3. Click on **Add roles and features**.

  ![Server manager add roles ad features](./images/windows-servermanager-add.png "Server manager add roles ad features")

4. The Add Roles and Features Wizard look like the following image. Click on **Next**.

  ![Server manager roles and features](./images/windows-servermanager-begin.png "Server manager roles and features")

5. Choose the Installation Type **Role-based or feature-based Installation**, click on **Next**.

  ![Server manager installation type](./images/windows-servermanager-installtype.png "Server manager installation type")

6. Choose the Server Selection Type **Select a server from the server pool**, click on **Next**.

  ![Server manager server pool](./images/windows-servermanager-serverselection.png "Server manager server pool")

7. Put a tick mark on **Failover Clustering** and click on **Add Features** to install the feature with dependency.

  ![Server manager features selection](./images/windows-servermanager-features.png "Server manager features selection")

  Click on **Next** to continue with the installation.

  ![Server manager features Failover Clustering](./images/windows-servermanager-features-install.png "Server manager features Failover Clustering")

8. The Confirmation will show the details for roles, role services, or features on selected servers, choose the **Restart the destination server automatically if required**, a pop up will appear to check on **yes** for auto restart, click on **Install** to proceed with the Installation.

  ![Server manager features installation confirmation](./images/windows-servermanager-confirmation.png "Server manager features installation confirmation")

9. In Installation progress **Results** show that the Installation succeeded.

  ![Server manager features Failover Clustering installation results](./images/windows-servermanager-results.png "Server manager features Failover Clustering installation results")

10. To verify the Failover Cluster services, From the taskbar, click the **search button** and search for **Failover Cluster**.

  ![Windows command search Failover Cluster manager](./images/windows-command-fcm.png "Windows command search Failover Cluster manager")

  The **Failover Cluster Manager** opens as shown in the following image.

  ![Windows Failover Cluster manager wizard](./images/windows-command-fcmanager.png "Windows Failover Cluster manager wizard")

##  Task 2: Install Failover Clustering features in Node2

* Repeat the all steps from **Task 1** to install **Failover Clustering features** in Node2

## Task 3: Create Secondary Private IPs for Node1

  Add two secondary IPs for each node. One is used for Windows Server Failover Clustering and will use the other for the Always-On Availability Group.

1. Open the navigation menu, click Compute, and click Instances.

  ![OCI Compute Instance](./images/compute-instance-oci.png "OCI Compute Instance")

2. Click on the **Compute Instance** to add the secondary IPs.

  ![OCI Compute Instance](./images/compute-instance-selectinstance.png "OCI Compute Instance")

3. In the **Resource** section, click on **Attached VNICs**, and then click on Primary VNIC to add the secondary IPs.

  ![OCI Compute Instance attached VNICs](./images/compute-instance-nic.png "OCI Compute Instance attached VNICs")

4. Open VNIC and click on **IPv4 Address**.

  ![OCI Compute Instance attached VNICs IP](./images/compute-instance-ipv.png "OCI Compute Instance attached VNICs IP")

5. The **IPv4 Address** show the Primary IP address details, and then click on **Assign Secondary Private IP Address**.

  ![OCI Compute Instance attached VNICs secondary IP](./images/compute-instance-ipv-secondary.png "OCI Compute Instance attached VNICs secondary IP")

6. Click on **Assign** will automatically assign the available private IP. Repeat the same step to assign another private IP.

  ![OCI Compute Instance attached VNICs secondary private IP](./images/compute-instance-ipv-assign.png "OCI Compute Instance attached VNICs secondary private IP")

7. In the **IPv4 Addresses** Section, we can see one Primary IP and two secondary IP addresses, as shown in the following image.

  ![OCI Compute Instance attached VNICs secondary private IPs](./images/compute-instance-ipvdetail.png "OCI Compute Instance attached VNICs secondary private IPs")

## Task 4: Create Secondary Private IPs for Node2

* Repeat the all steps from **Task 3** to add secondary IPs for Node2 VNICS.

## Task 5:  Configure the two-node Windows Failover Cluster

1. RDP to the Bastion host server using the username **use the testadmin user created in lab 1, Task 2 in step 35** and password, from the Bastion host, open the Remote Desktop and connect to the Node1 server using the private IP Address.

2. From the taskbar, click the **search button** and search for **Failover Cluster**.

  ![Windows search command](./images/windows-command-search.png "Windows search command")

  The **Failover Cluster Manager** opens as shown in the following image, right-click **Failover Cluster Manager**and click on **Create Cluster**.

  ![Windows create Failover Cluster](./images/windows-fcm-create.png "Windows create Failover Cluster")

3. The **Cluster Wizard** is shown in the following image, then click on **Next**.

  ![Windows create cluster wizard](./images/windows-fcm-begin.png "Windows create cluster wizard")

4. Click on Browse and search for the two servers which we created in **Lab 2**.

  ![Windows cluster wizard select servers](./images/windows-fcm-selectservers.png "Windows cluster wizard select servers")

5. After adding the two servers, it will show as below, and then click on **Next**.

  ![Windows cluster wizard select servers](./images/windows-fcm-name.png "Windows cluster wizard select servers")

6. In the Validation warning section, select **yes**and click on **Next**.

  ![Windows Cluster wizard validation warning check](./images/windows-fcm-validation.png "Windows Cluster wizard validation warning check")

7. The validation configuration wizard is shown as follows, and then click on **Next** to continue validation.

  ![Windows cluster wizard validation testing](./images/windows-fcm-config-validation.png "Windows cluster wizard validation testing")

8. In the **Testing Options** tab, choose the **Run all tests (recommended)** option and click on **Next**.

  ![Windows cluster wizard validation testing options](./images/windows-fcm-testing.png "Windows cluster wizard validation testing options")

9. The confirmation screen shows all servers we added to cluster validation, and then click on **Next**.

  ![Windows cluster wizard validation testing confirmation](./images/windows-fcm-confirmationtest.png "Windows cluster wizard validation testing confirmation")

10. The validation will run a test.

  ![Windows cluster wizard validation test run](./images/windows-fcm-confirmationtestrun.png "Windows cluster wizard validation test run")

11. Once the validation is completed, we can see the status as **Validated**and click on **View Report** to view the complete report in **Html** format.

  ![Windows cluster wizard validation test results](./images/windows-fcm-configvalidationrun.png "Windows cluster wizard validation test results")

12. In **Access Point for Administering the Cluster**, choose the **Cluster Name** and then click on **Next**.

  ![Windows cluster name](./images/windows-fcm-summary.png "Windows cluster name")

13. The **Confirmation** screen shows the cluster name, node details, and another few domain-related information, and then click on **Next** to continue with the configuration.

  ![Windows cluster name conformation](./images/windows-fcm-clustername.png "Windows cluster name conformation")

14. Once the Cluster is configured, you can see the confirmation that **You have completed the Create Cluster Wizard** message as shown follows.

  ![Windows cluster creation results](./images/windows-fcm-successful.png "Windows cluster creation results")

15. The cluster details are shown below after successfully creating the Cluster.

  ![Windows cluster wizard](./images/windows-fcm-clusterdetails.png "Windows cluster wizard")

16. Select the Cluster and navigate to **Cluster Core Resources**. The cluster resource will show offline, as shown in the following image. To bring the Cluster online, we need to update the **Static IP Address**, which we created in **Task 3** and **Task4**.

  ![Windows cluster server name](./images/windows-fcm-clustercoreservices.png "Windows cluster server name")

17. Right-click on **IP Address on Cluster Network 1**, and then click on **Properties**. Select the Static IP Address and provide the secondary IP address which we created in **Task 3** for node1.

  ![Windows cluster network static ip](./images/windows-fcm-staticip.png "Windows cluster network static IP")

18. Repeat the same above step for the Node2 network.

  ![Windows cluster network static ip](./images/windows-fcm-staticip-secondnode.png "Windows cluster network static IP")

19. Once the static secondary IP is updated, right-click on SQLName and click on **Bring online** cluster.

  ![Windows cluster core resources](./images/windows-fcm-bringonline.png "Windows cluster core resources")

20. The Cluster should come online, as shown in the following image. Since the Cluster is a multi-subnet cluster, we can see only one network online.

  ![Windows cluster core resources status](./images/windows-fcm-clusteronlinestatus.png "Windows cluster core resources status")

  With the above step, you have successfully set up the two-node Windows Server Failover Cluster. You may now **proceed to the next lab**.


## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, June 2022