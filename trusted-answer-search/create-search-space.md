# Create a Search Space and Import Reports

## Introduction

Create an empty space, import the configuration for existing brokerage reports, and test an imported target before adding your own.

Estimated Time: 5 minutes

### Objectives

* Create Brokerage Lab and its draft version.
* Import the existing report targets and value sets, then test an imported search.

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

## Task 3: Try an Imported Search

1. Open **Query Tester**, choose **LiveLab Draft**, and search for:

    ```text
    <copy>
    Show me Oracle stock performance.
    </copy>
    ```

2. Find **Market Lens**. Check that its stock-ticker input is `ORCL`. Open **Target URL** to see the report, then return to Admin.

The imported `STOCK_TICKERS` value set maps **Oracle** to `ORCL`. Next, build the same kind of connection yourself for a new report in **Add and Evaluate a Search**.

## Acknowledgements

**Authors:** Markus Kissling, Akshay S Kulkarni, and Kishy Kumar

**Last Updated Date:** October 2026
