# Oracle AI Database -- AI Capabilities Deep-Dive Tutorial and Workshop

<br><span style="font-size: 25px; text-align: left;"><strong>About this Workshop</strong></span>

<span style="font-size: 22px; text-align: left;"><strong>Prerequisites</strong></span>
* Basic Linux, Python and SQL knowledge

Generative Artificial Intelligence (AI) excels at creating text responses based on large language models (LLMs) where the AI is trained on a massive number of data points. The good news is that the generated text is often easy to read and provides detailed responses that are broadly applicable to the questions asked of the software, often called prompts.

The bad news is that the information used to generate the response is limited to the information used to train the AI, often a generalized LLM. The LLM’s data may be weeks, months, or years out of date and in a corporate AI chatbot may not include specific information about the organization’s products or services. That can lead to incorrect responses that erode confidence in the technology among customers and employees.

That’s where retrieval-augmented generation (RAG) comes in. RAG provides a way to optimize the output of an LLM with targeted information without modifying the underlying model itself; that targeted information can be more up to date than the LLM as well as specific to a particular organization and industry. That means the generative AI system can provide more contextually appropriate answers to prompts as well as base those answers on extremely current data.


This Livelab workshop walks through the tools within the Oracle AI Database, AI Vector Search and Select AI to enable you to develop the building blocks of a RAG infrastructure.  You will be using the associated jupyter notebook to create the python and SQL to used to create your own infrastructure. It consists of "markdown" that overviews the capabilities and then presents live Python and SQL code that you can examine and execute.  The workshop leader can take unstructured documents (pdfs, emails, html, etc.) that you would like to use in the workshop and load them into object storage ahead of time.  You will be able to follow them, live, through the workshop.

The workshop is intended for application developers who will learn the basics of AI Vector Search and Select AI from the Python and SQL coding perspective. This workshop highlights the capabilities of the Oracle Machine Learning for Python ('OML4Py') tools.

By the end of this lab, you will have:
- Stored, chunked, and vectorized your documents.
- Used a Large Language Model (LLM) to generate a precise answer to a query you enter based on relevant context stored in Oracle AI database.
- See the diagram below what you will be learning.

<p style="font-family: Arial, sans-serif; font-size: 20px; text-align: left;color:blue;"><strong>Throughout this tutorial we will be leveraging Jupyter Notebook to explore Oracle Database AI capabilities.</strong></p>

<p style="font-family: Arial, sans-serif; font-size: 20px; text-align: left;color:blue;">As you proceed through the workshop, 'blue' text will be your indicator to switch to the browser and follow those instructions in the jupyter notebook.</p> 

If you are unfamiliar with notebooks here are a few tips to get started:

- Instructions and code will be mixed together, each having their own blocks. You can use the run button on the code to see it execute. If you accidently hit run on any instructions, it will just move to the next block so don't worry.
- When running a code block it will switch from either a [ ] or a [1] (a number inside) to a [*]. When you see the one with a * that means its running. Wait till it switches to a number before moving on.
- If you see any warnings, don't worry, they are probably just letting you know that things are changing, depreciating and you should look at updating to the latest standards. You don't need to do anything.

 
 ![rag image](images\overview.png " ")

**_Estimated Time: 10 Minutes_**

## About Oracle AI Vector Search

Oracle AI Vector Search is a feature of Oracle Database 26ai that enables efficient searching of AI-generated vectors stored in the database. It supports fast search using various indexing strategies and can handle massive amounts of vector data. This makes it possible for Large Language Models (LLMs) to query private business data using a natural language interface, helping them provide more accurate and relevant results. Additionally, AI Vector Search allows developers to easily add semantic search capabilities to both new and existing applications.

## About Select AI

Select AI generates natural language to interact with your database and LLMs through SQL to enhance user productivity and develop AI-based applications. Select AI simplifies and automates using generative AI, whether generating, running, and explaining SQL from a natural language prompt, using retrieval augmented generation with vector stores, generating synthetic data, or chatting with the LLM.

You may now **proceed to the next lab**

## Acknowledgements
**Author** - Gary McKoy, Master Principal Solution Architect, Data Platform Infrastructure, NACI <br>

**Contributors** 
- Eileen Beck, Cloud Solution Engineer, Data Platform Infrastructure, NACI 
- Sania Bolla, Cloud Solution Engineer, Data Platform Infrastructure, NACI 
- Abby Mulry, Cloud Solution Engineer, Data Platform Infrastructure, NACI 
- Richard Piantini Cid, Cloud Solution Engineer, Data Platform Infrastructure, NACI <br>

**Last Updated By/Date** -  Gary McKoy, March 2026