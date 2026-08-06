# Conclusion: Connected Network Experience Decisions

## Introduction

You have completed the SQL-backed `TEL-5G-2026-501` investigation. You started with its evidence foundation, confirmed Hudson Yards capacity pressure, inspected the linked service order, interpreted the game-day congestion signal, traced the case impact, compared nearby response locations, and reviewed the Hudson Yards capacity-risk score. Each result uses a different database capability while remaining connected to one governed incident record.

Estimated Time: **5 minutes**

### Objectives

- Summarize the active Telco decision path.
- Explain the evidence that supports the `TEL-5G-2026-501` response.
- Carry the same investigation pattern into another network-experience case.

## Task 1: Review what you can now explain

1. Use this table as a recap of the workshop.

    | Telco question | What you can now explain |
    | --- | --- |
    | Is the case foundation ready? | How catalog views confirm the tables, JSON duality view, vector columns, property graph, and spatial layers used to investigate `TEL-5G-2026-501`. |
    | Why does Hudson Yards need attention first? | How a 91% capacity KPI drills through to a named site, city, and load percentage. |
    | Which service action is linked to the incident? | How `ORDERS_DV` exposes order `601` as JSON while relational rows remain the source of truth. |
    | What does the congestion signal mean? | How vector-match evidence connects the game-day signal to a related service. |
    | Who and what does the case involve? | How `GRAPH_TABLE` returns the case's site, outage, subscriber cluster, and support-case relationships. |
    | Which site is nearest for response planning? | How Spatial SQL identifies the Hudson Yards and Newark pair as 9.0 miles apart. |
    | What should capacity planners review next? | How OML ranks Hudson Yards as `ESCALATE` using the capacity features already tied to the incident. |

2. Make the case decision brief.

    The evidence supports a clear next step: **prioritize a Hudson Yards capacity and field-response review for `TEL-5G-2026-501`.** The case is critical, affects 31,200 subscribers, and places $2.14M at risk. Hudson Yards is at 91% load and is ranked `ESCALATE` by the capacity-risk model. The graph identifies the subscriber cluster, outage signal, and support case that need coordinated review. Newark is the nearest returned response site at 9.0 miles.

    This is not an automatic dispatch instruction. It is an explainable planning brief: the operations leader can inspect the capacity row, order `601`, signal `501`, case relationships, distance result, and model score before assigning work.

3. Review the persona value.

    | Persona | Workshop value |
    | --- | --- |
    | Network operations analyst | Gets a capacity decision path that can be inspected instead of a black-box KPI. |
    | Service-order developer | Sees how a JSON document can stay connected to relational truth. |
    | Customer-experience analyst | Reviews a semantic service match with the business evidence beside it. |
    | Network-impact investigator | Follows the case relationships that determine coordinated review. |
    | Field-operations planner | Uses location evidence beside capacity and service context. |
    | Capacity planner | Reviews a model prediction beside the site capacity and load evidence that shaped it. |

4. Carry the pattern forward.

    For the next incident, begin with a case ID and a business decision. Trace the capacity or service symptom to its governed rows. Read the affected order as JSON where an application needs it. Use Vector Search when the signal wording differs from service terminology. Use Property Graph to reveal connected people, sites, events, and cases. Use Spatial to compare response locations. Use OML as a priority signal beside, never instead of, operational evidence.

    Oracle AI Database 26ai keeps those data models and scores connected under one governance model. That reduces sensitive copies and reconciliation work, and gives the team a repeatable explanation for every response decision.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Pat Shepherd, July 2026
