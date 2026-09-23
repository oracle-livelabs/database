# SEER MANUFACTURING: Oracle LiveLabs

The workshop and supporting stack have been converted for component production, inspection, material traceability, and plant routing. The 11-lesson sequence and its technical exercises are preserved.

**Status: manually validated workshop; green-button phase pending.** The core SQL labs, two Graph Studio notebooks, AutoML, Select AI and agent test ran as LLUSER. All 43 database screenshot positions and six live-application examples are filled. See the validation report for the staged-loader execution boundary and remaining platform checks. LiveLabs green-button and Terraform provisioning have not been run.

- [Jargon and antislop review](validation/copy-review.md)
- [Workshop map](validation/workshop-map.md)
- [Data model and loader contract](validation/schema-contract.md)
- [Validation results and limitations](validation/validation-report.md)
- [Screenshot coverage](validation/screenshots.md)
- [Manual database checklist](validation/manual-database-checklist.md)
- [Deferred green-button checklist](validation/green-button-checklist.md)
- [Supporting stack](stack/README.md)

Serve this directory with a local HTTP server and open `workshops/tenancy/` or `workshops/sandbox/`. Both use Oracle's hosted LiveLabs renderer and require network access. Do not interpret the learner's launch instructions as confirmation that provisioning has been tested.

All example organizations, people, orders, inspections, and locations are synthetic. Dates use a fixed September 2026 analysis window. Costs are USD material and setup costs; they are not sales revenue.
