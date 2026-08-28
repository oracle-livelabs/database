# Traceability Summary

Estimated Time: 5 minutes

## Source Classification

- Oracle-owned/internal sources: Oracle AI Database Private Agent Factory 26.7 public documentation.
- User-provided sources: Two screenshots of the Agent Builder node palette, used as reference only.
- External/non-Oracle sources: None.
- Unclear or mixed-ownership sources: None used in learner-facing content.
- Current-build source-owner approval required: No.
- Attribution or rights review needed: No.

## Embedded Asset Review

| Asset | Parent Source | Asset Type | Owner / Source Class | Used As | Approval / Attribution / Rights Notes |
| --- | --- | --- | --- | --- | --- |
| Processing-node palette screenshot | User attachment | Screenshot of Oracle product UI | User-provided / Oracle product UI | Reference only | Not copied into the workshop |
| Tools-node palette screenshot | User attachment | Screenshot of Oracle product UI | User-provided / Oracle product UI | Reference only | Not copied into the workshop |

The workshop includes no screenshots, diagrams, datasets, copied code, or other embedded assets.

## Source Traceability

| Workshop Area | Source | Owner / Source Class | Evidence Type | Used As | Approval / Attribution / Rights Notes |
| --- | --- | --- | --- | --- | --- |
| Custom Agent Builder workflows | [Agent Builder](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder.html) | Oracle-owned | Feature behavior | Summarized | Public Oracle documentation |
| Specialized agent nodes | [Agent Builder Components](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html) | Oracle-owned | Data Analysis Agent and Knowledge Agent behavior | Summarized | Public Oracle documentation |
| Data and processing nodes | [Agent Builder Components](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html) | Oracle-owned | Image Input, Read CSV, URL Crawler, Condition, Type Convert, Combine JSON Data, and Parser behavior | Summarized | Public Oracle documentation |
| Image workflow pattern | [Sample Flows with Agent Builder](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/create-agent.html) | Oracle-owned | Image Input and Vision Language Model flow | Summarized | Public Oracle documentation |
| Supporting database tools | [Agent Builder Components](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html) | Oracle-owned | Oracle Database and PL/SQL Executor behavior | Summarized | Public Oracle documentation |

## SME Validation Gaps

- EBS SMEs must approve the Data Analysis Agent objects, invoice-hold questions, curated views, and any supporting diagnostic routine.
- PeopleSoft SMEs must approve the policy knowledge base, crawlable lab URL, absence views, routing rules, and any supporting validation routine.
- JD Edwards EnterpriseOne SMEs must approve the image, CSV fields, inventory views, VLM prompt, processing mappings, and any reorder routine.
- Security reviewers must confirm that the URL Crawler reaches only approved public lab content.
- The JDE task author must account for Image Input configuration at design time rather than chat-time image upload.
- Database and application SMEs must confirm that supporting wrappers use approved interfaces or isolated demo logic.
- `oracle-db-skills` was unavailable during authoring. Oracle-specific implementation details require later technical validation.

## Attribution Notes

- All product claims come from public Oracle documentation.
- The user-provided screenshots serve only as reference evidence and do not appear in learner-facing content.
- This skeleton needs no third-party attribution or source-owner permission.
- Learner-facing content includes no private or confidential source details.

## Acknowledgements

* **Traceability Compiled By** - Kumar G. Varun, Lead Principal Product Manager
* **Last Updated By/Date** - Kumar G. Varun, August 28, 2026
