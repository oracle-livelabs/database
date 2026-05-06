# Lab 4: Fulfillment Map

## Introduction

This lab applies spatial SQL patterns for fulfillment-center ranking and routing decisions.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
- Compare center stock capacity.
- Compute customer-to-center distance candidates.
- Interpret routing tradeoffs between speed and availability.

## Task 1: Rank Inventory-Ready Centers

This task identifies which active centers can fulfill demand from current stock. It is important because fulfillment decisions must account for real inventory, not just geography.

1. Run this SQL.

    ```
    <copy>
    SELECT fc.center_name,
           fc.city,
           fc.state_province,
           SUM(i.quantity_on_hand - i.quantity_reserved) AS available_units
    FROM fulfillment_centers fc
    JOIN inventory i ON i.center_id = fc.center_id
    WHERE fc.is_active = 1
    GROUP BY fc.center_name, fc.city, fc.state_province
    ORDER BY available_units DESC;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F2WQwU7EIBRF9%252FMVd6mJnWTWxoV20NE4YqgT44pg%252BxpfwlAFSjJ%252FL8WoY2XHvRx4BwBoxL2on9C3y5ZcJK%252Bd2dPZAr9rqjge5lmIJpJ%252B90Ni1%252F4lmt32hJcfo3Exg3pw%252Bs24DhWOQk%252BBfKLuFJcNTDJszaslPTqOodx1reQW%252FWh7tnafR9Nf84X8dunv5O0D2KWcDv4AhszbbwnucHHkxF1BnjdCiSnmoE0bOVE%252BtSrVjZK7R1y9zD%252Fix%252F6%252FcuGkWgs1cTMFrEVTny%252BqSsj6E9efETpnAQAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Identify which center has the highest available_units.

## Task 2: Build a Distance-Aware Candidate List

Here you layer spatial distance onto fulfillment options to create routing candidates. This mirrors the demo's operational tradeoff between speed and availability.

1. Run this SQL.

    ```
    <copy>
SELECT c.customer_id,
       c.city AS customer_city,
       fc.center_name,
       fc.city AS center_city,
       ROUND(SDO_GEOM.SDO_DISTANCE(c.location, fc.location, 0.005, 'unit=MILE'), 2) AS distance_miles
FROM customers c
CROSS JOIN fulfillment_centers fc
WHERE c.location IS NOT NULL
  AND fc.location IS NOT NULL
  AND fc.is_active = 1
ORDER BY distance_miles
FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F22QUWvDIBSF3%252F0V960tpCEr9Gn0IY12dSQKail9CsEaEEwC0wz272cIS1c2n%252FQczz0fV5KSFAp0qkcfhs581PaeIJhPVG34glzC4k7C4rfxg%252BlDlPumM0%252FyT262n1KCXxheS8zrN8KrdLpgKlXOCrLWqRt0E%252BzQJ9OYxyNLs2yfwGrsbThUtCSrTQK7zdRxtz40vTZ1Z53x6CR4tfB60KgQXEp455RBO7rWOtdFqnpG87EGXc9EEHjUAZXAuAJ2KctInTP8G%252BZ%252F1%252Fq60cF%252BGjjAC%252BICEwHH2x84oooznKiQCnb7uIqrBM7K2yvabgkvvgE2EVV1jgEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Record the nearest center for at least two customers.

## Task 3: Check Your Understanding

Use this checkpoint to validate your routing logic. Strong fulfillment decisions come from combining inventory and distance, not optimizing either in isolation.

```quiz
Q: Why combine distance and inventory in fulfillment SQL?
* Operations decisions need both service speed and stock readiness.
- Distance alone guarantees availability.
- Inventory alone guarantees on-time delivery.
> Correct. Real routing balances both constraints.

Q: Why are location columns stored as SDO_GEOMETRY points?
* They enable native spatial distance calculations in SQL.
- They are required for JSON generation.
- They automatically create shipments.
> Correct. Spatial types support direct geospatial reasoning in queries.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
