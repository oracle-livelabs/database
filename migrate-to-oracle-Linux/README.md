# Migrate Red Hat Enterprise Linux to Oracle Linux

A LiveLabs workshop for learners using their own OCI tenancy. It preserves the tested eight-lab Luna sequence and the prepared RHEL 9.8 Apache image.

Estimated Time: About 6 hours 45 minutes including optional Lab 2, plus tenancy preparation and cleanup.

## Open the workshop

Serve this directory over HTTP and open `workshops/tenancy/index.html`. From a terminal in this directory:

```text
python -m http.server 8000 --bind 127.0.0.1
```

Open `http://127.0.0.1:8000/workshops/tenancy/`. The LiveLabs renderer loads from Oracle's CDN, so internet access is required. Publishing to a repository or LiveLabs catalog is a separate step.

## Workshop sequence

Complete [Introduction](introduction/introduction.md) and the shared Get Started page, then follow the labs in order. Lab 1 includes the required tenancy preparation.

| Lab | Topic | Status |
| --- | --- | --- |
| 1 | Build and Verify the Migration Environment | Required |
| 2 | Linux Command-Line Quickstart | Optional |
| 3 | Assess Readiness and Protect the Source | Required |
| 4 | Migrate to Oracle Linux | Required |
| 5 | Explore Rebootless Patching with Ksplice | Required |
| 6 | Explore Oracle Linux Kernel Choices | Required |
| 7 | OS Management Hub Quickstart on OCI | Required |
| 8 | Automate Post-Migration Verification with Oracle Linux Automation Engine | Required, followed by cleanup |

## Before delivery

Have a tenancy administrator review [Administrator setup](administrator-setup/administrator-setup.md). Supply the approved prepared-image URL privately. The repository deliberately contains no image access token. Confirm image distribution rights, availability, and expiry management before public delivery.

See [Conversion and QA notes](conversion-notes.md), [validation results](VALIDATION-RESULT.md), [Recovery](recovery/recovery.md), and [Workshop help](need-help/need-help.md).

## Content and maintenance

This is a conversion toward publish-ready delivery. Static checks do not replace an end-to-end run in a learner tenancy. No OCI resources were provisioned as part of document conversion. Preserve the pinned migration commit and checksum until a new procedure is tested. Authentic screenshots come from the completed source workshop; only the architecture diagram was redrawn for the learner-owned tenancy. Screenshot annotations use red arrows.

The source repository remains independent and unchanged. There is no FreeSQL content because this workshop teaches OS migration and administration.

## Acknowledgements

- Perside Foster, Principal Solution Engineer, Oracle
- Rosario Spiezia, Principal Sales Consultant, Oracle
- Mitch Dsouza, Principal Presales Consultant, Oracle Cloud Infrastructure Software
- Nick Mader, Global Channel Enablement & Strategy Director, Open Source Solutions, Oracle
