# Setup the vector database (Oracle Database 23ai)

## Introduction

This lab guide you through setting up Oracle Database Free (23c) in a container and setting it up for vector operations.

Estimated Time: 15 minutes

### Objectives

* Create an Oracle Cloud Infrastructure (OCI) Compute instance needed to run the workshop.
* Install and configure the vector database.

### Prerequisites

* Basic knowledge of Oracle Cloud Infrastructure (OCI) concepts and console
* Basic Linux knowledge

> Note: Any kind of Linux-based system is okay, but you will need to modify the following instructions to suit your specific setup.

## Task 1: Create a compute instance to run the lab

> Note: If you don't know how to create a virtual machine and connect to it via SSH, please [see this lab first](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=648&clear=RR,180&session=108750023091545). The following section will only give you a brief overview.

Open your Oracle Cloud Infrastructure Cloud Console and make sure you are in the "US Midwest (Chicago)" or "Frankfurt" region, which is necessary to access the OCI Generative AI services endpoint.

   ![console](images/image1.png)

1. Navigate to the "Compute" section and click on "Instances".

2. Click on "Create Instance".

3. Fill in the necessary details, such as name, compartment, and availability domain.

4. Choose the "Oracle Linux 8" image.

5. Choose a `VM.Standard.E4.Flex` shape.

6. In the Networking section, most of the defaults are perfect for our purposes. However, you will need to scroll down and select the Assign a public IPv4 address option.

6. Configure the security list to allow SSH (port 22) and Jupyter Lab (port 8888). [See here](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securitylists.htm) how to do it.

7. Create your instance by clicking on the `Create` button.

8. Connect to your remote instance using SSH.
   ```
   <copy>
   ssh -i <private_ssh_key> opc@<public_ip_address>
   </copy>
   ```

## Task 2: Install and configure the database (Oracle Database 23ai Free)
For simplicity, we will install our database in a container using Podman, a popular container management tool similar to Docker.

### Step 1:  Installing Podman.
```bash
<copy>
sudo dnf config-manager --set-enabled ol8_addons
sudo dnf install -y podman
</copy>
``` 

Now, let's verify our install:
```bash
<copy>
podman --version
</copy>
```

### Step 2:  And now, the database itself.

```bash
<copy>
podman run 
    -d 
    --name 23ai 
    -p 1521:1521   
    -e ORACLE_PWD=<the paswword for database admin accounts>   
    -v oracle-volume:/home/<your home directory>/oradata   
    container-registry.oracle.com/database/free:latest
</copy>
```

Let's verify if it worked:
```bash
<copy>
podman ps
</copy>
   ```
### Step 3: Configuring the database setup.

1. First, start a Bash session inside our newly created container.
   ```bash
   <copy>
   podman exec -it 23ai /bin/bash
   <copy>
   ```
2. Let's connect to the default Oracle 23c Free PDB service and create a tablespace and user by default.
   ```bash
   <copy>
   sqlplus sys@localhost:1521/freepdb1 as sysdba
   <copy>
   ```
   When prompted, enter the password you created when you started your container in the previous step. 
   
3. Paste the following command inside the SQL*Plus session.
   ```sql
   <copy>
   Create bigfile tablespace tbs2  
   Datafile 'bigtbs_f2.dbf'  
   SIZE 1G AUTOEXTEND ON  
   next 32m maxsize unlimited
   extent management local segment space management auto;
   </copy>
   ``` 
   ```sql
   <copy>
   CREATE UNDO TABLESPACE undots2 DATAFILE 'undotbs_2a.dbf' SIZE 1G AUTOEXTEND ON RETENTION GUARANTEE;
   </copy>
   ```
   ```sql
   <copy>
   CREATE TEMPORARY TABLESPACE temp_demo  
   TEMPFILE 'temp02.dbf' SIZE 1G reuse AUTOEXTEND ON  
   next 32m maxsize unlimited extent management local uniform size 1m;
   </copy>
   ```

   We create now a new user for our vector operations:
   ```sql
   <copy>
   create user vector identified by vector default tablespace tbs2  
   quota unlimited on tbs2;
   </copy>
   ```
   ```sql
   <copy>
   grant DB_DEVELOPER_ROLE to vector;
   </copy>
   ```

4. Exiting the sqlplus session:
   ```sql
   <copy>
   exit
   </copy>
   ```

5. We have now to allocate memory for the in-memory vector index.
   ```bash
   <copy>
   sqlplus / as sysdba
   </copy>
   ```
   ```sql
   <copy>
   create pfile from spfile;
   </copy>
   ```
   ```sql
   <copy>
   ALTER SYSTEM SET vector_memory_size = 512M SCOPE=SPFILE;
   </copy>
   ```
   ```sql
   <copy>
   shutdown
   </copy>
   ```
   ```sql
   <copy>
   startup
   </copy>
   ```
   
   Check if the vector memory size parameter is there after the restart.
   ```sql
   <copy>
   show parameter vector_memory_size;
   </copy>
   ```
   It should show `512M`.


6. We now exit the sqlplus session:
   ```
   <copy>
   exit
   </copy>
   ```

   And the bash session inside the container:
   ```
   <copy>
   exit
   </copy>
   ```

You may now **proceed to the next lab**

## Learn More
* [Oracle Generative AI Service](https://www.oracle.com/artificial-intelligence/generative-ai/generative-ai-service/)
* [Oracle Database Free](https://www.oracle.com/database/free/)
* [Get Started with Oracle Database 23ai](https://www.oracle.com/ro/database/free/get-started/)

## Acknowledgements
* **Author** - Bogdan Farca, Customer Strategy Programs Leader, Digital Customer Experience (DCX), EMEA
* **Contributors** 
   - Liana Lixandru, Senior Digital Adoption Manager, Digital Customer Experience (DCX), EMEA
   - Kevin Lazarz, Senior Manager, Product Management, Database
* **Last Updated By/Date** -  Bogdan Farca, May 2024