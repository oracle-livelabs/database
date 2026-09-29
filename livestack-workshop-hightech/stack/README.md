# HighTech supporting stack

The stack provisions the workshop database, prepares the `LLUSER` account and AI profile, and loads the HighTech data. The loader is supplied in [hightech-platform-handoff-loader.zip](load_data/hightech-platform-handoff-loader.zip), which contains `hightech-platform-handoff-loader.sql`. `adb.tf` extracts the archive before SQLcl runs the SQL file. The loader takes two positional arguments: the existing `LLUSER` password and database service alias.

Each LiveLabs sandbox provisions a fresh Oracle AI Database 26ai environment. The loader starts as `ADMIN`, checks prerequisites, grants the required workshop capabilities, connects as `LLUSER`, creates the HighTech schema and sample data, creates vectors and graph objects, and updates the `GENAI` profile's object list.

The supplied user and AI-provider templates run before the loader. `ADMIN.ALL_MINILM_L12_V2` and the `SPATIAL_AUTHOR` role for `LLUSER` are required; the loader stops if either is missing. The user template grants `SPATIAL_AUTHOR` before the loader checks that prerequisite.

## AI inference region

`ociGenAiRegion` defaults to `us-chicago-1`; `ociGenAiModel` defaults to `cohere.command-a-03-2025`. The database region is controlled separately by `ociRegionIdentifier`. Keep the public OCI endpoint implicit in the profile. Check [Oracle model availability](https://docs.oracle.com/en-us/iaas/Content/generative-ai/model-endpoint-regions.htm) before changing the model or inference region.

The Select AI Agent lab temporarily uses `meta.llama-3.3-70b-instruct` and includes instructions to restore the previous profile model afterward.
