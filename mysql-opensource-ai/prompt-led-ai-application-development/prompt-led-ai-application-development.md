# Prompt Led AI Application Development

## Introduction

This lab introduces a reusable AI prompt engineering framework for generating production-quality starter applications using modern web technologies and MySQL HeatWave GenAI capabilities. By using a structured prompt template, developers can rapidly create scalable, AI-enabled applications with semantic vector search, chatbot functionality, and intelligent recommendation systems.

The lab demonstrates how to guide AI coding assistants using clearly defined business objectives, frontend requirements, backend architecture, database design, and deployment expectations.

> **Note:** This lab focuses on educational prompt engineering and application scaffolding techniques. The generated applications should be reviewed, secured, and optimized before production deployment.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

- Understand the Prompt-Led Application Development framework
- Learn how to structure production-quality AI prompts
- Generate full-stack starter applications using AI
- Integrate MySQL HeatWave GenAI features
- Configure semantic vector search capabilities
- Prepare applications for deployment and testing
- Understand HeatWave embedding and vector similarity workflows

### Prerequisites

Before starting this lab, ensure you have:

- Completed Lab1 and Lab2
- Basic familiarity with:
  - Python Flask
  - MySQL
  - HTML/CSS/JavaScript
  - Prompt Engineering concepts


## Task 1: Understand the Prompt-Led Development Framework

### Starter Application Generation Template

```text
# STARTER APPLICATION GENERATION TEMPLATE

Create a production-quality {application_type} web application.

1. Business Objective
2. Frontend Requirements
3. Required Features
4. Backend Requirements
5. Database Requirements
6. AI / GenAI Features
7. Deployment Requirements
8. Important
    ```

    ### Template Section Breakdown

    ### 1. Business Objective

    Defines the business problem and user goals the application is designed to solve.

    Examples:
    - E-commerce platform
    - AI chatbot
    - Feedback analytics system
    - Recommendation engine

    ### 2. Frontend Requirements

    Defines:

    - UI framework
    - Responsiveness
    - Layout expectations
    - Visual styling
    - User experience standards

    Examples:
    - Bootstrap 5
    - Responsive grid layouts
    - Sticky navigation
    - Modern dashboard interfaces

    ### 3. Required Features

    Specifies all application functionality such as:

    - Authentication
    - Product search
    - Order management
    - Dashboards
    - Reports
    - Feedback systems
    - Semantic search

    ### 4. Backend Requirements

    Defines backend architecture and implementation details:

    - Framework selection
    - Modular project structure
    - Exception handling
    - Logging
    - Service organization
    - API architecture

    ### 5. Database Requirements

    Ensures executable SQL scripts are generated including:

    - Database creation
    - Tables
    - Primary keys
    - Foreign keys
    - Indexes
    - Seed data
    - Vector columns

    ### 6. AI / GenAI Features

    Defines AI-powered functionality such as:

    - Vector embeddings
    - Semantic search
    - Recommendations
    - Summarization
    - Chatbots
    - HeatWave GenAI integration

    ### 7. Deployment Requirements

    Specifies deployment expectations:

    - VM deployment
    - Startup instructions
    - Environment setup
    - Runtime dependencies


    ### 8. Important

    Emphasizes:

    - Production-quality output
    - Clean UI design
    - Deployment readiness
    - Modular architecture
    - Reusable code structure


## Task 2: Generate an Example AI Application Prompt

The following example demonstrates how to request a production-quality AI-powered e-commerce application using Python Flask and MySQL HeatWave.

### Example Prompt

```text
<copy>Role: Senior Full-Stack Engineer.

Task: Build a production-quality E-commerce Web Application for electronics using Python Flask and MySQL HeatWave.

1. Required Web Pages

    Generate clean, modular HTML5/Bootstrap 5 templates for the following:

    Home/Landing Page:
    Includes a sticky navigation bar (Home, Orders, Feedback, Logout), a premium hero banner, and a prominent search bar.

    Product Grid:
    A responsive 3-column layout featuring elegant product cards. Each card must include:
    - Product image
    - Title
    - Price
    - Star rating
    - Description
    - Buy button

    Login Page:
    A visually polished authentication form.

    Order History Page:
    Dashboard view listing previous purchases.

    Product Details Page:
    Detailed product information and customer feedback.

2. Database Requirements (MySQL HeatWave)

    Provide a complete executable SQL script.

    products Table:
    - product_description (TEXT)
    - description_vector (VECTOR)
    - image_url (VARCHAR)
    - id
    - name
    - price
    - category
    - rating
    - quantity

    Other Tables:
    - users
    - orders
    - feedback

    Seed Data:
    Include realistic electronics product data.

3. AI Feature: Semantic Vector Search

    Implement native Vector Search capability using MySQL HeatWave.

    Use VECTOR_DISTANCE for similarity calculations.

4. Technical Architecture

Backend:
Modular Python Flask architecture using db_utils.py.

Frontend:
Vanilla JavaScript and responsive Bootstrap UI.</copy>
```

## Task 3: Understand HeatWave GenAI Integration

To generate AI-powered applications correctly, provide sample HeatWave GenAI SQL statements to the AI assistant.

This helps ensure accurate SQL generation and proper GenAI routine usage.

1. Generate Embeddings

    Use the following sample query:

    ```sql
    <copy>SELECT sys.ML_EMBED_ROW(
    "What is artificial intelligence?",
    JSON_OBJECT("model_id", "all_minilm_l12_v2")
    ) INTO @text_embedding;</copy>
    ```

    This generates vector embeddings using the `all_minilm_l12_v2` model.



2. Perform Semantic Vector Search

Use cosine similarity calculations:

```sql
<copy>SELECT DISTANCE(
    STRING_TO_VECTOR("[1.01231, 2.0123123, 3.0123123, 4.01231231]"),
    STRING_TO_VECTOR("[1, 2, 3, 4]"),
    "COSINE" </copy>
);
```

This enables semantic similarity matching between embeddings.

### Why Provide Sample Queries?

Providing example HeatWave GenAI queries helps the AI assistant understand:

- Your exact schema requirements
- Procedure naming conventions
- JSON parameter syntax
- Embedding workflows
- Semantic search implementation

This significantly improves generated code quality and reduces integration errors.


## Task 4: Initialize the Database

Run SQL Scripts in HeatWave SQL Editor

After generating the application:

1. Open the mysql HeatWave SQL Editor in VS code.
2. Run the generated:
    - CREATE TABLE scripts
    - Seed data scripts
3. Verify all tables and vector columns are created successfully

> **Important:** Database initialization must be performed manually because the HeatWave database is deployed inside a private network.



## Task 5: Configure Database Connectivity

Update your application configuration with the correct database connection details.

1. Local Testing via SSH Tunnel

    Use:

    ```text
    <copy>localhost</copy>
    ```

    or

    ```text
    <copy>127.0.0.1</copy>
    ```



2. Deployment Inside OCI VCN

Use the HeatWave private IP address when deploying the application on a Compute VM within the same Virtual Cloud Network (VCN).



## Task 6: Environment Setup and Application Execution

1. Create a Python Virtual Environment OR ask code assist to do it

    ```bash
    <copy>python3 -m venv venv</copy>
    ```

    Activate the environment:

    ```bash
    <copy>source venv/bin/activate</copy>
    ```

    Install dependencies:

    ```bash
    <copy>pip install -r requirements.txt</copy>
    ```



2. Run the Application

    ```bash
    <copy>python app.py</copy>
    ```



## Task 7: Create an SSH Tunnel

Use the following command to securely connect your local machine to the private HeatWave database:

1. open Terminal and run the following

    ```bash
   <copy> ssh -i &lt;private_key&gt; -L 3306:&lt;db_private_ip&gt;:3306 opc@&lt;vm_public_ip&gt;</copy>
    ```

Replace:

- `<private_key>` with your SSH private key file path
- `<db_private_ip>` with the HeatWave private IP
- `<vm_public_ip>` with the Compute VM public IP



### Important Notes

This lab provides:

- A sample prompt framework
- A reusable application-generation structure
- Example architecture patterns

It is **not** intended to be a strict syntax standard.

You are encouraged to:

- Customize the sections
- Add domain-specific requirements
- Expand the prompt structure
- Improve generated architecture patterns

The goal is to accelerate development through effective AI-guided prompt engineering.



### Optional

Enhance your generated application with a **Feedback Summary** feature.


## Learn More

- [MySQL HeatWave Documentation](https://dev.mysql.com/doc/heatwave/en/mys-hw-about-heatwave.html)
- [MySQL HeatWave GenAI Documentation](https://dev.mysql.com/doc/heatwave/en/mys-hwgenai-routines.html)
- [OCI Compute Documentation](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)
- [Python Flask Documentation](https://flask.palletsprojects.com/en/stable/)



## Acknowledgements

**Authors:**  
Lohith R and Jayshri Dhar from SEHUB

**Contributors:**  
Rahul Shringarpure from Mysql Heatwave
