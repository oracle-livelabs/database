# Prepare VMware Source VMs  for Migration  to OLVM

## Introduction

In this lab, you prepare Windows and Linux source VMs for the VirtIO devices used by Oracle Linux Virtualization Manager (OLVM). Complete this preparation before replication so the migrated VM can boot and access its network and disks after it is provisioned on OLVM.

Estimated Time: 30 minutes per source VM

### Objectives

In this lab, you will:

* Identify the operating system of each source VM in the migration wave.
* Install Oracle VirtIO drivers on Windows source VMs.
* Confirm that Linux VirtIO modules are available in the initramfs.
* Reboot and validate driver readiness before migration.

### Important

Perform these steps with the Windows or Linux administrator responsible for each source VM. Test the procedure on a non-production VM first, and record a backup or rollback point before changing a production source VM.

## Task 1: Identify Source VM Operating Systems

1. List every source VM planned for the migration wave.

2. Record the operating system and version for each VM.

3. Use the Windows procedure for Windows VMs and the Linux procedure for Linux VMs.

    ```text
    <copy>Source VM:
    Operating system and version:
    VM owner:
    Backup or rollback point:</copy>
    ```

## Task 2: Install Oracle VirtIO Drivers on Windows

1. Identify the latest Oracle VirtIO Drivers for Microsoft Windows release from Oracle Software Delivery Cloud or My Oracle Support.

    At the time this lab was authored, Oracle documents version 2.3.2. Confirm the current release before each workshop delivery.

2. Review the release notes and confirm that the driver release supports the Windows version in the source VM.

3. Sign in to the Windows source VM with the administrator account that can install drivers.

4. Follow Oracle's download instructions to obtain the driver package or ISO.

5. Create a restore point or confirm that the approved VM backup is available.

6. Reboot Windows VM before installation.

7. Install the Oracle VirtIO drivers by following the installation instructions included with the downloaded package.

8. Reboot the Windows VM when the installer requests it.

9. After the reboot, confirm that Windows starts normally and that the driver installation completed without errors.

10. Optionally validate the installation by checking for the driver binaries and service entries. For example, confirm that the expected files exist and that the related services are present under `HKLM\\SYSTEM\\CurrentControlSet\\Services`.

    ```bash
    <copy>C:\Windows\System32\drivers\vioscsiorc.sys</copy>
    ```

11. Record the Windows readiness result.

    ```bash
    <copy>Windows VirtIO release:
    Storage driver validated: Yes/No
    Network driver validated: Yes/No
    Reboot completed: Yes/No</copy>
    ```

## Task 3: Prepare VirtIO Drivers in Linux initramfs

1. Sign in to the Linux source VM with an account that can rebuild the initramfs.

2. Check whether VirtIO modules are already included in the initramfs.

    ```bash
    <copy>lsinitrd|grep virtio</copy>
    ```

3. If the required modules are not present, rebuild the initramfs with the `qemu` dracut module so the VirtIO drivers required by the migration target are included. On Oracle Linux, use the distribution-approved `dracut` syntax for the installed release. For example:

    ```bash
    <copy>dracut -f --add qemu</copy>
    ```

4. Run the validation command again and confirm that the expected VirtIO modules are listed.

    ```bash
    <copy>lsinitrd|grep virtio</copy>
    ```

5. Reboot the Linux VM now.

6. Confirm that Linux starts normally and that the source VM's disks and network interfaces are available.

7. Record the Linux readiness result.

    ```text
    <copy>Kernel version:
    VirtIO modules present before rebuild: Yes/No
    Initramfs rebuilt: Yes/No/Not required
    VirtIO modules present after rebuild: Yes/No
    Reboot completed: Yes/No</copy>
    ```

## Task 4: Confirm Migration Readiness

1. Confirm that each source VM has completed the appropriate Windows or Linux preparation.

2. Confirm that each VM rebooted successfully after driver preparation.

3. Confirm that the VM owner has validated the operating system, network, disks, and application services.

4. Do not begin replication for a VM with missing VirtIO storage or network readiness. Resolve the issue and repeat validation first.

You may now **proceed to the next lab**

## Learn More

* [Downloading the Oracle VirtIO Drivers for Microsoft Windows](https://docs.oracle.com/en/operating-systems/oracle-linux/kvm-virtio/kvm-virtio-DownloadingtheOracleVirtIODriversforMicrosoftWindows.html)
* [About Oracle VirtIO Drivers for Microsoft Windows](https://docs.oracle.com/en/operating-systems/oracle-linux/kvm-virtio/kvm-virtio-WhatsNew.html)
* [Oracle Linux UEK VirtIO initramfs guidance](https://docs.oracle.com/en/operating-systems/uek/7/relnotes7.0/33834972.html)

## Acknowledgements

* **Author** - Mark Atkinson, Evgeny Golenkov, Andrey Sokolov, Perside Foster
* **Contributor** - Keya Balutkar
* **Last Updated By/Date** - Perside Foster, July 2026
