# Connect to MySQL HeatWave With Cloud Shell Private Access and OCI Shell

## Introduction

When working in the cloud, there are often times when your servers and services are not exposed to the public internet. The Oracle Cloud Infrastructure (OCI) MySQL cloud service is an example of a service that is only accessible through private networks. Since the service is fully managed, we keep it siloed away from the internet to help protect your data from potential attacks and vulnerabilities. It’s a good practice to limit resource exposure as much as possible, but at some point, you’ll likely want to connect to those resources. That’s where Cloud Shell Private Access enters the picture. Cloud Shell Private Access allows you to connect a Cloud Shell session to a private network so you can access  your MySQL HeatWave Database without having the network traffic flow over public networks

_Estimated Lab Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Connect to Cloud Shell
- Setup Cloud Shell Private Access
- Use MySQL Shell to Connect to your Heatwave Database

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Must Complete Lab 1

## Task 1: Access Cloud Shell via the Console 

1. Login to the OCI Console.
2. Click the Cloud Shell icon in the Console header. Note that the OCI CLI running in the Cloud Shell will execute commands against the region selected in the Console's Region selection menu when the Cloud Shell was started.

    ![DBConnect](./images/cloudshell-console-button.png "cloudshell console button")

    This displays the Cloud Shell in a "drawer" at the bottom of the console:

    ![DBConnect](./images/cloudshell-console-drawer.png "cloudshell console drawer")

    You can use the icons in the upper right corner of the Cloud Shell window to minimize, maximize, restart, and close your Cloud Shell session.

## Task 2: Setup Cloud Shell Private Access

1. To change the network your Cloud Shell session is using to the HeatWave Database network, use the drop-down Network menu at the top of the Cloud Shell terminal window:

    ![DBConnect](./images/cloud_shell_private_access_dropdown_terminal.png "cloud shell private access dropdown terminal")

2. Select the Private Network Setup menu item. this will bring up the Private Network Setup panel. This panel allows you to select details for the private network you want to use:

    ![DBConnect](./images/cloud_shell_private_access_dropdown_vcn.png "cloud shell private access vcn")

3. Select the compartment that you want to use, and then select the VCN and the Subnet to use from the drop-down list boxes. You can also optionally select one or more Network Security groups to use.

    ![DBConnect](./images/cloud_shell_private_network_setup.png "cloud shell private network setup")

4. Click on the Connect to this network button to switch your Cloud Shell network connection to the HeatWave Database network.

    Your Cloud Shell session is now connected to your HeatWave private network, as indicated in the Networking drop-down at the top of the Cloud Shell terminal session:

    ![DBConnect](./images/cloud_shell_private_network_connected.png "cloud shell private network setup")

    You can see details about your private network connection by clicking the Details link.

    ![DBConnect](./images/cloud_shell_private_network_details.png "cloud shell private network details")

## Task 3: Use MySQL Shell

1. Connect to HeatWave Database

    ```bash
    <copy>mysqlsh -uadmin -p -h 10.0.1.... --sql</copy>
    ```

    ![DBConnect](./images/mysql-shell-login.png "mysql shell login ")

2. View  Database information

   a. To display a list of databases, Enter the following command at the prompt:

      ```bash
      <copy>SHOW DATABASES;</copy>
      ```

    ![DBConnect](./images/mysql-show-databases.png "mysql show databases ")

   b. Access mysql\_customer\_orders schema:

      ```bash
      <copy>use mysql_customer_orders;</copy>
      ```

   c. List tables and record count in mysql\_customer\_orders:

      ```bash
      <copy>SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'mysql_customer_orders';</copy>
      ```

    d. Exit MySQL Shell

      ```bash
      <copy>\q</copy>
      ```

    ![DBConnect](./images/mysql-list-tables.png "mysql list tables")

You may now **proceed to the next lab**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Abhinav Agarwal, Senior Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2023