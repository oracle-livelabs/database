# Setup Sakila Sample Database and JavaScript Stored Function

## Introduction

The Sakila sample database was initially developed by Mike Hillyer, a former member of the MySQL AB documentation team. It is intended to provide a standard schema that can be used for examples in books, tutorials, articles, samples, and so forth. The Sakila sample database also serves to highlight features of MySQL such as Views, Stored Procedures, and Triggers.


_Estimated Time:_ 20 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Install  and explore Sakila
- Prepare Sakila for  RAG processing

### Prerequisites

This lab assumes you have:

- Completed Labs 5


## Task 1: Build and Review  Sakila database

1. If not already connected with SSH, on Command Line, connect to the Compute instance using SSH ... be sure replace the  "private key file"  and the "new compute instance IP"

     ```bash
    <copy>ssh -i private_key_file opc@new_compute_instance_ip</copy>
     ```


2. Download the Sakila files

    ```bash
    <copy>cd ~/mysql-ai-workshop
    wget https://downloads.mysql.com/docs/sakila-db.tar.gz</copy>
    ```
3. Unzip the  Sakila files

    ```bash
    <copy>tar -xzf sakila-db.tar.gz</copy>
    ```
4. Login to MySQL

    ```bash
    <copy>mysql -h localhost -u admin -p</copy>
    ```
5. Create Sakila database

    ```bash
    <copy>SOURCE ~/mysql-ai-workshop/sakila-db/sakila-schema.sql;</copy>
    ```
6. Load data into Sakila

    ```bash
    <copy>SOURCE ~/mysql-ai-workshop/sakila-db/sakila-data.sql;</copy>
    ```

7. Verify Created tables

    ```bash
    <copy>USE sakila;
    SHOW TABLES;</copy>
    ```
    ![List Sakila tables](./images/list-sakila-tables.png "List Sakila tables")

8. Verify data loaded

    ```bash
    <copy>SELECT COUNT(*) FROM film;
    SELECT COUNT(*) FROM actor;
    SELECT COUNT(*) FROM customer;</copy>
    ```
    ![Sakila data sizes](./images/loaded-data-sizes.png "Sakila data sizes")

9. Explore sample data

    ```
    <copy> SELECT film_id, title, description, length, rating FROM film LIMIT 5;
    SELECT * FROM category;</copy>
    ```
    ![Explore Sakila data](./images/explore-sakila-data.png "Explore Sakila data")



## Task 2: Prepare Sakila for RAG processing
1. Now create the RAG embeddings table

    ```bash
    <copy>CREATE TABLE film_rag (
    id INT AUTO_INCREMENT PRIMARY KEY,
    film_id SMALLINT UNSIGNED,
    content TEXT,
    embedding VECTOR(384) COMMENT 'GENAI_OPTIONS=EMBED_MODEL_ID=all_minilm_l12_v2',
    FOREIGN KEY (film_id) REFERENCES film(film_id));
    </copy>
    ```

    ![CREATE TABLE film_rag results](./images/film-rag-results.png "CREATE TABLE film_rag results")



2. Populate with enriched film data

    ```bash
    <copy>INSERT INTO film_rag (film_id, content)
    SELECT 
        f.film_id,
        CONCAT(title, '. ', description, '. Category: ', 
            (SELECT name FROM category c JOIN film_category fc ON c.category_id = fc.category_id WHERE fc.film_id = f.film_id))
    FROM film f;</copy>
    ```
3. Generate embeddings

    ```bash
    <copy>UPDATE film_rag 
    SET embedding = sys.ML_EMBED_ROW(content, JSON_OBJECT('model_id', 'all_minilm_l12_v2'))
    WHERE embedding IS NULL;</copy>
    ```
4. Wait 5 minutes.
5. Check the embedding results.

    ```bash
    <copy>SELECT 
    COUNT(*) as total_rows,
    COUNT(embedding) as rows_with_embeddings,
    COUNT(*) - COUNT(embedding) as rows_remaining
    FROM film_rag;</copy>
    ```
    ![Embedding results](./images/embedding-results.png "Embedding results")
6. Exit MySQL.

    ```bash
    <copy>EXIT;</copy>
    ```
You may now **proceed to the next lab**

## Learn More

- [Sakila Sample Database](https://dev.mysql.com/doc/sakila/en/sakila-introduction.html)

## Acknowledgements

- Authors: Craig Shallahamer, Applied AI Scientist, Viscosity North America, Perside Foster, Open Source Principal Partner Solution Engineer
- Contributors: Open - Source Channel Enablement Team (Nick Mader, Chris Bates, Juliana Castro)
- Last Updated: Perside Foster, October 2025