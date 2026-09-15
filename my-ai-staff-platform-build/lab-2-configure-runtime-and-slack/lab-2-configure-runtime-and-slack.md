# Install the My AI Staff Runtime

## Introduction

In this lab, you configure runtime dependencies, repositories, virtual environments, and local service access. Slack apps, environment files, and systemd activation are covered in Lab 3 so each deployment phase has explicit verification steps.

Estimated Time: 90 minutes

### Objectives

In this lab, you will:

- Install platform dependencies and runtime tools.
- Configure per-agent Python virtual environments.
- Install rclone for required Google Drive delivery.
- Prepare the current agent directories for Slack configuration and service activation.

### Prerequisites

- Completion of Lab 1.
- SSH access to the OCI compute instance.
- Slack admin rights for your target workspace.

## Task 1: Install Runtime Packages and Tooling

1. Connect to your compute instance and update system packages.

    ```
    <copy>
    sudo dnf update -y
    sudo dnf install -y dnf-plugins-core git python3.12 policycoreutils-python-utils
    sudo dnf config-manager --set-enabled ol9_developer_EPEL
    sudo dnf install -y rclone
    sudo dnf install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
    sudo dnf install -y ffmpeg
    ffmpeg -version
    rclone version
    </copy>
    ```

2. Install and authenticate Codex CLI with the account used for this deployment. Core platform agents invoke Codex from the path configured by `CODEX_BIN` or `/home/opc/.local/bin/codex`.

3. Verify the CLI from the instance shell using a non-destructive test.

    ```
    <copy>
    codex exec --skip-git-repo-check "Reply with OK."
    </copy>
    ```

4. Install Claude Code only when you enable the optional AI Staff email, intake, or triage flows. Those components still invoke `claude -p`; it is not required for the core content pipeline.

## Task 2: Clone the Platform and Build Virtual Environments

1. Clone the platform repository into your home directory. Use `~/livelabs-ai-staff`; the service units co-located with the agents use this path.

    ```
    <copy>
    cd ~
    git clone <your-repository-remote> livelabs-ai-staff
    cd ~/livelabs-ai-staff
    mkdir -p posts pending-posts
    git status --short
    </copy>
    ```

2. Install the repository's local Codex skills plugin, then start a new Codex session so the skills list refreshes.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    codex plugin marketplace add .agents/plugins
    codex plugin add livelabsagentic-skills@personal
    </copy>
    ```

3. Build Python 3.9 virtual environments for the current agent directories: `pipeline`, `assistant`, `brand-agent`, `ops`, `publish`, and `website`. Do not follow old build-guide directory names such as `sasha`, `nia`, `amara`, `ida`, or `imani`.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    for agent in pipeline assistant brand-agent ops publish website; do
      python3 -m venv "agents/$agent/venv"
      "agents/$agent/venv/bin/pip" install --upgrade pip
      "agents/$agent/venv/bin/pip" install -r "agents/$agent/requirements.txt"
      "agents/$agent/venv/bin/pip" install -r agents/shared/requirements.txt
      sudo chcon -R -t bin_t "agents/$agent/venv/bin/"
      sudo chcon -h -t bin_t "agents/$agent/venv/bin/python"*
      sudo semanage fcontext -a -t bin_t "/home/opc/livelabs-ai-staff/agents/$agent/venv/bin(/.*)?" || \
        sudo semanage fcontext -m -t bin_t "/home/opc/livelabs-ai-staff/agents/$agent/venv/bin(/.*)?"
    done
    sudo restorecon -Rv ~/livelabs-ai-staff/agents
    </copy>
    ```

4. Create the Data Agent `agents/data/venv` with Python 3.12; its memory dependencies require Python 3.10 or later.

    ```
    <copy>
    cd ~/livelabs-ai-staff
    python3.12 -m venv agents/data/venv
    agents/data/venv/bin/pip install --upgrade pip
    agents/data/venv/bin/pip install -r agents/data/requirements.txt
    sudo chcon -R -t bin_t agents/data/venv/bin/
    sudo chcon -h -t bin_t agents/data/venv/bin/python*
    sudo semanage fcontext -a -t bin_t '/home/opc/livelabs-ai-staff/agents/data/venv/bin(/.*)?' || \
      sudo semanage fcontext -m -t bin_t '/home/opc/livelabs-ai-staff/agents/data/venv/bin(/.*)?'
    sudo restorecon -Rv agents/data/venv
    </copy>
    ```

5. Create and label the File Editor virtual environment. The editor serves local edit links on port 8001.

    ```
    <copy>
    python3 -m venv apps/file-editor/venv
    apps/file-editor/venv/bin/pip install --upgrade pip
    apps/file-editor/venv/bin/pip install -r apps/file-editor/requirements.txt
    apps/file-editor/venv/bin/pip install -r agents/shared/requirements.txt
    sudo chcon -R -t bin_t apps/file-editor/venv/bin/
    sudo chcon -h -t bin_t apps/file-editor/venv/bin/python*
    sudo semanage fcontext -a -t bin_t '/home/opc/livelabs-ai-staff/apps/file-editor/venv/bin(/.*)?' || \
      sudo semanage fcontext -m -t bin_t '/home/opc/livelabs-ai-staff/apps/file-editor/venv/bin(/.*)?'
    sudo restorecon -Rv apps/file-editor/venv
    </copy>
    ```

6. Create the AI Staff virtual environment only when you plan to enable its Gmail, Calendar, email, or public-intake automation. This optional component is not required for the core content workflow.

    ```
    <copy>
    python3 -m venv agents/aistaff/venv
    agents/aistaff/venv/bin/pip install --upgrade pip
    agents/aistaff/venv/bin/pip install -r agents/aistaff/requirements.txt
    agents/aistaff/venv/bin/pip install -r agents/shared/requirements.txt
    sudo chcon -R -t bin_t agents/aistaff/venv/bin/
    sudo chcon -h -t bin_t agents/aistaff/venv/bin/python*
    sudo semanage fcontext -a -t bin_t '/home/opc/livelabs-ai-staff/agents/aistaff/venv/bin(/.*)?' || \
      sudo semanage fcontext -m -t bin_t '/home/opc/livelabs-ai-staff/agents/aistaff/venv/bin(/.*)?'
    sudo restorecon -Rv agents/aistaff/venv
    </copy>
    ```

## Task 3: Prepare for Slack Configuration

1. Confirm the generic role mapping: Assistant Agent/`assistant`, Content Agent and Creative Agent/`pipeline`, Brand Agent/`brand-agent`, Data Agent/`data`, Ops Agent/`ops`, and Publish Agent/`publish`.
2. Keep the Slack bot and app tokens, channel IDs, owner member ID, and Assistant Agent bot ID in a secure deployment worksheet. You will use them in Lab 3.
3. Do not create a Slack app for Website Agent/`website`; it is the HTTP-only intake service on port 8005.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gomez Guerrero
- Last Updated: Cyrce Salinas Rojas, September 2026
