# Connect Services and Verify the Deployment

## Introduction

In this lab, you finalize optional service integrations and perform layered verification to confirm the platform is production-ready. You will execute health checks, Slack smoke tests, manual validation, and one complete end-to-end run.

Estimated Time: 60 minutes

### Objectives

In this lab, you will:

- Configure optional external integrations where required.
- Validate service and database health endpoints.
- Execute automated and manual Slack validation.
- Complete one end-to-end workflow from topic intake to publish.
- Confirm final platform status is healthy.

### Prerequisites

- Completion of Lab 2.
- Active runtime services.
- Access to Slack workspace and channels configured in Lab 2.

## Task 1: Configure Optional External Integrations

1. Configure Google Drive integration through rclone if Drive delivery is required.
2. Configure Google OAuth for Gmail and Calendar if assistant integrations are required.
3. Configure optional email delivery and voice transcription integrations as needed.
4. Validate each optional integration before moving to full verification.

## Task 2: Run Tier 1 Platform Health Checks

1. Validate that all systemd services are active.
2. Check all core /health endpoints.
3. Validate database health from data-agent endpoint.

    ```
    <copy>
    for p in 8002 8003 8004 8005; do curl -sm 5 localhost:$p/health; echo " :$p"; done
    curl -sm 15 localhost:8004/health-db
    </copy>
    ```

4. If database checks fail, revisit ONNX model and schema setup from Lab 1.

## Task 3: Run Tier 2 and Tier 3 Slack Validation

1. Run the automated Slack smoke test script.

    ```
    <copy>
    agents/ops/venv/bin/python3 scripts/smoke_test.py
    </copy>
    ```

2. Validate each agent manually by sending expected test prompts to the mapped channels.
3. Confirm assistant reminders and approval interactions are functioning.
4. Resolve channel-membership or token issues before continuing.

## Task 4: Execute One End-to-End Workflow

1. Submit a topic in the content-start channel.
2. Progress through each workflow pause and approval checkpoint.
3. Trigger at least one revision and then approve final publish.
4. Confirm final content publication and delivery behavior.

## Task 5: Complete Final Status Validation

1. Send status command to assistant-agent in direct message.
2. Confirm the response reports all agents up and database healthy.
3. Capture verification evidence and record any follow-up actions.

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
