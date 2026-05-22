/*
 * load_graph_data.sql
 * Influencer connections (3000+ edges) and brand-influencer links
 */

SET SERVEROUTPUT ON
PROMPT Loading graph edges...

DECLARE
    v_max_inf NUMBER;
    v_max_brand NUMBER;
    v_from_id NUMBER;
    v_to_id NUMBER;
    v_count    NUMBER := 0;
    v_conn_idx NUMBER;
    TYPE t_str IS TABLE OF VARCHAR2(30);
    v_conn_types t_str := t_str('follows','collaborates','mentioned','reshared','tagged','duet','inspired_by');
BEGIN
    SELECT MAX(influencer_id) INTO v_max_inf FROM influencers;
    SELECT MAX(brand_id) INTO v_max_brand FROM brands;

    -- Generate ~3000 influencer connections
    FOR i IN 1..3500 LOOP
        v_from_id := FLOOR(DBMS_RANDOM.VALUE(1, v_max_inf + 1));
        v_to_id := FLOOR(DBMS_RANDOM.VALUE(1, v_max_inf + 1));

        IF v_from_id != v_to_id THEN
            v_conn_idx := MOD(i, v_conn_types.COUNT) + 1;
            BEGIN
                INSERT INTO influencer_connections (
                    from_influencer, to_influencer, connection_type,
                    strength, interaction_count
                ) VALUES (
                    v_from_id, v_to_id,
                    v_conn_types(v_conn_idx),
                    ROUND(DBMS_RANDOM.VALUE(0.1, 1.0), 3),
                    FLOOR(DBMS_RANDOM.VALUE(1, 200))
                );
                v_count := v_count + 1;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
                WHEN OTHERS THEN NULL;
            END;
        END IF;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Influencer connections loaded: ' || v_count);

    -- Generate brand-influencer links (~1500)
    v_count := 0;
    FOR i IN 1..2000 LOOP
        BEGIN
            INSERT INTO brand_influencer_links (
                brand_id, influencer_id, relationship_type,
                post_count, avg_engagement, revenue_attributed,
                first_mention, last_mention
            ) VALUES (
                FLOOR(DBMS_RANDOM.VALUE(1, v_max_brand + 1)),
                FLOOR(DBMS_RANDOM.VALUE(1, v_max_inf + 1)),
                CASE MOD(i, 5)
                    WHEN 0 THEN 'organic'
                    WHEN 1 THEN 'organic'
                    WHEN 2 THEN 'sponsored'
                    WHEN 3 THEN 'affiliate'
                    ELSE 'ambassador'
                END,
                FLOOR(DBMS_RANDOM.VALUE(1, 100)),
                ROUND(DBMS_RANDOM.VALUE(0.01, 0.12), 4),
                ROUND(DBMS_RANDOM.VALUE(0, 50000), 2),
                SYSTIMESTAMP - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(30, 365) * 24, 'HOUR'),
                SYSTIMESTAMP - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 30) * 24, 'HOUR')
            );
            v_count := v_count + 1;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Brand-influencer links loaded: ' || v_count);
END;
/
