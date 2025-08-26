# Create Loan Application Processing Workflow

## Introduction

This lab walks you through the steps to create a workflow for a loan processing application.

**Note**: A complete workflow is already available in MicroTx Workflow on your remote desktop. You can use this workflow as a reference. To directly run the workflow, jump to the next lab and skip this lab.

In this lab, you will understand the various building blocks of the workflow, such as tasks, prompts, and agent profile. You will also build a few of these blocks. In this lab, you will add multiple tasks in a step-by-step manner. Each task accomplishes a specific goal. This workflow accepts user input in natural language.

Estimated Lab Time: 30 minutes

### About <Product/Technology> (Optional)
Enter background information here about the technology/feature or product used in this lab - no need to repeat what you covered in the introduction. Keep this section fairly concise. If you find yourself needing more than two sections/paragraphs, please utilize the "Learn More" section.

### Objectives

*List objectives for this lab using the format below*

In this lab, you will:
* Objective 1
* Objective 2
* Objective 3

### Prerequisites (Optional)

*List the prerequisites for this lab using the format below. Fill in whatever knowledge, accounts, etc. is necessary to complete the lab. Do NOT list each previous lab as a prerequisite.*

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed


*This is the "fold" - below items are collapsed by default*

## Task 1: Create a New Workflow

1. Open the navigation menu and click **Definitions**.

2. Click the **Workflow** tab.

	 ![New Workflow Definition](images/sample1.png)

3. Click **New Workflow Definition**.
   A JSON file is displayed, which is the default workflow in the left pane. In the right pane, the components of the workflow are depicted visually.
	 ![Default Workflow Definition](images/sample1.png)

4. Delete the JSON code that appears by default and paste the following code.

  	```
    <copy>
    {
     "name": "acme_bank_loan_processing_workflow",
     "description": "Acme bank Loan processing workflow with multi agent orchestration",
     "tasks": []
    }
    </copy>
    ```
5. Click **Save**.

## Task 2: Extract loan application details

The workflow accepts user input in natural language. Use a GenAI task type to extract the loan application details from the input provided by a user. Since a GenAI task requires LLM, let's start by creating a connector for accessing the LLM.

1. Open the navigation menu and click **Connectors**.

2. Click the **LLM** tab.

3. Click **New LLM Definition**. The **New LLM Definition** dialog box appears.

4. Enter the following information.

    * Name: Enter openaai-dev as a unique and descriptive name to identify this LLM definition in workflows.
    * Model Provider: Select OPENAI as the model provider.
    * Models: Enter gpt-4o, gpt-4o-mini as a comma-separated list of the names of the models which you intend to use.
    * Description: Enter a description for the LLM definition.
    * API Key: Paste your OpenAI API key, which authenticates your requests.
    * Base URL: Enter https://api.openai.com/ as the URL to access the API endpoint of the LLM.

	 ![New LLM Definition](images/openai-llm-connector.png)

5. Click **Submit**.
    Your new definition appears in the list of available LLM definitions.

6. 

(optional) Task 1 opening paragraph.

1. Step 1

	![Image alt text](images/sample1.png)

2. Step 2

  ![Image alt text](images/sample1.png)

4. Example with inline navigation icon ![Image alt text](images/sample2.png) click **Navigation**.

5. Example with bold **text**.

   If you add another paragraph, add 3 spaces before the line.

## Task 2: Concise Task Description

1. Step 1 - tables sample

  Use tables sparingly:

  | Column 1 | Column 2 | Column 3 |
  | --- | --- | --- |
  | 1 | Some text or a link | More text  |
  | 2 |Some text or a link | More text |
  | 3 | Some text or a link | More text |

2. You can also include bulleted lists - make sure to indent 4 spaces:

    - List item 1
    - List item 2

3. Code examples

    ```
    Adding code examples
  	Indentation is important for the code example to appear inside the step
    Multiple lines of code
  	<copy>Enclose the text you want to copy in <copy></copy>.</copy>
    ```

4. Code examples that include variables

	```
  <copy>ssh -i <ssh-key-file></copy>
  ```

## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>
