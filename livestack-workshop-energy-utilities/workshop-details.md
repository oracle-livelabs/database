# Seer Utility Network workshop details

## Workshop

Build Connected Energy & Utilities Solutions with Oracle AI Database.

The workshop follows service requests, reliability signals, restoration relationships, field logistics and service-demand analysis at the fictional Seer Utility Network. It contains Introduction, Getting Started, nine numbered labs and the common Need Help page.

The introduction follows the approved Hospitality structure. Other lessons retain the reference task sequence and technical objectives. Graph tasks are numbered 1 through 7.

## Live walkthrough status: 9 October 2026

The data-only loader passed as LLUSER in the supplied 26ai database. The final walkthrough passed 63 executable SQL blocks, including the three notebook queries; the graph creation appendix is reference-only because initialization already creates that graph. Graph Studio import and all eight paragraphs ran successfully. The optional AutoML experiment completed. The final agent configuration returned the database ranking and recorded successful team and SQL-tool history.

The agent uses a separate lab-owned reasoning profile with `meta.llama-3.3-70b-instruct`, while its SQL tool retains the existing Cohere `GENAI` profile. The reset step removes the agent objects and reasoning profile. The embedding model remains owned by LLUSER.

The workshop includes 53 of the 56 planned live screenshot slots, plus a relational graph comparison and the completed quiz. The three reservation-dialog screenshots remain pending because the walkthrough used a separately provisioned database.

Both local launch modes render with Oracle's LiveLabs renderer. The scored quiz passed with 7/7 answers and displayed its downloadable badge. This does not validate a hosted LiveLabs reservation, green-button SQLcl execution, or a Terraform deployment.

## Application reference

[Seer Utility Network LiveStack Demo](http://134.98.142.113:8505/).

The welcome-page image is an application-context capture from 9 October 2026, not proof of workshop SQL execution. The opening scene and ERD are generated educational illustrations.

## Dataset and model boundaries

The loader keeps selected application physical names and Utilities views. It is a synthetic workshop subset, with explicit numeric keys for learner inserts, not a production application migration.

OML predictors use data through 31 August 2026. September labels are synthetic and assigned independently of the predictor formulas. Both classes have 30 rows. The lesson teaches service-demand classification; it makes no accuracy, electricity forecasting or autonomous-dispatch claim. What-if scoring rows are not an independent evaluation set.

The graph notebook matches the loader's labels and properties, with no saved results. SQL/PGQ execution, Graph Studio import, and the two labeled graph visualizations were verified.
