# Lab 4: AI Vector Search and Retrieval-Augmented Generation (RAG)

**( Refer to 'Lab 4' of the Jupyter notebook as go through this lab )** 

## Introduction

![vector search and RAG flow highlighting database vector search](images/station_05.png)

Estimated Time: 10 minutes

This lab guides you through the steps to retrieve database rows containing vectors, and the associated data chunks, which are close to the query/prompt in **vector space**. Then, we will use the most relevant text chunks to augment, or enhance, the query/prompt and present it to the LLM which will present a well-formed natural language response. This is the basic Retrieval-Augmented Generation (RAG) approach.

### Objectives

In this lab, you will:

- Examine for understanding, then execute the workshop python function "DB\_AI\_Vector\_Search" that you defined in Lab 2, containing Python and SQL code to retrieve records from a vector database based on vector distance from a generalized query or prompt (the "prompt").
- Examine and execute previously defined workshop function "LLM\_Search" which uses a Llama-3.2 multimodal large language model to retrieve a publicly available response to the prompt. This will be our baseline non-RAG response.
- Examine and execute previously defined workshop function "LLM\_Search_using_RAG" which creates a new, enhanced prompt that uses the previous non-RAG response, the top chunks from the database vector search, and custom instructions.

### **Prerequisites**

This lab assumes you have:

- All previous labs successfully completed

## Task 1: AI Vector Search

In this step, we will take a text, supposedly a question the user is asking re: a relevant business issue, opportunity, etc. and transform it into a vector. We will then feed this vector to the database, where it will be used to retrieve **similar** vectors and associated metadata.
 
### Similarity Search

A similarity search looks for the relative order of vectors compared to a query vector.
The comparison is done using a particular **distance metric**, allowing us to return from the database a result set of the **top closest vectors** along with **the associated data Chunks most similar to the query**.

### Executing the query

Below is an example of the similarity search process in SQL.

The similarity search query returns the **vector\_data** , **doc\_id**, **chunk\_id** and **chunk\_data** columns from the USERINFO\_VECTOR table. It also returns the result of **VECTOR_DISTANCE** as **distance**

1. The SQL language function **VECTOR_DISTANCE** is used to calculate the distance between two vectors. Here, it takes **vector\_data** and **distance** as parameters.
2. **vector_data** contains the embedded vector data derived in Lab 3
3. SQL language function **VECTOR\_EMBEDDING** generates a single vector embedding for multiple data types using machine learning models. Here, we use the sentence transformer model **ALL\_MPNET\_BASE\_V2** used in Lab 3 to generate the embedding, using a plain text string.
4. The prompt from Lab3 is used as the VECTOR\_EMBEDDING 'USING' parameter. 

The similarity search query returns the top ten rows from USERINFO\_VECTOR in ascending **distance** order.  The smallest vector distances between **vector_data** data and the prompt embedding indicate the most similar associated Chunks to the prompt text.

![SQL code example of database vector search](images/station_06_large.png)

Below is an excerpt of the code, previously defined in "**DB\_AI\_Vector\_Search"** function", you will execute in the workshop

```python
<copy>
def DB_AI_Vector_Search(query_sql_UserInfo):
    try:
            with oml.cursor() as cursor:
                    sql = """SELECT vector_distance(vector_data, (vector_embedding(ALL_MPNET_BASE_V2 using :search_text as data))) as distance,
                    doc_id,
                    chunk_id,
                    chunk_data
                    FROM Userinfo_vector order by distance fetch first 10 rows only with target accuracy 90"""
                    cursor.execute(sql, [query_sql_UserInfo])
</copy>
```

![calling the python vector search function](images/station_06a_large.png)

**(jupyter notebook) -->**  [Lab4 Task1:]&nbsp;&nbsp;&nbsp;After reviewing the steps and the screenshot, Press 'Shift-Enter' **twice** or Click the 'Run Cell' icon **twice** to Execute the **DB\_AI\_Vector\_Search"** function below
Stand by for all results to return...

## Task 2: Large Language Model Query

- In this step, we will execute the "**LLM\_Search**" function defined in Lab 2.

![vector search and RAG flow highlighting LLM internet search](images/station_07.png)

- A LLM will use our prompt to retrieve a publicly available response from the internet
- We will use this as a part-1 baseline to compare against a RAG response that we will generate in Task 3.  See an excerpt from LLM_Search below.
- **LLM\_Search** takes the prompt ( **query\_sql\_UserInfo** ) as a single parameter.

![python code definition for LLM chat function](images/station_06b_large.png)

**(jupyter notebook) -->**  [Lab4 Task2:]&nbsp;&nbsp;&nbsp;After reviewing the steps and the screenshot, Press 'Shift-Enter' **twice** or Click the 'Run Cell' icon **twice** to Execute the **LLM\_Search** function below
Stand by for all results to return...

## Task 3: Retrieval-Augmented Generation (RAG) Enhanced Query

![vector search and RAG flow highlighting RAG](images/station_09.png)

- In this part-2 step, we will execute the "**LLM\_Search\_using\_RAG**" function defined in Lab 2.
- We have the query returning a response augmented by the database rows returned by AI Vector Search (Retrieval-Augmented Generation or "RAG").

- The response has gained more specificity by adding data only available within the organization. See an excerpt from **LLM\_Search\_using\_RAG** below.
RAG is accomplished, in natural language, by combining the preserved AI Vector Search output from Task 1 ( coalesced_top_rows_UserInfo ) with the prompt ( query_sql_UserInfo ) to present an LLM response combining publicly available and organization-specific information.

```python
<copy>
chat_request=oci.generative_ai_inference.models.GenericChatRequest(
    message=[oci.generative_ai_inference.models.UserMessage(
    content=[oci.generative_ai_inference.models.TextContent(
    text="Given the query \"" + query_sql_UserInfo + "\" to the LLM, use \"" + coalesced_top_rows_UserInfo + "\" to enrich the response)])],
    temperature=0.75,
    top_p=1.00),
    serving_mode=oci.generative_ai_inference.models.OnDemandServingMode(
    model_id="meta.llama-3.2-90b-vision-instruct")

    chat_response = genai_client.chat(chat_detail)

    reply = chat_response.data.chat_response.choices[0].message.content[0].text

    print(reply)
</copy>
```

![python code definition for RAG function](images/station_06c_large.png)

**(jupyter notebook) -->**  [Lab4 Task3:]&nbsp;&nbsp;&nbsp;After reviewing the steps and the screenshot, Press 'Shift-Enter' **twice** or Click the 'Run Cell' icon **twice** to Execut&nbsp;&nbsp;&nbsp;e the **LLM\_Search\_using\_RAG** function below
Stand by for all results to return...

You may now **proceed to the next lab**

## Acknowledgements

**Author** - Gary McKoy, Master Principal Solution Architect, Data Platform Infrastructure, NACI

**Contributors** -

* Eileen Beck, Cloud Solution Engineer, Data Platform Infrastructure, NACI
* Sania Bolla, Cloud Solution Engineer, Data Platform Infrastructure, NACI
* Abby Mulry, Cloud Solution Engineer, Data Platform Infrastructure, NACI
* Richard Piantini Cid, Cloud Solution Engineer, Data Platform Infrastructure, NACI

**Last Updated By/Date** -  Gary McKoy, March 2026