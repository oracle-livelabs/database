# Use AI Vector Search

## Introduction

In this lab, you will explore AI Vector Search using a simple example. You will create vector embeddings, store them in Oracle AI Database, and use vector similarity search to find related data based on semantic meaning rather than exact text matches.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Load an ONNX embedding model into Oracle AI Database.
* Create vector embeddings from existing text.
* Use vector similarity search to find semantically related data.

### Prerequisites

None.

## Task 1: Explore AI Vector Search

Now that you have successfully migrated the PDB to Oracle AI Database 26ai, you can explore AI Vector Search.

1. Connect to the *RED* PDB to create the *DEMO* schema.

    ``` sql
    <copy>
    cd 
    . cdb26
    sql sys/oracle@//localhost:1521/red as sysdba
    </copy>
    ```

2. Create the *DEMO* schema.

    ``` sql
    <copy>
    create user demo identified by "oracle" default tablespace users quota unlimited on users;
    grant db_developer_role to demo;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create user demo identified by "oracle" default tablespace users quota unlimited on users;

    User DEMO created.

    SQL> grant db_developer_role to demo;

    Grant succeeded.
    ```

    </details>

3. Create a directory object that points to `/home/oracle/models`, where the ONNX model is located, and grant *DEMO* read access to the directory.

    ``` sql
    <copy>
    create or replace directory models as '/home/oracle/models';
    grant read on directory models to demo;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create or replace directory models as '/home/oracle/models';

    Directory MODELS created.

    SQL> grant read on directory models to demo;

    Grant succeeded.
    ```

    </details>


4. Connect as the *DEMO* user and create the *TRIVIA* table.

    ``` sql
    <copy>
    conn demo/oracle@//localhost/RED
    @scripts/upg-trivia-facts.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> conn demo/oracle@//localhost/RED
    Connected.
    SQL> @scripts/upg-trivia-facts.sql

    Table TRIVIA dropped.


    Table TRIVIA created.


    110 rows inserted.


    50 rows inserted.


    40 rows inserted.


    20 rows inserted.


    20 rows inserted.


    50 rows inserted.


    40 rows inserted.


    Commit complete.
    ```

    </details>

5. Examine a few rows in the *TRIVIA* table.

    ``` sql
    <copy>
    select pk, facts
    from   trivia
    where  pk between 1 and 3
           or pk between 121 and 123
           or pk between 171 and 173
           or pk between 221 and 223
           or pk between 311 and 313;
    </copy>
    ```

    * The table contains trivia about cities, cars, fruits, drinks, and other topics.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
        PK FACTS
    ______ __________________________________________________________________
         1 Atlanta is located in Georgia.
         2 Boston is located in Massachusetts.
         3 Chicago is located in Illinois.
       121 Altima is made by Nissan.
       122 Charger is made by Dodge.
       123 Outback is made by Subaru.
       171 Mangos are the most consumed fruit worldwide.
       172 Oranges are a hybrid of pomelo and mandarin.
       173 Pomegranates have anti-inflammatory properties.
       221 Dogs have about 1,700 taste buds.
       222 A dog�s sense of smell is 40 times better than humans.
       223 Dogs sweat through their paws.
       311 A French 75 contains Gin, lemon juice, simple syrup, Champagne.
       312 An Aperol Spritz contains Aperol, prosecco, soda water.
       313 A Cuba Libre contains White rum, cola, lime juice.
    
    15 rows selected.
    ```

    * A text search shows that the word *cocktail* does not appear in any row. Later, you will use vector similarity search to find semantically related results even though the search term does not occur in the text.

    ``` sql
    <copy>
    select * 
    from   trivia
    where  lower(facts) like '%cocktail%';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> select * 
    2    from   trivia
    3*   where  lower(facts) like '%cocktail%';

    no rows selected
    ```

    </details>

6. Load the *all_MiniLM_L12_v2.onnx* model into the database. This *SentenceTransformers* model is suitable for semantic similarity search and clustering.

    ``` sql
    <copy>
    begin
    dbms_vector.load_onnx_model(
        'MODELS',
        'all_MiniLM_L12_v2.onnx',
        'DOC_MODEL',
        JSON('{"function":"embedding",
                "embeddingOutput":"embedding",
                "input": {"input": ["DATA"]}}'));
    end;
    /
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> begin
    2    dbms_vector.load_onnx_model(
    3       'MODELS',
    4       'all_MiniLM_L12_v2.onnx',
    5       'DOC_MODEL',
    6       JSON('{"function":"embedding",
    7              "embeddingOutput":"embedding",
    8              "input": {"input": ["DATA"]}}'));
    9  end;
    10* /

    PL/SQL procedure successfully completed.
    ```

    </details>

7. Verify that the model was loaded by querying the data dictionary.

    ``` sql
    <copy>
    select model_name, algorithm, mining_function
    from   user_mining_models;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    MODEL_NAME    ALGORITHM    MINING_FUNCTION
    _____________ ____________ __________________
    DOC_MODEL     ONNX         EMBEDDING
    ```

    </details>

8. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```

9. Connect to the *RED* PDB using SQL*Plus.

    ``` sql
    <copy>
    sqlplus demo/oracle@//localhost:1521/red
    </copy>
    ```

10. Create a table that stores each trivia entry together with its vector embedding.

    ``` sql
    <copy>
    create table trivia_vec as
    select pk, facts, vector_embedding(doc_model using t.facts as data) as vec
    from   trivia t;
    </copy>
    ```

    * You copy all data into a new table with similar structure.
    * You add a new column, *VEC*, which contains the vector embedding for that specific row.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create table trivia_vec as
    2  select pk, facts, vector_embedding(doc_model using t.facts as data) as vec
    3* from   trivia t;

    Table TRIVIA_VEC created.
    ```

    </details>

11. Examine the generated vectors.

    ``` sql
    <copy>
    set pagesize 10000
    set linesize 130
    col facts format a80
    col vec format a40 trunc
    select facts, vec
    from   trivia_vec
    where  rownum <= 10;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    FACTS										 VEC
    -------------------------------------------------------------------------------- ----------------------------------------
    Atlanta is located in Georgia.							 [3.0079985E-002,-5.27411886E-003,-3.8773
    Boston is located in Massachusetts.						 [9.21797678E-002,-1.03325688E-003,8.2331
    Chicago is located in Illinois. 						 [4.39825356E-002,-1.2022635E-002,1.72175
    Denver is located in Colorado.							 [1.2066979E-001,-4.58574202E-003,1.11382
    Houston is located in Texas.							 [1.45818507E-002,-3.98688689E-002,3.8565
    Miami is located in Florida.							 [1.86449513E-002,-1.30586907E-001,-1.443
    Nashville is located in Tennessee.						 [-6.88686385E-004,8.72113407E-002,8.0254
    Phoenix is located in Arizona.							 [1.34541601E-001,-3.95113677E-002,-8.865
    Seattle is located in Washington.						 [1.05677709E-001,7.45320544E-002,7.75661
    Philadelphia is located in Pennsylvania 					 [1.3837832E-002,-5.05678244E-002,7.70600

    10 rows selected.
    ```

    </details>

12. Compare the size of the original table with the table that includes the vectors.

    ``` sql
    <copy>
    col segment_name format a20
    select segment_name, bytes/1024 as kbytes
    from   user_segments 
    where  segment_name like 'TRIVIA%';
    </copy>
    ```

    * Adding the vector embeddings increases the table size significantly. In this example, *TRIVIA_VEC* is approximately 12 times the size of *TRIVIA*.
    * Vector embeddings require additional storage, so consider their storage requirements when designing applications that use AI Vector Search.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SEGMENT_NAME		     KBYTES
    -------------------- ----------
    TRIVIA                       64
    TRIVIA_VEC                  768
    ```

    </details>

12. Create a vector embedding for the word *cocktail*.

    ``` sql
    <copy>
    select vector_embedding(doc_model using 'cocktail' as data);
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    VECTOR_EMBEDDING(DOC_MODELUSING'COCKTAIL'ASDATA)
    --------------------------------------------------------------------------------
    [-2.84580588E-002,6.74280385E-003,-2.74021868E-002,8.71311314E-003,
    ```

    </details>

13. Now, use semantic search to find the trivia entries that are semantically closest to the word *cocktail*.

    ``` sql
    <copy>
    select   pk, facts
    from     trivia_vec
    order by vector_distance(vec , vector_embedding(doc_model using 'cocktail' as data), cosine)
    fetch first 4 rows only;
    </copy>
    ```

    * The output shows the key benefit of semantic search: none of these trivia entries contains the word *cocktail*, yet the vector similarity search correctly identifies several cocktails based on their meaning.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    	PK FACTS
    ---------- --------------------------------------------------------------------------------
           291 A Margarita contains Tequila, lime juice, triple sec.
           318 A Vesper contains Gin, vodka, Lillet Blanc.
           293 A Martini contains Gin, dry vermouth.
           304 A Gin and Tonic contains Gin, tonic water.
    ```

    </details>

14. Repeat the search to find the entries semantically closest to *suzuki*.
    ``` sql
    <copy>
    select   pk, facts
    from     trivia_vec
    order by vector_distance(vec , vector_embedding(doc_model using 'suzuki' as data), cosine)
    fetch first 4 rows only;
    </copy>
    ```

    * The results are related to cars and automobile manufacturers even though none of the entries contains *suzuki*. This demonstrates that vector similarity search finds semantic relationships rather than exact text matches. 

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    	PK FACTS
    ---------- --------------------------------------------------------------------------------
           139 CR-V is made by Honda.
           112 Accord is made by Honda.
           155 Sorento is made by Kia.
           126 Elantra is made by Hyundai.
    ```

    </details>

15. Repeat the search using the phrase *fastest running dog*.

    ``` sql
    <copy>
    select   pk, facts
    from     trivia_vec
    order by vector_distance(vec , vector_embedding(doc_model using 'fastest running dog' as data), cosine)
    fetch first 4 rows only;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    	PK FACTS
    ---------- --------------------------------------------------------------------------------
           231 Greyhounds can run up to 45 mph.
           238 Dogs have an excellent sense of time.
           211 Domestic cats can run up to 30 mph.
           234 Labradors are the most popular breed.
    ```

    </details>

16. Exit SQL*Plus.

    ``` bash
    <copy>
    exit
    </copy>
    ```

You may now [*proceed to the next lab*](#next).

## Acknowledgements

* **Author** - Rodrigo Jorge
* **Contributors** - Daniel Overby Hansen, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026
