# Index your XML documents

## Introduction
Indexing XML data will give you quick access to the data and significantly improve the query performance. The use of indexes is particularly recommended for online transaction processing (OLTP) environments involving few updates.

Generally, when your XML data contains structured, predictable fragments of data and your queries are known, we recommend using XMLIndex with a structured component. When you need to support ad-hoc XML queries, range, or text search queries, we recommend using the XML Search index. In this lab, we will explore both XMLIndex and XML Search Index.

Estimated Time: 20 minutes

### Objectives
In this lab, you will learn:
-	How to use Structured XMLIndex,
-	How to use XML Search Index.

### Prerequisites
- Be logged into your Oracle Cloud Account and have access to the SQL Worksheet in Database Actions.


## Task 1: Create and use structured XMLIndexes
  
Often times users know the structure or pattern of the queries and consequently the fragments of their XML documents that are used for selective access. For example, consider the following few examples: 

```
<copy>
SELECT
    XMLQUERY('/PurchaseOrder/LineItems/LineItem/@ItemNumber'
        PASSING P.DOC
    RETURNING CONTENT).GETCLOBVAL() as ItemNumber
FROM
    PURCHASEORDER P
WHERE
    XMLEXISTS ('/PurchaseOrder[Reference="CJONES-2022PST"]'
        PASSING P.DOC
    );
</copy>
```

```
<copy>
CREATE OR REPLACE VIEW V_ORDERITEM AS 
    SELECT M.REFERENCE, L.*
    FROM PURCHASEORDER P,
        XMLTABLE ('/PurchaseOrder' PASSING P.DOC
            COLUMNS
                REFERENCE VARCHAR2(30) PATH 'Reference/text()',
                LINEITEMS XMLTYPE PATH 'LineItems/LineItem') M,
        XMLTABLE ('/LineItem' PASSING M.LINEITEMS
            COLUMNS
                ITEMNO NUMBER(38) PATH '@ItemNumber',
            PARTNO VARCHAR2(14) PATH 'Part/@Id',
                DESCRIPTION VARCHAR2(100) PATH 'Description',
                QUANTITY NUMBER(5) PATH 'Quantity') L;
</copy>
```

The queries use a similar XPath to access /PurchaserOrder/Reference or /PurchaseOrder/LineItems/LineItem elements. We can create a structured XML index on these structured parts of the data. An XML index will also help the query performance significantly.

Let us create a structured XML index for our sample table:
```
<copy>
DROP INDEX PURCHASEORDER_IDX;

CREATE INDEX PURCHASEORDER_IDX
    ON purchaseorder(doc) INDEXTYPE IS XDB.XMLIndex
    PARAMETERS ('
        XMLTABLE PO_INDEX_MASTER
                ''/PurchaseOrder''
        COLUMNS
            reference VARCHAR2(30) PATH ''Reference/text()'',
            lineitem  XMLTYPE PATH ''LineItems/LineItem'' VIRTUAL
        XMLTable PO_INDEX_LINEITEM
                ''/LineItem'' PASSING lineitem
        COLUMNS
            ITEMNO number(38)   PATH ''@ItemNumber'',
            PARTNO varchar2(14)  PATH ''Part/@Id'',
            DESCRIPTION varchar2(30) PATH ''Description'',
            QUANTITY NUMBER(5) PATH ''Quantity''
    ');
</copy>
```
![Create index](./images/img-3.png)

After you created the index, you will see an index PURCHASEORDER_IDX in your data dictionary, but you will also see two additional (structured) tables being created; those are so-called "path tables" that provide the structure for your XML index. You can describe them, however.

The two internal XML index path tables PO\_INDEX\_MASTER and PO\_INDEX\_LINEITEM are named after the XMLTABLE parameters of your index creation statement. 
- PO\_INDEX\_MASTER has columns reference and lineitem. Column lineitem is of type XMLTYPE which is virtual. It represents a collection and is passed to the second XMLTable construct to form the second-level relational index table, PO\_INDEX\_LINEITEM.
- PO\_INDEX\_LiNEITEM has columns itemno, partno, description, and quantity. 

Your queries are optimized through Structured XML Index directly from the underneath relational index tables. We will see this later in this lab.

You can even create secondary indexes on the columns of these internal XML index tables, which will further improve the query performance. Let's do this now:
```
<copy>
CREATE UNIQUE INDEX REFERENCE_IDX ON
    PO_INDEX_MASTER (
        REFERENCE
    );

-- creating a secondary index on the UPC column
CREATE INDEX UPC_IDX ON
    PO_INDEX_LINEITEM (
        PARTNO
    );
</copy>
```

Copy the above statement into the worksheet area and press "Run Statement".

![Secondary indexes](./images/img-4.png)

Now let's see our indexes at work, using some sample queries.

```
<copy>
SELECT
    XMLQUERY('/PurchaseOrder/LineItems/LineItem/@ItemNumber'
        PASSING P.DOC
    RETURNING CONTENT).GETCLOBVAL()
FROM
    PURCHASEORDER P
WHERE
    XMLEXISTS ( '/PurchaseOrder[Reference="CJONES-2022PST"]'
        PASSING P.DOC
    );
</copy>
```

Copy the above statement into the worksheet area and press "Explain Plan".

![Explain plan 1](./images/img-5.png)

You will see that the access path is driven by our secondary index on /PurchaseOrder/Reference (index REFERENCE\_IDX on our path table PO\_INDEX\_MASTER) since we have a very selective predicate "REFERENCE"='CJONES-2022PST'.

Now let's create a view and see what happens when I am just selecting from my view:
```
<copy>
CREATE OR REPLACE VIEW V_ORDERITEM AS  
    SELECT M.REFERENCE, L.*
    FROM PURCHASEORDER P,
        XMLTABLE ('/PurchaseOrder' PASSING P.DOC
            COLUMNS
                REFERENCE VARCHAR2(30) PATH 'Reference/text()',
                LINEITEMS XMLTYPE PATH 'LineItems/LineItem') M,
        XMLTABLE ('/LineItem' PASSING M.LINEITEMS
            COLUMNS
                ITEMNO NUMBER(38) PATH '@ItemNumber',
                PARTNO VARCHAR2(14) PATH 'Part/@Id',
                DESCRIPTION VARCHAR2(30) PATH 'Description',
                QUANTITY NUMBER(5) PATH 'Quantity') L;

SELECT * FROM V_ORDERITEM;
</copy>
```

Copy the above statement into the worksheet area and press "Explain Plan". You see how the structures built for our structured XML index work together to optimize the master-detail access of our XML documents.

![Explain plan 2](./images/img-6.png)

## Task 2: Create and use XML Search Indexes
    
In case of ad-hoc or free-form XML queries, that don’t follow a well-defined structure as appropriate for the Structured XMLIndex discussed in the previous section, we recommend creating an XML Search Index instead. The search index can be used to get a performance boost on both full-text as well as range search queries.

1. The first step is to create a section group and set the search preferences:
        ```
        <copy>
        BEGIN
            CTX_DDL.DROP_PREFERENCE('STORAGE_PREFS');
        END;
        /

        BEGIN
            CTX_DDL.DROP_SECTION_GROUP('XQFT');
        END;
        /

        BEGIN
            CTX_DDL.CREATE_SECTION_GROUP('XQFT', 'PATH_SECTION_GROUP');
            CTX_DDL.SET_SEC_GRP_ATTR('XQFT', 'XML_ENABLE', 'T');
            CTX_DDL.CREATE_PREFERENCE('STORAGE_PREFS', 'BASIC_STORAGE');
        END;
        /
        </copy>
        ```

    Copy the above statement into the worksheet area and press "Run Statement". You can ignore the errors from the first two drop operations if you run this lab for the first time. The lab is built in a way that you can re-run individual sections.

    ![Set preferences](./images/img-7.png)

2. The second step is to actually create the search index on the base table using the preferences created in the previous step: 
        ```
        <copy>
        CREATE INDEX PURCHASEORDER_XQFT_IDX ON
            PURCHASEORDER (
                DOC
            )
        INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ( 'storage STORAGE_PREFS 
                    section group XQFT' );
        </copy>
        ```

    Copy the above statement into the worksheet area and press "Run Statement".

    ![Create XML search index](./images/img-8.png)

Now that the search index has been set up, try running a variety of different queries and verify if the index is picked for each one of them by clicking on explain plan.

Let’s look at a few text-search queries:

1. Find all “Overnight” orders
    ```
    <copy>
    SELECT
        id
    FROM
        PURCHASEORDER
    WHERE
        XMLEXISTS ('/PurchaseOrder/SpecialInstructions[. contains text "Overnight"]'
            PASSING doc);
    </copy>
    ```

    Copy the above statement into the worksheet area and press "Explain Plan".

    ![Explain plan SIQ1](./images/img-9.png)

2. Orders where the description contains “Harry” and “Potter”
    ```
    <copy>
    SELECT
        id
    FROM
        PURCHASEORDER 
    WHERE
        XMLEXISTS ( '/PurchaseOrder/LineItems/LineItem/Description[. contains text "Harry" ftand "Potter"]'
            PASSING doc
        );
    </copy>
    ```

    Copy the above statement into the worksheet area and press "Explain Plan".

    ![Explain plan SIQ2](./images/img-10.png)

3. Orders where the description contains the words “C++” or “Java”

    ```
    <copy>
    SELECT
        id
    FROM
        PURCHASEORDER
    WHERE
        XMLEXISTS ( '/PurchaseOrder/LineItems/LineItem/Description[. contains text "Java" ftor "C++"]'
            PASSING doc
        );
    </copy>
    ```

    Copy the above statement into the worksheet area and press "Explain Plan".

    ![Explain plan SIQ3](./images/img-11.png)
    

4. Orders with price > 50
    ```
    <copy>
    SELECT
        id
    FROM
        PURCHASEORDER
    WHERE
        XMLEXISTS ( '(# ora:use_xmltext_idx #) 
            {/PurchaseOrder/LineItems/LineItem/Part[@UnitPrice > 50]}' 
            PASSING doc
        );
    </copy>
    ```

    Copy the above statement into the worksheet area and press "Explain Plan".

    ![Explain plan SIQ4](./images/img-12.png)
    

5. Orders where the Requestor name is lexicographically > “Jake”

    ```
    <copy>
    SELECT
        id
    FROM
        PURCHASEORDER
    WHERE
        XMLEXISTS ( '(# ora:use_xmltext_idx #) 
            {/PurchaseOrder[Requestor > "Jake"]}'
            PASSING doc
        );
    </copy>
    ```

    Copy the above statement into the worksheet area and press "Explain Plan".

    ![Explain plan SIQ5 with stemming](./images/img-13.png)
 
You have now experienced both structured XML indexes and search XML indexes in action to optimize various predicates and search condition. Feel free to experience more with other variants of queries if you like. 

You may now **proceed to the next lab**.

## Acknowledgements
* **Author** - Harichandan Roy, Principal Member of Technical Staff, Oracle Document DB
* **Contributors** -  XDB Team
- **Last Updated By/Date** - Ernesto Alvarez, April 2024
