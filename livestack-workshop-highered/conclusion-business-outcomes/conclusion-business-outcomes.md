# Conclusion: From Student Signal to Support Action

## Introduction

You followed a student who needed help choosing courses and meeting an advisor. You began by reviewing the shared student-success data and finding where requests were building. You matched the student's words to available services, explored the people and programs that could help, and compared campus locations with current capacity.

You also worked with a request as both an application-ready JSON document and normal relational rows. You created a new request, updated its status, and confirmed the change with SQL. Finally, you used Oracle Machine Learning to rank service demand and identify model results that deserved staff attention.

The workshop does not decide what should happen to a student. It brings the request, services, people, locations, and predictions together so campus staff can understand the situation and choose the next step.

### Objectives

- Summarize the student-support story and the activities completed in each lab.
- Explain how one connected data foundation helps campus teams respond to student needs.

Estimated Time: **5 minutes**

## Task 1: Review the student-support journey

1. Use this table to review what you accomplished across the workshop.

    | Lab | What You Did | Why It Matters |
    | --- | --- | --- |
    | Student Success Data Foundation | Identified the database objects used by the workshop and compared support pressure across academic programs. | Campus teams start with the same view of students, services, requests, and demand. |
    | Student Success Command Center | Summarized request queues and opened the high-demand requests behind the totals. | Staff can move from a dashboard number to the students and services that may need attention. |
    | Unified Student Request Intelligence | Read a request as JSON, enabled document inserts, created a request, verified its relational rows, and updated its status. | Applications and analysts can work with the same request without maintaining separate copies. |
    | Student Intent and Support Signals | Matched a course-planning question to services, then changed the question to financial-aid help and compared the ranking. | A student's own words can help staff find relevant services even when the wording differs from the catalog. |
    | Advisor, Program, and Support Network | Explored direct support connections and focused the network on one academic program. | Staff can see which people and programs may help coordinate follow-up. |
    | Campus Service Coverage | Compared distance and capacity, then added a capacity guardrail to the search. | The closest location is not always the best choice when a site is already busy. |
    | Student Success OML Analytics | Scored service demand and found places where the model prediction differed from the observed label. | Staff can prioritize what to review while keeping the final decision with people. |

    Together, these activities form a practical student-support workflow: notice a need, find a suitable service, understand who and where can help, update the request, and decide what deserves attention first.

## Task 2: Describe the outcome for each persona

1. Choose the outcome that matters most to the person you are speaking with.

    | Persona | Workshop Outcome |
    | --- | --- |
    | Student-success leader | Sees where demand is building and which services may need attention. |
    | Advisor or service planner | Combines the student's need with service options, support relationships, location, and capacity before following up. |
    | Application developer | Creates and updates application-friendly request documents while reporting from the same underlying data. |
    | Database developer | Uses SQL to connect student records, JSON requests, meaning-based search, relationships, locations, and model results. |
    | AI engineer | Keeps service matching and demand scoring connected to current request and service information. |

    When requests, service catalogs, relationships, locations, and predictions sit in separate systems, campus teams must compare different copies before they can help. Oracle AI Database keeps that information together, so each role can work from the same student and service context using the tools suited to its job.

## Learn More

- [Oracle AI Vector Search documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/)
- [Oracle JSON Relational Duality documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/jsnvu/)
- [Oracle Property Graph documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/spatl/)

## Acknowledgements

* **Last Updated By/Date** - Oracle Database Product Management, August 2026
