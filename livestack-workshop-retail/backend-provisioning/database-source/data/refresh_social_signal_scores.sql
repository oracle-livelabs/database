/*
 * refresh_social_signal_scores.sql
 * Recomputes SOCIAL_POSTS.VIRALITY_SCORE from engagement and momentum signals.
 *
 * Run after social posts are loaded or restored, and before OML models are built.
 */

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT Refreshing social virality scores...

DECLARE
  v_updated_rows NUMBER;
  v_total_posts  NUMBER;
  v_scored_posts NUMBER;
  v_avg_score    NUMBER;
BEGIN
  UPDATE social_posts
  SET virality_score = ROUND(
    LEAST(
      100,
      LEAST(GREATEST(NVL(likes_count, 0), 0) / 500, 45) +
      LEAST(GREATEST(NVL(shares_count, 0), 0) / 250, 25) +
      LEAST(GREATEST(NVL(comments_count, 0), 0) / 200, 15) +
      LEAST(GREATEST(NVL(views_count, 0), 0) / 200000, 10) +
      CASE NVL(momentum_flag, 'normal')
        WHEN 'mega_viral' THEN 30
        WHEN 'viral' THEN 20
        WHEN 'rising' THEN 10
        ELSE 0
      END
    ),
    2
  );

  v_updated_rows := SQL%ROWCOUNT;

  SELECT COUNT(*),
         COUNT(virality_score),
         ROUND(AVG(virality_score), 2)
  INTO v_total_posts,
       v_scored_posts,
       v_avg_score
  FROM social_posts;

  DBMS_OUTPUT.PUT_LINE(
    'Social virality scores refreshed: ' ||
    v_updated_rows || ' rows updated, ' ||
    v_scored_posts || '/' || v_total_posts ||
    ' scored, average score ' || NVL(TO_CHAR(v_avg_score), 'n/a') || '.'
  );
END;
/

COMMIT;
