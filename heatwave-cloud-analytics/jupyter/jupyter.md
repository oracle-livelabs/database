# Deploy Jupyter notebook

## Introduction

<a href="https://www.jubyterlab.org/", target="\_blank">JupyterLab</a> notebook is the latest web-based interactive development environment for notebooks, code, and data. Its flexible interface allows users to configure and arrange workflows for machine learning analysis, data profiling and other data science analytics tasks easily.

In this lab, we will deploy **JupyterLab** to Oracle Container for Kubernetes Engine and create a simple notebook to analyze data in **MySQL HeatWave**.

**Oracle Container Engine for Kubernetes (OKE)** is an Oracle-managed container orchestration service that can reduce the time and cost to build modern cloud-native applications. Unlike most other vendors, Oracle Cloud Infrastructure provides Container Engine for Kubernetes as a free service that runs on higher-performance, lower-cost compute shapes.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Create a Kubernetes namespace for Jupyter
* Deploy Jupyter notebook to OKE
* Analyze data in MySQL HeatWave

### Prerequisites

* You have an Oracle account
* You have enough privileges to use OCI
* OCI Resource required: HOL-compartment, OKE Cluster, MySQL HeatWave

## Task 1: Verify OKE cluster

1. Click the **Hamburger Menu** ![](images/hamburger.png) in the upper left, navigate to **Developer Services** and select **Kubernetes Cluster (OKE)**

    ![Navigate to OKE](images/navigate-to-oke.png)

2. Select the Compartment (e.g. HOL-Compartment) that you provisioned the OKE cluster, and verify the status of **oke_cluster** is **Active**

    ![Verify OKE](images/click-cluster.png)

## Task 2: Deploy Jupyter to OKE

1. Connect to the **oke-operator** compute instance using OCI Cloud Shell

	![Connect to VM](images/connect-to-vm.png)

2. Install the helm client

	>**Note** Skip this step if you have installed helm client
	
	```
<copy>
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 |bash -
</copy>
```

3. Create the namespace in OKE

	```
<copy>
kubectl create ns jhub
</copy>
```

4. Add Jupyter repository using helm

	```
<copy>
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
</copy>
```
	```
<copy>
helm repo update
</copy>
```

5. Install Jupyter using helm

	```
<copy>
helm upgrade --install jhub jupyterhub/jupyterhub --namespace jhub
</copy>
```

	> **Note** JupyterHub is a multi-user environment to host the Jupyter notebook. By default, the helm will install the latest stable version of JupyterHub with the classic Jupyter notebook UI. If you want to try out the latest JupyterLab notebook, specify the development release of JupyterHub using the specific version <a href="https://jupyterhub.github.io/helm-chart/", target="\_black">helm version</a> as shown in the following example:
	```
	<copy>
	helm upgrade --install jhub jupyterhub/jupyterhub --namespace jhub --version=1.1.3-n410.hd8ae7348
	</copy>
	```

6. Retrieve the public IP of the deployed Jupyter notebook

	```
<copy>
kubectl -n jhub get svc proxy-public -o jsonpath='{.status.loadBalancer.ingress[].ip}'
</copy>
```

7. Access the deployed Jupyter application using your browser, http:://&lt;Jupyter&#95;Proxy&#95;PUBLIC&#95;IP&gt;/.

	Enter **admin/admin** to log into Jupyter notebook

	![Jupyter Login](images/jupyter-login.png)

	>Note: When you login to Jupyter for the first time, you will need to wait for Jupyter to complete a few setup task before you can start using it

## Task 3: Connect Jupyter to MySQL HeatWave

1. Open a new terminal in Jupyter

	![jupyter terminal](images/jupyter-terminal.png)

2. Install the MySQL connector for Python using pip

	```
<copy>
pip3 install mysql-connector-python
</copy>
```
	![install mysql connector](images/import-mysql-connector.png)

3. Install the iPython-sql modules

	```
<copy>
pip3 install ipython-sql
</copy>
```
	![install ipython-sql](images/install-ipython-sql.png)

4. Install the pymysql modules

	```
<copy>
pip3 install pymysql
</copy>
```
	![install pymysql](images/install-pymysql.png)

	Click on the top left corner **jupyterhub** to go back to home page

5. Create a new notebook

	Click on File, New Launcher

	![New launcher](images/jupyter-new-launcher.png)

	Click on Notebook

	![New notebook](images/jupyter-new-notebook.png)

6. Execute SQL codes

	```sql
<copy>
%load_ext sql
</copy>
```
	
	```sql
<copy>
%sql mysql+pysql://admin:<password>@<mysql_private_ip>/airportdb
</copy>
```

	```sql
<copy>
%sql select * from airport limit 10
</copy>
```

	```sql
<copy>
%sql select airline.airlinename, count(*) as nb_people from booking, flight, airline, passengerdetails \
where booking.flight_id=flight.flight_id and \
airline.airline_id=flight.airline_id and \
booking.passenger_id=passengerdetails.passenger_id and \
country in ("SWITZERLAND", "FRANCE", "ITALY") \
group by \
airline.airlinename \
order by \
airline.airlinename, nb_people \
limit 10;
</copy>
```
	![Execute SQL](images/jupyter-sql.png)

6. [Optional] Another way to access MySQL HeatWave using python

	```
<copy>
db = mysql.connector.connect(
   host="10.0.30.97",
   user="admin",
   passwd="<password>"
)
print(db)
</copy>
```

	You may now **proceed to the next lab.**

## Acknowledgements

* **Author**
	* Ivan Ma, MySQL Solutions Engineer, MySQL Asia Pacific
	* Ryan Kuan, MySQL Cloud Engineer, MySQL Asia Pacific
* **Contributors**
	* Perside Foster, MySQL Solution Engineering North America
	* Rayes Huang, OCI Solution Specialist, OCI Asia Pacific

* **Last Updated By/Date** - Ryan Kuan, May 2022