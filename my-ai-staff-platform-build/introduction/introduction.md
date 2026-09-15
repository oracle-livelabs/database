# Introduction

## About this Workshop

In this workshop, you deploy My AI Staff, a multi-agent AI operations platform on Oracle Cloud Infrastructure (OCI). You provision OCI resources, configure Autonomous AI Database 26ai and vector embeddings, install the runtime, configure Slack workflows, connect Google Drive delivery, secure and run services with systemd, complete an end-to-end verification, and connect external intake services.

Use generic bot identities for every deployment: Assistant Agent, Content Agent, Creative Agent, Brand Agent, Data Agent, Ops Agent, and Publish Agent. Define their `*_BOT_NAME` values centrally in `.env.shared`; each runtime configuration loads that shared file before its agent-specific `.env`. Website Agent is an HTTP-only intake service and does not use a Slack app.

Estimated Workshop Time: 315 minutes

### Objectives

In this workshop, you will:

- Provision OCI compute, networking, and Autonomous Database 26ai for the platform.
- Configure the AI_FOR_YOU application schema and load an in-database ONNX embedding model.
- Configure runtime services, secure environment files, and seven Slack agent integrations.
- Configure required Google Drive delivery with rclone.
- Run layered verification and execute one complete Slack-driven content workflow.
- Enable AI Staff Gmail and Calendar, voice transcription, and email reminders when those services are part of the deployment.

### Prerequisites

This workshop assumes you have:

- Access to an OCI tenancy with permissions to create Compute, VCN ingress rules, and Autonomous Database resources.
- Access to create and configure a Slack workspace, channels, and apps.
- Basic Linux administration and shell-command familiarity.
- Basic familiarity with OCI networking and Oracle Autonomous Database.

## Deployment Values Checklist

Before you start, create a secure worksheet for values that are unique to the customer deployment. Never copy these values between customers.

| Category | Values to capture |
| --- | --- |
| Customer intake | Business name, owner email, owner timezone, delivery targets, and enabled external integrations |
| OCI | Tenancy access, region, compute public IP, Autonomous Database name, ADMIN password, `AI FOR YOU` password, wallet zip, and wallet directory |
| Slack | Workspace name, seven bot tokens, seven app-level tokens, `ASSISTANT_BOT_ID`, deployment owner member ID, and every channel ID |
| Runtime | Codex account or API key, `CODEX_BIN` path when non-default, repository URL, and deployment path |
| Content Kit | `base_dir`, NotebookLM Python path, font paths, Data Agent URL, headshot path, rclone remote, and Google Drive folder ID |
| External services | Google OAuth client ID and secret, Google refresh token, SMTP host/user/password/from address, Substack config, and Instagram cookies when those integrations are enabled |

## Workshop Labs

1. Lab 1: Prepare OCI Infrastructure and Database
2. Lab 2: Install the My AI Staff Runtime
3. Lab 3: Configure Slack Agents, Environment Files, and Services
4. Lab 4: Connect Services and Verify the Deployment
5. Lab 5: Configure External Services

## Acknowledgements

- Contributor: CYRCE SALINAS ROJAS
- Last Updated By/Date: CYRCE SALINAS ROJAS, August 2026
