# Search regulatory and market signals

## Introduction

The Regulatory & Market Signals page searches risk and market text. You will inspect signal data and run vector-style queries that rank related financial products.

### Objectives

- Query regulatory and market signals.
- Connect signal routes to vector search structures.
- Use `VECTOR_DISTANCE` safely.
- Note model and embedding prerequisites.

Estimated Time: 11 minutes

## Task 1: Inspect signal routes

1. Find the signal routes in `api-map.md`.

    | Route | Purpose |
    | --- | --- |
    | `/api/social/posts` | Returns the signal feed |
    | `/api/social/viral` | Finds elevated signals |
    | `/api/social/semantic-search` | Runs semantic search behavior |
    | `/api/social/post-search` | Runs text search behavior |

## Task 2: Query signal records

1. Run a signal feed query.

    ```sql
    SELECT signal_id,
           source_name,
           risk_area,
           momentum_flag,
           virality_score
    FROM risk_signals_v
    ORDER BY virality_score DESC
    FETCH FIRST 10 ROWS ONLY;
    ```

    Sample result:

    | SIGNAL_ID | SOURCE_NAME | RISK_AREA | MOMENTUM_FLAG | VIRALITY_SCORE |
    | ---: | --- | --- | --- | ---: |
    | 203 | FINRA Watch | Fraud | mega_viral | 98 |
    | 118 | Branch Ops | Liquidity | viral | 93 |

## Task 3: Run a vector ranking pattern

1. Use vector distance to rank product matches.

    ```sql
    SELECT p.product_name,
           p.category,
           VECTOR_DISTANCE(
               pe.embedding,
               VECTOR_EMBEDDING(
                   ALL_MINILM_L12_V2
                   USING 'fraud alerts and suspicious payment activity' AS DATA
               ),
               COSINE
           ) AS distance
    FROM product_embeddings pe
    JOIN products p ON p.product_id = pe.product_id
    ORDER BY distance
    FETCH FIRST 5 ROWS ONLY;
    ```

    Lower distance means closer semantic match.

## Task 4: Check your work

1. Confirm that lower vector distance means a closer match.

2. Confirm that model loading requires an available ONNX model.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle LiveLabs, May 2026
