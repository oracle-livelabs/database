# Build Student Success Intelligence with Oracle AI Database 26ai

## Introduction

Student-success teams must see pressure early. Pressure can appear as a rise in advising requests, a capacity gap, a student signal, or a helpful relationship. Separate systems make those decisions harder.

In this workshop, you work with **Seer Higher Education**, a fictional institution. It uses Oracle AI Database 26ai as one student-success foundation. You will follow a student who needs course-planning and advising help. You will trace that need through the request queue, service matching, relationships, coverage, a request document, and a demand score.

The LiveStack Demo image shows the broader operational workflow. The labs use a compact, repeatable dataset and SQL to explain the governed evidence behind each decision.

You will also complete short interactive investigations. After you run a baseline query, you will change one business question, compare the evidence, and make a review recommendation. Complete solutions stay inside collapsed **Challenge answer** sections so you can try each change first.

![How fragmented student-success data becomes one governed foundation](images/highered-converged-data-foundation.svg " ")

Arrows beside expandable sections reveal optional context. Select an arrow for a definition or deeper explanation. The main task remains visible.

![An expandable details section before and after it is opened](images/details-accordion-expand-flow.png " ")

<details>
<summary><strong>Learn more: What does a converged database mean here?</strong></summary>

> A converged database keeps relational records, JSON documents, AI vectors, graph relationships, spatial data, and model results near the same student-success data.
>
> That reduces copies of sensitive operational information and gives advising, service, application, and analytics teams one repeatable evidence path.

</details>

The journey follows one operating loop. Establish the foundation. Identify demand. Match a need to a service. Add relationship and location context. Inspect the request. Then prioritize human review. The conclusion returns to this path.

### Objectives

- Explain how a connected Oracle AI Database foundation supports student-success decisions.
- Query relational, JSON, vector, graph, spatial, and Oracle Machine Learning (OML) evidence with SQL.
- Test a bounded student-success question and explain what the changed evidence means.
- Connect a LiveStack Demo workflow to reviewable database results.

Estimated Workshop Time: **135 minutes**

### Business Scenario

| Step | Student-success focus |
| --- | --- |
| Business Problem | Seer Higher Education needs timely student support decisions without splitting evidence across disconnected tools. |
| Technical Challenge | Application, data, and AI teams need relational, document, signal, relationship, location, and prediction data to remain governed and connected. |
| Persona Focus | You support student-success leaders, advisors, application developers, database developers, and AI engineers. |
| What You Will Do | Trace dashboard, request, signal, network, coverage, and prediction questions back to SQL evidence. |
| Database Capability | Relational SQL, JSON Relational Duality, AI Vector Search, Property Graph, Oracle Spatial, and OML. |
| Outcome | Teams can prioritize student support from explainable database-backed evidence. |

**Persona focus:** You are a database developer helping campus teams move from a student-success signal to a reviewable action without creating another disconnected data copy.

## Acknowledgements

* **Last Updated By/Date** - Oracle Database Product Management, August 2026
