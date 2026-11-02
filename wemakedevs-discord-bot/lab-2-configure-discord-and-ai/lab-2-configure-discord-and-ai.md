# Lab 2: Download the Bot and Configure Discord and OpenRouter

## Introduction

Download and configure the bot. Set up Discord and OpenRouter on Compute, register the slash commands, and start the app. The sample Object Storage URL is invalid. The workshop owner replaces it after publishing the ZIP and creating a PAR.

Estimated Time: 25 minutes.

### Objectives

In this lab, you will:

- Download and inspect the bot ZIP through the workshop object-scoped PAR.
- Configure Discord slash-command and interaction settings.
- Add OpenRouter settings without recording credential values in the workshop.
- Install locked dependencies, register six commands, and start the bot.

### Prerequisites

- Finish Lab 1. You need system Node.js 24, SSH access, a reserved IP, and a valid IP certificate.
- An active Object Storage PAR from the workshop owner.
- Discord Developer Portal access and a private test server.
- An OpenRouter API key and model name available to your account.

## Task 1: Download and Inspect the Bot Package

1. Confirm that the workshop owner replaced the placeholder with a working object-read PAR. The PAR must target only the bot ZIP and expire after the workshop. Anyone with the URL can download the file.

2. Download the package to the Compute host. Replace the temporary URL with the real value from the workshop owner.

    ```sh
    <copy>
    PACKAGE_URL='https://objectstorage.REGION.oraclecloud.com/p/TEMPORARY-PAR-NOT-CREATED/n/NAMESPACE/b/discord-bot-assets/o/hackathon-bot.zip'
    curl --fail --location "$PACKAGE_URL" \
      --output /tmp/hackathon-bot.zip
    </copy>
    ```

    The sample URL will fail until the owner replaces it. If it remains unchanged, request the current package link.

3. Inspect the archive before extraction. Confirm it contains `.env.sample`, `LICENSE`, `package.json`, `package-lock.json`, `app.js`, `agents/`, and `db/`. Confirm it does not contain `.env`, wallets, keys, credentials, `.git`, or `node_modules`.

    ```sh
    <copy>
    unzip -l /tmp/hackathon-bot.zip
    </copy>
    ```

4. Extract the package, install production dependencies from the lockfile, and create a private environment file.

    ```sh
    <copy>
    unzip -o /tmp/hackathon-bot.zip \
      -d /home/opc/hackathon-bot
    cd /home/opc/hackathon-bot
    npm ci --omit=dev
    cp .env.sample .env
    chmod 600 .env
    </copy>
    ```

    Keep the original `.env.sample` unchanged. Keep `.env` on Compute. Do not add it to the asset ZIP or Git.

## Task 2: Create and Install a Discord Application

1. In the [Discord Developer Portal](https://discord.com/developers/docs/intro), create an application and add its bot user. Set an application name and bot display name for your workshop server.

2. Create a **Guild Install** link with the `bot` and `applications.commands` scopes. Grant only these permissions in the test server: view channels, send messages, read history, and attach files.

3. Use the Developer Portal installation flow to add the bot to your private test server. Keep the bot token and application public key in your password manager until you enter them on the host.

4. Edit `.env` on Compute. Add the application ID, bot token, application public key, and port. Do not put credential values in workshop notes, chat, or source control.

    ```text
    <copy>
    APP_ID=
    DISCORD_TOKEN=
    PUBLIC_KEY=
    PORT=3000
    </copy>
    ```

    The application ID is the Discord application identifier. The public key is in the app **General Information** page. The bot token is in the **Bot** page. These values serve different purposes.

5. Set **Interactions Endpoint URL** to `https://<your-public-ip>/interactions` after you start the app in Task 4. Replace the placeholder with the reserved public IPv4 address from Lab 1. Discord sends a verification request to this address. Nginx provides HTTPS and proxies requests to the app on port `3000`.

## Task 3: Configure OpenRouter

1. Add the OpenRouter API key and a model identifier available to your account. Keep the default agent data-collection preference set to `deny` unless you have reviewed and approved the provider policy.

    ```text
    <copy>
    OPENROUTER_API_KEY=
    OPENROUTER_MODEL=
    OPENROUTER_STUDY_MODEL=
    OPENROUTER_DATETIME_TIMEZONE=America/Mexico_City
    OPENROUTER_AGENT_DATA_COLLECTION=deny
    </copy>
    ```

    `OPENROUTER_STUDY_MODEL` is optional; the bot falls back to `OPENROUTER_MODEL`. The timezone is optional and uses an IANA timezone name. Check the current `.env.sample` for any new optional settings.

2. Save `.env`, then confirm its permissions.

    ```sh
    <copy>
    chmod 600 /home/opc/hackathon-bot/.env
    stat -c '%a %U %n' /home/opc/hackathon-bot/.env
    </copy>
    ```

    Expect mode `600` and owner `opc`. Do not print or screenshot the file contents.

## Task 4: Register Commands and Start the Bot

1. Register the current global slash commands from the application directory.

    ```sh
    <copy>
    cd /home/opc/hackathon-bot
    npm run register
    </copy>
    ```

2. Confirm that registration reports six commands: `/ask`, `/db`, `/research`, `/study`, `/oci`, and `/agent`.

3. Start the bot in the foreground.

    ```sh
    <copy>
    npm start
    </copy>
    ```

4. Confirm the logs show the HTTP listener and a successful Discord Gateway login. Nginx should be active and proxy requests to the app on port `3000`.

5. In the Discord test server, run `/ask` with a short learning question. Confirm it returns one answer. Mention the bot with a short question and confirm a reply. If Discord has not accepted the endpoint yet, confirm that `https://<your-public-ip>/interactions` uses the reserved IP and valid certificate, then retry.

6. Stop the foreground process with `Ctrl+C`. Lab 4 will run the bot under systemd.

## Data Handling Checkpoint

The bot sends `/ask`, `/research`, `/study`, `/oci`, and agent prompts to OpenRouter. It processes each attachment for the current request and does not store it permanently. Do not test with private information. Server replies appear to channel members.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gómez Guerrero
- Last Updated: Ilan Gómez Guerrero, November 2026
