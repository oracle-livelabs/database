SELECT prompt_response AS agent_answer
FROM user_cloud_ai_conversation_prompts
WHERE conversation_id IN (
  SELECT conversation_id FROM user_ai_agent_team_history
  WHERE team_name = 'NINA_HIGHTECH_TEAM'
)
ORDER BY created
FETCH FIRST 1 ROW ONLY;
