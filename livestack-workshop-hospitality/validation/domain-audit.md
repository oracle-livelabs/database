# Hospitality domain audit

The follow-up audit covers every target path and text file, including reports, manifests, SQL examples, SVG text, both notebooks and their nested display settings. All 11 retained raster images were visually inspected and their text recognized with macOS Vision. The [image review](raster-review.json) records their exact hashes; any image change requires a new review.

Guest-service severity wording, reservation-draft examples, SQL aliases, graph descriptions, and vector-search quiz wording were corrected. The welcome diagram uses guest operations. Illustrative coordinates are distinguished from actual loader data. Technical graph scores and loyalty-points transfers remain appropriate hospitality examples.

Reference path maps, baseline hashes and original image filenames now live in a separate migration-evidence archive. The [image inventory](screenshots.md) uses stable asset IDs to retain traceability. No source file was edited.

The validator scans all text, all paths, decoded nested JSON, and PNG text metadata. Its only text exceptions are its own prohibited-word detection expression and exact official Oracle navigation/author labels. No folder, report, notebook, or validation file is exempt. Ordinary database operations, hotel revenue, booking review scores and loyalty membership retain their correct meanings.

Run the offline check from the workshop root:

```text
python3 validation/validate.py
```

To verify reference immutability and structural equivalence as well, supply the read-only reference and external migration-evidence directory:

```text
python3 validation/validate.py --source /path/to/reference --reference-evidence /path/to/hospitality-migration-evidence
```

Static checks cover both manifests, local links, 60 SQL blocks, 18 foreign-key contracts, and 51 notebook paragraphs. They do not execute Oracle SQL or import Graph Studio notebooks. Runtime checks and 54 environment-dependent image captures remain pending Phase 2.

## Follow-up verification

- The revised quiz was run in the actual local LiveLabs renderer: 7/7 correct, with the passing badge displayed. The graph lesson also loaded with its updated content.
- Six temporary regression fixtures were rejected: report content, validation-document content, validator comments, a new prohibited filename, an escaped notebook label, and changed image bytes/text metadata. The clean fixture passed again after each removal. These fixtures are outside the delivered workshop.
- Three existing JPEG payloads had incorrect extensions. Their files and references now use `.jpg`; image bytes were preserved.
- Reference SHA-256 checks confirm all 104 files are unchanged. The original lab sequence, 40 task headings, 60 SQL blocks, and 51 notebook paragraphs remain.

## Seer Hotels introduction update

The hotel-group name is now Seer Hotels throughout current workshop text, metadata, filenames, and illustrations. The prior working brand is included in the validator’s prohibited-word expression. Introduction captures were refreshed from the actual local renderer.

The data-model prose was replaced with a static illustrated ERD and short caption. It shows the five core entities and their five foreign-key relationships; the full schema remains linked for supporting entities, revenue definitions and constraints. The new image is recorded as N001 and reviewed separately from the 86 reference assets. The current raster inventory contains 12 images.
