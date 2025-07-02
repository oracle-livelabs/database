# Build and Deploy the custom Machine learning model to evaluate the probablity of asset failure

![Data Science](images/ds-banner.jpg)

### Introduction

In this task, we will be using already created compute instance and will be using the training data set 
to build and Deploy a predictive ML model on OCI platform which will identify the probablity of failure of a sensor device . The ML API URL once generated will be used by the Fn function code to evaluate the probablity of device when exposed to Live sensor datasets from stereaming layer .


_Estimated Lab Time_: 30 Minutes

### Objectives

In this section, you will:


- Build and Deploy a custom ML model on Compute VM to evaluate the device failure probability.


### Prerequisites

- All previous sections have been successfully completed.

##  
## Task 1: Open the port

1. Login to your same compute machine as opc, which we created earlier:

      ```
      <copy> sudo firewall-cmd --zone=public --add-port=5000/tcp --permanent </copy>
      ```


2. Check the python version:

      ```
      <copy> python3 --version </copy>
      ```
      Output: Python 3.8.17
      

3. Install the pip

      ```
       <copy> sudo dnf install python3-pip  </copy>
      ```
 
4. Install virtualenv

      ```
      <copy> pip install virtualenv  </copy>
      ```

## Task 2: Create Virtual Environment and Install Dependencies

1. Create a Virtual Environment

      ```
      <copy> virtualenv datasciecne_venv  </copy>
      ```
2. Activate the Virtual Environment

      ```
      <copy> source datasciecne_venv/bin/activate  </copy>
      ```

3. Installing Required Packages

      ```
      <copy> pip install flask pandas scikit-learn joblib  </copy>
      ```

4. Creating a Directory

      ```
      <copy> mkdir /home/opc/model </copy>
      ```
5. Changing to the New Directory

      ```
      <copy> cd /home/opc/model </copy>
      ```
6.  Download the Lab Files and scp the files(devices.csv & model_deployement.py) from Lab3 to /home/opc/model 

      ```
      <copy> ls </copy>
      ```
   
   output :
         
         devices.csv  model_deployement.py

7.  Now run the ML code in virtual environment and keep this running in the terminal:

      ```
      <copy> python3 model_deployement.py  </copy>
      ```
8. ML Endpoint URL : Copy the generated ML Model API endpoint which will be used in the Fn code.
   
      ```
      <copy> http://<compute-VM-IP>:5000/predict  </copy>
      ```
You may now **proceed to the next lab**
## Acknowledgements
* **Author** - Biswanath Nanda, Principal Cloud Architect, North America Cloud Infrastructure - Engineering
* **Contributors** -  Biswanath Nanda, Principal Cloud Architect,Bhushan Arora ,Principal Cloud Architect,Sharmistha das ,Master Principal Cloud Architect,North America Cloud Infrastructure - Engineering
* **Last Updated By/Date** - Biswanath Nanda, November 2024