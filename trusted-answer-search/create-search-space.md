# Lab 1: Create a Search Space and Import Reports

## Introduction

Create an empty space, import the configuration for existing brokerage reports, and test an imported target before adding your own.

Estimated Time: 5 minutes

### Objectives

* Create Brokerage Lab and its draft version.
* Import the existing report targets and value sets, then test a search query.

## Understand the Core Concepts

The following concepts describe the search configuration you will build in this workshop.

| Concept | Meaning in this workshop |
| --- | --- |
| **Search space** | A versioned collection of search targets for an application or domain. You will create **Brokerage Lab** to hold your brokerage search configuration. |
| **Search target** | A configured entry describing a destination users can find through search. **Open Stock Orders** will be your new target; its report webpage already exists. |
| **Target action** | The URL or SQL associated with a search target. In this lab, the action is a URL that the widget opens when the user selects the report. |
| **Target input** | A placeholder in the action that receives a resolved value. `:ORDER_SIDE` determines whether the report shows buy orders, sell orders, or all open orders. |
| **Target value set** | Defines how values are resolved for a target input. You will configure `BUY`, `SELL`, and `ALL`, with synonyms such as **purchases** for `BUY`. |
| **Search space version** | A particular version of the search configuration. You will configure and test a **draft**, then **publish** it for searches through the widget. |

After you configure the target and value set in Lab 2, a search for **"check purchases that have not gone through"** finds the **Open Stock Orders** target. The configured value set maps **purchases** to `BUY`, supplying the `:ORDER_SIDE` input in its URL action. Selecting the result opens the existing report with its buy-order view.

For more details, see [Core concepts in Oracle Trusted Answer Search](https://docs.oracle.com/en/database/oracle/oracle-database/26/otasc/trusted-answer-search-concepts.html).

## Task 1: Create Your Search Space

1. In Admin, open **Search Spaces** and select **Create Search Space**.
2. Paste the following into **Name**:

    ```text
    <copy>
    Brokerage Lab
    </copy>
    ```

    For **Give the initial version a label**, paste:

    ```text
    <copy>
    LiveLab Draft
    </copy>
    ```

    Leave the optional fields blank and select **Create**.
3. Select **Brokerage Lab** in the header's **Search Space** selector. Select **LiveLab Draft**, marked **Draft**, while configuring and testing. After you publish it, the same version label remains but its status becomes **Published**. Do not edit the installed **Demo Brokerage** sample.
4. Open **Settings** > **Search Space Settings**. For this fictional demo, set **Visibility** to **PUBLIC** if it is not already public, and save the search space settings. This allows the workshop website's widget to query the space after publication. Keep **Edit Published Versions?** off.

    Your new space starts empty. You do not need to enter all the existing reports by hand.

## Task 2: Import the Brokerage Reports

1. Return to **Search Spaces** and open the versions page for **Brokerage Lab**. Select **Import**.
2. Choose **LiveLab Draft** under **Search Space Version**. Upload the files downloaded in Get Started:

    | Import field | File |
    | --- | --- |
    | Search Targets | `search-targets.json` |
    | Target Value Sets | `target-value-sets.json` |

3. Leave **Delete Existing Search Targets & Target Value Sets?** unselected. Select **Import** once. Wait for the import to finish; if an **Import Status** message appears, check it for errors. The dialog may close when the import finishes. Verify the imported records in the next step before continuing; stop if an error appears or the expected counts are missing.
4. Open **Search Targets** and confirm the draft contains **20** targets, including **Market Lens**. Under **Target Value Sets**, confirm **five** sets were imported.

    The files register existing report URLs, descriptions, sample queries, and input mappings. Importing them does not create report webpages or copy brokerage account data into Trusted Answer Search. **Open Stock Orders** and `LAB_ORDER_SIDE` are deliberately absent: you will add them next.

## Task 3: Test a Search Query

1. Open **Query Tester**, choose **LiveLab Draft**, and search for:

    ```text
    <copy>
    Show me Oracle stock performance.
    </copy>
    ```

2. Find **Market Lens**. Check that its stock-ticker input is `ORCL`. Open **Target URL** to see the report, then return to Admin.

    The imported `STOCK_TICKERS` value set maps **Oracle** to `ORCL`. Next, build the same kind of connection yourself for a new report in **Lab 2: Add and Evaluate a Search**.

## Acknowledgements

**Authors:** Markus Kissling, Akshay S Kulkarni, and Kishy Kumar

**Last Updated Date:** October 2026
