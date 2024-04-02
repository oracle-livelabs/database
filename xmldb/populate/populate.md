# Create tables and populate data

## Introduction
This lab will use the SQL Workshop in Database Actions from the Autonomous Transaction Processing page. We will create a simple table with an XMLType column in it and populate the table with some XML documents.

Estimated Time: 15 minutes

### Objectives
In this lab, you will learn:
1.	How to create and populate a table with an XMLType column

### Prerequisites
- Be logged into your Oracle Cloud Account

## Task 1: Open Database Actions
1.	Log in to the Oracle Cloud.
2.	If you are using a Free Trial or Always Free account, and you want to use Always Free Resources, you need to be in a region where Always Free Resources are available. You can see your current default Region in the top, right-hand corner of the page.
3.	Click the navigation menu in the upper left to show top-level navigation choices.
4.	Click on Oracle Database and choose Autonomous Transaction Processing.
5.	If using FreeTier, your compartment should be the root compartment for your tenancy.
Note: Avoid the use of the ManagedCompartmentforPaaS compartment as this is an Oracle default used for Oracle Platform Services.
6.	You should see your database XMLDB listed in the center. Click on the database name "XMLDB".
7.	On the database page, choose Database Actions.
8.	You are now in Database Actions.
Database Actions allows you to connect to your Autonomous Database through various browser-based tools. We will just be using the SQL workshop tool.
9.	You should be in the Database Actions panel. Click on the SQL card.

## Task 2: Create and Populate a Table with an XMLType Column
1.	Go to Database Actions panel

    Click on the SQL card. When you first enter SQL, you will get a tour of the features. We recommend you step through it, but you can skip the tour by clicking on the "X". The tour is available at any time by clicking the tour button. You can dismiss the warning that you are logged in as an ADMIN user.

2.	Create a table with XMLType column

    We will create a simple table to record the sample purchase orders. It contains a numeric column for purchase ID and an XMLType column for purchase details. 

    Copy the following into the 'Worksheet' area and press the "Run Statement" button:

    ```
    -- By default, the storage type is Binary XML
    CREATE TABLE purchaseorder
    (
        id  NUMBER PRIMARY KEY,
        doc XMLTYPE
    );
    ```

    ```
    SELECT column_name, storage_type 
        FROM user_xml_tab_cols 
        WHERE table_name ='PURCHASEORDER'
    ```
    You should see the message "Table PURCHASEORDER created". 

    ![Create table](./images/img-1.png)

    On the left side, click the "Refresh" button to see your new table in the tables list.

    ![Table list](./images/img-2.png)

3.	Populate the table with a few rows

    Use the 'trashcan' icon to delete the previous statement from the Worksheet area. Copy the following SQL into the worksheet area. Make sure you highlight the whole statement with your mouse and press the "Run Statement" button:

    Here we are using XML files stored in the Object store. So, we will now load the XML data to our table from the Object store.

    ```
    <copy>
    -- Create the credentials
    begin
    DBMS_CLOUD.create_credential(
        credential_name => 'OBJ_STORE_CRED',
        username => 'your_email_address',
        password => 'your_password'
    );
    end;
    / 
    </copy>
    ```
    Now let’s insert the documents from the object store.

    ```
    <copy>
    -- Inserting xmldoc-1
    DECLARE
        BLOB_IN   BLOB;
        X         XMLTYPE;
    BEGIN
        BLOB_IN := DBMS_CLOUD.GET_OBJECT(CREDENTIAL_NAME => null, 
                                    OBJECT_URI => 'https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/labfiles/livelab-xmldoc-1.xml'
        );
        X := XMLTYPE(BLOB_IN, nls_charset_id('AL32UTF8'));
        INSERT INTO PURCHASEORDER VALUES (
            1,
            X
        );
    END;
    </copy>
    ```

    ![Insert from the object store](./images/img-3.png)

    You can also use the external table approach to load the XML documents into your table. Here is the link for more info: [External table approach to load the data](https://blogs.oracle.com/datawarehousing/post/loading-xml-data-from-your-object-store-into-autonomous-database)

    ```
    BEGIN
        DBMS_CLOUD.CREATE_EXTERNAL_TABLE (
            table_name =>'STAGING_TABLE',  credential_name =>null,  
            format => json_object('delimiter' value '%$#^@%$', 'recorddelimiter' value '0x''02'''),
            file_uri_list =>'https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/labfiles/livelab-xmldoc-2.xml',
            column_list => 'xml_document clob',
            field_list => 'xml_document CHAR(1000000)'
        );
    END;
    /

    INSERT INTO PURCHASEORDER SELECT 2, XMLTYPE(xml_document) FROM staging_table;
    ```

    ![External table](./images/img-6.png)

    If your XML documents are smaller, you can even use the ‘insert into’ statements to insert the docs into your table.

    ```
    <copy>
    INSERT INTO PURCHASEORDER VALUES (
        3,
        '<PurchaseOrder>
            <Reference>MAllen-2024PST</Reference>
            <Actions>
                <Action>
                    <User>BLAKE</User>
                </Action>
            </Actions>
            <Requestor>Michael Allen</Requestor>
            <User>MALLEN</User>
            <CostCenter>T10</CostCenter>
            <ShippingInstructions>
                <name>Michael Allen</name>
                <Address>
                    <street>300 Oracle Parkway</street>
                    <city>Redwood Shores</city>
                    <state>CA</state>
                    <zipCode>94065</zipCode>
                    <country>USA</country>
                </Address>
                <telephone>650-506-7300</telephone>
            </ShippingInstructions>
            <SpecialInstructions>Overnight</SpecialInstructions>
            <LineItems> 
                <LineItem ItemNumber="10"> 
                    <Description>Java complete reference</Description>
                    <Part Id="2748329425" UnitPrice="10"/>
                    <Quantity>5</Quantity>
                </LineItem> 
                <LineItem ItemNumber="20"> 
                    <Description>Julius Caesar</Description>
                    <Part Id="86471878626" UnitPrice="36.5"/>
                    <Quantity>10</Quantity>
                </LineItem> 
                <LineItem ItemNumber="30"> 
                    <Description>anthology of short stories</Description>
                    <Part Id="86471878637" UnitPrice="49"/>
                    <Quantity>5</Quantity>
                </LineItem> 
            </LineItems>
        </PurchaseOrder>'
    );
    </copy>
    ```

    ![External table](./images/img-7.png)

    You can choose any of the above approaches to insert the XML documents into the table. 

    Let's insert two more documents - this time NULL document.

    ```
    <copy>
    INSERT INTO purchaseorder
    VALUES      (4, NULL);

    INSERT INTO purchaseorder
    VALUES      (5, NULL);

    COMMIT;  
    </copy>
    ```

    ```
    <copy>
    -- Check if all docs are inserted correctly
    SELECT
        COUNT(*)
    FROM
        PURCHASEORDER;
    </copy>
    ```

    Now the table PURCHASEORDER table should have 5 rows.

    ![Number of rows](./images/img-4.png)

4.	Check that we have rows in the table

    Copy the following simple SELECT into the worksheet area and press "Run Statement".

    ```
    <copy>
    SELECT
        t.id,
        t.doc.getclobval()
    FROM
        PURCHASEORDER t
    ORDER BY t.id;
    </copy>
    ```

    You should see the rows you inserted. You can expand the view to see the whole text 
    column by adjusting the column header. 

    ![Inserted documents](./images/img-5.png)

    If there are no rows shown, return to Step 3.

You may now **proceed to the next lab**.

## Learn More

- [Manage and Monitor Autonomous Database](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=553)
- [Scale and Performance in the Autonomous Database](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=608)
- [Oracle XML DB](https://www.oracle.com/database/technologies/appdev/xmldb.html)
- [Oracle Autonomous Database](https://www.oracle.com/database/autonomous-database.html)
- [XML DB Developer Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/adxdb/index.html)


## Acknowledgements
* **Author** - Harichandan Roy, Principal Member of Technical Staff, Oracle Document DB
* **Contributors** -  XDB Team
* **Last Updated By/Date** - Harichandan Roy, February 2023
