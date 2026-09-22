# Deferred green-button phase

No Terraform initialization, validation, planning, application, or LiveLabs green-button launch was performed.

After manual database execution and screenshots pass:

- Verify Resource Manager packaging and the canonical loader path in adb.tf.
- Resolve the bootstrap prerequisite for SPATIAL_AUTHOR: the loader checks it, but the supplied setup does not assign it. Confirm the supported assignment process before attempting automation.
- Verify the embedding-model download endpoint, model import, provider model, OCI region, compartment, credential configuration, and service readiness. Retain protected output handling.
- Confirm timing and permissions for Database Actions, Graph Studio, Spatial Studio, OML and Select AI Agent using the learner identity.
- Launch a fresh LiveLabs reservation through the approved green-button workflow; verify both navigation variants, login outputs, loader completion, every lab and the quiz.
- Verify repeatability, failure reporting, resource cleanup and absence of secrets in logs and the deliverable. Rebuild the release archive with verified captures.
