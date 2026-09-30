# Shared-browser screenshot update

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: TODO - x minutes


All 48 database, Graph Studio and AutoML screenshot placements were replaced with authentic page-only captures from the shared browser. They exclude browser tabs and address bars. Existing screenshot filenames and lesson order are preserved. Original captures are retained under `validation/before-shared-browser-captures` and excluded from the learner ZIP.

SQL results were recaptured through SQL Worksheet as LLUSER. The existing learner-pass Graph Studio notebook and AutoML experiment were reopened for their completed results; this capture pass does not claim a new AutoML training run. Notebook file selection was captured and cancelled without importing another duplicate. Long SQL, JSON and AI values were opened in their result viewers. Grid and scrollable result images are excerpts of the actual UI, not a replacement for executing and inspecting the complete results.

The browser supplied JPEG pixels. Images with existing PNG filenames were losslessly encoded as PNG; image content was not altered or synthesized. Capture dimensions and SHA-256 hashes are recorded in `validation/shared-browser-captures.json`.

## Focused instruction retest

The revised agent definitions were recreated using the lesson's documented reset path, as LLUSER. The SQL tool, agent, task and team definitions all executed successfully.

- Agent run `5CA5A2E4-C497-E98B-E063-96E8000A8EB4` completed with `SUCCEEDED`, from 20:00:37 to 20:05:10 in the database display: approximately 273 seconds.
- The tool history records one invocation using the complete natural-language question and `RUNSQL`.
- The final agent answer matched all five components, categories, rankings and ten numeric totals in the fixed verification SQL.
- The revised narration included all five components and all ten correct totals. It returned a numbered list rather than the requested table, so strict output-format compliance is still incomplete.
- This is one successful agent retest and one revised narration result, not a repeated-run reliability qualification. The earlier failures remain documented in the learner-pass evidence.
- The original `cohere.command-a-03-2025` profile model was restored and verified after the agent exercise.

| Component | Material value | Planned units |
| --- | ---: | ---: |
| Pressure interface module P15 Rev A | 585580 | 2546 |
| Pressure interface module P07 Rev A | 532450 | 2315 |
| Encoder interface module P09 Rev A | 520800 | 2480 |
| Encoder interface module P01 Rev A | 519750 | 2475 |
| Pressure interface module P14 Rev A | 511290 | 2223 |

## Validation boundary

This was the prepared database, using LLUSER only. No ADMIN access or direct database API execution was used. The six separate HighTech application views still require the absent runnable application. Fresh provisioning/bootstrap and the optional PGX repeat-session property issue are not resolved by replacing screenshots.

Static validation and the source/structure/domain audit passed. OCR completed for all 58 raster images without errors. All 48 installed screenshot hashes match the verified 94-entry ZIP. The replacement agent screenshot loaded in the rendered workshop at its expected 905 × 734 size. The immutable source remains unchanged.

## Acknowledgements

* **Author** - TODO: Your Name, Your Title, Your Organization
* **Last Updated By/Date** - TODO: Your Name, Month Year
