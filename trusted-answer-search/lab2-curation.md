# Curating the Mapping

## Introduction
Learn how to build the "language-to-report" foundation by defining search spaces and curated descriptions.

**Estimated time:** 25 minutes.

### Objectives
* Create a Search Space and Search Targets.
* Configure curated natural-language descriptions.
* Set up parameter extraction for value-specific answers.

## Task 1: Create a Search Space and Targets
Login to the **Search Admin** application. 
1.  Navigate to **Search Spaces** and create a new space (e.g., "Finance").
2.  Navigate to **Search Targets** and define a new target, such as "HSA Activity".
3.  Associate the target with a **match document (JSON)** containing the specific URL or report ID the application should trigger.

## Task 2: Add Sample Queries and Parameters
To allow the AI to find the right report, you must provide sample natural-language descriptions.
1.  Add sample questions to your target, such as "How is my HSA doing?"
2.  Configure **Target Value Sets** to identify parameters (like "checking" or "last Monday") from the user's query.
3.  Ensure these parameters are mapped to the match document so they can be used for automatic report filtering.

You may now **proceed to the next lab**

## Acknowledgements
**Authors**
* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - March, 2026

