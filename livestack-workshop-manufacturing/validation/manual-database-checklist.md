# Manual Oracle validation: completed with execution boundary

### Objectives

- Record the completed manual database checks and the boundary between manual validation and green-button provisioning.

Estimated Time: **5 minutes**

- [x] Authenticate as LLUSER in the manually provisioned database; verify embedding model and GENAI connectivity.
- [x] Execute loader SQL stages, verify all 15 table counts and assertions, and observe the completion marker.
- [x] Walk through JSON, vectors, graph, spatial, OML, Select AI and agent exercises.
- [x] Import and run both native graph notebooks, including optional PGQL setup and PGX algorithms.
- [x] Complete AutoML comparison and inspect the confusion matrix and prediction impact.
- [x] Capture all 43 planned database screenshots and place them beside their instructions.
- [x] Capture the six related live-application views and place them beside the matching lesson explanations.
- [x] Verify original persona artwork outside updated caption masks and OCR all raster images.
- [x] Render all 11 pages, load all 69 images, and pass the quiz with 7/7.
- [x] Run static validation, residue audit and complete ZIP integrity/content checks.

The loader execution was staged in Database Actions, not a fresh SQLcl run. Preserve the post-lab database for review; do not rerun initial-state assertions into it. The optional destructive reset appendix was not run. Details and remaining platform checks are in the [validation report](validation-report.md).

Terraform and green-button provisioning remain deferred. The API-key stack path still needs its own validation; manual tests used resource principal. No green-button launch was performed.

## Acknowledgements

* **Author** - Matt Kowalik
* **Last Updated By/Date** - Matt Kowalik, September 2026
