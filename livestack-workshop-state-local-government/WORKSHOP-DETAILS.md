# Workshop Details

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: **95 minutes**

## Workshop Title

Build Connected State and Local Government Service Operations with Oracle AI Database 26ai

## Mode

Platform-ready draft; ADB and Green Button runtime validation pending

## Short Description

Follow a Colorado resident-services decision from an early operational warning to request evidence, semantic search, partner coordination, service coverage, and predictive capacity planning with Oracle AI Database 26ai.

## Long Description

State and local government leaders must respond to resident-service pressure without losing the evidence behind each decision. In this workshop, Colorado uses a Medicaid eligibility error rate of 2.7%, approaching but still within a stakeholder-provided 3.0% threshold, as the early warning that begins a broader resident-services investigation.

Learners support statewide digital services lead Jessica Chen and regional manager Maria Santos. They query the governed foundation behind the Seer State and Local Government LiveStack, trace command-center measures to rows, inspect one service request as relational data and JSON, search resident concerns by meaning, follow community-partner relationships, measure service access with spatial SQL, and review Oracle Machine Learning results.

The workshop shows how relational SQL, JSON Relational Duality, AI Vector Search, Property Graph, Oracle Spatial, and Oracle Machine Learning can operate over connected evidence in one governed database foundation. Ask Data, copilot, agent, and trusted-action flows are intentionally outside the active workshop because they are not backed by validated learner evidence in the supplied stack.

## Audience

- Database and application developers
- Data and analytics engineers
- Public-service operations analysts
- State and local government technology leaders

## Prerequisites

- A provisioned Oracle AI Database 26ai workshop environment
- Database Actions access as `LLUSER`
- Familiarity with basic SQL is helpful but not required

## Estimated Workshop Time

95 minutes

## Workshop Outline

1. Introduction
2. Getting Started
3. Lab 1: Data Foundation
4. Lab 2: Public Service Command Center
5. Lab 3: Service Request Workbench with JSON Relational Duality
6. Lab 4: Resident Demand Signals with AI Vector Search
7. Lab 5: Community Partner Network with Property Graph
8. Lab 6: Service Access and Coverage Map with Oracle Spatial
9. Lab 7: Demand and Capacity Analytics with Oracle Machine Learning (OML)
10. Lab 8: Conclusion
11. Lab 9: Final Quiz

## Scope Decisions

- The active lab arc follows the Finance Gold Standard.
- The Introduction absorbs Scene 1.
- Scenes 2 through 8 supply the seven active technical labs, reordered to match the Gold Standard feature arc.
- The active workshop excludes Scene 9 (Ask State and Local Government Data) and Scene 10 (Public Service AI Agent Console).
- Scene 11 (Use Your Own Public Service Data) is not an active technical lab.
- The 2.7% and 3.0% eligibility figures establish the business situation. Learner SQL does not claim to calculate that application-configured metric.

## FreeSQL Decision

The workshop uses Database Actions SQL Worksheet. FreeSQL is not used because the labs depend on provisioned schema objects, Oracle AI Vector Search models, Property Graph, Spatial metadata, and Oracle Machine Learning models that are not available in a generic FreeSQL session.

## Acknowledgements

- **Author** - Oracle LiveLabs
- **Last Updated By/Date** - Oracle LiveLabs, August 2026
