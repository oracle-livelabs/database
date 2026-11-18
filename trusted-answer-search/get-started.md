# Get Started

## Introduction

Estimated Time: 2 minutes

### Objectives

* Locate the prepared Admin, Demo Brokerage, and Workshop Files applications.
* Download the import files and verify the Open Stock Orders report.

## Open the Prepared Applications

> **Using a LiveLabs sandbox?** When you receive the environment-ready email, open **My Reservations** and select **Launch Workshop**. Open **View Login Info** > **Environment Details** to find your **Admin URL**, **Demo Brokerage URL**, **Workshop Files URL**, and application login.

1. Open **Admin URL**, **Demo Brokerage URL**, and **Workshop Files URL** in separate tabs. Copy the supplied application username and password into the Admin sign-in form, then sign in.

    | Tab | What you will do there |
    | --- | --- |
    | Admin | Configure, test, and evaluate search. |
    | Demo Brokerage | Search as a customer after publishing your space. |
    | Workshop Files | Download the sample configuration and open the new report. |

2. From **Workshop Files**, download `search-targets.json`, `target-value-sets.json`, and `brokerage-quick-check.json`. Note where your browser saves them; you will select them for import later. Keep the files unchanged. Their report URLs are prepared for your workshop website. If your browser adds a filename suffix such as `(1)`, use those newly completed downloads for this reservation, not an older copy.
3. On **Workshop Files**, find the **Open Stock Orders** heading and select **Open the report**. The report opens in a new tab.
4. Check that **Order side** shows **All open orders**. The report should list **four orders: two buys and two sells**.

Keep the report tab open. Later, you will use its URL as the destination for your new search target.

A search space holds report destinations (search targets) and the allowed input values (target value sets). You will create **Brokerage Lab**, edit its draft, and publish it for the widget. The widget is already connected to that exact space name; use it as written. It will not return your space's results until you publish.

Continue to **Lab 1: Create a Search Space and Import Reports**.

> **Using your own environment?** Download Trusted Answer Search from the [Oracle Trusted Answer Search website](https://www.oracle.com/database/trusted-answer-search/) and follow the extracted ZIP's `README.md`. The workshop owner must prepare the website, report, workshop downloads, and widget connection described in the workshop setup notes before the exercise.

## Acknowledgements

**Authors:** Markus Kissling, Akshay S Kulkarni, and Kishy Kumar

**Last Updated Date:** November 2026
