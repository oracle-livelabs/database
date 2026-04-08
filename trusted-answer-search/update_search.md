# Lab 3: Trusted Continuous Improvement of Search

## Introduction
Trusted Answer Search is a dynamic system designed to improve continuously through **human oversight** and **structured feedback loops**., Unlike generic chatbots, this system allows application experts to review match outcomes and provide feedback that deterministically refines how the AI ranks relevant reports., This lab demonstrates how to manage your search domain and use the **Query Tester** to improve search accuracy.

**Estimated time:** 15 minutes.

### Objectives
*   Navigate to a Search Space and manage its versions.
*   Bulk-import search targets and parameter value sets via JSON.
*   Test natural-language queries and use user feedback to refine result rankings.

---

## Task 1: Navigate to the Search Space
To begin managing your search experience, you must first select the correct logical domain, or **Search Space**, in the administrative interface.,

1.  In the **Search Admin** application sidebar, click on **Search Spaces**.
2.  Select your desired search space from the list (e.g., `trusted_search`).
3.  The **Search Space Versions** screen will appear. This screen allows you to manage different iterations of your search domain, enabling you to work on **Draft** versions and perform regression analysis before promoting them to production.,

![Search Space Versions Screen](images/navigate-to-search-space.png)
* The **Search Space Versions** screen showing a draft version of the `trusted_search` space.*

---

## Task 2: Upload Search Targets and Value Sets
Instead of manually creating dozens of entries, you can use the **Import** feature to bulk-load your search metadata.

1.  On the **Search Space Versions** screen, click the **Import** button.,
2.  In the **Import** modal, ensure the correct **Search Space Version** is selected.
3.  Upload your **Search Targets** file (e.g., `search_target.json`). These targets represent the vetted reports and actions the system will link to.,
4.  Upload your **Target Value Sets** file (e.g., `target_value_set.json`). These define the parameter classes, such as dates or categories, that the system should extract from user queries.,,
5.  Click **Import** to populate your search space.

![Import Search Metadata](images/upload-search-targets.png)
* The **Import** modal used to populate a search space with targets and value sets via JSON files.*

---

## Task 3: Run and Refine a Search Query
The **Query Tester** allows you to simulate the user experience and provide the "human-in-the-loop" feedback necessary for continuous improvement.,

1.  Navigate to the **Query Tester** in the sidebar.
2.  **Run a search query:** Enter a natural-language question, such as: `Show total page views for all Wikimedia projects by month over the last 2 years.`
3.  **Review the initial ranking:** The system uses **AI Vector Search** to rank the most relevant targets., In this initial run, **"Total Page Views - All Projects"** appears as **Rank #1**.

![Initial Query Results](images/initial-ranking.png)
* The **Query Tester** showing initial rankings and extracted parameters (e.g., "monthly" and "2-year") for the Wikimedia query.*

4.  **Provide feedback:** If you determine that a different report is more appropriate for this specific phrasing, you can use feedback to demote the current top answer. Click the **Downvote** button on the **Rank #1** result.,
5.  **Re-run the query:** Execute the same search query again.
6.  **Verify the improvement:** Observe that the rankings have updated based on your feedback. The downvoted result has moved lower in the order, and a more relevant target, such as **"New Pages Creation Trend - All Projects"**, has now moved to **Rank #1**.

![Updated Ranking results](images/updated-ranking.png)
* The **Query Tester** showing updated rankings after the initial Rank #1 result was downvoted, demonstrating deterministic search improvement.*

You have successfully completed the **Trusted Answer Search** Live Lab! You now have the skills to deploy, curate, and continuously improve a secure, natural-language search interface.

---

## Acknowledgements

**Authors** 

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - April, 2026
