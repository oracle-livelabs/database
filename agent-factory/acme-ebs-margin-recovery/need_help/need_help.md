# Need Help?

## Introduction

Use this section if you get stuck while running the ACME EBS margin recovery LiveLab or want follow-up resources for Oracle AI Database Private Agent Factory.

**Estimated Time:** 3 minutes.

### Objectives

- Learn where to find Private Agent Factory documentation and downloads.
- Know what to check if the workshop environment is missing assets.
- Understand what to report to the instructor or support team.

### Prerequisites

- None.

## Task 1: Check the Product Documentation

The product documentation is available in the [Oracle AI Database Private Agent Factory User's Guide](https://docs.oracle.com/en/database/oracle/agent-factory/25.3/paias/introduction.html).

Use the documentation for product concepts, installation details, model configuration, Knowledge Agents, Data Analysis agents, Agent Builder flows, and source management.

## Task 2: Check the Workshop Assets

If a lab step does not match your environment, first confirm these assets exist in Private Agent Factory:

- Database source: **ACME EBS AI Database**
- REST source: **ACME EBS Action Service**
- MCP source: **ACME Oracle AI Database MCP Server**
- Data Analysis agents: **ACME Margin Full Agent**, **ACME Contract Exception Packet Agent**, **ACME Order Contract Context Agent**, and **ACME Margin Recovery Candidate Agent**
- Contract source: **ACME Contract CONTRACT ID 1111 ACME Northstar Master Agreement**
- Policy sources: **ACME Policy Revenue Contract Review** and **ACME Policy Commercial Recovery**

If these assets are missing, ask the instructor to refresh the Resource Manager stack with the latest workshop package.

## Task 3: Capture Useful Troubleshooting Details

If you need help, capture:

- The Private Agent Factory URL.
- The lab and task number.
- The exact source, agent, or REST operation you were using.
- The prompt you ran.
- Any visible error message.
- Whether `listActionAudit` shows `margin_notes`, `revenue_exceptions`, `margin_recovery_cases`, and `audit`.

This information helps the instructor distinguish a workshop-content issue from an environment setup issue.

## Task 4: Download or Deploy Private Agent Factory

You can find the official installation kit at [Get Oracle AI Database Private Agent Factory](https://www.oracle.com/database/technologies/private-agent-factory-downloads.html#).

You can also review the [Oracle AI Database Private Agent Factory Marketplace listing](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/201588705) for deployment in your own tenancy.

## Acknowledgements

**Authors**

- Database Applied AI Technical Staff
- Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - June, 2026
