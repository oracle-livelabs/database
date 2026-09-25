# Final Quiz

## Introduction

Use this quiz to check your understanding of how the **Media LiveStack** uses **Oracle Database 26ai** to move from audience signal to trusted launch action. The questions should reinforce business outcomes and reviewer value, not product trivia.

### Objectives

- Review the Midnight Harbor operating story taught in the workshop.
- Match visible launch outcomes to the database capabilities behind them.
- Confirm that you can explain why governed evidence matters in media operations.

Estimated Time: **5 minutes**

```quiz-config
passing: 75
badge: images/livestack-media-badge.png
```

## Task 1: Check your understanding

1. Answer the following questions.

    ```quiz score
    Q: Why does the workshop start with the Media data foundation instead of the command center?
    - Because dashboards cannot run on relational data.
    * Because the later launch decisions only matter if the shared audience, content, and campaign evidence is already trusted.
    - Because vector search replaces the need for base tables.
    - Because the command center is only a static mockup.
    > The workshop begins by proving the current row groups, views, vectors, graph objects, and audit surfaces are present before the learner depends on later outputs.

    Q: What business outcome does JSON Relational Duality provide in the campaign-request lab?
    - It moves campaign requests into a separate document store.
    * It gives the app a JSON request document while preserving relational truth.
    - It hides relational request rows from the application team.
    - It replaces route context with a static payload export.
    > The same Media request supports relational SQL, JSON access, and route context without a second source of truth.

    Q: Why is AI Vector Search valuable in the audience-signal lab?
    - It only works when the asset name appears exactly in the signal text.
    * It matches content assets and audience signals by meaning, not only by exact wording.
    - It removes the need to keep audience text governed.
    - It replaces the semantic views with a keyword index.
    > Vector search helps launch teams connect natural-language pressure signals to affected content assets before the wording is standardized.

    Q: What makes the Property Graph lab useful to a media operations team from a launch-decision perspective?
    - It prevents multi-hop reasoning until the data is exported elsewhere.
    * It shows how creators, communities, studios, and campaigns connect across hops.
    - It turns creator relationships into disconnected row counts.
    - It hides platform and relationship types from the learner.
    > The graph lab matters because connected influence is more useful than isolated creator metrics.

    Q: How does Oracle Spatial change the rights-coverage decision?
    - It stores only launch maps for later presentation.
    * It combines geography, launch hubs, demand regions, and capacity in one queryable footprint.
    - It replaces capacity data with region names.
    - It forces the team to leave the database before they can compare markets.
    > Oracle Spatial keeps coverage and launch geography tied to the same operational data the business already trusts.

    Q: What is the most important lesson from the OML analytics lab?
    - Model names matter more than business interpretation.
    - Predictions only matter after export to notebooks.
    - Forecast quality should be hidden so learners do not question it.
    * Forecasts are useful when they stay connected to launch capacity, revenue, and retention decisions.
    > The lab shows that OML outputs matter because they stay connected to the operational evidence they are meant to guide.

    Q: What should a reviewer look for before trusting an Ask Seer Media Data answer?
    * Whether the answer maps to approved semantic views and visible query logic.
    - Whether the SQL path is hidden from the reviewer.
    - Whether the language model avoids media object names.
    - Whether the response ignores the live schema.
    > Trusted answers require readable metadata, approved objects, and an inspectable SQL path.

    Q: What separates a trusted agent action from a free-form AI response in this workshop?
    - The action avoids the database and answers from memory.
    * The action uses approved tools and leaves durable audit evidence.
    - The action deletes its own audit history after completion.
    - The action invents new tools at runtime when needed.
    > The trusted-action pattern depends on constrained tool use plus an auditable record of what happened.
    ```

## Acknowledgements

* **Author** - Oracle LiveLabs Team
* **Last Updated By/Date** - Oracle Database Product Management, June 2026
