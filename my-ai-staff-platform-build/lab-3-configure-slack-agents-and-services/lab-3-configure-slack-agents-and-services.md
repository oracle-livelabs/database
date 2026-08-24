# Configure Slack Agents, Environment Files, and Services

## Introduction

In this lab, you import the role-specific Slack manifests supplied with this workshop, define generic bot names in `.env.shared`, populate deployment-specific environment files, and activate the platform services. Slack permissions do not add channel membership, so you explicitly invite every bot to its working channels.

Estimated Time: 60 minutes

### Objectives

In this lab, you will:

- Create Slack channels and configure seven Socket Mode applications.
- Map the runtime services to generic Assistant, Content, Creative, Brand, Data, Ops, and Publish agents.
- Configure protected shared and per-agent environment files.
- Install current systemd units and enable the platform timers.

### Prerequisites

- Completion of Lab 2.
- Slack workspace administrator access.
- Database connection values, Slack tokens, channel IDs, and deployment owner member ID.

## Task 1: Create Channels and Capture IDs

1. Create `#content-start`, `#content-runs`, `#content-internal`, `#creative-studio`, `#publishing`, `#data`, `#ops`, and `#errors` for the content workflow.

2. Create `#personal` (private), `#ideas`, `#inbox`, and `#briefing` for the Assistant Agent and AI Staff. Create private `#website-inbox` if website intake approvals need a dedicated destination.

3. Copy every channel's `C...` ID from Slack and save it in a secure deployment worksheet. Environment files use IDs, not display names.

## Task 2: Import the Role-Specific Slack Manifests

1. At `api.slack.com/apps`, select **Create New App**, then **From an app manifest**. Select the deployment workspace and paste the matching JSON manifest from the blocks below.

2. Import each manifest once. The manifests use generic display names and contain only the role's required scopes and events.

| Runtime directory | Manifest | Agent name | Required channel membership |
| --- | --- | --- | --- |
| `agents/assistant` | Assistant manifest below | Assistant Agent | `#personal`, `#ideas`, `#content-start`, `#publishing`, `#errors`, `#inbox`, `#briefing`, and direct messages |
| `agents/pipeline` | Content manifest below | Content Agent | `#content-start`, `#content-runs`, `#content-internal`, `#publishing`, `#errors` |
| `agents/pipeline` | Creative manifest below | Creative Agent | `#creative-studio`, `#content-runs`, `#content-internal`, `#errors` |
| `agents/brand-agent` | Brand manifest below | Brand Agent | `#content-runs`, `#errors`, and direct messages |
| `agents/data` | Data manifest below | Data Agent | `#data`, `#errors` |
| `agents/ops` | Ops manifest below | Ops Agent | `#ops`, `#errors` |
| `agents/publish` | Publish manifest below | Publish Agent | `#publishing`, `#content-runs`, `#errors` |

3. Assistant Agent and Brand Agent are the two apps that need Direct Message access. Their manifests include `im:history`, `im:read`, `im:write`, and the `message.im` event. After importing those two manifests, verify that direct messages are enabled for each app in Slack before installing it.

4. Paste this Assistant Agent manifest.

    ```json
    <copy>
    {
      "display_information": {
        "name": "Assistant Agent",
        "description": "Personal assistant and AI Staff coordinator."
      },
      "features": {
        "bot_user": {
          "display_name": "Assistant Agent",
          "always_online": true
        }
      },
      "oauth_config": {
        "scopes": {
          "bot": [
            "chat:write",
            "channels:history",
            "channels:read",
            "groups:history",
            "groups:read",
            "im:history",
            "im:read",
            "im:write",
            "files:read",
            "files:write",
            "reactions:read"
          ]
        },
        "pkce_enabled": false
      },
      "settings": {
        "event_subscriptions": {
          "bot_events": [
            "message.channels",
            "message.groups",
            "message.im",
            "reaction_added"
          ]
        },
        "interactivity": {
          "is_enabled": false
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false,
        "is_mcp_enabled": false
      }
    }
    </copy>
    ```

5. Paste this Content Agent manifest.

    ```json
    <copy>
    {
      "display_information": {
        "name": "Content Agent",
        "description": "Starts and coordinates content runs."
      },
      "features": {
        "bot_user": {
          "display_name": "Content Agent",
          "always_online": true
        }
      },
      "oauth_config": {
        "scopes": {
          "bot": [
            "chat:write",
            "channels:history",
            "channels:read"
          ]
        },
        "pkce_enabled": false
      },
      "settings": {
        "event_subscriptions": {
          "bot_events": [
            "message.channels"
          ]
        },
        "interactivity": {
          "is_enabled": false
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false,
        "is_mcp_enabled": false
      }
    }
    </copy>
    ```

6. Paste this Creative Agent manifest.

    ```json
    <copy>
    {
      "display_information": {
        "name": "Creative Agent",
        "description": "Handles creative work and asset uploads."
      },
      "features": {
        "bot_user": {
          "display_name": "Creative Agent",
          "always_online": true
        }
      },
      "oauth_config": {
        "scopes": {
          "bot": [
            "chat:write",
            "channels:history",
            "channels:read",
            "files:write"
          ]
        },
        "pkce_enabled": false
      },
      "settings": {
        "event_subscriptions": {
          "bot_events": [
            "message.channels"
          ]
        },
        "interactivity": {
          "is_enabled": false
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false,
        "is_mcp_enabled": false
      }
    }
    </copy>
    ```

7. Paste this Brand Agent manifest.

    ```json
    <copy>
    {
      "display_information": {
        "name": "Brand Agent",
        "description": "Reviews content against the brand standard."
      },
      "features": {
        "bot_user": {
          "display_name": "Brand Agent",
          "always_online": true
        }
      },
      "oauth_config": {
        "scopes": {
          "bot": [
            "chat:write",
            "channels:history",
            "channels:read",
            "im:history",
            "im:read",
            "im:write"
          ]
        },
        "pkce_enabled": false
      },
      "settings": {
        "event_subscriptions": {
          "bot_events": [
            "message.channels",
            "message.im"
          ]
        },
        "interactivity": {
          "is_enabled": false
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false,
        "is_mcp_enabled": false
      }
    }
    </copy>
    ```

8. Paste this Data Agent manifest.

    ```json
    <copy>
    {
      "display_information": {
        "name": "Data Agent",
        "description": "Provides data and database operations."
      },
      "features": {
        "bot_user": {
          "display_name": "Data Agent",
          "always_online": true
        }
      },
      "oauth_config": {
        "scopes": {
          "bot": [
            "chat:write",
            "channels:history",
            "channels:read"
          ]
        },
        "pkce_enabled": false
      },
      "settings": {
        "event_subscriptions": {
          "bot_events": [
            "message.channels"
          ]
        },
        "interactivity": {
          "is_enabled": false
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false,
        "is_mcp_enabled": false
      }
    }
    </copy>
    ```

9. Paste this Ops Agent manifest.

    ```json
    <copy>
    {
      "display_information": {
        "name": "Ops Agent",
        "description": "Reports and operates platform services."
      },
      "features": {
        "bot_user": {
          "display_name": "Ops Agent",
          "always_online": true
        }
      },
      "oauth_config": {
        "scopes": {
          "bot": [
            "chat:write",
            "channels:history",
            "channels:read"
          ]
        },
        "pkce_enabled": false
      },
      "settings": {
        "event_subscriptions": {
          "bot_events": [
            "message.channels"
          ]
        },
        "interactivity": {
          "is_enabled": false
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false,
        "is_mcp_enabled": false
      }
    }
    </copy>
    ```

10. Paste this Publish Agent manifest.

    ```json
    <copy>
    {
      "display_information": {
        "name": "Publish Agent",
        "description": "Publishes approved work and uploads deliverables."
      },
      "features": {
        "bot_user": {
          "display_name": "Publish Agent",
          "always_online": true
        }
      },
      "oauth_config": {
        "scopes": {
          "bot": [
            "chat:write",
            "channels:history",
            "channels:read",
            "files:write"
          ]
        },
        "pkce_enabled": false
      },
      "settings": {
        "event_subscriptions": {
          "bot_events": [
            "message.channels"
          ]
        },
        "interactivity": {
          "is_enabled": false
        },
        "org_deploy_enabled": false,
        "socket_mode_enabled": true,
        "token_rotation_enabled": false,
        "is_mcp_enabled": false
      }
    }
    </copy>
    ```

11. Do not create a Slack app for Website Agent. The `agents/website` service exposes a local HTTP API on port 8005.

12. For each app, create an app-level token with `connections:write`, install or reinstall it, and record its `xoxb-...` bot token and `xapp-...` app token. Socket Mode needs both tokens.

13. Invite each bot to all listed channels. A manifest grants scopes but does not grant membership; without membership, Slack does not deliver channel messages and file upload can fail with `not_in_channel`.

14. In your shell, export the Assistant Agent bot token temporarily, then obtain its bot ID and record it as `ASSISTANT_BOT_ID`. It is the only bot allowlisted to issue specialist-agent commands.

    ```
    <copy>
    export ASSISTANT_BOT_TOKEN='xoxb-<assistant-agent-token>'
    curl -s -H "Authorization: Bearer $ASSISTANT_BOT_TOKEN" \
      https://slack.com/api/auth.test | python3 -m json.tool
    unset ASSISTANT_BOT_TOKEN
    </copy>
    ```

15. Record the deployment owner's member ID as `SLACK_ASSISTANT_USER_ID`; the Assistant Agent uses it for reminders and privileged routing.

## Task 3: Configure and Protect Environment Files

1. Create environment files from the current templates. Do not commit the result or display secrets in evidence.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    cp .env.shared.template .env.shared
    for agent in pipeline assistant brand-agent data ops publish aistaff; do
      cp "agents/$agent/.env.example" "agents/$agent/.env"
    done
    </copy>
    ```

2. Populate `.env.shared` with `ADB_DSN`, `ADB_USER`, `ADB_PASSWORD`, `ADB_WALLET_DIR`, `ASSISTANT_BOT_ID`, and `OPENAI_API_KEY`. The OpenAI key is required by the core visual-generation preflight. Add SMTP and AI Staff channel values only when those optional integrations are enabled.

3. Define all generic display names in `.env.shared`. This is required because the current runtime loads `.env.shared` first, then loads each agent-specific `.env`; do not set competing `*_BOT_NAME` values in the per-agent files.

    ```
    <copy>
    ASSISTANT_BOT_NAME="Assistant Agent"
    CONTENT_BOT_NAME="Content Agent"
    CREATIVE_BOT_NAME="Creative Agent"
    BRAND_BOT_NAME="Brand Agent"
    DATA_BOT_NAME="Data Agent"
    OPS_BOT_NAME="Ops Agent"
    PUBLISH_BOT_NAME="Publish Agent"
    WEBSITE_BOT_NAME="Website Agent"
    </copy>
    ```

4. Use the current token names for a new deployment: `ASSISTANT_*`, `CONTENT_*`, `CREATIVE_*`, `BRAND_*`, `DATA_*`, `OPS_*`, and `PUBLISH_*`. The pipeline accepts legacy `ZORA_*` and `ZURI_*` keys, but they are not required for a new configuration.

5. Set the same channel ID wherever it is shared. For example, `SLACK_PUBLISHING_CHANNEL` is used by pipeline, assistant, and publish.

6. Restrict access and label every environment file for SELinux.

    ```
    <copy>
    chmod 600 .env.shared agents/*/.env
    sudo chcon -t etc_t .env.shared agents/*/.env
    sudo semanage fcontext -a -t etc_t '/home/opc/livelabs-ai-staff/\.env\.shared' || \
      sudo semanage fcontext -m -t etc_t '/home/opc/livelabs-ai-staff/\.env\.shared'
    sudo semanage fcontext -a -t etc_t '/home/opc/livelabs-ai-staff/agents/[^/]+/\.env' || \
      sudo semanage fcontext -m -t etc_t '/home/opc/livelabs-ai-staff/agents/[^/]+/\.env'
    sudo restorecon -Rv ~/livelabs-ai-staff
    </copy>
    ```

## Task 4: Install Services and Timers

1. Use the unit files stored alongside each runtime component. They are the canonical units for this workshop because they reference the `.env.shared` and per-agent `.env` files created in Task 3. Do not bulk-copy `deploy/systemd/*.service`: that directory contains deployment-specific and legacy paths.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    rg -n 'WorkingDirectory|EnvironmentFile|ExecStart' \
      agents/{assistant,pipeline,brand-agent,data,ops,publish,website}/contentkit-*.service \
      apps/file-editor/contentkit-file-editor.service
    </copy>
    ```

2. Create the File Editor environment file required by its unit, then install the required core units. This command deliberately omits Website Agent and AI Staff intake automation; configure those optional capabilities only when their required credentials and integrations are ready.

    ```
    <copy>
    sudo install -d -m 700 /etc/sysconfig
    sudo tee /etc/sysconfig/contentkit-file-editor > /dev/null <<'EOF'
    EDITOR_DOMAIN=editor.<your-domain>
    EOF
    sudo chmod 600 /etc/sysconfig/contentkit-file-editor
    sudo cp agents/pipeline/contentkit-pipeline.service \
      agents/assistant/contentkit-assistant.service \
      agents/assistant/contentkit-assistant-reminder.service \
      agents/assistant/contentkit-assistant-reminder.timer \
      agents/brand-agent/contentkit-brand.service \
      agents/data/contentkit-data.service \
      agents/ops/contentkit-ops.service \
      agents/publish/contentkit-publish.service \
      apps/file-editor/contentkit-file-editor.service \
      /etc/systemd/system/
    sudo systemctl daemon-reload
    for unit in contentkit-data contentkit-brand contentkit-ops contentkit-publish \
                contentkit-assistant contentkit-pipeline contentkit-file-editor; do
      sudo systemctl enable --now "$unit"
      systemctl is-active "$unit"
    done
    sudo systemctl enable --now contentkit-assistant-reminder.timer
    systemctl list-timers 'contentkit-*'
    </copy>
    ```

3. Enable Website Agent only when you expose the public intake surface. It depends on Data Agent and requires its own venv from Lab 2.

    ```
    <copy>
    sudo cp agents/website/contentkit-website.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable --now contentkit-website
    systemctl is-active contentkit-website
    </copy>
    ```

4. Enable AI Staff intake automation only after its Gmail, Calendar, and intake configuration is complete.

    ```
    <copy>
    sudo cp agents/aistaff/aistaff-intake-watch.service \
      agents/aistaff/aistaff-intake-watch.timer /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable --now aistaff-intake-watch.timer
    systemctl list-timers 'aistaff-*'
    </copy>
    ```

5. If a unit reports `Failed to load environment files`, restore the `etc_t` label. If it reports `203/EXEC`, restore the `bin_t` label on the virtual environment and use `chcon -h` for the `python*` symlink.

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
