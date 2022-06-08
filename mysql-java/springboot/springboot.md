# Run Spring Boot in Kubernetes

## Introduction

In this lab, we include run the same Java code to get data from MySQL in Spring Boot. Then run this program in Kubernetes.

Estimated Time: 20 minutes

### About Spring Boot
Spring Boot is a simple framework to run Java programs that includes a Webserver.

It is a production-grade Spring-based Applications that you can "just run". It is preconfigured with the Spring team's "opinionated view" of the best configuration and use of the Spring platform and third-party libraries so you can get started with minimum fuss. 

### Objectives

In this lab, you will:
* Create a Spring Boot program
* Upload the container to the Kubernetes Registry
* Run the Java container in OKE
* Configure secret and configMap to remove hardcoded value from the program

### Prerequisites

This lab assumes you have:
* Followed the previous labs

## Task 1: Environment variables

First, let's finish the Kubernetes setup.

Edit the file bin/env.sh to match your Oracle Cloud connection details.

```
<copy>cd oke_mysql_java_101/bin
cp env.sh.example env.sh
vi env.sh
</copy>
```
```
OCI_REGION=fra.ocir.io
OCI_NAMESPACE=frabcdefghjij
OCI_EMAIL=marc.gueury@oracle.com
OCI_USERNAME=oracleidentitycloudservice/marc.gueury@oracle.com
OCI_TOKEN="this_isAToken!"
```

- OCI_REGION: check the list [here] (https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registryprerequisites.htm)
- OCI USERNAME / OCI TOKEN: Follow the documentation to generate a Token [https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrypushingimagesusingthedockercli.htm] (https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrypushingimagesusingthedockercli.htm)
- OCI_NAMESPACE: See the doc above. A good idea is also to do this:
    - Go the OCI menu / Developers / Container Registry 
    - You will see the namespace in the middle of the screen

When all the environment variables are set, create the registry secret to allow Kubernetes to pull the image from the container registry

```
<copy>./create_registy_secret.sh
</copy>
```

## Task 2: Spring Boot - Hardcoded values

In this demo too, the DB details are hardcoded. 
1. If you are running MySQL database service, you will use the Private IP of MySQL
2. If you are running MySQL in Kubernetes, you will use the Kubernetes service name for MySQL ( named simply "mysql" in the sample above)  

To modify them:

```
<copy>cd oke_mysql_java_101/demo2/v1
vi src/main/java/com/mysql/web/basic/BasicController.java
</copy>
````
Replace
```
  private String DB_URL = "jdbc:mysql://10.1.1.237/db1?user=root&password=Welcome1!";
```
By
```
   1. private String DB_URL = "jdbc:mysql://&lt;mysql ip address&gt;/db1?user=root&password=Welcome1!";
or 2. private String DB_URL = "jdbc:mysql://mysql/db1?user=root&password=Welcome1!";
```

Then we need also to change the kubernetes yaml file 

```
<copy>vi webquerydb1.yaml 
</copy>
```
Replace
```
        image: fra.ocir.io/fr03kzmuvhtf/marc/webquerydb:v1
```
with the same value used in the environment variables above
```
        image: &lt;OCI_REGION&gt;/&lt;OCI_NAMESPACE&gt;/marc/webquerydb:v1
```

## Task 3: Spring Boot - Build and run



Then build the docker image, push it to the registry and run it,
```
<copy>bin/build.sh
bin/push.sh
kubectl apply -f webquerydb1.yaml 
kubectl get pods | grep webquerydb
kubectl get service webquerydb-service
</copy>
```
```
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
webquerydb-service   LoadBalancer   10.96.105.230   123.123.123.123   80:32114/TCP   18d

```
Here you will get the EXTERNAL-IP of the service. Then use it to test
```
<copy>curl http://123.123.123.123/query
</copy>
```

You will see
```
1:DOLPHIN 2:TIGER 3:PENGUIN 4:LION
```

## Task 4: Spring Boot - configMap and secrets

In this demo, the DB details are stored in Kubernetes configMap or secrets.

```
<copy>cd ../v2
cat bin/config.sh
</copy>
```
```
<copy>kubectl create secret generic db-secret --from-literal=username=root --from-literal=password=Welcome1!
kubectl apply -f webquerydb-cfg.yaml
</copy>
```

We need to do the same change than above. Replace with your address MySQL IP or Kubernetes service name. 
```
<copy>vi webquerydb-cfg.yaml
</copy>
```
```
...
    {
      "webquerydb.db.url": "jdbc:mysql://10.1.1.237/db1"
    }
...
1. "webquerydb.db.url": "jdbc:mysql://&lt;mysql ip address&gt;/db1"
or  2. "webquerydb.db.url": "jdbc:mysql://mysql/db1"
```

Then we need also to change the kubernetes yaml file 

```
<copy>vi webquerydb2.yaml
</copy>
```
Replace
```
        image: fra.ocir.io/fr03kzmuvhtf/marc/webquerydb:v1
```
with the same value used in the environment variables above
```
        image: &lt;OCI_REGION&gt;/&lt;OCI_NAMESPACE&gt;/marc/webquerydb:v1
```


Then rebuild the program, docker image and deploy it in Kubernetes

```
<copy>bin/config.sh
bin/build.sh
bin/push.sh
kubectl apply -f webquerydb2.yaml
</copy>
```
Same EXTERNAL IP than above
```
<copy>curl http://123.123.123.123/query
</copy>
```

You will see
```
1:DOLPHIN 2:TIGER 3:PENGUIN 4:LION
```

If you reach this point, CONGRATULATION !! You have a MySQL database, a Spring Boot application in Java running in Kubernetes using configMap and secrets.

## Known issues

#### demo 2 v1 or v2 compilation fails

```
Caused by: java.lang.IllegalArgumentException: invalid target release: 11
    at com.sun.tools.javac.main.OptionHelper$GrumpyHelper.error (OptionHelper.java:103)
    at com.sun.tools.javac.main.Option$12.process (Option.java:216)
    at com.sun.tools.javac.api.JavacTool.processOptions (JavacTool.java:217)
    at com.sun.tools.javac.api.JavacTool.getTask (JavacTool.java:156)
    at com.sun.tools.javac.api.JavacTool.getTask (JavacTool.java:107)
```

- Cause: you are using JDK8. 
- WA: edit pom.xml 
  - OLD: <java.version>11</java.version>  
  - NEW: <java.version>8</java.version>

## Tricks

### Connect to MySQL Database System from kubectl

Connect to it through a kubernetes mysql-client
```
<copy>kubectl run -it --rm --image=mysql --restart=Never mysql-client -- mysql -h10.1.1.237 -uroot -pWelcome1!
# Press enter to see the prompt
exit
</copy>
```

### Forward the port of MySQL Database System to localhost

Do not forget to change your IP address
```
<copy>
kubectl run --restart=Never --image=alpine/socat mysql-jump-server -- -d -d tcp-listen:3306,fork,reuseaddr tcp-connect:10.1.1.237:3306
kubectl wait --for=condition=Ready pod/mysql-jump-server
kubectl port-forward pod/mysql-jump-server 3306:3306 &
mysql -h127.0.0.1 -uroot -pWelcome1!
exit
</copy> 
```

## Acknowledgements
* Marc Gueury - Application Development EMEA
* Stuart Davey - MySQL EMEA
* Mario Beck - MySQL EMEA
* Olivier Dasini - MySQL EMEA
* Last Updated - Feb 2022
