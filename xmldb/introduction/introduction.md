# Introduction

## About This Workshop

In this workshop, you will get to know the basic XML capabilities of Oracle's Converged Database. After the workshop, you will understand how to store XML data and how to access and manipulate it.

Estimated Workshop Time: 1 hours, 30 minutes

## What Is XML?

XML is a human-readable, machine-readable, and self-describing format to represent data in a hierarchical format. The following is an example of an XML document containing information about a purchase order. 

```
<copy>
<PurchaseOrder>
    <Reference>CJONES-2022PST</Reference>
    <Actions>
        <Action>
            <User>DJOHN</User>
        </Action>
    </Actions>
    <Requestor>Cindy Jones</Requestor>
    <User>CJONES</User>
    <CostCenter>D30</CostCenter>
    <ShippingInstructions>
        <name>Cindy Jones</name>
        <Address>
            <street>200 Oracle Parkway</street>
            <city>Redwood Shores</city>
            <state>CA</state>
            <zipCode>94065</zipCode>
            <country>USA</country>
        </Address>
        <telephone>650-506-7400</telephone>
    </ShippingInstructions>
    <SpecialInstructions>Overnight</SpecialInstructions>
     <LineItems> 
         <LineItem ItemNumber="10"> 
             <Description>Harry Potter and the Goblet of Fire</Description>
             <Part Id="2748329235" UnitPrice="48.5"/> 
             <Quantity>2</Quantity>
         </LineItem> 
         <LineItem ItemNumber="15"> 
             <Description>Lord of the Rings</Description>
             <Part Id="86471875562" UnitPrice="54"/>
             <Quantity>1</Quantity>
         </LineItem> 
         <LineItem ItemNumber="115"> 
             <Description>Harry Potter and the Prisoner of Azkaban</Description>
             <Part Id="27895674912" UnitPrice="50.95"/> 
             <Quantity>5</Quantity>
        </LineItem> 
    </LineItems>
</PurchaseOrder>
</copy>
```

## Why Do You Need To Manage XML Documents?

XML is one of the popular ways to persist and exchange business-critical information. XML is an open standard, managed by the W3C, and under the control of no single vendor. Various industries have established XML-based standards, often leveraging XML Schema to define data structures. These standards are pervasive across sectors such as healthcare, finance, manufacturing, publishing, law enforcement, and government. These standards are typically based on XML Schema, a W3C-developed standard for defining the expected contents of a given XML File. XML also provides the foundation for SOAP-based application development. With governmental regulations increasingly mandating adherence to such standards, organizations are experiencing a surge in XML volume, necessitating the adoption of robust XML platforms that ensure data integrity and security comparable to operational data systems.

## XML with the Oracle Database

To address these requirements, Oracle implemented XML capabilities natively in the database, commonly known as Oracle XML DB. Oracle XML DB is a high-performance, native XML storage, and retrieval technology that is integral part of Oracle's Converged Database. Oracle XML DB allows an organization to manage XML content in the same way that it manages traditional relational data. This allows organizations to save costs and improve return on investment by using a single platform to manage and secure all their mission-critical data. Oracle XML DB was first introduced with Oracle Database 9i Release 2, and it has been enhanced in each subsequent release of the database since then.


## Objectives

In this workshop, you will learn about the following topics:
-	How to provision an Oracle Autonomous Database
-	Fundamentals of XML, XQuery, SQL/XML
-	How to store, query, process, and update XML data
-	How to transform relational data to XML data
-	How to transform XML data to relational data
-	How to index XML data

### Prerequisites

-	An Oracle Cloud Account

You may now **proceed to the next lab**.

## Learn More

- [O.com: Oracle XML DB](https://www.oracle.com/database/technologies/appdev/xmldb.html)
- [O.com: Oracle Autonomous Database](https://www.oracle.com/database/autonomous-database.html)
- [Documentation: XML DB Developer Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/adxdb/index.html)


## Acknowledgements
* **Author** - Harichandan Roy, Principal Member of Technical Staff, Oracle Document DB
* **Contributors** -  XML Development, Oracle
* **Last Updated By/Date** - Ernesto Alvarez, April 2024
