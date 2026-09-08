# Configure External Services

## Introduction

In this lab, you connect intake, voice, email, and publishing helpers for deployments that use external services. Google Drive delivery was configured in Lab 3 because it is required for this deployment.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

- Configure AI Staff Gmail and Calendar OAuth.
- Enable voice transcription support.
- Configure email delivery and publishing helpers.
- Recheck the platform after external services are enabled.

### Prerequisites

- Completion of Lab 4.
- Customer intake values for each external service you plan to enable.
- Access to the target Google account, email sender, and publishing accounts.

## Task 1: Configure Google OAuth for AI Staff

1. Use this task when AI Staff email or calendar workflows are enabled. Current email support is Gmail-only; do not configure Outlook, Yahoo, IMAP, or Microsoft Graph for this build.

2. In Google Cloud, create a small project and enable the Gmail API and Google Calendar API.

3. Configure the OAuth consent screen as External and Testing mode. Add the target mailbox as the test user.

4. Create an OAuth client ID and secret. Add them to `agents/aistaff/.env`.

    ```
    <copy>
    AISTAFF_GOOGLE_CLIENT_ID="<google-client-id>"
    AISTAFF_GOOGLE_CLIENT_SECRET="<google-client-secret>"
    </copy>
    ```

5. Run the headless consent flow from the instance.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    agents/aistaff/venv/bin/python agents/aistaff/setup_google.py
    chmod 600 agents/aistaff/.env
    sudo chcon -t etc_t agents/aistaff/.env
    </copy>
    ```

6. Confirm the script writes `AISTAFF_GOOGLE_REFRESH_TOKEN` to `agents/aistaff/.env`. Testing-mode tokens can require weekly re-consent; reapply the `etc_t` label after each reconnect.

## Task 2: Enable AI Staff Voice Support

1. Use this task when the deployment needs audio transcription. The current runtime uses `faster-whisper` through the AI Staff requirements and needs `ffmpeg`.

2. Confirm `ffmpeg` is installed from Lab 2.

    ```
    <copy>
    ffmpeg -version
    </copy>
    ```

3. Verify transcription with a small local audio file.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    agents/aistaff/venv/bin/python agents/aistaff/transcribe.py /path/to/sample.m4a
    </copy>
    ```

## Task 3: Configure Email and Publishing Helpers

1. Configure OCI Email Delivery when pause-reminder email is required. In OCI Console, create an approved sender and SMTP credentials, then add the values to `.env.shared`.

    ```
    <copy>
    SMTP_HOST="<smtp-host>"
    SMTP_PORT="587"
    SMTP_USER="<smtp-user>"
    SMTP_PASSWORD="<smtp-password>"
    SMTP_FROM="<approved-sender-email>"
    NOTIFY_EMAIL="<notification-recipient>"
    </copy>
    ```

2. Configure Substack only when the customer publishes to Substack. Substack uses a third-party MCP flow with local patches, so read the repository gotchas before enabling it. If its config file is absent, Publish Agent skips the Substack step.

3. Configure Instagram cookies only when Instagram intake is required. Store cookies outside the repository, for example `~/.config/myapp/cookies.txt`, because the file grants account access.

4. Leave Buffer parked unless the deployment explicitly requires manual Buffer scheduling.

## Task 4: Recheck External Services

1. Restart any services whose environment files changed.

    ```
    <copy>
    sudo systemctl restart contentkit-pipeline contentkit-assistant
    sudo systemctl restart aistaff-intake-watch.service || true
    </copy>
    ```

2. Confirm the core services are still healthy.

    ```
    <copy>
    curl -sm 15 localhost:8004/health-db
    curl -sm 10 localhost:8003/agents | python3 -m json.tool
    systemctl list-timers 'aistaff-*'
    </copy>
    ```

3. Run one workflow that exercises the external service you enabled, such as AI Staff email intake or voice transcription.

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
