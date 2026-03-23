# Lab 4: CRUD Through Documents

## Introduction
Explain document-style DML backed by relational tables.

Estimated Lab Time: 4–5 minutes

## Objectives
* Insert JSON documents
* Update document fields in place
* Delete documents

## Task 1: Insert a JSON Document

In this step, you will insert a new attendee document into `attendee_dv`. The insert uses the portable `JSON_OBJECT(... RETURNING JSON)` form, which is easy to generate from application code and works consistently across environments.

After inserting, you will query the view to verify the new document was created and stored over the underlying relational table.

Run this step as a script.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE22QMU%252FDMBCFd%252F%252BKG5AcSzVLx4qBRAZSJTZyklZMkVGuYJQmyLEq2l%252BPYgKklJvu7r37bD3OIe0GdB6i995589wirAslaxWvRVLCrnd7RlJZCF1CKksFxnvsGsS6OUDUGG8Y2dxmlSggIjC%252FHUcAWtuGjk0wwXLxte3MHunPlhambY900vDDOzPQSbsgnhVtLHo6DRPsgC%252Bmm2DnZj%252B8WucLe8JvOs3ppU%252BLstIylffh8b86I%252F96GGErQjiHDTq7O5JCZGOAb0Pf1QM6a1p7whDY7DbJVAyPWpTlEyN3WuUA84DJ9kFoMaUaPhwAC6BX1yHXX5Ks8lhoBjewXHEuVPIJ%252FmszKdoBAAA%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Task 2: Update a JSON Document

Now that the document exists, update it in place using `JSON_TRANSFORM`.

This update demonstrates an app-style workflow: you modify a single document, and the database applies the change to the underlying relational row. Here we update the attendee’s `name` and add a new property under `extras` (`twitter`) without replacing the full JSON document.

Run this step as a script.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAE2XNQWvCQBAF4Pv%252BincobAJNLj1KoFFXq9RN2WT1GEZ3hJRUJZlq%252B%252B9LaqUH3%252FHxzbwkgT8FEkb02TNKU2F%252F7HDcvvNOsG%252B4DX2s%252FNs0rwxIhA%252BBuQ5nkBosAEoDCSHDsixsXbnclrPCrSKFW67i8b8YLvVDeqAP1sigS2rbb4xTfW%252F4SzrqU7k0Itz96ud%252B4PpGY7V5Mc7gur%252FOX72J%252FhaHB3UTNJypvLMLO4f1q7FxMTI8jVSSmGLyA8jA1rMCAQAA&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Task 3: Delete a JSON Document (Optional)

Finally, you can delete the document from `attendee_dv`. This removes the corresponding relational row behind the scenes.

This step is optional, but it is useful if you want to re-run the insert step later without hitting a duplicate `_id`.

Run this step as a script.

<iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAAEwXBPQvCMBAG4D2%252F4h2EtmC6OIqD2vOLNoGzsWM4yA2F0joc%252Fn6fx3t0uqgp6u1r87bK0riOehoJN44DxEzXoprLD%252BKmBzEBr3cM%252BXPuE9XSFjHZo9q1eS4VmMbE4RnuCGm4EDc44XB03lO8%252FgE8ZVE%252BbQAAAA%253D%253D&code_language=PL_SQL&code_format=false"
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