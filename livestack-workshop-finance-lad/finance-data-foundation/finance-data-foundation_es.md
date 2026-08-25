# Finanzas Data Foundation

## Introducción

Esta lab confirms that la current Seer Bank datos foundation es present antes de any finanzas resultado es trusted. Learners inspect semantic views, core datos groups, vectors, graphs, espacial objects, Oracle Machine Learning (OML) modelos, y agente functions como la compartido evidence base para la rest de la workshop.

La goal es simple: see how different finanzas decisions connect un one base de datos antes de tú start using la datos.

La point es un understand what es disponible antes de tú start asking negocio preguntas. Dashboard metrics, vector matches, grafo paths, espacial distances, OML scores, copilot respuestas, y agente audit filas all connect back un this compartido base de datos foundation.

Think de this lab como la map de la finanzas environment. La mismo schema supports la riesgo dashboard, transaction API, semantic búsqueda, financiero-crime grafo, service coverage, prediction, governed respuestas, y agente action history.

**Oracle AI Base de datos 26ai** es un convergente base de datos: it lets these different finanzas cargas de trabajo use one governed base de datos foundation instead de forcing each datos type en un separate specialist system.

![Before y después de architecture diagram comparing bespoke finanzas datos stores con Oracle Converged Base de datos](images/finanzas-convergente-base de datos-redwood.png " ")

<details>
<summary><strong>Key terms: schema, view, vector, grafo, espacial, Oracle Machine Learning (OML), y Procedural Language/Structured Consulta Language (PL/SQL)</strong></summary>

> - A **schema** es un named workspace inside la base de datos. It owns objects such como tablas, views, functions, modelos, vectors, y grafo definitions. In this workshop, `LLUSER` es la schema tú use, so it es la place donde la finanzas evidence es organized y secured.
>
> - A **view** es un saved SQL consulta that presents datos in un useful shape. A semantic finanzas view gives tú negocio-friendly columnas, such como productos, institutions, transactions, o signals, sin making tú understand every underlying tabla. Views help aplicación y analytics teams use consistent definitions instead de rebuilding la mismo uniones in many places.
>
> - A **vector** es un numerical representation de meaning. In this workshop, finanzas producto descriptions y riesgo-signal text puede be converted en vectors so la base de datos puede compare ideas, no solo exact words. That es what lets un búsqueda para one phrase find related finanzas language.
>
> - A **property grafo** represents entities y relationships. Entities puede be accounts, devices, phone numbers, IP addresses, payees, o cases. Relationships explain how those entities son connected, which es essential cuando un fraud pattern es visible solo mediante compartido devices, compartido contact details, o multi-hop account links.
>
> - **Spatial** datos stores ubicación y shape information. A service center puede be un point, un demand region puede be un boundary, y un SLA zone puede be un service area. Oracle Spatial lets tú calculate distancia y coverage con SQL instead de exporting ubicación datos un un separate mapping system.
>
> - **Oracle Machine Learning (OML)** lets tú build, store, y score modelos inside Oracle Base de datos, donde la finanzas records ya live. That keeps predictions closer un la governed datos that produced them.
>
> - **Procedural Language/Structured Consulta Language (PL/SQL)** es Oracle's procedural language para base de datos logic. Teams use it para approved functions, reusable negocio rules, y controlled operations that debe run close un governed datos rather than in scattered aplicación code.

</details>

La image below es la Data Foundation page de la Seer Bank aplicación. It shows la compartido finanzas datos domains that support la rest de la experience: financiero productos, clients, transactions, cases, regulatory signals, service geography, vectors, machine learning outputs, y agente audit history. En este laboratorio, tú use SQL un inspect that foundation directly instead de treating la aplicación screen como un black box.

![Finanzas Data Foundation page](images/datos-foundation.png " ")

### Objetivos

- Revisar la finanzas semantic views.
- Comprobar la scale de la current datos.
- Map each aplicación page un la Oracle AI Base de datos 26ai capability that supports la related finanzas decision.

Tiempo estimado: **10 minutes**

### Negocio Scenario

| Paso | Finanzas focus |
| --- | --- |
| Problema de negocio | Riesgo, prediction, y agente workflows necesita un compartido view de la finanzas datos they use un make decisions. |
| Reto técnico | Platform teams debe show how la mismo schema supports semantic views, vectors, graphs, espacial datos, OML modelos, y PL/SQL herramientas. |
| Enfoque de la persona | Base de datos developers y platform engineers map la foundation that negocio usuarios rely on para downstream evidence. |
| Lo que verás | La current Finanzas LiveStack aplicación uses connected views y object families in one base de datos schema. |
| Capacidad de la base de datos | Oracle catalog views y finanzas semantic views expose la governed object inventory. |
| Resultado | Each finanzas resultado puede be traced back un la mismo queryable datos foundation. |

Persona focus: Tú son la base de datos developer showing how Seer Bank's compartido foundation supports riesgo, operations, prediction, y AI workflows.

## Tarea 1: Inventory la finanzas object families

Start by inventorying la semantic views y base de datos capabilities that la rest de la workshop depends on:

1. Ejecutar this inventory consulta:

    > **SQL Worksheet reminder:** Need un reminder on how un open y use la SQL Worksheet? Return un [Getting Started Tarea 2: Open SQL Worksheet](?lab=getting-started#Tarea2:OpenSQLWorksheet) para la step-by-step graphic showing donde un paste y run SQL statements.

    Tú son building un simple capability map antes de making any finanzas decisions. Tú do no necesita un memorize this catalog SQL. La purpose es un ask Oracle Base de datos, "What finanzas capabilities son disponible in this schema?"

    Each section counts one kind de capability used by la workshop labs: approved finanzas views para reporting, JSON duality para transaction documentos, la fraud property grafo para relationship analysis, vector columnas para meaning-based búsqueda, espacial metadata para service coverage, y OML modelos para prediction. La `UNION ALL` lines stack those counts en one easy-un-read tabla.

    La names ending in `_V` son base de datos views. A view es un saved SQL consulta that presents governed datos in un negocio-ready shape. In this lesson, `FINANCE_INSTITUTIONS_V` y `FINANCE_PRODUCTS_V` describe la finanzas catalog, `RISK_SIGNALS_V` y `SIGNAL_SOURCES_V` organize riesgo evidence, `CLIENT_TRANSACTIONS_V` exposes transaction activity, y la `SERVICE_*_V` views support service-center, capacity, y route analysis. Counting those views matters porque later labs use them como trusted acceso points instead de asking tú un rebuild la mismo uniones each time.

    <details>
    <summary><strong>Why this matters: easier in un convergente base de datos</strong></summary>

    > In un fractured environment, tú might look in one system para reporting views, another para JSON documentos, another para grafo objects, another para vector indexes, another para espacial metadata, y another para machine learning modelos. Each system puede have its own seguridad, metadata, y operational rules.
    >
    > Oracle Base de datos lets tú inspect these object families de one schema using SQL catalog views. That makes it easier un understand what es disponible antes de tú start making finanzas decisions.

    </details>

    ```sql
    <copy>
    SELECT 'Finance semantic views' AS "Area", COUNT(*) AS "Count"
    FROM user_views
    WHERE view_name IN (
      'FINANCE_INSTITUTIONS_V','FINANCE_PRODUCTS_V','RISK_SIGNALS_V',
      'SIGNAL_SOURCES_V','CLIENT_TRANSACTIONS_V','SERVICE_CENTERS_V',
      'SERVICE_CAPACITY_V','SERVICE_ROUTES_V'
    )
    UNION ALL
    SELECT 'JSON duality views', COUNT(*)
    FROM user_json_duality_views
    WHERE view_name = 'ORDERS_DV'
    UNION ALL
    SELECT 'Finance property graphs', COUNT(*)
    FROM user_property_graphs
    WHERE graph_name = 'FRAUD_NETWORK'
    UNION ALL
    SELECT 'MiniLM vector columns', COUNT(*)
    FROM user_tab_cols
    WHERE data_type = 'VECTOR'
      AND table_name IN ('PRODUCT_EMBEDDINGS','SIGNAL_EMBEDDINGS')
    UNION ALL
    SELECT 'Spatial metadata layers', COUNT(*)
    FROM user_sdo_geom_metadata
    WHERE table_name IN ('FULFILLMENT_CENTERS','FULFILLMENT_ZONES','DEMAND_REGIONS')
    UNION ALL
    SELECT 'OML mining models', COUNT(*)
    FROM user_mining_models
    WHERE model_name IN (
      'DEMAND_SURGE_MODEL','CUSTOMER_SEGMENT_MODEL',
      'REVENUE_PREDICT_MODEL','PRODUCT_CLUSTER_MODEL'
    );
    </copy>
    ```

    **Resultado esperado: Foundation Object Inventory**

    | Area | Count |
    | --- | --- |
    | Finanzas semantic views | 8 |
    | JSON duality views | 1 |
    | Finanzas property graphs | 1 |
    | MiniLM vector columnas | 2 |
    | Spatial metadata layers | 3 |
    | OML mining modelos | 4 |


2. Revisar la counts.
    Leer la resultado como un capability checklist. La consulta reads Oracle catalog views instead de aplicación tablas, so it tells tú what kinds de base de datos objects son disponible antes de tú start using them.

    Si tú son looking at riesgo metrics, la semantic views son donde trusted finanzas datos comes de. Si un aplicación necesita transaction documentos, la duality view provides that shape sin un separate documento copy. Si tú son investigating fraud, la property grafo es what lets tú follow relationships. Si tú necesita meaning-based búsqueda, vector columnas support that. Si tú necesita service coverage, espacial metadata tells Oracle how un interpret geometry columnas. Si tú necesita predictions, OML modelos son disponible.

    Treat this como la capability map para la finanzas aplicación. Each fila points un un negocio use tú va un work con in SQL.

**Nota:** Sample valores may change después de datos refreshes o rebuilds. Focus on la expected resultado pattern y la negocio takeaway, no la exact valores.

## Tarea 2: Count la current finanzas datos groups

La next consulta shows la scale de la finanzas scenario behind la aplicación pages.

1. Ejecutar this datos group count consulta:

    Tú son sizing la finanzas scenario so later dashboard, grafo, búsqueda, espacial, y prediction resultados have context. La SQL counts filas de la negocio-facing finanzas views y core tablas, then combines those counts en one tabla con `UNION ALL`.

    La `_v` objects in this consulta son la lowercase SQL references un la mismo finanzas views tú inventoried earlier. `finance_institutions_v` y `finance_products_v` give tú la negocio catalog, `risk_signals_v` y `signal_sources_v` give tú monitored riesgo evidence, `client_transactions_v` gives tú transaction activity, y `service_centers_v` gives tú la service locations used later para espacial analysis. Their valor here es consistency: la counts come de la mismo governed acceso layer later labs consulta para negocio evidence.

    Each fila tells tú how much datos exists para one part de la finanzas environment.

    ```sql
    <copy>
    SELECT 'Institutions' AS "Data Group", COUNT(*) AS "Rows" FROM finance_institutions_v
    UNION ALL SELECT 'Financial products', COUNT(*) FROM finance_products_v
    UNION ALL SELECT 'Risk signals', COUNT(*) FROM risk_signals_v
    UNION ALL SELECT 'Signal sources', COUNT(*) FROM signal_sources_v
    UNION ALL SELECT 'Client transactions', COUNT(*) FROM client_transactions_v
    UNION ALL SELECT 'Service centers', COUNT(*) FROM service_centers_v
    UNION ALL SELECT 'SLA zones', COUNT(*) FROM fulfillment_zones
    UNION ALL SELECT 'Demand regions', COUNT(*) FROM demand_regions
    UNION ALL SELECT 'Fraud entities', COUNT(*) FROM fraud_entities
    UNION ALL SELECT 'Fraud relationships', COUNT(*) FROM fraud_relationships;
    </copy>
    ```

    **Resultado esperado: Finanzas Row Counts**

    | Data Group | Rows |
    | --- | --- |
    | Institutions | 50 |
    | Financiero productos | 79 |
    | Riesgo signals | 5000 |
    | Signal sources | 463 |
    | Client transactions | 3000 |
    | Service centers | 30 |
    | SLA zones | 120 |
    | Demand regions | 20 |
    | Fraud entities | 25 |
    | Fraud relationships | 35 |


2. Usar la counts como la baseline para later analysis.
    Esta consulta reads la negocio-facing finanzas views y core tablas that tú va un aggregate, búsqueda, traverse, score, o audit. It gives tú un concrete sense de la datos population antes de tú inspect specific riesgo y operations resultados.

    These counts establish la scale de la finanzas scenario: productos y institutions provide la negocio catalog, riesgo signals y transactions drive la dashboard, service centers y SLA zones support operations, y fraud entities plus relationships support la grafo investigation.

    La baseline helps tú interpret focused resultados. When un consulta returns solo un few filas, tú puede understand why: la SQL es filtering, ranking, scoring, o following relationships de this larger population.

## Agradecimientos

* **Author** - Pat Shepherd, Senior Principal Base de datos Product Manager
* **Contributor** - Linda Foinding, Principal Base de datos Product Manager
* **Last Updated By/Date** - Oracle Base de datos Product Management, June 2026
