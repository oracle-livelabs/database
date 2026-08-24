# Install the My AI Staff Runtime

## Introduction

In this lab, you configure runtime dependencies, repositories, virtual environments, and secure endpoint access. Slack apps, environment files, and systemd activation are covered in Lab 3 so each deployment phase has explicit verification steps.

Estimated Time: 90 minutes

### Objectives

In this lab, you will:

- Install platform dependencies and runtime tools.
- Configure per-agent Python virtual environments.
- Configure nginx with HTTPS for the file editor endpoint.
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
    sudo dnf install -y dnf-plugins-core git python3.12 nginx policycoreutils-python-utils
    sudo dnf config-manager --set-enabled ol9_developer_EPEL
    sudo dnf install -y certbot python3-certbot-nginx
    sudo dnf install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
    sudo dnf install -y ffmpeg
    ffmpeg -version
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

5. Create and label the File Editor virtual environment. The editor must exist before nginx can proxy to port 8001.

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

## Task 3: Configure HTTPS for the Editor Endpoint

1. Enable and start nginx.
2. Enable SELinux HTTP network connectivity for reverse proxy behavior.

    ```
    <copy>
    sudo systemctl enable --now nginx
    sudo setsebool -P httpd_can_network_connect 1
    </copy>
    ```

3. Create an HTTP-only editor virtual host. Replace both domain placeholders before you run the command.

    ```
    <copy>
    sudo tee /etc/nginx/conf.d/editor.<your-domain>.conf > /dev/null <<'EOF'
    server {
        listen 80;
        server_name editor.<your-domain>;
        location / {
            proxy_pass http://127.0.0.1:8001;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 60s;
        }
    }
    EOF
    sudo nginx -t
    sudo systemctl reload nginx
    </copy>
    ```

4. Do not request TLS yet. You will request and test the certificate once, in Task 5, after you confirm the DNS record resolves to this instance.

## Task 4: Prepare for Slack Configuration

1. Confirm the generic role mapping: Assistant Agent/`assistant`, Content Agent and Creative Agent/`pipeline`, Brand Agent/`brand-agent`, Data Agent/`data`, Ops Agent/`ops`, and Publish Agent/`publish`.
2. Keep the Slack bot and app tokens, channel IDs, owner member ID, and Assistant Agent bot ID in a secure deployment worksheet. You will use them in Lab 3.
3. Do not create a Slack app for Website Agent/`website`; it is the HTTP-only intake service on port 8005.

## Task 5: Request and Verify TLS

1. Confirm the editor virtual host proxies only to `127.0.0.1:8001` and that nginx validates before requesting TLS.

    ```
    <copy>
    sudo nginx -t
    sudo systemctl reload nginx
    </copy>
    ```

2. Request the certificate after DNS resolves to the instance, then test renewal.

    ```
    <copy>
    sudo certbot --nginx -d editor.<your-domain> --agree-tos --redirect -m <your-email>
    sudo systemctl enable --now certbot-renew.timer
    sudo certbot renew --dry-run
    </copy>
    ```

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
