# Lab 5: Network Access and Field Operations

## Introduction

Location changes the meaning of a network problem. A capacity issue near a high-demand zone needs different action than the same issue in a quiet area. Oracle Spatial connects network sites, service zones, demand density, and field dispatch context to the same operational data foundation.

Estimated Time: 10 minutes

| Operating Story | Detail |
| --- | --- |
| Business Problem | Field teams need to know where capacity and demand are misaligned. |
| Technical Challenge | Location, service orders, network capacity, and demand forecasts often sit in separate tools. |
| Persona Focus | Field operations manager, network access planner, and NOC dispatcher. |
| What You Will Learn | Spatial objects and SQL can support network-site, zone, and dispatch decisions. |
| Database Capability | Oracle Spatial, `SDO_GEOMETRY`, spatial joins, distance calculations. |
| Outcome | Operators can turn map context into capacity action. |
{: title="What this lab covers"}

**Persona focus:** You are the field operations manager deciding which sites need capacity relief.

### Objectives

- Inspect network sites that carry location and capacity context.
- Use spatially relevant capacity evidence to identify constrained sites.
- Connect dispatch activity to the network sites that need field attention.

The image below is the network access map. Field operations teams use this view to connect service pressure to physical sites and regions. The SQL in this lab explains the site and capacity evidence behind that map.

![Network access map](images/network-access-map.png)

The concept diagram below introduces the spatial operations pattern. It shows how location, capacity, and dispatch data can stay connected so teams can act on places, not just rows.

![Lab 5: Network Access and Field Operations concept diagram](images/spatial-flow.svg)

## How This Lab Fits the Story

You turn impact into a field decision. The spatial and capacity queries show where network sites, demand, and dispatch work meet, which helps operations teams decide where capacity relief should start first.

## Scene Evidence

Use the screenshot to orient the field operations scenario. The SQL tasks below show the location, capacity, and dispatch evidence an operations team would use before sending work into the field.

The image below is the capacity risk table. It gives field operations a short list of where service demand may exceed available access capacity. The SQL in this lab recreates that evidence from governed network capacity rows.

![Capacity risk table](images/capacity-risk-table.png)

## Task 1: Inspect network sites

1. Run this SQL block.

    This query identifies active sites and their current load. It reads the network site view, filters to active sites, and orders by load percentage. On a map, a site marker is only useful when you also know how hard that site is working.

    ```sql
    <copy>
    SELECT network_site_name, network_site_type, city, state_province, service_capacity_units, current_capacity_load_pct
    FROM seer_comms_network_sites_v
    WHERE is_active = 1
    ORDER BY current_capacity_load_pct DESC
    FETCH FIRST 8 ROWS ONLY;
    </copy>
    ```

    **Expected output: Network sites available for spatial analysis**

    | Network Site Name | Network Site Type | City | State Province | Service Capacity Units | Current Capacity Load Pct |
    | --- | --- | --- | --- | ---: | ---: |
    | Atlanta Home Internet Dispatch | NOC / regional operations hub | Atlanta | GA | 5850 | 82 |
    | Dallas 5G Dispatch Center | Fiber or device field hub | Dallas | TX | 5500 | 79 |
    {: title="Network sites available for spatial analysis"}

## Task 2: Find capacity risk by service and site

1. Run this SQL block.

    This query turns capacity thresholds into a short list of places that may need action. The `CASE` expression labels rows as capacity risk when available capacity is at or below the escalation threshold. That helps field operations separate normal load from sites that are getting too close to the limit.

    ```sql
    <copy>
    SELECT service_name,
       network_site_name,
       capacity_available,
       capacity_reserved,
       escalation_threshold,
       CASE WHEN capacity_available <= escalation_threshold THEN 'Capacity risk' ELSE 'Available' END AS capacity_status
    FROM seer_comms_network_capacity_v
    WHERE capacity_available <= escalation_threshold
    ORDER BY capacity_available
    FETCH FIRST 8 ROWS ONLY;
    </copy>
    ```

    **Expected output: Capacity risks by service and site**

    | Service Name | Network Site Name | Capacity Available | Capacity Reserved | Escalation Threshold | Capacity Status |
    | --- | --- | ---: | ---: | ---: | --- |
    | Number Port-In Activation | NYC Network Command Center | 37 | 16 | 50 | Capacity risk |
    | Gigabit Fiber Install | Houston Roaming Operations Hub | 55 | 21 | 60 | Capacity risk |
    {: title="Capacity risks by service and site"}

## Task 3: Review field dispatch evidence

1. Run this SQL block.

    This query connects capacity pressure to active field work. It filters out completed dispatches and returns the network site tied to each open job. That helps operations teams ask a practical question: do we already have work moving toward the sites that need help?

    ```sql
    <copy>
    SELECT dispatch_id, service_order_id, network_site_name, dispatch_status
    FROM seer_comms_field_dispatch_v
    WHERE dispatch_status <> 'Completed'
    ORDER BY dispatch_id
    FETCH FIRST 6 ROWS ONLY;
    </copy>
    ```

    **Expected output: Field dispatches tied to network sites**

    | Dispatch ID | Service Order ID | Network Site Name | Dispatch Status |
    | ---: | ---: | --- | --- |
    | 1 | 3 | Phoenix Device Logistics Hub | In Progress |
    | 5 | 11 | Houston Roaming Operations Hub | In Progress |
    {: title="Field dispatches tied to network sites"}



## Learn More

- See `ORACLE_REFERENCE_LINKS.md` in the supporting files directory for official Oracle documentation links.

## Acknowledgements

- **Author** - Oracle LiveLabs Team
