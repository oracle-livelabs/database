# Intelligent Fulfillment Network with Oracle Spatial

## Introduction

A fulfillment operations manager, supply chain planner, or omnichannel operations lead needs to understand where customer demand, inventory, shipment activity, and service coverage intersect. That work is difficult when warehouse systems, ecommerce orders, customer geography, carrier data, social demand signals, and forecasting models live in separate applications.

Oracle AI Database helps by keeping spatial, relational, inventory, shipment, demand forecast, and security-governed data together. In the application, Intelligent Fulfillment Network shows centers, service zones, demand regions, inventory alerts, and route context. In SQL Worksheet, you inspect the geometry metadata, GeoJSON, distance calculations, and risk view that support that map.

Estimated Time: 10 minutes

### Objectives

- Inspect spatial metadata for fulfillment and demand geometry.
- Produce map-ready GeoJSON from Oracle Spatial objects.
- Find nearby fulfillment options with `SDO_DISTANCE`.
- Connect inventory risk and location context to fulfillment decisions.


## Task 1: Inspect spatial metadata
1. Review the related application screen before you run the SQL.

    ![Intelligent Fulfillment Network overview map and KPIs](images/fulfillment-network-overview.png " ")

    *Figure 1: Intelligent Fulfillment Network brings together inventory, centers, service areas, and demand geography.*

2. Run this query.

    ```sql
    <copy>
    SELECT owner AS "Owner", table_name AS "Table", column_name AS "Geometry", srid AS "SRID"
    FROM all_sdo_geom_metadata
    WHERE owner = 'RETAILDB'
      AND table_name IN ('FULFILLMENT_CENTERS','CUSTOMERS','FULFILLMENT_ZONES','DEMAND_REGIONS')
    ORDER BY table_name, column_name;
    </copy>
    ```

    Expected output:

    | Owner | Table | Geometry | SRID |
    | --- | --- | --- | ---: |
    | RETAILDB | CUSTOMERS | LOCATION | 4326 |
    | RETAILDB | `DEMAND_REGIONS` | BOUNDARY | 4326 |
    | RETAILDB | `FULFILLMENT_CENTERS` | LOCATION | 4326 |
    | RETAILDB | `FULFILLMENT_ZONES` | `ZONE_BOUNDARY` | 4326 |
    {: title="Spatial Geometry Metadata"}

## Task 2: Produce map-ready GeoJSON
1. Use the live Intelligent Fulfillment Network context from Figure 1 before you run the SQL.

2. Run this query.

    ```sql
    <copy>
    SELECT center_name AS "Center",
           city AS "City",
           state_province AS "State",
           SUBSTR(SDO_UTIL.TO_GEOJSON(location), 1, 120) AS "GeoJSON"
    FROM RETAILDB.fulfillment_centers
    WHERE location IS NOT NULL
    ORDER BY center_id
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Center | City | State | GeoJSON |
    | --- | --- | --- | --- |
    | NYC Metro Hub | Edison | New Jersey | { "type": "Point", "coordinates": [-74.4121, 40.5187] } |
    | LA Mega Center | Ontario | California | { "type": "Point", "coordinates": [-117.6509, 34.0633] } |
    | Chicago Midwest Hub | Joliet | Illinois | { "type": "Point", "coordinates": [-88.0817, 41.525] } |
    | Dallas South Central | Lancaster | Texas | { "type": "Point", "coordinates": [-96.7561, 32.5921] } |
    | Atlanta Southeast | Union City | Georgia | { "type": "Point", "coordinates": [-84.5421, 33.5871] } |
    {: title="Fulfillment Centers as GeoJSON"}

3. The application can use GeoJSON directly for mapping without moving geometry processing to a separate service.

## Task 3: Find nearby fulfillment options
1. Use the live Intelligent Fulfillment Network context from Figure 1 before you run the SQL.

2. Run this distance query.

    ```sql
    <copy>
    SELECT fc.center_name AS "Center",
           fc.city AS "City",
           fc.state_province AS "State",
           ROUND(SDO_GEOM.SDO_DISTANCE(c.location, fc.location, 0.005, 'unit=MILE'), 1) AS "Miles"
    FROM RETAILDB.customers c
    CROSS JOIN RETAILDB.fulfillment_centers fc
    WHERE c.customer_id = 1
      AND fc.is_active = 1
    ORDER BY SDO_GEOM.SDO_DISTANCE(c.location, fc.location, 0.005, 'unit=MILE')
    FETCH FIRST 5 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Center | City | State | Miles |
    | --- | --- | --- | ---: |
    | LA Mega Center | Ontario | California | 34.7 |
    | Las Vegas West | North Las Vegas | Nevada | 230.7 |
    | San Francisco Bay | Fremont | California | 318.8 |
    | Phoenix Desert Hub | Goodyear | Arizona | 342.3 |
    | Reno West Hub | Sparks | Nevada | 386.2 |
    {: title="Nearest Fulfillment Centers"}

3. A fulfillment manager can combine this result with inventory to route orders quickly without increasing stockout risk.

## Task 4: Inspect fulfillment risk semantics
1. Use the live Intelligent Fulfillment Network context from Figure 1 before you run the SQL.

2. Run this semantic-view query.

    ```sql
    <copy>
    SELECT product_name AS "Product",
           center_name AS "Center",
           state_province AS "State",
           quantity_on_hand AS "On Hand",
           reorder_point AS "Reorder At",
           inventory_risk AS "Risk"
    FROM RETAILDB.retail_fulfillment_risk_v r
    ORDER BY r.inventory_risk DESC, r.quantity_on_hand ASC, r.product_name
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Product | Center | State | On Hand | Reorder At | Risk |
    | --- | --- | --- | ---: | ---: | --- |
    | Carbon Road Bike | Portland Pacific | Oregon | 10 | 38 | `AT_RISK` |
    | Heritage Leather Belt | Indianapolis Heartland | Indiana | 10 | 84 | `AT_RISK` |
    | Lavender Diffuser Set | Anchorage Alaska | Alaska | 10 | 71 | `AT_RISK` |
    | PhantomCase PC Mid Tower | Minneapolis North Central | Minnesota | 10 | 20 | `AT_RISK` |
    | UltraWide Curved 34 | Portland Pacific | Oregon | 10 | 34 | `AT_RISK` |
    | 4-Season Tent 3P | Tampa Florida | Florida | 11 | 87 | `AT_RISK` |
    | LED Festival Jacket | Nashville Central | Tennessee | 11 | 34 | `AT_RISK` |
    | Midnight Espresso Blend | Houston Gulf Coast | Texas | 11 | 83 | `AT_RISK` |
    | Moonbeam Highlighter | Phoenix Desert Hub | Arizona | 11 | 30 | `AT_RISK` |
    | Retro Wave Tee | Philadelphia Mid-Atlantic | Delaware | 11 | 49 | `AT_RISK` |
    {: title="Fulfillment Inventory Risk"}

3. The semantic view turns raw spatial, inventory, and demand data into a business-ready risk surface.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
