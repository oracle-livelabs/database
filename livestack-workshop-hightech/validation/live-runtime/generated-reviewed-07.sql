SELECT 
    c.COMPONENT_NAME AS "Component Name",
    c.CATEGORY AS "Category",
    SUM(pol.LINE_TOTAL) AS "Summed Line Total",
    SUM(pol.QUANTITY) AS "Summed Quantity"
FROM 
    "LLUSER"."COMPONENTS" c
JOIN 
    "LLUSER"."PRODUCTION_ORDER_LINES" pol ON c.COMPONENT_ID = pol.COMPONENT_ID
JOIN 
    "LLUSER"."PRODUCTION_ORDERS" po ON pol.PRODUCTION_ORDER_ID = po.PRODUCTION_ORDER_ID
WHERE 
    po.ORDER_STATUS IN ('released', 'in_production', 'completed')
GROUP BY 
    c.COMPONENT_NAME, 
    c.CATEGORY
ORDER BY 
    "Summed Line Total" DESC
FETCH FIRST 5 ROWS ONLY;
