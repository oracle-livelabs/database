# Install and Configure Agent Factory on OCI
## Introduction
In this lab, you'll deploy the Private Agent Factory from the OCI Marketplace on a compute instance using a pre-built image. You'll use the VCN (with a public subnet) and Autonomous Database created in the previous lab during setup and configure OCI GenAI Services as the LLM Provider.

**Estimated time:** 15 minutes.

### Objectives

* Install the Private Agent Factory from the OCI Marketplace 
* Login and configure the Agent Factory
* Set the Oracle AI Database and the LLM provider

### Prerequisites

* Your VCN and Oracle AI Database 26ai details from the previous lab
* Familiarity with the OCI Marketplace and Resource Manager


## Task 1: Review Stack Resources and Retrieve Application URL

This task uses a Resource Manager stack published in the OCI Marketplace.

### 1. Open the Marketplace Listing

* Navigate to the **Oracle AI Database – Private Agent Factory** listing:
  [https://cloudmarketplace.oracle.com/marketplace/en_US/listing/201588705](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/201588705)

   ![Agent Factory Application in Marketplace](images/marketplace-listing.png "Agent Factory Application in Marketplace")

### 2. Launch the Stack

* Click **Get App** and authenticate to your tenancy
* Review the product overview
* Click **Launch Stack**

   ![Agent Factory launch stack](images/launch-stack.png "Agent Factory launch stack")

### 3. Accept Terms

* Review and accept the Oracle Standard Terms and Restrictions
* Click **Launch Stack**

### 4. Stack Configuration

> For this step, ensure you have a VCN with a public subnet (created in Task 1 of the Getting Started Lab). Ensure your subnet allows inbound access on ports 22, 8080, and 1521.

Under **General Settings**:

* Select the **Region** of your VCN.
* Select the **Compartment** of your VCN.

Under **Network Configuration**:

* Select your **VCN** 
* Select your **Public Subnet** 


### 5. Compute Configuration

* Provide a display name for the Agent Factory instance
* Select an instance shape (for example, `VM.Standard.E5.Flex`)
* Choose appropriate OCPU and memory (larger memory improves agent performance)

   ![Agent Factory configure variables](images/configure-variables.png "Agent Factory configure variables")

### 6. Create the Stack

* Review the configuration
* Click **Create**

Resource Manager will now run a Terraform **Apply** job to provision the instance and install the Agent Factory container.

### 7. Retrieve the Application URL

Once the job completes successfully:

* Open the **Logs** or **Outputs** tab
* Copy the application URL, which has the format:

   ```
   <copy>
   https://{instance_public_ip}:8080/studio/installation
   </copy>
   ```

   ![Agent Factory creation succeeded](images/creation-succeeded.png "Agent Factory creation succeeded")


## Task 2: Login and First-Time Configuration

### 1. Create the Agent Factory User

* Open the application URL in your browser
* Set the **username and password** for the Agent Factory administrator

   ![Sign Up screen for Oracle AI Database Private Agent Factory .](images/sign_up.png)

### 2. Configure the Database Connection

Provide the following:

* Upload the **Autonomous Database wallet**
* Database wallet username and password

Click **Test Connection** before proceeding.

   ![Database configuration screen for Oracle AI Database Private Agent Factory.](images/database_setup.png)


### 3. Install the Agent Factory into your Database

Click **Install** to begin downloading the Private Agent Factory resources into your database. Once complete, select **Next**.

   ![Installation complete screen for Oracle AI Database Private Agent Factory.](images/db_installation_complete.png)

### 4. Configure AI Provider Access

Provide credentials for your LLM provider, such as:

* OCI Generative AI (using OCI API keys)
* Other supported providers, depending on your environment

   ![LLM Configuration screen for Oracle AI Database Private Agent Factory.](images/llm_config.png)


This enables:

* Agent reasoning
* Embedding generation
* Evaluation and summarization workflows

### 5. Finalize Setup

* Complete the wizard
* Log back in to access the Agent Factory UI

You are now ready to start building agents using:

* Pre-built agent templates
* The visual Agent Builder
* Open Agent Specification-compatible workflows

---

You may now **proceed to the next lab**

## References

* Product documentation: [https://docs.oracle.com/en/database/oracle/agent-factory/](https://docs.oracle.com/en/database/oracle/agent-factory/)

## Acknowledgements

**Authors** 

* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI
* Kumar Varun, Senior Principal Product Manager, Database Applied AI

**Last Updated Date** - February, 2026
