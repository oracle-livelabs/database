# Workshop language review

Reviewed the full SEER Telecomms workshop against the plain-language criteria in the supplied JARGONCHECK.md. Its unrelated role and output instructions were not applied.

- Read all 11 lessons, including seven quiz questions, and the explanatory paragraphs in both Graph Studio notebooks. Checked the supporting documentation, readable metadata, SQL comments, SVG text, and existing image-text review records.
- Revised 20 prose files. Replaced vague roles with support, operations, plan, and fraud analysts; simplified document and graph explanations; explained model testing and accuracy terms.
- Corrected outdated notes about pending database runs and screenshots, plus one leftover term for an order line from the source domain.
- Retained Oracle feature names, SQL identifiers, literal tool labels, and precise technical terms needed for the exercises. Evidence remains where it means investigation records or recorded validation results, not a vague compliance claim. Authentic screenshots and banners remain unchanged.

| Before | After |
| --- | --- |
| synthetic workshop fixtures | made-up sample data for this workshop |
| external embedding pipeline | separate service that creates embeddings |
| schema metadata | table and column definitions |
| time-separated holdout | a later period reserved for testing |
| database principal with SELECT-only grants | separate database user that can only read the required tables and rows |

Validation passed: 45 static check groups, all 60 SQL blocks unchanged, both notebooks' executable content and configuration unchanged, task headings unchanged, all 77 images unchanged, and loader/deployment files unchanged. The domain check found no old-domain terms in readable release files. All 116 source files retain their original hashes.

No database queries or provisioning were run for this editorial pass. Previous manual-database results still apply to the unchanged code. SQLcl launch and LiveLabs green-button/Terraform validation remain for the next phase.
