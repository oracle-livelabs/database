# Green-button validation results: 29 September 2026

### Objectives

- Record the fresh LiveLabs provisioning and learner walkthrough results.
- Record the checks that remain outside the learner walkthrough.

Estimated Time: **5 minutes**

The LiveLabs green button launched a fresh reservation in South Korea Central (Seoul) from the corrected stack revision. The Resource Manager apply completed successfully, the manufacturing loader archive was extracted and executed, Database Actions opened as `LLUSER`, and the fresh object inventory and fixture counts matched the canonical loader. `SPATIAL_AUTHOR`, the GENAI profile, and `PRODUCTION_QUALITY_NETWORK` were present before the labs ran.

The fresh run passed Getting Started, the dashboard, JSON duality, vector, SQL graph, Graph Studio, spatial, OML SQL, AutoML, Select AI, Select AI Agent, and the final quiz. The primary Graph Studio notebook imported and ran all three SQL paragraphs. AutoML completed five classification models at 1.0000 balanced accuracy. The agent team completed with one SQL tool invocation and the original Cohere profile model was restored. The quiz scored 7/7 and displayed the manufacturing badge. See [green-button-results.json](green-button-results.json) for the measured results.

The corrected target follows the reference two-step sequence: unzip `manufacturing-platform-handoff-loader.zip`, then run the extracted SQL with SQLcl. This green-button reservation proves that sequence on a fresh database. Static parity and loader-content validation also pass.

Remaining checks:

- Run `terraform init` and `terraform validate` locally if CLI-level validation is required. The green-button Resource Manager apply itself succeeded.
- Run the reservation destroy flow and confirm resource cleanup when the test is closed.
- Keep reservation credentials and protected Terraform outputs out of logs and release archives.

## Stack parity review: 25 September 2026

The manufacturing stack was compared file by file with the tested reference stack. `main.tf`, `output.tf`, and `create_user.sql.tmpl` have identical content; `output.tf` differs only by its final newline. The common Terraform blocks in `adb.tf`, `genai.tf`, and `variables.tf` are aligned. The target uses the reference unzip and SQLcl dependency sequence with the manufacturing loader names, and it sets the tested GENAI inference region and model explicitly. Template-variable coverage, dependency order, loader arguments, the `SPATIAL_AUTHOR` grant, and source immutability passed static checks. The fresh 29 September apply passed; local Terraform CLI commands remain unrun.

## Acknowledgements

* **Author** - Matt Kowalik
* **Last Updated By/Date** - Matt Kowalik, September 2026
