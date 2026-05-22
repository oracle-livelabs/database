/*
 * load_social_posts.sql
 * 5000 social posts with realistic text, varied engagement, and product mentions
 */

SET SERVEROUTPUT ON
PROMPT Loading social posts...

DECLARE
    TYPE t_str IS TABLE OF VARCHAR2(500);

    -- Post templates with {brand} and {product} placeholders
    v_templates t_str := t_str(
        'Just got my {product} from {brand} and I am absolutely obsessed!! The quality is unreal',
        'Okay but has anyone tried the new {product}? {brand} really outdid themselves this time',
        'My {product} just arrived and wow. {brand} never disappoints',
        'POV: you finally cave and buy the {product} everyone has been talking about. Zero regrets',
        'Unboxing my new {product} from {brand}! Stay tuned for the full review',
        '{brand} {product} review after 2 weeks of daily use - is it worth the hype?',
        'Cannot believe how good the {product} is. {brand} take my money already',
        'Hot take: the {brand} {product} is the best purchase I have made all year',
        'Running errands with my new {product}. Getting so many compliments already',
        'If you are sleeping on the {product} from {brand} you are missing out fr',
        'Day 30 with the {product} and it still hits different. {brand} quality is chef kiss',
        'Just recommended the {brand} {product} to literally everyone I know',
        'Thought the {product} was overhyped but {brand} proved me wrong. This thing slaps',
        'GRWM featuring the new {product}. {brand} has been killing it lately',
        'Added the {product} to my daily rotation. Thank you {brand} for this masterpiece',
        'That moment when your {product} from {brand} arrives a day early. Today is a good day',
        'Rating the {brand} {product} a solid 9.5 out of 10. Only complaint is I didnt buy it sooner',
        'My followers keep asking about this {product}. Yes it is from {brand}. Yes it is amazing',
        '{brand} really said lets change the game with this {product}. Mission accomplished',
        'Three months with the {product} - still my favorite purchase from {brand}',
        'Gifted the {brand} {product} to my bestie and now she wants everything from them',
        'The {product} just went viral for a reason. {brand} understood the assignment',
        'Comparing the {brand} {product} to the competition and it is not even close',
        'When {brand} drops a new {product} you know I am first in line',
        'This {product} is giving everything it needs to give. Major props to {brand}',
        'Real talk the {brand} {product} changed my whole routine. Game changer status',
        'Everyone needs a {product} in their life. Trust me on this one. Thank you {brand}',
        'The attention to detail on this {product} from {brand} is next level craftsmanship',
        'Spotted: the {brand} {product} trending everywhere. Can confirm it lives up to the hype',
        'My honest review of the {product} after using it for a month. Spoiler: {brand} nailed it'
    );

    -- Additional organic-sounding posts (no brand mention)
    v_generic t_str := t_str(
        'Trying out this new skincare routine and my skin has never looked better',
        'Found the perfect workout gear for my morning runs. Absolute game changer',
        'Home office upgrade complete! New desk setup is giving productivity vibes',
        'This new coffee blend I discovered is literally the best thing ever',
        'Finally upgraded my tech setup and I cannot go back to the old one',
        'Weekend hiking with the new gear. Nature therapy hits different',
        'My closet cleanout led to finding some amazing sustainable fashion brands',
        'Testing out meal prep containers that actually keep food fresh. Mind blown',
        'New headphones just dropped and the sound quality is insane for the price',
        'Self care Sunday with all my favorite wellness products. Feeling recharged'
    );

    v_max_inf_id NUMBER;
    v_max_prod_id NUMBER;
    v_inf_id NUMBER;
    v_prod_id NUMBER;
    v_brand_name VARCHAR2(200);
    v_prod_name VARCHAR2(300);
    v_post_text CLOB;
    v_platform VARCHAR2(50);
    v_platforms t_str := t_str('instagram','tiktok','twitter','youtube','threads');
    v_likes NUMBER;
    v_shares NUMBER;
    v_comments NUMBER;
    v_views NUMBER;
    v_sentiment NUMBER;
    v_posted_at TIMESTAMP;
    v_post_id NUMBER;
    v_count NUMBER := 0;
BEGIN
    SELECT MAX(influencer_id) INTO v_max_inf_id FROM influencers;
    SELECT MAX(product_id) INTO v_max_prod_id FROM products;

    FOR i IN 1..5000 LOOP
        -- Pick random influencer
        v_inf_id := FLOOR(DBMS_RANDOM.VALUE(1, v_max_inf_id + 1));

        -- Platform from influencer or random
        BEGIN
            SELECT platform INTO v_platform FROM influencers WHERE influencer_id = v_inf_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_platform := v_platforms(MOD(i, 5) + 1);
                v_inf_id := NULL;
        END;

        -- 70% brand-mention posts, 30% generic
        IF DBMS_RANDOM.VALUE < 0.7 THEN
            -- Pick random product
            v_prod_id := FLOOR(DBMS_RANDOM.VALUE(1, v_max_prod_id + 1));
            BEGIN
                SELECT p.product_name, b.brand_name
                INTO v_prod_name, v_brand_name
                FROM products p JOIN brands b ON p.brand_id = b.brand_id
                WHERE p.product_id = v_prod_id;

                v_post_text := REPLACE(
                    REPLACE(
                        v_templates(MOD(i, v_templates.COUNT) + 1),
                        '{brand}', v_brand_name
                    ),
                    '{product}', v_prod_name
                );
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_post_text := v_generic(MOD(i, v_generic.COUNT) + 1);
                    v_prod_id := NULL;
            END;
        ELSE
            v_post_text := v_generic(MOD(i, v_generic.COUNT) + 1);
            v_prod_id := NULL;
        END IF;

        -- Generate engagement metrics with power-law distribution
        -- Most posts low engagement, some medium, few viral
        CASE
            WHEN DBMS_RANDOM.VALUE < 0.02 THEN  -- 2% mega viral
                v_likes := FLOOR(DBMS_RANDOM.VALUE(50000, 500000));
                v_shares := FLOOR(DBMS_RANDOM.VALUE(10000, 100000));
                v_comments := FLOOR(DBMS_RANDOM.VALUE(5000, 50000));
                v_views := FLOOR(DBMS_RANDOM.VALUE(1000000, 20000000));
            WHEN DBMS_RANDOM.VALUE < 0.08 THEN  -- 6% viral
                v_likes := FLOOR(DBMS_RANDOM.VALUE(10000, 50000));
                v_shares := FLOOR(DBMS_RANDOM.VALUE(2000, 15000));
                v_comments := FLOOR(DBMS_RANDOM.VALUE(1000, 8000));
                v_views := FLOOR(DBMS_RANDOM.VALUE(200000, 1000000));
            WHEN DBMS_RANDOM.VALUE < 0.25 THEN  -- 17% rising
                v_likes := FLOOR(DBMS_RANDOM.VALUE(1000, 10000));
                v_shares := FLOOR(DBMS_RANDOM.VALUE(200, 2000));
                v_comments := FLOOR(DBMS_RANDOM.VALUE(100, 1000));
                v_views := FLOOR(DBMS_RANDOM.VALUE(20000, 200000));
            ELSE  -- 75% normal
                v_likes := FLOOR(DBMS_RANDOM.VALUE(10, 1000));
                v_shares := FLOOR(DBMS_RANDOM.VALUE(0, 100));
                v_comments := FLOOR(DBMS_RANDOM.VALUE(0, 50));
                v_views := FLOOR(DBMS_RANDOM.VALUE(100, 20000));
        END CASE;

        -- Sentiment: mostly positive for product mentions
        v_sentiment := CASE
            WHEN v_prod_id IS NOT NULL THEN ROUND(DBMS_RANDOM.VALUE(0.2, 0.95), 3)
            ELSE ROUND(DBMS_RANDOM.VALUE(-0.3, 0.9), 3)
        END;

        -- Posted within last 30 days, weighted toward recent
        v_posted_at := SYSTIMESTAMP - NUMTODSINTERVAL(
            POWER(DBMS_RANDOM.VALUE(0, 1), 2) * 30 * 24, 'HOUR'
        );

        INSERT INTO social_posts (
            influencer_id, platform, external_post_id, post_text,
            posted_at, likes_count, shares_count, comments_count, views_count,
            sentiment_score, momentum_flag
        ) VALUES (
            v_inf_id,
            v_platform,
            'ext_' || LOWER(v_platform) || '_' || LPAD(i, 8, '0'),
            v_post_text,
            v_posted_at,
            v_likes, v_shares, v_comments, v_views,
            v_sentiment,
            CASE
                WHEN v_likes > 50000 THEN 'mega_viral'
                WHEN v_likes > 10000 THEN 'viral'
                WHEN v_likes > 1000  THEN 'rising'
                ELSE 'normal'
            END
        ) RETURNING post_id INTO v_post_id;

        -- Insert product mention if we have one
        IF v_prod_id IS NOT NULL THEN
            BEGIN
                INSERT INTO post_product_mentions (
                    post_id, product_id, confidence_score, mention_type
                ) VALUES (
                    v_post_id, v_prod_id,
                    ROUND(DBMS_RANDOM.VALUE(0.7, 1.0), 3),
                    CASE MOD(i, 5)
                        WHEN 0 THEN 'direct'
                        WHEN 1 THEN 'semantic'
                        WHEN 2 THEN 'hashtag'
                        WHEN 3 THEN 'visual'
                        ELSE 'inferred'
                    END
                );
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;
        END IF;

        v_count := v_count + 1;

        IF MOD(v_count, 500) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Social posts loaded: ' || v_count);
END;
/
