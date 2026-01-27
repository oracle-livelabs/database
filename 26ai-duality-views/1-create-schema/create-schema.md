# Lab 1: Set Up the Relational Schema

## Introduction

In this lab, you will create a small relational schema that serves as the foundation for JSON Relational Duality Views. The schema models a simple conference system with attendees, speakers, sessions, and schedules.

The tables include primary keys, foreign keys, and a JSON column to support flexible document attributes.

Estimated Lab Time: 5–7 minutes

### Objectives

In this lab, you will:
* Create relational tables with primary and foreign keys
* Initialize a JSON column with a valid object
* Seed sample data using idempotent SQL statements

*This is the "fold"*

---

## Task 1: Create the Base Tables

Run the following script to create the base tables used throughout the workshop. The `extras` column is defined as a JSON object and initialized with a default value.

Run this step as a script.

-iframe here

## Task 2: Seed Sample Data

Insert sample data using idempotent MERGE statements so the script can be safely re-run without duplicating data.

-iframe here

## Task 3: Ensure Valid JSON Data

Ensure all rows contain a valid JSON object in the extras column.

-iframe here