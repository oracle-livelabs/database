# Configure GoldenGate hub

## Introduction

#### Logical Online Migration with Backup Location
ZDM's Logical Online Migration requires a GoldenGate Hub with two GoldenGate Microservices, one Extract and one Replicat. These two microservices' task is to keep both source and target in sync during the migration and during the graceful switchover. The overall logical workflow architecture, as discussed in this workshop's introduction, is as follows:

![Oracle Zero Downtime Migration Logical Online Workflow Step-by-Step visualization](./images/logical-online-backup-workflow.png " ")


Estimated Time: 30 minutes

### Workshop Objectives

In this lab, you will:
* Learn how to configure the required GoldenGate Hub for ZDM's Logical Online Migration

## Task 1: Verify VCN Correct Configuration

This workshop section requires having access to an Oracle Cloud account, having created SSH Keys and verify the Virtual Cloud Network Configuration. This last step will be described below.

1. Login to the Oracle Cloud.

2. Once you are logged in, you are taken to the cloud services dashboard where you can see all the services available to you. Click the navigation menu in the upper left to show top level navigation choices. Click __Networking__ and Click __Virtual Cloud Networks__

    ![Screenshot of Oracle Cloud Networking menu with Virtual Cloud Networks option](./images/ogg-vcn.png " ")

3.  Click on the Name of the only available VCN in your compartment

    ![Screenshot of Oracle Cloud Virtual Cloud Networks menu for current compartment](./images/ogg-available-vcn.png " ")

4.  Scroll down to the __Subnets__ section and click on the only available subnet in your compartment

    ![Screenshot of Oracle Subnets menu for current compartment](./images/ogg-subnet.png " ")

5.  Scroll down to the __Security Lists__ section and click on the only available Security List in your compartment

    ![Screenshot of Oracle Security Lists menu for current compartment](./images/ogg-security-list.png " ")

6.  Scroll down to the __Ingress Rules__ section. If there are no rules for __Port 443__ and __Port 1521__, they must be added. The absence of rules would look like this:

    ![Screenshot of Oracle Ingress rules](./images/ogg-no-rules.png " ")

7.  If there are no rules present, click on the __Add Ingress Rules__ button. Otherwise, you may proceed to __Task 1__.

8. An __Add Ingress Rules__ pane will pop up. Enter the following parameters. 

    - Stateless - __Left Unchecked__
    - Source Type - __CIDR__
    - Source CIDR - __keep as is__
    - IP Protocol - __TCP__
    - Source Port Range - __Left as is__
    - Destination Port Range - __443__
    - Description - __OGG HTTPS__

    ![Screenshot showing how to add Ingress rules](./images/ogg-add-rules.png " ")

9. Click on the __Add Ingress Rules__ button on the bottom:

10. Once you have added a rule for __Port 443__, proceed with a rule for __Port 1521__. Click on the __Add Ingress Rules__ button, an __Add Ingress Rules__ pane will pop up. Enter the following parameters and Click on the __Add Ingress Rules__ button on the bottom:

    - Stateless - __Left Unchecked__
    - Source Type - __CIDR__
    - Source CIDR - __keep as is__
    - IP Protocol - __TCP__
    - Source Port Range - __Left as is__
    - Destination Port Range - __1521__
    - Description - __Oracle DB__


    The list should now look as follows:

    ![Screenshot of newly added Ingress Rules](./images/ogg-yes-rules.png " ")


## Task 2: Setting up the GoldenGate Image from the Oracle Cloud Infrastructure Market Place

1. Click the navigation menu in the upper left to show top level navigation choices. On the Search bar, type "Marketplace" and click on the __All Applications__ result on the right hand side.

    ![Screenshot of marketplace results for the search function in Oracle Cloud Infrastructure](./images/marketplace-search.png " ")

2. On the Market Place search bar enter __GoldenGate Migration__ and select the __Oracle GoldenGate - Database Migrations__ Image.

    ![Screenshot of marketplace results for GoldenGate Migration image](./images/marketplace-gg-images.png " ")

3. Accept the Terms & Conditions and Click on __Launch Stack__.

    ![Screenshot of Oracle GoldenGate for Oracle - Database Migrations Launch Menu ](./images/marketplace-gg-launch.png " ")

4. Creating the stack is divided in three stages, Stack Information, Configurable Variables and Final Review. For the first stage, Stack Information, scroll down to the bottom and click on __Next__

    ![Screenshot of Oracle GoldenGate Image Create Stack Menu](./images/marketplace-gg-stack-information.png " ")

5. Configure the following variables for section __Name for New Resources__:

    - Display Name (As is)
    - Host DNS Name, enter oggzdm

    ![Screenshot of Oracle GoldenGate Image Create Stack Menu, Resource Name Section](./images/ogg-name-for-new-resources.png " ") 

6. Configure the following variables for section __Network Settings__, bear in mind that all variables must be from the compartment where all your resources are deployed:

    - VCN Network Compartment
    - VCN
    - Subnet Network Compartment
    - Subnet

    ![Screenshot of Oracle GoldenGate Image Create Stack Menu, VCN Section](./images/ogg-network-names.png " ") 


7. Configure the following variables for section __Instance Settings__, bear in mind that the Availability Domain must be the same as the rest of your resources. The Compute Shape of choice is VM.Standard2.4:

    - Availability Domain
    - Compute Shape
    - Assign Public IP (Check)
    - Custom Volume Sizes (Left Unchecked)

    ![Screenshot of Oracle GoldenGate Image Create Stack Menu, Instance Settings Section](./images/ogg-instance-settings.png " ") 

8. Configure the following variables for section __Create OGG Deployment__:

    - Deployment  Name, enter __Marketplace__
    - Deployment 2 - Automomous Database (__Check__)
    - Deployment 2 - Autonomous Database Compartment, select appropriate compartment as the rest of your deployment
    - Deployment 2 - Autonomous Database Instance, select the target database created earlier 

    ![Screenshot of Oracle GoldenGate Image Create Stack Menu, Create Ogg Deployments Section](./images/ogg-create-deployments.png " ") 

9. Configure the following variable for section __Shell Access__:

    - SSH Public Key, enter the key saved for the opc user in Lab 1.

    ![Screenshot of Oracle GoldenGate Image Create Stack Menu, Shell Access Section](./images/ogg-ssh-key.png " ")

10. Review your entries & Click __Next__

11. Proceed to do a final review & Click __Create__ when ready. 

    ![Screenshot of Oracle GoldenGate Image Create Stack Menu, Final Section](./images/ogg-hub-create.png " ")

12. Upon creation, scroll down to the bottom of the logs and copy the __ogg\_image\_id__ __ogg\_instance_\_id__ and the __ogg\_public\_ip__. Save them for later use, you will require it during the migration

    ![Screenshot of Oracle GoldenGate Image Creation Logs](./images/ogg-copy-ocid.png " ")

## Task 3: Connecting to the GoldenGate Hub

1. Open CloudShell

2. Connect to the GoldenGate Hub, replace __ogg\_public\_ip__ with the GoldenGate Hub public ip copied above and replace __sshkeyname__ with the SSH Key name used previously. Enter yes at the prompt. Please bear in mind that the instance creationg might still be wrapping up and hence the connection might be refused. If this is the case, please wait for a couple of minutes and try again

    ```
    <copy>
    ssh -i ~/.ssh/<sshkeyname> opc@<ogg_public_ip>
    </copy>
    ```

3. Copy the output of the following command, it will be required in the following steps
    
    ```
    <copy>
    cat ./ogg-credentials.json
    </copy>
    ```

    ![Screenshot of Cloud Shell OGG Credentials](./images/ogg-cat-credentials.png " ")

4. In a separate browser tab, open the OGG Service Manager home page using the __GoldenGate Hub Public ip__ : __https://ogg\_public\_ip__ (replace the ogg\_public\_ip value with the value saved above). 
    The browser will show warnings that the page is insecure because it uses a self-signed certificate. Ignore those warnings and proceed

    ![Screenshot of Oracle GoldenGate Services Manager Login Menu](./images/ogg-service-manager.png " ")

5. Enter the username and password (labeled credential) from the out copied from the ogg-credentials.json file from above. Click __Sign In__

6. Click on the top left "Navigation" menu

    ![Screenshot of Oracle GoldenGate Services Manager](./images/ogg-validation-menu.png " ")

7. Click on __Administrator__

    ![Screenshot of Oracle GoldenGate Services Manager Hamburguer Menu](./images/ogg-menu-admin.png " ")

8. Click on the Edit Pen on the right to edit the oggadmin user

    ![Screenshot of Oracle GoldenGate Services Manager Users Administrator Menu ](./images/ogg-edit-user-menu.png " ")

9. Enter the following information:

    - Type: Basic
    - Info: admin
    - Password: __WELcome##1234__
    - Verify Password: __WELcome##1234__

    Upon review, click __Submit__

    ![Screenshot of Oracle GoldenGate Services Manager User Edit options](./images/ogg-edit-user-entry.png " ")

10. You will be logged out of the Oracle GoldenGate Service Manager, sign in again with oggadmin and the recently updated password from the step above (#9)

11. In the Services table, click on the __port__ of the Marketplace Administration Server (typically __9011__), this will open a new Sign In page for the __Oracle GoldenGate Administrator Server__

12. Enter the username and password (labeled credential) from the out copied from the ogg-credentials.json file from step 3 above. Do not enter the newly updated password.

13. Click on the top left navigation menu

    ![Screenshot of Oracle GoldenGate Administrator Server](./images/ogg-validation-menu-source.png " ")

14. Click on __Administrator__

    ![Screenshot of Oracle GoldenGate Administrator Server Hamburguer Menu](./images/ogg-menu-admin-source.png " ")

15. Click on the Edit Pen on the right to edit the oggadmin user

    ![Screenshot of Oracle GoldenGate Administrator Server User Edit](./images/ogg-edit-user-menu.png " ")

16. Enter the following information:

    - Type: Basic
    - Info: admin
    - Password: __WELcome##1234__
    - Verify Password: __WELcome##1234__

    Upon review, click __Submit__

    ![Screenshot of Oracle GoldenGate Administrator Server User Edit options](./images/ogg-edit-user-entry.png " ")



You may now close any Oracle GoldenGate Service Manager leftover tab.
Please *proceed to the next lab*.

## Learn More About ZDM's Oracle GoldenGate Hub

* [Oracle Zero Downtime Migration - Product Page](http://www.oracle.com/goto/zdm)
* [Oracle GoldenGate MicroService Documentation](https://docs.oracle.com/en/middleware/goldengate/core/19.1/oggmp/oracle-goldengate-microservices-oracle-cloud-marketplace.html)



## Acknowledgements
* **Authors** - Ricardo Gonzalez, Senior Principal Product Manager, Oracle Cloud Database Migration
* **Authors** - Ameet Kumar Nihalani, Senior Principal Support Engineer, Oracle Cloud Database Migration
* **Contributors** - LiveLabs Team, ZDM Development Team
* **Last Updated By/Date** - Ricardo Gonzalez, January 2022
