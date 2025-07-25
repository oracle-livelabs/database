# Introduction

## About this Workshop

This workshop offers a deep dive into building intelligent, AI-agentic workflows using Oracle® Transaction Manager for Microservices (MicroTx) Workflow, focused on a practical loan application processing use case.

The session introduces a novel architecture where a planner system task, powered by a Large Language Model (LLM), dynamically determines the flow of execution across multiple specialized AI agents (e.g., KYC, credit scoring, risk evaluation), and ensure consistency in financial operations through distributed transactions coordinated by MicroTx. Participants will build this orchestration end-to-end using JSON, Java, MicroTx Workflow Engine, using a modular agent-based design. This session will equip participants with the ability to define, configure, and execute AI-enhanced workflows in real-world scenarios with dynamic control flow, decision-making, and integration.

In this workshop, participants will learn how to create intelligent, AI-agentic workflows using JSON and orchestrated using MicroTx Workflow, with a specific focus on a loan application processing use case. Attendees will use a planner system task, powered by a Large Language Model (LLM), which dynamically determines the execution sequence of multiple agent-based tasks. Upon loan approval, the workflow culminates in a loan disbursement step that is executed as a distributed transaction coordinated by MicroTx, ensuring atomicity and consistency across distributed system boundaries.

Estimated Workshop Time: 1 hour 30 minutes

### Objectives

In this workshop, you will learn how to:

* Model and orchestrate agentic workflows for production-grade use cases

* Use a planner system task that uses LLMs for real-time decision-making

* Build modular agent workers in Java (e.g., KYC Agent, Credit Agent)

* Combine AI and orchestration to improve flexibility, automation, and control in business processes

* Configure and execute distributed transactions with MicroTx

This workshop is ideal for anyone building AI-driven agentic workflows with strict reliability and transactional guarantees in Java-based microservices environments.

Watch the video for more information about [Oracle Transaction Manager for Microservices (MicroTx)](youtube:4j74C4GobzY).

### Prerequisites

This lab assumes you have:
* An Oracle account
* At least 4 OCPUs, 24 GB memory, and 128 GB of bootable storage volume or more is available in your Oracle Cloud Infrastructure tenancy.

## Learn More

* [Oracle® Transaction Manager for Microservices Installation and Configuration Guide](https://docs.oracle.com/pls/topic/lookup?ctx=microtx-latest&id=TMMDG)
* [Oracle® Transaction Manager for Microservices Developer Guide](hhttps://docs.oracle.com/pls/topic/lookup?ctx=microtx-latest&id=TMMDV)

## Acknowledgements
* **Author** - Sylaja Kannan, Consulting User Assistance Developer
* **Contributors** -  Brijesh Kumar Deo and Bharath MC
* **Last Updated By/Date** - Sylaja Kannan, September 2025