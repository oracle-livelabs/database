# HighTech maintainer evidence

Current reports are in this directory. `source-baseline/` contains unchanged Manufacturing history and does not establish a HighTech pass. `source-captures/` retains obsolete source screenshots for the capture checklist. Neither directory is shipped.

Run `validate.py` for static/SQLite checks and `audit_hightech.py` for source, structure, stack, diagram and residue checks. Run `ocr.swift` against the target after image changes. `convert_hightech.py` records the one-time conversion and is not a rerun command for an already converted target. `finalize.py` verifies and builds the archive. No script provisions cloud resources.
