# Introduction

## About this Workshop

Large Language Models (LLMs) have transformed artificial intelligence by enabling computers to understand and generate human-like text. These models rely on vectors—mathematical representations of words, phrases, and sentences—to process and create language. Vectors allow LLMs to capture the meaning of words and the relationships between them, making it possible for the models to perform tasks like text generation, translation, and question-answering with impressive accuracy. However, as we push LLMs to handle more complex tasks, such as integrating text with other types of data like images, new challenges arise. Combining these different kinds of vectors—those representing text and those representing images—requires advanced techniques to ensure the model can effectively understand and generate multimodal information.

In this workshop, we will look at one approach to solving this problem. We will leverage one model to generate descriptions for the image and then a second model for creating the vectors for the textual descriptions. This greatly simplifies the problem because having a single model that can both take images and text as inputs and generate compatible vectors is a challenge and very few models support this. By breaking the task up into two steps we get captions for the images which we can use in the application and we get access to many more LLMs as the tasks individually are much simplier. The diagram below shows the workflow that we will accomplish in this workshop.


![Image alt text](images/diagram1.png)


Estimated Workshop Time: 70 Minutes

  [](youtube:pu79sny1AzY)

### Objectives

In this workshop, you will learn how to:
* Work with Large Language Models (LLMs)
* Create and Load Vectors
* Create an APEX application using AI Vector Search

### Prerequisites

This lab assumes you have:
* An Oracle account

## Learn More

* [Oracle AI Vector Search Users Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/whats-new-oracle-ai-vector-search.html)
* [AI Vector Search Blog](https://blogs.oracle.com/database/post/oracle-announces-general-availability-of-ai-vector-search-in-oracle-database-23ai)

## Acknowledgements
* **Author** - David Start, Product Management
* **Contributors** -  David Start, Product Management
* **Last Updated By/Date** - David Start, Sept 2024
