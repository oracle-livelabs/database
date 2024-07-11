# Prepare Setup

## Introduction
In this lab, you will quickly configure the Oracle Autonomous Database Free 23ai Docker Container in your remote desktop environment.

*Estimated Time:* 10 minutes

### Objectives

In this lab, you will:

* Pull, run, and start an Oracle Autonomous Database 23ai Docker image with Podman.
* Gain access to Database Actions, APEX, and more via your container.
* Explore Oracle’s AI Vector Search. 

### Prerequisites
This lab assumes you have:
- An Oracle account

<!-- ## Task 1: Obtain the PODMAN Container information 
1.   Copy the command below to obtain the PODMAN Container ID.

```
<copy>
podman container ls -a 
</copy>
``` -->

## Task 1: Pull and Start Docker Image
1.  If the terminal is not displayed as shown below, select Activities and click Terminal.

    ![Open the terminal](images/novnc-terminal.png)
 
2.  Copy the commands below and paste them into the terminal. This will pull the zip file with our podman-compose files and scripts that we'll be running to create and configure the ADB container. This series of commands will also unzip the files, and give them the permissions to be executable within the container.

    ```
    <copy>
    wget https://objectstorage.ca-toronto-1.oraclecloud.com/p/AZAlcycOLHY5iAWwYZ6KTwJcrnJy7k1LcpHJh0ELmGdZj5ptc6rEteLmnUKnn4Gl/n/c4u04/b/apex-images/o/BERT-TINY.onnx
    wget https://objectstorage.ca-toronto-1.oraclecloud.com/p/WC7293Pwf4UNmrM44Mequmek_fjzKDkU-zBUrA8lAzcJMAiR19Jecjt1x1U4gBne/n/c4u04/b/apex-images/o/compose3.zip
    unzip compose3.zip
    chmod +x scripts start-container.sh
    </copy>
    ```

    ![Wget the zip file with the scripts and give them permissions](images/wget.png)

3. Run this command to begin the process of starting up the container. Go to your LiveLabs reservation under View Login Details in order to get your information needed to login to the container registry.

    ```
    <copy>
    ./start-container.sh
    </copy>
    ```

    ![Run start container script](images/run-start-container.png)

    ![Information underneath login details](images/auth-token-copy.png)

4. Input your tenancy name, username, and auth token as found under "View Login Details" in your LiveLabs reservation.
    
    ![Input user variables](images/input-user-vars.png)

5. Input the desired workload type for your ADB.

    ![Input ADB configuration variables](images/adb-config-vars.png)

6. The container is now initializing. A podman-compose.yml script is running in the background to pull the image, start the container, mount necessary scripts onto the database.

    ![Podman Compose is running to start the container](images/podman-compose.png)

<!-- 3. Now that you are prompted to login, type the username in the format of ***tenancy-name***/***username***. The password will be your ***auth-token***. You will find all the necessary information in the Login Details of your LiveLabs reservation. 

    ![Copy auth token](images/4-auth-token-copy.png)

4. Hit enter, and it should say "Login Succeeded".

    ![Login succeeded](images/3-login-succeeded.png) -->

7. Now, we're waiting until the container is healthy so we can run the remainder of our scripts.

    ![Waiting until container is healthy](images/container-status.png)

8. Once the container is healthy, another script will automatically run to reset where the APEX images are sourced from. This allows APEX to function within our LiveLabs environment.
    
    ![Successful execution of reset image prefix script in SQL](images/successful-sql-script.png)

    
9. Note that your wallet and admin password will be printed as shown below.

    ![Screenshot of script output producing the admin and wallet password](images/password-output.png)

10. As the script completes, make sure you copy and run the command printed out at the end so you can easily run ADB-CLI commands.

    ![ADB CLI](images/adb-cli.png)

11. (Optional) If you want to reset your admin password, use the command printed out by the script and fill in your desired password. Make sure the following passwords you select are between 12-30 characters, with at least 1 uppercase letter, 1 lowercase letter, and 1 number.

    ![Reset password command](images/reset-password-command.png)

12. Now, the ADB container is live and you can run commands against it. You can view the list of available commands using the following command.

    ```
    <copy>
    adb-cli --help 
    </copy>
    ```

    ![Run adb-cli command help](images/adb-cli-help.png)

## Task 2: Access Database Actions and APEX

1. To access Database Actions/ORDS, open a new window in your Chrome browser and go to this website:

    ```
    <copy>
    https://localhost:8443/ords
    </copy>
    ```

    It must include the "https://" to work.

    ![ORDS landing page](images/ords-landing.png)

2. Sign in with your admin password you had set for the ADB in Task 1, Step 4.

    ![Sign into DB Actions](images/sign-in-ords.png)

3. You now have access to Database Actions! Let's first click SQL Developer Web to test it out.

    ![Database Actions](images/launch-sql-developer.png)

4. Next, let's go to Oracle APEX. Go back to the landing page and click Go to Oracle APEX.

    ```
    <copy>
    https://localhost:8443/ords
    </copy>
    ```

    ![ORDS landing page](images/launch-apex.png)

5. Sign in with your admin password you had set for the ADB in Task 1, Step 4.

    ![Sign into APEX](images/sign-in-apex.png)

6. Now you have access to Database Actions and APEX within your ADB 23ai Container Image! Feel free to explore what's possible within your environment.

<!-- 11. 
9. You can add a database.

    ```
    <copy>
    adb-cli add-database --workload-type "ADW" --admin-password "Welcome_1234"
    </copy>
    ```

10. You can change the admin password.

    ```
    <copy>
    adb-cli change-password --database-name "MYADW" --old-password "Welcome_1234" --new-password "Welcome_12345"
    </copy>
    ```

11. **Note:** At anytime, you can check if your container is still running with this command. The list returned should not be empty.

    ```
    <copy>
    podman ps -a
    </copy>
    ```

 11. 
mkdir /scratch/
podman cp adb-free:/u01/app/oracle/wallets/tls_wallet /scratch/tls_wallet

12. 

hostname fqdn -->


<!-- 11. This is how you connect to ORDS.

12. Finally, this is how you would connect to APEX. -->

## Appendix 1: Restart Docker Container
1. If you wanted to stop the ADB Docker container at any time and start with a fresh one, feel free to. If you are in the middle of running the start-container.sh script, type ctrl+C to stop it.

2. Run this command to stop the container.

    ```
    <copy>
    podman-compose down
    </copy>
    ```

    ![Stopping the container](images/stop-container.png)

2. Return to the home directory and restart the start-container.sh script.

    ```
    <copy>
    cd ~
    ./start-container.sh
    </copy>
    ```

    ![Input user variables](images/input-user-vars.png)

4. Run through the same steps onward of Task 1, step 4.

## Appendix 2: Explore the Podman Compose script
1. If you want to take a closer look at how we configure the container, run this command.

    ```
    <copy>
    cat ~/podman-compose.yml
    </copy>
    ```

## Acknowledgements
- **Authors** - Brianna Ambler, Dan Williams Database Product Management, July 2024
- **Contributors** - Brianna Ambler, Dan Williams,  Database Product Management
- **Last Updated By/Date** - Brianna Ambler, Dan Williams July 2024
