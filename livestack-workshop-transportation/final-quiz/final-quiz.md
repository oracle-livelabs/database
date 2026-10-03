# Final Quiz

```quiz-config
passing: 75
badge: images/badge.png
```

## Introduction

Use this scored quiz to check how Seer Transport connects passenger service decisions to database evidence.

### Objectives

- Review the main Oracle AI Database capabilities used in the workshop.
- Earn the workshop badge by answering the scored questions.

Estimated Time: **3 minutes**

## Task 1: Answer the quiz questions

1. Complete the scored quiz.

    ```quiz score
    Q: What does JSON Relational Duality help Seer Transport do in the booking lab?
    - Copy booking documents into a separate document database.
    * Use the same booking data as JSON documents and relational rows without maintaining duplicate records.
    - Remove relational tables from the booking workflow.
    - Require analysts to read raw JSON for every review.
    > A duality view presents relational booking rows as a JSON document while SQL, keys, joins, and database controls continue to use the same source.

    Q: What does a vector similarity score help Gilly do?
    - Confirm that a disruption has already occurred.
    - Replace the service and booking tables with embeddings.
    * Rank transport services by how closely their descriptions match a search phrase.
    - Count rows in every transportation table.
    > The query turns vector distance into a similarity score, then joins matching services to precise booking and passenger records.

    Q: What question does Bob answer with a property graph?
    - Which service has the highest fare revenue?
    * Which trips are connected through routes, stations, vehicles, and disruption cases?
    - Which station is closest to a passenger home address?
    - Which model predicts a demand surge?
    > SQL/PGQ follows relationship paths without a separate chain of joins for each hop.

    Q: Why does Moon use Oracle Spatial in the station access lab?
    - To choose a station from its name alone.
    - To move location data to a separate map system.
    * To find passengers in a service region and compare nearby active stations with capacity information.
    - To replace geographic calculations with static labels.
    > Spatial functions test where passenger points fall and measure distance to station points. SQL adds station capacity and occupancy.

    Q: How should an operations analyst use the OML surge probability?
    - Treat it as a guaranteed future event.
    * Use it to rank services for review alongside demand and booking evidence.
    - Ignore the model inputs after scoring.
    - Interpret every score as a confirmed disruption.
    > A probability supports prioritization, but the team still checks the service activity behind the score.

    Q: What keeps a Select AI answer reviewable?
    - The AI model can query every table automatically.
    - The explanation is guaranteed to be identical each time.
    * The profile limits approved objects and Nina can inspect the generated SQL.
    - The answer comes only from general model knowledge.
    > Nina uses SHOWSQL before RUNSQL and compares the result with her business question.

    Q: What is the advantage of a converged database in this workshop?
    - Each capability needs a separate specialist database.
    * Relational, JSON, vector, graph, spatial, machine learning, and AI work with connected governed data.
    - Screenshots replace the need for database evidence.
    - Operations must reconcile copied data before every decision.
    > The labs use different capabilities over connected transportation records in Oracle AI Database.
    ```

2. When you achieve the passing score, the quiz displays your completion badge.

## Acknowledgements

* **Author** - Linda Foinding, Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, October 2026
