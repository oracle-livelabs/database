# Using noVNC Remote Desktop

## Introduction

This workshop can be accessed using a browser based graphical remote desktop (noVNC) or via SSH. You are free to use either method, but we recommend SSH as for this workshop it provides a superior experience.

This lab will show you how to get started with your workshop with a remote desktop session. SSH access was (optionally) provisioned when you created the OCI instance using the provided ORM stack file.

If you prefer to use SSH access (recommended), and do not plan to use the graphical desktop, then you can skip the rest of this lab and *proceed to the next lab.*

**Estimated Lab Time**: 5 minutes

### Objectives

In this lab, you will:

- Enable fullscreen display of remote desktop session
- Enable remote clipboard integration
- Open the workshop guide from the remote desktop

### Prerequisites

This lab assumes you have:

- Launched the workshop in your own tenancy (paid or free trial)

## Task 1: Enable Full-screen Display
For seamless desktop integration and to make the best use of your display, perform the following tasks to render your remote desktop session in fullscreen mode.

1. Click on the small gray tab on the middle-left side of your screen to open the control bar.

    ![](./images/novnc-fullscreen-1.png " ")

2. Select *Fullscreen* to render the session on your entire screen.

    ![](./images/novnc-fullscreen-2.png " ")
    ![](./images/novnc-fullscreen-3.png " ")

## Task 2: Enable Copy/Paste from Local to Remote Desktop
During the execution of your labs you may need to copy text from your local PC/Mac to the remote desktop, such as commands from the lab guide. While such direct copy/paste isn't supported as you will realize, you may proceed as indicated below to enable an alternative local-to-remote clipboard with Input Text Field.

1. Continuing from the last task above, Select the *clipboard* icon

    ![](./images/novnc-clipboard-1.png " ")

2. Copy some text from your local computer as illustrated below and paste into the clipboard widget, then finally open up the desired application (e.g. Terminal) and paste accordingly using *mouse controls*

    ![](./images/novnc-clipboard-2.png " ")

    *Note:* Please make sure you initialize your clipboard with step [1] shown in the screenshot above before opening the target application in which you intend to paste the text. Otherwise will find the *paste* function in the context menu grayed out when attempting to paste for the first time.

## Task 3: Open Your Workshop Guide

1. If the *Web* browser window(s) is(are) not already open side-by-side, double-click on the *Get Started with your Workshop* icon from the remote desktop. This will launch one or two windows depending on the workshop.

    ![](./images/novnc-launch-get-started-1.png " ")

2. On the left windows is your workshop guide and depending on your workshop, you may also one or two browser tabs loaded with webapps. e.g. Weblogic console, Enterprise Manager Cloud Console, or a relevant application to your workshop such as SQL Developer, JDeveloper, etc.

    ![](./images/novnc-launch-get-started-2.png " ")
    ![](./images/novnc-launch-get-started-3.png " ")

You may now *proceed to the next lab*.

## Acknowledgements
* **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
* **Contributors** - Arabella Yao, Database Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022