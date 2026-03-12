# Lab 1: Set Up the Relational Schema

## Introduction

In this lab, you will create a small relational schema that serves as the foundation for JSON Relational Duality Views. The schema models a simple conference system with attendees, speakers, sessions, and schedules.

The tables include primary keys, foreign keys, and a JSON column to support flexible document attributes.

Estimated Lab Time: 5–7 minutes

## Objectives

In this lab, you will:
* Create relational tables with primary and foreign keys
* Initialize a JSON column with a valid object
* Seed sample data using idempotent SQL statements

---

## Task 1: Create the Base Tables

First, we create a small relational schema for a conference system: attendees, speakers, sessions, and schedule. Each table has a primary key, and foreign keys connect sessions to speakers and schedule entries to both attendees and sessions.

The attendee.extras column is defined as `JSON (OBJECT) DEFAULT JSON_OBJECT()`. This does two important things:

* `JSON (OBJECT)` enforces that only JSON objects can be stored in the column.

* `DEFAULT JSON_OBJECT()` ensures every new row automatically starts with `{}`.

This gives us a strongly structured relational foundation with a flexible JSON column ready for document-style extensions.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE4WSTW%252BDMAxA7%252FwKH4M0DqumadJOwIxG18IUaLWeqhTMYANSkVTqz5%252F4qlqtLbnFz3Ke7RiWBY5QBFrsSlLAqM5kkxDI3Q8lGlQu9gSZbEDnBFlJR0hkeahq03A52jFCbDsLBN%252BDIIwBv%252FwojkBoTXVKBMwAEEUK3QlWSwc5fHJ%252FafMNfODmocW1qKjFa5u77zafscfZi9kSOupGKACYR2EALHTm6MYmvKFnrxZxF932QWYa5qtxz0jtSfxS0wmp%252B0KjzxWhShTlBXl%252B6kAjdFF%252FnypOypBShazVpc2Uzn%252BfRsrqBhr69dOxKkcPOQYunmbBVJFOzy3JKT2U%252FSbHy7ZIb8gOnbUJ1x4e%252Bu5e7nY%252F%252FJOzgmfpI2WiF7UsDN0%252F1V%252F3k7ECAAA%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Task 2: Seed Sample Data

Next, we seed the schema with sample data using `MERGE` statements instead of plain`INSERT`.

Each `MERGE`:

- Matches rows by primary key.

- Inserts only when a row does not already exist.

This makes the script idempotent. You can re-run it without creating duplicate rows or violating primary key constraints. On a first run, rows are inserted. On subsequent runs, the `MERGE` statements simply do nothing.

This approach is ideal for tutorials and demos where users may execute the script multiple times.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE52UT2%252BbQBDF73yKdwNLmBanUg9RpboOjYkwJAa3x2jqHcWrGBaxEKnfvuKfTZ0Q2dkLzDJvdub3VkyniJkFBJUESwpOc1VyVk6Mlbe%252B9eCHSQQqS84EM8jYxH54Cyv2Am%252BRwAVJYcOMd6R3lD2boIxSxs91tIKoaI9N6Ech5kFgoF2dcma3oXmjqicTg3XQTqCNKIRFDkmBb9D1c2L8XnohwijBap4slt4NkqUXGoAfxt46gdV01LQxwa95sPFiWI3Uris0%252B9fGcDqdMz1zAZ2%252Fmk430%252F1QQpmolTbMPyzoe5XJFy60LP86LCoTnJLc2%252FgKFFTK7OkSAIksypodFaYNMy2csivfV7d7Mu7nMUQ6d3THSJ%252FDqJmrHahrve17YmDATLfM2jztdJna6XJPKLLWUmUamkcw3sVRCMoE4odg6HgHdq1UCtdEoVRq16LWFl9cAvM%252B%252BBQ%252FBFAF7uiF9LaQeXkA2B4x62P3zVs3esZVf0ZU0HbPUBnk%252FU5lfDTocIbb783evdmaP2xbS%252BnA6F3julznmH1i3XbHotpz%252FfLau%252B7jY13T7W3uov7H8CgvcalfJ%252FEH%252FRip9jb50WpfTqpdndPbwcftzhlwag09xmcYO4Q8RDwAfGLxfwpnqNHOUHU9nXrR4h%252Bl97Ei5wUAAA%253D%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Task 3: Ensure Valid JSON Data

Finally, we ensure all existing attendee rows contain a valid JSON object in the extras column:

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE0WNsQ6CMBgG9z7FN8LQJyAOiH8iBFrTluhmqv5BHEpCq%252FL4JpjoepfLSQkK8TkzeBljGsOAeXpH3P2L4dFYrTBdHnxNGAPo5ExpRX%252FYlY7gU%252BJwYxaWHADwkmYfsVmrs942VLksF8c9GfrZ2kL1bQttoLRD9sfr61vlhRCV7rraFUJK0tUHRZDlEKcAAAA%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

On a fresh run, this will update 0 rows because:

- extras defaults to `{}`.

- The column is constrained to `JSON` objects.

This step is included as a safety check. If legacy or imported data contained NULL values, this statement would normalize those rows to `{}`.

## Task 4: Sanity Check

The following query confirms that every attendee row has a valid JSON object in extras. On a fresh run, both rows should show `OK` and `{}`.

<iframe
            id="live-sql-embedded"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE02PQU%252BDQBCF7%252Fsr3g2byKVHPS0wbWlxN9lFTXtpRjoJ2IgNbBr594YUqXN782a%252BlxfH8Nw2YUBVS3V%252BglylG8AhSHsSQc09GFtvDb4%252FPqUKaFrIT%252Bi4V54KSktwc3pUuA23%252FCWzSrUn%252FAngfUNm%252BkXub1CbbEdGOVqR3UX3ayo8IUp0Nu%252FIZNB%252BIhz7mi%252F3qBF29ORyXeQHephSHJWvzuRmjTft0o12y8U%252FwqWTEAa1cvZlLqysy8gh2Y%252B1nlUck01%252FAcfIyqQkAQAA&code_language=PL_SQL&code_format=false"
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