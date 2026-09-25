# Lab 6: Knowledge Check

## Introduction

Use this lab to confirm that you understand the integration pattern before you adapt it to your own application. The questions focus on design choices, failure modes, and the behavior of the PL/SQL processes used in the earlier labs.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

- Confirm why the API Gateway is required in this design.
- Review how session creation and message delivery work.
- Validate the key operational decisions from the workshop.

```quiz-config
passing: 75
badge: images/badge.png
```

## Task 1: Complete the Scored Quiz

1. Answer the following questions based only on the workshop content.

    ```quiz score
    Q: Why is OCI API Gateway the recommended bridge between Oracle APEX and the private PAF backend in this workshop?
    * It gives APEX a trusted public endpoint while still reaching the private self-signed backend.
    - It converts NDJSON into XML so APEX can parse the response.
    - It removes the need for Agent Factory authentication entirely.
    - It stores the PAF password so APEX does not need Web Credentials.
    > The gateway solves the certificate and network boundary problem at the same time. It presents a trusted public certificate to APEX while forwarding traffic to the private backend.

    Q: What does the `loginValidation` endpoint provide that the APEX integration needs before it can call the agent?
    * A fresh `agent_factory_session` cookie in the `Set-Cookie` header
    - A room ID and the first assistant message in a single response
    - A new public gateway deployment URL
    - A permanent token that never expires
    > The login route is used to mint a fresh session cookie. The room ID is created later by posting the initial message to the agent endpoint.

    Q: Why is the manual cookie-copy workflow unsuitable for production use?
    * The cookie expires regularly and requires repeated operator intervention.
    - The cookie is too large for APEX page items.
    - The cookie cannot be read in browser developer tools.
    - The cookie prevents API Gateway from forwarding requests.
    > The source workflow required a person to copy the session value from developer tools and paste it into the app again after the cookie expired.

    Q: Why does the initialization PL/SQL send a starter message such as `hi` after logging in?
    * To force the agent endpoint to create a room and emit a `roomCreated` event
    - To warm the API Gateway cache with a sample payload
    - To verify that the APEX Web Credential password is encrypted
    - To disable the session timeout for the rest of the chat
    > The first agent call establishes the room context. The code then parses the NDJSON response to capture the room ID for later messages.

    Q: What is the main reason to fetch a fresh cookie before every outbound chat message?
    * It avoids cookie-expiry tracking and keeps the session working without manual refresh steps.
    - It reduces the size of the NDJSON response payload.
    - It changes the room ID for every message to isolate history.
    - It allows the agent to respond without a message body.
    > Refreshing the cookie on each call trades a small extra request for a simpler and more reliable session model.

    Q: Why should the PAF username and password live in APEX Web Credentials instead of inside the PL/SQL block?
    * Web Credentials store the secret in APEX and keep it out of the source code.
    - Web Credentials are the only way to parse `Set-Cookie` headers in APEX.
    - Web Credentials automatically convert NDJSON into JSON arrays.
    - Web Credentials remove the need for hidden page items.
    > The workshop uses Web Credentials so the login secret is managed by APEX rather than copied into PL/SQL source.
    ```

## Acknowledgements

* **Author** - Lavkesh Singh, Cloud Solution Engineer, JAPAC Hub
* **Last Updated By/Date** - Lavkesh Singh, April 2026
