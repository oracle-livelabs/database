# Lab 1: Import ONNX Embedding Model

## Introduction
This lab covers the essential environment setup and model preparation required to deploy **Oracle Trusted Answer Search**. You will provision an Autonomous Database, set up a compute environment, and prepare a compatible ONNX embedding model that will power your semantic search results.

> **Important:** Do not use a model downloaded directly from Hugging Face. It must be exported via the OML4Py client to ensure the input tensor dimensions are fixed and compatible with Oracle AI Vector Search. A raw Hugging Face export will fail with `ORA-54426` during installation.

**Estimated time:** 30 minutes.

### Objectives
* Provision an Oracle Autonomous Database Serverless (ADB-S) instance.
* Set up an OCI Compute VM with Python 3.13 and OML4Py.
* Export and upload a database-compatible ONNX embedding model.
* Configure the database client and wallet for backend installation.

---

## Task 1: Create ADB-S Instance

1. Sign in to the OCI Console and navigate to **Oracle Database → Autonomous Database → Create Autonomous Database**.
2. Set the **Database version** to **26ai**.
3. Configure your ADMIN password and note it down — it will be used throughout the installation.
4. Once the status shows **Available**, click **Database Connection** and select **Download Wallet**. Save the wallet zip to your local machine.
5. From the **Database Connection** page, note your preferred TNS alias (e.g. `_high`) — you will use this as your connect string.

---

## Task 2: Create an OCI Compute VM

Create an Oracle Linux 9 x86-64 Compute VM in the same region as your database.
This VM will be used for both the ONNX model conversion and running the backend installer.

1. In the OCI Console, navigate to **Compute → Instances → Create Instance**.
2. Select **Oracle Linux 9** as the image and choose a shape with at least 16 GB RAM (e.g. VM.Standard.E4.Flex, 1 OCPU).
3. Add your SSH public key so you can connect to the VM.
4. Once running, connect via SSH:

    ```sh
    <copy>
    ssh opc@PUBLIC-IP
    </copy>
    ```

---

## Task 3: Install Python 3.13 and Set Up OML4Py

### 3.1 Install Python 3.13

Python 3.13 is required by the OML4Py client. It is available via the Oracle Linux EPEL developer repository:

```sh
<copy>
sudo dnf config-manager --enable ol9_developer_EPEL
sudo dnf install -y python3.13
</copy>
```

### 3.2 Create a virtual environment

```sh
<copy>
python3.13 -m venv ~/oml4py-env
source ~/oml4py-env/bin/activate
</copy>
```

### 3.3 Download the OML4Py client

1. Go to the **Oracle Machine Learning for Python Downloads** page on the Oracle Technology Network (oracle.com/downloads).
2. Accept the license agreement and select **Oracle Machine Learning for Python Downloads (v2.1.1)**.
3. Select **Oracle Machine Learning for Python Client Install for Oracle Database on Linux 64 bit**.
4. Save the zip file to your VM (e.g. into a directory named `~/oml4py`).

### 3.4 Unzip the OML4Py client

```sh
<copy>
cd ~/oml4py
unzip oml4py-client-linux-x86_64-2.1.1.zip
cd client/
</copy>
```

The zip extracts to a `client/` subdirectory containing:
- `oml-2.1.1-cp313-cp313-linux_x86_64.whl` — the OML4Py wheel for Python 3.13
- `client.pl` — a Perl pre-install helper (can be skipped if Perl is not installed)
- `OML4PInstallShared.pm`
- `oml4py.ver`

### 3.5 Install OML4Py and all required dependencies

Install the dependencies first, then the OML4Py wheel:

```sh
<copy>
pip install oracledb onnxruntime onnx
pip install ./oml-2.1.1-cp313-cp313-linux_x86_64.whl
pip install transformers torch onnxruntime_extensions requests sentencepiece
pip install "optimum[exporters]"
pip install "optimum[onnxruntime]" --upgrade
</copy>
```

---

## Task 4: Export the ONNX Embedding Model

Create and run the following Python script to export the recommended `multilingual-e5-base` model:

```python
<copy>
from oml.utils import EmbeddingModel

em = EmbeddingModel(model_name="intfloat/multilingual-e5-base")
em.export2file("multilingual-e5-base", output_dir=".")
</copy>
```

Deprecation and TorchScript warnings during export are expected and safe to ignore.

Verify the output file was created:

```sh
<copy>
ls -lh multilingual-e5-base.onnx
# Expected: approximately 283 MB
</copy>
```

---

## Task 5: Upload Model to OCI Object Storage

### 5.1 Create a bucket

In the OCI Console, navigate to **Storage → Object Storage → Create Bucket**.
Name it `TAS-models`.

### 5.2 Upload the model using OCI CLI

If OCI CLI is not yet configured on the VM, run `oci setup config` first and
follow the prompts for your tenancy OCID, user OCID, region, and API key.

Then upload the model:

```sh
<copy>
oci os object put \
  --bucket-name TAS-models \
  --file multilingual-e5-base.onnx \
  --name multilingual-e5-base.onnx
</copy>
```

### 5.3 Generate a Pre-Authenticated Request (PAR) URL

1. In the OCI Console, click into your bucket and click the uploaded object.
2. Select **Create Pre-Authenticated Request**.
3. Set an expiry date far enough in the future to cover your installation window.
4. Copy the generated URL — it will be used as `MODEL_URI` in your configuration.

The URL will look like:
```
<copy>
https://objectstorage.{REGION}.oraclecloud.com/p/{PATH}/n/{NAMESPACE}/b/{BUCKET}/o/multilingual-e5-base.onnx
</copy>
```

Verify the URL is reachable from your VM:
```sh
<copy>
curl -I "{your-PAR-URL}"
# Expect: HTTP/1.1 200 OK
</copy>
```

---

## Task 6: Install SQL*Plus and Configure the Wallet

### 6.1 Install Oracle Instant Client and SQL*Plus

```sh
<copy>
sudo dnf install -y oracle-instantclient-release-23ai-el9
sudo dnf install -y oracle-instantclient-basic oracle-instantclient-sqlplus
</copy>
```

Add SQL*Plus to your PATH:

```sh
<copy>
export PATH=/usr/lib/oracle/23/client64/bin:$PATH
echo 'export PATH=/usr/lib/oracle/23/client64/bin:$PATH' >> ~/.bashrc
</copy>
```

Verify:

```sh
<copy>
sqlplus -version
</copy>
```

### 6.2 Copy the wallet to the VM

From your local machine:

```sh
<copy>
scp -i ~/.ssh/your-private-key Wallet_{db_name}.zip opc@{vm-ip}:~/
</copy>
```

### 6.3 Unzip and configure the wallet

```sh
<copy>
mkdir -p ~/adb-wallet
unzip Wallet_{db_name}.zip -d ~/adb-wallet/
</copy>
```

Edit `~/adb-wallet/sqlnet.ora` and replace the `DIRECTORY` value with the
absolute path to the wallet folder:

```
<copy>
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/home/opc/adb-wallet/")))
SSL_SERVER_DN_MATCH=yes
</copy>
```

### 6.4 Set the TNS_ADMIN environment variable

```sh
<copy>
export TNS_ADMIN=/home/opc/adb-wallet/
echo 'export TNS_ADMIN=/home/opc/adb-wallet/' >> ~/.bashrc
</copy>
```

### 6.5 Verify connectivity

```sh
<copy>
sqlplus ADMIN/{your-admin-password}@{tns-alias}
# e.g. sqlplus ADMIN/mypassword@tasdb_high
</copy>
```

You should reach a `SQL>` prompt. Type `exit` to quit.

You now have the model location and database connectivity values needed by the backend installer.

You may now **proceed to the next lab**.

---

## Acknowledgements

**Authors**
* Allen Hosler, Principal Product Manager, Database Applied AI


**Last Updated Date** - May, 2026
