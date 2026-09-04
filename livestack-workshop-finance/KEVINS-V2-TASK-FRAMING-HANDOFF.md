# Kevin's V2 Updates: Task-Framing Improvement Handoff

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: TODO - x minutes


## Purpose

Improve the learner flow in the active Finance workshop so a beginner can understand the reason for each task before starting the numbered instructions. The opening prose should naturally explain the problem the team is solving, why this is the next step, which result matters, and how that result helps the person in the scenario. The learner should also understand what the team can do once the task or lab is complete.

The workshop already has stronger lab-level introductions, business scenarios, feature explanations, screenshots, and a named Seer Bank team. This pass closes the remaining gap between that opening context and each task's actual work.

## Scope and boundaries

Edit only learner-facing Markdown in the active manifest sequence:

- `finance-data-foundation/finance-data-foundation.md`
- `risk-operations-dashboard/risk-operations-dashboard.md`
- `transaction-case-duality/transaction-case-duality.md`
- `risk-signal-vector-search/risk-signal-vector-search.md`
- `financial-crime-network/financial-crime-network.md`
- `service-sla-spatial/service-sla-spatial.md`
- `predictive-risk-oml/predictive-risk-oml.md`
- `select-ai-finance-questions/select-ai-finance-questions.md`
- `select-ai-agent-risk-triage/select-ai-agent-risk-triage.md`

Do not change SQL, JSON notebooks, data loaders, database schema, image assets, manifests, quiz scoring, badges, or screenshots. Do not create a PR, commit, or push.

## Team continuity

Use the established named team consistently. Use the person’s name and role on first reference in a lab, then first name only.

| Person | Role | Main responsibility |
| --- | --- | --- |
| Jessica | Risk Analyst | Investigates risk signals and recommends review action. |
| Jordan | Database Administrator | Keeps the shared Oracle AI Database foundation ready, governed, and queryable. |
| Sam | Application Developer | Uses governed transaction data in application-friendly document form. |
| Priya | AI Engineer | Configures AI search, models, Select AI, and narrowly approved agent tools. |
| Maya | Service Operations Leader | Uses investigation findings, location, demand, and SLAs to plan response. |

Keep the beginner definition consistent: a **risk signal** is information that may need a closer look, such as an alert, a bulletin, unusual activity, or a service issue. It is not proof of fraud or harm. It is a prompt for investigation.

## Conversational task-framing pattern

Add a concise framing paragraph directly below a `## Task ...` heading and before the numbered steps. Write it as a natural continuation of the lab story, not as a checklist, callout, or set of labels. In two to four short sentences, let the learner know what the named person needs, why the team is doing this now, what they should look for in the result, and how it prepares the next decision.

Use this prose shape:

> [Person] needs to [business problem]. Because [connection to the preceding task or prerequisite], you now [run, open, or configure the artifact]. Look for [specific rows, columns, values, map layers, status, or history]. This gives [person] the evidence or control needed to [business outcome or next decision].

Use a shorter version when the existing task introduction already covers one or more of these ideas. Avoid restating the full feature definition in every task.

## Priority edits

These tasks need explicit framing first because they currently move most quickly into setup or SQL.

| File | Task | Needed framing |
| --- | --- | --- |
| `finance-data-foundation` | Task 1: Inventory object families | Jordan confirms the foundation before anyone relies on later results; inspect the object families and identify the capability each later lab needs. |
| `finance-data-foundation` | Task 2: Count data groups | Give the later dashboard, graph, vector, spatial, and model results scale; inspect counts and compare the data domains. |
| `risk-operations-dashboard` | Task 1: Calculate risk signal KPIs | Jessica needs an initial priority view; inspect total signals, average criticality, high-risk count, exposure, and open cases. |
| `risk-operations-dashboard` | Task 3: Find top product exposure | Move from individual signals to a product-level decision; inspect the highest-exposure product rows and explain why Jessica would begin there. |
| `financial-crime-network` | Task 1: Trace two-hop fraud reach | Jessica needs the first relationship map from a suspicious account; inspect reached entities, risk scores, and connection paths before looking for shared infrastructure. |
| `financial-crime-network` | Task 2: Find shared identifiers | Verify whether a suspicious pattern is isolated or shared; inspect the account pairs and shared device, IP, phone, or email values. |
| `service-sla-spatial` | Task 1: Calculate distance | Maya needs a measurable answer to which center is closest; inspect the ordered distance and the New York Metro boundary. |
| `service-sla-spatial` | Task 2: Summarize SLA zones | Convert location into response commitments; inspect zone type, count, and response-hour columns before opening the map. |
| `predictive-risk-oml` | Task 1: Inventory models | Priya must confirm which existing models are available before scoring them; inspect model name, mining function, and algorithm. |
| `select-ai-finance-questions` | Tasks 1–4 | Explain why the notebook, profile, AI-ready views, and approved object boundary are prerequisites for Jessica’s governed question. State what configuration or object list the learner should confirm. |
| `select-ai-agent-risk-triage` | Tasks 1–8 | Explain why every controlled component must exist and be verified before Jessica requests triage. Name the expected tool, function, agent, task, team, or history result to inspect. |

## Maintain and tighten existing strong transitions

Retain the existing business framing in these areas, but add only missing inspection or achievement language where needed:

- JSON Relational Duality Tasks 2–4
- Vector Search Tasks 1–2
- Graph Studio Tasks 3–5
- Spatial Studio Tasks 3–4
- OML Tasks 2–3
- Select AI Tasks 5–9
- Select AI Agent Tasks 9–12

## Lab-end outcome sentence

At the end of each active lab, verify that the final task or its closing paragraph tells the learner what the named person can now do. Add one short closing sentence only where this is absent.

Examples:

- Jessica can move from a dashboard number to product-level evidence that supports a review priority.
- Sam can provide a transaction as a JSON document while preserving the rows Jessica can inspect with SQL.
- Maya can compare nearby service centers, demand, and response commitments before routing work.
- Priya can show that an AI-assisted answer or agent action stayed inside the approved database boundary.

## Editing sequence

1. Read the Introduction, Business Scenario, each task heading, the first paragraph under the heading, and the expected-result text for one lab at a time.
2. Identify which parts of the learner story are missing from the task opening: the immediate problem, the reason for this step, the result to inspect, or the value to the named person.
3. Add or revise only the framing paragraph before the numbered instructions.
4. Keep the existing SQL, code blocks, screenshots, expected output, and challenge details unchanged.
5. Confirm the task handoff: the result of one task must make the reason for the next task obvious.
6. Repeat through the labs in manifest order, then review each lab's final task for a clear achievement statement.

## Acceptance criteria

- Every active task uses conversational prose to make the business reason, timing, inspection target, and learner achievement clear either in its opening or immediately before its numbered steps.
- Each task names a concrete result to inspect, not only a command to run.
- The explanation identifies how the result helps Jessica, Jordan, Sam, Priya, or Maya when relevant.
- Technical setup tasks explain the control or prerequisite they establish before the learner performs it.
- The learner can follow the sequence without needing finance or database experience beyond the definitions supplied in the lab.
- The named-team storyline uses first names only and retains the established roles.
- No changes occur outside the listed learner-facing Markdown files.

## Validation

Run these checks after the Markdown edits:

```sh
git diff --check
rg -n "^## Task |Expected result:|Expected output:|Persona focus:" \
  finance-data-foundation/finance-data-foundation.md \
  risk-operations-dashboard/risk-operations-dashboard.md \
  transaction-case-duality/transaction-case-duality.md \
  risk-signal-vector-search/risk-signal-vector-search.md \
  financial-crime-network/financial-crime-network.md \
  service-sla-spatial/service-sla-spatial.md \
  predictive-risk-oml/predictive-risk-oml.md \
  select-ai-finance-questions/select-ai-finance-questions.md \
  select-ai-agent-risk-triage/select-ai-agent-risk-triage.md
```

Report the changed Markdown files, whether `git diff --check` passed, and any task where a concise framing paragraph could not cover all five learner questions without becoming repetitive.

## Acknowledgements

* **Author** - TODO: Your Name, Your Title, Your Organization
* **Last Updated By/Date** - TODO: Your Name, Month Year
