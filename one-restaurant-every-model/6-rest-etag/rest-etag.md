# The Third Door, Writable — REST ETag Choreography (Optional)

## Introduction

In Lab 5 you read a duality document through REST and noticed its `_metadata.etag`. This optional lab runs the full optimistic-concurrency choreography: read with the etag, write with `If-Match` (200 OK), then replay the stale etag and collect the teaching **412 Precondition Failed**. Lock-free concurrency you didn't have to build — no row locks held across think time, no saga, no compensating action; the engine refuses stale writes.

In a live session this lab is an instructor demo by default; it is fully scripted for fast finishers and homework.

Estimated Lab Time: 5 minutes

### Objectives

* Capture a document's etag with an HTTP/2-safe one-liner
* Perform a conditional PUT that succeeds, then one that correctly fails with 412
* Leave the database state exactly as you found it

## Task 1: Set Your Connection Variables

1. In **Cloud Shell**, export your ORDS endpoint and credentials (the `helper_commands.sql` script in the pack prints these three lines fully substituted for your instance):

    ```
    <copy>
    export ORDS_BASE="https://HOST.adb.REGION.oraclecloudapps.com/ords/USERNAME"
    export ORDS_USER="USERNAME"
    export ORDS_PASS="PASSWORD"
    </copy>
    ```

## Task 2: Run the Choreography

1. Run the script (also in `scripts/05_ords_etag.sh`):

    ```
    <copy>
    bash scripts/05_ords_etag.sh
    </copy>
    ```

    The script does four things, printing each step — no hand-edited JSON, no copy-pasted etag strings:

    1. `GET` the `s_100` document, capturing the body to a file and the etag with `curl -w '%header{etag}'` (HTTP/2 header names are lowercase; this extraction doesn't care).
    2. Edit **only** the location-owned override name with a `jq` one-liner, `PUT` with `If-Match: <etag>` → **200 OK**.
    3. Repeat the `PUT` with the now-stale etag → **412 Precondition Failed**. Nobody held a lock; the engine simply refused a write based on stale state. Your conflict-resolution policy ("refresh, reapply, retry") is app code — the *detection* never is.
    4. **Revert** the edit, restoring the canonical state the later labs expect.

    **What you should see:** `200` then `412` then `reverted`. If step 1 returns 401, re-check `ORDS_USER`/`ORDS_PASS`; if 404, re-run the `ORDS.ENABLE_OBJECT` block from Lab 5 Task 1.

## Learn More

* [ORDS AutoREST and ETags](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/)

## Acknowledgements
* **Author** - Rick Houlihan, Field CTO, Oracle Data & AI Platform
* **Last Updated By/Date** - Rick Houlihan, July 2026
