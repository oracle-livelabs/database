# Configure the AI Staff Runtime and Slack

## Introduction

In this lab, you configure runtime dependencies, repositories, virtual environments, secure endpoint access, and Slack integrations. You then prepare environment files and enable platform services with systemd.

Estimated Time: 90 minutes

### Objectives

In this lab, you will:

- Install platform dependencies and runtime tools.
- Configure per-agent Python virtual environments.
- Configure nginx with HTTPS for the file editor endpoint.
- Create Slack workspace channels and app integrations.
- Configure environment files and enable services with systemd.

### Prerequisites

- Completion of Lab 1.
- SSH access to the OCI compute instance.
- Slack admin rights for your target workspace.

## Task 1: Install Runtime Packages and Tooling

1. Connect to your compute instance and update system packages.

    ```
    <copy>
    sudo dnf update -y
    sudo dnf install -y git python3.12 ffmpeg nginx policycoreutils-python-utils
    sudo dnf config-manager --set-enabled ol9_developer_EPEL
    sudo dnf install -y certbot python3-certbot-nginx
    </copy>
    ```

2. Install and authenticate Codex CLI with the account used for this deployment.
3. Verify the CLI from the instance shell.

## Task 2: Clone the Platform and Build Virtual Environments

1. Clone the platform repository into your home directory.
2. Create required directories such as posts and pending-posts.
3. Build per-agent virtual environments based on the project build guide.
4. Apply SELinux labels to each virtual environment binary path after setup.

    ```
    <copy>
    sudo chcon -R -t bin_t agents/<agent>/venv/bin/
    sudo chcon -h -t bin_t agents/<agent>/venv/bin/python*
    </copy>
    ```

5. Install NotebookLM runtime dependencies in a Python 3.12 environment.

## Task 3: Configure HTTPS for the Editor Endpoint

1. Enable and start nginx.
2. Enable SELinux HTTP network connectivity for reverse proxy behavior.

    ```
    <copy>
    sudo systemctl enable --now nginx
    sudo setsebool -P httpd_can_network_connect 1
    </copy>
    ```

3. Configure the editor virtual host to proxy to localhost:8001.
4. Validate nginx configuration.

    ```
    <copy>
    sudo nginx -t
    sudo systemctl reload nginx
    </copy>
    ```

5. Request and install TLS certificates with certbot for editor.<your-domain>.

## Task 4: Configure Slack Workspace, Channels, and Apps

1. Create the workspace channels required by the platform workflow.
2. Create Slack apps from the supplied manifests for each Slack-integrated agent.
3. Install each app into the workspace and capture bot tokens and app-level tokens.
4. Invite bots to channels according to the role mapping.
5. Capture and store channel IDs, owner user ID, and assistant bot ID values.

## Task 5: Configure Environment Files and Systemd Services

1. Populate shared and per-agent environment files with tenancy-specific values.
2. Restrict permissions and set SELinux context for all env files.

    ```
    <copy>
    chmod 600 .env.shared agents/*/.env
    sudo chcon -t etc_t .env.shared agents/*/.env
    </copy>
    ```

3. Configure Content Kit settings, including base directories and service endpoints.
4. Copy unit files to /etc/systemd/system and run daemon-reload.
5. Enable and start all required services and timers.
6. Confirm all service units are active.

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
