# Workshop with a single set of labs

## Instructions—delete this file when finished

Estimated Time: X

### Objectives

- Understand the required structure for single-workshop labs.
- Apply naming, accessibility, and linting standards before publishing.
- Know how to reference prerequisite labs and build manifests correctly.
- Reuse the sample folder layout to create parent/child workshop variants.


1. Open the sample-workshop template in your editor (VS Code or Atom).
2. Five lab folders are pre-created; a workshop is a sequence of multiple labs.
3. Remove placeholder comments such as *List objectives for this lab*.
4. Use lowercase folder/filenames with dashes (`setup-adb`, not `Setup_ADB`).
5. Give images descriptive, lowercase, dashed names (e.g., `adb-network-policy.png`) and write meaningful alt text.
6. Download the QA checklist from WMS before you begin; teams ship faster when they understand the production requirements and follow the skeleton early.

> **Reminder:** Don’t add `README.md` files inside workshops. Readmes live at the repo root because we route traffic through LiveLabs for usage tracking. Avoid direct GitHub links; traffic that bypasses LiveLabs can’t be measured.

## Absolute path guidance for Oracle Cloud navigation

**Lab 1: Provision an Instance → Step 0.** Use the standardized Oracle Cloud menu screenshots we provide so future UI changes don’t break your lab.

## Folder structure

One “parent” workshop can become several “child” workshops by reusing subsets of labs:

```
sample-workshop/
  provision/
  setup/
  dataload/
  query/
  introduction/
    introduction.md   # Treats the full workshop as a lab

  workshops/
    freetier/
      index.html
      manifest.json
    livelabs/
      index.html
      manifest.json
```

### Tenancy vs. Sandbox

- **Tenancy:** Free Trial, paid, or Always Free accounts (brown button)
- **Sandbox:** Oracle-provided tenancy reservations (green button)
- **Desktop:** NoVNC environment packaged inside a compute instance

### About the workshop

- All six labs run in sequence.
- The introduction lab describes the full set; reuse it for child workshops unless a unique intro is required.
- See `product-name-workshop/tenancy/manifest.json` for the manifest layout.
- “Lab n:” prefixes in titles are optional.

### Referencing prerequisite labs

Reuse existing labs via absolute URLs:

```
"filename": "https://oracle-livelabs.github.io/common/labs/cloud-login/cloud-login-livelabs2.md"
```

Reference local labs with relative paths:

```
"filename": "../../provision/provision.md"
```

### Example

- Live lab: https://oracle-livelabs.github.io/apex/spreadsheet/workshops/freetier/
- Source: https://github.com/oracle-livelabs/apex/tree/main/spreadsheet

## Acknowledgements
* **Author** - LiveLabs Team
* **Last Updated By/Date** - LiveLabs Team, 2026
