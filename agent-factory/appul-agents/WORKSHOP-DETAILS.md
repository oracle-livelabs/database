# Workshop Details

Estimated Time: 5 minutes

## Workshop Title

Build Enterprise Application Agents with Oracle AI Database Private Agent Factory

## Short Description

Build three custom enterprise application agents in Oracle AI Database Private Agent Factory. Reuse specialized agents and combine knowledge, structured data, images, files, processing nodes, database tools, and approved PL/SQL routines.

## Long Description

Enterprise application workflows rarely depend on one tool. They often need structured analysis, approved policy knowledge, multimodal input, and data transformation before an agent can answer or act.

This workshop shows three distinct custom-agent patterns. The EBS Payables lab embeds a Data Analysis Agent for invoice-hold analysis. The PeopleSoft lab combines a Knowledge Agent, URL Crawler, and routing nodes for policy-aware absence eligibility. The JD Edwards EnterpriseOne lab combines image analysis, CSV data, database results, and processing nodes for inventory replenishment. Oracle Database and PL/SQL tools support the business scenarios without becoming the main objective of every lab.

## Audience

- ERP application developers
- Oracle enterprise application technical administrators
- Database administrators familiar with SQL and PL/SQL
- Agent builders who need governed access to enterprise application data

## Workshop Outline

1. Introduction - Custom-agent composition patterns (10 minutes)
2. Lab 1 - EBS Payables analysis with a Data Analysis Agent (25 minutes)
3. Lab 2 - PeopleSoft policy grounding and conditional routing (25 minutes)
4. Lab 3 - JD Edwards multimodal inventory processing (30 minutes)

Estimated Workshop Time: 90 minutes

## Workshop Prerequisites

- A pre-provisioned Oracle AI Database Private Agent Factory 26.7 tenancy with supported text and vision models.
- Permissions to create, edit, save, and test custom workflows in Agent Builder.
- A published EBS Data Analysis Agent and a published PeopleSoft Knowledge Agent.
- A lab-provided public policy site that Agent Factory can reach without credentials.
- A lab-provided JDE inventory image and supplier CSV file.
- Saved demo database sources for EBS, PeopleSoft, and JD Edwards EnterpriseOne.
- Least-privilege read access to curated demo views.
- `EXECUTE` access to approved PL/SQL wrappers where the scenario uses them.

## Authoring Boundaries

- This draft includes two example task sections in each lab as a syntax reference.
- Application SMEs must approve all views, policies, URLs, images, CSV fields, wrapper routines, prompts, and expected outcomes.
- Detailed screenshots, production SQL, PL/SQL implementations, and Agent Spec exports remain excluded.
- All exercises must use demo data and approved content. Do not use production credentials or direct DML against application base tables.

## Acknowledgements

* **Author** - Kumar G. Varun, Lead Principal Product Manager
* **Last Updated By/Date** - Kumar G. Varun, August 28, 2026
