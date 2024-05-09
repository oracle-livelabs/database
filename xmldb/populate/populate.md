# Create your first XML table and insert some XML documents

## Introduction
You will use the SQL Worksheet in Database Actions from your Autonomous Database. We will create a sample table with an XMLType column and populate the table with some XML documents.

Estimated Time: 15 minutes

### Objectives
In this lab, you will learn:
1.	How to create and populate a table with an XMLType column

### Prerequisites
- Access to an Oracle Autonomous Database, Database Actions web interface.

## Task 1: Open Database Actions
1.	Log in to the Oracle Cloud.
6.	Navigate to your previously created Autonomous Database "XMLDB" (or the name you have chosen).
7.	On the database detail page, choose Database Actions. You can navigate to the Database Actions overview page or go directly to the SQL Worksheet

![Database Actions](./images/database_actions.png)

## Task 2: Create and Populate a Table with an XMLType Column
1.	Enter the SQL Worksheet

    When you first enter SQL, you will get a tour of the features. We recommend you step through it, but you can skip the tour by clicking on the "X" The tour is available at any time by clicking the tour button. You can dismiss the warning that you are logged in as an ADMIN user.

2.	Create a table with XMLType column

    We will create a simple table to record the sample purchase orders. It contains a numeric column for purchase ID and an XMLType column for our purchase details.

    Copy the following into the 'Worksheet' area and press the "Run Statement" button:

    ```
    <copy>
    -- By default, the storage type is Binary XML
    CREATE TABLE purchaseorder
    (
        id  NUMBER PRIMARY KEY,
        doc XMLTYPE
    );
    </copy>
    ```

    You should see the message "Table PURCHASEORDER created". 

    ![Create table](./images/img-1.png)

    On the left side, click the "Refresh" button to see your new table in the tables list.

    ![Table list](./images/img-2.png)

    You can check the storage type 'BINARY' of your XMLtype column in the data dictionary
    ```
    <copy>
    SELECT column_name, storage_type 
        FROM user_xml_tab_cols 
        WHERE table_name ='PURCHASEORDER'
    </copy>
    ```


3.	Populate the table with a few rows

    Use the 'trashcan' icon to delete the previous statement from the Worksheet area. Copy the following SQL into the worksheet area. Make sure you highlight the whole statement with your mouse and press the "Run Statement" button:

    Here we are using XML files stored in the Object store. The files are created with pre-authentication, so you do not need to provide a credential for authentication and authorization.

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
    <copy>
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
    </copy>
    ```

    ![External table](./images/img-6.png)

    If your XML documents are smaller, you can even use the INSERT INTO’ statements to insert the XML documents into your table.

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

    Now the table PURCHASEORDER table should have 5 rows.
 
    ```
    <copy>
    -- Check if all docs are inserted correctly
    SELECT
        COUNT(*)
    FROM
        PURCHASEORDER;
    </copy>
    ```

    

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

* [Get started with Oracle Autonomous Database Serverless ](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/videos.html)
- [XML DB Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/adxdb/index.html)
- [Oracle XML DB](https://www.oracle.com/database/technologies/appdev/xmldb.html)


## Acknowledgements
* **Author** - Harichandan Roy, Principal Member of Technical Staff, Oracle Document DB
* **Contributors** -  XDB Team
- **Last Updated By/Date** - Ernesto Alvarez, April 2024
