# LiveStack LiveLab Workshops

This repository contains many Database LiveLabs workshops. The LiveStack LiveLab workshop projects live under this directory as workshop folders, for example:

- `livestack-workshop-retail/` - retail workshop.
- `livestack-finance-workshop/` - finance workshop currently present in this repo.

Prefer the naming pattern `livestack-workshop-<domain>` for new LiveStack workshops unless an existing folder already uses a different checked-in name.

## Working Guidelines

- Treat `/Users/patshepherd/GitHub/livelabs/database` as the source-of-truth parent for actual LiveStack workshop projects.
- Keep each LiveStack workshop self-contained inside its own folder.
- Do not move or rename existing workshop folders unless explicitly requested.
- Preserve each workshop's existing LiveLabs structure, including lab markdown, images, manifests, source schema, and backend provisioning assets.
- Use `rg` and `rg --files` first when searching.
- Keep generated operating-system files such as `.DS_Store` out of project changes.

## Retail Notes

- The retail workshop is `livestack-workshop-retail/`.
- The retail seed/handoff SQL file is `livestack-workshop-retail/backend-provisioning/database-source/retail_workshop_admin_create_lab_seed.sql`.
- Keep retail lab markdown, workshop manifests, images, and backend provisioning changes aligned when editing workshop flow.

## Verification

When changing a workshop, verify only the affected workshop unless the change is explicitly shared across multiple workshops. Prefer focused validation commands from that workshop's existing docs or scripts.
