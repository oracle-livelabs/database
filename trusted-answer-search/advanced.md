# **Lab 4: Advanced Capabilities**

## Introduction

In this lab, you will explore how Trusted Answer Search interprets **structured intent from natural language**, using real Wikimedia analytics queries.

You will see how the system extracts parameters like:

* Time ranges
* Frequency (daily/monthly)
* Language and project

and converts them into structured inputs for reports.

**Estimated time:** 15 minutes.

### Objectives

* Understand parameter extraction from natural language queries.
* Observe how structured values are passed to reports.
* Explore current limitations and upcoming enhancements.
* See how this differs from chatbot-style systems.

---

## Task 1: Parameter Extraction Across Projects

1. Run:

   ```
   How has French Wiktionary readership changed by month over the last year?
   ```

This maps to: 

### Observe:

Extracted parameters:

* `language = fr`
* `project = wiktionary`
* `period = 1-year`
* `frequency = monthly`

The system understands:

* “French” → `fr`
* “Wiktionary” → project
* “last year” → `1-year`

---

## Task 2: Parameter Extraction Across Different Dimensions

Run:

```
Show daily unique-device counts for Japanese Wikibooks over the last month
```

### Observe:

* `language = ja`
* `project = wikibooks`
* `period = 1-month`
* `frequency = daily`

This shows:

* Multi-parameter extraction working together
* Structured interpretation, not text generation

---

## Task 3: Explore Synonyms and Value Mapping

Run:

```
Show page views for all Wikimedia projects over the past 24 months
```

### Observe:

* “past 24 months” → `period = 2-year` 

The system maps synonyms deterministically using value sets

---

## Task 4: Understand Current Limitations

Run:

```
Show page views for all Wikimedia projects this month
```

### Observe:

* “this month” may not resolve into exact dates

Today:

* Works with predefined value sets

Coming soon:

* LLM-powered **Named Entity Recognition (NER)**

  * “this month” → exact date range
  * “last quarter” → computed values

---

## Task 5: Deterministic Behavior

Run the same query multiple times:

```
Show total page views for Wikimedia Commons over the last 2 years
```

### Observe:

It's the same result every time:

* No randomness
* No hallucination
* No variation

---

## Task 6: Structured Output (Conceptual)

Behind the scenes, this query:

```
Show total page views for Wikimedia Commons over the last 2 years
```

Maps to a structured action like:

```json
{
  "target": "Total Page Views - Wikimedia Commons",
  "params": {
    "period": "2-year",
    "frequency": "monthly"
  }
}
```

The application then executes:

* A report URL
* With validated parameters

---

## Summary

In this lab, you observed that Trusted Answer Search:

* Extracts structured meaning from natural language
* Uses controlled vocabularies and mappings
* Produces deterministic, repeatable outcomes
* Avoids the unpredictability of generated responses

---

You have successfully completed the **Trusted Answer Search Live Lab**.

---

## Acknowledgements

**Authors**

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - April, 2026
