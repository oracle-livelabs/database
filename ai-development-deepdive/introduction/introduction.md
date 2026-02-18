# Oracle AI Database -- AI Capabilities Deep-Dive Workshop

## **About this Workshop**

Generative Artificial Intelligence (AI) excels at creating text responses based on large language models (LLMs) where the AI is trained on a massive number of data points. The good news is that the generated text is often easy to read and provides detailed responses that are broadly applicable to the questions asked of the software, often called prompts.

The bad news is that the information used to generate the response is limited to the information used to train the AI, often a generalized LLM. The LLM’s data may be weeks, months, or years out of date and in a corporate AI chatbot may not include specific information about the organization’s products or services. That can lead to incorrect responses that erode confidence in the technology among customers and employees.

That’s where retrieval-augmented generation (RAG) comes in. RAG provides a way to optimize the output of an LLM with targeted information without modifying the underlying model itself; that targeted information can be more up-to-date than the LLM as well as specific to a particular organization and industry. That means the generative AI system can provide more contextually appropriate answers to prompts as well as base those answers on extremely current data.


This Livelab workshop walks through the tools within the Oracle AI Database, AI Vector Search and Select AI to enable you to develope the building blocks of a RAG infrastructure.  You will be using the associated jupyter notebook to create the python and SQL to used to create your own infrastructure. It consists of "markdown" that overviews the capabilities and then presents live Python and SQL code that you can examine and execute.  The workshop leader can take unstructured documents (pdfs, emails, html, etc.) that you would like to use in the workshop and load them into object storage ahead of time.  You will be able to follow them, live, through the workshop.

The workshop is intended for application developers who will learn the basics of AI Vector Search and Select AI from the Python and SQL coding perspective. This workshop highlights the capabilities of the Oracle Machine Learning for Python ('OML4Py') tools.

By the end of this lab, you will have:
- Stored, chunked, and vectorized your documents.
- Used a Large Language Model (LLM) to generate a precise answer to a query you enter based on relevant context stored in Oracle AI database.
- See the diagram below what you will be learning.
 
 ![rag image](images\overview.png " ")

**_Estimated Time: 10 Minutes_**

## About Oracle AI Vector Search

Oracle AI Vector Search is a feature of Oracle Database 23ai that enables efficient searching of AI-generated vectors stored in the database. It supports fast search using various indexing strategies and can handle massive amounts of vector data. This makes it possible for Large Language Models (LLMs) to query private business data using a natural language interface, helping them provide more accurate and relevant results. Additionally, AI Vector Search allows developers to easily add semantic search capabilities to both new and existing applications.

## About Select AI

Select AI generates natural language to interact with your database and LLMs through SQL to enhance user productivity and develop AI-based applications. Select AI simplifies and automates using generative AI, whether generating, running, and explaining SQL from a natural language prompt, using retrieval augmented generation with vector stores, generating synthetic data, or chatting with the LLM.

You may now **proceed to the next lab**

