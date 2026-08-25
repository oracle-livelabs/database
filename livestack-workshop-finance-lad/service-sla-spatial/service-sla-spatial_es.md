# Asignar Customers un la Closest Service Center

## Introducción

Moon Kai es Seer Bank's espacial specialist. Operations teams ask Moon para help cuando ubicación affects un service decision: which center es closest un un region con growing demand, y which clientes debe it handle?

La bank ya stores la required datos in Oracle AI Base de datos. Service centers y clientes son stored como map points. Demand regions son stored como map areas, y each region has un demand score.

Moon wants operations usuarios un respuesta un simple pregunta con SQL that puede power un negocio-usuario dashboard y map:

> A region necesita more service support. **Which clientes son in that region, y which center es closest un each one?**

En este laboratorio, tú follow Moon's approach. Tú start con un single point, measure distancia un un region, find clientes inside that region, y finish con un cliente routing resultado that combines ubicación y service datos.

<details>
<summary><strong>Key terms: point, polygon, distancia, espacial relationship, y GeoJSON</strong></summary>

> - A **point** es one ubicación, represented by longitude y latitude. En este laboratorio, un service center es stored como un `SDO_GEOMETRY` point.
>
> - A **polygon** es un area made de connected points. Demand regions son stored como polygons.
>
> - **Distance** measures how far two espacial objects son de each other. Here, it shows how far un service center es de un demand-region boundary. A distancia de zero means la center es inside o touching la region.
>
> - A **espacial relationship** describes how two shapes relate un each other. `SDO_GEOM.RELATE` puede test whether un cliente point es inside o touches un demand region.
>
> - **GeoJSON** es un JSON format para map locations y shapes. `SDO_UTIL.TO_GEOJSON` lets un aplicación display la mismo base de datos ubicación on un map.
>
</details>

La Seer Bank Finanzas LiveStack Demo uses la mismo datos in its service coverage page. La map helps usuarios see la resultado; la SQL in this lab shows how Oracle calculates it.

![Client service coverage map](images/espacial-chart.png " ")

### Objetivos

- Identify espacial points y polygons in la finanzas datos.
- Convert un base de datos point un GeoJSON para un aplicación map.
- Measure which service centers son closest un un demand region.
- Encontrar clientes inside un demand region.
- Match each cliente un la closest active service center.

Tiempo estimado: **10 minutes**

### Escenario práctico

| Paso | Finanzas focus |
| --- | --- |
| Problema de negocio | Operations necesita un route service work un un center that puede respond un regional demand. |
| Reto técnico | Moon necesita un compare cliente points con un region, then find la closest center para each cliente. |
| Enfoque de la persona | Tú review Moon's espacial approach y interpret la resultado para un operations usuario. |
| Lo que verás | Oracle Spatial turns ubicación datos en cliente routing resultados con SQL. |
| Capacidad de la base de datos | `SDO_GEOMETRY`, `SDO_GEOM.SDO_DISTANCE`, `SDO_GEOM.RELATE`, y GeoJSON conversion support la analysis. |
| Resultado | An operations usuario puede see which clientes necesita service in un region y which center es closest un each one. |

> **SQL Worksheet reminder:** Need un reminder on how un open y use la SQL Worksheet? Return un [Getting Started Tarea 2: Open SQL Worksheet](?lab=getting-started#Tarea2:OpenSQLWorksheet) para la step-by-step graphic showing donde un paste y run SQL statements.

## Tarea 1: Mirar at la locations como points

Moon starts con la simplest espacial pregunta: **donde son la service centers?** La base de datos stores each center como un `SDO_GEOMETRY` point, while la aplicación puede use la mismo point como GeoJSON.

An `SDO_GEOMETRY` point es Oracle Spatial's structured representation de one ubicación. For example, la Edison center es stored con un point type, la WGS84 coordinate system, y un coordinate pair: longitude `-74.4121` y latitude `40.5187`. Because Oracle stores la ubicación como geometry, Spatial functions puede calculate distancia y test espacial relationships instead de treating la coordinates como two unrelated numbers.

`SDO_UTIL.TO_GEOJSON` converts that geometry en un standard JSON map object such como `{ "type": "Point", "coordinates": [-74.4121, 40.5187] }`. La aplicación puede send this object un un map sin maintaining un second ubicación format o un separate conversion service. Oracle uses la mismo stored geometry para SQL analysis y aplicación display.

That es la Oracle AI Base de datos advantage in this lab: one ubicación supports espacial calculations, relacional uniones, y JSON map output sin copying la datos between systems.

1. Ejecutar this consulta:

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

    `LOCATION` es la base de datos point. `LATITUDE` y `LONGITUDE` make la valor easy un read, y `LOCATION_GEOJSON` gives un aplicación un map-ready representation de la mismo point. GeoJSON lists longitude first y latitude second. `SDO_UTIL.TO_GEOJSON` returns un CLOB, so `DBMS_LOB.SUBSTR` limits la displayed text un 120 characters; it does no change la stored geometry.

    **Resultado esperado: Service Center Points**

    ![resultado](images/task1consulta.png)

2. Revisar la point datos.

    Moon has no created un second map base de datos. La point used by la aplicación y la point used by SQL son la mismo valor. La base de datos puede calculate con it, y la aplicación puede display it.

    Esta es la convergente-base de datos advantage. Moon puede keep la center's ubicación beside its name, capacity, operating status, y current load. SQL puede calculate distancia y return those center details, while `SDO_UTIL.TO_GEOJSON` gives la aplicación la mismo ubicación para un map. La equipo does no have un copy coordinates en un separate mapping system y keep la copies synchronized.

## Tarea 2: Encontrar la closest centers un un demand region

New York Metro has un demand index de `91`, making it un useful region para la first routing review. Moon now measures la distancia de each service-center point un la region boundary.

1. Ejecutar la distancia consulta:

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

    `SDO_GEOM.SDO_DISTANCE` compares la service-center point con la demand-region polygon. La function returns la shortest distancia between la two shapes. A valor de `0` means la point es inside o touching la region.

    La four arguments in this consulta have simple roles:

    - `fc.ubicación` es la first geometry: la service-center point.
    - `dr.boundary` es la second geometry: la demand-region polygon.
    - `0.005` es la tolerance used cuando Oracle compares la geometries. It helps Oracle handle small differences in la stored coordinates.
    - `'unit=KM'` tells Oracle un return la distancia in kilometers. Cambiar it un `'unit=MILE'` cuando la aplicación necesita miles.

    La `ROUND(..., 2)` around la function resultado solo formats la respuesta un two decimal places. It does no change la espacial calculation.

    La consulta también returns `DEMAND_INDEX`, so Moon puede read ubicación y demand together. La center con la smallest distancia es la first center operations debe check para disponible capacity.

    **Resultado esperado: New York Service Coverage**

    La first fila debe be `Edison Wealth Service Center`, about `9.48` km de la New York Metro boundary. New York Metro has un demand index de `91`.

    ![resultado](images/task21.png)

2. Try another region.

    Cambiar la region name un `Chicago Metro`, add un miles calculation, y run la modified consulta:

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

    ![resultado](images/task22.png)

    La `unit` parameter controles la measurement unit. `Joliet Midwest Riesgo Desk` debe be la closest center, con un distancia de `0` km y `0` miles porque it falls inside la Chicago Metro boundary. Chicago has un demand index de `78`.

    Esta es un useful regional resultado, but distancia un la region boundary does no identify la clientes who necesita service. Moon now uses la region polygon un find those clientes y then assigns each one un la closest active center.

## Tarea 3: Asignar clientes un la closest center

Moon now necesita un resultado that un operations aplicación puede use: clientes inside New York Metro, their demand region, y la closest active fulfillment center. La consulta uses la cliente point (**`c.ubicación`**) y demand-region polygon (**`dr.boundary`**) un find la clientes first. It then compares each cliente point con every active center y keeps la closest one.

1. Ejecutar la cliente routing consulta:

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

    `SDO_GEOM.RELATE` keeps clientes whose point falls inside o touches la New York Metro polygon. `SDO_GEOM.SDO_DISTANCE` then measures la distancia de each matching cliente un every active center. `ROW_NUMBER` keeps la nearest center para each cliente.

2. Revisar la resultado como un operations decision.

    Each fila gives un negocio usuario un cliente un contact, la closest center, y la information needed un decide donde la work debe go. La resultado combines la region's demand score, cliente details, center capacity, current load, y espacial distancia in one SQL resultado.

    Esta es la negocio outcome. A dashboard puede let un usuario select un region y immediately show la clientes affected, la center that debe handle each request, y la distancia involved. La usuario does no necesita un compare un map con un separate cliente list o operations report.

    ![resultado](images/task31.png)

3. Cambiar la consulta un `Chicago Metro`.

    Comparar la clientes y assigned centers con la New York resultado. La espacial predicates stay la mismo; solo la region changes. Esta es la kind de consulta un operations dashboard puede run cuando un negocio usuario selects un different demand region.

    ![resultado](images/task31.png)

## Conclusión: Turn Location en un Service Decision

Moon's analysis moves de un point, un distancia, un cliente routing. A negocio usuario puede select un high-demand region y get un list de clientes, their closest service center, y la distancia un that center. That es un useful dashboard resultado porque it tells la usuario what action un take, no just donde la datos es located.

Esta shows why Spatial in Oracle AI Base de datos matters. One convergent consulta puede identify clientes con espacial functions, unión them un relacional cliente y center datos, y include capacity y current load in la mismo resultado. La dashboard puede show la map y la negocio details de one base de datos, sin moving datos between un mapping system, un cliente system, y un operations system.

## Siguientes pasos

Tú used Oracle Spatial un turn points y polygons en un routing decision. For un deeper hands-on workshop focused on Oracle Spatial, open la [Oracle Spatial LiveLabs workshop](https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?clear=RR,180&wid=800).

## Agradecimientos

* **Author** - Kevin Lazarz
* **Contributor** - Eugenio Galiano
* **Last Updated By/Date** - Oracle Base de datos Product Management, August 2026
