# TimesTen LiveLabs on GitHub - Welcome!
[![](../../common/images/livelabs-banner-formarketplace.png)](https://livelabs.oracle.com)

Oracle TimesTen In-Memory Database (TimesTen) delivers real time application performance (low response time and high throughput) by changing the assumptions around where data resides at runtime. By managing data in memory, and optimizing data structures and access algorithms accordingly, database operations execute with maximum efficiency achieving dramatic gains in responsiveness and throughput.

TimesTen is a relational database, with SQL as its access language and PL/SQL as its procedural language, so you can leverage your existing Oracle Database skills. TimesTen supports a wide range of database APIs such as JDBC, ODBC, ODP.NET and Oracle Call Interface (OCI). Several Open Source languages, such as Python and Node.js, are supported via Open Source APIs.

TimesTen Scaleout, a shared nothing scale-out architecture based on the existing TimesTen in-memory technology, allows databases to transparently scale across dozens of hosts, reach hundreds of terabytes in size and support hundreds of millions of transactions per second without the need for manual database sharding or workload partitioning. 

TimesTen can be deployed in two distinct ways:

_TimesTen Classic_

A single node database for applications that require the lowest and most consistent response time. High availability is provided via active-standby pair replication to another node, and also supports multiple read-only subscribers for scaling read heavy workloads.

TimesTen Classic can also be deployed as a cache for Oracle Database. By caching a subset of your Oracle Database data in a TimesTen cache, you can dramatically improve the performance of data access. TimesTen provides a declarative caching mechanism which suports both readonly caching and read-write caching. Data change synchronization, a standard feature of TimesTen cache, ensures that the cache and the backend database are always in sync.

_TimesTen Scaleout_

A shared nothing distributed database based on the existing TimesTen in-memory technology. TimesTen Scaleout allows databases to transparently scale across dozens of hosts, reach hundreds of terabytes in size and support hundreds of millions of transactions per second without the need for manual database sharding or workload partitioning. Scaleout features include concurrent parallel cross-node processing, transparent data distribution (with single database image) and elastic scaleout and scalein. High availability and fault tolerance are automatically provided through use of Scaleout's K-safety feature. TimesTen Scaleout supports most of the same features and APIs as TimesTen Classic.

TimesTen Scaleout can also be deployed as a cache for Oracle Database, supporting a subset of the cache features of TimesTen Classic.


## How do I get started with TimesTen LiveLabs?

Before attempting any of the workshops listed below you need to determine which type of environment you are going to utilize. You have the choice of running the workshops in your own Oracle Cloud tenancy or in a LiveLabs provided tenancy. If you want to use your own tenancy it can either be via an existing Oracle Cloud account to which you have access or you can register for an Oracle Cloud Trial Account.

## Get an Oracle Cloud Trial Account for Free!
If you don't have an Oracle Cloud account then you can quickly and easily sign up for a free trial account that provides:
- $300 of free credits good for up to 3500 hours of Oracle Cloud usage
- Credits can be used on all eligible Cloud Platform and Infrastructure services for the next 30 days
- Your credit card will only be used for verification purposes and will not be charged unless you 'Upgrade to Paid' in My Services

Click here to request your trial account: [https://www.oracle.com/cloud/free](https://www.oracle.com/cloud/free)

## TimesTen Workshop Pre-requisites

The TimesTen workshops have the following pre-requisites:
  
- A basic familiarity with relational databases and SQL

## Available TimesTen Workshops
- [Accelerate your Applications: Achieve Blazing Fast SQL With an Oracle TimesTen Cache](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3282)

## TimesTen Related Pages
- [TimesTen Product Home](https://www.oracle.com/database/technologies/related/timesten.html)
- [TimesTen Samples on GitHub](https://github.com/oracle-samples/oracle-timesten-samples)
- [TimesTen Blogs](https://blogs.oracle.com/timesten/)

## Documentation
- [TimesTen Documentation](https://docs.oracle.com/en/database/other-databases/timesten/)
 
## Need Help?
Please first consult the "Need Help?" lab located at the bottom of your workshop to see if our FAQ can solve your problem.  If you have an issue that is specific to the contents of the workshop, please reach out to the author located in the "Acknowledgements" section at the bottom of each lab via email. Please include your workshop name and lab name. You can also include screenshots and attach files. If you have a more general issue, or would like to reach out to the LiveLabs management team, email us [here](mailto:livelabs-help_us@oracle.com).   

If you do not have an Oracle Account, click [here](https://profile.oracle.com/myprofile/account/create-account.jspx) to create one.
