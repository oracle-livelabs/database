# Introduction to Trusted Answer Search

## Introduction
Welcome to this 4-part workshop series. This workshop will guide you through setting up **Oracle Trusted Answer Search**, and demonstrate how enterprise can build Trust into their systems while leveraging the latest and great in Vector Databases.

**Estimated Workshop Time:** 60 minutes.

### Objectives
* Understand the "language-to-report" mapping architecture.
* Prepare to deploy the platform on **Oracle AI Database 23ai or 26ai**.
* Learn to configure search targets and parameter extraction.
* Understand how to integrate search capabilities using APIs and widgets.

## Task 1: Understand the Core Mapping Concept

Traditional LLMs are pattern-matching engines rather than truth engines, making them unreliable for bounded application-specific questions. Trusted Answer Search addresses this by using **AI Vector Search** to find the best matching report based on curated descriptions, ensuring the application remains in control of the final output. This architecture provides faster access to the right report while maintaining a strict security posture by keeping answers within governed environments.

## Task 2: Review the Deployment Architecture

The system runs natively within the **Oracle AI Database**, utilizing **TRUSTED_SEARCH** as the core schema for PL/SQL packages and dictionary tables. Deployment consists of three phases: installing the backend via shell scripts, setting up an **Oracle APEX** workspace, and importing the Admin and Portal applications. This multi-layered approach allows for continuous improvement through human feedback and structured change management.

You may now **proceed to the next lab**

## Acknowledgements

**Authors** 

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - April, 2026
