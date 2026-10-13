# Lab 2: Single-Table Duality Views

## Introduction

In this lab, you will expose relational tables as **updatable JSON documents** using **JSON Relational Duality Views**. You will create two document views and then query them to confirm the document structure.

Estimated Lab Time: 5 minutes

## Objectives

In this lab, you will:

* Create single-table JSON Relational Duality Views

* Apply field-level control (read-only)

* Query JSON documents generated from relational data

---

## Task 1: Create Duality Views for Attendees and Speakers

In this step, you will create two single-table duality views:

- `attendee_dv` maps relational attendee rows into JSON documents. The `extras` column is exposed as a plain JSON property, meaning the entire JSON object is stored and retrieved as-is.

- `speaker_dv` maps speaker rows into JSON documents, hides the `email` column, and marks `rating` as read-only using `WITH NOUPDATE`.

Both views are fully updatable (`WITH INSERT UPDATE DELETE`), allowing document-style DML over relational tables.

Run this step as a script.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE5WQy07DMBRE9%252F6K2WVD%252BgHNKkovIigkVeJSsaou%252BIpa5KXYLVSIf0dN2oLEomJnH8uaOROGYO%252BlNSIbs59j1xv2%252FFwLTPeya6T12Ft5j9BwD%252FnwAzuwQ1%252BzbXFfFTn6oetl8AeVlBRrQlGipGUWJzS9l5TFOi3yOMNiFWepfsJjSuvfsYgrVVFGiZ6%252BfCog2FgTAMAcPGNrbo6s5UaCMzteRjrVCkY6ndWXui2Lh0sGGOtU3yHNKyo1VsvFsemCMtIUKRWGcL3wmwzjBltrBNKwrSMM7G37CuswCJuwa%252BsD9pbhtzIO81%252Frn5wr0m7m%252Fki72cV56hWM8NRxNMyLSe68wCkP7soAVCTfa6SLZwsCAAA%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

> Tip: If you re-run this script, it will replace the views safely.

---

## Task 2: Query a JSON Document from a Duality View

Now that the duality views exist, query `attendee_dv` to view JSON documents generated from relational data.

This query uses`JSON_SERIALIZE(... PRETTY)` to format the document for readability. Notice that the output includes an automatically generated `_metadata` section, which is managed by the database.

Run this step as a script.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAEx3MMQrCMBQG4D2n%252BAehFowXcGrjU5SYlCQVOoXQvKEqLdjg4OkFvwN8UqJjfgpPmlTAY13muPJ7Sq%252Fpy9ucSoKj0DtzMWcobVt0jkIYajQeeRnFydkbgFQKz5k55o%252Bw7kgOaAdcvTXx3uie%252FtUO1WYfp1zVByElWfUDidNy0n4AAAA%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

---

## Acknowledgements
* **Author** – Layla Elwakhi, Oracle
* **Last Updated By** – Layla Elwakhi, March 2026