# Screenshot Censoring Review

Review these items before publishing Lab 6. This file is for workshop authors and is not included in either workshop manifest.

Estimated Time: 5 minutes

## Required Censoring

### `10-assistant-agent-calendar-approval.png`

Censor all visible instances of:

- The invitee email address.
- The complete Zoom meeting URL, including its `pwd` query parameter.
- The opaque `calendar-details` and `calendar-event` identifiers.

The event title, date, duration, approval controls, and generic calendar confirmation can remain visible.

## Recommended Review

### `01-content-runs-research-pause.png`, `06-assistant-agent-routes-content-url.png`, and `07-content-start-routed-url.png`

The screenshots expose an exact LiveLabs workshop URL and query parameters. These values are not credentials, but mask the workshop identifier and query string if they point to a private or temporary workshop.

### `02-content-agent-markdown-drive-approval.png`

The artifact previews show the deployment path under `/home/opc/livelabs-ai-staff`. This path is not a credential, but mask it if the host filesystem layout should remain private.

### `09-ideas-channel.png`

The first idea includes a specific workshop reference number. Mask that number if it maps to an internal request or unpublished workshop.

## Excluded Asset

The source file captured at 1:38:50 p.m. is a blank 1 x 1 pixel image. Lab 6 excludes it, and the images folder no longer contains it.

No other screenshot in this lab visibly contains a credential, personal email address, or secret value. Recheck the captures after any replacement or recapture.

## Acknowledgements

- Review owner: Workshop author
