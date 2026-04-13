# Lab 8: Ask Your Data

## Introduction

This lab demonstrates prompt-to-SQL framing using deterministic, auditable query patterns.

Estimated Time: 8 minutes

### Objectives

In this lab, you will:
- Translate natural-language questions into SQL.
- Validate query grain, joins, and ordering.
- Keep analysis reproducible in FreeSQL.

## Task 1: Translate a Business Question to SQL

1. Start with this question: "What are the top 5 products by revenue?"

2. Run this SQL.

    ```
    <copy>
SELECT p.product_name,
       ROUND(SUM(oi.line_total), 2) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F12OsQqDMABE93zFjRXUodCpdGhjbC1qSqIUJ5GaIaBGNPb7m1IH6W13HPdOspTRAmM4TqZdXrYeml75BD8JXubRTpbZzuiw04OqrbFN5%252FnYezhLTOqthkWRWPAMZmrVVGur%252BhlGkztPcqyrM0bwfEPRLU6utPHk6mAPXKq%252FL4SLiIlvvsIQMUlJzAp6Q5wIWeDgfj6lA6TVkQQB4%252FQDk0%252BY59YAAAA%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

## Task 2: Validate Prompt-to-SQL Quality

1. Confirm each generated SQL pattern includes:

    - explicit join keys
    - clear row grain
    - deterministic ordering for top-N output

2. Optional follow-up question: "Which category has the most social-attributed revenue?"

## Task 3: Check Your Understanding

```quiz
Q: Why require deterministic ORDER BY for top-N SQL?
* It keeps repeated runs stable and comparable.
- It removes the need for GROUP BY.
- It increases row counts.
> Correct. Deterministic sorting improves trust in repeated analysis.

Q: Why enforce explicit join keys in prompt-generated SQL?
* It makes logic auditable and reduces hidden assumptions.
- It is only needed for graph queries.
- It prevents use of aggregate functions.
> Correct. Explicit joins are a core quality guardrail.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
