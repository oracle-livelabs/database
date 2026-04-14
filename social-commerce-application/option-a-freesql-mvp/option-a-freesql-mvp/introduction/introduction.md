# Build a Social Commerce MVP with Oracle Database and FreeSQL

## Introduction

This workshop maps directly to the TIM app database workflow and uses FreeSQL SQL prompt capabilities only.

Estimated Workshop Time: 79 minutes

### Objectives

In this workshop, you will:
- Create and seed a social-commerce schema used by the application.
- Run KPI, graph-style, spatial, JSON, and agent-audit SQL patterns.
- Practice prompt-compatible SQL workflows that mirror real app operations.

## Walk Through the Application First

Before you start the labs, open the app and click through the left navigation:

`http://152.70.54.67:5500/`

Use this screen capture as a guide:

![Social Commerce application](images/social-commerce-app.png)

You can see these flows in action (based on the app source in `frontend/src/pages`):
- **Schema & Data**: interactive table model across relational, JSON, graph, vector, spatial, AI, and security tags.
- **Dashboard**: command-center KPIs for orders, revenue, trends, and operational status.
- **Social Vector Trends**: visible in the app, but omitted in this FreeSQL workshop because vector search support is limited.
- **Influencer Graph**: SQL/PGQ and network-style traversal patterns.
- **Fulfillment Map**: spatial routing, nearest-center logic, and delivery coverage.
- **Orders**: order lifecycle plus JSON duality-style projections.
- **Ask Your Data**: NL-to-SQL flow with generated SQL inspection.
- **Agent Console**: multi-agent actions, tool traces, and audit/event views.

Mapped tab-to-lab version:

![Social Commerce app tabs mapped to workshop labs](images/social-commerce-app-lab-map.png)

### Workshop Labs

1. Lab 1: Schema & Data
2. Lab 2: Dashboard
3. Lab 3: Influencer Graph
4. Lab 4: Fulfillment Map
5. Lab 5: Orders
6. Lab 6: Ask Your Data
7. Lab 7: Agent Console
8. Lab 8: Cleanup

> Note: Social Vector Trends and OML Analytics are intentionally omitted in this FreeSQL-only path.

## Acknowledgements

* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
