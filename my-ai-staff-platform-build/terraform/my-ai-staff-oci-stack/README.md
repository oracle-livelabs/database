# My AI Staff OCI Resource Manager stack

This directory is the source for the root-level release ZIP consumed by the
Deploy to Oracle Cloud button. It creates the workshop VCN, SSH-only public
host, Always Free Autonomous Database, private temporary model bucket, and a
cloud-init bootstrap. The default model URL is Oracle's public, augmented
all-MiniLM-L12-v2 artifact; its SHA-256 is pinned in `variables.tf`.

Before publishing a release, run:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
./package.sh v1.0.0
```

Upload `dist/my-ai-staff-oci-stack-v1.0.0.zip` to an Object Storage bucket and
create an Object Read pre-authenticated request (PAR) for that object. Replace
`OBJECT_STORAGE_PAR_URL` in the Lab 2 Deploy button with the resulting PAR URL.
Do not use a repository source archive: Resource Manager requires this Terraform
configuration at the ZIP root.

The bootstrap installs the local Codex skills plugin for the `opc` user, labels
the created virtual environments for SELinux, and deliberately does not
configure credentials for Codex, Slack, Google, or publishing integrations. It
logs to `/var/log/my-ai-staff-bootstrap.log` and creates
`/var/lib/my-ai-staff-bootstrap.complete` only after the schema and model smoke
test succeed.
