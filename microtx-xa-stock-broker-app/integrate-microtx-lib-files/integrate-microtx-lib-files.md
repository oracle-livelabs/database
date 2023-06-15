# Integrate MicroTx Client Libraries with the Bank and Stock-Trading application

## Introduction

This lab walks you through all the steps to integrate the functionality provided by the Oracle® Transaction Manager for Microservices (MicroTx) client libraries with an application. Use MicroTx client libraries to register the required interceptors and callbacks, to obtain a connection to the application's resource manager, and to delineate transaction boundaries which indicate that an XA transaction has started, and then to commit or roll back the transaction.

Estimated Time: *5 minutes*

### Objectives

In this lab, you will:

* Configure the Stock Broker service as a Transaction initiator. A transaction initiator service starts and ends a transaction.
* Configure the Stock Broker service as a Transaction participant. A transaction participant service joins the transaction. The Stock Broker service initiates the transaction, and then participates in it. After starting a transaction to buy or sell shares, the Stock Broker service also participates in the transaction to deposit or withdraw the shares from a user's account.

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account.
* Successfully completed all previous labs:
  * Get Started
  * Lab 1: Prepare setup
  * Lab 2: Environment setup
* Logged in using remote desktop URL as an `oracle` user. If you have connected to your instance as an `opc` user through an SSH terminal using auto-generated SSH Keys, then you must switch to the `oracle` user before proceeding with the next step.

      ```
      <copy>
      sudo su - oracle
      </copy>
      ```
* Configured Visual Studio Code to edit the code for Java applications.

## Task 1: Configure the Stock Broker App as a Transaction Initiator

Uncomment all the lines of code in the following files to integrate the functionality provided by the MicroTx client libraries with the Stock Broker application.

* `pom.xml` file located in the `/home/oracle/OTMM/otmm-22.3.2/samples/xa/java/bankapp/StockBroker/` folder
* `UserStockTransactionServiceImpl.java` file located in the `/com/oracle/tmm/stockbroker/service/impl/` package of the `StockBroker` application

The following section provides reference information about each line of code that you must uncomment and its purpose. You can skip this reading this section if you only want to quickly uncomment the code and run the application. You can return to this section later to understand the purpose of each line of code that you uncomment.

1. Include the MicroTx library as a maven dependency in the application's `pom.xml` file. Open the `pom.xml` file which is in the `/home/oracle/OTMM/otmm-22.3.2/samples/xa/java/bankapp/StockBroker/` folder in any code editor, and then uncomment the following lines of code. The following sample code is for the 22.3.2 release. Provide the correct version, based on the release that you want to use.

    ```
    <copy>
    <dependency>
      <groupId>com.oracle.tmm.jta</groupId>
      <artifactId>TmmLib</artifactId>
      <version>22.3.2</version>
    </dependency>
    </copy>
    ```

2. Open the `UserStockTransactionServiceImpl.java` file in any code editor. This file is in the `/com/oracle/tmm/stockbroker/service/impl/` package of the `StockBroker` application.

3. Uncomment the following line of code to import the `oracle.tmm.jta.TrmUserTransaction` package.

    **Sample command**

    ```java
    <copy>
    import oracle.tmm.jta.TrmUserTransaction;
    </copy>
    ```

4. Uncomment the following line of code to initialize an object of the `TrmUserTransaction` class in the application code for every new transaction. This object demarcates the transaction boundaries, which are begin, commit, or roll back. In your application code you must create this object before you begin a transaction.

    **Sample command**

    ```java
    <copy>
    TrmUserTransaction transaction = new TrmUserTransaction();
    </copy>
    ```

5. Uncomment the following line of code to begin an XA transaction to buy stocks.

    **Sample command**

    ```java
    <copy>
    transaction.begin(true);
    </copy>
    ```

6. Uncomment all the occurrences of the following lines of code to specify the transaction boundaries for rolling back or committing the transaction. Based on the application's business logic, commit or rollback the transaction.

    **Sample command**

    ```java
   <copy>
   transaction.rollback();
   transaction.commit();
   </copy>
    ```

7. Uncomment the following line of code under `sell()` to create an instance of the `TrmUserTransaction` object to sell stocks.

    **Sample command**

    ```java
    <copy>
    TrmUserTransaction transaction = new TrmUserTransaction();
    </copy>
    ```

8. Uncomment the following line of code under `sell()` to begin the XA transaction to sell stocks.

    **Sample command**

    ```java
    <copy>
    transaction.begin(true);
    </copy>
    ```

9. Uncomment all the occurrences of the following lines of code to specify the transaction boundaries for rolling back or committing the transaction. Based on your business logic, commit or rollback the transaction.

    **Sample command**

    ```java
   <copy>
   transaction.rollback();
   transaction.commit();
   </copy>
    ```

## Task 2: Configure the Stock Broker Application as a Transaction Participant

Since the Stock broker application participates in the transaction in addition to initiating the transaction, you must make additional configurations for the application to participate in the transaction and communicate with its resource manager.

When you integrate the MicroTx client library for Java with the Stock broker application, the library performs the following functions:

* Enlists the participant service with the transaction coordinator.
* Injects an `XADataSource` object for the participant application code to use through dependency injection. The MicroTx libraries automatically inject the configured data source into the participant services, so you must add the `@Inject` or `@Context` annotation to the application code. The application code runs the DML using this connection.
* Calls the resource manager to perform operations.

Uncomment all the lines of code in the following files:

* `DatasourceConfigurations.java` file located in the `/com/oracle/tmm/stockbroker` package of the `StockBroker` application.
* `TMMConfigurations.java` file located in the `/com/oracle/tmm/stockbroker` package of the `StockBroker` application.
* `AccountServiceImpl.java` file located in the `/com/oracle/tmm/stockbroker/service/impl/` package of the `StockBroker` application.
* `StockBrokerTransactionServiceImpl.java` file located in the `/com/oracle/tmm/stockbroker/service/impl/` package of the `StockBroker` application.

The following section provides reference information about each line of code that you must uncomment and its purpose. You can skip this reading this section if you only want to quickly uncomment the code and run the application. You can return to this section later to understand the purpose of each line of code that you uncomment.

To configure the Stock Broker application as a transaction participant:

1. Open the `DatasourceConfigurations.java` file in any code editor. This file is in the `/com/oracle/tmm/stockbroker` package of the `StockBroker` application.

2. Uncomment the following lines of code in the transaction participant function or block to create a `PoolXADataSource` object and provide credentials and other details to connect to the resource manager. This object is used by the MicroTx client library.

    ```java
    <copy>
    @Bean(name = "SBPoolXADataSource")
    @Primary
    public PoolXADataSource getXAPoolDataSource() {
        PoolXADataSource xapds = null;
        try {
            xapds = PoolDataSourceFactory.getPoolXADataSource();
            xapds.setConnectionFactoryClassName("oracle.jdbc.xa.client.OracleXADataSource");
            xapds.setURL(url); //database connection string
            xapds.setUser(username); //username to access the resource manager
            xapds.setPassword(password); //password to access the resource manager
            xapds.setMinPoolSize(Integer.valueOf(minPoolSize));
            xapds.setInitialPoolSize(Integer.valueOf(initialPoolSize));
            xapds.setMaxPoolSize(Integer.valueOf(maxPoolSize));
        } catch (SQLException ea) {
            log.severe("Error connecting to the database: " + ea.getMessage());
        }
        log.info("PoolXADataSource initialized successfully.");
        return xapds;
    }
    </copy>
    ```

    It is your responsibility as an application developer to ensure that an XA-compliant JDBC driver and required parameters are set up while creating the `PoolXADataSource` object.

3. Open the `TMMConfigurations.java` file in any code editor. This file is in the `/com/oracle/tmm/stockbroker` package of the `StockBroker` application.

4. Uncomment the following lines of code to import the following packages.

    ```java
    <copy>
    import oracle.tmm.common.TrmConfig;
    import oracle.tmm.jta.XAResourceCallbacks;
    import oracle.tmm.jta.common.TrmConnectionFactory;
    import oracle.tmm.jta.common.TrmSQLConnection;
    import oracle.tmm.jta.common.TrmXAConnection;
    import oracle.tmm.jta.common.TrmXAConnectionFactory;
    import oracle.tmm.jta.common.TrmXASQLStatementFactory;
    import oracle.tmm.jta.filter.TrmTransactionRequestFilter;
    import oracle.tmm.jta.filter.TrmTransactionResponseFilter;
    import oracle.ucp.jdbc.PoolXADataSource;
    import org.glassfish.jersey.internal.inject.AbstractBinder;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Lazy;
    import org.springframework.web.context.annotation.RequestScope;
    import javax.sql.XAConnection;
    import java.sql.Connection;
    import java.sql.Statement;
    </copy>
    ```

4. Uncomment the following lines of code to create a `PoolXADatasource` object. `PoolXADatasource` is an interface defined in JTA whose implementation is provided by the JDBC driver. The MicroTx client library uses this object to connect to database to start XA transactions and perform various operations such as prepare, commit, and rollback. The MicroTx library also provides a SQL connection object to the application code to execute DML using dependency injection.

    ```java
    <copy>
    @Autowired
    private PoolXADataSource poolXADataSource;
    </copy>
    ```

5. Register the listeners, XA resource callback, filters for MicroTx libraries, and MicroTx XA connection bindings.

    ```java
    <copy>
    //Register the MicroTx XA Resource callback that coordinates with the transaction coordinator
    register(XAResourceCallbacks.class);

    // filters for the MicroTx libraries that intercept the JAX-RS calls and manages the XA Transactions
    register(TrmTransactionRequestFilter.class);
    register(TrmTransactionResponseFilter.class);

    // MicroTx XA connection Bindings
    register(new AbstractBinder() {
        @Override
        protected void configure() {
            bindFactory(TrmConnectionFactory.class).to(Connection.class);
            bindFactory(TrmXASQLStatementFactory.class).to(Statement.class);
        }
        });
    </copy>
    ```

6. Uncomment the following line of code in the `init()` method to initialize an XA data source object.
    ```java
    <copy>
    initializeOracleXADataSource();
    </copy>
    ```

7. Uncomment the following line of code to call the XA data source object that you have initialized.

    ```java
    <copy>
    private void initializeOracleXADataSource() {
        TrmConfig.initXaDataSource(this.poolXADataSource);
    }
    </copy>
    ```

8. Initialize a Bean for the `TrmSQLConnection` object and `TrmXAConnection` object.

    ```java
    <copy>
    // Register the MicroTx TrmSQLConnection object bean
    @Bean
    @TrmSQLConnection
    @Lazy
    @RequestScope
    public Connection tmmSqlConnectionBean(){
        return new TrmConnectionFactory().get();
    }

    // Register the MicroTx TrmXaConnection object bean
    @Bean
    @TrmXAConnection
    @Lazy
    @RequestScope
    public XAConnection tmmSqlXaConnectionBean(){
        return new TrmXAConnectionFactory().get();
    }
    </copy>
    ```

9. Save the changes.

10. Open the `AccountServiceImpl.java` file in any code editor. This file is in the `/com/oracle/tmm/stockbroker/service/impl/` package of the `StockBroker` application.

11. Uncomment the following lines of code to import the required packages.

    ```java
    <copy>
    import javax.inject.Inject;
    import oracle.tmm.jta.common.TrmSQLConnection;
    </copy>
    ```

12. Uncomment the following lines of code so that the application uses the connection passed by the MicroTx client library. The following code in the participant application injects the `connection` object that is created by the MicroTx client library.

    ```java
    <copy>
    @Inject
    @TrmSQLConnection
    private Connection connection;
    </copy>
    ```

13. Delete all the occurrences of the following line of code as the connection is managed by the MicroTx client library.

    ```java
    <copy>
    Connection connection = poolDataSource.getConnection();
    </copy>
    ```

14. Save the changes.

15. Open the `StockBrokerTransactionServiceImpl.java` file in any code editor. This file is in the `/com/oracle/tmm/stockbroker/service/impl/` package of the `StockBroker` application.

16. Uncomment the following lines of code to import the required packages.

    ```java
    <copy>
    import javax.inject.Inject;
    import oracle.tmm.jta.common.TrmSQLConnection;
    </copy>
    ```

17. Uncomment the following lines of code so that the application uses the connection passed by the MicroTx client library. The following code in the participant application injects the `connection` object that is created by the MicroTx client library.

    ```java
    <copy>
    @Inject
    @TrmSQLConnection
    private Connection connection;
    </copy>
    ```

18. Delete all the occurrences of the following line of code as the connection is managed by the MicroTx client library.

    ```java
    <copy>
    Connection connection = poolDataSource.getConnection();
    </copy>
    ```

19. Save the changes.

You may now **proceed to the next lab**.

## Learn More

* [Develop Applications with XA](https://docs.oracle.com/en/database/oracle/transaction-manager-for-microservices/22.3/tmmdg/develop-xa-applications.html#GUID-D9681E76-3F37-4AC0-8914-F27B030A93F5)

## Acknowledgements

* **Author** - Sylaja Kannan
* **Contributors** - Brijesh Kumar Deo and Bharath MC
* **Last Updated By/Date** - Sylaja, June 2023
