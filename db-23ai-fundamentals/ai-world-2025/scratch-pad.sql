DECLARE
    TYPE t_product_name IS TABLE OF VARCHAR2(100);
    TYPE t_price IS TABLE OF NUMBER;
    l_product_names t_product_name;
    l_old_prices t_price;
    l_new_prices t_price;
    l_price_differences t_price;
BEGIN
    UPDATE PRODUCTS
    SET PRICE = PRICE * 1.1,
        LAST_UPDATED = SYSDATE
    RETURNING 
        PRODUCT_NAME,
        OLD PRICE,
        NEW PRICE,
        ROUND((NEW PRICE - OLD PRICE), 2)
    BULK COLLECT INTO 
        l_product_names,
        l_old_prices,
        l_new_prices,
        l_price_differences;

    -- Display the results
    FOR i IN 1..l_product_names.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Product: ' || l_product_names(i) ||
            ', Old Price: $' || l_old_prices(i) ||
            ', New Price: $' || l_new_prices(i) ||
            ', Difference: $' || l_price_differences(i)
        );
    END LOOP;
END;
/