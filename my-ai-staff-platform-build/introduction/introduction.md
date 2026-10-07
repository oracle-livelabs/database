# Introduction

## About this Workshop

In this workshop, you deploy My AI Staff, a multi-agent AI operations platform on Oracle Cloud Infrastructure (OCI). You provision OCI resources, configure Autonomous AI Database 26ai and vector embeddings, install the runtime, configure Slack workflows, connect Google Drive delivery, secure and run services with systemd, complete an end-to-end verification, and connect external intake services.

Use generic bot identities for every deployment: Assistant Agent, Content Agent, Creative Agent, Brand Agent, Data Agent, Ops Agent, and Publish Agent.

Estimated Workshop Time: 120 minutes

![Example image](./images/livelabs-ai-staff-image.png)

### Objectives

In this workshop, you will:

- Provision OCI compute, networking, and Autonomous Database 26ai for the platform.
- Configure the `AI_FOR_YOU` application schema and load an in-database ONNX embedding model.
- Configure runtime services, secure environment files, and seven Slack agent integrations.
- Configure required Google Drive delivery with OAuth.
- Run layered verification and execute one complete Slack-driven content workflow.
- Enable AI Staff Gmail and Calendar, voice transcription, and email reminders when those services are part of the deployment.

### Prerequisites

This workshop assumes you have:

- Access to an OCI tenancy with permissions to create Compute, VCN ingress rules, and Autonomous Database resources.
- A laptop or desktop with a current web browser, an SSH client, and a way to edit remote files. [Visual Studio Code](https://code.visualstudio.com/Download) with the [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) is recommended; any equivalent editor and OpenSSH client are also supported. Lab 1 explains when to create or download the SSH key and configure the connection, after the instance receives its public IP.
- `scp` (included with OpenSSH) or an equivalent browser upload method for transferring the database wallet after the instance is reachable.
- Access to create and configure a Slack workspace, channels, and apps.
- An OpenAI account or subscription.
- A personal Gmail account with [Google Cloud Platform](https://cloud.google.com) Access and a personal [Slack](https://slack.com) account/workspace for this workshop. Do not use a corporate or customer-owned account for the workshop identities or OAuth consent flow.
- Basic Linux administration and shell-command familiarity.
- Basic familiarity with OCI networking and Oracle Autonomous Database.

The OCI Console and SQL Developer Web are browser-based. Commands in the lab code blocks run on the OCI instance unless the step explicitly says **on your laptop**. The instance needs outbound HTTPS/DNS access to download the platform ZIP and install packages.

## Deployment Values Checklist

Before you start, create a secure worksheet for values that are unique to the customer deployment. Never copy these values between customers.

| Category | Values to capture |
| --- | --- |
| Customer intake | Business name, owner email, owner timezone, delivery targets, and enabled external integrations |
| OCI | Tenancy access, region, compute public IP, Autonomous Database name, ADMIN password, `AI_FOR_YOU` password, wallet zip, and wallet directory |
| Slack | Workspace name, seven bot tokens, seven app-level tokens, `ASSISTANT_BOT_ID`, deployment owner member ID, and every channel ID |
| Runtime | Codex account or API key, OpenAI API key, `CODEX_BIN` path when non-default, ZIP download URL, and deployment path |
| Content Kit | `base_dir`, Python, font paths, Data Agent URL, and headshot path |
| External services | Google OAuth client ID, secret, refresh token, publication Drive folder and Substack config |

## Choose a Deployment Path

Choose one deployment path before starting the numbered labs. Do not run both
paths on the same host.

**Manual path:** Lab 1 → Lab 2 → Lab 3 → Lab 4 → Lab 5

**Fast path:** Fast Path: Click the Magic Button → Lab 3 → Lab 4 → Lab 5

The Fast Path replaces the non-interactive work in Labs 1 and 2. It provisions
OCI, Autonomous Database, the platform files, the local Codex plugin, labeled
virtual environments, the application schema, the vector model, and the base
systemd unit files. Lab 3 is still required because Slack apps, tokens,
channels, and environment values are deployment-specific. Lab 4 configures
Google OAuth and the other external services; Lab 5 activates and verifies the
complete deployment.

The Fast Path has been created if you have already used your Always Free Resources in your OCI Account.

## Workshop Labs

1. Lab 1: Prepare OCI Infrastructure and Database (manual path)
2. Lab 2: Install the My AI Staff Runtime (manual path)
3. Lab 3: Configure Slack Agents, Environment Files, and Services
4. Lab 4: Configure External Services
5. Lab 5: Connect Services and Verify the Deployment

## Acknowledgements

- Contributor: Cyrca Salinas Rojas
- Last Updated By/Date: Cyrce Salinas Rojas, August 2026