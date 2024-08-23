# Explore the Power of Oracle AI Vector Search

## Introduction
In this lab, you will quickly configure the Oracle Autonomous Database Free 23ai Docker Container in your remote desktop environment.

**_Estimated Time: 20 minutes_**

### **Objectives**

In this lab, you will:

* Configure a clothing retail schema.
* Compare the performance of traditional search vs. vector search.

### **Prerequisites**
This lab assumes you have:
- An Oracle account


## Task 1: Configure the Clothing Retail Schema

**_Note:_** _All of the following commands are to be run in the terminal._

1.  **Connect to the database.**
    ```
    <copy>
    podman exec -it oracle_adb-free_1 sqlplus admin/Welcome_12345@myatp_low
    </copy>
    ```

2. **Install the sample schema.** You'll be installing Oracle's "Customer Orders" sample schema, which stores the data, objects, and relations necessary for a typical retail store. This schema mas been modified to include English product descriptions for us to vectorize later.

    ```
    <copy>
    start /u01/customer-orders/co_install.sql;
    </copy>
    ```
3. **Fill in the installation prompts.** <br/><br/> 
    &nbsp;&nbsp;&nbsp;&nbsp; **Password for the user CO:** D3fP&$$_12345 <br/>
    &nbsp;&nbsp;&nbsp;&nbsp; **Enter a tablespace for CO:** Press enter. <br/>
    &nbsp;&nbsp;&nbsp;&nbsp; **Do you want to overwrite the schema, if it already exists?:** YES

The following output means the schema has successfully installed. You may now proceed to the next lab.

## Task 2: Perform a Traditional Search for Professional Attire 
As a retailer, you want customers to easily search your catalog for the clothing items they want. Let's see how that would typically work.

1. **Return to SQL Developer Web.** Open Google Chrome (Activities >> Chrome Icon) to return to SQL Developer Web. 
    [insert gif]
    
2. **Review the products table.** 
    ```
    <copy>
    select * from co.products;
    </copy>
    ```

3. . **Traditionally search your catalog for the word "professional".** 
    ```
    <copy>
    select * from co.products where lower(JSON_VALUE(product_details, '$.description')) like '%professional%' or lower(product_name) like '%professional%';
    </copy>
    ```
4. . **Traditionally search your catalog for the word "slacks".**
    ```
    <copy>
    select * from co.products where lower(JSON_VALUE(product_details, '$.description')) like '%slacks%' or lower(product_name) like '%slacks%';
    </copy>
    ```

**Notice that both queries returned zero results!**

This doesn't mean that our catalog has nothing we could wear to a conference or in a professional setting. Our results are simply limited by traditional search methods. Only searching for a specific word means that we might overlook similar results because they aren't an exact match. Even when we find that exact match, it's still not a guarantee that it'll align with what you meant. 

This because we're only looking at the literal value of of our search query and not considering the actual meaning of it. Vector search allows us to query our data based on its actual meaning. In the next lab, we'll embed these terms and perform vector search on them instead.

## Acknowledgements
- **Authors** - Brianna Ambler, Database Product Management, August 2024
- **Contributors** -Brianna Ambler, August 2024
- **Last Updated By/Date** - Brianna Ambler, August 2024
