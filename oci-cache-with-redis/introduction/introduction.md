# Introduction

## About this Workshop

Welcome to the OCI Redis Cache LiveLab! In this hands-on workshop, we will explore an advanced solution to enhance the performance of a web application that generates pull data stored in Oracle Autonomous Transaction Processing (ATP).

Enquiring records from large datasets and executing complex queries on database can be resource-intensive and time-consuming. To address this challenge, we introduce a powerful solution – leveraging Redis as a caching layer. By caching frequently accessed reports or data in a Redis cluster, we aim to significantly reduce load times, optimize query response times, and ultimately enhance the overall user experience.

Imagine a scenario where you have a web application deployed on a virtual machine (VM). This application retrieves taxi trip data from Oracle ATP and show it online. However, to overcome the potential delays associated with querying ATP directly, we'll implement a Redis cluster to efficiently cache frequently requested data.

Estimated Workshop Time: 2 hours

## Objectives

In this workshop, you will learn how to:
* Set up and configure a Flask application on a VM
* Connect the Flask application to Oracle ATP for data retrieval
* Deploy a Redis cluster to cache frequently accessed data
* Integrate Redis into the Flask application for efficient caching
* Test the performance improvements achieved by Redis caching 

## Lab Breakdown

* **Lab 1:** Provision OCI services
* **Lab 2:** Load Data into ATP
* **Lab 3:** Setup & Deploy Flask Application in VM
* **Lab 4:** Run application and test the performance

## Prerequisites 

This lab assumes you have:
* Access to an Oracle Cloud Infrastructure (OCI) account
* Basic knowledge of Python and Flask
* Familiarity with Redis concepts 

## Learn More

* [About OCI Redis](https://docs.oracle.com/en-us/iaas/Content/redis/home.htm)
* [About OCI ATP](https://docs.oracle.com/en/cloud/paas/atp-cloud/index.html)

## Acknowledgements
* **Author** 
* Pavan Upadhyay, Principal Cloud Engineer, NACI 
* Saket Bihari, Principal Cloud Engineer, NACI
* **Last Updated By/Date** - Pavan Upadhyay, Saket Bihari, Feb 2024
