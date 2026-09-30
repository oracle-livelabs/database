# Build Enterprise Application Agents with Oracle AI Database Private Agent Factory

## Introduction

Enterprise application teams need agents that can work with many kinds of information. A useful workflow may analyze database records, consult approved policy content, inspect an image, or combine several structured outputs. Oracle AI Database Private Agent Factory provides reusable specialized agents, data nodes, processing nodes, and governed tools for these patterns.

In this workshop, you will build three custom agents for Oracle E-Business Suite, Oracle PeopleSoft, and Oracle JD Edwards EnterpriseOne. Each lab highlights a different Agent Builder capability. Saved database connections and approved PL/SQL wrappers remain available as supporting tools, but they are not the primary learning objective in every lab.

Estimated Workshop Time: 90 minutes

### Objectives

In this workshop, you will:

- Build custom workflows that reuse specialized agents, data sources, processing nodes, and governed tools.
- Use a Data Analysis Agent inside an EBS Payables custom agent.
- Combine a Knowledge Agent, URL Crawler, and routing nodes for a PeopleSoft policy scenario.
- Process image, CSV, and database inputs in a JD Edwards inventory workflow.
- Apply least-privilege database access and expose PL/SQL wrappers only when a business step requires them.
- Compare structured analysis, grounded knowledge, multimodal input, and data-processing patterns.

### Prerequisites

This workshop assumes you have:

- Access to a pre-provisioned Oracle AI Database Private Agent Factory 26.7 tenancy with supported text and vision models.
- Permission to create, edit, save, and test custom workflows in Agent Builder.
- A published Data Analysis Agent configured for the EBS demo data.
- A published Knowledge Agent configured with approved PeopleSoft policy content.
- Access to a lab-provided public policy site for the URL Crawler.
- A lab-provided JDE inventory image and sample supplier CSV file.
- Saved demo database sources for Oracle E-Business Suite, Oracle PeopleSoft, and Oracle JD Edwards EnterpriseOne.
- Read access to curated demo views and `EXECUTE` access to any approved supporting PL/SQL wrappers.

> **Note:** Use only lab-provided data, knowledge sources, files, images, and wrapper routines. Do not connect these draft exercises to production application schemas.

## Learn More

- [Introduction to Agent Factory](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/introduction.html)
- [Agent Builder](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder.html)
- [Agent Builder Components](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html)
- [Sample Flows with Agent Builder](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/create-agent.html)

## Acknowledgements

* **Author** - Kumar G. Varun, Lead Principal Product Manager
* **Last Updated By/Date** - Kumar G. Varun, August 28, 2026
* **Source** - [Oracle AI Database Private Agent Factory 26.7 Agent Factory User Guide](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/)
