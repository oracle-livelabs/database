# Setup

## Introduction
In the previous lab you created an ADB instance.  In this lab, you will connect to the ADB instance from Oracle Cloud Shell.

Estimated Time: 20 Minutes

### Objectives
- Create a bucket, auth token and Oracle Wallet
- Load ADB instance
- Grant Roles and Privileges to Users
- Create a Database Credential for the Users

### Prerequisites
- Lab: Provision ADB

## Task 1: Create a Bucket

1. Login to Oracle Cloud if you are not already logged in.

2. Click on the hamburger menu and navigate to **Storage** and click on **Buckets**.

      ![](./images/object_storage.png " ")

3. Choose the compartment where your ATP is provisioned and click **Create Bucket**.

      ![](./images/step1-3.png " ")

4. Name your bucket **adb1** and click **Create**.

      ![](./images/step1-4.png " ")

5. Once the bucket is created, click on the bucket and make note of the `bucket name` and `namespace`.

      ![](./images/step1-5.png " ")

## Task 2: Create Oracle Wallet in Cloud Shell

There are multiple ways to create an Oracle Wallet for ADB.  We will be using Oracle Cloud Shell as this is not the focus of this workshop.  To learn more about Oracle Wallets and use the interface to create one, please refer to the lab in this workshop: [Analyzing Your Data with ADB - Lab 6](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?p180_id=553)

1.  Login to the Oracle Cloud if you aren't logged in already.
   
2.  Click the Cloud Shell icon to start up Cloud Shell
      ![](./images/cloud-shell.png " ")
3.  While your Cloud Shell is starting up, click on the Hamburger Menu -> **Autonomous Transaction Processing** 
      ![](https://raw.githubusercontent.com/oracle/learning-library/master/common/images/console/database-atp.png " ")

4.  Click on the **Display Name** to go to your ADB main page.

      ![](./images/step2-4.png " ")
   
5.  Locate and copy the **OCID** (Oracle Cloud ID) you will need that in a few minutes. 

      ![](./images/locate-ocid.png " ")

6.  Use your autonomous\_database\_ocid to create the Oracle Wallet. You will be setting the wallet password to the same value as the ADB admin password for ease of use: *WElcome123##* Note: This is not a recommended practice and just used for the purposes of this lab. 
7.  Copy the command below and paste it into Cloud Shell.  Do not hit enter yet.  

      ````
      <copy>
      cd ~
      oci db autonomous-database generate-wallet --password WElcome123## --file 21c-wallet.zip --autonomous-database-id  </copy> ocid1.autonomousdatabase.oc1.iad.xxxxxxxxxxxxxxxxxxxxxx
      ````

      ![](./images/wallet.png " ")

8.  Press copy to copy the OCID from Step 5 and fill in the autonomous database ocid that is listed in the output section of your terraform.  Make sure there is a space between the --autonomous-database-id phrase and the ocid.  Click **enter**.  Be patient, it takes about 20 seconds.

9.  The wallet file will be downloaded to your cloud shell file system in /home/yourtenancyname

10. Enter the list command in your cloud shell below to verify the *21c-wallet.zip* was created
   
      ````
      ls
      ````
      ![](./images/21cwallet.png " ")

## Task 3: Create Auth Token

1.  Click on the person icon in the upper right corner.
2.  Select **User Settings**

      ![](./images/select-user.png " ")

3.  Copy the **Username**.

      ![](./images/copy-username.png " ")

4.  Under the **User Information** tab, click the **Copy** button to copy your user **OCID**.

      ![](./images/copy-user-ocid.png " ")

5.  Create your auth token with description `adb1` using the command below by substituting your actual *user OCID* for the userid below.  *Note: If you already have an auth token, you may get an error if you try to create more than 2 per user*
   
      ````
      <copy>
       oci iam auth-token create --description adb1 --user-id </copy> ocid1.user.oc1..axxxxxxxxxxxxxxxxxxxxxx
      ````
      ![](./images/token.png " ")

6.  Identify the line in the output that starts with **"token"**.
7.  Copy the value for the **token** somewhere safe, you will need it in the following steps.

## Task 4:  Load ADB Instance with Application Schemas

1. Go back to your cloud shell and start the cloud shell if it isn't already running
   
2. Run the wget command to download the load_21c.sh script from object storage.

      ````
      <copy>
      cd $HOME
      pwd
      wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/load-21c.sh
      chmod +x load-21c.sh
      export PATH=$PATH:/usr/lib/oracle/19.10/client64/bin
      </copy>
      ````

3.   Run the load script passing in the two arguments from your notepad, your admin password and the name of your ATP instance.  This script will import all the data into your ATP instance for your application and set up SQL Developer Web for each schema.  This script runs as the opc user.  Your ATP name should be the name of your ADB instance.  In the example below we used *adb1*.  This load script takes approximately 3 minutes to run.  *Note : If you use a different ADB name, replace adb1 with your adb instance name*

      ``` 
      <copy> 
      ./load-21c.sh WElcome123## adb1 2>&1 > load-21c.out</copy>
      ```

      ![](./images/load21c-1.png " ")

## Task 5: Grant Roles and Privileges to Users

1.  Go back to your Autonomous Database Homepage.

      ![](./images/step4-0.png " ") 

      ![](./images/step4-1.png " ") 

2.  Click on the **Tools** tab.

      ![](./images/step4-tools.png " ") 

3.  Click **Database Actions**.

      ![](./images/step4-database.png " ") 

4.  Select **admin** for your username.

      ![](./images/step4-admin.png " ") 

5.  Password:  **WElcome123##**.

      ![](./images/step4-password.png " ") 

6. Under Administration, select **Database Users**.

      ![](./images/step4-databaseuser.png " ")

7. For **HR** user, click the **3 Dots** to expand the menu and select **Edit**.

      ![](./images/step4-edit.png " ")

8. Enable the **REST Enable** and **Authorization required** sliders.

      ![](./images/step4-enable-rest.png " ")

9. Click on the **Granted Roles** tab at the top. 

      ![](./images/step4-roles.png " ")

10. Scroll down **DWROLE**, and make sure the **1st** and **3rd** check boxes are enabled.

      ![](./images/step4-dwrole.png " ")

11. Scroll all the way to the bottom, and click **Apply Changes**.

      ![](./images/step4-apply.png " ")

12. Click the **X** in the search bar to view all the users again. 

      ![](./images/step4-cancel-search.png " ")

13. Repeat steps 7-12 for **OE** user.

      ![](./images/step5-13a.png " ")
      
      ![](./images/step5-13b.png " ")
      
      ![](./images/step5-13c.png " ")
      
      ![](./images/step5-13d.png " ")
      
      ![](./images/step5-13e.png " ")

14. Repeat steps 7-12 for **REPORT** user.

      ![](./images/step5-14a.png " ")
      
      ![](./images/step5-14b.png " ")
      
      ![](./images/step5-14c.png " ")
      
      ![](./images/step5-14d.png " ")
      
      ![](./images/step5-14e.png " ")

## Task 6: Login to SQL Developer Web

1.  Test to ensure that your data has loaded by logging into SQL Developer Web. 

2.  In the upper left, select the **Hamburger Button** and expand out the **Development** tab. Select **SQL**.

      ![](./images/step4-sql.png " ") 

3. Click the **X** to dismiss the pop-up.

      ![](./images/step4-sql-x.png " ") 

4. Run the code snippet below and verify that there are 665 items.

      ````
      <copy>
      select count(*) from oe.order_items;
      </copy>
      ````

      ![](./images/step4-run.png " ") 

## Task 7: Create a Database Credential for Your Users

To access data in the Object Store you have to enable your database user to authenticate itself with the Object Store using your OCI object store account and Auth token. You do this by creating a private CREDENTIAL object for your user that stores this information encrypted in your Autonomous Transaction Processing. This information is only usable for your user schema.

1. Copy and paste this the code snippet in to SQL Developer worksheet. Specify the credentials for your Oracle Cloud Infrastructure Object Storage service by replacing the `<username>` and `<token>` with the following username and password:

	- Credential name: Description of the auth token. In this example, the auth token is created with the description - `adb1` from step 1.
	- Username: The username will be the **OCI Username** you noted in step 3
	- Password: The password will be the OCI Object Store Auth **Token** you generated in step 3.

	```
	<copy>
	BEGIN
  		DBMS_CLOUD.CREATE_CREDENTIAL(
    		credential_name => 'adb1',
    		username => '<username>',
    		password => '<token>'
  		);
	END;
	/
	</copy>
	```

      ![](./images/step7-1.png " ") 

    Now you are ready to load data from the Object Store.
    
2.  Click the down arrow next to the word **ADMIN** and **Sign Out**.

      ![](./images/step4-signout.png " ") 

You may now **proceed to the next lab**.

## Acknowledgements
* **Authors** - Kay Malcolm, Senior Director, Database Product Management
* **Contributors** - Anoosha Pilli, Didi Han, Database Product Management
* **Last Updated By/Date** - Didi Han, April 2021

