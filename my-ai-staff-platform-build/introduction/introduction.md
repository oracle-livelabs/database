# Introduction

## About this Workshop

In this workshop, you deploy My AI Staff, a multi-agent AI operations platform on Oracle Cloud Infrastructure (OCI). You provision OCI resources, configure Autonomous AI Database 26ai and vector embeddings, install the runtime, configure Slack workflows, secure and run services with systemd, and complete an end-to-end verification.

Use generic bot identities for every deployment: Assistant Agent, Content Agent, Creative Agent, Brand Agent, Data Agent, Ops Agent, and Publish Agent. Define their `*_BOT_NAME` values centrally in `.env.shared`; each runtime configuration loads that shared file before its agent-specific `.env`. Website Agent is an HTTP-only intake service and does not use a Slack app.

Estimated Workshop Time: 270 minutes

### Objectives

In this workshop, you will:

- Provision OCI compute, networking, DNS, and Autonomous Database 26ai for the platform.
- Configure the AI_FOR_YOU application schema and load an in-database ONNX embedding model.
- Configure runtime services, secure environment files, and seven Slack agent integrations.
- Run layered verification and execute one complete Slack-driven content workflow.

### Prerequisites

This workshop assumes you have:

- Access to an OCI tenancy with permissions to create Compute, VCN ingress rules, and Autonomous Database resources.
- Access to a domain registrar to add an A record for the editor endpoint.
- Access to create and configure a Slack workspace, channels, and apps.
- Basic Linux administration and shell-command familiarity.
- Basic familiarity with OCI networking and Oracle Autonomous Database.

## Workshop Labs

1. Lab 1: Prepare OCI Infrastructure and Database
2. Lab 2: Install the My AI Staff Runtime
3. Lab 3: Configure Slack Agents, Environment Files, and Services
4. Lab 4: Connect Services and Verify the Deployment

## Acknowledgements

- Contributor: CYRCE SALINAS ROJAS
- Last Updated By/Date: CYRCE SALINAS ROJAS, August 2026
