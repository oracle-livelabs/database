# Verify the environment #

## Introduction ##

 Since we will upgrade databases, we have prepared an image with several database versions already set up. This image is accessible through a NoVNC URL and runs in the Oracle OCI Cloud.

 Estimated time: 5 minutes

### Objectives ###

In this lab, you will

- Connect to the hands-on lab client
- Optionally connect using a ssh client
- Setup the lab instructions inside the lab client

### Prerequisites ###

 To complete this lab, you need the following account credentials and assets:

- Oracle PTS 19c Lab environment
    - This environment has been pre-setup by the Livelabs environment
    - Your IP address is visible on the Livelabs -> Launch Workshop page
    - The URL to the NoVNC Remote Desktop is also visible on this screen

   ![](./images/01-LL-details.png)

## Task 1: Connect to the Hands-On Lab client image using NoVNC ##

 Click on the supplied link on the LiveLabs Attendee Page. A new browser window should open and show you a running Linux desktop like this:

   ![](./images/02-NoVNC-Desktop.png)

### Suggestion ####

 It is more accessible to cut-and-paste values from the Hands-On Labs if the Hands-On Lab document is open in the same desktop/environment as the prompt you want to paste. We therefore highly recommend you to:

- Make the remote Linux desktop fullscreen
- Open a new browser window inside the Linux Desktop Environment
- Navigate to Oracle Livelabs, log in and go to My Reservations to Launch this workshop

### Optional: Using SSH to connect to the image ###

 By default, the SSH ports are enabled, and the SSH daemon is running in the image so that you can connect your favorite SSH client to the image for all non-graphical steps in the labs.

 > **The ssh server only accepts public/private key authentication. <br>
 > It is NOT allowed to change the authentication method to accept passwords !**

 You are allowed to add your public key to the `authorized_keys` file in the image.
 It is out of the scope of this hands-on lab to demonstrate how to do this.

### Next step: Lab 2 - Install 19c ###

- **All labs depend on the 19c installation in lab 2**
- There is no dependency between the labs after lab 2
- Please continue with your hands-on experience by running the steps in Lab 2
- After finishing Lab 2, continue as instructed to the next lab or choose an exciting lab
    - If one lab is executing the upgrade, you can start another Lab if you want to
    - Every Lab has its dedicated instances and versions, so even the upgrade can run in parallel

You may now **proceed to the next lab**.

## Acknowledgements ##

- **Author** - Robert Pastijn, Database Product Management, PTS EMEA - April 2020
- **Last update** - Robert Pastijn, Database Product Development, PTS EMEA - November 2021
