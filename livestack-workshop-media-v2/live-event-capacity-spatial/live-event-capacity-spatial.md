# Route Audience Accounts to the Closest Distribution Hub

<!-- markdownlint-configure-file
{
  "MD013": {
    "code_blocks": false,
    "tables": false
  },
  "MD033": {
    "allowed_elements": [
      "details",
      "summary",
      "strong"
    ]
  }
}
-->

## Introduction

Moon Kai is Seer Media's spatial specialist. Launch operations asks Moon for
help when location affects a distribution decision: which hub is closest to a
region with growing demand, and which audience accounts should it support?

Seer Media already stores the required data in Oracle AI Database. Distribution
hubs and audience accounts are stored as map points. Audience regions are stored
as polygons, and each region has a demand score.

Moon wants operations users to answer a simple question with SQL that can power
a dashboard and map:

> A region needs more distribution capacity. **Which audience accounts are in
> that region, and which distribution hub is closest to each one?**

In this lab, you follow Moon's approach. Start with a point, measure its
distance to a region, find audience accounts inside that region, and finish with
a routing result that combines location and distribution data.

![Moon introduces media distribution hubs and audience demand regions](images/media-moon.png)

<details>
<!-- markdownlint-disable-next-line MD013 -->
<summary><strong>Key terms: point, polygon, distance, spatial relationship, and GeoJSON</strong></summary>

> * A **point** is one location, represented by longitude and latitude. In this
>   lab, a media distribution hub is stored as an `SDO_GEOMETRY` point.
>
> * A **polygon** is an area made from connected points. Audience regions are
>   stored as polygons.
>
> * **Distance** measures how far two spatial objects are from each other. Here,
>   it shows how far a media distribution hub is from an audience-region
>   polygon. A distance of zero means the hub is inside or touching the region.
>
> * A **spatial relationship** describes how two shapes relate to each other.
>   `SDO_GEOM.RELATE` can test whether an audience-account point is inside or
>   touches an audience region.
>
> * **GeoJSON** is a JSON format for map locations and shapes.
>   `SDO_UTIL.TO_GEOJSON` lets an application display the same database location
>   on a map.
>
</details>

The workshop stores distribution hubs in `FULFILLMENT_CENTERS`, audience
accounts in `CUSTOMERS`, and audience regions in `DEMAND_REGIONS`.
`CAPACITY_UNITS` represents distribution capacity. The illustration below shows
the prepared hubs and two audience regions.

![Prepared media distribution hubs and the Northeast and Florida audience regions](images/media-loader-hubs-regions.svg " ")

*Distribution hubs and audience regions from the workshop data. The polygons are
synthetic workshop regions; the panels use different scales.*

### Objectives

* Identify spatial points and polygons in the media data.
* Convert a database point to GeoJSON for an application map.
* Measure which media distribution hubs are closest to an audience region.
* Find audience accounts inside an audience region.
* Match each audience account to the closest active media distribution hub.

Estimated Time: **10 minutes**

### Hands-on Scenario

| Step | Media & Entertainment focus |
| --- | --- |
| Business Problem | Operations needs to route distribution requests to a hub that can respond to regional demand. |
| Technical Challenge | Moon needs to compare audience-account points with a region, then find the closest hub for each audience account. |
| Persona Focus | You review Moon's spatial approach and interpret the result for an operations user. |
| What You Will See | Oracle Spatial turns location data into audience-account routing results with SQL. |
| Database Capability | `SDO_GEOMETRY`, `SDO_GEOM.SDO_DISTANCE`, `SDO_GEOM.RELATE`, and GeoJSON conversion support the analysis. |
| Outcome | An operations user can see which audience accounts are in a region and which hub is closest to each one. |

> **SQL Worksheet reminder:** See [Getting Started, Task 2][link-1] for the
> steps to open SQL Worksheet and run SQL. Each block in this lab is one SQL
> statement; paste the complete block into an empty worksheet and select **Run
> Statement**.

## Task 1: Look at the locations as points

Moon starts with the simplest spatial question: **where are the media
distribution hubs?** The database stores each hub as an `SDO_GEOMETRY` point,
while the application can use the same point as GeoJSON.

An `SDO_GEOMETRY` point is Oracle Spatial's structured representation of one
location. For example, the Edison hub uses the WGS84 coordinate system, with
longitude `-74.4121` and latitude `40.5187`. Because the database stores the
location as geometry, Spatial functions can calculate distance and test location
relationships.

`SDO_UTIL.TO_GEOJSON` converts that geometry into a standard JSON map object
such as `{ "type": "Point", "coordinates": [-74.4121, 40.5187] }`. An
application can display that object on a map. SQL analysis and map output use
the same stored geometry.

One stored location supports spatial calculations, relational joins, and JSON
map output. Moon can return the hub's location and operational details in the
same query.

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

    `LOCATION` stores the point; `LATITUDE` and `LONGITUDE` expose its
    coordinates. `LOCATION_GEOJSON` returns the same point for a map, with
    longitude before latitude. `SDO_UTIL.TO_GEOJSON` returns a CLOB.
    `DBMS_LOB.SUBSTR` limits its displayed text to 120 characters while
    preserving the stored geometry.

    **Expected output: Media Distribution Hub Points**

    ![Media distribution hub coordinates and GeoJSON for IDs 1, 3, and 16](images/media-hub-points.jpg)

2. Review the point data.

    Check the hub names, coordinates, and GeoJSON values. The point used by the
    application and the point used by SQL are the same value. The database can
    calculate with it, and the application can display it.

    Moon keeps each hub's location beside its name, capacity, operating status,
    and current load. SQL can calculate distance and return those details, while
    `SDO_UTIL.TO_GEOJSON` gives the application the same location for a map.

## Task 2: Find the closest hubs to an audience region

The Northeast Streaming Corridor has a demand index of `91`, making it a useful
region for the first routing review. Moon now measures the distance from each
distribution-hub point to the region polygon.

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
    WHERE dr.region_name = 'Northeast Streaming Corridor'
    ORDER BY boundary_distance_km, fc.center_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    `SDO_GEOM.SDO_DISTANCE` compares the distribution-hub point with the
    audience-region polygon. The function returns the shortest distance between
    the two shapes. A value of `0` means the point is inside or touching the
    region.

    The function takes four arguments:

    * `fc.location` is the first geometry: the distribution-hub point.
    * `dr.boundary` is the second geometry: the audience-region polygon.
    * `0.005` is the tolerance used when Oracle compares the geometries. It
      helps Oracle handle small differences in the stored coordinates.
    * `'unit=KM'` tells Oracle to return the distance in kilometers. Change it
      to `'unit=MILE'` when the application needs miles.

    The `ROUND(..., 2)` around the function result only formats the answer to
    two decimal places. It does not change the spatial calculation.

    The query also returns `DEMAND_INDEX`, so Moon can read location and demand
    together. Start by reviewing hubs with the smallest distance. This query
    does not filter for active hubs or check available capacity; Task 3 returns
    the closest active hub and its capacity and load.

    **Expected output: Northeast Streaming Coverage**

    The first row is the closest Seer Media hub to the Northeast Streaming
    Corridor. The region has a demand index of `91`.

    ![Media hubs ranked by distance to the Northeast Streaming Corridor](images/media-northeast-distance.jpg)

2. Try another region.

    Change the region name to `Florida Family Watch Zone`, add a miles
    calculation, and run the modified query:

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
    WHERE dr.region_name = 'Florida Family Watch Zone'
    ORDER BY boundary_distance_km, fc.center_id
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    ![Media hubs ranked by distance to the Florida Family Watch Zone in kilometers and miles](images/media-florida-distance.jpg)

    The `unit` parameter controls the measurement unit. The closest Seer Media
    hub may be inside the Florida Family Watch Zone boundary, producing a
    distance of `0`. Florida Family Watch Zone has a demand index of `78`.

    This is a useful regional result, but distance to the region does not
    identify the audience accounts that need distribution support. Moon now uses
    the region polygon to find those accounts and then ranks active hubs by
    distance for each one.

## Task 3: Route audience accounts to the closest hub

Moon now needs a result that an operations application can use: audience
accounts inside the Northeast Streaming Corridor, their audience region, and the
closest active distribution hub. The query first compares account points
(**`c.location`**) with the region polygon (**`dr.boundary`**). It then compares
each matching account with every active hub and keeps the closest one.

1. Run the audience-account routing query:

    ```sql
    <copy>
    WITH regional_audience_accounts AS (
      SELECT dr.region_name,
             dr.demand_index,
             c.customer_id,
             c.first_name || ' ' || c.last_name AS audience_account,
             c.email,
             c.customer_tier,
             c.location
      FROM customers c
      CROSS JOIN demand_regions dr
      WHERE dr.region_name = 'Northeast Streaming Corridor'
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
             rc.audience_account,
             rc.email,
             rc.customer_tier,
             fc.center_name,
             fc.city AS hub_city,
             fc.capacity_units,
             fc.current_load_pct,
             ROUND(
               SDO_GEOM.SDO_DISTANCE(
                 rc.location,
                 fc.location,
                 0.005,
                 'unit=KM'
               ), 2
             ) AS account_hub_distance_km,
             ROW_NUMBER() OVER (
               PARTITION BY rc.customer_id
               ORDER BY SDO_GEOM.SDO_DISTANCE(
                          rc.location,
                          fc.location,
                          0.005,
                          'unit=KM'
                        ), fc.center_id
             ) AS center_rank
      FROM regional_audience_accounts rc
      CROSS JOIN fulfillment_centers fc
      WHERE fc.is_active = 1
    )
    SELECT region_name,
           demand_index,
           customer_id,
           audience_account,
           email,
           customer_tier,
           center_name,
           hub_city,
           capacity_units,
           current_load_pct,
           account_hub_distance_km
    FROM ranked_centers
    WHERE center_rank = 1
    ORDER BY account_hub_distance_km, customer_id
    FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    `SDO_GEOM.RELATE` keeps audience accounts whose point falls inside or
    touches the Northeast Streaming Corridor polygon. `SDO_GEOM.SDO_DISTANCE`
    then measures the distance from each matching audience account to every
    active hub. `ROW_NUMBER` keeps the nearest hub for each audience account.

2. Review the result as an operations decision.

    Each row gives an operations user an audience account, the closest active
    hub, and the information needed to decide where distribution work should go.
    The result combines the region's demand score, account details, hub
    capacity, current load, and spatial distance in one SQL result.

    A dashboard can present these details when a user selects a region. The
    query selects the closest active hub by geographic distance. It does not
    rank hubs by spare capacity, measure network latency, reserve capacity, or
    assign campaign orders. Operations can review capacity and load before
    making that decision.

    ![Northeast audience accounts matched to their closest active media hub](images/media-northeast-routing.png)

3. Change the query to `Florida Family Watch Zone`.

    Compare the audience accounts and recommended hubs with the Northeast
    result. The spatial predicates stay the same; only the region changes. An
    operations dashboard can run this query when a user selects a different
    audience region.

    ![Florida audience accounts routed to their closest media distribution hub](images/media-florida-routing.png)

## Conclusion: Turn Location into a Distribution Decision

Moon's analysis moves from a point, to distance, to audience-account routing. An
operations user can select a region and get a list of audience accounts, their
closest active distribution hubs, and the distance to each hub. The result
includes capacity and load so operations can review them before assigning
distribution work.

One query identifies audience accounts with spatial functions and joins them to
relational account and hub data. Spatial calculations and GeoJSON map output use
the same database locations, so a dashboard can display the map and operational
details from one source.

## Next Steps

You used Oracle Spatial to turn points and polygons into a routing decision. For
a deeper hands-on workshop focused on Oracle Spatial, open the
<!-- markdownlint-disable-next-line MD013 -->
[Oracle Spatial LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=800).

## Acknowledgements

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano, Linda Foinding
* **Last Updated By/Date** - Vahn Kessler, September 2026

[link-1]: ?lab=getting-started#Task2:OpenSQLWorksheet
