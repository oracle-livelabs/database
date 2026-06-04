# LiveStack Workshop Build Plan

Use this plan when building or revising LiveStack LiveLabs workshops such as Retail, Finance, and future verticals. The goal is to keep each workshop learner-focused, outcome-driven, technically accurate, and easy to validate.

## Core Pattern

1. Start with the operating story.
   - State the business problem.
   - State the technical challenge.
   - Identify the persona focus.
   - Name the database capability.
   - End with the outcome.

2. Treat each lab as part of one decision loop.
   - Observe the business.
   - Understand the signal.
   - Decide what action is needed.
   - Act through trusted database-backed tools.
   - Review the evidence.

3. Avoid feature-catalog language.
   - Do not lead with a product feature unless the learner knows why it matters.
   - Tie every SQL block, screenshot, and diagram to a business question.
   - Use `Outcome`, not `Business Takeaway`, in story tables.

4. Keep the workshop grounded in the LiveStack Demo.
   - Refer to the application as the LiveStack Demo when describing the running app.
   - Make clear that the app shows the workflow and the lab explains the database evidence behind it.

## Recent Working Decisions

These decisions came out of the Retail workshop revision and should carry forward into Finance and future LiveStack workshops.

- Use the real workshop source under the LiveLabs database tree.
  - Current Retail source: `/Users/patshepherd/GitHub/livelabs/database/livestack-workshop-retail`.
  - Future workshops should follow the same pattern, for example `livestack-workshop-finance`.
  - Avoid renaming lab folders or markdown files casually; manifests, URLs, screenshots, anchors, and browser links may depend on those paths.
- Keep the workshop SQL-first unless a UI workflow is explicitly approved.
  - Graph Studio, Spatial Studio, OML UI, Select AI, and Select AI Agents are larger content decisions.
  - Mention those tools as learn-more or visual context only unless the lab is being redesigned around that UI.
- Treat Labs 8 and 9 as short, focused labs unless the environment guarantees live GenAI setup.
  - Lab 8 is about trusted answers.
  - Lab 9 is about trusted actions.
  - Do not imply live Select AI or agent frameworks are configured unless they are part of the provisioned environment.
- For examples that mutate data, use a dedicated workshop row and make the flow rerunnable.
  - Delete prior workshop row if present.
  - Insert the known row.
  - Commit.
  - Verify through both representations.
  - Avoid reset/cleanup language when each LiveLabs instance starts from a fresh seed.
- Prefer learner-facing table summaries over synthetic `UNION ALL` SQL when the SQL only exists to print a static capability map.
- When simplifying SQL, keep the teaching purpose visible.
  - Remove scaffolding that only exists for portability or author convenience.
  - Keep SQL that teaches a real database pattern.
- Validate changed SQL against ADB when possible, especially:
  - JSON Relational Duality inserts/updates.
  - Vector model calls and expected distances.
  - OML scoring outputs.
  - Agent tool function calls.
- If ADB validation cannot run in the current shell, say so and avoid claiming live validation.

## Lab Structure

Each lab should include:

- A concise introduction that explains the business problem and technical challenge.
- An `Operating Story` table with:
  - `Business Problem`
  - `What You Will Prove`
  - `Database Capability`
  - `Outcome`
- A short `Persona focus` paragraph.
- Objectives that match what the learner actually does.
- SQL or UI steps that teach one idea at a time.
- Expected output that is cleanly formatted and tied to interpretation.
- A closing interpretation that explains why the result matters to the business.

## SQL And Worksheet Guidance

- Prefer simple, learner-readable SQL over author-side robustness unless the robustness teaches something.
- Use `USER_*` catalog views when the learner is connected as the workshop schema user.
- Do not use `DUAL` in Oracle 23ai/26ai examples unless there is a specific reason.
- Do not explain `DUAL` as a demo helper.
- Split multi-step write operations into separate copy blocks:
  - `DELETE`
  - `INSERT`
  - `COMMIT`
  - verification query
- Explain when to use **Run Script** in Database Actions SQL Worksheet.
  - Use Run Script for DDL.
  - Use Run Script when formatted `PRETTY` JSON output is expected.
  - Clarify that Run Script is different from the single-statement green Run Statement control.
- Validate SQL against ADB when the lab changes query behavior or expected output.
- Use the exact model owner when required.
  - In Retail, `ADMIN.ALL_MINILM_L12_V2` was required for embedding generation.
  - The stored vector metadata may still use `ALL_MINILM_L12_V2` as the embedding model value.
- Use modern Oracle SQL style for 23ai/26ai.
  - Do not add `FROM dual` to literal or scalar function examples unless testing proves the environment requires it.
- When a SQL block contains several operations, split the operations into separate copy blocks unless the learner specifically needs to run a script.
- Keep expected outputs in well-formed markdown tables.
  - Do not use one-cell malformed tables such as `| Result | | --- | ...`.
  - Use clear column headings such as `Product | Inventory Summary`.

## Content Rules

- Remove author-facing notes such as “verify before presenting” or “sample values may change” unless the learner needs that caveat.
- Avoid saying something is useful “for demos” or “for workshops”; explain why it matters in real application or business terms.
- Do not call out workshop weaknesses in quiz questions or lab conclusions.
- Avoid stale concepts in quizzes or maps when a lab no longer teaches them.
- Keep screenshots unique; remove duplicate or redundant screenshots.
- Use diagrams when they simplify the learning moment, but verify labels do not overlap.
- Put complex UI-tool workflows such as Graph Studio, Spatial Studio, OML UI, Select AI, and Select AI Agents into a separate design decision before adding them.
- Use screenshots deliberately.
  - Remove duplicate or near-duplicate screenshots.
  - If the user supplies a specific screenshot, use that screenshot or crop faithfully.
  - Preserve blurred secrets in supplied screenshots.
  - Tie each screenshot to the lab step; do not include a screenshot only because it exists.
- Use learner language, not build-prompt language.
  - Avoid headers such as “Summarize what the learner can do.”
  - Prefer learner-facing headings such as “From retail signal to trusted action.”
- Avoid broad caveats about seeded values changing unless the learner needs to act on that caveat.

## Feature-Specific Patterns

### JSON Relational Duality

- Explain that the business/application value is API-friendly document access.
- Explain that Oracle still stores and protects the data relationally.
- Explain `WITH INSERT UPDATE DELETE` before the learner runs the view definition.
- Show the same data as JSON and relational rows.
- For write labs, show document insert/update and relational verification.
- If the lab inserts a document through a duality view, make the student prove it came back through SQL.
- Use `Run Script` guidance for `PRETTY` JSON and DDL so the SQL Worksheet output is predictable.

### AI Vector Search

- Emphasize in-database embeddings: source text, vectors, and SQL search stay close to governed data.
- Use `DBMS_VECTOR_CHAIN.UTL_TO_EMBEDDING` for embedding generation.
- Use `VECTOR_DISTANCE` for semantic comparison.
- Explain cosine distance in plain terms:
  - It compares vector direction.
  - Lower distance means closer meaning.
- Keep distance calculation and full product search as separate tasks when both teach useful ideas.
- For semantic search examples, generate scores dynamically with `VECTOR_DISTANCE`.
  - Do not rely on seeded hard-coded similarity score tables unless the lesson is explicitly about persisted match history.
- If duplicate display names appear, group by the learner-facing product name/category and use `MIN(VECTOR_DISTANCE(...))` for a clean result.
- Explain that smaller distance means closer meaning; if displaying a similarity score, explain any `1 - VECTOR_DISTANCE(...)` conversion.

### Property Graph

- Explain the business problem as relationship analysis, not graph terminology.
- Show why relationship paths become easier than long chains of self-joins.
- Explain vertices, edges, and path patterns.
- Keep Graph Studio as a future/optional content decision unless the lab is explicitly becoming a UI walkthrough.

### Spatial

- Explain that spatial data supports maps and queryable decisions.
- Tie points, polygons, GeoJSON, distance, service zones, and inventory together.
- Make the business decision clear: which fulfillment option is practical and why.
- Keep Spatial Studio as a future/optional content decision unless the lab is explicitly becoming a UI walkthrough.

### OML

- If models are seeded, say so clearly.
- Explain that the lab starts from deployed models so the learner can focus on scoring and action.
- Connect predictions to business action, such as replenishment or risk triage.
- Treat model creation/training as a larger lab expansion, not a quick wording change.

### Ask Data And Agents

- Lab 8 should focus on trusted answers:
  - approved views
  - readable columns
  - visible filters
  - inspectable SQL
- Lab 9 should focus on trusted actions:
  - approved PL/SQL tools
  - grounded evidence
  - durable audit history
- Do not rebuild these around live Select AI or Select AI Agents unless the environment guarantees the needed GenAI, profile, and agent setup.

## Preview And Browser Workflow

- Start a local Python server from the workshop root when previewing the whole workshop.
  - Example: `python3 -m http.server <port>`.
  - Open `http://127.0.0.1:<port>/workshops/sandbox/index.html`.
- If rendered content looks stale:
  - Add a cache-busting query string.
  - Hard refresh the browser.
  - Restart the local server if needed.
  - Confirm the markdown is being served from the expected repo root.
- When checking the final quiz, expand the quiz task and answer all questions to verify:
  - score calculation
  - pass message
  - badge display
  - badge image dimensions
- Keep local server notes out of learner-facing markdown unless the learner must run a server.

## Quiz Rules

- Revisit the quiz after each major lab reframing pass.
- Test business outcomes and persona value, not only technical terms.
- Avoid questions about workshop limitations.
- Avoid stale content, such as VPD, if the current workshop does not teach it.
- Do not make every correct answer first.
- Keep answer choices similar in length and specificity.
- Validate quiz structure:
  - one correct answer per question
  - three distractors per question
  - one explanation per question
  - correct answers distributed across A/B/C/D
- Avoid making the correct answer obviously longer or more detailed than the distractors.
- Test outcome questions, not only vocabulary.
  - Converged database value.
  - Reduced integration.
  - Governed AI.
  - Explainable outcomes.
  - Persona-specific value.

## Badge Rules

- Use a polished Oracle LiveLabs-style badge, not a placeholder.
- Avoid cluttered concentric-ring designs.
- Prefer a clean shield or certificate badge with restrained colors.
- Keep the main workshop title readable at small size.
- Follow the Oracle LiveLabs badge visual language when a reference badge is supplied:
  - shield shape
  - restrained plum/tan palette
  - folded LiveLabs ribbon
  - minimal text
  - no unnecessary concentric rings
- Keep active PNG assets at 512 x 512.
- Keep the SVG source alongside the rendered PNG for future edits.
- Update both the configured badge path and `badge.png` fallback, because the LiveLabs renderer may use either.
- If the renderer still displays a stale badge, check browser cache and confirm whether it is using the configured path or `badge.png`.

## Validation Checklist

Before closing a pass:

- Search for stale labels:
  - `Business Takeaway`
  - removed feature names such as `VPD`
  - author-facing notes
  - demo-only phrasing
- Search for old SQL patterns:
  - unnecessary `FROM dual`
  - stale model/function names
  - malformed tables
- Check markdown fences are balanced.
- Check screenshots are not duplicated.
- Confirm expected outputs match validated SQL when SQL changed.
- Restart or cache-bust the local server/browser when rendered content looks stale.
- Run a repo-wide search for old workshop decisions after a reframing pass:
  - stale feature names
  - old badge paths
  - old model/function names
  - author-facing notes
  - duplicated figures
  - malformed markdown tables
