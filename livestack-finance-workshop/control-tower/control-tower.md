# Orient to the Seer Equity control tower

## Introduction

The Seer Equity control tower introduces the application story. It presents finance operations, risk, service coverage, analytics, and AI workflows as one database-backed experience.

### Objectives

- Identify the main application surfaces.
- Inspect the input package contract.
- Confirm the backend connection pattern.
- Build a screen-to-source map for later labs.

Estimated Time: 10 minutes

## Task 1: Review the application surfaces

1. Open `frontend-source/src/App.jsx` in the input package.

    The navigation defines the learner path.

    | Surface | What it teaches |
    | --- | --- |
    | Seer Equity Bank Control Tower | Scenario, feature map, and entry points |
    | Seer 26ai Data Foundation | Schema model and demo data controls |
    | Risk & Operations Dashboard | Aggregates, revenue, signals, and In-Memory checks |
    | Regulatory & Market Signals | Signal feed and vector search |
    | Financial Crime Network | SQL/PGQ graph investigation |
    | Client Service Coverage | Oracle Spatial coverage and routing |
    | Client Transactions & Cases | Relational rows plus JSON duality |
    | Predictive Risk & Revenue Analytics | Forecasting, segmentation, and clustering |
    | Ask Seer Equity Data | Natural-language SQL assistance |
    | Agent Console | Governed agent actions and audit history |

2. Use the table to describe the app in one sentence.

    Example answer: Seer Equity uses one Oracle database platform to connect finance operations, risk signals, graph investigation, spatial coverage, analytics, and governed AI actions.

## Task 2: Confirm the API layer

1. Inspect `backend-source/server.js` and `backend-source/config/database.js`.

    The backend uses Express and `node-oracledb` to connect directly to Oracle. ORDS may appear in deployment files, but it is not the API layer for these routes.

2. Run the health-check SQL in your database session.

    ```sql
    SELECT 'connected' AS status, SYSDATE AS db_time
    FROM dual;
    ```

    Sample result:

    | STATUS | DB_TIME |
    | --- | --- |
    | connected | 11-MAY-26 |

## Task 3: Check your work

1. Confirm that you can name the four package roots.

2. Confirm that you can explain the screen-to-source mapping.

3. Confirm that you can describe the backend as Express plus `node-oracledb`.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
