# Lab 4: Run the Bot as a Service and Verify Its Features

## Introduction

Test the bot under systemd. Check Discord, model, and agent features, then review the service logs.

Estimated Time: 30 minutes.

### Objectives

In this lab, you will:

- Run the application as the `opc` user with a protected environment file.
- Confirm the Nginx HTTPS proxy and Discord interaction handshake.
- Test the configured bot commands, bot mentions, file handling, and agent privacy behavior.
- Review service status, logs, and restart behavior.

### Prerequisites

- Completion of Labs 1 through 3.
- A PAR, Discord app, OpenRouter settings, database wallet, agent schema, and reserved IP certificate.
- The reserved Compute public IPv4 address and a valid, renewed Let’s Encrypt IP certificate.
- A private Discord server where you can test all bot features.

## Task 1: Check the Asset Link and Register Commands

1. Confirm that the Object Storage link in Lab 2 downloads the ZIP. Confirm the ZIP contains the approved source package and has no `.env`, wallet, credentials, private keys, or `node_modules`.

2. Confirm that `opc` owns `.env` and that its mode is `600`. Do not print the file contents.

    ```sh
    <copy>
    stat -c '%a %U %n' /home/opc/hackathon-bot/.env
    </copy>
    ```

3. Register the commands after any configuration changes.

    ```sh
    <copy>
    cd /home/opc/hackathon-bot
    npm run register
    </copy>
    ```

## Task 2: Create and Start the systemd Service

1. Stop the foreground process from Lab 3 with `Ctrl+C`.

2. Create the service file. This command writes the unit to `/etc/systemd/system/discord-example.service`. The service reads `.env` at startup and runs as the unprivileged `opc` user.

    ```sh
    <copy>
    sudo tee /etc/systemd/system/discord-example.service >/dev/null <<'EOF'
    [Unit]
    Description=Discord learning bot
    After=network-online.target nginx.service
    Wants=network-online.target nginx.service

    [Service]
    Type=simple
    User=opc
    Group=opc
    WorkingDirectory=/home/opc/hackathon-bot
    EnvironmentFile=/home/opc/hackathon-bot/.env
    ExecStart=/usr/bin/node /home/opc/hackathon-bot/app.js
    Restart=on-failure
    RestartSec=5
    NoNewPrivileges=true
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target
    EOF
    </copy>
    ```

    Lab 1 installs system-wide Node at `/usr/bin/node`. If `command -v node` reports another path, update `ExecStart` to that absolute path.

3. Reload systemd and enable the service.

    ```sh
    <copy>
    sudo systemctl daemon-reload
    sudo systemctl enable --now discord-example.service
    sudo systemctl is-active discord-example.service
    sudo systemctl is-enabled discord-example.service
    </copy>
    ```

4. Review the service log. Confirm that the HTTP listener and Discord Gateway login both succeed.

    ```sh
    <copy>
    sudo journalctl -u discord-example.service -n 80 --no-pager
    </copy>
    ```

5. Confirm Nginx is active and can proxy to the bot on port 3000. From the Compute host, check the service and configuration if requests fail.

    ```sh
    <copy>
    sudo systemctl is-active nginx
    sudo nginx -t
    sudo journalctl -u nginx -n 40 --no-pager
    </copy>
    ```

## Task 3: Verify the Discord Endpoint and Bot Features

1. In the Discord Developer Portal, set **Interactions Endpoint URL** to `https://<your-public-ip>/interactions`, using the reserved IP from Lab 1. Save it. Discord verifies the URL with a signed interaction handshake. Confirm that the portal accepts it.

2. In the private test server, run `/ask` with a short learning question. Mention the bot in a message. Confirm each request receives one response.

3. Run `/research` with a non-sensitive topic. Confirm the response contains source links.

4. Run `/study` with **Guide**, then use **Exam**. Confirm the exam contains five questions. Try a non-sensitive sample attachment in PDF, TXT, Markdown, CSV, or JSON format. The current source limits study files to 8 MB.

5. Run `/oci` with one of its supported topics: Oracle AI Database, GoldenGate, AI Lakehouse, or Deep Trust AI.

6. Lab 3 Task 4 verifies the `/db` schema scan. Skip `/db` status and lookup; this workshop tests only the scan.

7. Open `/agent`. Create and run a small learning agent. Confirm management and private tests use ephemeral responses. Confirm a normal run in a server channel is visible to channel members.

8. Ask for a long answer. Confirm the bot sends a Markdown attachment when the response exceeds Discord message limit.

9. Check data handling. Model prompts go to OpenRouter. Agent profiles remain in Autonomous Database. Channel members can see agent runs. Use no private learner, customer, or production data.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gómez Guerrero
- Last Updated: Ilan Gómez Guerrero, November 2026
