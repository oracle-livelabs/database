# Vector Sample Recovery

## Introduction

Use this appendix only when the prebuilt sample or index fails verification in the vector-search lab. These recovery steps are separate from the normal learning path and are not additional required lab steps.

*Estimated Time:* 15 minutes, depending on the missing objects.

### Objectives

- Restore a missing vector sample from the existing PAYMENTS data.
- Create a missing cosine IVF index or rebuild an unusable one.

### Prerequisites

Use only the disposable workshop database, with the lab administrator's agreement. Primary must be healthy. Existing malformed tables, invalid vector dimensions, or a sample containing unexpected data require investigation; these commands do not repair those cases.

## Task 1: Connect to Primary

If you are still at the Primary SQL*Plus prompt from the vector-search lab, skip the two connection commands. Otherwise enter Primary from a host terminal:

```bash
<copy>
sudo podman exec -it prod /bin/bash
</copy>
```

At the container prompt:

```bash
<copy>
ORACLE_SID=ORCLCDB sqlplus / as sysdba
</copy>
```

At `SQL>`, select the PDB and inspect the existing sample definition.

```sql
<copy>
alter session set container=ORCLPDB1;
describe transactions.payment_vectors
</copy>
```

The expected columns are `PAYMENT_ID`, `ACCOUNT_ID`, `COUNTRY_CD`, `AMOUNT`, `CREATED_UTC`, and `EMBEDDING VECTOR(16, FLOAT32)`. If an existing table differs, stop; do not drop or replace it using this appendix.

## Task 2: Restore Only Missing Sample Data

If the table is absent, create it. The guard ignores only the name-already-exists error; other errors are raised.

```sql
<copy>
begin
  execute immediate 'create table TRANSACTIONS.PAYMENT_VECTORS (payment_id number primary key, account_id number, country_cd varchar2(8), amount number, created_utc timestamp, embedding vector(16, float32))';
exception
  when others then
    if sqlcode != -955 then raise; end if;
end;
/
</copy>
```

For a missing or incomplete sample, populate missing payment IDs. This inserts and commits rows; it does not replace existing vectors. The session uses a period as its decimal separator when formatting the vector values.

```sql
<copy>
alter session set nls_numeric_characters = '.,';
merge into TRANSACTIONS.PAYMENT_VECTORS target
using (
  select id, account_id, country_cd, amount, created_utc,
    to_vector('[' ||
      to_char(least(greatest(amount,0)/1000,1),'FM0.000') || ',' ||
      to_char(mod(account_id,1000)/1000,'FM0.000') || ',' ||
      to_char(ascii(substr(country_cd,1,1))/255,'FM0.000') || ',' ||
      to_char(ascii(substr(country_cd,2,1))/255,'FM0.000') || ',' ||
      to_char(extract(month from created_utc)/12,'FM0.000') || ',' ||
      to_char(extract(day from created_utc)/31,'FM0.000') || ',' ||
      to_char(extract(hour from created_utc)/24,'FM0.000') || ',' ||
      to_char(mod(id,997)/997,'FM0.000') || ',' ||
      to_char(mod(account_id,97)/97,'FM0.000') || ',' ||
      to_char(mod(id,89)/89,'FM0.000') ||
      ',0.100,0.080,0.060,0.050,0.040,0.030]') embedding
  from TRANSACTIONS.PAYMENTS
  where rownum <= 20000
) source
on (target.payment_id = source.id)
when not matched then insert
  (payment_id, account_id, country_cd, amount, created_utc, embedding)
  values
  (source.id, source.account_id, source.country_cd, source.amount, source.created_utc, source.embedding);
commit;
select count(*) vector_rows from TRANSACTIONS.PAYMENT_VECTORS;
</copy>
```

**Expected:** the workshop's 20,000-row sample. The source uses the first rows returned by `PAYMENTS`, not a guaranteed ordered set. If the source data or existing sample differs, do not repeatedly rerun the merge to force a count; ask the administrator to inspect it.

## Task 3: Restore the Index If Needed

Use this block only when the index is missing or unusable. It leaves an existing usable index unchanged.

```sql
<copy>
declare
  v_index_count number;
  v_index_status varchar2(20);
begin
  select count(*)
    into v_index_count
    from dba_indexes
   where owner = 'TRANSACTIONS'
     and index_name = 'PAYMENT_VECTORS_IVF_IDX';
  if v_index_count = 0 then
    execute immediate 'create vector index TRANSACTIONS.PAYMENT_VECTORS_IVF_IDX on TRANSACTIONS.PAYMENT_VECTORS (embedding) organization neighbor partitions distance cosine with target accuracy 90';
  else
    select status into v_index_status
    from dba_indexes
    where owner = 'TRANSACTIONS'
      and index_name = 'PAYMENT_VECTORS_IVF_IDX';
    if v_index_status = 'UNUSABLE' then
      execute immediate 'alter index TRANSACTIONS.PAYMENT_VECTORS_IVF_IDX rebuild online';
    end if;
  end if;
end;
/
select index_name, index_type, status
from dba_indexes
where owner = 'TRANSACTIONS'
  and index_name = 'PAYMENT_VECTORS_IVF_IDX';
</copy>
```

**Expected:** index status `VALID`. A different status or any Oracle error needs investigation before continuing.

Type `exit` to leave SQL*Plus, then `exit` to return to the host. Repeat the verification in [Semantic Cache with Vector Search](../vector-search/vector-search_dbw26.md) before running the searches.

## Acknowledgements

* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
