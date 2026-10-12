SELECT c.component_name, c.category,
       SUM(l.line_total) AS total_material_value,
       SUM(l.quantity) AS planned_units
FROM components c
JOIN production_order_lines l ON l.component_id = c.component_id
JOIN production_orders o ON o.production_order_id = l.production_order_id
WHERE o.order_status IN ('released', 'in_production', 'completed')
GROUP BY c.component_id, c.component_name, c.category
ORDER BY total_material_value DESC
FETCH FIRST 5 ROWS ONLY;
