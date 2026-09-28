# Manufacturing supporting stack

The canonical loader is [manufacturing-platform-handoff-loader.sql](load_data/manufacturing-platform-handoff-loader.sql). There is one loader copy. `adb.tf` invokes this exact path. The loader retains the two positional arguments: the existing LLUSER password and database service alias.

Use a separate, fresh manually provisioned Oracle AI Database 26ai environment for testing. The loader does not drop existing tables. It starts as ADMIN, verifies prerequisites, grants the required workshop capabilities, connects as LLUSER, creates the manufacturing schema and fixtures, creates vectors and graph objects, and updates the existing GENAI profile's object list. It is not a migration for an occupied schema.

The supplied user and AI-provider templates must be applied with approved values first. ADMIN.ALL_MINILM_L12_V2 and LLUSER's SPATIAL_AUTHOR role are required. The loader deliberately fails if either prerequisite is missing. The manual database test verified the embedding model import and GENAI chat as LLUSER using OCI resource-principal authentication, Chicago inference, and `cohere.command-a-03-2025`. The stack uses API-key authentication, which still requires separate validation.

The Terraform structure is aligned with the tested reference stack. `main.tf`, `output.tf`, and `create_user.sql.tmpl` have identical content to that source; `output.tf` differs only by its final newline. The manufacturing stack has two deliberate provisioning differences: `adb.tf` runs the single manufacturing SQL loader directly instead of expanding a loader ZIP, and the GENAI template explicitly selects the model tested by this workshop. The user template now grants `SPATIAL_AUTHOR` before the loader checks that prerequisite.

No Terraform provisioning was performed. The loader SQL stages, all fixture counts and loader assertions passed in a manually provisioned database. Core lab walkthroughs, the primary graph notebook, AutoML and Select AI passed as LLUSER. The agent passed with a temporary Llama model selection, followed by verified restoration of Cohere. This was staged Database Actions execution, not a fresh end-to-end SQLcl run. See the [manual checklist](../validation/manual-database-checklist.md) and [green-button checklist](../validation/green-button-checklist.md).

## AI inference region

`ociGenAiRegion` defaults to `us-chicago-1`; `ociGenAiModel` defaults to `cohere.command-a-03-2025`. The database region remains controlled by `ociRegionIdentifier`. Keep the public OCI endpoint implicit in the profile. The manual test returned `SEER MANUFACTURING connection ready` from the workshop GENAI profile as LLUSER on 2026-09-22.

Cohere Command A is listed as dedicated-only in Ashburn and available on demand in Chicago in [Oracle model availability](https://docs.oracle.com/en-us/iaas/Content/generative-ai/model-endpoint-regions.htm). Check availability when changing either value. LiveLabs may supply an explicit inference-region value that overrides this default; validate that value in the green-button phase.
