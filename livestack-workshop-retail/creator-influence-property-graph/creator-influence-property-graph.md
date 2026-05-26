# Creator Influence Network with Property Graph

## Introduction

A social commerce lead, creator partnerships manager, or merchandising strategist needs to understand which creators and communities can move product demand. Follower counts alone do not show relationship paths, community bridges, brand propagation, or co-creator influence.

Oracle AI Database helps by modeling creator, brand, product, and post relationships as a property graph over governed retail data. In the application, Creator Influence Network visualizes those communities. In SQL Worksheet, you run graph checks and `GRAPH_TABLE` traversals that prove those relationships are queryable database evidence.

Estimated Time: 10 minutes

### Objectives

- Verify the `INFLUENCER_NETWORK` property graph.
- Count the graph source tables.
- Run one-hop and two-hop `GRAPH_TABLE` traversals.
- Connect graph results to creator, community, and product-demand decisions.


## Task 1: Verify graph objects and source rows
1. Review the related application screen before you run the SQL.

    ![Creator Influence Network graph overview](images/creator-influence-network-overview.png " ")

    *Figure 1: Creator Influence Network shows communities and relationship paths instead of a flat creator list.*

2. Run this graph check.

    A creator network is more than a flat list of influencers. This query confirms that the database has a property graph object that can model relationships among creators, brands, products, and posts.

    ```sql
    <copy>
    SELECT owner AS "Owner", graph_name AS "Graph"
    FROM all_property_graphs
    WHERE owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
      AND graph_name = 'INFLUENCER_NETWORK';
    </copy>
    ```

    Expected output:

    | Owner | Graph |
    | --- | --- |
    | LLUSER | `INFLUENCER_NETWORK` |
    {: title="Influencer Property Graph"}

3. Count the graph source tables.

    Property graphs are most valuable when they are built from governed source data. Counting the source tables shows that the graph is grounded in actual retail entities, not a separate visualization-only copy.

    ```sql
    <copy>
    SELECT 'Influencers' AS "Source", COUNT(*) AS "Rows" FROM influencers
    UNION ALL SELECT 'Social posts', COUNT(*) FROM social_posts
    UNION ALL SELECT 'Influencer connections', COUNT(*) FROM influencer_connections
    UNION ALL SELECT 'Brand influencer links', COUNT(*) FROM brand_influencer_links
    UNION ALL SELECT 'Post product mentions', COUNT(*) FROM post_product_mentions;
    </copy>
    ```

    Expected output:

    | Source | Rows |
    | --- | ---: |
    | Influencers | 483 |
    | Social posts | 5000 |
    | Influencer connections | 3042 |
    | Brand influencer links | 1789 |
    | Post product mentions | 3503 |
    {: title="Graph Source Row Counts"}

## Task 2: Traverse creator relationships
1. Use the live Creator Influence Network context from Figure 1 before you run the SQL.

2. Run this one-hop traversal.

    A one-hop traversal reveals direct creator-to-creator influence paths. Retail teams use those paths to see how a campaign, product mention, or brand signal can move through a creator network.

    ```sql
    <copy>
    SELECT src_handle AS "From",
           dst_handle AS "To",
           connection_type AS "Link",
           strength AS "Strength"
    FROM GRAPH_TABLE ( influencer_network
      MATCH (src IS influencer) -[e IS connects_to]-> (dst IS influencer)
      COLUMNS (
        src.handle AS src_handle,
        dst.handle AS dst_handle,
        e.connection_type AS connection_type,
        e.strength AS strength
      )
    )
    ORDER BY strength DESC, src_handle, dst_handle
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | From | To | Link | Strength |
    | --- | --- | --- | --- |
    | `@beauty_sarah` | `@beauty_nora` | collaborates | 0.999 |
    | `@solar_drew` | `@pure_nora` | duet | 0.999 |
    | `@thunder_sarah` | `@mist_max` | duet | 0.999 |
    | `@flame_jack` | `@aura_reed` | duet | 0.998 |
    | `@golden_ruby` | `@fit_zoe` | tagged | 0.998 |
    | `@luxe_maya` | `@bloom_pia` | `inspired_by` | 0.998 |
    | `@rift_sarah` | `@urban_tess` | reshared | 0.998 |
    | `@sage_maya` | `@luxe_jace` | collaborates | 0.998 |
    | `@golden_liam` | `@tech_luna` | tagged | 0.997 |
    | `@luxe_xena` | `@nexus_cleo` | collaborates | 0.997 |
    {: title="Creator Relationship Traversal"}

3. Run this brand reach query.

    Brand reach turns graph relationships into a business metric. This query shows which brands have broader creator coverage and stronger social evidence.

    ```sql
    <copy>
    SELECT promoter AS "Promoter",
           reached AS "Reached",
           relationship_type AS "Relationship"
    FROM GRAPH_TABLE ( influencer_network
      MATCH (b IS brand) <-[p IS promotes]- (i IS influencer) -[c IS connects_to]-> (j IS influencer)
      COLUMNS (
        i.handle AS promoter,
        j.handle AS reached,
        p.relationship_type AS relationship_type
      )
    )
    ORDER BY promoter, reached
    FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```

    Expected output:

    | Promoter | Reached | Relationship |
    | --- | --- | --- |
    | `@aura_aria` | `@crystal_cleo` | organic |
    | `@aura_aria` | `@crystal_cleo` | organic |
    | `@aura_aria` | `@crystal_cleo` | organic |
    | `@aura_aria` | `@foodie_nina` | organic |
    | `@aura_aria` | `@foodie_nina` | organic |
    | `@aura_aria` | `@foodie_nina` | organic |
    | `@aura_aria` | `@nexus_liam` | organic |
    | `@aura_aria` | `@nexus_liam` | organic |
    | `@aura_aria` | `@nexus_liam` | organic |
    | `@aura_aria` | `@nova_max` | organic |
    {: title="Brand Reach Paths"}

4. A merchandiser can use the traversal to find which creator communities may amplify demand or returns exposure for a product category.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
