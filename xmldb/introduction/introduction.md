# Introduction

## About This Workshop

In this workshop, we will discuss some of the basic capabilities of Oracle XML DB. After the workshop, the users will be able to understand how to store XML data in Oracle DB and how to access and manipulate them.

Estimated Workshop Time: 3 hours, 30 minutes

## What Is XML?

XML is a human-readable, machine-readable, and self-describing format to represent data in a hierarchical format. Here is an example of an XML document containing information on a purchase order. 

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

## Why Do We Need To Manage XML Documents?

XML is one of the popular ways to persist and exchange business-critical information. XML is an open standard, managed by the W3C, and under the control of no single vendor. Many industry segments have developed XML-based standards for representing information. These standards are typically based on XML Schema, a W3C-developed standard for defining the expected contents of a given XML File. XML-based standards can be found in healthcare, financial services, manufacturing, publishing, law enforcement, and the public sector. XML also provides the foundation for SOAP-based application development. In a growing number of situations, government regulation mandates the use of such standards when exchanging information. These trends have led to massive increases in the volume of XML that an organization needs to deal with and forced organizations to adopt XML platforms that manage XML with a similar degree of rigor and security to operational data.

## What Does Oracle XML DB Offer?

To meet this need, Oracle developed Oracle XML DB. Oracle XML DB is a high-performance, native XML storage, and retrieval technology that is delivered as a part of Oracle Database. Oracle XML DB allows an organization to manage XML content in the same way that it manages traditional relational data. This allows organizations to save costs and improve return on investment by using a single platform to manage and secure all their mission-critical data. Oracle XML DB was first released with Oracle 9iR2, and it has been enhanced in each subsequent major release of the database.


## Objectives

In this workshop, we intend to cover the following topics:
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

- [Manage and Monitor Autonomous Database](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=553)
- [Scale and Performance in the Autonomous Database](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=608)
- [Oracle XML DB](https://www.oracle.com/database/technologies/appdev/xmldb.html)
- [Oracle Autonomous Database](https://www.oracle.com/database/autonomous-database.html)
- [XML DB Developer Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/adxdb/index.html)


## Acknowledgements
* **Author** - Harichandan Roy, Principal Member of Technical Staff, Oracle Document DB
* **Contributors** -  XDB Team
* **Last Updated By/Date** - Harichandan Roy, February 2023
