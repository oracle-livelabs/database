# Deferred green-button phase

### Objectives

- List the deployment and provisioning checks that remain for the LiveLabs green-button phase.

Estimated Time: **5 minutes**

No Terraform initialization, validation, planning, application, or LiveLabs green-button launch was performed.

After manual database execution and screenshots pass:

- Verify Resource Manager packaging and the canonical loader path in adb.tf.
- Confirm that `create_user.sql.tmpl` grants `SPATIAL_AUTHOR` before the manufacturing loader performs its prerequisite check.
- Verify the embedding-model download endpoint, model import, provider model, OCI region, compartment, credential configuration, and service readiness. Retain protected output handling.
- Confirm timing and permissions for Database Actions, Graph Studio, Spatial Studio, OML and Select AI Agent using the learner identity.
- Launch a fresh LiveLabs reservation through the approved green-button workflow; verify both navigation variants, login outputs, loader completion, every lab and the quiz.
- Verify repeatability, failure reporting, resource cleanup and absence of secrets in logs and the deliverable. Rebuild the release archive with verified captures.

## Stack parity review: 25 September 2026

The manufacturing stack was compared file by file with the tested reference stack. `main.tf`, `output.tf`, and `create_user.sql.tmpl` now have identical content; `output.tf` differs only by its final newline. The common Terraform blocks in `adb.tf`, `genai.tf`, and `variables.tf` are aligned. The remaining differences are deliberate: the target runs its single manufacturing SQL loader directly, and it sets the tested GENAI inference region and model explicitly. Template-variable coverage, dependency order, loader arguments, the `SPATIAL_AUTHOR` grant, and source immutability passed static checks. Terraform and SQLcl are unavailable in the local validation environment, so `terraform init`, `terraform validate`, plan, apply, and fresh SQLcl execution remain part of the green-button phase.

## Acknowledgements

* **Author** - Matt Kowalik
* **Last Updated By/Date** - Matt Kowalik, September 2026
