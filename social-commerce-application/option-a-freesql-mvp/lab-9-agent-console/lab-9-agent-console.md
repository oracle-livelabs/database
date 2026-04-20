# Lab 7: Agent Console

## Introduction

This lab builds SQL observability views for agent decisions and execution outcomes.

Estimated Time: 8 minutes

### Objectives

In this lab, you will:
- Query agent action history.
- Summarize reliability and confidence by execution status.
- Define one governance signal for production monitoring.

## Task 1: Query Agent Decision History

This task surfaces recent agent actions, outcomes, and confidence scores. It matters because observability starts with a clear audit trail of what was attempted and when.

1. Run this SQL.

    ```
    <copy>
    SELECT agent_name,
           action_type,
           execution_status,
           ROUND(confidence, 3) AS confidence,
           executed_at
    FROM agent_actions
    ORDER BY executed_at DESC
    FETCH FIRST 25 ROWS ONLY;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F2WOMQvCMBSE9%252F6KGxXaRXFy0iRFoTaQVKRTCelTOpgKSUH%252FvZIKtnjjd%252FfeHQBoUQhWwdzIhcaZO6UJfjI2dL1rwusx5%252FQkO0TLBxMGPzOVPJd8YXt37VpyllKsl9hpTMj%252FL2obEyLOlTx994z1PmKpuFDY19M8uNBsPBIVOyA%252FKl1htflMuGjIsqi3SZYJyd5%252FeJx06gAAAA%253D%253D&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Note any failed or review states.

## Task 2: Summarize Operational Risk Signals

Here you aggregate execution patterns to identify reliability drift. This is directly tied to the demo's governance story around production agent operations.

1. Run this SQL.

    ```
    <copy>
SELECT execution_status,
       COUNT(*) AS actions_count,
       ROUND(AVG(confidence), 3) AS avg_confidence,
       MIN(executed_at) AS first_seen,
       MAX(executed_at) AS last_seen
FROM agent_actions
GROUP BY execution_status
ORDER BY actions_count DESC;
    </copy>
    ```

    <iframe
            class="freesql-embed"
            data-freesql-src="https://freesql.com/embedded/?layout=vertical&compressed_code=H4sIAAAAAAAC%252F2XPwQ6CMAwG4Pueosdh8OTRE45JTISZgUZPyzIKITEjccP4%252BIIQiKHH9mvaP%252BdnzgrAD5rON61VzmvfuZDAWExcs4JuAohy0GYQTpm2s34WshcxjW4JNa2tmhKtwSCE3bjyrtXSnnfSU0bHk1gq7X%252B0al7OK4doFxbdV%252BypJ0WOUqSga7ReTZ%252BRpH%252FmAofHKg8RMuZymPyFgJjnbE%252B2Wy7YFysbJuoKAQAA&code_language=SQL&code_format=false"
            height="460px"
            width="100%"
            scrolling="no"
            frameborder="0"
            allowfullscreen="true"
            name="FreeSQL Embedded Playground"
            title="FreeSQL"
            style="width: 100%; border: 1px solid #e0e0e0; border-radius: 12px; overflow: hidden;"
        >FreeSQL Embedded Playground</iframe>

2. Identify which status pattern would trigger your alert threshold.

## Task 3: Check Your Understanding

Use these questions to confirm you can turn logs into actionable monitoring signals. The objective is early risk detection, not just historical reporting.

```quiz
Q: Why capture execution_status alongside confidence?
* Together they reveal whether confident decisions are actually completing successfully.
- Confidence alone replaces status tracking.
- Status alone explains model reasoning quality.
> Correct. Pairing both helps monitor reliability and decision quality.

Q: Which trend is most useful for operational governance?
* Growth in failed and review actions over time
- Number of markdown headings
- Total number of brands
> Correct. Status drift is a practical early-warning signal.
```

## Acknowledgements
* **Author** - Pat Shepherd + Codex
* **Last Updated By/Date** - Codex, April 2026
