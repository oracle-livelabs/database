# Connect to your FreeSQL schema from VS Code

## Introduction

Connect your FreeSQL schema to VS Code to write and execute SQL directly against your FreeSQL environment, making it easy to develop, test, and manage queries from within your local workflow.

### Objectives

In this lab, you will:

- Create or sign in to a FreeSQL account
- Retrieve your schema connection details
- Install the Oracle SQL Developer for VS Code extension
- Capture connection information for later use

Estimated Time: 10 minutes

## Task 1: Navigate to FreeSQL.com and sign in or create a new account

<freesql-button>

![click-sign-in-for-freesql](images/click-sign-in-for-freesql.png " ")
![click-create-new-account-button](images/click-create-new-account-button.png " ")
![creating-an-oracle-account-form](images/creating-an-oracle-account-form.png " ")
![sign-in-with-existing-or-new-credentials](images/sign-in-with-existing-or-new-credentials.png " ")
![oracle-mfa-authorize-in-second-device](images/oracle-mfa-authorize-in-second-device.png " ")

## Task 2: Log into FreeSQL

Once logged in, click the <strong>Connect with [rotating language option]</strong> button.

![click-connect-with-button](images/click-connect-with-button.png " ")

## Task 3: Grab your FreeSQL connection details

Your new FreeSQL connection details will appear. Your password will appear only once. Copy the SQLcl connect string for future use. If you need a new password, click <strong>&circlearrowleft; Regenerate</strong>.

![schema-connection-details-for-freesql](images/schema-connection-details-for-freesql.png " ")

![regenerating-new-password](images/regenerating-new-password.png " ")

## Task 4: Install the SQL Developer VS Code extension

Install the SQL Developer for VS Code extension, found [here](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer). Take note of your password, click the <strong><span style="display:inline-block; transform: rotate(90deg);">&#8689;</span> Create a SQL Developer for VS Code connection</strong> button, and continue to the next task. Visual Studio Code should open automatically.

![create-a-sql-connection-in-vs-code-button](images/create-a-sql-connection-in-vs-code-button.png " ")

## Task 5: Note your FreeSQL connection details for later

If you do not yet have the SQL Developer for VS Code extension installed, note your FreeSQL credentials for later use:

- Username
- Password
- Hostname
- Port
- Service Name

![sqlcl-connection-details-for-later-use](images/sqlcl-connection-details-for-later-use.png " ")

## Acknowledgements

* **Author** – Layla Elwakhi, Oracle
* **Last Updated By** – Layla Elwakhi, March 2026