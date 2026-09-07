# Connect Services and Verify the Deployment

## Introduction

In this lab, you perform layered verification to confirm the core platform is production-ready. You will execute health checks, database and memory probes, Slack smoke tests, manual validation, and one complete end-to-end run.

Estimated Time: 45 minutes

### Objectives

In this lab, you will:

- Validate service and database health endpoints.
- Validate Data Agent memory recall.
- Execute automated and manual Slack validation.
- Complete one end-to-end workflow from topic intake to publish.
- Confirm final platform status is healthy.

### Prerequisites

- Completion of Lab 3.
- Active runtime services.
- Access to Slack workspace and channels configured in Lab 3.

## Task 1: Confirm External Service Scope

1. Continue with this lab to validate the core content workflow.
2. Use Lab 5 only when the deployment needs AI Staff Gmail and Calendar, voice transcription, Substack, Instagram intake, or OCI Email Delivery.
3. Keep external integrations disabled while validating the core platform unless the customer intake explicitly requires them.

## Task 2: Run Tier 1 Platform Health Checks

1. Validate that `contentkit-assistant`, `contentkit-pipeline`, `contentkit-brand`, `contentkit-data`, `contentkit-ops`, and `contentkit-publish` are active. Also validate `contentkit-website` when the public intake service is enabled.
2. Check all loopback-only `/health` endpoints: file editor (8001), Brand Agent (8002), Ops Agent (8003), Data Agent (8004), and Website Agent (8005 when enabled).
3. Validate database health and memory recall from the Data Agent endpoint. Empty recall results are acceptable; the response must return `"status": "ok"`. A 500 response usually means the ONNX model from Lab 1 was not loaded or the wallet/database configuration is wrong.

    ```
    <copy>
    for p in 8001 8002 8003 8004 8005; do curl -sm 5 localhost:$p/health; echo " :$p"; done
    curl -sm 15 localhost:8004/health-db
    curl -s -X POST localhost:8004/memory/recall \
      -H 'Content-Type: application/json' \
      -d '{"agent":"assistant-agent","query":"test","limit":3}' | python3 -m json.tool
    curl -sm 10 localhost:8003/agents | python3 -m json.tool
    </copy>
    ```

4. If database or memory checks fail, revisit the wallet, `AI_FOR_YOU` schema, and `MINILM_V2` model setup from Lab 1.

## Task 3: Run Tier 2 and Tier 3 Slack Validation

1. Run the automated Slack smoke test script.

    ```
    <copy>
    agents/data/venv/bin/python3 scripts/smoke_test.py
    </copy>
    ```

2. Validate each agent manually with the prompts printed by the smoke test: Ops Agent in `#ops`, Data Agent in `#data`, Brand Agent by DM, Publish Agent in `#publishing`, Assistant Agent by DM, Content Agent in `#content-runs`, and Creative Agent in `#creative-studio`.
3. Confirm Assistant Agent reminders and approval interactions are functioning.
4. Resolve channel-membership, Socket Mode, or token issues before continuing.

## Task 4: Execute One End-to-End Workflow

1. Submit a topic in `#content-start` and follow the Content Agent prompt to begin the run.
2. Progress through each workflow pause and approval checkpoint with `continue`, `edit`, `done`, or `approve` as requested in the active thread.
3. Trigger at least one Creative Agent asset revision, then approve the Brand Agent grade-gated content.
4. Confirm that the Content Agent hands the final item to the Publish Agent in `#publishing`, then run `publish <post-number>` to validate the configured delivery behavior.

## Task 5: Complete Final Status Validation

1. Send `status` to the Assistant Agent in a direct message.
2. Confirm the response reports all configured agents up and the database healthy. This exercises Assistant Agent routing, the Ops Agent aggregate health check, and the Data Agent database probe.
3. Capture verification evidence and record any follow-up actions.

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
