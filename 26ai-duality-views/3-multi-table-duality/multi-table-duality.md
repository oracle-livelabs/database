# Lab 3: Multi-Table Duality View

## Introduction
In this lab, you will create a multi-table JSON Relational Duality View that produces nested JSON documents from normalized relational tables.

Instead of exposing a single table as a document, this view combines data from multiple related tables into one hierarchical JSON structure.

Estimated Lab Time: 4–5 minutes

## Objectives

In this lab, you will:

* Create a multi-table duality view

* Generate nested JSON documents from normalized tables

* Observe how relational joins become hierarchical JSON

## Task 1: Create a Multi-Table Duality View
In this step, you will create `schedule_dv` using the GraphQL-style duality syntax.

This view produces:

* One document per attendee

* A nested schedule array for that attendee

* Nested session details

* Nested speaker information inside each session

Although the document appears hierarchical, the underlying data remains fully normalized with primary and foreign keys enforced by the database.

The previously created `attendee_dv` remains unchanged. This is a new view built over the same relational foundation.

Run this step as a script.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE22PTQrCMBCF9z3Fu4AXqJuGmkWlWKlVcVWCGTBYE2mmbsS7S6qmgmYxP3l882byWopGoqpRy3UpconlplqhlqVoimolSiy2oiyaA3aF3MMfT6SHjlp9g9gkgGImq4lwTwCgNRpIoYweW6suFNqQx48Pj3QqM2M99YxsuGrFhExTR%252FyZODGF%252FqLatwPgyXvjrEc2WEueIxelFxgBgA13NFYp4mrhde6o2DgbhN65yzTpSupM%252FR%252BPqP24vM%252F%252F5%252FNIvnOIj%252FlsJqv8CY6ZDj2PAQAA&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Task 2: View a Nested JSON Document

Now that `schedule_dv` exists, query it to view a single attendee’s document.

This query retrieves attendee `_id = 1` and pretty-prints the nested JSON structure.

Notice how:

* The top level represents the attendee

* The schedule property contains an array

* Each array element includes session and speaker information

Even though the output looks like a single JSON document, the data comes from multiple normalized tables.

Run this step as a script.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE03MTQqCQBgG4L2neBeBCSm0jhYqX3%252FojIxj0UoG54MsUWisRauu0fU6SRAtOsDzhCEK5guGnmHGkXvL%252FH6%252BHOzQeCVllGqc3dDXjq%252Bt6doHT11kzWigSFdKbMUaaSYTFIq0PgaIyy9dKZkDcM2J7a3j2t7hvMOGFAG7Uop6H2cV%252Fa4Z%252FElUt9b%252FS0WVJ6QCLDFfeGFIMv0AFz98lqsAAAA%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Acknowledgements
* **Author** – Layla Elwakhi, Oracle
* **Last Updated By** – Layla Elwakhi, March 2026