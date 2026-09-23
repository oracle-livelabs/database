# SEER Telecomms LiveLabs workshop

This edition follows the SEER Telecomms team through subscriber support, service-order documents, plan search, activation-fraud review, network-site analysis, demand classification and questions in plain language.

Open `workshops/sandbox/index.html` or `workshops/tenancy/index.html` through a local HTTP server. The LiveLabs renderer requires network access. Both manifests preserve the same lesson and task sequence.

## Release state

The repository conversion, offline checks and manual database validation are complete. The loader statements, lab SQL, both Graph Studio notebooks, AutoML and Select AI/agent examples were exercised as LLUSER. Authentic demo and database screenshots are placed beside their instructions. See [manual validation](validation/manual-results.md) for results, corrected failures and limits. The SQLcl launch step, LiveLabs green-button and Terraform provisioning remain untested.

- [Workshop map](validation/workshop-map.md)
- [Tables and sample data](validation/schema-contract.md)
- [Main loader and manual run sequence](stack/README.md)
- [Screenshot placement and capture queue](validation/screenshots.md)
- [Validation evidence](validation/README.md)

Run `python3 validation/validate.py` for the offline checks. The loader creates a synthetic telecom dataset in a fresh LLUSER schema; it deliberately rejects an occupied schema instead of dropping data.
