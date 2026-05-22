/*
 * 03_graph.sql
 * Property Graph for influencer networks and brand propagation
 * Oracle 26ai — SQL/PGQ (Property Graph Queries)
 */

-- ============================================================
-- INFLUENCER CONNECTIONS (edges for the graph)
-- Represents: follows, collaborates_with, mentioned_by, reshared_from
-- ============================================================
CREATE TABLE influencer_connections (
    connection_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_influencer   NUMBER NOT NULL REFERENCES influencers(influencer_id),
    to_influencer     NUMBER NOT NULL REFERENCES influencers(influencer_id),
    connection_type   VARCHAR2(30) NOT NULL
                      CHECK (connection_type IN ('follows','collaborates','mentioned',
                             'reshared','tagged','duet','inspired_by')),
    strength          NUMBER(4,3) DEFAULT 0.5,  -- 0-1 edge weight
    interaction_count NUMBER(8) DEFAULT 1,
    first_seen        TIMESTAMP DEFAULT SYSTIMESTAMP,
    last_interaction  TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT uq_connection UNIQUE (from_influencer, to_influencer, connection_type)
);

CREATE INDEX idx_conn_from ON influencer_connections(from_influencer);
CREATE INDEX idx_conn_to   ON influencer_connections(to_influencer);

-- ============================================================
-- BRAND ↔ INFLUENCER RELATIONSHIPS
-- ============================================================
CREATE TABLE brand_influencer_links (
    link_id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand_id          NUMBER NOT NULL REFERENCES brands(brand_id),
    influencer_id     NUMBER NOT NULL REFERENCES influencers(influencer_id),
    relationship_type VARCHAR2(30) DEFAULT 'organic'
                      CHECK (relationship_type IN ('organic','sponsored','ambassador',
                             'affiliate','competitor_mention')),
    post_count        NUMBER(8) DEFAULT 0,
    avg_engagement    NUMBER(8,4) DEFAULT 0,
    revenue_attributed NUMBER(12,2) DEFAULT 0,
    first_mention     TIMESTAMP,
    last_mention      TIMESTAMP,
    CONSTRAINT uq_brand_inf UNIQUE (brand_id, influencer_id)
);

-- ============================================================
-- PROPERTY GRAPH DEFINITION
-- This creates the graph over existing relational tables
-- ============================================================
CREATE PROPERTY GRAPH influencer_network
    VERTEX TABLES (
        influencers KEY (influencer_id)
            LABEL influencer
            PROPERTIES (
                influencer_id,
                handle,
                display_name,
                platform,
                follower_count,
                engagement_rate,
                influence_score,
                niche,
                city,
                region,
                is_verified
            ),
        brands KEY (brand_id)
            LABEL brand
            PROPERTIES (
                brand_id,
                brand_name,
                brand_category,
                social_tier
            ),
        products KEY (product_id)
            LABEL product
            PROPERTIES (
                product_id,
                product_name,
                category,
                unit_price
            ),
        -- SOURCE vertex for the mentions_product edge
        social_posts KEY (post_id)
            LABEL social_post
            PROPERTIES (
                post_id,
                platform,
                posted_at,
                virality_score,
                momentum_flag
            )
    )
    EDGE TABLES (
        influencer_connections
            KEY (connection_id)
            SOURCE KEY (from_influencer) REFERENCES influencers (influencer_id)
            DESTINATION KEY (to_influencer) REFERENCES influencers (influencer_id)
            LABEL connects_to
            PROPERTIES (
                connection_type,
                strength,
                interaction_count
            ),
        brand_influencer_links
            KEY (link_id)
            SOURCE KEY (influencer_id) REFERENCES influencers (influencer_id)
            DESTINATION KEY (brand_id) REFERENCES brands (brand_id)
            LABEL promotes
            PROPERTIES (
                relationship_type,
                post_count,
                avg_engagement,
                revenue_attributed
            ),
        post_product_mentions
            KEY (mention_id)
            SOURCE KEY (post_id) REFERENCES social_posts (post_id)
            DESTINATION KEY (product_id) REFERENCES products (product_id)
            LABEL mentions_product
            PROPERTIES (
                confidence_score,
                mention_type
            )
    );

-- ============================================================
-- GRAPH QUERY EXAMPLES (for reference / demo use)
-- ============================================================

/*
-- Find influencers within 2 hops of a viral post's author
SELECT v2.handle, v2.influence_score, v2.follower_count
FROM GRAPH_TABLE ( influencer_network
    MATCH (v1 IS influencer) -[e IS connects_to]-> (v2 IS influencer)
    WHERE v1.handle = '@fashionista_sarah'
    COLUMNS (
        v2.handle,
        v2.influence_score,
        v2.follower_count
    )
)
ORDER BY v2.influence_score DESC
FETCH FIRST 20 ROWS ONLY;

-- Find shortest propagation path between two influencers
SELECT *
FROM GRAPH_TABLE ( influencer_network
    MATCH SHORTEST (a IS influencer) -[e IS connects_to]->{1,5} (b IS influencer)
    WHERE a.handle = '@techguru_mike'
      AND b.handle = '@lifestyle_jen'
    COLUMNS (
        a.handle AS source,
        b.handle AS target,
        LISTAGG(e.connection_type, ' → ') AS path_types
    )
);

-- Brand propagation: which influencers propagate a brand through the network
SELECT v1.handle AS promoter,
       v2.handle AS reached,
       e1.relationship_type,
       e2.connection_type,
       e2.strength
FROM GRAPH_TABLE ( influencer_network
    MATCH (b IS brand) <-[e1 IS promotes]- (v1 IS influencer)
          -[e2 IS connects_to]-> (v2 IS influencer)
    WHERE b.brand_name = 'UrbanPulse'
    COLUMNS (
        v1.handle, v2.handle,
        e1.relationship_type,
        e2.connection_type,
        e2.strength
    )
)
ORDER BY e2.strength DESC;
*/

COMMIT;

SELECT 'Property graph created successfully' AS status FROM dual;
