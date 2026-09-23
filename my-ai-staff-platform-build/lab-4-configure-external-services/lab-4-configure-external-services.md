# Lab 4: Configure External Services

## Introduction

In this lab, you configure Google OAuth and the external services used by My AI Staff. The runtime and Slack configuration were prepared in Lab 3; the complete service activation and end-to-end verification happen in Lab 5.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

- Configure AI Staff Gmail and Calendar OAuth.
- Configure the single Google Drive publication root for all new content.
- Configure Cloudflare Workers AI image generation.
- Enable voice transcription support.
- Configure email delivery and publishing helpers.

### Prerequisites

- Completion of Lab 3.
- Customer intake values for each external service you plan to enable.
- A personal Gmail account for the workshop OAuth flow. Do not use a corporate or customer-owned Google account.
- A Google Cloud project, Desktop OAuth client, and one approved Drive folder named `AI Staff Approved` for all published AI Staff artifacts.
- A Cloudflare account ID and API token when image generation is enabled.
- Access to the email sender and publishing accounts.

## Task 1: Configure Google OAuth for AI Staff

1. Use this task when AI Staff email or calendar workflows are enabled. Current email support is Gmail-only.

2. In [Google Cloud Console](https://console.cloud.google.com/), create a small project and enable the Gmail API, Google Calendar API, and Google Drive API. Sign in with the personal Gmail account selected for this workshop.

3. Configure the OAuth consent screen as External and Testing mode. Add the target mailbox as the test user.

4. Create or identify one Drive folder named `AI Staff Approved`. This is the only production Drive root; published posts, assets, receipts, and documents are stored below it. Create a Desktop OAuth client ID and secret, then create the protected integration file before adding the values:

    ```bash
    <copy>
    cd ~/livelabs-ai-staff
    install -d -m 700 agents/aistaff/integrations
    cp agents/aistaff/integrations/.env.example agents/aistaff/integrations/.env
    chmod 600 agents/aistaff/integrations/.env
    </copy>
    ```

    Edit `agents/aistaff/integrations/.env` and add the values:

    ```text
    <copy>
    AISTAFF_GOOGLE_CLIENT_ID="<google-client-id>"
    AISTAFF_GOOGLE_CLIENT_SECRET="<google-client-secret>"
    AISTAFF_DRIVE_ROOT_FOLDER_ID="<approved-published-folder-id>"
    </copy>
    ```

5. Run the headless consent flow from the instance.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    agents/aistaff/venv/bin/python agents/aistaff/integrations/setup_google.py
    chmod 700 agents/aistaff/integrations
    chmod 600 agents/aistaff/integrations/.env
    sudo chcon -t etc_t agents/aistaff/integrations/.env
    </copy>
    ```

6. Confirm the script writes `AISTAFF_GOOGLE_REFRESH_TOKEN` to `agents/aistaff/integrations/.env`. Testing-mode tokens can require weekly re-consent; reapply the `etc_t` label after each reconnect.

## Task 2: Configure Cloudflare Workers AI

1. Use this task when infographic, story, or other image-generation workflows are enabled. Cloudflare credentials belong in `.env.shared`, not in the Content Kit JSON.

    ```text
    CLOUDFLARE_ACCOUNT_ID=<cloudflare-account-id>
    CLOUDFLARE_API_TOKEN=<cloudflare-api-token>
    ```

2. Protect and label the shared environment file after adding the values:

    ```bash
    chmod 600 .env.shared
    sudo chcon -t etc_t .env.shared
    sudo restorecon -v .env.shared
    ```


## Task 4: Validate the External-Service Handoff

1. Validate the external configuration before activating services.

    ```
    <copy>
    python3 scripts/validate_config.py --env-only
    </copy>
    ```

    Do not activate or restart the platform services yet. Lab 5 performs activation after all external configuration is complete.

2. Confirm the protected Google integration file and, when image generation is enabled, the shared Cloudflare values exist without printing their contents.

    ```
    <copy>
    test -f agents/aistaff/integrations/.env
    test "$(stat -c '%a' agents/aistaff/integrations/.env)" = "600"
    if grep -Eq '^CLOUDFLARE_(ACCOUNT_ID|API_TOKEN)=[^[:space:]]' .env.shared; then
      grep -Eq '^CLOUDFLARE_ACCOUNT_ID=[^[:space:]]' .env.shared
      grep -Eq '^CLOUDFLARE_API_TOKEN=[^[:space:]]' .env.shared
    fi
    </copy>
    ```

3. Continue directly to Lab 5: Connect Services and Verify the Deployment.

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
