# Creating dynamic group to access streams/objects

### Introduction

In this lab we will create the dynamic group

_Estimated Lab Time_: 5 minutes

### Objectives
In this lab, you will:
- Create Dynamic Group
- Create Policies

##  
## Task 1 Create Dynamic Group

1. Open the navigation menu and click ***Domains***

    ![Domain Navigation](./images/dg_navigation.png)

2. Click on ***Default***(Current Domain)
    
    ![OCI Default Domain](./images/default_domain.png)

3. Click on ***Dynamic Group*** -> ***Create dynamic group***:
    
    ![OCI Stream console](./images/create_dg3.png)


4. Give Details as in following screen shot:


    ![Create Dynamic Group Details](./images/create_dg_matching_rule.png)

      ```
      <copy>
      ALL {resource.type = 'fnfunc', resource.compartment.id = 'ocid1.compartment.oc1……xyz’}
      </copy>

      ```

5. Open the navigation Menu -> Go to Identity -> Policies ->  Create Policy
    
    ![create_policies](./images/create_policy_1.png)

6. Click on Create Policy and give it name **function-dynamic-group**

    In following copy & Replace the OCID of compartment **e2e-demo-specialist-eng** 

    ```
    <copy>
    allow dynamic-group function-dynamic-group to manage stream-family in compartment id resource.compartment.id = ‘ocid1.compartment.oc1……xyz’
    allow dynamic-group function-dynamic-group to manage stream-pull in compartment id resource.compartment.id = ‘ocid1.compartment.oc1……xyz’
    allow dynamic-group function-dynamic-group to manage streams in compartment id resource.compartment.id = ‘ocid1.compartment.oc1……xyz’
    allow dynamic-group function-dynamic-group to manage stream-pools in compartment id resource.compartment.id = ‘ocid1.compartment.oc1……xyz’
    allow dynamic-group function-dynamic-group to manage objects in compartment id resource.compartment.id = ‘ocid1.compartment.oc1……xyz’
    </copy>
    ```

    Above Create Policy should like as in following screen shots:

    ![create_policies_allow](./images/create_policy_builder.png)

7. Now you should see **function-dynamic-group** has been created

    ![allow-dynamic-group](./images/allow_dg_to_manage.png)

You may now **proceed to the next lab**

## Acknowledgements
* **Author** - Bhushan Arora, Principal Cloud Architect, North America Cloud Infrastructure - Engineering
* **Contributors** -  Biswanath Nanda, Master Principal Cloud Architect,Bhushan Arora ,Principal Cloud Architect, Lovelesh Saxena, Principal Cloud Architect
* **Last Updated By/Date** - Bhushan Arora, November 2024