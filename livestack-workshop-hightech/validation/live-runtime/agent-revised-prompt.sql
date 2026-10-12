SELECT DBMS_CLOUD_AI_AGENT.RUN_TEAM(
             team_name   => 'NINA_HIGHTECH_TEAM',
             user_prompt => 'Which five components have the highest scheduled material value? Return exactly one row per component, with component name, category, SUM(PRODUCTION_ORDER_LINES.LINE_TOTAL) as total material value and SUM(PRODUCTION_ORDER_LINES.QUANTITY) as planned units. Join COMPONENTS to PRODUCTION_ORDER_LINES using COMPONENT_ID and join PRODUCTION_ORDER_LINES to PRODUCTION_ORDERS using PRODUCTION_ORDER_ID. Filter PRODUCTION_ORDERS.ORDER_STATUS IN (''released'', ''in_production'', ''completed''). Group only by component ID, name and category, order by total material value descending and take five rows. Send this question to the SQL tool in natural language, not as SQL text. Use the returned numeric totals exactly, and include the category in your answer.',
             params      => '{"conversation_id": "' || DBMS_CLOUD_AI.CREATE_CONVERSATION() || '"}'
           ) AS agent_answer;
