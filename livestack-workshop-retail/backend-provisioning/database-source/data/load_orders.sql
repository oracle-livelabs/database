/*
 * load_orders.sql
 * 3000 orders with line items, varied statuses, and social attribution
 */

SET SERVEROUTPUT ON
PROMPT Loading orders...

DECLARE
    v_min_cust NUMBER; v_max_cust NUMBER;
    v_min_prod NUMBER; v_max_prod NUMBER;
    v_min_post NUMBER; v_max_post NUMBER;
    v_min_center NUMBER; v_max_center NUMBER;
    v_cust_id NUMBER;
    v_order_id NUMBER;
    v_num_items NUMBER;
    v_prod_id NUMBER;
    v_price NUMBER;
    v_qty NUMBER;
    v_total NUMBER;
    v_status VARCHAR2(30);
    v_center_id NUMBER;
    v_social_id NUMBER;
    v_count NUMBER := 0;
    v_distance NUMBER;
    v_est_hours NUMBER;

    TYPE t_str IS TABLE OF VARCHAR2(30);
    v_statuses t_str := t_str('pending','confirmed','processing','shipped','delivered','delivered','delivered','cancelled');
BEGIN
    SELECT MIN(customer_id), MAX(customer_id) INTO v_min_cust, v_max_cust FROM customers;
    SELECT MIN(product_id),  MAX(product_id)  INTO v_min_prod, v_max_prod FROM products;
    SELECT MIN(post_id),     MAX(post_id)     INTO v_min_post, v_max_post FROM social_posts;
    SELECT MIN(center_id),   MAX(center_id)   INTO v_min_center, v_max_center FROM fulfillment_centers;

    FOR i IN 1..3000 LOOP
        v_cust_id := v_min_cust + FLOOR(DBMS_RANDOM.VALUE(0, v_max_cust - v_min_cust + 1));
        v_status := v_statuses(MOD(i, v_statuses.COUNT) + 1);
        v_num_items := FLOOR(DBMS_RANDOM.VALUE(1, 6));
        v_total := 0;

        -- 30% of orders are social-influenced
        IF DBMS_RANDOM.VALUE < 0.3 THEN
            v_social_id := v_min_post + FLOOR(DBMS_RANDOM.VALUE(0, v_max_post - v_min_post + 1));
        ELSE
            v_social_id := NULL;
        END IF;

        -- Assign fulfillment center for non-pending orders
        IF v_status != 'pending' THEN
            v_center_id := v_min_center + FLOOR(DBMS_RANDOM.VALUE(0, v_max_center - v_min_center + 1));
        ELSE
            v_center_id := NULL;
        END IF;

        INSERT INTO orders (
            customer_id, order_status, order_total, shipping_cost,
            fulfillment_center_id, social_source_id, demand_score,
            created_at
        ) VALUES (
            v_cust_id, v_status, 0,
            CASE
                WHEN DBMS_RANDOM.VALUE < 0.3 THEN 0          -- free shipping
                WHEN DBMS_RANDOM.VALUE < 0.7 THEN 7.99
                ELSE 14.99
            END,
            v_center_id,
            v_social_id,
            ROUND(DBMS_RANDOM.VALUE(10, 95), 2),
            SYSTIMESTAMP - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 60) * 24, 'HOUR')
        ) RETURNING order_id INTO v_order_id;

        -- Add line items
        FOR j IN 1..v_num_items LOOP
            v_prod_id := v_min_prod + FLOOR(DBMS_RANDOM.VALUE(0, v_max_prod - v_min_prod + 1));
            v_qty := FLOOR(DBMS_RANDOM.VALUE(1, 4));

            BEGIN
                SELECT unit_price INTO v_price FROM products WHERE product_id = v_prod_id;

                INSERT INTO order_items (order_id, product_id, quantity, unit_price, fulfilled_from)
                VALUES (v_order_id, v_prod_id, v_qty, v_price, v_center_id);

                v_total := v_total + (v_price * v_qty);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN NULL;
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;
        END LOOP;

        -- Update order total
        UPDATE orders SET order_total = v_total WHERE order_id = v_order_id;

        -- Create shipment for shipped/delivered orders
        IF v_status IN ('shipped', 'delivered') AND v_center_id IS NOT NULL THEN
            -- Compute real distance using Oracle Spatial SDO_GEOM.SDO_DISTANCE (great-circle)
            -- For live queries, the backend uses SDO_GCDR.ELOC_ROUTE for actual driving distance/time
            BEGIN
                SELECT ROUND(SDO_GEOM.SDO_DISTANCE(
                           c.location, fc.location, 0.005, 'unit=MILE'
                       ), 2)
                  INTO v_distance
                  FROM customers c, fulfillment_centers fc
                 WHERE c.customer_id = v_cust_id
                   AND fc.center_id = v_center_id;
            EXCEPTION
                WHEN OTHERS THEN v_distance := NULL;
            END;

            -- Estimate transit hours at ~55 mph average
            v_est_hours := CASE WHEN v_distance IS NOT NULL
                                THEN ROUND(v_distance / 55, 1)
                                ELSE NULL END;

            INSERT INTO shipments (
                order_id, center_id, carrier, tracking_number,
                ship_status, distance_km, estimated_hours, ship_cost,
                shipped_at, delivered_at
            ) VALUES (
                v_order_id, v_center_id,
                CASE MOD(i, 4)
                    WHEN 0 THEN 'FedEx'
                    WHEN 1 THEN 'UPS'
                    WHEN 2 THEN 'USPS'
                    ELSE 'DHL'
                END,
                'TRK' || LPAD(v_order_id, 12, '0'),
                CASE v_status WHEN 'delivered' THEN 'delivered' ELSE 'in_transit' END,
                CASE WHEN v_distance IS NOT NULL THEN ROUND(v_distance * 1.60934, 2) ELSE NULL END,
                v_est_hours,
                ROUND(DBMS_RANDOM.VALUE(5, 25), 2),
                SYSTIMESTAMP - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(1, 10) * 24, 'HOUR'),
                CASE v_status
                    WHEN 'delivered' THEN SYSTIMESTAMP - NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 2) * 24, 'HOUR')
                    ELSE NULL
                END
            );
        END IF;

        v_count := v_count + 1;

        IF MOD(v_count, 500) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Orders loaded: ' || v_count);
END;
/
