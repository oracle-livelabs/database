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
- A personal Gmail account and a personal Slack account/workspace for this workshop. Do not use a corporate or customer-owned account for workshop identities or OAuth consent.
- Slack admin rights for your personal target workspace.

## Task 1: Install Runtime Packages and Tooling

1. Connect to the OCI compute instance from your laptop. Use either method:
    - **VS Code:** Open the Command Palette, select **Remote-SSH: Connect to Host**, choose `my-ai-staff-oci`, and open a new terminal with **Terminal > New Terminal**. The commands below must run in that remote terminal.
    - **Laptop terminal:** Run `ssh my-ai-staff-oci` from a local terminal. After the prompt changes to the remote `opc` shell, run the commands below. The `my-ai-staff-oci` alias and key are configured in Lab 1 Task 1.

    Once connected, update system packages:

    ```
    <copy>
    sudo dnf update -y
    sudo dnf install -y dnf-plugins-core git curl unzip python3.12 policycoreutils-python-utils
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

## Task 2: Download the Platform ZIP, Install Its Codex Plugin, and Build Virtual Environments

1. Download the supplied platform ZIP and extract it into your home directory. The archive already contains the complete `livelabs-ai-staff/` directory; it is not a Git repository, so do not run `git clone` or expect a repository remote. Use `~/livelabs-ai-staff`; the service units co-located with the agents use this path.

    ```
    <copy>
    cd ~
    curl -fL --retry 3 'https://c4u02.objectstorage.us-ashburn-1.oci.customer-oci.com/p/9DEArLjsgbKXuJgQtSG95E8hMXRFtxgHR8jiHbqz4HgyVYXVnSo0SC_s-zq5CJA3/n/c4u02/b/hosted-files/o/livelabs-ai-staff.zip' -o /tmp/livelabs-ai-staff.zip
    test ! -e ~/livelabs-ai-staff || { echo 'Remove or rename the existing ~/livelabs-ai-staff directory before continuing.'; exit 1; }
    unzip -q /tmp/livelabs-ai-staff.zip -d ~
    cd ~/livelabs-ai-staff
    mkdir -p posts pending-posts
    test -f schema/ai_for_you_full_ddl.sql
    test -f .agents/plugins/marketplace.json
    find . -maxdepth 1 -type d -print | sort
    </copy>
    ```

2. Install the ZIP's included local Codex skills plugin from the repository root, then start a new Codex session so the skills list refreshes. The marketplace file registers the plugin as `livelabsagentic-skills@personal`. After extraction and plugin installation, return to Lab 1 Task 3 step 4 to run the application DDL before continuing with the runtime setup.

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
2. Lab 3 creates the apps at [Slack API: Your Apps](https://api.slack.com/apps). Keep the Slack bot and app tokens, channel IDs, owner member ID, and Assistant Agent bot ID in a secure deployment worksheet. Use the personal Slack workspace from the prerequisites.
3. Do not create a Slack app for Website Agent/`website`; it is the HTTP-only intake service on port 8005.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gomez Guerrero
- Last Updated: Cyrce Salinas Rojas, September 2026
