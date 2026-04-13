# Lab 10: Cleanup

## Introduction

This lab removes all schema objects created during the workshop so you can reset your FreeSQL environment cleanly.

Estimated Time: 8 minutes

### Objectives

In this lab, you will:
- Review workshop objects before removal.
- Drop vector indexes, relational tables, constraints, and related metadata.
- Verify cleanup completed successfully.

## Task 1: Preview Objects That Will Be Removed

1. Run this SQL to see workshop objects before cleanup.

    ```
    <copy>
    SELECT object_type, object_name
    FROM user_objects
    WHERE object_name IN (
      'BRANDS','PRODUCTS','CUSTOMERS','INFLUENCERS','SOCIAL_POSTS',
      'ORDERS','ORDER_ITEMS','FULFILLMENT_CENTERS','INVENTORY',
      'INFLUENCER_CONNECTIONS','AGENT_ACTIONS','PRODUCT_EMBEDDINGS',
      'IDX_PRODUCT_EMBEDDINGS_IVF'
    )
    ORDER BY object_type, object_name;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F3VQu27DMAzc8xXc3ADJF3SyJSohIJGBJKfNRLSBlwJ9oEmH%252Fn0suW4CFF2IO92ROhIAIKFHk%252BH9%252BWU4nvX8%252FTGsZvL29DosRgu4KAG%252BTsOnTsqpvj5sMeKtF4jhrkoATRdbtqlZNbsotje5QNOnLAFjwcTO98hmYkkMtV53kopxniHRTnIFShlDYa73jrwPyFnNWOaB%252BxFLPFz7r3%252BoEeZxTxIu3nZTettf%252FpNRMXRoLfHmJgTZR%252F2rK%252B1dUy3LWmtC6A7%252FHvJ%252BsV6jmAtjgSCpcwEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Confirm the list matches your expected workshop objects.

## Task 2: Drop Workshop Objects (Tables, Indexes, Constraints, Model)

1. Run this cleanup script in FreeSQL using **Run Script (F5)**.

    ```
    <copy>
    DECLARE
    BEGIN
      -- Drop vector index if present
      FOR i IN (
        SELECT index_name
        FROM user_indexes
        WHERE index_name IN ('IDX_PRODUCT_EMBEDDINGS_IVF','IDX_PRODUCT_VEC','IDX_POST_VEC')
      ) LOOP
        EXECUTE IMMEDIATE 'DROP INDEX ' || i.index_name;
      END LOOP;

      -- Drop workshop tables (CASCADE CONSTRAINTS removes referential integrity)
      FOR t IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
          'PRODUCT_EMBEDDINGS','AGENT_ACTIONS','INVENTORY','INFLUENCER_CONNECTIONS',
          'SOCIAL_POSTS','INFLUENCERS','ORDER_ITEMS','ORDERS','CUSTOMERS',
          'FULFILLMENT_CENTERS','PRODUCTS','BRANDS'
        )
      ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
      END LOOP;

      -- Drop embedding model if loaded
      BEGIN
        DBMS_DATA_MINING.DROP_MODEL('ALL_MINILM_L12_V2');
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;

      -- Remove spatial metadata entries when present
      DELETE FROM user_sdo_geom_metadata
      WHERE table_name IN ('CUSTOMERS','FULFILLMENT_CENTERS');

      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Workshop cleanup complete.');
    END;
    /
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F5VTTXPaMBC98yv2ZpgpdJprTkJaqGb0wdgyoSeNEyvEU4wZ20namfz4ygKMk9J2esA8abWrp%252Fd2AQAYUkFiHHkIc1xyFRDAdAqsrg7w4h7aqoZin7sfUDzCoXaN27enUwsdQwFcwfi0AZCgQGqOCXafla6PLGIt4blxtQ1B1%252FSRu68Y4yAlVIw429hVrFlKjUU5R8a4WiaWrxfRp3fBNdLzjk6Oy8mp9gSE1qv%252BItwgTQ0ClxIZJx5FLNYrfx%252FDDUTw9gbF7MLj9pSIioU6t6MP6rxW9ffmyYM2u9%252B5BsaUJJQwBKpVYmLClUmgdmX14oO1e3S1167Idv6trdvWRftzMlCyvapkKP0nJY%252F3fhDykvG%252BIED0u55eObJEZSyhhnvWnZJq7Td0%252FC3ghUhRUYytf5PC86Fh0URTTkQQP3mX0q10zHwuNyj7VQdomhgtAx6WWqRiwYWQHSHqP8fDJ9YdnMdEsSTqc%252F7TaEPmAo9Gt7OBTn4dwTXzVmm8xOifjeDKe5fnxX4LZZW7XTcpuyrLXX46NxwtP3RzmVhGDLGSK2%252FCrONmpWYoxhERImwLacWXG7u%252BiSb99RuKq86AoeEKtPG2J2A6rFIhBmyHROPQh9AcstCCpWuzPGsz8C1ZF74%252FX5%252Fc%252FsN8e0Lotbv0W5NXduuq0p6zR39pvKHJV52d9PSolpKbM%252FGgj07NKjUz%252F7OCKxxHd%252Bdhe9i5bP%252Fs%252F6vysHOtm50VCg%252FuwOfRdIqa%252FgLmh9CO4QQAAA%253D%253D&code_language=PL_SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Confirm the script completes without errors.

## Task 3: Verify Cleanup

1. Run this SQL to confirm tables and indexes are removed.

    ```
    <copy>
    SELECT object_type, object_name
    FROM user_objects
    WHERE object_name IN (
      'BRANDS','PRODUCTS','CUSTOMERS','INFLUENCERS','SOCIAL_POSTS',
      'ORDERS','ORDER_ITEMS','FULFILLMENT_CENTERS','INVENTORY',
      'INFLUENCER_CONNECTIONS','AGENT_ACTIONS','PRODUCT_EMBEDDINGS',
      'IDX_PRODUCT_EMBEDDINGS_IVF'
    )
    ORDER BY object_type, object_name;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F3VQu27DMAzc8xXc3ADJF3SyJSohIJGBJKfNRLSBlwJ9oEmH%252Fn0suW4CFF2IO92ROhIAIKFHk%252BH9%252BWU4nvX8%252FTGsZvL29DosRgu4KAG%252BTsOnTsqpvj5sMeKtF4jhrkoATRdbtqlZNbsotje5QNOnLAFjwcTO98hmYkkMtV53kopxniHRTnIFShlDYa73jrwPyFnNWOaB%252BxFLPFz7r3%252BoEeZxTxIu3nZTettf%252FpNRMXRoLfHmJgTZR%252F2rK%252B1dUy3LWmtC6A7%252FHvJ%252BsV6jmAtjgSCpcwEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Optional model verification:

    ```
    <copy>
    SELECT model_name
    FROM user_mining_models
    WHERE model_name = 'ALL_MINILM_L12_V2';
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F1NQUFAIdvVxdQ5RyM1PSc2Jz0vMTeUCCiq4Bfn7KpQWpxbF52bmZealx4Pli8Fy4R6uQa5IGhRsFdQdfXzifT39PH18430MjeLDjNStuXR1Xf2dAcclE65jAAAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Task 4: Check Your Understanding

```quiz
Q: Why use `CASCADE CONSTRAINTS PURGE` in the cleanup script?
* It removes dependent referential constraints and purges dropped objects immediately.
- It preserves all foreign keys for next run.
- It creates new indexes automatically.
> Correct. This avoids leftover dependencies and recycle-bin clutter.

Q: Why verify with `USER_OBJECTS` after cleanup?
* It confirms all expected tables and indexes are actually removed.
- It rebuilds missing objects.
- It reloads the ONNX model.
> Correct. Verification prevents partial cleanup states.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
