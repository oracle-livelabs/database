# Run queries

## Introduction

This lab will use the SQL Workshop in Database Actions from the Autonomous Transaction Processing page. Here we will explore XQuery to query XML content stored in Oracle XML DB. It is one of the main ways that you interact with XML data in Oracle XML DB. It is the W3C language designed for querying and updating XML data.

The support for the XQuery Language is provided through a native implementation of SQL/XML functions: XMLQuery, XMLTable, XMLExists, and XMLCast. These SQL/XML functions are defined by the SQL/XML standard as a general interface between the SQL and XQuery languages.

Estimated Time: 60 minutes

### Objectives

In this lab, you will learn:
-	Querying XML documents or fragments,
-	Extracting XML nodes/scalar values,
-	Constructing new XML documents from stored documents,
-	Generating relational data from XML documents,
-	Serializing XML data,
-	Joining XML data with relational data.

### Prerequisites

- Be logged into your Oracle Cloud Account.

## Task 1: Queries

1. Get the number of not-null XML documents
    
    Let's first see how many not-null XML documents we have. The 'where' clause in the following statement filters the not-null documents.
    
    Copy the following simple SELECT into the worksheet area and press "Run Statement".

    ```
    <copy>
    SELECT
        COUNT(*)
    FROM
        PURCHASEORDER
    WHERE
        DOC IS NOT NULL;
    </copy>
    ``` 

    ![Number of not-null documents](./images/img-1.png)

2. Search for the specific XML documents

    XMLExists SQL/XML function can be used in the where clause to filter rows based on an XQuery expression. It evaluates whether or not a given document contains a node that matches an XQuery expression.

    This query will return the XML documents which satisfy the XPath /PurchaseOrder/Reference.

    ```
    <copy>
    SELECT
        P.DOC.GETCLOBVAL() XMLDOC
    FROM
        PURCHASEORDER P
    WHERE
        XMLEXISTS ('/PurchaseOrder/Reference'
            PASSING P.DOC
        );
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement". All non-null documents are returned since all of them have the same XPath node.

    ![Documents satisfying the XPath](./images/img-2.png)
    
    The next query is even more specific, and it will return the XML documents where XPath /PurchaseOrder/Reference has 'ROY-1PDT' as the value.

    ```
    <copy>
    SELECT
        P.DOC.GETCLOBVAL() XMLDOC
    FROM
        PURCHASEORDER P
    WHERE
        XMLEXISTS ('$p/PurchaseOrder[Reference="CJONES-2022PST"]'
            PASSING P.DOC AS "p"
        );
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement". You'll see that we only have one document with a purchase order reference to 'ROY-1PDT'.

    ![Documents satisfying the XPath and predicate](./images/img-3.png)


    ```
    <copy>
    -- You can also use a bind variable to pass a value. Bind variables should always be used when a query will be executed with different predicates.
    SELECT
        P.DOC.GETCLOBVAL() XMLDOC
    FROM
        PURCHASEORDER P
    WHERE
        XMLEXISTS ( '$p/PurchaseOrder[Reference=$REF]'
            PASSING P.DOC AS "p",
            'CJONES-2022PST' AS "REF"
        );
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".
    
    ![Documents satisfying the XPath and a bind predicate](./images/img-4.png)


3. Access fragments or nodes of the XML documents

    Now if we are not interested in all the information in the XML documents, but are interested in only seeing the shipping instruction information , we will use XMLQuery function which takes an XQuery expression and returns the fragments or nodes we are looking for.

    The 'where' clause of this query will filter the documents that we are looking for and the XMLQuery will extract the fragments/nodes from those filtered XML documents. 

    ```
    <copy>
    SELECT
        XMLQUERY('/PurchaseOrder/ShippingInstructions'
            PASSING P.DOC
        RETURNING CONTENT).GETCLOBVAL() XMLNODE
    FROM
        PURCHASEORDER P
    WHERE
        XMLEXISTS ( '$p/PurchaseOrder[Reference="MAllen-2024PST"]'
            PASSING P.DOC AS "p"
        );
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".
    
    ![Fragments satisfying the XPath and predicate](./images/img-5.png)


4. Extract the scalar value from XML fragments or nodes

    If we want to extract the scalar value of the fragments or nodes from the xml documents, we can use XMLCast to map the XQuery result to a SQL data type.

    This query will return the scalar value of the 'name' node in 'ShippingInstructions' of the documents having 'ROY-1PDT' as the Reference value.

    ```
    <copy>
    SELECT
        XMLCAST(XMLQUERY('/PurchaseOrder/ShippingInstructions/name'
            PASSING P.DOC
        RETURNING CONTENT) AS VARCHAR2(50)) XMLNODE
    FROM
        PURCHASEORDER P
    WHERE
        XMLEXISTS ('$p/PurchaseOrder[Reference="SBELL-2023PDT"]'
            PASSING P.DOC AS "p"
        );
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".
    
    ![Value of the fragments satisfying the XPath and predicate](./images/img-6.png)

5. Generate relational data from XML data

    XMLTable function decomposes the result of a XQuery evaluation into the relational rows and columns of a new virtual table. We can insert this data into a relational table, or we can query it using SQL depending on the use cases.

    In Q3, we get the ShippingInstructions as an XML fragment. The following statement will give us the same fragment as a relational table.

    ```
    <copy>
    SELECT
        SI.*
    FROM
        PURCHASEORDER P,
        XMLTABLE ('/PurchaseOrder/ShippingInstructions'
                PASSING P.DOC
            COLUMNS
                NAME VARCHAR2(15) PATH 'name',
                STREET VARCHAR2(30) PATH 'Address/street',
                CITY VARCHAR2(15) PATH 'Address/city',
                STATE VARCHAR2(10) PATH 'Address/state',
                ZIPCODE VARCHAR2(10) PATH 'Address/zipCode',
                COUNTRY VARCHAR2(30) PATH 'Address/country',
                TELEPHONE VARCHAR2(15) PATH 'telephone'
        ) SI
    WHERE
        XMLEXISTS ('$p/PurchaseOrder[Reference="SBELL-2023PDT"]'
            PASSING P.DOC AS "p"
        );
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".
    
    ![XML data to relational data](./images/img-8.png)

    Furthermore, we can chain the XMLTable calls when we want to see data contained in multiple levels. For example, in the following example, the element PurchaseOrder is first decomposed to a relational view of two columns, reference as varchar2 and lineitem as XMLType. The lineitem column is then passed to a second XMLTable call to be broken into its various parts as multiple columns of relational values.

    ```
    <copy>
    SELECT
        PO.REFERENCE,
        LI.*
    FROM
        PURCHASEORDER P,
        XMLTABLE ('/PurchaseOrder'
                PASSING P.DOC
            COLUMNS
                REFERENCE VARCHAR2(30) PATH 'Reference',
                LINEITEM XMLTYPE PATH 'LineItems/LineItem'
        )             PO,
        XMLTABLE ('/LineItem'
                PASSING PO.LINEITEM
            COLUMNS
                ITEMNO NUMBER(3) PATH '@ItemNumber',
                PARTNO NUMBER(12) PATH 'Part/@Id',
                DESCRIPTION VARCHAR2(25) PATH 'Description',
                UNITPRICE NUMBER(8, 4) PATH 'Part/@UnitPrice',
                QUANTITY NUMBER(12, 2) PATH 'Quantity'
        )             LI
    WHERE
        XMLEXISTS ('$p/PurchaseOrder[Reference="CJONES-2022PST"]'
            PASSING P.DOC AS "p"
        );
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".
    
    ![XMLTABLE chain](./images/img-9.png)

6. Join relational tables with XML tables/columns

    In Q5, we saw how XMLTable function creates an in-line relational view of XML content. The result can be used to join with other relational tables in the database.

    Let's first create a simple relational table, EMP, and then insert a few rows.

    ```
    <copy>
    CREATE TABLE EMP (
        ID   NUMBER,
        NAME VARCHAR(20),
        HIREDATE DATE
    );

    insert into emp values(101, 'Sarah J. Bell', date '2001-06-01');
    insert into emp values(102, 'Cindy Jones', date '2019 01-20');
    insert into emp values(103, 'Michael Allen', date '2005-09-01');

    COMMIT;
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".

    ![EMP relational table](./images/img-12.png)
    

    ```
    <copy>
    SELECT
        *
    FROM
        EMP;
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".

    ![EMP table entries](./images/img-13.png)

    ```
    <copy>
    SELECT
        E.ID,
        T.*
    FROM
        EMP           E,
        PURCHASEORDER P,
        XMLTABLE ('/PurchaseOrder' PASSING P.DOC
            COLUMNS
                REQUESTOR PATH 'Requestor/text()',
                INSTRUCTIONS PATH 'SpecialInstructions/text()'
        ) T
    WHERE
        E.NAME = T.REQUESTOR
        AND ROWNUM <= 5;
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".
    
    ![Joining XMLTABLE and EMP, a relational table](./images/img-14.png)

7. Construct a new response document

    Let's assume we have some purchase order XML documents containing detailed purchase information. We want to generate a new and smaller XML document containing only the required information as a response to an application request. The following query just does that:

    ```
    <copy>
    SELECT
        XMLQUERY('<Response>{
                $XML/PurchaseOrder/Reference,
                $XML/PurchaseOrder/User,
                $XML/PurchaseOrder/SpecialInstructions
            }
            </Response>'
            PASSING P.DOC AS "XML"
        RETURNING CONTENT).GETCLOBVAL() INITIAL_STATE
    FROM
        PURCHASEORDER P
    WHERE
        P.DOC IS NOT NULL;
    </copy>
    ``` 

    Copy the above statement into the worksheet area and press "Run Statement".
    
    ![Customized XML fragment](./images/img-15.png)

8. Serialize XML data 

    Now consider you have an application or product that does not support XMLType data. In that case, you can serialize the XML data as CLOB or BLOB and view or process it in your application or product. Oracle XML DB provides an XMLSerialize function to achieve this goal. XMLSerialize also allows control over the layout of the serialized XML:

    ```
    SELECT XMLSERIALIZE(DOCUMENT doc as CLOB)  XMLCONTENT
    FROM purchaseorder p
    WHERE XMLEXISTS ('$p/PurchaseOrder[Reference="MAllen-2024PST"]'
            PASSING P.DOC AS "p"
        );
    ```

    ![Customized XML fragment](./images/img-19.png)![Alt text](image.png)

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
