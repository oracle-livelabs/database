# Lab 2.2: Installing the Private Agent Factory from Source

## Introduction
While the OCI Marketplace provides the fastest path to deployment, installing the **Private Agent Factory** from source offers maximum flexibility and control for advanced users. This method is ideal for those looking to deploy in highly customized environments, integrate with local container registries, or manage the "Agentic Flows" within specific DevOps pipelines.

By installing from source, you are essentially setting up the **Agent Factory Container** and its associated services manually. This path leverages the **Portability** pillar of the **S3P3 Framework**, allowing the factory to run anywhere—whether on-premises or across various cloud providers—by utilizing the **Open Agent Spec**.

### Objectives
*   Prepare a Linux compute environment for a manual containerized deployment.
*   Configure the connection to the **Oracle AI Database 26ai** backend.
*   Manually pull and initialize the Agent Factory application containers.
*   Configure the environment variables for LLM providers and database schemas.

### Prerequisites
*   A compute instance (VM or Bare Metal) running Oracle Linux 8 or 9.
*   Root or sudo access to install container runtimes (Docker or Podman).
*   An existing **Oracle AI Database 26ai** (Autonomous or On-Premises) with network visibility to your compute instance.
*   Minimum system requirements: 8 OCPUs and 64GB of RAM to ensure smooth performance for agent orchestration.

***

## 1. Prepare the Host Environment
Unlike the automated Marketplace stack, a manual installation requires you to configure the operating system and container engine yourself.
1.  **Install Container Engine:** Ensure Docker or Podman is installed and the service is enabled.
2.  **Network Setup:** Ensure the firewall on your Linux host allows traffic on port **8080** (for the web interface) and that the host can reach the database on port **1521**.
3.  **Create Installation Directory:** Create a dedicated directory for the Agent Factory files to manage your configuration and persistent data.

## 2. Secure the Source Files
You will need the official container images and the configuration templates provided by the Oracle AI Database Products team.
1.  **Pull Images:** Pull the **Agent Factory Container** and the **Ingestion Service** images from the designated repository.
2.  **Template Configuration:** Copy the sample environment configuration file (often labeled as `.env.template`). This file will serve as the "brain" for your installation, defining how the containers talk to the outside world.

## 3. Configure the Database Backend
The Private Agent Factory is a "Converged AI Database" application. It requires a schema and a vector store to manage its long-term memory and agentic state.
1.  **Schema Creation:** Log into your **Autonomous AI Database** and create a dedicated user/schema for the Factory.
2.  **Assign Permissions:** Grant the necessary privileges for **Vector AI Search** and **Select AI** integration.
3.  **Connectivity:** Download the Database Wallet (if using Mutual TLS) or prepare the connection string for standard TCP connections.

## 4. Initialize the Factory
With the images pulled and the database ready, you can now launch the services.
1.  **Edit Environment Variables:** Update your configuration file with:
    *   `DB_HOST`, `DB_PORT`, and `DB_SERVICE_NAME`.
    *   `FACTORY_ADMIN_USER` credentials.
    *   `LLM_PROVIDER_API_KEYS` (e.g., OCI GenAI, OpenAI, or local vLLM endpoints).
2.  **Start Containers:** Use your container orchestration tool to start the Factory. This will initialize the **Agent Factory Schema** and the **Vector Store** automatically within your database.
3.  **Verify Services:** Check the container logs to ensure the application server has successfully connected to the 26ai database and is listening on port 8080.

## 5. Final Registration
Once the containers are running:
1.  Access the interface via your browser at `http://<your-server-ip>:8080`.
2.  Follow the on-screen prompts to complete the **User Configuration** and **LLM Management** setup.
3.  Test the connection to ensure the Factory can successfully execute **SQL Queries** and **Vector Searches** against your database.

***

## Acknowledgements

- **Authors** 
* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026