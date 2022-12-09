# Cleanup Lab Environment (Optional)

## Introduction

This lab will walk you through the steps to delete all objects that are created throughout the
previous 3 labs

*Estimated Lab Time*: 10 minutes

### Objectives
- Delete the adb_wallet directory
- Delete the lltest ADB
- Delete all policies and Groups

## Task 1: Delete all resources

1. With the cloud shell still open, navigate to the home directory if you are still in the **adb_wallet** directory.

    ```
    <copy>cd ..</copy>
    ```

2. Delete the **adb_wallet** directory and its contents with the following command.

    ```
    <copy>rm -r adb_wallet/</copy>
    ```

3. Next, delete the ADB **lltest**.

    ```
    <copy>oci db autonomous-database delete --autonomous-database-id $ADB_OCID</copy>
    ```

4. Remove your user from the **ALL\_DB\_USERS** and **DB_ADMIN** groups so that they can be deleted.

    ```
    <copy>oci iam group remove-user --user-id $OCI_CS_USER_OCID --group-id $ALL_DB_USERS_OCID</copy>
    ```

    ```
    <copy>oci iam group remove-user --user-id $OCI_CS_USER_OCID --group-id $DB_ADMIN_OCID</copy>
    ```


5. Delete the **ALL\_DB\_USERS** and **DB_ADMIN** groups.

    ```
    <copy>oci iam group delete --group-id $ALL_DB_USERS_OCID</copy>
    ```

    ```
    <copy>oci iam group delete --group-id $DB_ADMIN_OCID</copy>
    ```

5. You may now close your cloud shell session, as you will use the OCI Console to delete the final resource. Click on the hamburger icon in the top left corner. Choose **Identity and Security** then **Policies**.

    ![OCI Homepage](images/oci-homepage.png)

    ![Identity and Security](images/identity-security.png)

6. Ensure that you are in your root compartment, and you should see the policiy called **grant-adb-access**. Click the box next to its name then click delete.

    ![Policy Page - Delete](images/delete-policy.png)

Your OCI tenancy should now be cleared of all lab resources!

## Acknowledgements
* **Author**
  * Richard Evans, Database Security Product Management
  * Miles Novotny, Solution Engineer, North America Specalist Hub
  * Noah Galloso, Solution Engineer, North America Specalist Hub
* **Last Updated By/Date** - Miles Novotny, December 2022
