# Validation evidence

## Completed

- `static-results.json`: 45 passing check groups, including 11,491 insert rows, primary and foreign keys, price/quantity totals, spatial constructors, graph paths, OML class balance, local lesson links and loader-to-lab DDL consistency.
- `structure-results.json`: reference source unchanged; 11 lessons and numbered task sequence preserved, with 40 task headings and 60 SQL blocks. Six provisioning templates are byte-identical and adb.tf changes only the loader path.
- `sql-parser-results.json`: 37 SQL blocks parsed with SQLGlot's Oracle dialect; 23 Oracle-specific blocks reviewed manually. This is not Oracle compilation.
- `domain-audit.json`: filenames and readable file contents scanned, including SQL fixtures, notebooks, JSON and SVG metadata. Two introduction illustrations have separate schema and browser evidence in `introduction-visual-review.json`. Nine application captures passed visual and OCR review. Eight raster banners also have OCR transcripts in `banner-text-review.json`; the artwork and captions were reviewed visually. The platform's Reservation Information/My Reservations wording remains intentionally.
- `browser-results.json`: local LiveLabs pages render, numbered lab navigation resolves, actual image sources load, expandable tasks work, and the quiz returns 7/7 with a completion badge. The renderer adds an empty image element without a source. Clipboard copying could not be confirmed through the browser session clipboard. An inherited renderer animation error was logged; it did not prevent these interactions.

- `final-browser-results.json`: all 69 image placements loaded across the nine revised SQL lesson pages after expanding and scrolling tasks; no capture placeholders remain. The earlier renderer report is retained as historical evidence.

## Manual database validation

[manual-results.md](manual-results.md) records the loader sections, SQL, Graph Studio, optional PGX, AutoML, Select AI and successful agent run. The capture inventory and database-captures.json record authentic screenshots and hashes. Selected transcripts are in manual-evidence/. The supplied demo remains a separate dataset; see application-capture-review.json.

The SQLcl launch step and green-button/Terraform provisioning remain untested. Browser execution of the canonical Oracle statements does not establish that automated provisioning works.

The persona artwork is visually preserved through caption editing. Raster editing is not a pixel-identical guarantee outside the text area; see the recorded banner review.
