# SEER Telecomms LiveLabs workshop

This edition follows the SEER Telecomms team through subscriber support, service-order documents, plan search, activation-fraud review, network-site analysis, demand classification and questions in plain language.

Open `workshops/sandbox/index.html` or `workshops/tenancy/index.html` through a local HTTP server. The LiveLabs renderer requires network access. Both manifests preserve the same lesson and task sequence.

## Release state

The repository conversion and offline checks are complete. Nine live application screenshots are included beside the related instructions; their captions distinguish the demo dataset and local AI runtime from the workshop. Database execution, Graph Studio import, AutoML, Select AI calls and authentic database-result screenshots are deferred until a manual database is available. LiveLabs green-button and Terraform validation have not been run. This is a reviewable handoff, not a runtime-certified release.

- [Workshop map](validation/workshop-map.md)
- [Schema and fixture contract](validation/schema-contract.md)
- [Canonical loader and manual run sequence](stack/README.md)
- [Screenshot placement and capture queue](validation/screenshots.md)
- [Validation evidence](validation/README.md)

Run `python3 validation/validate.py` for the offline checks. The loader creates a synthetic telecom dataset in a fresh LLUSER schema; it deliberately rejects an occupied schema instead of dropping data.
