# Log in to the Private Agent Factory

## Introduction

In this lab, you will learn how to connect Oracle Database 23ai with LLM services to get the most out of Oracle AI Database Private Agent Factory.

**Estimated time:** 10 minutes.

### Objectives

By the end of this lab, you will be able to:

- Create a dedicated user account to manage Oracle AI Database Private Agent Factory.
- Configure secure connection between Oracle Database 23ai and Oracle AI Database Private Agent Factory.
- Install and initialize Oracle AI Database Private Agent Factory schema and tables in your database.
- Set up Large Language Model (LLM) credentials for use in the application.
- Log in and validate successful configuration of Oracle AI Database Private Agent Factory.

### Prerequisites

- **Oracle Database 23ai credentials**. You will need access to an instance of Oracle Database 23ai. It is recommended to create a dedicated user for this purpose. This user should be used exclusively for managing these tables and not for storing production data.

- **LLM credentials**. The Oracle AI Database Private Agent Factory relies on integration with a Large Language Model to function properly. You will require appropriate authentication credentials or an access key to connect the application with an available LLM instance of your choice.

## Task 1: User creation

Continuing from the previous module, you will now sign up for Oracle AI Database Private Agent Factory by creating a user account. You will need to set up an email and a securely stored password. This user will be responsible for managing the Oracle AI Database Private Agent Factory application and its other users.

![Sign Up screen for Oracle AI Database Private Agent Factory displaying user configuration step. The form includes fields for email, password, and repeat password, with an information box stating that this user would be responsible for managing the application and other users. The 'Next' button is disabled.](images/sign_up.png)

## Task 2: Configure Application Data Database Connection

Next, connect to the database where application data will be stored. We strongly suggest creating a dedicated user for this purpose, separate from your production environment.

You can either enter the Oracle 23ai Database connection details directly, provide the connection string or upload a database wallet file.

![Database configuration screen for Oracle AI Database Private Agent Factory showing fields for connection protocol, host, port, service name, username, and password. An information box at the top explains the purpose of configuring a 23ai database connection for storage and search, and a 'Test Connection' button is at the bottom. Other connection options are Connection String and Wallet.](images/database_setup.png)

After entering your credentials, click **Test Connection**. If the credentials are correct, a "Database connection successful" message will be displayed. Then click **Next**.

## Task 3: Database Installation

Proceed to install Oracle AI Database Private Agent Factory into the configured database.

![Installation screen for Oracle AI Database Private Agent Factory showing an info box explaining that the application will be installed into the configured database, with an 'Install' button below the message and the 'Next' button disabled.](images/db_installation.png)

Click **Install** and wait a few minutes for the setup to complete. When finished, you will see the message `✓ Please proceed to the next step for LLM Configuration`. Then press **Next**.

![Installation complete screen for Oracle AI Database Private Agent Factory displaying an information box about the installation, a detailed installation log with successful migration and component start messages, and a 'Next' button enabled.](images/db_installation_complete.png)

## Task 4: LLM Configuration

Select an LLM configuration based on your LLM provider. The application supports integration with Ollama, vLLM, OpenAI, and the full suite of OCI GenAI offerings. Depending on your select provider, the required connection credentials may differ.

![LLM Configuration screen for Oracle AI Database Private Agent Factory showing fields to configure a generative model, including configuration name, model ID, endpoint, compartment ID, user, tenancy, fingerprint, region, and a key file upload area. The 'With Finger Print' option is selected, and the OCI GenAI tab is active. Available generative model options are: Ollama, vLLM, OpenAI and OCI GenAI.](images/llm_config.png)

Once all required fields are completed, test the connection using the **Test Connection** button. If the credentials are valid, a "Connection successful" message will appear. Then click **Save Configuration**.

Oracle AI Database Private Agent Factory also enables you to add a dedicated embedding model for various use cases. For this tutorial, this step is skipped. The configuration process for an embedding model is similar.

After saving the configuration and successfully connecting to the model, click **Finish installation**.

## Task 5: Log In

With the configuration complete, you will be prompted to log in with the email and password created in Task 1. After logging in, you will be greeted by the Get Started screen.

![The Log In screen for Oracle AI Database Private Agent Factory, featuring a form with fields for email and password. An unchecked box of 'Remember me' and a 'Forgot password?' link are visible. The 'Sign In' button is currently disabled.](images/log_in.png)

## Summary

This concludes the current module. Your configuration is now complete. The following modules will explore each feature of Oracle AI Database Private Agent Factory in greater detail. Continue with them so you don't miss out on new discoveries and learning opportunities. You may now **proceed to the next lab**.

## Acknowledgements

- **Authors** 
* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026


