# Lab 8: Cleanup

## Introduction

This lab removes all schema objects created during the workshop so you can reset your FreeSQL environment cleanly.

Estimated Time: 8 minutes

### Objectives

In this lab, you will:
- Review workshop objects before removal.
- Drop relational tables, constraints, and related metadata.
- Verify cleanup completed successfully.

## Task 1: Preview Objects That Will Be Removed

This preview step makes cleanup intentional and verifiable. It is important because you should always confirm scope before dropping workshop objects.

1. Run this SQL to see workshop objects before cleanup.

    ```
    <copy>
    SELECT object_type, object_name
    FROM user_objects
    WHERE object_name IN (
      'BRANDS','PRODUCTS','CUSTOMERS','INFLUENCERS','SOCIAL_POSTS',
      'ORDERS','ORDER_ITEMS','FULFILLMENT_CENTERS','INVENTORY',
      'INFLUENCER_CONNECTIONS','AGENT_ACTIONS'
    )
    ORDER BY object_type, object_name;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F3WQyw7CIBBF937F7KqJf%252BCKUlASYBoemq6IGjYmPmLrwr8XqE3duJncO%252FfMTAAAwDLJqIP76RLPQxjej7iezO14jYuEADeo4NXHZxiTvnQPO2bYLwtCw7JEAFVtiG5sta5ag42nLkvqrUPFTNZCc%252BmZpqOzSAWRoUWbwWkHmmaMiwjCMZUd95ILKRXTLtBUpoX7pNF08%252Fx8I1DUOr1ToM4s2eZZ8vUFX5VaDkHd%252Ff2PzQfFDLluNAEAAA%253D%253D&code_language=SQL&code_format=false"
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

## Task 2: Drop Workshop Objects (Tables and Constraints)

This task performs the teardown needed for a clean rerun environment. It removes dependent objects in a controlled order so future lab runs start from known state.

1. Run this cleanup script in FreeSQL using **Run Script (F5)**.

    ```
    <copy>
    DECLARE
    BEGIN
      

      -- Drop workshop tables (CASCADE CONSTRAINTS removes referential integrity)
      FOR t IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
          'AGENT_ACTIONS','INVENTORY','INFLUENCER_CONNECTIONS',
          'SOCIAL_POSTS','INFLUENCERS','ORDER_ITEMS','ORDERS','CUSTOMERS',
          'FULFILLMENT_CENTERS','PRODUCTS','BRANDS'
        )
      ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
      END LOOP;

      

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
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F31SwW7jIBC95yvm5kTaph%252FQE4FxFgmDBXi7e0Juy7ZRYzvCdKuV%252BvFLHNvrqlUPNm9meI9hHgAADKkgGlcJwg73XA4IYDWuV1fAQneC1y48908JxPru6HtYU2IoYQhUSWM14dIaCL7p%252FqRi8L998G081Ec4tNE%252FhkP8uxkVc6UhApewHhMABgVSe5F2bd34uZJrVcBL74O7nDsXbr%252BjxgXjvSBARvYorSPU8tRg9i3j8kdKKP1rwLmoUFLULrUvcdq05BtFORGuVMaad5RzpDRLXG6xmKMzoJWxqhjwUiqvRM6FKM4N0fS7bC61YhUdxHeaSGaymTONagNCqXJO40%252BklUXgRYGMk4QyplUJluxEwvD2BnG7GEmKM%252FjMp7LSe8xuRmGUbDjnZvXRez04Cv2pHsxsfKwf6lhDMjccktOvT76FU%252FB9SowslsxMrf13rn%252Fo3KPvGjexV19YuJzhp4PbzG1SVRTcTrdgu8I4Vdmystv0OcElrrPb6dneH33dvqS1a05HH%252F32LDTe%252FgKu%252FwEXLMo8DwMAAA%253D%253D&code_language=PL_SQL&code_format=false"
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

This verification confirms teardown was complete across expected schema objects. It prevents partial resets that can cause hidden setup issues later.

1. Run this SQL to confirm workshop tables are removed.

    ```
    <copy>
    SELECT object_type, object_name
    FROM user_objects
    WHERE object_name IN (
      'BRANDS','PRODUCTS','CUSTOMERS','INFLUENCERS','SOCIAL_POSTS',
      'ORDERS','ORDER_ITEMS','FULFILLMENT_CENTERS','INVENTORY',
      'INFLUENCER_CONNECTIONS','AGENT_ACTIONS'
    )
    ORDER BY object_type, object_name;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F3WQyw7CIBBF937F7KqJf%252BCKUlASYBoemq6IGjYmPmLrwr8XqE3duJncO%252FfMTAAAwDLJqIP76RLPQxjej7iezO14jYuEADeo4NXHZxiTvnQPO2bYLwtCw7JEAFVtiG5sta5ag42nLkvqrUPFTNZCc%252BmZpqOzSAWRoUWbwWkHmmaMiwjCMZUd95ILKRXTLtBUpoX7pNF08%252Fx8I1DUOr1ToM4s2eZZ8vUFX5VaDkHd%252Ff2PzQfFDLluNAEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>


## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
