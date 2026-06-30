# Lab 8: Ask Telecom Operations Data

## Introduction

Natural-language analytics is useful only when people can trust the path from question to answer. A telecom analyst may ask a plain-English question, but the business still needs to know which SQL ran and which data answered it.

This lab teaches that trusted-answer pattern without requiring you to configure a live GenAI provider.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | Business users need fast answers without waiting for a custom report. |
| Technical Challenge | Generated SQL can create governance risk when the logic is hidden or unbounded. |
| Persona Focus | Telecom business analyst, data engineer, and service assurance manager. |
| What You Will Learn | Approved views and visible SQL can ground natural-language answers in Oracle data. |
| Database Capability | Select AI pattern, read-only SQL, semantic views, governed execution. |
| Outcome | Users can ask business questions while keeping SQL evidence visible. |
{: title="What this lab covers"}

**Persona focus:** You are the data engineer showing how plain-English questions remain inspectable and database-grounded.

### Objectives

- Translate plain-English telecom questions into inspectable SQL paths.
- Review revenue and signal answers grounded in approved views.
- Explain why visible SQL makes natural-language analytics governable.

The image below is the Ask Telecom Operations Data workspace. A business analyst uses this area to ask operational questions without waiting for a custom report. The SQL in this lab shows what a trusted answer path should expose behind the screen.

![Ask data workspace](images/ask-data-workspace.png)

The concept diagram below introduces the trusted-answer pattern. It shows why natural-language analytics still needs visible SQL, read-only execution, and governed database views.

![Lab 8: Ask Telecom Operations Data concept diagram](images/trusted-answer-flow.svg)

## How This Lab Fits the Story

You switch from predefined reports to governed questions. The SQL examples show the transparent query path that should sit behind natural-language analytics, so a quick answer can still be inspected and defended.

## Scene Evidence

The image below shows the Show SQL mode. It gives analysts and reviewers a way to inspect how a natural-language question became a database query before they trust the result.

![Show SQL mode](images/show-sql-mode.png)

## Task 1: Answer a top-services question with SQL

1. Run this SQL block.

    This query represents the SQL path behind a plain-English revenue question. It joins service orders, order items, and services, then aggregates revenue and order count by service. The point is not only the answer; it is that the answer can be traced to approved views and joins.

    ```sql
    <copy>
    SELECT service_name,
       ROUND(SUM(service_value), 0) AS service_revenue,
       COUNT(*) AS service_orders
    FROM seer_comms_service_orders_v o
    JOIN order_items oi ON oi.order_id = o.service_order_id
    JOIN seer_comms_services_v s ON s.service_id = oi.product_id
    GROUP BY service_name
    ORDER BY service_revenue DESC
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    **Expected output: Revenue answer with visible SQL evidence**

    | Service Name | Service Revenue | Service Orders |
    | --- | ---: | ---: |
    | Fixed Wireless Home Internet | 184000 | 230 |
    | Device Upgrade Enrollment | 172000 | 216 |
    {: title="Revenue answer with visible SQL evidence"}

## Task 2: Answer a high-urgency signal question

1. Run this SQL block.

    This query represents the SQL path behind a plain-English subscriber-signal question. It groups subscriber signals by channel and reports volume, exposure, and escalations. That turns a business question about urgent channels into a governed aggregate over subscriber evidence.

    ```sql
    <copy>
    SELECT signal_channel,
       COUNT(*) AS signals,
       MAX(exposure_count) AS max_exposure,
       MAX(escalations) AS max_escalations
    FROM seer_comms_subscriber_signals_v
    GROUP BY signal_channel
    ORDER BY signals DESC;
    </copy>
    ```

    **Expected output: Signal-channel answer with visible SQL evidence**

    | Signal Channel | Signals | Max Exposure | Max Escalations |
    | --- | ---: | ---: | ---: |
    | threads | 1017 | 19937363 | 95869 |
    | twitter | 1012 | 19576775 | 98830 |
    {: title="Signal-channel answer with visible SQL evidence"}

## Task 3: Explain why Show SQL matters

1. Review the explanation and connect it to the lab evidence.

A governed natural-language interface should show the SQL it proposes and run read-only queries against Oracle. That visibility is the lesson: the answer is useful because a learner, analyst, or reviewer can inspect how it was produced.



## Learn More

- See `ORACLE_REFERENCE_LINKS.md` in the supporting files directory for official Oracle documentation links.

## Acknowledgements

- **Author** - Oracle LiveLabs Team
