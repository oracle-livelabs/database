# Introduction

## The Language-to-Report Foundation

Get ready to set up Oracle Trusted Answer Search. Enterprises need natural-language access to data but cannot accept the "guesswork" of generic chatbots. This purpose-built system routes natural-language questions to a constrained set of curated descriptions tied to vetted reports and actions. Unlike LLM-based RAG interfaces that can hallucinate or introduce randomness, this system delivers deterministic outcomes by returning **match documents (JSON)** instead of free-form generated text.

**Estimated time:** 5 minutes.

### Objectives
* Understand the "language-to-report" mapping architecture.
* Prepare to deploy the platform on **Oracle AI Database 26ai**.
* Learn to configure search targets and parameter extraction.
* Understand how to integrate search capabilities using APIs and widgets.

## Task 1: Understand the Core Mapping Concept

Traditional LLMs are pattern-matching engines rather than truth engines, making them unreliable for bounded application-specific questions. Trusted Answer Search addresses this by using **AI Vector Search** to find the best matching report based on report descriptions, ensuring that the application remains in control of the final output. This architecture provides faster access to the right report while maintaining a better security posture by keeping answers within governed environments.

## Task 2: Review the Deployment Architecture

The system is designed to run natively within the **Oracle AI Database 26ai**, leveraging its ability to unify searches across AI vectors and traditional relational data. Deployment involves installing two primary **APEX applications**—one for administration and one for end users—and utilizing a **Javascript search widget** or a **PL/SQL API** for integration into your custom web applications. This multi-layered approach allows for continuous improvement through human feedback and structured change management.

You may now **proceed to the next lab**.

## Acknowledgements

**Authors** 

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - March, 2026
