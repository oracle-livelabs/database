# Run the Sample NoSQL Application

## Introduction

This lab walks you through the steps to create a sample HelloWorld application to connect to an Oracle NoSQL Database Cloud Service and perform basic table level operations.

Estimated Lab Time: 10 Minutes

### About Oracle NoSQL Database Cloud Service

Oracle NoSQL Database Cloud Service is a fully managed database cloud service that handles large amounts of data at high velocity. Developers can start using this service in minutes by following the simple steps outlined in this tutorial. To get started with the service, you create a table. Oracle NoSQL Database supports Java, Python, Node.js , Go and C#.

### Prerequisites

*  An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account
*  Successful completon of Lab 1 : Create an API Signing Key and SDK CLI Configuration File

This workshop contains different language implementation in the form of different tabs. Click the tab corresponding to the language you are interested in.

## **Step 1:** Download the appropriate Oracle NoSQL SDK
<if type="Java">

1.  Make sure that a recent version of the java jdk is installed locally on your computer.

2. Use the pre-supplied maven project [pom.xml](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/pom.xml) to configure Oracle NoSQL SDK. This grabs the SDK runtime from Maven Central.

```
<copy>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.oracle.nosql.example</groupId>
  <artifactId>HelloWorld</artifactId>
  <version>1.0-SNAPSHOT</version>
  <name>HelloWorld</name>
  <url>http://maven.apache.org</url>

  <dependencies>
    <dependency>
      <groupId>com.oracle.nosql.sdk</groupId>
      <artifactId>nosqldriver</artifactId>
      <version>5.2.27</version>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <artifactId>maven-clean-plugin</artifactId>
        <version>3.1.0</version>
      </plugin>
      <plugin>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.8.0</version>
        <configuration>
          <!--<verbose>true</verbose>-->
          <fork>true</fork>
        </configuration>
      </plugin>
    </plugins>
  </build>

</project>
</copy>
```
</if>

<if type="Python">

1. Make sure that python is installed in your system.

2. You can install the Python SDK through the Python Package Index with the command given below.
```
 <copy> pip3 install borneo </copy>
```
</if>

<if type="Go">
  1. Open the [Go Downloads](https://golang.org/doc/install) page in a browser and click the download tab corresponding to your operating system. Save the file to your home folder.
  2. Install Go in your operating system.
    - On Windows systems, Open the MSI file you downloaded and follow the prompts to install Go.

      *Note: By default, the installer will install Go to Program Files or Program Files (x86). You can change the location as needed. After installing, you will need to close and reopen any open command prompts so that changes to the environment made by the installer are reflected at the command prompt.*
    - On Linux systems, Extract the archive you downloaded into /usr/local, creating a Go tree in /usr/local/go. Add /usr/local/go/bin to the PATH environment variable.

      ```
       <copy>tar -C /usr/local -xzf go1.16.5.linux-amd64.tar.gz
       export PATH=$PATH:/usr/local/go/bin
       </copy>
      ```
  3. Verify that you've installed Go. In the Command Prompt window that appears, type the following command:

      ```
        <copy>
          $ go version
        </copy>
      ```
  Confirm that the command prints the installed version of Go.
  </if>
 <if type="Node.js">
  1. Open the [Node.js Download](https://nodejs.org/en/) and download Node.js for your operating system. Ensure that Node Package Manager (npm) is installed along with Node.js.
  2. Install the node SDK for Oracle NoSQL Database.

      ```
      <copy>
      npm install oracle-nosqldb
      </copy>
      ```
      With the above command, npm will create node_modules directory in the current directory and install it there.

      Another option is to install the SDK globally:

      ```
      <copy>
      npm install -g oracle-nosqldb
      </copy>
      ```
      You can do one of the above options depending on the permissions you have.
</if>
  <if type="C-sharp">

You can add the SDK NuGet Package as a reference to your project by using .Net CLI:
1. Go to your project directory

```
<copy>
cd <your-project-directory>
//This will create a project called HelloWorld
 dotnet new console -o HelloWorld
</copy>
```
2. Add the SDK package to your project.
  ```
 <copy>
  dotnet add package Oracle.NoSQL.SDK
  </copy>
  ```
  </if>

## **Step 2:** Download, build and run the sample application

<if type="Java">
1. Download the provided [HelloWorld.java](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.java) file and move it to your home directory.

2. Review the sample application. You can access the [JavaAPI Reference Guide](https://docs.oracle.com/en/cloud/paas/nosql-cloud/csnjv/index.html) to reference Java classes, methods, and interfaces included in this sample application.

  Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. When authenticated as a specific user, your tables are managed in the root compartment of your tenancy unless otherwise specified. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root". Edit the code [HelloWorld.java](https://objectstorage.us-ashburn-1.oraclecloud.com/p/qCpBRv5juyWwIF4dv9h98YWCDD50574Y6OwsIHhEMgI/n/c4u03/b/data-management-library-files/o/HelloWorld.java), replace the placeholder of the compartment  in the fucntion ```setDefaultCompartment``` with the OCID of your compartment. Save the file and close it.

3. From your home directory, navigate to ".oci" directory.

       ```
       <copy>
       cd ~
       cd .oci
       </copy>
       ```
Use `vi` or `nano` or any text editor to create a file named `config` in the `.oci` directory.

      ```
      <copy>
      [DEFAULT]
      user=USER-OCID
      fingerprint=FINGERPRINT-VALUE
      tenancy=TENANCY-OCID
      key_file=<Location of the private key oci_api_key_private.pem>
      </copy>
      ```
Replace [USER-OCID] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five) with the value you copied on your note pad, FINGERPRINT-VALUE with your API key fingerprint, TENANCY-OCID with your [tenancy OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five). The [key_file] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How) is the private key that you generated. You should have noted these values in a text file as you've been working through this workshop.  Use the values recorded from Lab 1.
![](images/config-file.png)
When `SignatureProvider` is constructed without any parameters, the default [Configuration File](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/sdkconfig.htm) is located in the `~/.oci/config` directory.

4. Build your maven project using the following command.

```
<copy>
$ mvn exec:java -Dexec.mainClass=HelloWorld -Dexec.args="-service cloud -endpoint <your region endpoint>"
</copy>
```

*Note: In the main method of `HelloWorld.java`, the `dropTable(handle)` is commented out to allow you to see the result of creating the tables in the Oracle Cloud Console.*
</if>

<if type="Python">

1. Download the provided [HelloWorld.py](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.py) file and move it to your home directory.

2. Review the sample application. You can access the [Python API Reference Guide](https://nosql-python-sdk.readthedocs.io/en/latest/api.html) to reference Python classes and methods included in this sample application.

   Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. When authenticated as a specific user, your tables are managed in the root compartment of your tenancy unless otherwise specified. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root". Edit the code [HelloWorld.py](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.py), replace the placeholder of the compartment in the function ```set_default_compartment``` with the OCID of your compartment. Save the file and close it.

3. From your home directory, navigate to ".oci" directory. Create a file named `config` in the `.oci` directory. Add OCID, tenancy ID, fingerprint & key credentials in the `config` file.

      ```
      <copy>
      [DEFAULT]
      user=USER-OCID
      fingerprint=FINGERPRINT-VALUE
      tenancy=TENANCY-OCID
      key_file=<Location of the private key oci_api_key_private.pem>
      </copy>
      ```
    Replace [USER-OCID] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five) with the value you copied on your note pad, FINGERPRINT-VALUE with your API key fingerprint, TENANCY-OCID with your [tenancy OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five). The [key_file] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How) is the private key that you generated. You should have noted these values in a text file as you've been working through this workshop.  Use the values recorded from Lab 1.
      ![](images/config-file.png)

4. Execute the sample application:
   Open the Command Prompt, and navigate to the directory where you saved the `HelloWorld.py` program.
   Execute the HelloWorld program.

    ```
    <copy>
    python HelloWorld.py
    </copy>
    ```
    You get the following output:

    ```
    <copy>
    Connecting to the Oracle NoSQL Cloud Service
    Creating table: create table if not exists HelloWorldTable (employeeid integer, name string,  primary key(employeeid))
    Wrote record:
          {'employeeid': 1, 'name': 'Tracy'}
    Read record:
          {'employeeid': 1, 'name': 'Tracy'}
    </copy>
    ```

*Note: In the main method of `HelloWorld.py`, the `drop_table` method is commented out to allow you to see the result of creating the tables in the Oracle Cloud Console.*  
</if>
<if type="Go">

1. Download the provided [HelloWorld.go](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.go) file and move it to your home directory.

2. Review the sample application. You can access the [Go API docs](https://pkg.go.dev/github.com/oracle/nosql-go-sdk/nosqldb?utm_source=godoc) to reference Go classes and methods included in this sample application.

   Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. When authenticated as a specific user, your tables are managed in the root compartment of your tenancy unless otherwise specified. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root". Edit the code [HelloWorld.go](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.go) , replace the placeholder of the compartment in the constructor of ```NewSignatureProviderFromFile``` with the OCID of your compartment. Save the file and close it.

3.From your home directory, navigate to ".oci" directory. Create a file named `config` in the `.oci` directory. Add OCID, tenancy ID, fingerprint & key credentials in the `config` file.

      ```
      <copy>
      [DEFAULT]
      user=USER-OCID
      fingerprint=FINGERPRINT-VALUE
      tenancy=TENANCY-OCID
      key_file=<Location of the private key oci_api_key_private.pem>
      </copy>
      ```
      Replace [USER-OCID] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five) with the value you copied on your note pad, FINGERPRINT-VALUE with your API key fingerprint, TENANCY-OCID with your [tenancy OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five). The [key_file] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How) is the private key that you generated. You should have noted these values in a text file as you've been working through this workshop.  Use the values recorded from Lab 1.
      ![](images/config-file.png)

4.  Execute the sample application:
    Initialize a new module for the example program.

      ```
      <copy>
      go mod init example.com/HelloWorld
      </copy>
      ```
  Build the HelloWorld application.

       ```
       <copy>
       go build -o HelloWorld
       </copy>
       ```
  Run the HelloWorld application.

       ```
       <copy>
       ./HelloWorld
       </copy>
       ```

   *Note: In the main method of `HelloWorld.go`, the code for dropping the table is commented out to allow you to see the result of creating the tables in the Oracle Cloud Console.*    
</if>
<if type="Node.js">

1. Download the provided [HelloWorld.js](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.js) file and move it to your home directory.

2. Review the sample application. You can access the [Node.js API  Reference Guide](https://oracle.github.io/nosql-node-sdk/index.html) to reference Node.js classes and methods included in this sample application.

   Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. When authenticated as a specific user, your tables are managed in the root compartment of your tenancy unless otherwise specified. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root". Edit the code [HelloWorld.js](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.js), replace the placeholder of the compartment in the ```NoSQLClient``` constructor with the OCID of your compartment. Save the file and close it.

3. From your home directory, navigate to ".oci" directory. Create a file named `config` in the `.oci` directory. Add OCID, tenancy ID, fingerprint & key credentials in the `config` file.

      ```
      <copy>
      [DEFAULT]
      user=USER-OCID
      fingerprint=FINGERPRINT-VALUE
      tenancy=TENANCY-OCID
      key_file=<Location of the private key oci_api_key_private.pem>
      </copy>
      ```
      Replace [USER-OCID] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five) with the value you copied on your note pad, FINGERPRINT-VALUE with your API key fingerprint, TENANCY-OCID with your [tenancy OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five). The [key_file] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How) is the private key that you generated. You should have noted these values in a text file as you've been working through this workshop.  Use the values recorded from Lab 1.
      ![](images/config-file.png)

4. Execute the Sample Application
   Open the Command Prompt, and navigate to the directory where you saved the `HelloWorld.js` program.
   Execute the HelloWorld program.

      ```
      <copy>
      node HelloWorld.js
      </copy>
      ```
   *Note: In the main method of `HelloWorld.js`, the `dropTable(handle)` is commented out to allow you to see the result of creating the tables in the Oracle Cloud Console.*    
</if>
<if type="C-sharp">
1. Download the provided [HelloWorld.cs](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.cs) file and move it to your home directory.
2. Review the sample application. You can access the [.NET API  Reference Guide](https://oracle.github.io/nosql-dotnet-sdk/index.html) to reference .NET classes and methods included in this sample application.

   Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. When authenticated as a specific user, your tables are managed in the root compartment of your tenancy unless otherwise specified. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root". Edit the code [HelloWorld.cs](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/HelloWorld.cs), replace the placeholder of the compartment in the ```NoSQLClient``` constructor with the OCID of your compartment. Save the file and close it.

3. From your home directory, navigate to ".oci" directory. Create a file named `config` in the `.oci` directory. Add OCID, tenancy ID, fingerprint & key credentials in the `config` file.

      ```
      <copy>
      [DEFAULT]
      user=USER-OCID
      fingerprint=FINGERPRINT-VALUE
      tenancy=TENANCY-OCID
      key_file=<Location of the private key oci_api_key_private.pem>
      </copy>
      ```
      Replace [USER-OCID] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five) with the value you copied on your note pad, FINGERPRINT-VALUE with your API key fingerprint, TENANCY-OCID with your [tenancy OCID](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five). The [key_file] (https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How) is the private key that you generated. You should have noted these values in a text file as you've been working through this workshop.  Use the values recorded from Lab 1.
      ![](images/config-file.png)
4. Run your Application as shown below. This command will build and run the application.

```
<copy>
 dotnet run -f net5.0
</copy>
```
   *Note: In the RunBasicExample method of `HelloWorld.cs`, the section to drop table is commented out to allow you to see the result of creating the tables in the Oracle Cloud Console.*    
</if>
## **Step 3:** Explore tables using the Oracle Cloud Infrastructure Console

1. On the left hand menu, click **NoSQL Database**.

  ![](images/nosql-cloud.png)

2. Click **HelloWorldTable** to open the details page.

  *If you do not see HelloWorldTable select your correct compartment ( that you mentioned in your code) on the left dropdown.*

  ![](images/open-helloworldtable.png)

3. Click **Table Rows** under Resources.

  ![](images/helloworldtable.png)

4. Click Run Query to execute the select statement and display the record inserted into the table.

  ![](images/run-query.png)

Congratulations! You have completed the workshop.

This application accesses Oracle NoSQL Database Cloud Service, but most likely you would want to deploy by running your application inside your own tenancy co-located in the same Oracle Cloud Infrastructure region as your NoSQL table and use the Oracle Cloud Infrastructure Service Gateway to connect to the NoSQL Cloud Service.

## Learn More

* [About Oracle NoSQL Database Cloud Service](https://docs.oracle.com/pls/topic/lookup?ctx=cloud&id=CSNSD-GUID-88373C12-018E-4628-B241-2DFCB7B16DE8)
* [Oracle NoSQL Database Cloud Service page](https://cloud.oracle.com/en_US/nosql)
<if type="Java">
* [Java API Reference Guide](https://docs.oracle.com/en/cloud/paas/nosql-cloud/csnjv/index.html)
</if>
<if type="Python">
* [Python API Reference Guide](https://nosql-python-sdk.readthedocs.io/en/latest/api.html)
</if>
<if type="Go">
* [Go Reference Guide](https://pkg.go.dev/github.com/oracle/nosql-go-sdk/nosqldb?utm_source=godoc)
</if>
<if type="Node.js">
* [Node.js API Reference Guide](https://oracle.github.io/nosql-node-sdk/index.html)
</if>

## Acknowledgements
* **Author** - Dave Rubin, Senior Director, NoSQL and Embedded Database Development and Michael Brey, Director, NoSQL Product Development
* **Contributors** - Jaden McElvey, Technical Lead - Oracle LiveLabs Intern
* **Last Updated By/Date** -Vandana Rajamani, Database User Assistance, December 2021
