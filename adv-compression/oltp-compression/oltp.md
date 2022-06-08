# Enable OLTP table compression

## Introduction

Oracle has been a pioneer in database compression technology. Oracle Database 9i introduced Basic Table Compression several years ago that compressed data loaded using bulk load operations. Oracle Database 11g Release 1 introduced a new OLTP Table Compression feature that allows data to be compressed during all types of data manipulation operations, including conventional DML such as INSERT and UPDATE. In addition, 
OLTP Table Compression reduces the associated compression overhead of write operations making it suitable for transactional or OLTP environments as well. OLTP Table Compression, therefore, extends the benefits of compression to all application workloads. OLTP Table Compression was renamed to Advanced Row Compression starting with Oracle Database release 12c.

Estimated Time: 20 minutes

### About OLTP table compression

Oracle's OLTP Table Compression uses a unique compression algorithm specifically designed to work with OLTP applications. The algorithm eliminates duplicate values within a database block, even across multiple columns. Compressed blocks contain a structure called a symbol table that maintains compression metadata. When a block is compressed, duplicate values are eliminated by first adding a single copy of the duplicate value to the symbol table. Each duplicate value is then replaced by a short reference to the appropriate entry in the symbol table. 

### SecureFiles LOB compression

SecureFiles LOB Compression utilizes industry-standard compression algorithms to minimize the storage requirements of SecureFiles data. With SecureFiles LOB Compression, typical files such as documents or XML files experience a reduction of 2x to 3x times in size. There are three levels of SecureFiles LOB Compression:  LOW, MEDIUM, and HIGH. By default, SecureFiles LOB Compression uses the MEDIUM level, which typically provides good compression with a modest CPU overhead. In addition to SecureFiles LOB Compression, SecureFiles LOB Deduplication, a feature of Advanced Compression, eliminates duplicate copies of SecureFiles LOBs. SecureFiles LOB Compression was renamed Advanced LOB Compression, and SecureFiles LOB Deduplication was renamed Advanced LOB Deduplication in Oracle Database release 12c. Compression advisor typically provides fairly accurate estimates, of the actual compression results that may be obtained, after implementing compression.
 
### Benefits of OLTP table compression 

The compression ratio achieved in a given environment depends on the nature of the data being compressed, specifically the cardinality of the data. In general, customers can expect to reduce their storage space consumption by a factor of 2x to 3x by using the OLTP Table Compression feature. That is, the amount of space consumed by uncompressed data will be two to three times larger than that of the compressed data.

### Objectives
 
In this lab, you will enable:
* OLTP Table Compression 
* SecureFiles LOB Deduplication
* SecureFiles LOB Compression

### Prerequisites 
This lab assumes you have:

* A LiveLabs Cloud account and assigned compartment
* The IP address and instance name for your DB19c Compute instance
* Successfully logged into your LiveLabs account
* A Valid SSH Key Pair
  
## Task 1: Enable OLTP table compression 

1. Create table Emp with OLTP table compression

      ```
      <copy>
      CREATE TABLE emp  (
               emp_id NUMBER , first_name VARCHAR2(128) , last_name VARCHAR2(128) 
            ) COMPRESS FOR OLTP;
      </copy>
      ```  

2. Verify compression.

      ```
      <copy>
      SELECT table_name, compression, compress_for FROM user_tables where table_name = 'EMP' ;
      </copy>
      ```  

      ![View EMP Table Compression](images/emp-table.png "View EMP Table Compression")

## Task 2: SecureFiles LOB Deduplication

1. Create tablespace. 

      ```
      <copy> 
      CREATE TABLESPACE lob_tbs 
         DATAFILE 'tbs1_data.dbf' 
         SIZE 10m; 
      </copy>
      ```

2. Create table with STORE AS SECUREFILE option

      ```
      <copy> 
      CREATE TABLE images (
      image_id NUMBER,
      image BLOB)
      LOB(image) STORE AS SECUREFILE (TABLESPACE lob_tbs DEDUPLICATE);
      </copy>
      ```

3. Display compression details from user\_lobs      

      ```
      <copy> 
      SELECT table_name, column_name,  retention,  compression, deduplication, in_row, format, securefile
      FROM user_lobs where table_name='IMAGES'; 
      </copy>
      ```

      ![User ILM Policies](images/images.png "User ILM Policies")
 
## Task 3: SecureFiles LOB compression

1. Create table with STORE AS SECUREFILE option 
 

      ```
      <copy>
      CREATE TABLE newimages (
      image_id NUMBER,
      image BLOB)
      LOB(image) STORE AS SECUREFILE (TABLESPACE lob_tbs COMPRESS);
      </copy>
      ```

2. View Data in user\_lobs table.      

      ```
      <copy> 
      SELECT table_name, column_name,  retention,  compression, deduplication, in_row, format, securefile
      FROM user_lobs where table_name='NEWIMAGES'; 
      </copy>
      ```
      

      ![User ILM Policies](images/new-images.png "User ILM Policies")
 
## Task 4: Cleanup

1. When you are finished testing the example, you can clean up the environment by dropping the tables 
 
      ```
      <copy>
      drop table images purge;  
      </copy>
      ```

      ```
      <copy> 
      drop table newimages purge; 
      </copy>
      ```

      ```
      <copy> 
      drop table emp purge;  
      </copy>
      ```

      ```
      <copy>   
      drop tablespace lob_tbs;
      </copy>
      ```
  
   You successfully made it to the end this lab OLTP Compression. You may now [proceed to the next lab](#next).  

## Learn More

* [OLTP Compression](https://docs.oracle.com/cd/E29633_01/CDMOG/GUID-090FB709-9BC1-44C7-9855-B49AF8AAF587.htm) 
 
## Acknowledgements

- **Author** - Madhusudhan Rao, Principal Product Manager, Database
* **Contributors** - Kevin Lazarz, Senior Principal Product Manager, Database and Gregg Christman, Senior Product Manager
* **Last Updated By/Date** -  Madhusudhan Rao, Feb 2022 
