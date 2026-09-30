# Introduction

## About this Workshop

Autonomous Database Serverless - like all other versions and editions of Oracle Database - has a built-in text search engine, Oracle Text. This is a really powerful feature of the converged database, that people often don&#39;t even realize they have. Want to find a mis-spelled company name? Want to find all comments in a work log that mention &#39;failure&#39; and &#39;hardware&#39;? No problem, Oracle Text can do that - and lots more.

You can easily create text indexes on VARCHAR2, CLOB or BLOB columns in the database, and search them using word-based content searches.

Let&#39;s look at a simple, basic example:

```
<copy>
create table pangrams (tdata varchar2(80));

insert into pangrams values (&#39;The quick brown fox jumps over the lazy dog&#39;);
insert into pangrams values (&#39;Bright vixens jump; dozy fowl quack&#39;);

create index pangidx on pangrams(tdata) indextype is ctxsys.context;

select * from pangrams where contains(tdata, &#39;jump%&#39;) &gt; 0;
</copy>
```

The &#39;jump%&#39; in our query matches the indexed words &#39;jump&#39; and &#39;jumps&#39;, so both rows are returned.
(in case you&#39;re interested, a pangram is a phrase that uses all the letters of the alphabet).

Great - that&#39;s really useful for content searching on text within the database. But what if our data is actually in files on Object Storage, rather than in the database itself? If only Oracle Text could manage to index files as well as just text in the database...

Well, it can do that too! Oracle Text is almost infinitely extendable, and you can plug in your own code at many points. It&#39;s possible to write a &quot;user datastore&quot; procedure that can access files in object storage. But now, we&#39;ve made that much easier for you with a new <kbd>DBMS\_CLOUD </kbd>procedure, <kbd>CREATE\_EXTERNAL\_TEXT\_INDEX</kbd>. We just need to provide a URI for an Object Storage bucket, and it will traverse all the files in that bucket and index the contents of each file. At a preset interval (the default is five minutes) it will check the bucket for new, updated, or deleted files and index, reindex or remove those files as appropriate.

### Workshop Scenario

We're going to load some files in Object Storage, and create a credential that allows programs (including SQL programs) to access those files.

We'll then create an external text index on those files, and then run some Oracle Text queries against them.

### Prerequisites

Oracle Text is a SQL-level toolkit. This workshop assumes you have:

* Some familiarity with basic SQL concepts
* An Oracle Cloud account

You may now proceed to the next lab.

## Learn More

* [Oracle Text Homepage](https://www-sites.oracle.com/database/technologies/appdev/oracletext.html)

## Acknowledgements

* **Author** - Roger Ford, Principal Product Manager
- **Contributors** - James Zheng
* **Last Updated By/Date** - Roger Ford, March 2022
