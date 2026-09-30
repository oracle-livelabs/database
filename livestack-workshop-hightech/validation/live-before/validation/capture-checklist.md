# HighTech capture checklist

These are outstanding authentic captures. No HighTech database or application execution is claimed. Source images are preserved under `validation/source-captures/`; do not relabel them.

After database access and phase authorization are supplied, run the loader on a fresh schema, execute the labs in sequence, verify the results, and replace each image beside its matching instruction. The six separate application views also require a HighTech application, which is not included in the source stack.

| Lesson | Instruction | Required capture |
| --- | --- | --- |
| production-operations-dashboard | Task 1: Run a converged production investigation | `production-operations-dashboard/images/sql-dashboard.png` |
| production-operations-dashboard | Task 2: Change the investigation question | `production-operations-dashboard/images/sql-dashboard-followup.png` |
| production-operations-dashboard | Application example | `production-operations-dashboard/images/demo-dashboard.jpg` |
| production-operations-dashboard | Application example | `production-operations-dashboard/images/demo-dashboard-charts.jpg` |
| quality-review-oml | Task 1: Read the training data | `quality-review-oml/images/sql-oml-training.png` |
| quality-review-oml | Task 2: Compare models with AutoML (optional) | `quality-review-oml/images/oml-settings.png` |
| quality-review-oml | Task 2: Compare models with AutoML (optional) | `quality-review-oml/images/oml-leaderboard.png` |
| quality-review-oml | Task 2: Compare models with AutoML (optional) | `quality-review-oml/images/oml-model-comparison.png` |
| quality-review-oml | Task 2: Compare models with AutoML (optional) | `quality-review-oml/images/oml-confusion-matrix.png` |
| quality-review-oml | Task 2: Compare models with AutoML (optional) | `quality-review-oml/images/oml-prediction-impact.png` |
| quality-review-oml | Task 4: Score new component inspection measurements in SQL | `quality-review-oml/images/sql-oml-scoring.png` |
| production-order-duality | Task 3: Read a customer site document from relational data | `production-order-duality/images/sql-duality-document.png` |
| production-order-duality | Task 5: Create and update a JSON production order | `production-order-duality/images/sql-duality-released.png` |
| production-order-duality | Task 6: Project JSON fields with SQL | `production-order-duality/images/sql-duality-projection.png` |
| production-order-duality | Task 6: Project JSON fields with SQL | `production-order-duality/images/sql-duality-relational.png` |
| plant-routing-spatial | Introduction | `plant-routing-spatial/images/demo-spatial-map.jpg` |
| plant-routing-spatial | Task 1: Look at the locations as points | `plant-routing-spatial/images/sql-spatial-points.png` |
| plant-routing-spatial | Task 2: Find the closest plants to a demand region | `plant-routing-spatial/images/sql-spatial-new-york.png` |
| plant-routing-spatial | Task 2: Find the closest plants to a demand region | `plant-routing-spatial/images/sql-spatial-chicago.png` |
| plant-routing-spatial | Task 3: Route customer sites to the closest plant | `plant-routing-spatial/images/sql-spatial-routing.png` |
| selectai-agent | Task 4: Run a HighTech question | `selectai-agent/images/sql-agent-answer.png` |
| selectai-agent | Task 5: Inspect what the agent did | `selectai-agent/images/sql-agent-history.png` |
| selectai-agent | Task 5: Inspect what the agent did | `selectai-agent/images/sql-agent-tools.png` |
| selectai | Task 3: Ask a question and inspect the SQL | `selectai/images/sql-ai-generated.png` |
| selectai | Task 4: Run the question in the database | `selectai/images/sql-ai-answer.png` |
| selectai | Task 5: Improve the business question | `selectai/images/sql-ai-refined-generated.png` |
| selectai | Task 5: Improve the business question | `selectai/images/sql-ai-refined-answer.png` |
| selectai | Task 6: Explain the result | `selectai/images/sql-ai-narration.png` |
| production-quality-network | Introduction | `production-quality-network/images/demo-network-overview.jpg` |
| production-quality-network | Introduction | `production-quality-network/images/demo-network-query.jpg` |
| production-quality-network | Task 2: Read the same connections as a graph | `production-quality-network/images/sql-graph-direct.png` |
| production-quality-network | Task 3: Trace four-hop quality traceability | `production-quality-network/images/sql-graph-four-hop.png` |
| production-quality-network | Task 4: Find production orders that share traceability records | `production-quality-network/images/sql-graph-shared.png` |
| production-quality-network | Task 6: Download and import the HighTech notebook | `production-quality-network/images/graph-notebooks.png` |
| production-quality-network | Task 6: Download and import the HighTech notebook | `production-quality-network/images/graph-import-file.png` |
| production-quality-network | Task 7: Run and interpret the Graph Studio notebook | `production-quality-network/images/graph-notebook-top.png` |
| production-quality-network | Task 7: Run and interpret the Graph Studio notebook | `production-quality-network/images/live-09-graph-notebook-table.png` |
| production-quality-network | Task 7: Run and interpret the Graph Studio notebook | `production-quality-network/images/live-10-graph-production-network.png` |
| production-quality-network | Task 7: Run and interpret the Graph Studio notebook | `production-quality-network/images/live-11-graph-shared-lot.png` |
| component-quality-vector-search | Task 2: Create a component vector | `component-quality-vector-search/images/sql-vector-values.png` |
| component-quality-vector-search | Task 3: Test the component vector | `component-quality-vector-search/images/sql-vector-distance.png` |
| component-quality-vector-search | Task 3: Test the component vector | `component-quality-vector-search/images/sql-vector-similarity.png` |
| component-quality-vector-search | Task 4: Find customer sites affected by a component concern | `component-quality-vector-search/images/sql-vector-customer-sites.png` |
| introduction | Running the manufacturing demo | `introduction/images/demo-welcome.jpg` |

## Live validation still required

- Fresh SQLcl loader invocation, prerequisites, model loading, vectors, geometry and graph assertions.
- All nine labs and Getting Started in sequence, including reruns and cleanup.
- Graph Studio import, all three primary notebook SQL paragraphs, and optional PGX setup and algorithms.
- AutoML, SQL GLM creation/scoring, Select AI generated SQL/results, agent execution history and model restoration.
- Actual LiveLabs green-button provisioning and reservation/login flow, including the deployed quiz.
- HighTech application source/environment and six application captures. No app server was present in the supplied source.
