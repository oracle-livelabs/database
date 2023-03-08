# Create MySQL Database HeatWave  and Cluster

## Introduction

In this lab, you will create and configure a MySQL DB System. The creation process will use a provided object storage link to create the airportdb schema and load data into the DB system.  Finally you will add a HeatWave Cluster comprise of two or more HeatWave nodes.  

_Estimated Time:_ 20 minutes

Watch the video below for a quick walk through of the lab.

[](youtube:Uz_PXHzO9ac)

### Objectives

In this lab, you will be guided through the following tasks:

- Create Virtual Cloud Network
- Create MySQL Database for HeatWave (DB System) instance with sample data (airportdb)
- Add a HeatWave Cluster to MySQL Database System

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell

## Task 1: Create Virtual Cloud Network

1. Click **Navigation Menu**, **Networking**, then **Virtual Cloud Networks**  
    ![VCN](./images/vcn-menu.png "vcn menu ")

2. Click **Start VCN Wizard**
    ![VCN](./images/vcn-wizard.png "vcn wizard.png ")

3. Select 'Create VCN with Internet Connectivity'

    Click 'Start VCN Wizard'
    ![VCN](./images/vcn-wizard-internet.png "vcn wizard internet ")

4. Create a VCN with Internet Connectivity

    On Basic Information, complete the following fields:

    VCN Name:

    ```batch
    <copy>MDS-VCN</copy>
    ```

    Compartment: Select  **(root)**

    Your screen should look similar to the following
    ![VCN](./images/vcn-compartment.png " vcn compartment")

5. Click 'Next' at the bottom of the screen

6. Review Oracle Virtual Cloud Network (VCN), Subnets, and Gateways

    Click 'Create' to create the VCN
    ![VCN](./images/vcn-subset.png "vcn subset ")

7. The Virtual Cloud Network creation is completing
    ![VCN](./images/vcn-create.png "vcn create ")

8. Click 'View Virtual Cloud Network' to display the created VCN
    ![VCN](./images/vcn-display.png "vcn display ")

9. On MDS-VCN page under 'Subnets in (root) Compartment', click  '**Private Subnet-MDS-VCN**'
     ![VCN](./images/vcn-subnet-compartment.png "vcn subnet compartment ")

10. On Private Subnet-MDS-VCN page under 'Security Lists',  click  '**Security List for Private Subnet-MDS-VCN**'
    ![VCN](./images/vcn-securitylist.png "vcn securitylist ")

11. On Security List for Private Subnet-MDS-VCN page under 'Ingress Rules', click '**Add Ingress Rules**'
    ![VCN](./images/vcn-ingress.png "vcn ingress ")

12. On Add Ingress Rules page under Ingress Rule 1

    Add an Ingress Rule with Source CIDR

    ```batch
    <copy>0.0.0.0/0</copy>
    ```

    Destination Port Range

     ```batch
    <copy>3306,33060</copy>
     ```

     Description

     ```batch
    <copy>MySQL Port Access</copy>
     ```

    Click 'Add Ingress Rule'
    ![VCN](./images/vcn-add-ingress.png "vcn add ingress ")

13. On Security List for Private Subnet-MDS-VCN page, the new Ingress Rules will be shown under the Ingress Rules List
    ![VCN](./images/vcn-ingres-rule-list.png " vcn ingres rule list")

## Task 2: Create MySQL Database for HeatWave (DB System) instance with sample data (airportdb)

1. Go to Navigation Menu
         Databases
         MySQL
         DB Systems
    ![MDS](./images/mysql-menu.png "mysql menu")

2. Click 'Create MySQL DB System'
    ![MDS](./images/mysql-create.png "mysql create ")

3. Create MySQL DB System dialog complete the fields in each section

    - Provide basic information for the DB System
    - Setup your required DB System
    - Create Administrator credentials
    - Configure Networking
    - Configure placement
    - Configure hardware
    - Exclude Backups
    - Advanced Options - Data Import

4. Provide basic information for the DB System:

    Select Compartment **(root)**

    Enter Name

    ```bash
    <copy>MDS-HW</copy>
    ```

    Enter Description

    ```bash
    <copy>MySQL Database Service HeatWave instance</copy>
    ```

    Select **HeatWave** to specify a HeatWave DB System
    ![MDS](./images/mysql-heatwave.png "mysql heatwave ")

5. Create Administrator Credentials

    **Enter Username** (write username to notepad for later use)

    **Enter Password** (write password to notepad for later use)

    **Confirm Password** (value should match password for later use)

    ![MDS](./images/mysql-password.png "mysql password ")

6. On Configure networking, keep the default values

    Virtual Cloud Network: **MDS-VCN**

    Subnet: **Private Subnet-MDS-VCN (Regional)**

    ![MDS](./images/mysql-vcn.png "mysql vcn ")

7. On Configure placement under 'Availability Domain'

    Select AD-3

    Do not check 'Choose a Fault Domain' for this DB System.

    ![MDS](./images/mysql-fault-domain.png "mysql fault domain ")

8. On Configure hardware, keep default shape as **MySQL.HeatWave.VM.Standard.E3**

    Data Storage Size (GB) Set value to:  **1024**

    ```bash
    <copy>1024</copy>
    ```

    ![MDS](./images/mysql-hardware.png "mysql hardware ")

9. On Configure Backups, disable 'Enable Automatic Backup'

    ![MDS](./images/mysql-backup.png "mysql backup ")

10. Click on Show Advanced Options

11. Go to the Networking tab, in the Hostname field enter (same as DB System Name):

    ```bash
        <copy>MDS-HW</copy> 
    ```

12. Select Data Import tab.

13. Use the Image below identify your OCI Region.

    ![MDS](./images/regionSelector.png "regionSelector ")

14. Click on your localized geographic area

    ## North America (NA)

    **Tenancy Regions** Please select the same region that you are creating MDS in  

    <details>
    <summary>US East (Ashburn) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.us-ashburn-1.oraclecloud.com/p/zRBSs7nKURyZRcIoV4QlYhascC5gkZcJeQoBS8c2ssyEPID3PSDAnh73OMClQQH4/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>US West (Phoenix) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.us-phoenix-1.oraclecloud.com/p/bbL6aZuTtFkEg4oTSjGxkFl2ni7UqG8J9uCX-5WHHd67qG_yV2fUpfJVr6mAASOb/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>US West (San Jose) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.us-sanjose-1.oraclecloud.com/p/gTwIFjGxs__5dy8RzqKHgaz6JjgBpqcIGiodRWgPCwBsyacNOjoLsybXkijCRJkh/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>Canada Southeast (Montreal) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ca-montreal-1.oraclecloud.com/p/Hi5OuQEaIUoRIiVpXxectQOG602Ie0Clb-tXRFKZjaCadeAVcBbZ7RulKyy5WHkK/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>Canada Southeast (Toronto) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ca-toronto-1.oraclecloud.com/p/SA-hZy48_NjzM420pGYNEE2Q5XE9sneGHy1CNVMekt-zwhfF89yo9f318ClFdWKF/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    ## Latin America (LAD)
    **Tenancy Regions** Please select the same region that you are creating MDS in
    <details>
    <summary>Brazil East (Sao Paulo) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.sa-saopaulo-1.oraclecloud.com/p/qzYmRurVINK-VXQQTBcoBqNGU8WxNk_0FvfU0_T1piBK1kioslc9-_8P8IVMVVjX/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>Chile (Santiago) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.sa-santiago-1.oraclecloud.com/p/_mjwJMQ2mWe5HVUeYgvGYRF2NGybIml2_M4lOveooEgN6r1-chjg5ItlufU24dZT/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>Brazil Southeast (Vinhedo) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.sa-vinhedo-1.oraclecloud.com/p/pyD-ME06UHxjY7Agy19cxbwytY1nchmu7sI_yt7wpe_axSIJMvft1zCe7BQzmO2d/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>
    ## Europe, Middle East and Africa (EMEA)
    **Tenancy Regions** Please select the same region that you are creating MDS in

    <details>
    <summary>UK South(London) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.uk-london-1.oraclecloud.com/p/l0jITzinEWEiAQmFNorC8s-4PAv-jwAMU97aEDjmTSfzlte-VUhJ7zPIYGXJMZh9/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>UK West (Newport) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.uk-cardiff-1.oraclecloud.com/p/hV2VaYxhcRGU1efgjnmwK_zY5hBL4tuT5UBo-RPYCyHXbFvQkDGzfTx2d_Vfqnsy/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json

    </copy>
    ```
    </details>

    <details>
    <summary>Germany Central (Frankfurt) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/kTZVWyDV2Rry4pLBxbf5Yjn87pC3dEAUuFE8JRJb2Nbv1FoDWNtuAfDChzQey2H0/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>Switzerland North(Zurich) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.eu-zurich-1.oraclecloud.com/p/3w2UjDyli22Jr4ymrLuo80wV0_Qp3fG144WjNedYPZ4w6OHbIMKQuwnXdDPgsV-x/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>Netherlands Northwest(Amsterdam) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.eu-amsterdam-1.oraclecloud.com/p/3_Ez8iA8SCTn4AGRfs3m3PJBtBpl3MyZSn869_nDaIOFAiXB-fWJEjh2ta0tS8N-/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json   
    </copy>
    ```
    </details>

    <details>
    <summary>Saudi Arabia West(Jeddah)  Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.me-jeddah-1.oraclecloud.com/p/cqBq_4AhY4zX7Sq_v4ziwR3ojeonM6l8JzknXMOUNov-HRcKqwmpTKOk-QCJgxln/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>Israel 1 (Jerusalem) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.il-jerusalem-1.oraclecloud.com/p/0OhJRlazP__cAgFoNTHPw2KSyVg6BlMP1NLxbHBDp7ZsI7X_7XyHimMJyLR4lQt3/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>France South (Marseille)  - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.eu-marseille-1.oraclecloud.com/p/TCunSmwaRpBFR6Vft8bhddlX3lEy7fw2unoIkCjCCZ1JscMtHqPF4jxFiayOCGj_/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>
    ## Asia Pacific (APAC)
    **Tenancy Regions** Please select the same region that you are creating MDS in

    <details>
    <summary>Japan East(Tokyo) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-tokyo-1.oraclecloud.com/p/BiO_UJkmKGkQpjh5dZNSe6CdCpMGx1himhTvHzBaoebm16JvETigjy2VZsW6hqdC/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary> Japan Central (Osaka) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-osaka-1.oraclecloud.com/p/nSqONNKWXkzjNFsGEYH5aZ-W-jv1zVuzz1AtLuOwIPHL8mvGvjV09Je9OoD_o-Sp/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary>South Korea Central(Seoul) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-seoul-1.oraclecloud.com/p/oKjZnACJpb6_WpL6u0T0f3YRe_SGXFMP3dOGRf-TbUO-h62dl_iJPyXcVkI6iBpA/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary> South Korea North (Chuncheon) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-chuncheon-1.oraclecloud.com/p/eEUcaUsaAErg11FhPaC1iAA6v4g-UO-bWdmR-V11TZ0rzJfSn7nXSYSAmvLrm7L2/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary> Australia East (Sydney) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-sydney-1.oraclecloud.com/p/NKIaOmREA4Wo_OTK98Po1UkQKKh7ioiZhflIWhgqYEc7nsM9VopYJjiDlHG8lS6q/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary> Australia Southeast (Melbourne) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-melbourne-1.oraclecloud.com/p/3XjNGFSL5f5cbj6qavA4Nq7qHLpPW3FUMCC0MTmg3QdL2TkBXPzXy6n9rrVHl4X8/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary> India West (Mumbai) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-mumbai-1.oraclecloud.com/p/qKJpoQUAPn1ccZxtKPFucUlGRHigExVhrX5kt5ivbblvgBfrbLQR5vC_noK_P9hi/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

    <details>
    <summary> India South (Hyderabad) Region - Copy and paste to PAR Source URL</summary>
    <br>
    ```
    <copy>
    https://objectstorage.ap-hyderabad-1.oraclecloud.com/p/-4mCVxfFgJi1ObsCZKbRaUOi7ZRS6lpJerBtA_Ny5nAGD56OIQncsFUiybmM23tB/n/idazzjlcjqzj/b/airportdb-bucket-10282022/o/airportdb/@.manifest.json
    </copy>
    ```
    </details>

15. Your PAR Source URL entry should look like this:

    ![MDS](./images/mysql-link.png "mysql link ")

16. Review **Create MySQL DB System**  Screen

    ![MDS](./images/mysql_create_db.png "mysql create db")

    Click the '**Create**' button

17. The New MySQL DB System will be ready to use after a few minutes

    The state will be shown as 'Creating' during the creation
    ![MDS](./images/mysql-create-button.png "mysql create button ")

18. The state 'Active' indicates that the DB System is ready for use

    On MDS-HW Page, check the MySQL Endpoint (Private IP Address)

    ![MDS](./images/mysql-create-button.png"mysql create button ")

## Task 3: Add a HeatWave Cluster to MDS-HW MySQL Database System

1. Open the navigation menu  
    Databases
    MySQL
    DB Systems
2. Choose the root Compartment. A list of DB Systems is displayed.
    ![Connect](./images/mysql-add-heatwave.png "mysql add heatwave ")
3. In the list of DB Systems, click the **MDS-HW** system. click **More Action ->  Add HeatWave Cluster**.
    ![Connect](./images/mysql-add-heat-vcn.png "mysql add heat vcn ")
4. On the “Add HeatWave Cluster” dialog, select “MySQL.HeatWave.VM.Standard.E3” shape
5. Click “Estimate Node Count” button
    ![Connect](./images/mysql-add-heat-estimate.png "mysql add heat estimate ")
6. On the “Estimate Node Count” page, click “Generate Estimate”. This will trigger the auto
provisioning advisor to sample the data stored in InnoDB and based on machine learning
algorithm, it will predict the minimum number of nodes needed.
    ![Connect](./images/mysql-heat-cluster-estimate.png "mysql heat cluster estimate ")
7. Once the estimations are calculated, it shows list of database schemas in MySQL node. If you expand the schema and select different tables, you will see the estimated memory required in the Summary box, There is a Load Command (heatwave_load) generated in the text box window, which will change based on the selection of databases/tables
8. Select the airportdb schema and click “Apply Node Count Estimate” to apply the node count
    ![Connect](./images/mysql-heat-apply-estimate.png "mysql heat apply estimate ")
9. **Set Node Count to 2 for this Lab Click** “Add HeatWave Cluster” to create the HeatWave cluster
    ![Connect](./images/mysql-apply-heat-cluster.png "mysql apply heat cluster ")
10. HeatWave creation will take about 10 minutes. From the DB display page scroll down to the Resources section. Click the **HeatWave** link. Your completed HeatWave Cluster Information section will look like this:
    ![Connect](./images/mysql-heat-cluster-complete.png "mysql heat cluster complete ")

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Mndy Pang, Principal Product Manager, Salil Pradhan, Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2022
