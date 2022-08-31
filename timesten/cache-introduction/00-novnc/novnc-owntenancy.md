# Using noVNC Remote Desktop and enabling SSH access

## Introduction

This workshop can be accessed using a browser based graphical remote desktop (noVNC). It can also be accessed using SSH. This lab will show you how to get started with your workshop with a remote desktop session. 

If you plan to only use SSH access then you can *proceed to the next lab*.

**Estimated Lab Time**: 5 minutes

### Objectives

In this lab, you will:

- Enable fullscreen display of remote desktop session
- Enable remote clipboard integration
- Open the workshop guide from the remote desktop

### Prerequisites

This lab assumes you have:

- Launched the workshop in your own tenancy using via the provided ORM stack

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
    
    **IMPORTANT:** Due to the slightly cumbesome nature of copying between your host system and the NoVNC session, we recommend that you perform all of the copy/paste actions within the NoVNC session rather than between your host and the NoVNC session.

## Task 3: Open Your Workshop Guide

1. If the *Web* browser window is not already open, double-click on the *Get Started with your Workshop* icon from the remote desktop. This will open the workshop instructions within the NoVNC session (ideal for copy/paste).

    ![](./images/novnc-launch-get-started-1.png " ")

2. On the left is the browser window with your workshop guide

    ![](./images/novnc-launch-get-started-2.png " ")

*You may now proceed to the next lab.*

## Acknowledgements
* **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
* **Contributors** - Arabella Yao, Database Product Management
* **Last Updated By/Date** - Chris Jenkins, August 2022