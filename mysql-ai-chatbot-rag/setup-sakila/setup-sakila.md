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


1. Create a copy of the film_list view, which contains film context.

    ```bash
    <copy>create table film_list_rag as select * from film_list;</copy>
    ```
2. Rename fid column to film_id.

    ```bash
    <copy>alter table film_list_rag rename column fid to film_id;</copy>
    ```
3. Add column release_year and update.

    ```bash
    <copy>alter table film_list_rag add column release_year integer;
    UPDATE film_list_rag
    JOIN film ON film_list_rag.film_id = film.film_id
    SET film_list_rag.release_year = film.release_year;
    </copy>
    ```

4. Add the embedding columns for performing similarity searches.

    ```bash
    <copy>alter table film_list_rag add column embedding_text text;</copy>
    ```

    ```bash
    <copy>alter table film_list_rag add column vector_embedding VECTOR(384) COMMENT 'GENAI_OPTIONS=EMBED_MODEL_ID=all_minilm_l12_v2';</copy>
    ```
    ![Show film-list-rag table](./images/film-list-rag.png "Show film-list-rag table")

5. Exit MySQL.

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