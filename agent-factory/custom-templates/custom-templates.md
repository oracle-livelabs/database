# Agents Built from Custom Templates

## Introduction

Agent Factory provides a number of templates to quickly create sophisticated AI Agents with minimal configuration. In this lab, you explore the template gallery to learn about agent templates and use (marketsync/pdf-to-blog) template to create your own agent. 

**Estimated time:** 10 minutes.

### Objectives

By the end of this lab, you will be able to:

- Explore the Template Gallery 
- Import and configure <> template to create your customized agent in Agent Builder

### Prerequisites

* same as previous lab (tbd)

## Task 1: Explore templates Agent Factory Template Gallery

## Task 2: Import Template
* PDF-to-Blog Converter Template

## Task 3: Understand Agent Builder Interface 

## Task 4: Configure your Agent in Agent Builder

## Task 5: Test Agent in Playground and Publish

## Task 6: Talk to your production agent

The Template Gallery offers a curated collection of pre-built agentic templates designed to help you get started quickly with intelligent automation.

Templates may include workflows for tasks such as document summarization, meeting note extraction, content transformation, and more. You can browse, search, and import any template that fits your needs, customizing them as needed with minimal configuration.

![Main dashboard of Oracle AI Database Private Agent Factory with the left navigation panel expanded. The Template Gallery option under the Studio section is highlighted, and the Get Started page is displayed with pre-built agent options and a quick start guide on the right.](images/get_started_template_gallery.png)

1. Open Oracle AI Database Private Agent Factory and log in. In the sidebar, click **Template Gallery**.

    ![Template Gallery screen displaying a list of template options, each with a description, last updated date, and an 'Import Flow' button. Templates include Draft Release Notes Generator, PDF to Blog Converter, Meeting Summary Item Extractor, Recruitment Optimizer, and Generate Product Pitch.](images/template_gallery.png)

    Here you will find all prebuilt workflows currently offered by Oracle AI Database Private Agent Factory.

2. For this tutorial, we will use the "PDF to Blog Converter" as an example, but you are encouraged to explore other templates based on your needs. Select a template to continue.

    ![Agent Builder workflow for a pdf-to-blog converter, showing nodes for File Upload, Prompt, Vllm (language model), Chat Input, and Chat Output connected in sequence. The File Upload and Chat Input nodes feed into the Prompt node, which sends its output to the Vllm node, and finally to the Chat Output node. Node configuration panels and connection points are visible.](images/pdf-to-blog.png)

3. The prebuilt workflow will be displayed and can be customized using a simple drag-and-drop interface, no code required. To help identify the workflow, you can change its name in the top right corner of the canvas. For this example, type a name such as “Blog Post Generator” or another descriptive name of your choice.

    ![Edit Details modal dialog open in Agent Builder, showing fields to edit the name and description of the custom flow. The background displays the workflow editor with nodes and connections, while the modal has options to cancel or save changes.](images/edit_details.png)

4. When you import a new workflow, make sure to select your desired LLM provider. You can add different LLM providers on the LLM management section.

    ![Agent Builder workflow for pdf-to-blog showing a dropdown menu with an option labeled as OCI_LLM (oci).](images/select_LLM.png)

5. Some templates are designed to process files as inputs, such as PDF files. If the template requires it, use the **Upload File** function to select your file.

    ![Agent Builder workflow showing the File Upload node's, with a PDF file highlighted. The workflow connects File Upload and Chat Input nodes to a Prompt node, which links to an OCI Agent node and then to a Chat Output node.](images/select_placeholder.png)

    You are also able modify the workflow components to suit your needs. For instance, you can remove a node by selecting it and pressing Delete, and you can add a new node by dragging it from the palette and configuring it as needed.

6. Click **Save** and then **Publish** to deploy your customized workflow.

    ![Publish Workflow confirmation dialog open in Agent Builder, asking the user to confirm publishing the '23ai Database New Features' workflow. The dialog has Cancel and Confirm buttons, overlaying the workflow editor with connected nodes for File Upload, Prompt, OCI Agent, and Chat Output.](images/publish_workflow.png)

## Task 2: Interact with the created workflow

After publishing the workflow, go to your workflow gallery. In the sidebar, click **My Custom Workflows**.

![My custom workflows screen displaying a search bar and a card for the 23ai Database New Features workflow, which contains a description, a label indicating it has been published and the last updated date. Buttons for delete, edit and run the workflow appears at the bottom.](images/custom_flows.png)

Select your workflow from the gallery. Here, you can edit, delete, or run your custom workflows. To proceed, click **Run Flow**.

![23ai Database New Features Chat screen with tabs for messages and chat history. The main chat area displays the prompt 'Star using your custom flow' with a message input field at the bottom containing 'How can I help you?'.](images/pdf_to_blog_chat_ui.png)

Interact with your workflow through the chat interface. Example query prompts will depend on your data source contents. For example, if your document is a product release guide, you could ask about new features described within. The workflow will provide responses based only on the information it has processed from your chosen file.

![Chat interface foe the '23ai Database New Features' custom workflow showing a user asking about the new data type added in Oracle Database 23ai and a response from the custom Flow answering the question. The main area displays messages and responses, with chat input available at the bottom.](images/pdf_to_blog_qa.png)


## Acknowledgements

- **Authors** 
* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026
