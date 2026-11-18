# Build a JD Edwards Inventory Agent

## Introduction

JD Edwards EnterpriseOne inventory planning can draw on more than database quantities. A planner may also need a visual inspection, supplier lead-time data, and a structured summary. In this lab, you will combine a lab image, a CSV file, and curated inventory results in one custom workflow.

Image Input and a Vision Language Model will describe the configured inventory image. Read CSV will load supplier data. Type Convert, Combine JSON Data, and Parser will prepare the inputs for the agent. An approved PL/SQL wrapper can provide a final reorder calculation, but multimodal data processing is the main lesson.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

- Analyze a lab-provided inventory image with Image Input and a Vision Language Model.
- Load supplier or lead-time data with Read CSV.
- Query curated branch/plant inventory data through an Oracle Database tool.
- Normalize and merge outputs with Type Convert and Combine JSON Data.
- Format the combined context with Parser before the agent recommends an action.
- Use a PL/SQL reorder routine only as an optional final calculation.

### Prerequisites

This lab assumes you have:

- Access to Oracle AI Database Private Agent Factory 26.7 with a vision-capable model.
- Permission to create and test custom Agent Builder workflows.
- A lab-provided inventory image in a supported format.
- A lab-provided CSV file with approved demo supplier or lead-time fields.
- A saved JDE demo source with read access to curated branch/plant inventory views.
- Optional `EXECUTE` access to an SME-approved reorder wrapper.
- JD Edwards SME confirmation of the image, CSV fields, objects, mappings, and expected results.

## Task 1: Assemble Multimodal Inventory Context

1. Add Image Input and Vision Language Model nodes, then configure the lab image.

2. Add Read CSV and select the lab-provided supplier file.

3. Add the Oracle Database tool for curated branch/plant inventory data.

4. Use Type Convert and Combine JSON Data to normalize and merge the three inputs.

5. Use Parser to create a readable inventory context for the custom agent.

    > **Note:** Image Input uses an image selected by the workflow builder. It does not accept a new image from the chat user at runtime.

## Task 2: Test the Replenishment Recommendation

1. Save the workflow and open it in the Agent Builder playground.

2. Submit a replenishment prompt using this syntax:

    ```
    <copy>Use the inspection, supplier, and branch/plant data to recommend the next action for item [item number].</copy>
    ```

3. Verify that the response uses evidence from the image, CSV file, and database result.

4. If configured, confirm that the approved PL/SQL routine supplies only the final reorder calculation.

## Learn More

- [Image Input, Read CSV, and Processing Nodes](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html)
- [Image Analysis with a Vision Language Model](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/create-agent.html)
- [Agent Builder](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder.html)

## Acknowledgements

* **Author** - Kumar G. Varun, Lead Principal Product Manager
* **Contributors** - JD Edwards EnterpriseOne SME, TODO
* **Last Updated By/Date** - Kumar G. Varun, August 28, 2026
* **Source** - [Oracle AI Database Private Agent Factory 26.7 Agent Builder Components](https://docs.oracle.com/en/database/oracle/agent-factory/26.7/paias/agent-builder-components.html)
