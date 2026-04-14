# Lab 3: Influencer Graph

## Introduction

This lab uses SQL-only network analysis patterns to approximate graph workflows in FreeSQL.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:
- Analyze direct influencer-to-influencer relationships.
- Approximate two-hop reach with relational SQL.
- Identify high-impact connectors for campaign planning.

## Task 1: Analyze Direct Influencer Links

This task inspects first-hop relationships between influencers. It matters because direct link strength is the simplest signal for immediate campaign amplification potential.

1. Run this SQL.

    ```
    <copy>
    SELECT i1.handle AS from_handle,
           i2.handle AS to_handle,
           ic.connection_type,
           ic.strength
    FROM influencer_connections ic
    JOIN influencers i1 ON i1.influencer_id = ic.from_influencer
    JOIN influencers i2 ON i2.influencer_id = ic.to_influencer
    ORDER BY ic.strength DESC
    FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F3WPwQ6CMBBE73zFfoCQ0MST8aClRAzSpCUxnIgpRZpgMVAP%252Fr0FDjSKe9vZN5NZAABOUoJzUGHQ3HTVSjhwqPvuUc7rxoNlFHIg060iIhCd1lIY1enSvJ8%252F58H0Ut9NM8kxoxdQum5fUgvZl4t3sOyEnGmSOYjVQ6DZWNjxqQr2Y%252FjUfNH%252FBKApAK0F2K%252B%252B7JRFhMGxcLtDRDieHyA5PkGcMJ4D2gKjV27D02Ln%252BT6h%252BAOk%252F%252BK9YgEAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Note which link types appear most often.

## Task 2: Approximate Two-Hop Reach

This step extends analysis from direct links to indirect network reach. It helps you model how influence can propagate beyond a single connection, which is central to the demo narrative.

1. Run this SQL.

    ```
    <copy>
SELECT a.handle AS seed_handle,
       c.handle AS reached_handle,
       COUNT(*) AS path_count,
       ROUND(AVG(e2.strength), 3) AS avg_path_strength
FROM influencer_connections e1
JOIN influencer_connections e2 ON e1.to_influencer = e2.from_influencer
JOIN influencers a ON a.influencer_id = e1.from_influencer
JOIN influencers c ON c.influencer_id = e2.to_influencer
GROUP BY a.handle, c.handle
ORDER BY path_count DESC, avg_path_strength DESC
FETCH FIRST 20 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F4WQ0U6DMBSG7%252FsU55IZ1mx4abyYpWwzk5qCml2RppwNklkMdD6%252FLYsMJcbe9Xz%252Fd3LyZ3zHWQ6KVsqUJ4RVBh1iWVy%252BIYHL0yPeotLVNMLES5oHNzMf%252BVC2KnRzNnbA0uE4WL2uA4xoZ1s0R1vNQrjtBfV5LHrpm5BEiieozeF0RqOxdduMQW3rxnSAS%252FIotumfOAKRuhC1TXGNwL0D9NA276Ph7z0dKO8qOlpdl15d%252Fq9qr%252BqpGv08hKxdF8%252FwsB9aD4d%252BiZAxl55dK4SYZyycVtTPScJztoFkK7McooWr%252BS1zZ%252Bz2d2Q%252B54J9AfSOXbHgAQAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Capture one seed_handle with broad indirect reach.

## Task 3: Check Your Understanding

Use these questions to confirm you can interpret network-style SQL results. The focus is on translating path metrics into practical marketing decisions.

```quiz
Q: Why does this lab use SQL joins for network analysis?
* FreeSQL MVP focuses on prompt-compatible SQL without Graph Studio dependencies.
- Joins are always more accurate than property graphs.
- SQL cannot model relationships.
> Correct. This is a practical SQL fallback for network reasoning.

Q: What does a high two-hop path_count suggest?
* The seed account can indirectly reach many accounts through intermediaries.
- The seed account has zero engagement.
- The seed account has no outgoing edges.
> Correct. Two-hop reach is a proxy for amplification potential.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
