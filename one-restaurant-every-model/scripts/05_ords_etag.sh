#!/usr/bin/env bash
# Lab 6: ORDS ETag optimistic-concurrency choreography.
# Requires: ORDS_BASE, ORDS_USER, ORDS_PASS in the environment; jq in Cloud Shell.
# Edits ONLY the location-owned override name and reverts it - downstream-inert.
set -euo pipefail

DOC_URL="$ORDS_BASE/store_menu_dv/s_100"

# 1. GET the document; capture body and etag (HTTP/2-safe: %header{} ignores case).
#    Strip the header's own quotes - If-Match must carry EXACTLY one quoted hex
#    string, or the engine raises ORA-42626 (validated live on ADB).
ETAG=$(curl -s -u "$ORDS_USER:$ORDS_PASS" -o /tmp/doc.json -w '%header{etag}' "$DOC_URL" | tr -d '"')
echo "step 1: GET 200, etag=$ETAG"

# 2. Edit only the override-owned field with jq, PUT with If-Match -> 200 OK
jq '(.menus[0].categories[0].items[0].name) as $n | .' /tmp/doc.json > /tmp/doc_orig.json
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
