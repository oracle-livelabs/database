# Creator Influence Network with Property Graph

## Introduction

Follower counts are useful, but they do not show how a signal moves through a creator community. The confusing part is the relationship path: who collaborates, who amplifies a brand, and which creators connect otherwise separate groups.

This lab follows Scene 5, Creator Influence Network, in the runbook. After Lab 4 shows what customers and creators are saying, this lab shows who can amplify that signal. Oracle AI Database models creators, brands, products, and posts as a property graph over retail data. In SQL Worksheet, you run graph-style traversals that connect the visual network paths to queryable database evidence.

Estimated Time: 10 minutes

### Objectives

- Verify the `INFLUENCER_NETWORK` property graph.
- Count the governed source tables behind the graph.
- Run `GRAPH_TABLE` traversals for direct relationships and brand propagation.
- Explain how creator paths can amplify social demand signals from Lab 4.


## Task 1: Verify graph objects and source rows
1. Review the related application screen before you run the SQL.

    ![Creator Influence Network graph overview](images/creator-influence-network-overview.png " ")

    *Figure 1: Creator Influence Network shows how creator relationships can amplify product and brand signals.*

2. Run this graph check.

    A creator network is more than a flat influencer list. This block checks `ALL_PROPERTY_GRAPHS` for the graph object managed by Oracle Database. The graph models how creators, brands, products, and posts connect while keeping the relationship data in the retail schema.

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
    {: title="Property Graph"}

3. Count the graph source tables.

    Property graphs are most useful when they come from governed source data. This block counts the relational source tables that feed the graph. It shows that the graph uses the same creators, posts, mentions, and brand links that feed social trend analysis.

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
    {: title="Graph Sources"}

## Task 2: Traverse creator relationships
1. Use the live Creator Influence Network context from Figure 1 before you run the SQL.

2. Review what the relationship terms mean.

    The graph treats each creator as a node and each creator-to-creator interaction as an edge. An edge is a relationship that points from one creator to another. The `connection_type` column describes the social action behind that edge:

    - `collaborates`: two creators worked together on content, a campaign, or a shared promotion.
    - `duet`: one creator made response content linked to another creator's post, such as a duet or stitched video.
    - `tagged`: one creator mentioned or tagged another creator in a post.
    - `reshared`: one creator amplified another creator's content by reposting or sharing it.
    - `inspired_by`: one creator's content appears to have influenced another creator's content.

    The `strength` value is a score from the seeded workshop data. A higher value means the relationship is stronger in this sample network. In a real retail system, this could come from engagement, frequency, recency, campaign history, or a model score.

3. Run this one-hop traversal.

    A high-momentum post from Lab 4 is only the starting point. Retail teams also need to know who may carry that signal into another audience. This query asks one simple graph question: for each creator, which directly connected creator can they reach next?

    The `GRAPH_TABLE` clause lets SQL query the property graph. The `MATCH` pattern reads from left to right: start at a source creator, follow one `connects_to` relationship, and end at a destination creator. The `COLUMNS` section chooses which graph properties to return as regular SQL columns. The final `ORDER BY` sorts the strongest relationships first so the highest-signal paths appear at the top.

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
    {: title="Creator Relationships"}

4. Read the result as network paths.

    Each row means: the creator in **From** has a direct relationship to the creator in **To**. The **Link** column explains the type of social connection. The **Strength** column helps rank which paths may matter most. For example, a `collaborates` link suggests a shared audience or campaign relationship. A `reshared` link suggests that one creator can amplify another creator's post. A `tagged` link shows a direct mention that may expose followers to another creator or product story.

5. Run this brand propagation query.

    The first traversal looked only at creator-to-creator relationships. This query adds brands to the path. It asks: which creators promote a brand, and which other creators can they reach through a direct network connection? That pattern helps a retail team connect brand partnerships to likely audience spread.

    In the `MATCH` pattern, the brand node connects to a promoter through a `promotes` edge. The same promoter then connects to another creator through a `connects_to` edge. The query returns the promoter, the reached creator, and the brand relationship type so the path can be reviewed as business evidence.

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
    {: title="Brand Paths"}

6. This is the handoff from social signal to network action. A merchandiser can use the traversal to find creator communities that may amplify demand, returns exposure, or category momentum after Customer Trend Signals surfaces the initial product story.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Contributor** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
