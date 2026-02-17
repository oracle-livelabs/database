# Setup the Python Functions

## Introduction

This lab will guide you through setting up the Python functions needed for the workshop.

Estimated Time: 15 minutes

### Objectives

Define the functions required to:
- Execute vector search on business data in the Oracle Database in response to a user prompt
- Use a large language model to retrieve a public response to the prompt
- Use the large language model, augmented by the database vector search response, to retrieve an enriched response using internal and public data

## Task 1: Overview

In the "Overview" notebook cell, the vector search, LLM and RAG python functions are described

![overview](images/Station_01a.png)

### DB\_AI\_Vector\_Search
- Oracle Database AI Vector Search lets applications store vector embeddings alongside traditional relational data and use them to perform fast, semantic similarity searches over both structured and unstructured content such as text, images, and audio.
- It introduces a native VECTOR data type, SQL functions, and vector indexes so developers can generate embeddings, index them, and query by meaning rather than keywords.

### LLM\_Search
- In this context, Large Language Models (LLMs) act as the central **reasoning** and language-understanding engines, interpreting natural-language instructions, breaking goals into steps, and deciding which data, tools or APIs to call to accomplish tasks.

### LLM\_Search\_using_RAG
- Retrieval-augmented generation (RAG) with Oracle AI Vector Search and Large Language Models (LLMs) combines semantic search over enterprise data with generative reasoning to produce more accurate, grounded answers.
- Oracle AI Vector Search stores and indexes embeddings for documents and other content, then, at query time, converts a user question into a vector and runs similarity search to retrieve the most relevant chunks from relational, text, JSON, graph, and other data in the Oracle database. 
- These retrieved chunks are appended to the user’s prompt and sent to an LLM, which synthesizes a response constrained by the supplied context, reducing hallucinations while leveraging both the model’s general knowledge and the organization’s up-to-date private data. 


## Task 2: Define Python functions

When ready, after examining the python code defining the three functions, Press 'Shift-Enter' **twice** or Click the 'Run Cell' icon **twice** to create these functions.


You may now **proceed to the next lab**

