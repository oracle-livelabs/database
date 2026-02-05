# Lab 2: Single-Table Duality Views

## Introduction

In this lab, you will expose relational tables as **updatable JSON documents** using JSON Relational Duality Views. You will create two document views, then query a document to confirm everything works.

Estimated Lab Time: 5 minutes

### Objectives

In this lab, you will:
* Create single-table JSON Relational Duality Views
* Apply a simple field-level control (read-only)
* Query JSON documents from a duality view

---

## Task 1: Create Duality Views for Attendees and Speakers

Run the script below to create two single-table duality views:
* `attendee_dv` maps attendees into JSON documents, including the `extras` JSON object.
* `speaker_dv` maps speakers into JSON documents and makes `rating` read-only.

Run this step as a script.

<iframe
            id="live-sql-embedded"
            src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE5WQy07DMBRE9%252F6K2WVD%252BgHNKkovIigkVeJSsaou%252BIpa5KXYLVSIf0dN2oLEomJnH8uaOROGYO%252BlNSIbs59j1xv2%252FFwLTPeya6T12Ft5j9BwD%252FnwAzuwQ1%252BzbXFfFTn6oetl8AeVlBRrQlGipGUWJzS9l5TFOi3yOMNiFWepfsJjSuvfsYgrVVFGiZ6%252BfCog2FgTAMAcPGNrbo6s5UaCMzteRjrVCkY6ndWXui2Lh0sGGOtU3yHNKyo1VsvFsemCMtIUKRWGcL3wmwzjBltrBNKwrSMM7G37CuswCJuwa%252BsD9pbhtzIO81%252Frn5wr0m7m%252Fki72cV56hWM8NRxNMyLSe68wCkP7soAVCTfa6SLZwsCAAA%253D&code_language=PL_SQL&code_format=false"
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

Now that the views exist, query `attendee_dv` to view JSON documents stored over relational data.

Run this step as a script.

<iframe
            id="live-sql-embedded"
            src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAEx3MMQrCMBQG4D2n%252BAehFowXcGrjU5SYlCQVOoXQvKEqLdjg4OkFvwN8UqJjfgpPmlTAY13muPJ7Sq%252Fpy9ucSoKj0DtzMWcobVt0jkIYajQeeRnFydkbgFQKz5k55o%252Bw7kgOaAdcvTXx3uie%252FtUO1WYfp1zVByElWfUDidNy0n4AAAA%253D&code_language=PL_SQL&code_format=false"
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

## Learn More

* [JSON Relational Duality Views Developer’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/json-relational-duality-developers-guide.pdf)

## Acknowledgements
* **Author** - Layla Elwakhi, Oracle
* **Last Updated By/Date** - Layla Elwakhi, January 2026
