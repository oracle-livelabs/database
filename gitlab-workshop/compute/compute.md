# Set up OCI Virtual Cloud Network and a Compute Instance 

## Introduction

This lab will show you how to setup an Oracle Cloud network (VCN) and a compute instance running Oracle Linux.

Estimated Lab Time:  30 minutes



### Objectives


In this lab, you will:
* Create a compartment to group all the resources together 
* Setup a VCN (Virtual Compute Network) using VCN Wizard
* Setup a compute instance
* Login to your compute instance

### Prerequisites

This lab assumes you have:
- An Oracle Free Tier or Paid Cloud account


## Task 1: Create a Compartment

When you first start working with Oracle Cloud Infrastructure, you need to think carefully about how you want to use compartments to organize and isolate your cloud resources. Compartments are fundamental to that process. Most resources can be moved between compartments. However, it's important to think through your compartment design for your organization up front, before implementing anything. Compartment is a global resource and can be created and accessed from any region in the OCI ecosystem.

1. To create a compartment, click the **Navigation Menu** in the upper left, navigate to **Identity & Security**, and select **Compartments** under **Identity**. Select the Parent compartment from the drop-down list where you want your compartment to be created.

![compartment](images/compartment.png)

The Console is designed to display your resources by compartment within the current region. When you work with your resources in the Console, you must choose which compartment to work in from a list on the page. 

## Task 2: Setup Virtual Cloud Network

Oracle Cloud Infrastructure (OCI) Virtual Cloud Networks (VCNs) provide customizable and private cloud networks in Oracle Cloud Infrastructure (OCI). Just like a traditional data center network, the VCN provides customers with complete control over their cloud networking environment. This includes assigning private IP address spaces, creating subnets and route tables, and configuring stateful firewalls. Ensure to select the correct region from the upper right corner of the console. If the desired region is not subscribed, it can be subscribed using a single-click operation.

To create a VCN, click the **Navigation Menu** in the upper left, navigate to **Networking**, and select **Start VCN Wizard** under **Virtual Cloud Networks**.

1. Select the option **Create VCN with Internet Connectivity**
	![vcn1](images/vcn1.png)
	
2. Specify Basic Information for your VCN
	![vcn1](images/vcn2.png)

    - Specify the Name of the VCN
    - Select the same Compartment for your VCN creation, that was created in the previous step
    - Specify a VCN CIDR Block big enough to accommodate two subnets
    - Specify the Public Subnet CIDR Block
    - Specify the Private Subnet CIDR Block
    - Ensure to check the DNS Resolution radio button for the naming resolution to be enabled in the VCN
 
    

3. Review and Validate the VCN Information and hit **Create**
	![vcn1](images/vcn3.png)

4. VCN provisioning is completed

	![vcn1](images/vcn4.png)


5. After Successful creation of a VCN, the following VCN / Subnets will be provisioned

  | VCN / Subnet | CIDR Block | Total IPs | Total Usable IPs| Subnet Access |
  | --- | --- | --- | --- |
  | livelab |  172.30.0.0/21 | 2048 | |
  | Public Subnet-livelab | 172.30.0.0/22 | 1024 | 1021 | Public (Regional) |
  | Private Subnet-livelab | 172.30.4.0/22 | 1024 | 1021 | Private (Regional) |
    
    >**Note:** 3 IPs per Subnet are reserved by OCI


## Task 3: Create SSH Keys

### Introduction

The SSH (Secure Shell) protocol is a method for secure remote login from one computer to another. SSH enables secure system administration and file transfers over insecure networks using encryption to secure the connections between endpoints. SSH keys are an important part of securely accessing Oracle Cloud Infrastructure compute instances in the cloud.

If you already have an SSH key pair, you may use that to connect to your environment. We recommend you use the *Oracle Cloud Shell* to interface with the OCI compute instance you will create. Oracle Cloud Shell is browser-based, does not require installation or configuration of anything on your laptop, and works independently of your network setup. However, if you prefer to connect via your laptop, please select an option based on your configuration.

*IMPORTANT:  If the SSH key is not created correctly, you will not be able to connect to your environment and will get errors.  Please ensure you create your key properly.*


### Objectives
- Generate and access SSH public and private keys

1. **Generate SSH Keys on MacOS**

The ssh keys on MacOS can be created using the **Terminal** application. If you don't already have a shortcut to the terminal application for MacOS, you can find it in the **Applications > Utilities** menu or (Shift+Command+U) on your keyboard.

  ```
  <copy>ssh-keygen -t rsa</copy>
  Generating public/private rsa key pair.
  Enter file in which to save the key (/Users/demo/.ssh/id_rsa):
  Enter passphrase (empty for no passphrase):
  Enter same passphrase again:
  Your identification has been saved in /Users/demo/.ssh/id_rsa
  Your public key has been saved in /Users/demo/.ssh/id_rsa.pub
  The key fingerprint is:
  SHA256:3UYprkLRvQI/QdKyOoeghc/ow/fx0S2noUBnFvzJeLk demo@demo-mac
  The key's randomart image is:
  +---[RSA 3072]----+
  |      ...        |
  |      o+..   .   |
  | .    o=o o o    |
  |. o   .+=+o=     |
  | * . +.=S*+ o    |
  |o o =.= o+o.     |
  |o    =...E o     |
  | + .  +.o =      |
  |  o .. o .       |
  +----[SHA256]-----+
```

The command above creates two files under the .ssh folder in the Home directory of the user, a *private key:* ```id_rsa``` and a *public key:* ```id_rsa.pub```. Keep the private key safe and don't share its content with anyone. The public key will be needed for various activities and can be uploaded to certain systems as well as copied and pasted to facilitate secure communications in the cloud.

2. **Generate SSH Keys on Windows**

SSH keys on Windows can either be created using **PowerShell** or **Command Prompt**.

Open a **Powershell** command window on your Windows system by typing 'powershell' in the search field in the Start bar.

![powershell](images/powershell1.png)


Press Enter at all of the prompts to accept the default location, default file names, and no passphrase.

![powershell](images/powershell2.png)

The command above creates two files under the .ssh folder in the Home directory of the user, a *private key:* ```id_rsa``` and a *public key:* ```id_rsa.pub```. Keep the private key safe and don't share its content with anyone. The public key will be needed for various activities and can be uploaded to certain systems as well as copied and pasted to facilitate secure communications in the cloud.

## Task 4: Setup Compute Instance for GitLab Server

* Create a compute instance for GitLab server that will be used to install and configure GitLab software in the following labs.

1. Click the **Navigation Menu** in the upper left, navigate to **Compute**, and select **Instances**
2. Click on **Create Instance**
3. Enter the **Name** for your Compute Instance and choose the **compartment**
4. Click on edit and choose the **Availability Domain**, **Image**, and **Shape** of your choice. For this lab, use the latest Oracle Linux 8.x image



![compute](images/compute1.png)

5. Specify the **VCN** and the *public* **Subnet Name**
6. Make sure to **Assign a Public IPV4 address** to the compute instance. We will use this Public IP to login to to the compute instance
7. In the **Add SSH keys**, select **Upload Public Key** and specify your public ssh key


![compute](images/compute2.png)

8. Default options for **Boot Volume** should suffice for this Lab. No Change is required. Then click create

![compute](images/compute3.png)

9. The compute instance will be provisioned shortly

![compute](images/compute4.png)


## Task 5: Connect to the Instance

### 1. *Connect from MacOS*

Click the **Navigation Menu** in the upper left, navigate to **Compute**, select **Instances** and click on the instance that was provisioned in the previous steps. This will bring the instance details.

1. Copy the **Public IP** of the Instance, Also, the default user is always *opc* for Oracle Linux images

![compute](images/connect.png)




2. Connect to the compute Instance on MacOS / Linux

    ```
    ssh opc@<public-ip-address>
    The authenticity of host '<public-ip-address> (<public-ip-address>)' can't be established.
    ED25519 key fingerprint is SHA256:jOKuEsU9C9Lb/cL9YH/vN/4JuLCRijHl7oV5ZLo/4jI.
    This key is not known by any other names
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    Warning: Permanently added '<public-ip-address>' (ED25519) to the list of known hosts.
    Activate the web console with: systemctl enable --now cockpit.socket

    ```


### 2. *Connect from Windows using Putty*

Putty can be used to connect to Linux machines from Windows machines. However, the private ssh key created earlier needs to be converted from a **PEM** format to a **PPK** format before connecting to the instance. Use the steps below to do the conversion of the key before attempting to log in. Ensure to download the [Putty Installer](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) before attempting to perform the key conversion. 

1. On the Windows machine, click on **Start Menu**> **All Programs** > **PuTTY** > **PuTTYgen**.
![puttygen1](images/puttygen1.png)

2. Click the **Load** button and select the private key *id_rsa*, generated earlier
![puttygen1](images/puttygen2.png)

3. Click the **Save private key** and save the file with the same name with **ppk** extension
![puttygen1](images/puttygen3.png)

Once the private key is saved in the ppk format, Putty can be used to connect to the compute instance

4. Open Putty, and input the username and the host IP address
![puttygen1](images/putty1.png)

5. Next, in the left hand panel locate the **Connection > SSH > Auth** configuration tab. Specify the location of the Private Key File (converted earlier to ppk format) and hit **Open** button
![puttygen1](images/putty2.png)

6. *Accept* the **PuTTy Security Alert**
![puttygen1](images/putty3.png)

7. Successful connection is established with the instance
![puttygen1](images/putty4.png)


## Task 6: Setup DNS

One of the requirement for GitLab configuration is to use *https* protocol for secure communication between the server and the client. During the configuration the TLS certificates are automatically requested and configured on the GitLab server. Since, the certificates are always bound to a DNS domain, therefore it is essential to bind the IP address of the server to a domain name that would later be used for configuring and accessing GitLab securely.

If you are using an external DNS management service, then configure the Public IP address of the GitLab server to the desired domain. For the purpose of this LiveLab, I will use OCI's DNS Management service to create the DNS entry for the GitLab server. The domain name is already registered with an external registrar, and the nameservers are configured to point to Oracle Cloud Infrastructure's Nameservers. 

1. In the Console, open the navigation menu and click **Networking**. Under **DNS Management**, click **Zones** and create a new **Public Zone**.
* The domain name registered for this lab is cloudlab.site. Select the Zone Type as Primary from the drop-down list.

![DNS Management](images/dns1.png)

2. Add a new **A** record, pointing the Public IP address to the desired Name.

![DNS Management](images/dns2.png)

3. Verify that the domain name to IP address mapping is resolving correctly, before proceeding.

    ```
    <copy>nslookup gitlab.cloudlab.site</copy>
    Server:		167.206.10.178
    Address:	167.206.10.178#53

    Non-authoritative answer:
    Name:	gitlab.cloudlab.site
    Address: &lt;public-ip-address&gt;
    ```


## Task 7: Create Compute for GitLab Runner

Use the same process to create another compute instance for GitLab Runner Installation. Instance with 2 OCPUs and 16GB of RAM should be sufficient for the installation to succeed. After successful creation of the compute, we should have two compute instances up and running. GitLab software will be installed and configured on the compute named *gitlab*, whereas compute named *runner* will be used to install GitLab Runner. 

  | Hostname | VCN Subnet | OCPUs | Memory (GB) |
  | --- | --- | --- | --- |
  | gitlab | Public Subnet | 4  | 64 GB RAM  |
  | runner | Public Subnet | 2  |  32 GB RAM |
  


## Learn More



* [OCI Compartments](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm)
* [Virtual Cloud Network (VCN)](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
* [OCI Compute Service](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)
* [Managing Key Pairs on Linux Instances](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managingkeypairs.htm)
* [Connecting to an Instance](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/accessinginstance.htm)
* [Download Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)


## Acknowledgements
- **Created By/Date** - Farooq Nafey, Principal Cloud Architect, August 2022
* **Last Updated By/Date** - Farooq Nafey, September 2022