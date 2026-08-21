# Route Customers to the Closest Service Center

## Introduction

Moon Kai is Seer Bank's spatial specialist. Operations teams ask Moon for help when location affects a service decision: which center is closest to a region with growing demand, and which customers should it handle?

The bank already stores the required data in Oracle AI Database. Service centers and customers are stored as map points. Demand regions are stored as map areas, and each region has a demand score.

Moon wants operations users to answer a simple question with SQL that can power a business-user dashboard and map:

> A region needs more service support. **Which customers are in that region, and which center is closest to each one?**

In this lab, you follow Moon's approach. You start with a single point, measure distance to a region, find customers inside that region, and finish with a customer routing result that combines location and service data.

<details>
<summary><strong>Key terms: point, polygon, distance, spatial relationship, and GeoJSON</strong></summary>

> - A **point** is one location, represented by longitude and latitude. In this lab, a service center is stored as an `SDO_GEOMETRY` point.
>
> - A **polygon** is an area made from connected points. Demand regions are stored as polygons.
>
> - **Distance** measures how far two spatial objects are from each other. Here, it shows how far a service center is from a demand-region boundary. A distance of zero means the center is inside or touching the region.
>
> - A **spatial relationship** describes how two shapes relate to each other. `SDO_GEOM.RELATE` can test whether a customer point is inside or touches a demand region.
>
> - **GeoJSON** is a JSON format for map locations and shapes. `SDO_UTIL.TO_GEOJSON` lets an application display the same database location on a map.
>
</details>

The Seer Bank Finance LiveStack Demo uses the same data in its service coverage page. The map helps users see the result; the SQL in this lab shows how Oracle calculates it.

![Client service coverage map](images/spatial-chart.png " ")

### Objectives

- Identify spatial points and polygons in the finance data.
- Convert a database point to GeoJSON for an application map.
- Measure which service centers are closest to a demand region.
- Find customers inside a demand region.
- Match each customer to the closest active service center.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step | Finance focus |
| --- | --- |
| Business Problem | Operations needs to route service work to a center that can respond to regional demand. |
| Technical Challenge | Moon needs to compare customer points with a region, then find the closest center for each customer. |
| Persona Focus | You review Moon's spatial approach and interpret the result for an operations user. |
| What You Will See | Oracle Spatial turns location data into customer routing results with SQL. |
| Database Capability | `SDO_GEOMETRY`, `SDO_GEOM.SDO_DISTANCE`, `SDO_GEOM.RELATE`, and GeoJSON conversion support the analysis. |
| Outcome | An operations user can see which customers need service in a region and which center is closest to each one. |

> **SQL Worksheet reminder:** Need a reminder on how to open and use the SQL Worksheet? Return to [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the step-by-step graphic showing where to paste and run SQL statements.

## Task 1: Look at the locations as points

Moon starts with the simplest spatial question: **where are the service centers?** The database stores each center as an `SDO_GEOMETRY` point, while the application can use the same point as GeoJSON.

An `SDO_GEOMETRY` point is Oracle Spatial's structured representation of one location. For example, the Edison center is stored with a point type, the WGS84 coordinate system, and a coordinate pair: longitude `-74.4121` and latitude `40.5187`. Because Oracle stores the location as geometry, Spatial functions can calculate distance and test spatial relationships instead of treating the coordinates as two unrelated numbers.

`SDO_UTIL.TO_GEOJSON` converts that geometry into a standard JSON map object such as `{ "type": "Point", "coordinates": [-74.4121, 40.5187] }`. The application can send this object to a map without maintaining a second location format or a separate conversion service. Oracle uses the same stored geometry for SQL analysis and application display.

That is the Oracle AI Database advantage in this lab: one location supports spatial calculations, relational joins, and JSON map output without copying the data between systems.

1. Run this query:

    ```sql
    <copy>
    SELECT fc.center_id,
           fc.center_name,
           fc.city,
           fc.state_province,
           fc.latitude,
           fc.longitude,
           DBMS_LOB.SUBSTR(
             SDO_UTIL.TO_GEOJSON(fc.location), 120, 1
           ) AS location_geojson
    FROM fulfillment_centers fc
    WHERE fc.center_id IN (1, 3, 16)
    ORDER BY fc.center_id;
    </copy>
    ```

    `LOCATION` is the database point. `LATITUDE` and `LONGITUDE` make the value easy to read, and `LOCATION_GEOJSON` gives an application a map-ready representation of the same point. GeoJSON lists longitude first and latitude second. `SDO_UTIL.TO_GEOJSON` returns a CLOB, so `DBMS_LOB.SUBSTR` limits the displayed text to 120 characters; it does not change the stored geometry.

    **Expected output: Service Center Points**

    ![result](images/task1query.png)

2. Review the point data.

    Moon has not created a second map database. The point used by the application and the point used by SQL are the same value. The database can calculate with it, and the application can display it.

    This is the converged-database advantage. Moon can keep the center's location beside its name, capacity, operating status, and current load. SQL can calculate distance and return those center details, while `SDO_UTIL.TO_GEOJSON` gives the application the same location for a map. The team does not have to copy coordinates into a separate mapping system and keep the copies synchronized.

## Task 2: Find the closest centers to a demand region

New York Metro has a demand index of `91`, making it a useful region for the first routing review. Moon now measures the distance from each service-center point to the region boundary.

1. Run the distance query:

    ```sql
    <copy>
    SELECT fc.center_name,
           fc.city,
           fc.state_province,
           ROUND(
             SDO_GEOM.SDO_DISTANCE(
               fc.location,
               dr.boundary,
               0.005,
               'unit=KM'
             ), 2
           ) AS boundary_distance_km,
           dr.region_name,
           dr.demand_index
    FROM fulfillment_centers fc
    CROSS JOIN demand_regions dr
    WHERE dr.region_name = 'New York Metro'
    ORDER BY boundary_distance_km
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    `SDO_GEOM.SDO_DISTANCE` compares the service-center point with the demand-region polygon. The function returns the shortest distance between the two shapes. A value of `0` means the point is inside or touching the region.

    The four arguments in this query have simple roles:

    - `fc.location` is the first geometry: the service-center point.
    - `dr.boundary` is the second geometry: the demand-region polygon.
    - `0.005` is the tolerance used when Oracle compares the geometries. It helps Oracle handle small differences in the stored coordinates.
    - `'unit=KM'` tells Oracle to return the distance in kilometers. Change it to `'unit=MILE'` when the application needs miles.

    The `ROUND(..., 2)` around the function result only formats the answer to two decimal places. It does not change the spatial calculation.

    The query also returns `DEMAND_INDEX`, so Moon can read location and demand together. The center with the smallest distance is the first center operations should check for available capacity.

    **Expected output: New York Service Coverage**

    The first row should be `Edison Wealth Service Center`, about `9.48` km from the New York Metro boundary. New York Metro has a demand index of `91`.

    ![result](images/task21.png)

2. Try another region.

    Change the region name to `Chicago Metro`, add a miles calculation, and run the modified query:

    ```sql
    <copy>
    SELECT fc.center_name,
           fc.city,
           fc.state_province,
           ROUND(
             SDO_GEOM.SDO_DISTANCE(
               fc.location,
               dr.boundary,
               0.005,
               'unit=KM'
             ), 2
           ) AS boundary_distance_km,
           ROUND(
             SDO_GEOM.SDO_DISTANCE(
               fc.location,
               dr.boundary,
               0.005,
               'unit=MILE'
             ), 2
           ) AS boundary_distance_miles,
           dr.region_name,
           dr.demand_index
    FROM fulfillment_centers fc
    CROSS JOIN demand_regions dr
    WHERE dr.region_name = 'Chicago Metro'
    ORDER BY boundary_distance_km
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    ![result](images/task22.png)

    The `unit` parameter controls the measurement unit. `Joliet Midwest Risk Desk` should be the closest center, with a distance of `0` km and `0` miles because it falls inside the Chicago Metro boundary. Chicago has a demand index of `78`.

    This is a useful regional result, but distance to the region boundary does not identify the customers who need service. Moon now uses the region polygon to find those customers and then assigns each one to the closest active center.

## Task 3: Route customers to the closest center

Moon now needs a result that an operations application can use: customers inside New York Metro, their demand region, and the closest active fulfillment center. The query uses the customer point (**`c.location`**) and demand-region polygon (**`dr.boundary`**) to find the customers first. It then compares each customer point with every active center and keeps the closest one.

1. Run the customer routing query:

    ```sql
    <copy>
    WITH regional_customers AS (
      SELECT dr.region_name,
             dr.demand_index,
             c.customer_id,
             c.first_name || ' ' || c.last_name AS customer_name,
             c.email,
             c.customer_tier,
             c.location
      FROM customers c
      CROSS JOIN demand_regions dr
      WHERE dr.region_name = 'New York Metro'
        AND SDO_GEOM.RELATE(
              dr.boundary,
              'ANYINTERACT',
              c.location,
              0.005
            ) = 'TRUE'
    ), ranked_centers AS (
      SELECT rc.region_name,
             rc.demand_index,
             rc.customer_id,
             rc.customer_name,
             rc.email,
             rc.customer_tier,
             fc.center_name,
             fc.city AS center_city,
             fc.capacity_units,
             fc.current_load_pct,
             ROUND(
               SDO_GEOM.SDO_DISTANCE(
                 rc.location,
                 fc.location,
                 0.005,
                 'unit=KM'
               ), 2
             ) AS customer_center_distance_km,
             ROW_NUMBER() OVER (
               PARTITION BY rc.customer_id
               ORDER BY SDO_GEOM.SDO_DISTANCE(
                          rc.location,
                          fc.location,
                          0.005,
                          'unit=KM'
                        )
             ) AS center_rank
      FROM regional_customers rc
      CROSS JOIN fulfillment_centers fc
      WHERE fc.is_active = 1
    )
    SELECT region_name,
           demand_index,
           customer_id,
           customer_name,
           email,
           customer_tier,
           center_name,
           center_city,
           capacity_units,
           current_load_pct,
           customer_center_distance_km
    FROM ranked_centers
    WHERE center_rank = 1
    ORDER BY customer_center_distance_km, customer_id
    FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    `SDO_GEOM.RELATE` keeps customers whose point falls inside or touches the New York Metro polygon. `SDO_GEOM.SDO_DISTANCE` then measures the distance from each matching customer to every active center. `ROW_NUMBER` keeps the nearest center for each customer.

2. Review the result as an operations decision.

    Each row gives a business user a customer to contact, the closest center, and the information needed to decide where the work should go. The result combines the region's demand score, customer details, center capacity, current load, and spatial distance in one SQL result.

    This is the business outcome. A dashboard can let a user select a region and immediately show the customers affected, the center that should handle each request, and the distance involved. The user does not need to compare a map with a separate customer list or operations report.

    ![result](images/task31.png)

3. Change the query to `Chicago Metro`.

    Compare the customers and assigned centers with the New York result. The spatial predicates stay the same; only the region changes. This is the kind of query an operations dashboard can run when a business user selects a different demand region.

    ![result](images/task31.png)

## Conclusion: Turn Location into a Service Decision

Moon's analysis moves from a point, to distance, to customer routing. A business user can select a high-demand region and get a list of customers, their closest service center, and the distance to that center. That is a useful dashboard result because it tells the user what action to take, not just where the data is located.

This shows why Spatial in Oracle AI Database matters. One convergent query can identify customers with spatial functions, join them to relational customer and center data, and include capacity and current load in the same result. The dashboard can show the map and the business details from one database, without moving data between a mapping system, a customer system, and an operations system.

## Next Steps

You used Oracle Spatial to turn points and polygons into a routing decision. For a deeper hands-on workshop focused on Oracle Spatial, open the [Oracle Spatial LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=800).

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
