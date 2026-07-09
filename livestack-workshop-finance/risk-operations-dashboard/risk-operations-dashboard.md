# Risk and Operations Dashboard

## Introduction

Risk leaders cannot inspect every signal one by one. They need to know which signals, products, and client exposures deserve review first. This lab shows the SQL behind the dashboard numbers.

The dashboard is the first place a risk leader looks. It summarizes monitored risk activity, exposure, transactions, and open case work.

In this lab, **exposure** means the reach or scale of monitored risk signals. A signal with low exposure may still matter. A signal with high exposure can affect more clients, products, channels, or public attention. Exposure helps answer a practical question: which issues could have the widest impact?

The key point is traceability. A dashboard can show a number, but the bank still needs to show where that number came from. In this lab, SQL shows the rows behind the dashboard.

<details>
<summary><strong>Key terms: KPI, signal, criticality, exposure, and case</strong></summary>

> - A **KPI** is a key performance indicator. It is a summary measure that helps leaders understand the current operating picture quickly, such as transaction volume, exposure, high-risk signal count, or product review pressure. A useful KPI also needs a way to check the rows behind it.
>
> - A **risk signal** is an event, bulletin, alert, or observation that may deserve review. It is not automatically confirmed fraud or confirmed harm. In this workshop, signals help Seer Bank decide which products, institutions, or client activities need attention first.
>
> - **Criticality** is a severity measure for a risk signal. Higher criticality means the signal appears more urgent or consequential, so the team may review it before lower-severity activity. Criticality helps prioritize work when there are more signals than people can inspect manually.
>
> - **Exposure** is the reach or scale of a signal or product risk. A highly exposed issue may affect more clients, higher transaction value, more products, more channels, or more public attention. Exposure helps answer, "How wide could the impact be if this risk is real?"
>
> - A **case** is follow-up work opened for review, investigation, or action. Cases turn a signal into operational work, such as analyst review, compliance escalation, client outreach, document handling, or service routing.

</details>

The image below is the Risk and Operations Dashboard. It is the daily view for a risk leader or product portfolio manager. KPI cards summarize monitored signal volume, exposure, high-risk signals, product review pressure, and opened cases. Charts show signal volume and exposure by product category. The product table shows where review starts.

![Risk and Operations Dashboard page](images/risk-operations-dashboard.png " ")

### Objectives

- Calculate risk and exposure KPIs.
- Review product-linked risk signal rows.
- Identify products with high signal exposure.

Estimated Time: **12 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Risk teams need a shared view of exposure, transaction pressure, and case-processing capacity. |
| Technical Challenge | App and data teams need one SQL path for signals, products, transactions, and service data. |
| Persona Focus | Risk operations leaders read the dashboard; database and application developers show where the dashboard evidence comes from. |
| What You Will See | Dashboard metrics can be checked with SQL. |
| Database Capability | SQL aggregates risk-signal views with product and institution details. |
| Outcome | Operators can start with a dashboard KPI and inspect the related detail rows. |

Persona focus: You support the risk operations leader by showing the SQL behind the dashboard numbers.

## Task 1: Calculate risk signal KPIs

Start with the KPI query that explains the top-level dashboard numbers.

1. Run the dashboard aggregate query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](/workshops/sandbox/index.html?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are recreating the main dashboard risk measures from signal data. The SQL counts all rows in `RISK_SIGNALS_V`. It also calculates average criticality, counts high-risk signals, and sums exposure and opened cases.

    `RISK_SIGNALS_V` is a view, not a raw table. It gives the dashboard the columns this lesson needs: severity, exposure, case counts, product context, and signal timing.

    The exposure total shows the overall reach of the monitored risk activity. It helps separate isolated alerts from signals that may affect many clients or products.

    <details>
    <summary><strong>Why this matters: better than a separate reporting pipeline</strong></summary>

    > In a fractured environment, the application may store events in one system, the dashboard may calculate metrics in another, and analysts may investigate details somewhere else. If the numbers do not match, teams must spend time reconciling them.
    >
    > With Oracle Database, the dashboard summary and the detail rows can come from the same finance data. You can start with the KPI and then inspect the rows behind it.

    </details>

    ```sql
    <copy>
    SELECT COUNT(*) AS total_signals,
           ROUND(AVG(criticality_score), 1) AS avg_criticality,
           SUM(CASE WHEN criticality_score >= 80 THEN 1 ELSE 0 END) AS high_risk_signals,
           SUM(exposure_count) AS total_exposure,
           SUM(cases_opened_count) AS cases_opened
    FROM risk_signals_v;
    </copy>
    ```

    **Expected output: Dashboard KPI Summary**

    | Total Signals | Avg Criticality | High Risk Signals | Total Exposure | Cases Opened |
    | --- | --- | --- | --- | --- |
    | 5000 | 41.2 | 9 | 1602966769 | 5657933 |


2. Interpret the result.
    The query summarizes 5,000 monitored signals. It returns the measures a risk leader would scan first: volume, average severity, high-risk count, total exposure, and opened cases.

    A risk signal is a monitored event that may require review. In this workshop, signals can come from product mentions, customer activity, transactions, service pressure, or other finance operations data.

    Exposure adds scale to severity. Criticality tells you how serious a signal appears. Exposure tells you how widely that signal may matter. A lower-severity issue with very high exposure may still deserve attention.

    The high-risk count is the number of signals with a criticality score of 80 or higher. A higher count means more issues may need analyst review, case triage, or follow-up. It does not mean every item is confirmed fraud. It means more items crossed the bank review threshold.

## Task 2: Review product-linked risk signal rows

Dashboard KPIs help show where risk is rising. Next, look at the product-linked signal rows an analyst would investigate first.

1. Run this product-linked signal query:

    This query starts with `RISK_SIGNALS_V`. It keeps signals with a score of 80 or higher, then joins to product and institution views. That threshold matches the high-risk count from Task 1.

    `POST_PRODUCT_MENTIONS` is a bridge table. It connects a signal to the financial products mentioned by that signal.

    The query uses readable aliases: `signals`, `mentions`, `products`, and `institutions`. It also uses `ORDER BY ... FETCH FIRST` so Oracle returns the same top-10 order each time.

    ```sql
    <copy>
    SELECT signals.signal_id,
           signals.criticality_score,
           signals.exposure_count,
           signals.cases_opened_count,
           products.financial_product_name,
           institutions.institution_name,
           products.product_category
    FROM risk_signals_v signals
    JOIN post_product_mentions mentions
         ON mentions.post_id = signals.signal_id
    JOIN finance_products_v products
         ON products.financial_product_id = mentions.product_id
    JOIN finance_institutions_v institutions
         ON institutions.institution_id = products.institution_id
    WHERE signals.criticality_score >= 80
    ORDER BY signals.criticality_score DESC, signals.exposure_count DESC, signals.signal_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: Product-Linked Risk Signals**

    | Signal Id | Criticality Score | Exposure Count | Cases Opened Count | Financial Product Name | Institution Name | Product Category |
    | --- | --- | --- | --- | --- | --- | --- |
    | 1 | 96 | 12560000 | 1260 | AML Screening Package | Clearwater Credit Union | Compliance Services |
    | 2 | 92 | 8840000 | 980 | Wire Transfer Service | Clearwater Credit Union | Payments |
    | 3 | 88 | 6420000 | 740 | Rate Hedge Advisory | Harvest Commercial Bank | Capital Markets |
    | 4479 | 87 | 17564089 | 9719 | CECL Reserve Scenario | Greenline Asset Management | Risk Analytics |
    | 5 | 83 | 2630000 | 410 | Commercial Real Estate Loan | Granite Wealth | Commercial Lending |
    | 6 | 81 | 1710000 | 290 | Real-Time Payments Service | SecureLedger Compliance | Payments |
    | 7 | 80 | 980000 | 180 | Adjustable Rate Mortgage | NorthBridge Investments | Mortgage Lending |


2. Review the product-linked rows.
    Each row connects a risk signal to a financial product. Start with the first row. Ask three questions: which product is involved, which institution owns it, and what type of product is it?

    `Criticality Score` shows how serious the signal is. `Exposure Count` shows how widely the signal may affect customers, accounts, or operations. `Cases Opened Count` shows how much follow-up work already exists.

    An analyst usually starts with rows that combine high criticality, high exposure, and many opened cases. Those rows point to products that may need faster review, extra staffing, or closer monitoring.

## Task 3: Find top product exposure

Next, summarize the products tied to monitored exposure.

1. Run this product exposure query:

    You are grouping risk signals by financial product. The SQL joins risk-signal rows to product mentions, finance products, and institutions.

    This query uses `finance_products_v` and `finance_institutions_v` so the result shows business names and product categories, not just internal IDs.

    Each row shows signal volume, average criticality, and exposure for one financial product. The query uses `risk_signals_v.criticality_score` and `risk_signals_v.exposure_count`. That keeps the result in finance risk terms.

    ```sql
    <copy>
    SELECT products.financial_product_name,
           institutions.institution_name,
           products.product_category,
           COUNT(DISTINCT signals.signal_id) AS signal_count,
           ROUND(AVG(signals.criticality_score), 1) AS avg_criticality,
           SUM(signals.exposure_count) AS exposure_count
    FROM risk_signals_v signals
    JOIN post_product_mentions mentions
         ON mentions.post_id = signals.signal_id
    JOIN finance_products_v products
         ON products.financial_product_id = mentions.product_id
    JOIN finance_institutions_v institutions
         ON institutions.institution_id = products.institution_id
    GROUP BY products.financial_product_name, institutions.institution_name, products.product_category
    ORDER BY avg_criticality DESC, exposure_count DESC
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    **Expected output: Top Product Exposure**

    | Financial Product Name | Institution Name | Product Category | Signal Count | Avg Criticality | Exposure Count |
    | --- | --- | --- | --- | --- | --- |
    | Carbon Credit Custody | IPA Direct Finance | Carbon Markets | 51 | 46 | 30212024 |
    | Auto Loan Digital Offer | NorthBridge Investments | Consumer Lending | 48 | 45.9 | 66064101 |
    | KYC Refresh Workflow | NorthBridge Investments | Compliance Services | 41 | 45.6 | 37993643 |
    | Managed ETF Portfolio | Horizon Capital | Wealth Management | 29 | 45.3 | 52445042 |
    | Loan Portfolio Review | LedgerGrade Connect | Risk Analytics | 45 | 45.1 | 42518770 |
    | 529 Education Savings Plan | Harvest Commercial Bank | Investments | 41 | 45 | 20763811 |
    | Small Business Term Loan | Meridian Trust Bank | Commercial Lending | 40 | 44.6 | 15504074 |
    | Corporate Card Program | Horizon Capital | Cards and Payments | 37 | 44 | 4680777 |
    | Mortgage Pre-Approval | NorthBridge Investments | Mortgage Lending | 46 | 43.9 | 23334598 |
    | Digital Wallet Account | SecureLedger Compliance | Payments | 48 | 43.8 | 37616607 |


2. Review the product summary rows.
    Look at the first few rows in the result. These are the products with the strongest mix of signal volume, average criticality, and exposure.

    `Signal Count` shows how many monitored signals are tied to the product. `Avg Criticality` shows how severe those signals are on average. `Exposure Count` shows the scale of the monitored exposure tied to those signals.

    Review products with many signals, high average criticality, and high exposure first. That mix means the issue appears often, scores as more severe, and may affect more clients or business activity.

    For a production dashboard, review the execution plan for each KPI query. Useful indexes usually support the filter and join columns used here: `CRITICALITY_SCORE`, `SIGNAL_ID`, `POST_ID`, `PRODUCT_ID`, `FINANCIAL_PRODUCT_ID`, and `INSTITUTION_ID`.

    A materialized view may help when many users run the same dashboard totals. Product-level exposure totals by institution and category could be precomputed for faster dashboard response.

    This lab uses direct SQL instead of a materialized view so the calculation stays visible. KPI totals come from `RISK_SIGNALS_V`. Product-linked rows use the same signal view and join to product details. Product exposure joins back to product and institution context. In production, teams can keep the same logic and move repeated totals into indexed tables or materialized views.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
