# Conversion and QA Notes

### Objectives

In this lab, you will:
* TODO: Add objectives


Estimated Time: 10 minutes to review delivery status.

## Conversion scope

Built on November 8, 2026 using the approved blueprint. Source: `C:/Users/Perside/Documents/GitLab/migrate-to-oracle-linux`. Destination: `C:/Users/Perside/Documents/GitHub/_migrate-to-oracle-Linux`.

Mode: publish-ready conversion, with publication dependencies listed below. The completed Luna workshop supplies the lab procedure and execution evidence. The OLVM reference supplies the tenancy launch-page pattern. Its multi-server infrastructure is not part of this workshop.

## Source-to-target map

| Source section | Target | Intentional change |
| --- | --- | --- |
| Workshop introduction | `introduction/introduction.md` | Learner-owned tenancy, costs, updated architecture diagram |
| Lab 1 | `environment/environment.md` | Local access and private image delivery; SSH and HTTP ingress from 0.0.0.0/0 |
| Lab 2 | `linux-quickstart/linux-quickstart.md` | Optional status preserved |
| Lab 3 | `migration-readiness/migration-readiness.md` | Explicit recovery choice; backup remains optional |
| Lab 4 | `migrate-to-oracle-linux/migrate-to-oracle-linux.md` | Local report download path |
| Lab 5 | `ksplice/ksplice.md` | Tested Ksplice sequence preserved |
| Lab 6 | `kernel-choices/kernel-choices.md` | UEK 8 sequence preserved |
| Lab 7 | `os-management-hub/os-management-hub.md` | Explicit administrator prerequisites; permission-warning bypass removed |
| Lab 8 | `automation-engine/automation-engine.md` | Required automation preserved; cleanup appended |

The source heading levels changed to LiveLabs H1 and Task headings. Labs retain their order and titles. The pinned script, SHA-256 checksum, dry run, conversion flags, RHCK-to-UEK order, OSMH sources, and playbook remain tied to source evidence.

## Screenshot provenance

There are 38 PNG assets: 37 references to authentic source screenshots and one new architecture diagram. Duplicate application screenshots appear in their relevant lab folders. Twelve screenshot-based SVGs were flattened to PNG with their embedded screenshot pixels and existing red arrow geometry. Original PNG screenshots were copied unchanged. No execution output or Console page was generated.

See `qa/image-provenance.json` for paths, methods, and source hashes. The architecture diagram represents the new tenancy context and is not a screenshot. The excluded source assets are recorded below; they include obsolete Luna access screens, replaced key-selection instructions, broad ingress-rule examples, the policy-warning bypass, and unused source assets.

- `tutorial/images/add-ingress-rule.png`
- `tutorial/images/add-ssh.png`
- `tutorial/images/compute-menu.png`
- `tutorial/images/create-instance-add-ssh.png`
- `tutorial/images/default-add-ingress-rule-done.png`
- `tutorial/images/default-add-ingress-rule.png`
- `tutorial/images/default-security-list.png`
- `tutorial/images/default-security-rules.png`
- `tutorial/images/final-ingress-rules.png`
- `tutorial/images/http-default-security-rule.png`
- `tutorial/images/id-ras-pub.png`
- `tutorial/images/luna-lab-icon.png`
- `tutorial/images/luna-lab-login.png`
- `tutorial/images/luna-lab-page.png`
- `tutorial/images/osmh-policy-permission-warning.svg`
- `tutorial/images/show-hidden-flies.png`
- `tutorial/images/ssh-folder.png`
- `tutorial/images/ssh-key-select.png`
- `tutorial/images/ssh-luna-teminal.png`
- `tutorial/images/terminal-emulator.png`
- `tutorial/images/vcn-details-menu.png`
- `tutorial/images/workshop-architecture.png`
- `tutorial/images/workshop-architecture.svg`

Source screenshots are historical examples. Region labels, resource identifiers, package versions, and Console layout can differ. Learners follow their own selected region, compartment, key, and public IP. The learner SSH and HTTP ingress rules use source CIDR `0.0.0.0/0`, as requested by the workshop owner.

## Validation and limits

The local workshop validator checks structure, manifests, and Markdown. `qa/validate-conversion.py` adds source hashes, manifest sequence, links, image decoding, no SVG references, no em dash characters, code-block fidelity, and copy-tag checks. `qa/pinned-script-check.json` records the downloaded pinned script checksum; the script was not executed locally.

The validator's Lanham score is a heuristic over entire files, including shell syntax, YAML, and technical vocabulary. It is not a runtime result. The conversion keeps precise technical checks and uses direct task instructions. Review any remaining prose advisories before catalog submission.

The in-app preview connection failed because its native bridge was not trusted. A fallback browser launch approval timed out. No successful browser-rendered LiveLabs preview is claimed. Image contact-sheet review confirmed the exported screenshots, red arrows, and diagram were readable. The launch page, manifest, introduction, a screenshot, and playbook returned HTTP 200 locally. Oracle CDN asset requests timed out in this environment, so renderer availability was not verified. See `qa/http-checks.json`.

No OCI resources were created and no migration, package update, Ksplice operation, OSMH registration, or cleanup was executed during conversion. The authentic source screenshots record the tested source run. A fresh learner-tenancy acceptance run remains required before public delivery.

## Publication dependencies

- Workshop owner: confirm prepared-image redistribution rights and approved hosting, then provide learners the complete image URL through a private channel. Confirm expiry, refresh ownership, and image integrity before delivery.
- Tenancy administrator: validate the supplied policy templates in the learner's identity domain and compartment, confirm eligible OSMH access and physical E5 capacity, and prepare vendor-source access.
- Workshop owner: run the launch page in a browser with Oracle CDN access and complete an end-to-end learner-tenancy acceptance run. Confirm the new recovery and cleanup steps against that tenancy.
- Ksplice: no available patch is an honest recorded outcome, but it does not complete the actual patch-application test. Preserve that distinction when assessing completion.
- LiveLabs publisher: confirm the workshop support alias and catalog metadata. This build has not been committed, pushed, or published.

## FreeSQL

Not applicable. This workshop teaches OS migration and administration rather than SQL.

## Acknowledgements

- Perside Foster, Rosario Spiezia, Mitch Dsouza, and Nick Mader, original workshop authors.
