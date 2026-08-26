# The Third Door, Writable — REST ETag Choreography (Optional)

## Introduction

In Lab 5 you read a duality document through REST and noticed its `_metadata.etag`. This optional lab runs the full optimistic-concurrency choreography: read with the etag, write with `If-Match` (200 OK), then replay the stale etag and collect the teaching **412 Precondition Failed**. Lock-free concurrency you didn't have to build — no row locks held across think time, no saga, no compensating action; the engine refuses stale writes.

In a live session this lab is an instructor demo by default; it is fully scripted for fast finishers and homework.

Estimated Lab Time: 5 minutes

### Objectives

* Capture a document's etag with an HTTP/2-safe one-liner
* Perform a conditional PUT that succeeds, then one that correctly fails with 412
* Leave the database state exactly as you found it

### Prerequisites

* Completed **Lab 5** — `store_menu_dv` created and REST-enabled
* A terminal with `curl` and `jq` available

## Task 1: Set Your Connection Variables

1. In a **terminal**, export your ORDS endpoint and credentials. The host is the same one you used for the REST read in Lab 5 — substitute your own values:

    ```
    <copy>
    export ORDS_BASE="https://HOST.adb.REGION.oraclecloudapps.com/ords/USERNAME"
    export ORDS_USER="USERNAME"
    export ORDS_PASS="PASSWORD"
    </copy>
    ```

## Task 2: Run the Choreography

1. Paste the whole block into the same **terminal**. It needs `curl` and `jq` — both standard on macOS and Linux; on Windows use Git Bash or WSL. It does four things, printing each step — no hand-edited JSON, no copy-pasted etag strings:

    ```
    <copy>
    set -euo pipefail
    DOC_URL="$ORDS_BASE/store_menu_dv/s_100"

    # 1. GET the document; capture body and etag (HTTP/2-safe: %header{} ignores case).
    #    Strip the header's own quotes - If-Match must carry EXACTLY one quoted hex
    #    string, or the engine raises ORA-42626 (validated live on ADB).
    ETAG=$(curl -s -u "$ORDS_USER:$ORDS_PASS" -o /tmp/doc.json -w '%header{etag}' "$DOC_URL" | tr -d '"')
    echo "step 1: GET 200, etag=$ETAG"

    # 2. Edit only the location-owned override name with jq, PUT with If-Match -> 200 OK
    jq '.' /tmp/doc.json > /tmp/doc_orig.json
    jq 'del(._metadata) | .name = "Burger Palace"' /tmp/doc.json > /tmp/doc_edit.json
    CODE=$(curl -s -o /tmp/put1.json -w '%{http_code}' -u "$ORDS_USER:$ORDS_PASS" \
      -X PUT -H "Content-Type: application/json" -H "If-Match: \"$ETAG\"" \
      --data @/tmp/doc_edit.json "$DOC_URL")
    echo "step 2: conditional PUT -> $CODE (expect 200)"

    # 3. Replay the PUT with the now-stale etag -> 412 Precondition Failed
    CODE=$(curl -s -o /tmp/put2.json -w '%{http_code}' -u "$ORDS_USER:$ORDS_PASS" \
      -X PUT -H "Content-Type: application/json" -H "If-Match: \"$ETAG\"" \
      --data @/tmp/doc_edit.json "$DOC_URL")
    echo "step 3: stale PUT -> $CODE (expect 412 - the engine refused the stale write)"

    # 4. Revert: re-GET (fresh etag) and PUT the original body back
    ETAG=$(curl -s -u "$ORDS_USER:$ORDS_PASS" -o /dev/null -w '%header{etag}' "$DOC_URL" | tr -d '"')
    jq 'del(._metadata)' /tmp/doc_orig.json > /tmp/doc_revert.json
    CODE=$(curl -s -o /dev/null -w '%{http_code}' -u "$ORDS_USER:$ORDS_PASS" \
      -X PUT -H "Content-Type: application/json" -H "If-Match: \"$ETAG\"" \
      --data @/tmp/doc_revert.json "$DOC_URL")
    echo "step 4: reverted -> $CODE (canonical state restored)"
    </copy>
    ```

    Read what just happened, step by step:

    1. `GET` the `s_100` document, capturing the body to a file and the etag with `curl -w '%header{etag}'` (HTTP/2 header names are lowercase; this extraction doesn't care).
    2. Edit the document with a `jq` one-liner and `PUT` it with `If-Match: <etag>` → **200 OK**.
    3. Repeat the `PUT` with the now-stale etag → **412 Precondition Failed**. Nobody held a lock; the engine simply refused a write based on stale state. Your conflict-resolution policy ("refresh, reapply, retry") is app code — the *detection* never is.
    4. **Revert** the edit, restoring the canonical state the later labs expect.

    **What you should see:** `200` then `412` then `reverted`. If step 1 returns 401, re-check `ORDS_USER`/`ORDS_PASS`; if 404, re-run the `ORDS.ENABLE_OBJECT` block from Lab 5 Task 1.

## Learn More

* [ORDS AutoREST and ETags](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/)

You may now **proceed to the next lab**.

## Acknowledgements
* **Author** - Rick Houlihan, Field CTO, Oracle Data & AI Platform
* **Last Updated By/Date** - Rick Houlihan, July 2026
