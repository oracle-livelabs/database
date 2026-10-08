# New Feature: Semantic Cache with Vector Search

## Introduction

Find payments with similar attributes using Oracle AI Vector Search through True Cache. The image already contains the 20,000-row `PAYMENT_VECTORS` sample and its cosine IVF index.

True Cache can serve eligible read-only retrievals and reduce repeated reads against Primary. Primary remains responsible for writes and data refreshes. This lab uses deterministic 16-dimensional payment feature vectors, not an embedding model or an LLM response cache.

*Estimated Time:* 15 minutes.

### Objectives

- Check the prebuilt vector sample and index.
- Run a nearest-neighbor query through True Cache.
- Interpret cosine distance; optionally compare account and country filters.

### Prerequisites

Complete the previous labs and restore Primary after the availability exercise. Start with a host terminal. The normal path does not create tables, load vectors, or rebuild indexes.

## Task 1: Verify the Prebuilt Sample on Primary

1. Enter Primary from the host terminal.

    ```bash
    <copy>
    sudo podman exec -it prod /bin/bash
    </copy>
    ```

2. At the container prompt, open SQL*Plus.

    ```bash
    <copy>
    ORACLE_SID=ORCLCDB sqlplus / as sysdba
    </copy>
    ```

3. At `SQL>`, check the sample and index.

    ```sql
    <copy>
    alter session set container=ORCLPDB1;
    select count(*) vector_rows from transactions.payment_vectors;
    select index_name, index_type, status
    from dba_indexes
    where owner = 'TRANSACTIONS'
      and index_name = 'PAYMENT_VECTORS_IVF_IDX';
    </copy>
    ```

    **Expected:** 20,000 rows and `PAYMENT_VECTORS_IVF_IDX` with status `VALID`. If the objects are missing or invalid, stop this normal path and see [Vector Sample Recovery](../recovery/vector-sample-recovery.md). Do not run recovery on a healthy sample.

4. Type `exit` to leave SQL*Plus, then `exit` to return to the host.

## Task 2: Select a Reference Payment on True Cache

1. Enter True Cache from the host terminal.

    ```bash
    <copy>
    sudo podman exec -it truedb /bin/bash
    </copy>
    ```

2. At the container prompt, open SQL*Plus.

    ```bash
    <copy>
    ORACLE_SID=TRUEDB sqlplus / as sysdba
    </copy>
    ```

3. At `SQL>`, list a few reference payments.

    ```sql
    <copy>
    alter session set container=ORCLPDB1;
    set pages 100 lines 160
    select payment_id, account_id, country_cd, amount
    from transactions.payment_vectors
    order by payment_id
    fetch first 5 rows only;
    </copy>
    ```

4. Set the reference once. Use `1` if it appeared in the result; otherwise replace it with a returned payment ID.

    ```sql
    <copy>
    define reference_id = 1
    set verify off
    </copy>
    ```

    Later queries reuse `&reference_id`; there is no need to edit the same ID in several places. Keep this SQL*Plus session open for the searches.

## Task 3: Find Similar Payments

Run this query in the same True Cache SQL*Plus session.

```sql
<copy>
select payment_id, account_id, country_cd, amount,
       round(vector_distance(embedding,
         (select embedding from transactions.payment_vectors
          where payment_id = &reference_id), cosine), 6) distance
from transactions.payment_vectors
where payment_id <> &reference_id
order by vector_distance(embedding,
  (select embedding from transactions.payment_vectors
   where payment_id = &reference_id), cosine)
fetch first 5 rows only;
</copy>
```

**Expected:** five matching payments, excluding the reference, ordered by increasing distance. Ties may appear in a different order. A smaller cosine distance means greater similarity under the encoded features; it is not a currency amount, probability, or fraud score.

This is an exact nearest-neighbor query. Checking that the IVF index exists does not prove that this query uses it. Approximate index-search performance is outside this exercise.

## Optional Exercise: Compare Two Filters

Stay in the same SQL*Plus session. The following examples reuse your reference ID.

### Payments from the Same Account

```sql
<copy>
select payment_id, account_id, country_cd, amount,
       round(vector_distance(embedding,
         (select embedding from transactions.payment_vectors
          where payment_id = &reference_id), cosine), 6) distance
from transactions.payment_vectors
where account_id = (select account_id from transactions.payment_vectors
                    where payment_id = &reference_id)
  and payment_id <> &reference_id
order by vector_distance(embedding,
  (select embedding from transactions.payment_vectors
   where payment_id = &reference_id), cosine)
fetch first 5 rows only;
</copy>
```

The filter restricts the candidates to the reference account. The query returns up to five rows; fewer matches are possible for a small account sample.

### Similar Payments from a Different Country

```sql
<copy>
select payment_id, account_id, country_cd, amount,
       round(vector_distance(embedding,
         (select embedding from transactions.payment_vectors
          where payment_id = &reference_id), cosine), 6) distance
from transactions.payment_vectors
where country_cd <> (select country_cd from transactions.payment_vectors
                     where payment_id = &reference_id)
order by vector_distance(embedding,
  (select embedding from transactions.payment_vectors
   where payment_id = &reference_id), cosine)
fetch first 5 rows only;
</copy>
```

The country predicate changes the candidate set; cosine distance still ranks similarity. This is not a fraud classification.

## Completion

The prebuilt sample and index passed verification, and the similar-payment query returned results through True Cache. You can explain the reference payment, candidate filter, and meaning of distance. The two filtered searches are optional extensions.

Type `exit` to leave SQL*Plus, then `exit` to return to the host. In a LiveLabs sandbox, do not delete the reservation's stack or instances.

## Acknowledgements

* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
