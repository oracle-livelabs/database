# Lab 5: Query Documents with SQL

## Introduction

In this step, you will query nested JSON documents using standard SQL. The `JSON_TABLE` function expands each attendee’s `schedule` array into relational rows. Each session inside the JSON array becomes its own row, allowing you to report on session title, location, and speaker just like any other relational query.

## Objectives

In this lab, you will:

* Query nested JSON documents using `JSON_TABLE`
* Extract scalar values using `JSON_VALUE`
* Produce relational-style reporting from JSON arrays

Estimated Time: 5 minutes

## Key details

* `NESTED PATH '$.schedule[*]'` ensures one output row per session in the array.
* Quoted JSON paths such as `'$."sessionId"'` handle camelCase property names.
* `JSON_VALUE(s.data, '$.name')` extracts the attendee’s name from the top level of the document.

This demonstrates how you can store data as nested JSON documents while still performing structured, set-based analytics with SQL.

Run the query below to see the flattened results.

## Task 1: Query Nested JSON Data

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE32SXUvDMBSG7%252FMrDkVoO7oiA6%252B8SrvIlH5I0g5kSAlrwM7aion%252Bfmln0sY6c5WcvM%252F5eBNGEhIX8MDyrNrjpCSeDGuueADuVdjxN%252BH6gBlwpURXCxEgOK%252BTCqWQsum7%252B3oeVI1qLVXbH7lq%252Bs4i3wV%252FFR82%252BROshqLojuYpAMjji6g%252FW1HVXyCNeGy2wFFCPB0CmNp2p2CcJ2WaMZjpADLCCrKFR1zshiF1jcPq2Z3L%252FmQBzNTnXGUaEarvdErHiBw3sPHRH3PaYxrvMN14N9f%252BDB9FC1Q7%252BQvdWKgWLWjj%252Bb99a9ElfHydi30Pl45loo%252BWWx9OCuV0SyhET9PPmpy9Res1yeNv4IaKr5sCAAA%253D&code_language=PL_SQL&code_format=false"
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