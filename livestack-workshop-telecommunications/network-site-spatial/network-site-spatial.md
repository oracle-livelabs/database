# Find Nearby Network Sites

![Moon Kai, spatial specialist, introduces nearby network sites.](images/moon.png)

## Introduction

Moon Kai, SEER Telecomms’ spatial specialist, is helping support staff investigate poor connectivity in a busy region. **Which subscribers are in that region, and which active network site is nearest to each address?**

Use points and polygons to locate subscribers, calculate distances, and combine nearby-site details with service records.

<details>
<summary><strong>Key terms: point, polygon, distance, spatial relationship, and GeoJSON</strong></summary>

> - A **point** is one location, represented by longitude and latitude. In this lab, a network site is stored as an `SDO_GEOMETRY` point.
>
> - A **polygon** is an area made from connected points. Demand regions are stored as polygons.
>
> - **Distance** measures how far two spatial objects are from each other. Here, it shows how far a network site is from a demand-region boundary. A distance of zero means the site is inside or touching the region.
>
> - A **spatial relationship** describes how two shapes relate to each other. `SDO_GEOM.RELATE` can test whether a subscriber point is inside or touches a demand region.
>
> - **GeoJSON** is a JSON format for map locations and shapes. `SDO_UTIL.TO_GEOJSON` lets an application display the same database location on a map.
>
</details>

### Objectives

- Identify spatial points and polygons in the telecommunications data.
- Convert a database point to GeoJSON for an application map.
- Measure which network sites are closest to a demand region.
- Find subscribers inside a demand region.
- Match each subscriber to the closest active network site.

Estimated Time: **10 minutes**

### Hands-on Scenario

Help Moon find subscribers in a busy region and the nearest active site for each service address.

> **SQL Worksheet reminder:** See [Getting Started Task 2: Open SQL Worksheet](?lab=getting-started#Task2:OpenSQLWorksheet) for the steps to paste and run SQL.

## Task 1: Look at the locations as points

Moon starts with the simplest spatial question: **where are the network sites?** The database stores each site as an `SDO_GEOMETRY` point, while the application can use the same point as GeoJSON.

An `SDO_GEOMETRY` point specifies a point type, coordinate system, and coordinates. For example, a WGS84 point can use longitude `-74.4121` and latitude `40.5187`. Spatial functions use this geometry to calculate distances and test relationships.

`SDO_UTIL.TO_GEOJSON` converts the same geometry into a map object such as `{ "type": "Point", "coordinates": [-74.4121, 40.5187] }`.

1. Run this query:

    ```sql
    <copy>
    SELECT hp.site_id,
           hp.site_name,
           hp.city,
           hp.state_province,
           hp.latitude,
           hp.longitude,
           DBMS_LOB.SUBSTR(
             SDO_UTIL.TO_GEOJSON(hp.location), 120, 1
           ) AS location_geojson
    FROM network_sites hp
    WHERE hp.site_id IN (1, 3, 16)
    ORDER BY hp.site_id;
    </copy>
    ```

    ![Look at the locations as points](images/sql-spatial-points.png)

    `LOCATION` is the database point. `LATITUDE` and `LONGITUDE` make the value easy to read, and `LOCATION_GEOJSON` gives an application a map-ready representation of the same point. GeoJSON lists longitude first and latitude second. `SDO_UTIL.TO_GEOJSON` returns a CLOB, so `DBMS_LOB.SUBSTR` limits the displayed text to 120 characters; it does not change the stored geometry.

    **Expected output: Network Site Points**

    Compare the returned columns with the capture above.

2. Review the point data.

    Compare the point with its GeoJSON representation. Both describe the same site.

## Task 2: Find the closest sites to a demand region

The sample data gives New York Network Region a demand index of `91` for the first routing review. Moon now measures the distance from each network-site point to the region boundary.

1. Run the distance query:

    ```sql
    <copy>
    SELECT hp.site_name,
           hp.city,
           hp.state_province,
           ROUND(
             SDO_GEOM.SDO_DISTANCE(
               hp.location,
               dr.boundary,
               0.005,
               'unit=KM'
             ), 2
           ) AS boundary_distance_km,
           dr.region_name,
           dr.demand_index
    FROM network_sites hp
    CROSS JOIN network_regions dr
    WHERE dr.region_name = 'New York Network Region'
    ORDER BY boundary_distance_km
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    ![Find the closest sites to a demand region](images/sql-spatial-new-york.png)

    `SDO_GEOM.SDO_DISTANCE` compares the network-site point with the demand-region polygon. The function returns the shortest distance between the two shapes. A value of `0` means the point is inside or touching the region.

    The four arguments in this query have simple roles:

    - `hp.location` is the first geometry: the network-site point.
    - `dr.boundary` is the second geometry: the demand-region polygon.
    - `0.005` is the tolerance used when Oracle compares the geometries. It helps Oracle handle small differences in the stored coordinates.
    - `'unit=KM'` tells Oracle to return the distance in kilometers. Change it to `'unit=MILE'` when the application needs miles.

    The `ROUND(..., 2)` around the function result only formats the answer to two decimal places. It does not change the spatial calculation.

    The query also returns `DEMAND_INDEX`, so Moon can read location and demand together. The site with the smallest distance is the first site operations should check for available capacity.

    **Expected output: Sites nearest New York Network Region**

    Review the closest site and its distance. Rankings depend on the data your loader supplied. Verify the distances after loading the sample data.

2. Try another region.

    Change the region name to `Chicago Network Region`, add a miles calculation, and run the modified query:

    ```sql
    <copy>
    SELECT hp.site_name,
           hp.city,
           hp.state_province,
           ROUND(
             SDO_GEOM.SDO_DISTANCE(
               hp.location,
               dr.boundary,
               0.005,
               'unit=KM'
             ), 2
           ) AS boundary_distance_km,
           ROUND(
             SDO_GEOM.SDO_DISTANCE(
               hp.location,
               dr.boundary,
               0.005,
               'unit=MILE'
             ), 2
           ) AS boundary_distance_miles,
           dr.region_name,
           dr.demand_index
    FROM network_sites hp
    CROSS JOIN network_regions dr
    WHERE dr.region_name = 'Chicago Network Region'
    ORDER BY boundary_distance_km
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    ![Find the closest sites to a demand region](images/sql-spatial-chicago.png)

    The `unit` parameter controls the measurement unit. Review whether a site lies inside the Chicago Network Region polygon. A point inside or touching the polygon has distance zero. The sample data gives this region a demand index of 78. Check the site rankings in your result.

    This is a useful regional result, but distance to the region boundary does not identify the subscribers who need service. Moon now uses the region polygon to find those subscribers and then ranks the closest active site for each address.

In **Network Access and Field Operations**, enable **Network Sites** and **Demand Pressure Regions**. Compare the site markers with the region overlays. The demo uses its own locations and capacity data, so this map illustrates spatial presentation rather than the expected New York or Chicago SQL result.

![Live network map with site and demand-region layers enabled.](images/app-spatial-map.png)

## Task 3: Find the closest site for each subscriber

Moon now finds subscribers inside New York Network Region and the closest active site to each service address.

1. Run the subscriber-to-site query:

    ```sql
    <copy>
    WITH regional_subscribers AS (
      SELECT dr.region_name,
             dr.demand_index,
             g.subscriber_id,
             g.first_name || ' ' || g.last_name AS subscriber_name,
             g.email,
             g.customer_segment,
             g.location
      FROM subscribers g
      CROSS JOIN network_regions dr
      WHERE dr.region_name = 'New York Network Region'
        AND SDO_GEOM.RELATE(
              dr.boundary,
              'ANYINTERACT',
              g.location,
              0.005
            ) = 'TRUE'
    ), ranked_sites AS (
      SELECT rg.region_name,
             rg.demand_index,
             rg.subscriber_id,
             rg.subscriber_name,
             rg.email,
             rg.customer_segment,
             hp.site_name,
             hp.city AS site_city,
             hp.capacity_mbps,
             hp.utilization_pct,
             ROUND(
               SDO_GEOM.SDO_DISTANCE(
                 rg.location,
                 hp.location,
                 0.005,
                 'unit=KM'
               ), 2
             ) AS subscriber_site_distance_km,
             ROW_NUMBER() OVER (
               PARTITION BY rg.subscriber_id
               ORDER BY SDO_GEOM.SDO_DISTANCE(
                          rg.location,
                          hp.location,
                          0.005,
                          'unit=KM'
                        )
             ) AS site_rank
      FROM regional_subscribers rg
      CROSS JOIN network_sites hp
      WHERE hp.is_active = 1
    )
    SELECT region_name,
           demand_index,
           subscriber_id,
           subscriber_name,
           email,
           customer_segment,
           site_name,
           site_city,
           capacity_mbps,
           utilization_pct,
           subscriber_site_distance_km
    FROM ranked_sites
    WHERE site_rank = 1
    ORDER BY subscriber_site_distance_km, subscriber_id
    FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    ![Subscribers and their nearest active sites](images/sql-spatial-routing.png)

    `SDO_GEOM.RELATE` keeps subscribers whose point falls inside or touches the New York Network Region polygon. `SDO_GEOM.SDO_DISTANCE` then measures the distance from each matching subscriber to every active site. `ROW_NUMBER` keeps the nearest site for each subscriber.

2. Review the result as an operations decision.

    Subscriber `LOCATION` is the service address supplied in the sample data. Each row gives an operations analyst a subscriber to contact, the closest site, and the information needed to decide where the work should go. The result combines the region's demand score, subscriber details, site capacity, current load, and spatial distance in one SQL result.

3. Change the query to `Chicago Network Region`.

    Compare the subscribers and nearest sites with the New York result. The spatial predicates stay the same; only the region changes. This is the kind of query an operations dashboard can run when an operations analyst selects a different demand region.

> **Recommendation boundary:** The query finds the nearest active network site by straight-line distance. It does not establish serving-cell attachment, radio coverage, fiber reach, or available throughput. Check signal measurements, access technology, backhaul, alarms, and current capacity before recommending a service change. `CAPACITY_MBPS` and `UTILIZATION_PCT` are snapshots.

## Conclusion: Turn Location into a Service Decision

Moon used points and polygons to find subscribers in a demand region and rank nearby network sites. The result gives the service team subscribers to contact and network sites to investigate.

## Next Steps

For more practice, open the [Oracle Spatial LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=800).

## Acknowledgements

* **Author** - Matt Kowalik
* **Contributor** - Kevin Lazarz
* **Last Updated By/Date** - Matt Kowalik, September 2026
