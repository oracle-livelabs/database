# Deploy Agents from the Private Agent Factory

## Introduction
Building an intelligent agent is only the first half of the journey. To derive real business value, an agent must be **deployed** so it can be consumed by external applications, integrated into corporate portals, or called by automated scripts. The **Private Agent Factory** simplifies this transition from design to production through a streamlined publishing process.

Following the **S3P3 Framework**, specifically the **Portability** and **Simplicity** pillars, the Factory allows you to turn a visual "Agentic Flow" into a production-grade **REST endpoint** with a single click. This lab will teach you how to move your agent out of the Builder and into the hands of your developers.

### Objectives
*   Publish a custom agent using the Agent Builder interface.
*   Locate and understand the exposed REST endpoint.
*   Retrieve the necessary Bearer token for secure authentication.
*   Execute a local API call to your deployed agent using `curl`.

### Prerequisites
*   A completed and saved agent flow in the **Agent Builder** (from Lab 6).
*   Administrative access to the Private Agent Factory.
*   A local terminal or command-line interface (macOS, Linux, or Windows PowerShell).

***

## 1. Publishing Your Agent
Once you have tested your agent in the **Playground** and are satisfied with its performance, you must publish it to make it available outside of the Studio.

1.  Open your agent flow in the **Agent Builder**.
2.  Locate the **Publish** button in the top-right corner of the interface (next to the Playground button).
3.  Click **Publish**. The Factory will validate the flow, ensure all tool connections (like MCP servers or SQL nodes) are active, and generate a unique deployment ID.
4.  Once the status changes to "Published," your agent is now live and listening for external requests.

## 2. Locating the REST Endpoint
The Private Agent Factory is designed to be "Integration Ready." Every published agent exposes a standard REST API. 

1.  Navigate to the **My Custom Flows** or the specific Agent's settings page.
2.  Look for the **Deployment URL** or **Endpoint** field.
3.  The endpoint will typically follow a structure similar to: 
    `https://<your-factory-ip>:8080/api/v1/agents/<agent-id>/chat`

## 3. Obtaining a Bearer Token
To protect your enterprise data, all REST calls to the Factory require a **Bearer Token** for authentication.

**Note:** The following process for retrieving a token is based on standard REST application practices for this platform and may require independent verification depending on your specific SSO configuration.

1.  Navigate to the **Settings** menu in the left sidebar and select **User Management** or **Security Settings**.
2.  If your environment uses API Keys, click on your profile to **Generate API Token**.
3.  Alternatively, for local testing, you can often find your current session token by opening your browser's **Developer Tools** (F12), navigating to the **Network** tab, clicking on any internal Factory request, and copying the value of the `Authorization: Bearer <token>` header.

## 4. Calling the Agent from Your Local Machine
With the Endpoint and the Bearer Token, you can now interact with your agent from any terminal. Replace the placeholders in the following example with your actual data:

```bash
curl -X POST "https://<your-factory-ip>:8080/api/v1/agents/<agent-id>/chat" \
     -H "Authorization: Bearer <your_bearer_token>" \
     -H "Content-Type: application/json" \
     -d '{
           "message": "What is the current status of the project?",
           "stream": false
         }'
```

**What to expect:**
*   **Request:** You are sending a JSON payload containing your prompt to the agent.
*   **Response:** The agent will process the request through the flow you designed (e.g., querying the database or searching knowledge bases) and return a JSON response containing the grounded answer.

***

- **Authors** 
* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026