# Lab 1: Acquire and Import the RHEL Source Image

## Introduction

OCI does not provide a directly selectable RHEL platform image in the standard image list. For the certified bring-your-own-image path, obtain a supported RHEL KVM guest image from Red Hat, upload it to Object Storage, and import it as a custom image.

This lab uses RHEL 9.8 for x86\_64. The OCI documentation requires the KVM guest image, QCOW2 image type, and paravirtualized launch mode for this workflow.

### Objectives

In this lab, you will:

- Download an authorized RHEL 9.8 KVM guest image.
- Create a dedicated OCI compartment and Object Storage bucket.
- Upload the QCOW2 image to OCI.
- Import and verify a compatible custom image.

Estimated Time: 45 minutes

## Task 1: Confirm Red Hat and OCI readiness

1. Sign in to the [Red Hat Customer Portal](https://access.redhat.com/).

2. Confirm that your account can download RHEL 9.8 and has an entitlement that you may use for a temporary workshop VM.

3. Sign in to the [OCI Console](https://cloud.oracle.com/).

4. Select the preparation tenancy and region for Labs 1 and 2. The destination tenancy and region are selected later when importing the prepared image.

5. Confirm that the region offers `VM.Standard.E5.Flex` or another RHEL-certified x86\_64 flexible VM shape.

    > **Important:** Shape certification and regional capacity can change. Check the [Red Hat Ecosystem Catalog](https://catalog.redhat.com/en/cloud/detail/252697) before a production deployment.

## Task 2: Download the RHEL KVM guest image

1. In the Red Hat Customer Portal, select **Downloads** and open **Red Hat Enterprise Linux**.

2. Select the following values:

    - Product variant: Red Hat Enterprise Linux for x86\_64
    - Version: 9.8
    - Image: KVM Guest Image

3. Download the QCOW2 image to your local computer.

    Do not select the Boot ISO, Binary DVD ISO, or source image. OCI's documented RHEL workflow requires the KVM guest image.

4. Record the exact filename and file size.

5. If Red Hat provides a checksum beside the download, calculate the local SHA-256 checksum and compare it with the published value.

    On Windows PowerShell, run:

    ```powershell
    <copy>
    Get-FileHash -Algorithm SHA256 <path-to-rhel-qcow2>
    </copy>
    ```

    On macOS or Linux, run:

    ```bash
    <copy>
    sha256sum <path-to-rhel-qcow2>
    </copy>
    ```

## Task 3: Create the workshop compartment

1. In the OCI Console, open the navigation menu and select **Identity & Security**, then **Compartments**.

2. Select **Create compartment**.

3. Enter the following values:

    - Name: `ol-migrate-lab`
    - Description: `Temporary resources for the RHEL to Oracle Linux workshop`
    - Parent compartment: Select the compartment permitted by your organization.

4. Select **Create compartment**.

5. Wait until the compartment is available, then select it and record its name.

## Task 4: Create a private Object Storage bucket

1. Open the navigation menu and select **Storage**, then **Buckets**.

2. Select the `ol-migrate-lab` compartment.

3. Select **Create bucket**.

4. Enter a unique bucket name beginning with `ol-migrate-rhel-image`.

5. Keep the default storage tier as **Standard** and the visibility as **Private**.

6. Keep this bucket private. The raw QCOW2 is imported from the bucket directly. An object-read pre-authenticated request is created later for the prepared export in Lab 2.

7. Select **Create**.

## Task 5: Upload the RHEL image

1. Open the new bucket and select **Upload**.

2. Select the downloaded RHEL 9.8 KVM guest QCOW2 file.

3. Start the upload and keep the browser tab open.

4. Wait until the upload completes successfully.

    Upload time depends on the image size and your network connection. If the upload fails, remove the incomplete object before retrying.

5. Select the object and confirm that the displayed size matches the local file size.

## Task 6: Import the custom image

1. Open the navigation menu and select **Compute**, then **Custom images**.

2. Select the `ol-migrate-lab` compartment and then select **Import image**.

3. Enter `rhel-9-8-migration-import` for the image name.

4. Select **Linux** as the operating system.

5. Select **Import from an Object Storage bucket**.

6. Select your bucket and the uploaded RHEL QCOW2 object.

7. Configure the image:

    - Image type: **QCOW2**
    - Launch mode: **Paravirtualized mode**

8. Select **Import image**.

9. On the Custom images page, monitor the image until its state changes from **Importing** to **Available**.

10. If the import fails, open the associated work request and review the error before retrying.

## Task 7: Configure and verify shape compatibility

1. Open the `rhel-9-8-migration-import` custom image.

2. Under **Resources**, select **Compatible shapes**.

3. Add `VM.Standard.E5.Flex` if it is not already listed and the current Red Hat certification catalog supports it.

4. Confirm the following checkpoint:

    - Image state is Available.
    - Operating system identifies a Linux image.
    - Image type is QCOW2.
    - Launch mode is paravirtualized.
    - At least one tested x86\_64 flexible shape is compatible.

## Task 8: Review your knowledge

1. Why did you select a KVM guest image instead of a RHEL installation ISO?

    The KVM guest image is a prepared QCOW2 cloud image with components such as `cloud-init`. It matches OCI's documented RHEL custom-image workflow.

2. Why is the Object Storage bucket private?

    The RHEL image is participant-authorized software and must not be redistributed publicly.

3. What indicates that the image is ready for Compute?

    Its custom-image state is Available, its settings are correct, and a certified compatible shape is configured.

You may now **proceed to the next lab**.

## Learn More

- [Importing Custom Linux Images](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/importingcustomimagelinux.htm)
- [Bring Your Own Image](https://docs.oracle.com/en-us/iaas/Content/Compute/References/bringyourownimage.htm)
- [Understanding RHEL image downloads](https://access.redhat.com/solutions/104063)
- [Red Hat Ecosystem Catalog for Oracle Cloud](https://catalog.redhat.com/en/cloud/detail/252697)

## Acknowledgements

- **Author** - Perside Foster, Principal Solution Engineer, Oracle
- Last Updated By/Date - Perside Foster, Nov 2026
