# Lab 6: Explore Slack Agent Features

## Introduction

AI Staff uses Slack direct messages, shared channels, and threads for different kinds of work. Direct messages give you a personal control surface. Channels make team activity visible. Threads keep each request, approval, and delivery action attached to the correct job.

This lab documents the features shown in the current Slack examples. You will review each featured agent and its approval controls. You will also inspect `#content-start`, `#ideas`, and `#inbox`.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:

- Review the Assistant Agent command groups and cross-agent routing.
- Review Brand Agent commands, strategy setup, briefs, grading, and detailed feedback.
- Follow Content Agent research, artifact approval, Drive delivery, and Publish Agent handoff.
- Review Creative Agent image revision and approval controls.
- Understand the purpose of the featured Slack channels.

### Prerequisites

- Finish Lab 5.
- Access to the Slack workspace configured in Lab 3.
- AI Staff services running and the featured Slack apps installed.
- Gmail, Calendar, Drive, and publishing features configured in Lab 4 if you want to reproduce those examples.

## Task 1: Assistant Agent

1. Open a direct message with **Assistant Agent** and enter *what can you do?* to display the command guide.

    ![Assistant Agent command guide in a Slack direct message](./images/04-assistant-agent-command-guide.png "Assistant Agent command guide in a Slack direct message")

    The guide groups the available work into four areas:

    - **Status and pipeline:** Check platform health, locate a post, list work in flight, identify runs waiting for you, inspect a post record, or diagnose a stalled run. When the Assistant proposes a restart, you confirm it before the restart runs.
    - **Content:** Submit a source URL, start a content run, request a LinkedIn draft, grade text, send approved work to Publish, upload a post to Drive, or ask Creative Agent to regenerate an infographic or stories package.
    - **Your day:** Create an approved calendar event, check or sort email, request a calendar and inbox brief, review weekly metrics, log a receipt, import a CSV file, list event signups, or prepare an outbound email for approval.
    - **Reminders, ideas, and personal context:** Create and list reminders, review saved ideas, upload a resume, compare it with a job role, or ask a career or personal request based on approved documents.

    The Assistant also sends proactive briefings and due reminders when you enable those automations. Available commands depend on the external services configured for your system.

2. Use the Assistant to check the platform and inspect current work.

    ![Assistant Agent status, post lookup, and waiting-work responses](./images/05-assistant-agent-status-and-post-lookup.png "Assistant Agent status, post lookup, and waiting-work responses")

    In this example, *status* confirms that the agents and database are available. *where is post 1002* returns the post state and links to its run thread. *what is waiting for me* reports whether a workflow waits at an approval pause.

3. Paste a Topic or a Supported Link into the Assistant DM to start a content request.

    ![Assistant Agent routes a submitted URL to Content Agent](./images/06-assistant-agent-routes-content-url.png "Assistant Agent routes a submitted URL to Content Agent")

    The Assistant acknowledges the request, forwards the URL to Content Agent, and names the target channel. Continue the content run in the linked `#content-start` thread so its updates remain together.

4. Ask the Assistant to schedule an event in a direct message.

    ![Assistant Agent collects calendar details and waits for event approval](./images/10-assistant-agent-calendar-approval.png "Assistant Agent collects calendar details and waits for event approval")

    The Assistant collects the event purpose, invitees, place, and meeting-link choice. It then posts an event preview. React with the green check mark to create the event or the red cross to reject it. The preview expires after the displayed approval window.

5. Create a reminder with a natural-language date or time.

    ![Assistant Agent confirms a scheduled reminder](./images/11-assistant-agent-reminder.png "Assistant Agent confirms a scheduled reminder")

    The reply repeats the reminder text and the delivery time in the configured time zone. The reminder service sends the reminder when it becomes due.

    ![Assistant Agent sends the reminder at its scheduled time](./images/11b-assistant-agent-reminder-delivered.png "Assistant Agent sends the reminder at its scheduled time")

    The delivered message repeats the due time and reminder text. This follow-up confirms that the reminder service completed the request instead of only storing it.

6. Ask the Assistant to check your email.

    ![Assistant Agent starts email triage and posts the result to inbox](./images/12-assistant-agent-email-triage.png "Assistant Agent starts email triage and posts the result to inbox")

    The direct message stays concise. It reports that the inbox check started, then points you to `#inbox` for the shared result.

## Task 2: Brand Agent and your Personal Strategy

1. Open a direct message with **Brand Agent** and enter *what can you do?*.

    ![Brand Agent command guide in a Slack direct message](./images/14-brand-agent-command-guide.png "Brand Agent command guide in a Slack direct message")

    The command guide groups the available work into four areas:

    - **Grading:** Grade every generated format for a post, or select LinkedIn, newsletter, short videos, research, or slides. Enter *detail* after a grade run to see the flagged lines.
    - **Briefs:** Enter *brief for &lt;post-number&gt;* to create a brief from the post and active strategy.
    - **Strategy:** Enter *strategy status* to review the active profile. Enter *setup strategy* for a threaded interview, or use *setup strategy: &lt;field block&gt;* when you already have structured profile details.
    - **Quick checks:** Enter *does this sound like me?* followed by text to compare a draft with the active brand voice.

2. Enter *setup strategy* and complete the threaded interview.

    ![Brand Agent strategy review, approval, and generated profile files](./images/15-brand-agent-strategy-created.png "Brand Agent strategy review, approval, and generated profile files")

    The interview collects your role, main goal, topics, tone, content formats, and optional secondary goals. Brand Agent summarizes the answers before it writes anything. React with the green check mark to create the strategy or the red cross to cancel.

    After approval, Brand Agent creates the brand guide, general strategy, funnel strategy, and content-plan files. It also updates the active profile. Enter *strategy status* to review the saved summary before you grade or brief a post.

3. Enter *brief &lt;post-number&gt;* to generate a brief. This command can also be sent in `#briefing`.

    ![Brand Agent brief with selected formats and publishing goal](./images/16-brand-agent-brief.png "Brand Agent brief with selected formats and publishing goal")

    The production brief turns the post topic and active strategy into a shared guide for downstream agents. It identifies the selected formats and records a publishing goal for each deliverable. Review the brief before drafting when the team needs to agree on the topic, readers, or message.

4. Grade one format or every generated format for a post.

    ![Brand Agent grade summary and detailed diagnostic feedback](./images/17-brand-agent-grading-detail.png "Brand Agent grade summary and detailed diagnostic feedback")

    Enter a command such as *grade 1002 newsletter*. Brand Agent evaluates the artifact against the active profile and reports the original and improved grades. Enter *detail newsletter*, or *detail*, to inspect test results, flagged lines, missing support, and the reason for each finding.

    Read the detail response before assuming that automatic edits reached the source file. In this example, the workspace denied write access. Brand Agent completed the review, but it could not change the source or create the `.grade` sidecar. Correct the file permissions, rerun the grade, and confirm that the output no longer reports a write failure.

## Task 3: Content Runs (#content_starts and #content_runs)

1. Open `#content-runs`, select a post, and open its thread.

    ![Content Agent research phase and first review pause in content-runs](./images/01-content-runs-research-pause.png "Content Agent research phase and first review pause in content-runs")

    Content Agent posts each pipeline as a top-level message in `#content-runs`. The thread holds every update for that post. In this example, the agent reports the research phase as running, marks it complete, and stops at **PAUSE 1**. The research brief appears in the same thread so you can review its topic, source support, opportunities, and trade-offs before formats begin.

2. Review the generated Markdown artifacts and approve their Drive delivery.

    ![Content Agent artifact previews and Markdown Drive approval](./images/02-content-agent-markdown-drive-approval.png "Content Agent artifact previews and Markdown Drive approval")

    Here, the user replies *skip* at **PAUSE 3**, and Content Agent resumes the post. It displays the research brief, LinkedIn post, and newsletter with their artifact filenames and previews.

    The **Markdown Drive approval** message lists every file awaiting delivery. React with the green check mark to approve all listed Markdown artifacts for Drive. Keep the approval in the post thread so it applies to the correct files.

3. Confirm the Drive upload and Publish Agent handoff.

    ![Content Agent completes Drive delivery and Publish Agent confirms the handoff](./images/03-content-agent-drive-delivery.png "Content Agent completes Drive delivery and Publish Agent confirms the handoff")

    After approval, Content Agent records the decision, verifies the files, and uploads each artifact. The final message links to the delivered LinkedIn, newsletter, and research files. Publish Agent then confirms that it received the approved brief and uploaded it to Drive. These messages close the approval trail for the post.

## Task 4: Creative Agent and #creative_studio

1. Send an image request to Creative Agent in the `#creative-studio` channel.

    ![Creative Agent image draft, edit, and approval flow](./images/08-creative-agent-image-approval.png "Creative Agent image draft, edit, and approval flow")

    Creative Agent posts a candidate with a version number and asks for one of two responses:

    - Reply *approve* to accept the displayed revision.
    - Reply *revise: &lt;changes&gt;* to generate another candidate from your feedback.

2. Review the new candidate after requesting a change, then approve the correct version.

    The approval message identifies the accepted image and version. Only the approved PNG becomes eligible for later delivery. This gate prevents an older draft from moving forward by mistake.

## Task 5: Other Channels

1. Use `#ideas` as a shared capture queue for future work.

    ![Ideas channel with workshop, reading, and exam ideas](./images/09-ideas-channel.png "Ideas channel with workshop, reading, and exam ideas")

    Post a short idea, a link, or a goal as a top-level message. Assistant Agent records the item and replies in its thread. Separate threads keep follow-up details attached to each idea without turning the channel into one long chat.
    Afterward, send *whats on my idea list* to the Assistant Agent. It displays a similar list.

    ![Ideas List from the Assistant](./images/18-idea-list.png)

2. Review `#inbox` after an email check or inbox sweep.

    ![Inbox channel triage summary from Assistant Agent](./images/13-inbox-triage-summary.png "Inbox channel triage summary from Assistant Agent")

    The summary shows new-message counts, categories, suggested work, internal labels, drafts awaiting approval, and any immediate need. The channel holds shared results, while commands and approvals can remain in the Assistant DM.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gómez Guerrero
- Last Updated: Ilan Gómez Guerrero, October 2026
