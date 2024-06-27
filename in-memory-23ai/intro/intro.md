# Introduction

## About this workshop

*Database In-Memory* features a highly optimized In-Memory Column Store (IM column store) maintained alongside the existing row formatted buffer cache as depicted below. The primary purpose of the IM column store is to accelerate column-oriented data accesses made by analytics operations.

It is similar in spirit to having a conventional index (for analytics) on every column in a table. However, it is much more lightweight than a conventional index, requiring no logging, or any writes to the database. Just as the performance benefit to an application from conventional indexes depends on the amount of time the application spends accessing data in the tables that are indexed, the benefit from the IM column store also depends on the amount of time the application spends on data access for analytic operations.

*Estimated Workshop Time*: 90 minutes

Watch the video below for an overview of Oracle In-Memory.

[Youtube video](youtube:JGM1taVRZHs)

<if type="odbw">If you would like to watch us do the workshop, click [here](https://youtu.be/QzCnO_Me97g).</if>

## Overview
### Database In-Memory and Performance

There are four basic architectural elements of the column store that enable orders of magnitude faster analytic query processing:  

1. *Compressed columnar storage*: Storing data contiguously in compressed column units allows an analytic query to scan only data within the required columns, instead of having to skip past unneeded data in other columns as would be needed for a row major format. Columnar storage therefore allows a query to perform highly efficient sequential memory references while compression allows the query to optimize its use of the available system (processor to memory) bandwidth.
   ![In-Memory dual format](./images/DBIM.png " ")

2. *Vector Processing*: In addition to being able to process data sequentially, column organized storage also enables the use of vector processing. Modern CPUs feature highly parallel instructions known as SIMD or vector instructions, for example Intel AVX. These instructions can process multiple values in one instruction –for instance, they allow multiple values to be compared with a given value, for example find sales with State = “California”, in one instruction. Vector processing of compressed columnar data further multiplies the scan speed obtained with columnar storage, resulting in scan speeds exceeding tens of billions of rows per second, per CPU core.

3. *In-Memory Storage Indexes*: The IM column store for a given table is divided into units known as In-Memory Compression Units(IMCUs) that represent many rows, typically several hundred thousand. Each IMCU automatically records the min and max values for the data within each column in the IMCU, as well as other summary information regarding the data. This metadata serves as an In-Memory Storage Index:  For instance, it allows an entire IMCU to be skipped during a scan when it is known from the scan predicates that no matching value will be found within the IMCU.

4. *In-Memory Optimized Joins and Reporting*: Because of massive increases in scan speeds, the Bloom filter optimization (introduced earlier in Oracle Database 10g) can be commonly selected by the optimizer. With the Bloom filter optimization, the scan of the outer (dimension) table generates a compact Bloom filter which can then be used to greatly reduce the amount of data processed by the join from the scan of the inner (fact) table. Similarly, an optimization known as Vector Group By can be used to reduce a complex aggregation query on a typical star schema into a series of filtered scans against the dimension and fact tables.

### In-Memory Architecture

The following figure shows a sample IM column store. The database stores the sh.sales table on disk in traditional row format. The SGA stores the data in columnar format in the IM column store, and in row format in the database buffer cache.

![In-Memory architecture](./images/arch.png " ")

## Learn More

Database In-Memory Channel
[YouTube video](youtube:UCSYHgTG68nrHa5aTGfFH4pA)

Oracle Database Product Management Videos on In-Memory
[YouTube video](youtube:UCr6mzwq_gcdsefQWBI72wIQ) 

You may now **proceed to the next lab**.

## Acknowledgements

- **Authors/Contributors** - Andy Rivenes, Product Manager, Database In-Memory
- **Contributors** - Kay Malcolm, Anoosha Pilli, Rene Fontcha
- **Last Updated By/Date** - Rene Fontcha, LiveLabs Platform Lead, NA Technology, October 2021
