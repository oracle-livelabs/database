# Build Student Success Intelligence with Oracle AI Database 26ai

## Introduction

Student-success teams must identify support needs early, decide what requires attention, and coordinate the right service response. A rising request queue, the words a student uses, an overloaded location, or a useful program relationship can all change that decision. When those details sit in separate systems, staff spend more time assembling context before they can respond.

In this workshop, you work with **Seer Higher Education**, a fictional institution. It uses Oracle AI Database 26ai as one student-success foundation. You will follow one student-support operations workflow: establish trusted context, prioritize requests, maintain an application request, match student intent to services, find useful support relationships, compare location and capacity, and anticipate service demand.

This workshop shows how student-success operations teams can connect requests, student intent, support relationships, service locations, capacity, and predictive signals to prioritize and coordinate student support with fewer manual data handoffs.

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

The journey follows one route in the order shown below. Each lab illustrates the next stage in the student-support operating workflow.

| Route step | Decision supported | Time |
| --- | --- | ---: |
| Getting Started | Open the learner environment and confirm the working identity. | 8 minutes |
| Lab 1: Student Success Data Foundation | Establish which connected information and capabilities are available. | 10 minutes |
| Lab 2: Student Success Command Center | Decide which requests should enter the review queue first. | 12 minutes |
| Lab 3: Student Requests and Cases | Create and update a request without maintaining a separate document copy. | 25 minutes |
| Lab 4: Student Intent and Support Signals | Identify services whose meaning matches the student's expressed need. | 12 minutes |
| Lab 5: Advisor, Program, and Support Network | Find relationships that could help coordinate follow-up. | 12 minutes |
| Lab 6: Campus Service Coverage | Compare proximity and capacity before recommending a service site. | 12 minutes |
| Lab 7: Predictive Student-Service Demand | Identify service-demand predictions that deserve human review. | 12 minutes |
| Lab 8: Conclusion | Explain the connected workflow and its potential operational value. | 5 minutes |
| Lab 9: Final Quiz | Check your understanding of the database capabilities used in the workshop. | 5 minutes |
| **Workshop total** | **One complete route, including setup and quiz.** | **113 minutes** |

### Objectives

- Explain how a connected Oracle AI Database foundation supports student-success decisions.
- Query relational, JSON, vector, graph, spatial, and Oracle Machine Learning (OML) evidence with SQL.
- Test a bounded student-success question and explain what the changed evidence means.
- Connect a LiveStack Demo workflow to reviewable database results.

Estimated Workshop Time: **113 minutes**

### Business Scenario

| Step | Student-success focus |
| --- | --- |
| Business Problem | Seer Higher Education needs to move from an incoming student need to coordinated support without waiting for staff to reconcile disconnected systems. |
| Technical Challenge | Application, data, and AI teams need relational, document, signal, relationship, location, and prediction data to remain governed and connected. |
| Decision Owners | Student-success leaders, advisors, service planners, application developers, database developers, and AI engineers. |
| What You Will Do | Establish context, prioritize requests, maintain a request, match intent, evaluate relationships and locations, and review predicted demand. |
| Database Capability | Relational SQL, JSON Relational Duality, AI Vector Search, Property Graph, Oracle Spatial, and OML. |
| Outcome | Teams can coordinate a reviewable student-support response with fewer manual handoffs and reconciliation steps. |

**Persona focus:** You are a database developer helping campus teams move from an incoming support need to a coordinated, reviewable response without creating another disconnected data copy.

The workshop **demonstrates** the database mechanisms and review steps in this workflow. The pattern **supports** faster prioritization, routing, and coordination. Improvements in response time, request age, service fit, staff handoffs, and student outcomes **require validation** with each institution's data, policies, staffing model, and operating process.

## Acknowledgements

* **Last Updated By/Date** - Oracle Database Product Management, August 2026
