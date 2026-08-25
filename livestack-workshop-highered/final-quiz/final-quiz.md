# Final Quiz

## Introduction

Use this quiz to check that you can connect the student-success outcome to the database evidence behind it.

### Objectives

- Check your understanding of the active workshop labs.

Estimated Time: **5 minutes**

## Task 1: Check your understanding

1. Which result helps a student-success team find a service when a student uses different words from the service catalog?

    - [ ] A spatial distance calculation
    - [x] An AI Vector Search similarity result
    - [ ] A JSON document projection
    - [ ] A model catalog inventory

    AI Vector Search compares the meaning of a student need with the meaning of stored service descriptions.

2. Why does JSON Relational Duality help the student-service request workflow?

    - [ ] It creates a second document copy for every request.
    - [ ] It removes the need for relational reporting.
    - [ ] It stores vectors outside the database.
    - [x] It lets applications use JSON while SQL works with the same governed request rows.

    The document and relational representations stay connected to one source of truth.

3. What should a planner do with a demand model probability?

    - [ ] Treat it as a guaranteed outcome.
    - [x] Use it to rank review work alongside service and student context.
    - [ ] Use it to replace staff judgment about the student.
    - [ ] Ignore the predicted label and all other evidence.

    A model probability supports prioritization. It is not certainty, and the probability for `SURGE` is not automatically confidence in a returned `STABLE` label.

4. What does the campus coverage query add to a support-routing decision?

    - [x] Distance and service-site capacity evidence
    - [ ] A student-document update
    - [ ] A graph traversal depth
    - [ ] A model-training label

    Oracle Spatial keeps proximity evidence close to the operational service rows.

5. What does the Property Graph query show in the support-network lab?

    - [ ] The physical distance between a student and a service site
    - [ ] A JSON request document for an application
    - [x] A named advocate-to-program relationship path
    - [ ] The probability of a demand label

    The graph query follows a `promotes` relationship from an advocate vertex to an academic-program vertex.

6. Why does the command-center lab include a drill-through query after the request summary?

    - [ ] To replace the summary KPI with a separate data copy
    - [x] To show the student and service rows that explain the request totals
    - [ ] To train the demand model automatically
    - [ ] To convert locations into JSON

    Drill-through keeps a dashboard metric reviewable by exposing the governed rows behind it.

7. What is the main benefit of the connected student-success foundation?

    - [ ] Every team must maintain a separate data copy.
    - [ ] The dashboard cannot be explained with SQL.
    - [ ] Only application developers can inspect support data.
    - [x] Teams can review relational, document, AI, relationship, location, and model evidence through one governed path.

    The workshop demonstrates a connected evidence path, not a collection of isolated features.

## Acknowledgements

* **Last Updated By/Date** - Oracle Database Product Management, August 2026
