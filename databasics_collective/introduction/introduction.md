# Databasics Collective: Oracle Autonomous Database Fundamentals

## Introduction

The labs in this workshop introduce the basics of working with a database. You will use a university dataset with departments, students, courses, and enrollments to practice reading data, making changes, and creating database objects.

The reservation is prepared for you: the database, `DATABASICS` user, four core tables, and sample rows are already in place. Sign in through the reservation link, then run the lab SQL in the Database Actions SQL Worksheet. You will work with this same dataset throughout the workshop. Constraint and index names used in the labs start with `DBC_`.

### What is a database?

A database is an organized collection of related information. In this workshop, the information is about a university: students belong to departments, courses are offered, and enrollments connect students to courses. Tables hold the information in rows and columns. SQL is the language you use to read and change it.

A **database management system (DBMS)** is the software that stores and works with the data. **Oracle AI Database** is Oracle's database management system. A **schema** is the collection of database objects owned by a user, such as tables, views, and sequences. In these labs, `DATABASICS` is the user and schema you work in.

For a short introduction, see [Oracle AI Database Concepts](https://docs.oracle.com/en/database/oracle/oracle-database/26/cncpt/introduction-to-oracle-database.html).

### What makes Autonomous AI Database different?

The tables and SQL concepts you learn here also apply to a self-managed Oracle database. The difference is mainly who handles the database's routine operations. With a self-managed database, the organization running it takes care of more of the setup, software updates, backups, and ongoing maintenance. **Oracle Autonomous AI Database** is a managed cloud service: Oracle automates much of this work, including provisioning, backups, patching, and tuning.

Autonomous does not change how you design tables or write SQL. You still decide what data your schema contains and how its tables relate. In this workshop, the cloud database and sample data are already prepared, so you can focus on those database basics instead of setup. Learn more in [What is Oracle Autonomous AI Database?](https://docs.oracle.com/iaas/autonomous-database/index.html).

### Prerequisites

- A LiveLabs reservation with the DATABASICS user and loaded workshop data
- Ability to open Database Actions and sign in through the reservation link
- Permission to create tables, views, sequences, synonyms, and indexes in your schema
- No previous database experience

### Objectives

After the workshop, you can:

- Explain the difference between a database, a DBMS, and a schema.
- Explain the relationships and constraints in the ready schema.
- Create and change a small practice table.
- Query the loaded data and practice insert, update, and delete statements, then restore the practice data as instructed.
- Create a view, sequence, synonym, and indexes.
- Inspect database objects through Oracle data dictionary views.

Estimated Workshop Time: 90 minutes

## Acknowledgements

* **Author** - Ilan Gómez Guerrero
* **Last Updated By/Date** - Ilan Gómez Guerrero, November 2026
