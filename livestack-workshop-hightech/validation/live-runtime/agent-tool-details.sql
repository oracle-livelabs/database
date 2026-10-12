SELECT tool_name, invocation_id, input, output
FROM user_ai_agent_tool_history
ORDER BY start_date DESC
FETCH FIRST 5 ROWS ONLY;
