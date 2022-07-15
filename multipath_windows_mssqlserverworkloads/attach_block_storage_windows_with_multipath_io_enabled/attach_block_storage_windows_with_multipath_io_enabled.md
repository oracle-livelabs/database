# Attach Block storage on Windows with Multipath-IO (MPIO) enabled

## Introduction

This lab walks you through how to attach Block Storage on Windows with Multipath-IO (MPIO) enabled for **Microsoft SQL Server** workloads. 

Estimated Time:  30 min

### Objectives
In this lab, you will learn to :
* how to attach Block Storage on Windows with Multipath-IO (MPIO) enabled

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment

## Task 1: Configure the MPIO for OCI Block Volume

1. RDP to the Windows host using the OPC user credentials.

2. From the taskbar, click **search button** and search for Server Manager and click on Server Manager.

  ![Windows Command Search](./images/windows-command-search.png "Windows Command Search")

3. once successful open the Server Manager, click on **Tools** and select the **MPIO**

  ![Windows Server Manager select MPIO Role](./images/servermangermpio.png "Windows Server Manager select MPIO Roleora")

4. In the **MPIO Properties** selection
    * Click on **Discover Multi-Paths**
    * In Others section, select the **ORACLE BlockVolume** and then click on **Add**, and click on **Ok** to add the **ORACLE BlockVolume**.

  ![Windows Oracle block volume](./images/oracleblockvloume.png "Windows Oracle block volume")

  You may now proceed to the **next Task**.

5. The **ORACLE BlockVolume** was added to MPIO as shown in the following image. 

  ![Windows Oracle block volume success](./images/mpiosuccess.png "Windows Oracle block volume success")

  You may now **proceed to the next Task**.

##  Task 2: Attach Block Storage on Windows with Multipath-IO (MPIO) enabled

1. RDP to the Windows host using the OPC user credentials.

2. Right-click on the Start button from **Task Bar** from Windows and click on **Run** button. Once the **Run** command opens, type **diskmgmt.msc** to open the disk management service. 

  ![Windows Run Command](./images/windows_run.png "Windows Run Command")

3. From the **Disk Management** opens, you can see the unknown disk **Offline**, right-click on the disk and then click on **Online** to bring the disk online. 

  ![Disk Management disk online](./images/diskonline.png "Disk Management disk online")

4. After the disk **Online**, you can see the unknown disk **Not initialize**, right-click on the disk and then click on **Initialize Disk**. 

  ![Disk Management disk initialize](./images/initiateddisk.png "Disk Management disk initialize")

5. Select the disk and choose the **GPT** partition, and then click on **ok**

  ![Disk Management disk partition](./images/diskpartition.png "Disk Management disk partition")

6. The disk shows as the following image **Unallocated**, and then right-click on the disk and click on **New Simple Volume**.
  
  ![Disk Management create disk](./images/createdisk.png "Disk Management create disk")

7. The **disk create wizard** is shown as follows. 

  ![Disk Management disk online](./images/diskcreatewelcome.png "Disk Management disk online")

8. Leave the default values and click on **Next**.

  ![Disk Management disk size](./images/disksize.png "Disk Management disk size")

9. Assign the drive letter. 

  ![Disk Management disk letter](./images/diskletter.png "Disk Management disk letter")

10. In the **Format Partition** section
    * **Choose File System**: NTFS
    * **Allocation unit Size**: 64K
      > Note: **Microsoft SQL Server** uses extents to store data. Therefore, on a SQL Server machine, the NTFS allocation unit size for hosting SQL database files (including the tempdb) should be 64 KB.

    * Select the **Perform a quick format**

  ![Disk Management disk format partition](./images/diskformatpartition.png "Disk Management disk format partition")

11. The successful disk creation is shown in the following image.

  ![Disk Management disk creation success](./images/diskcreationcomplete.png "Disk Management disk creation success")

12. Right-click on newly created disk and click on **Properties**

  ![Disk Management disk Properties](./images/diskproperties.png "Disk Management disk Properties")

13. Click on **Hardware** tab and select the LUN1 and click on **Properties**. 

  ![Disk Management disk mpio properties](./images/diskmpioproperties.png "Disk Management disk mpio properties")

14. Click on **MPIO** and select the policy to **Round Robin** and click on **ok**.

  ![Disk Management disk mpio policy](./images/mpiopolicy.png "Disk Management disk mpio policy")

  You may now **proceed to the next Task**.
  
##  Task 3: Test the Disk Throughput from diskspd

1. Download the diskspd from the [link](https://github.com/microsoft/diskspd/releases/download/v2.1/DiskSpd.ZIP) from the browser.

2. Unzip the file **DiskSpd.ZIP**

  ![diskspd extract](./images/diskspdextract.png "diskspd extract")

3. To test random reads for IOPS: for the disk using the following diskspd command. 

        <copy>diskspd -d60 -t4 -o64 -b8k -r -Sh D: > c:\TestRandomReads.txt

   Open the **CMD** as administration and browse to the path where **diskspd.exe** file is available and run the diskspd command. The example is shown below. 

  ![diskspd extract](./images/diskspdresults.png "diskspd extract")

  Check the output file in the C drive. The results are shown in the following image. 

  ![diskspd extract read results](./images/results.png "diskspd extract read results")

  > Note:  For the throughput and IOPS performance numbers details for various volume sizes, see the [link] (https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumeultrahighperformance.htm#Higher_Performance). 

4. Repeat the steps from **Step3** to test **random reads for Throughput**: 

        <copy>diskspd -d60 -t4 -o64 -b8k -r -Sh D: > c:\TestRandomReadsThroughput.txt
  
  > Note: The parameter -b8K - SQL Server stores data in the pages, and these pages' size is 8KB; therefore, we will set the block size parameter as 8KB. Hence we have chosen the -b8K size. 

  Congratulations !!! You Have Completed Successfully The Workshop. 

## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Jitender Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, July 2022