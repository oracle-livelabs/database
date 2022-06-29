# Connect to the workshop compute instance

## Introduction

In this lab, you will learn the different ways to connect to the OCI compute instance that hosts the workshop.

The workshop requires you to use a terminal session to run various commands and observe their output. Often you may need to copy and paste commands or text from the workshop instructions into the terminal session.

If you chose to run the workshop in the LiveLabs sandbox then the only connection method available to you by default is a GUI session using the browser-based VNC mechanism. It is possible to set up SSH connectivity by adding your own SSH key into the instance (follow the instructions provided in the noVNC lab).

If you chose to run the workshop in your own tenancy, or in a free-trial Cloud account, then you can use the same browser-based GUI connection method. Also, if you selected the option during deployment via the ORM stack, you also have the option to use SSH connectivity (**strongly recommended)**. 

Estimated Time: **5 minutes**

### Objectives

- Connect to the compute instance using noVNC
- Connect to the compute instance using SSH (optional)

### Prerequisites

This lab assumes that you have:

- Completed all the previous labs in this workshop, in sequence.

## Task 1: Connect using noVNC

All environments support browser based noVNC connections.

_LiveLabs sandbox_

In the LiveLabs reservation page for your active reservation, you will see the URL to use for a noVNC connection to the workshop instance.

_Own tenancy or free-trial Cloud account_

At the end of the ORM stack 'apply' job execution log you will see the noVNC connection URL.

Copy/paste the URL into your browser and you should then see the workshop desktop.

![Workshp noVNC Desktop](./images/novnc-desktop.png " ")

You can use the **Terminal** option under the *Activities* menu, or double-click the *Terminal* icon on the desktop, to open a terminal session.

## Task 2: Connect using SSH (optional but recommended)

You can connect to the instance as the oracle user using an SSH private key.

_LiveLabs sandbox_

You can follow the instructions in the noVNC lab to add an SSH public key to the oracle user's SSH **authorized_keys** file. You then connect using the corresponding SSH private key.

_Own tenancy or free-trial Cloud account - user-provided public key_

If you enabled SSH connectivity by providing your own SSH public key as part of the ORM stack deployment process then you can connect using the corresponding SSH private key.

_Own tenancy or free-trial Cloud account - system-generated key pair_

If you enabled SSH connectivity and asked for a system generated key as part of the ORM stack deployment process, the SSH private key needed to connect is displayed at the end of the ORM stack 'apply' job execution log. Copy/paste the key into a file on your client computer, or import into your SSH client, and use that file to connect.

**NOTE:** On Linux and macOS systems, SSH private keys should be stored in your user's .ssh directory (**~/.ssh**) and must have permissions of **600 (rw-------)**.

Assuming that the SSH private key is **~/.ssh/id_livelabs** and the public IP address of the workshop compute instance is **123.123.123.123** then you can connect using:

**ssh -i ~/.ssh/id_livelabs oracle@123.123.123.123**

```
$ ssh -i ~/.ssh/id_livelabs oracle@123.123.123.123                                                      11:55:17
The authenticity of host '123.123.123.123 (123.123.123.123)' can't be established.
ED25519 key fingerprint is SHA256:bm2wv3HgyBIhIRov6+EtId10rQHyq1LXpXglQMpqhqA.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '140.238.69.118' (ED25519) to the list of known hosts.
Last login: Mon Jun 27 09:12:52 2022 from aa.bb.cc.dd
[oracle@ttlivelabvm ~]$
```

You can now *proceed to the next lab*. You can keep your terminal session open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022

