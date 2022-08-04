# Deploy phpMyAdmin

## Introduction

In this lab, we will deploy a very popular open-source tool, <a href="https://www.phpmyadmin.net/", target="\_blank">phpMyAdmin</a> to OKE to manage MySQL HeatWave

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Create a Kubernetes namespace for phpMyAdmin
* Deploy phpMyAdmin to OKE
* Manage MySQL using phpMyAdmin

### Prerequisites (Optional)

* You have an Oracle account
* You have enough privileges to use OCI
* You have one Compute instance having <a href="https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-install.html" target="\_blank">**MySQL Shell**</a> installed on it

## Task 1: Verify OKE cluster

1. Click the **Hamburger Menu** in the upper left, navigate to **Developer Services** and select **Kubernetes Cluster (OKE)**

    ![Navigate to OKE](images/navigate-to-oke.png)

2. Select the Compartment (e.g. HOL-Compartment) that you provisioned the OKE cluster, and verify that the status of OKE cluster 'oke_cluster' is Active

    ![Locate OKE](images/locate-oke-instance.png)

3. Click 'oke_cluster' to view the status of the OKE cluster and the worker nodes in your OKE cluster

    ![Verify OKE](images/oke-worker-nodes.png)

## Task 2: Deploy PhpMyAdmin to OKE

1. Connect to the **oke-operator** compute instance using OCI Cloud Shell

2. Create the phpMyAdmin yaml deployment script

	```
	<copy>
	cat <<EOF >> phpmyadmin.yaml
	apiVersion: v1
	kind: Pod
	metadata:
		name: phpmyadmin
		labels:
		app: phpmyadmin
	spec:
		containers:
		- name: phpmyadmin
			image: phpmyadmin/phpmyadmin
			env:
			- name: PMA_HOST
				value: "MYSQL_HOST"
			- name: PMA_PORT
				value: "3306"
			ports:
			- containerPort: 80
				name: phpmyadmin
	---
	apiVersion: v1
	kind: Service
	metadata:
		labels:
		app: phpmyadmin-svc
		name: phpmyadmin-svc
	spec:
		ports:
		- port: 80
		targetPort: 80
		selector:
		app: phpmyadmin
	EOF
	</copy>
	```

3. Specify your MySQL private IP address in the yaml file, replace **MYSQL_IP_ADDRESS** with your MySQL Private IP Address. For example, if your MySQL Private IP address is 10.0.30.11, then the sed command will be "sed -i -e 's/MYSQL_HOST/10.0.30.11/g' phpmyadmin.yaml"

	```
	<copy>
	sed -i -e 's/MYSQL_HOST/<MYSQL_IP_ADDRESS>/g' phpmyadmin.yaml 
	</copy>
	```

4. Create a phpmyadmin namespace in OKE

	```
	<copy>
	kubectl create ns phpmyadmin
	</copy>
	```

5. Create the phpmyadmin service

	```
	<copy>
	kubectl apply -f phpmyadmin.yaml -n phpmyadmin
	</copy>
	```

6. Create the phpmyadmin ingress service

	```
	<copy>
	cat <<EOF | kubectl apply -n phpmyadmin -f -
	apiVersion: networking.k8s.io/v1
	kind: Ingress
	metadata:
		name: phpmyadmin-ing
		annotations:
		nginx.ingress.kubernetes.io/rewrite-target: /$2
		nginx.ingress.kubernetes.io/app-root: /phpmyadmin/
		nginx.ingress.kubernetes.io/configuration-snippet: |
			rewrite ^/themes/(.*)$ /phpmyadmin/themes/$1 redirect;
			rewrite ^/index.php(.*)$ /phpmyadmin/index.php$1 redirect;
			rewrite ^/config/(.*)$ /phpmyadmin/config/$1 redirect;
	spec:
		ingressClassName: nginx
		rules:
		- http:
			paths:
			- path: /phpmyadmin(/|$)(.*)
				pathType: Prefix
				backend:
				service:
					name: phpmyadmin-svc
					port:
					number: 80
			- path: /index.php(.*)
				pathType: Prefix
				backend:
				service:
					name: phpmyadmin-svc
					port:
					number: 80
	EOF
	</copy>
	```

7. Find out the public IP of OKE Ingress Controller

	```
	<copy>
	kubectl get all -n ingress-nginx
	</copy>
	```
	![Ingress IP](images/ingress.png)

8. Access the deployed PhpMyAdmin application using your browser, http:://&lt;LOAD&#95;BALANCER&#95;PUBLIC&#95;IP&gt;/phpmyadmin

	![PhpMyAdmin](images/phpmyadmin.png)

  You may now **proceed to the next lab.**

* **Author**
	* Ivan Ma, MySQL Solution Engineer, MySQL APAC
	* Ryan Kuan, MySQL Cloud Engineer, MySQL APAC
* **Contributors**
	* Perside Foster, MySQL Solution Engineering
	* Rayes Huang, OCI Solution Specialist, OCI APAC

* **Last Updated By/Date** - Ryan Kuan, March 2022
