# Risk and Operations Dashboard

## Introduction

Risk leaders rarely have time to inspect every signal one by one. They need to know which signals, products, and client exposures deserve review first. This lab recreates the evidence behind the application dashboard so each metric can be traced back to SQL.

The dashboard is the workshop's first decision surface. It summarizes monitored risk activity, exposure, transactions, and case pressure into measures that help risk leaders prioritize review.

In this lab, **exposure** means the reach or scale of monitored risk signals. A signal with low exposure may still matter, but a signal with high exposure can affect more clients, products, channels, or public attention. Exposure helps answer a practical question: if the team can only review a few issues right now, which ones could have the widest impact?

The key point is traceability. A dashboard can summarize the business, but the bank still needs to show where the numbers came from. Here, each metric is reproducible with SQL over finance views and source tables.

<details>
<summary><strong>Key terms: KPI, signal, criticality, exposure, and case</strong></summary>

> - A **KPI** is a key performance indicator. It is a summary measure that helps leaders understand the current operating picture quickly, such as transaction volume, exposure, high-risk signal count, or product review pressure. A useful KPI should still be traceable to the rows behind it.
>
> - A **risk signal** is an event, bulletin, alert, or observation that may deserve review. It is not automatically confirmed fraud or confirmed harm; it is a prompt for investigation. In this workshop, signals help Seer Bank decide which products, institutions, or client activities need attention first.
>
> - **Criticality** is a severity measure for a risk signal. Higher criticality means the signal appears more urgent or consequential, so the team may review it before lower-severity activity. Criticality helps prioritize work when there are more signals than people can inspect manually.
>
> - **Exposure** is the reach or scale of a signal or product risk. A highly exposed issue may affect more clients, higher transaction value, more products, more channels, or more public attention. Exposure helps answer, "How wide could the impact be if this risk is real?"
>
> - A **case** is follow-up work opened for review, investigation, or action. Cases turn a signal into operational work, such as analyst review, compliance escalation, client outreach, document handling, or service routing.

</details>

The image below is the Risk and Operations Dashboard. It is the daily operating view for a risk leader or product portfolio manager: KPI cards summarize transaction volume, revenue exposure, critical fraud signals, products under review, and AI decisions logged; charts show signal velocity and revenue exposure by product category; and the product table identifies where review should start. The SQL in this lab recreates the dashboard evidence so you can see how those business measures are calculated from governed data.

![Risk and Operations Dashboard page](images/risk-operations-dashboard.png " ")

### Objectives

- Calculate risk and exposure KPIs.
- Identify products with high signal exposure.

Estimated Time: **10 minutes**

### Business Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Risk teams need a shared view of exposure, transaction pressure, and case-processing capacity. |
| Technical Challenge | App and data teams need one explainable query path instead of separate pipelines for signals, products, transactions, and service data. |
| Persona Focus | Risk operations leaders read the dashboard; database and application developers show where the dashboard evidence comes from. |
| What You Will See | Dashboard metrics are database-backed and can be explained with SQL. |
| Database Capability | Converged SQL aggregates finance views, transaction data, service records, and audit tables. |
| Outcome | Operators can move from a dashboard KPI to trusted detail without changing systems. |

Persona focus: You support the risk operations leader by showing that one database query path can explain the dashboard instead of hiding work across integration layers.

## Task 1: Calculate risk signal KPIs

Start with the KPI query that explains the top-level dashboard numbers.

1. Run the dashboard aggregate query:

    > **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](/workshops/sandbox/index.html?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

    You are recreating the dashboard's headline risk measures directly from governed signal data. The SQL aggregates all rows in `RISK_SIGNALS_V`, calculates the average criticality, counts signals above the high-risk threshold, and sums exposure and case counts into one KPI row.

    `RISK_SIGNALS_V` is a view, not a raw table. It gives the dashboard a clean risk-signal shape with the columns this lesson needs: severity, exposure, case counts, product context, and signal timing. That is valuable because you can focus on what the dashboard metric means instead of hunting through several lower-level tables to find the same business fields.

    The exposure total shows the overall reach of the monitored risk activity. That helps distinguish a small number of isolated alerts from risk signals that may have broad client, product, or reputational impact.

    <details>
    <summary><strong>Why this matters: better than a separate reporting pipeline</strong></summary>

    > In a fractured environment, the application may store events in one system, the dashboard may calculate metrics in another, and analysts may investigate details somewhere else. If the numbers do not match, teams must spend time reconciling them.
    >
    > With Oracle Database, the dashboard summary and the detail rows can come from the same governed finance data. You can move from the KPI to the SQL behind it without leaving the database.

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
    The query compresses 5,000 monitored signals into the headline measures a risk leader would scan first: volume, average severity, high-risk count, total exposure, and opened cases. These values explain the top row of the dashboard without requiring a separate reporting store.

    A risk signal is a monitored event that may require review. In this workshop, signals can come from product mentions, customer activity, transactions, service pressure, or other finance operations data. The total signal count shows how much activity the dashboard is watching, while average criticality shows the overall severity of that activity.

    Exposure adds scale to severity. Criticality tells you how serious a signal appears; exposure tells you how widely that signal may matter. A lower-severity issue with very high exposure may still deserve attention because it can affect many clients, generate more cases, or draw operational and regulatory scrutiny.

    The high-risk count is the number of signals with a criticality score of 80 or higher. A higher count means more issues may need immediate analyst review, case triage, or operational follow-up. It does not mean every item is confirmed fraud or a confirmed incident; it means the dashboard has found more items that cross the bank review threshold.

## Task 2: Find top product exposure

Next, move from headline measures to the financial products driving monitored exposure.

1. Run this product exposure query:

    You are moving from dashboard totals to the products and institutions that drive review priority. The SQL joins product mentions, signal rows, finance products, and institutions, then groups by product.

    This query uses `finance_products_v` and `finance_institutions_v` because the dashboard needs business names and product categories, not just internal IDs. Those views turn product and institution records into reporting-friendly columns, so the returned rows can explain exposure in language a risk leader recognizes.

    Each returned row shows signal volume, average criticality, and exposure for a specific financial product. The `SUM(sp.views_count)` expression calculates exposure by adding the reach of all monitored signal events tied to the product.

    ```sql
    <copy>
    SELECT fp.financial_product_name,
           fi.institution_name,
           fp.product_category,
           COUNT(DISTINCT sp.post_id) AS signal_count,
           ROUND(AVG(sp.virality_score), 1) AS avg_criticality,
           SUM(sp.views_count) AS exposure_count
    FROM post_product_mentions ppm
    JOIN social_posts sp ON sp.post_id = ppm.post_id
    JOIN finance_products_v fp ON fp.financial_product_id = ppm.product_id
    JOIN finance_institutions_v fi ON fi.institution_id = fp.institution_id
    GROUP BY fp.financial_product_name, fi.institution_name, fp.product_category
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


2. Use the top rows to explain dashboard priority.
    This query joins signal events to financial products and institutions so the dashboard can move from "risk is rising" to "these products and institutions need attention." The grouping logic turns individual signal rows into a review queue that business users can understand.

    Each row shows a financial product associated with monitored risk signals. `Signal Count` is the number of distinct posts or events tied to the product. `Avg Criticality` shows how severe those signals are on average. `Exposure Count` estimates how many views or interactions those signals reached.

    Exposure is important because it changes prioritization. A product with many signals, high average criticality, and high exposure should move to the top of the dashboard review queue. That combination means the issue is showing up repeatedly, scoring as more severe, and reaching more people. For a financial institution, that can raise client, regulatory, reputational, or operational risk.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
