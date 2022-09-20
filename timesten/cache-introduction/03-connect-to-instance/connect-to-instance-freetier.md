# Connect to the workshop compute instance using SSH (optional)

## Introduction

You always have the option to access the workshop host using the browser based NoVNC graphical desktop (covered in a previous lab). In addition, if you enabled the option when deploying the workshop, you also have direct SSH access to the workshop host.

In this optional lab, you will learn how to connect to the workshop host using SSH. If you prefer to use the NoVNC remote Desktop rather than SSH then you can simply *proceed to the next lab*.
 
**Estimated Lab Time:** 5 minutes

### Objectives

- Connect to the compute instance using SSH (optional)

### Prerequisites

This lab assumes that you have:

- Completed all the previous labs in this workshop, in sequence.

## Task 1: Connect using SSH (optional)

If you configured SSH access as part setting up the ORM stack then you can connect to the instance, as the **oracle** user, using an SSH private key.

If you selected an automatically generated SSH private key, the key can be viewed and copied on the Stack's Application Information tab:

![Workshp SSH private key](./images/orm-ssh-key.png " ")

Copy/paste the key into a file on your client computer, or import into your SSH client, and use it to connect via SSH.

**NOTE:** On Linux and macOS systems, SSH private keys should be stored in your user's .ssh directory (**~/.ssh**) and must have permissions of **600 (-rw-------)**.

Assuming that the SSH private key is **~/.ssh/id_livelabs** and the public IP address of the workshop compute instance is **123.123.123.123** then you can connect, as the **oracle** user, using:

```
<copy>
ssh -i ~/.ssh/id_livelabs oracle@123.123.123.123
</copy>
```

```
The authenticity of host '123.123.123.123 (123.123.123.123)' can't be established.
ED25519 key fingerprint is SHA256:bm2wv3HgyBIhIRov6+EtId10rQHyq1LXpXglQMpqhqA.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '140.238.69.118' (ED25519) to the list of known hosts.
Last login: Mon Jun 27 09:12:52 2022 from aa.bb.cc.dd
[oracle@ttlivelabvm ~]$
```

You can now *proceed to the next lab*. 

If you plan to use SSH for the rest of the workshop, keep your terminal session open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022

