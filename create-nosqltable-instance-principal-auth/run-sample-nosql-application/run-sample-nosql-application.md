# Run the Sample NoSQL Application

## Introduction

This lab walks you through the steps to create a sample HelloWorld application to connect to an Oracle NoSQL Database Cloud Service and perform basic table-level operations.

Estimated Lab Time: 30 Minutes

About Oracle NoSQL Database Cloud Service

Oracle NoSQL Database Cloud Service is a fully managed database cloud service that handles large amounts of data at high velocity. Developers can start using this service in minutes by following the simple steps outlined in this tutorial. To get started with the service, you create a table. Oracle NoSQL Database supports Java, Python, Node.js, Go, C#, and Rust.

### Prerequisites

-   An Oracle CLoud Account
-   Successful completion of Lab 1

You will learn to develop a sample Oracle NoSQL application using multiple language SDKs for Oracle NoSQL. The instructions for different SDKs are contained in tabbed pages. Click the tab corresponding to the language you are interested in.

## Task 1: Download the appropriate Oracle NoSQL SDK in your instance
<if type="Java">

1. Make sure that a recent version of the java jdk is installed locally on your computer.
2. Make sure you have `maven` installed. See [Installing Maven](https://maven.apache.org/install.html) for details.
3. Create a `test` directory. Copy `pom.xml`below to configure Oracle NoSQL SDK. This grabs the SDK runtime from Maven Central.

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
          <version><NOSQL_JAVASDK_VERSION></version>
        </dependency>
      </dependencies>

      <build>
        <plugins>
          <plugin>
            <artifactId>maven-clean-plugin</artifactId>
            <version>3.1.0</version>
          </plugin>
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.8.1</version>
            <configuration>
            <source>17</source>
            <target>17</target>
            <fork>true</fork>
            </configuration>
          </plugin>
        </plugins>
      </build>
    </project>
    </copy>
    ```
>   Note: The latest SDK can be found here [Oracle NoSQL Database SDK For Java](https://mvnrepository.com/artifact/com.oracle.nosql.sdk/nosqldriver). Please make sure to replace the placeholder for the version of the Oracle NoSQL Java SDK in the `pom.xml` file with the exact SDK version number.
</if>

<if type="Python">

1. Make sure that python is installed in your system.
2. You can install the Python SDK through the Python Package Index with the command given below.

    ```
    <copy> pip3 install borneo </copy>
    ```
3. If you are using the Oracle NoSQL Database cloud service you will also need to install the oci package:

    ```
    <copy> pip3 install oci </copy>
    ```
</if>

<if type="Go">

1.  Open the [Go Downloads](https://golang.org/doc/install) page in a browser and click the download tab corresponding to your operating system. Save the file to your home folder.

2.  Install Go in your operating system.
    - On Windows systems, Open the MSI file you downloaded and follow the prompts to install Go.

      >  Note: By default, the installer will install Go to Program Files or Program Files (x86). You can change the location as needed. After installing, you will need to close and reopen any open command prompts so that changes to the environment made by the installer are reflected at the command prompt.

    - On Linux systems, Extract the archive you downloaded into /usr/local, creating a Go tree in /usr/local/go. Add /usr/local/go/bin to the PATH environment variable.

        ```
        <copy>tar -C /usr/local -xzf go1.16.5.linux-amd64.tar.gz
        export PATH=$PATH:/usr/local/go/bin
        </copy>
        ```
        
3.  Verify that you've installed Go. In the Command Prompt window that appears, type the following command:

      ```
      <copy>
      $ go version
      </copy>
      ```
  Confirm that the command prints the installed version of Go.
</if>

<if type="Node.js">

The Node SDK supports both JavaScript and TypeScript applications. This lab includes code samples for JavaScript and TypeScript applications. Decide the language that you want to use.
  
1.  Open the [Node.js Download](https://nodejs.org/en/) link and download Node.js. Follow the prompts to install the Node.js package. The Node Package Manager (npm) is automatically installed.

With this Node.js package, you can run both JavaScript and TypeScript applications.

2.  Add node-v2x.xx.xx-linux-x64/bin to the PATH environment variable.

      ```
      <copy>
      export PATH=~/Downloads/node-v22.18.0-linux-x64/bin/:$PATH
      </copy>
      ```
      Verify the installation using

      ```
      <copy>
      node -v
      </copy>
      ```
      ```
      <copy>
      npm -v
      </copy>
      ```
3.  Install the Node SDK for Oracle NoSQL Database.
      
      ```
      <copy>
      npm install oracle-nosqldb
      </copy>
      ```  
With the command above, npm creates the `node_modules` directory in the current directoy
</if>
  
<if type="C-sharp">

1.  Make sure you have [.NET](https://dotnet.microsoft.com/en-us/download) installed in your system. You can add the SDK NuGet Package as a reference to your project by using .Net CLI.

2.  Add the PATH where you installed .NET in environment variable

    ```
    <copy>
    export PATH=~/Downloads:$PATH
    </copy>
    ```
3.  Run the following command to create your project directory.

    ```
    <copy>
    dotnet new console -o HelloWorld
    </copy>
    ```

4.  Go to your project directory. Add the SDK package to your project.

    ```
    <copy>
    dotnet add package Oracle.NoSQL.SDK
    </copy>
    ```
  </if>

<if type="Rust">

1.  Open the [Rust download page](https://www.rust-lang.org/tools/install) in your browser and download Rust using the instructions given. This creates a `~/.cargo/bin` directory where all the required tools are installed.

2.  Add the PATH directory in your environment variables.
    ```
    <copy>
    export PATH=~/.cargo/bin:$PATH
    </copy>
    ```

3.  Verify the installation using
    ```
    <copy>
    rustc --version
    </copy>
    ```

4.  Create a new project directory using
    ```
    <copy>
    cargo new HelloWorld
    </copy>
    ```

5.  Navigate to the project directory and update the Cargo.toml file as shown below.
    ```
    <copy>
    [package]
    name = "HelloWorldRust"
    version = "0.1.0"
    edition = "2024"

    [dependencies]
    tokio = { version = "1.38.0", features = ["full"] }
    chrono = { version = "0.4.31", features = ["alloc", "std"] }
    oracle-nosql-rust-sdk = { version = "0.1" }
    tracing = "0.1.40"
    tracing-subscriber =  { version = "0.3", features = ["env-filter", "std"] }
    </copy>
    ```
</if>

## Task 2: Download, build, and run the sample application

<if type="Java">

1.  Download the provided [Hello World.java](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/n/c4u04/b/nosql-cloud-service-authenticate-with-instance-principal/o/HelloWorld.java) file and move it to the `test/src/main/java` directory.

2.  Review the sample application. You can access the JavaAPI Reference Guide to know more about Java classes, methods, and interfaces included in this sample application.

    >   Note: Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root".

    Edit the code in HelloWorld.java file, replace the placeholder of the compartment in the function setDefaultCompartment with the OCID of your compartment. Replace the placeholder for region with the name of your region. Save the file and close it.

3.  Navigate to the `test` directory you created.

4.  Compile your java code using the command
    ```
    <copy>
    mvn compile
    </copy>
    ```

5.  Build your maven project using the following command.

    ```
    <copy>
    mvn compile exec:java "-Dexec.mainClass=HelloWorld"
    </copy>
    ```
</if>

<if type="Python">

1.  Download the provided [HelloWorld.py](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/n/c4u04/b/nosql-cloud-service-authenticate-with-instance-principal/o/HelloWorld.py) file.

2.  Review the sample application. You can access the [Python API Reference Guide](https://nosql-python-sdk.readthedocs.io/en/latest/api.html) to reference Python classes and methods included in this sample application.

    >   Note: Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root".

    Edit the code in HelloWorld.py file, replace the placeholder of the compartment in the function `set_default_compartment` with the OCID of your compartment. Replace the placeholder for region with the name of your region. Save the file and close it.

3.  Execute the sample application: Open the terminal and navigate to the directory where you saved the `HelloWorld.py` program. Execute the HelloWorld program.

    ```
    <copy>
    python3 HelloWorld.py
    </copy>
    ```
    You get the following output
    
    ```
    <copy>
    Inside main
    Connecting to the Oracle NoSQL Cloud Service
    Creating table: create table if not exists HelloWorldTable (employeeid integer, name STRING,  primary key(employeeid))
    Wrote record: 
        {'employeeid': 1, 'name': 'Tracy'}
    Read record: 
        {'employeeid': 1, 'name': 'Tracy'}
    </copy>
    ```
</if>

<if type="Go">

1.  Download the provided [HelloWorld.go](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/n/c4u04/b/nosql-cloud-service-authenticate-with-instance-principal/o/HelloWorld.go) file and move it to your desired directory.

2.  Review the sample application. You can access the [Go API docs](https://pkg.go.dev/github.com/oracle/nosql-go-sdk/nosqldb) to reference Go classes and methods included in this sample application.

    >   Note: Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root".

    Edit the code in HelloWorld.go file, replace the placeholder of the compartment in the constructor of `NewSignatureProviderFromFile` with the OCID of your compartment. 

Replace the placeholder for region with the name of your region. Save the file and close it.

3.  Execute the sample application: Initialize a new module for the example program.
    ```
    <copy>
    go mod init example.com/HelloWorld
    </copy>
    ```
    You see the following output:
    ```
    <copy>
    go: creating new go.mod: module example.com/HelloWorld
    go: to add module requirements and sums:
                  go mod tidy 
    </copy>
    ```

4.  Run the command below to add the various modules to the project
    ```
    <copy>
    go mod tidy
    </copy>
    ```
    You see the following output:
    ```
    <copy>
    go: finding module for package github.com/oracle/nosql-go-sdk/nosqldb/auth/iam
    go: finding module for package github.com/oracle/nosql-go-sdk/nosqldb
    go: downloading github.com/oracle/nosql-go-sdk v1.4.7
    go: finding module for package github.com/oracle/nosql-go-sdk/nosqldb/common
    go: finding module for package github.com/oracle/nosql-go-sdk/nosqldb/types
    go: found github.com/oracle/nosql-go-sdk/nosqldb in github.com/oracle/nosql-go-sdk v1.4.7
    go: found github.com/oracle/nosql-go-sdk/nosqldb/auth/iam in github.com/oracle/nosql-go-sdk v1.4.7
    go: found github.com/oracle/nosql-go-sdk/nosqldb/common in github.com/oracle/nosql-go-sdk v1.4.7
    go: found github.com/oracle/nosql-go-sdk/nosqldb/types in github.com/oracle/nosql-go-sdk v1.4.7
    go: downloading github.com/stretchr/testify v1.3.1-0.20190712000136-221dbe5ed467
    go: downloading github.com/davecgh/go-spew v1.1.0
    go: downloading github.com/pmezard/go-difflib v1.0.0
    go: downloading gopkg.in/yaml.v2 v2.4.0
    go: downloading github.com/stretchr/objx v0.1.0 
    </copy>
    ```

5.  Build the HelloWorld application
    
    ```
    <copy>
    go build -o HelloWorld
    </copy>
    ```
    Run the HelloWorld application
    ```
    <copy>
    ./ HelloWorld
    </copy>
    ```

>   Note: In the main method of HelloWorld.go, the code for dropping the table is commented out to allow you to see the result of creating the tables in the Oracle Cloud Console.
</if>

<if type="Node.js">

The given code sample in JavaScript and TypeScript use the [ES6 modules](https://docs.oracle.com/pls/topic/lookup?ctx=en/database/other-databases/nosql-database/24.1/nsdev&id=node_ecma_mod).

1.  For JavaScript applications, download the [HelloWorld.js](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/n/c4u04/b/nosql-cloud-service-authenticate-with-instance-principal/o/HelloWorld.js) file and move it to your home directory. For TypeScript applications, download the [HelloWorld.ts](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/n/c4u04/b/nosql-cloud-service-authenticate-with-instance-principal/o/HelloWorld.ts) file and move it to your home directory.

2.  Review the sample application. You can access the [Node.js API Reference Guide](https://oracle.github.io/nosql-node-sdk/index.html) to reference Node.js classes and methods included in this sample application.

    >   Note: Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root".

    Depending on your application, edit either the JavaScript code in HelloWorld.js or the TypeScript code in HelloWorld.ts, replace the placeholder of the compartment in the `NoSQLClient` constructor with the OCID of your compartment. Replace the placeholder for region with the name of your region. Save the file and close it.

3.  Execute the Sample Application

    For JavaScript Application: Open the terminal and navigate to the directory where you saved the `HelloWorld.js` program. Execute the HelloWorld program.
    ```
    <copy>
    node HelloWorld.js
    </copy>
    ```
    For TypeScript Application: Open the terminal and navigate to the directory where you saved the `HelloWorld.ts` program. Execute the HelloWorld program.
    ```
    <copy>
    npx tsx HelloWorld.ts
    </copy>
    ```
</if>

<if type="C-sharp">

1.  Download the provided [HelloWorld.cs](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/n/c4u04/b/nosql-cloud-service-authenticate-with-instance-principal/o/HelloWorld.cs) file and move it to your home directory.

2.  Review the sample application. You can access the [.NET API Reference Guide](https://oracle.github.io/nosql-dotnet-sdk/index.html) to reference .NET classes and methods included in this sample application.

    >   Note: Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root".

    Edit the code in HelloWorld.cs file, replace the placeholder of the compartment in the `NoSQLClient` constructor with the OCID of your compartment. Replace the placeholder for region with the name of your region. Save the file and close it.

3.  Go to your project directory. You will see the example source code `Program.cs`. Remove this file.
    ```
    <copy>
    rm Program.cs
    </copy>
    ```

4.  Build and run your project as shown below.
    
    ```
    <copy>
    dotnet run
    </copy>
    ```

>   Note: Multiple dotnet target frameworks are supported. Currently the supported frameworks are .NET 7.0 and higher.
</if>

<if type="Rust">

1.  Download the [HelloWorld.rs](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/n/c4u04/b/nosql-cloud-service-authenticate-with-instance-principal/o/HelloWorld.rs) file, navigate to the HelloWorld/src folder. The src folder already contains a `main.rs` file. Replace the content of main.rs with those from the downloaded file.

    To edit the `main.rs` file in editor, run the command below:
    ```
    <copy>
    vi main.rs
    </copy>
    ```

2.  Review the sample application. You can access the Rust Reference Guide to reference Rust classes and methods included in this sample application.

    >   Note: Oracle NoSQL Database Cloud Service tables are created in a compartment and are scoped to that compartment. It is recommended not to create tables in the "root" compartment, but to create them in your own compartment created under "root".
    
    Edit the code in `main.rs` file, replace the placeholder of the compartment in the `builder` class with the OCID of your compartment. Save the file and close it.

3.  Navigate back to the project directory and build your project using
    ```
    <copy>
    cargo build
    </copy>
    ```

4.  Run your project using
    
    ```
    <copy>
    cargo run
    </copy>
    ```
</if>

## Acknowledgements

-   **Author** - Aayushi Arora, Database User Assistance Development 
-   **Contributors** - Suresh Rajan, Michael Brey, Ramya Umesh
-   **Last Updated By/Date** - Aayushi Arora, January 2026