# Repository readiness and provenance

This document records observable repository facts and work still needed before presenting Rozay Connect for an external technical or licensing evaluation. It is deliberately factual; it does not claim buyer acceptance or a valuation.

## Current snapshot

- Product: Flutter / Dart multi-vendor marketplace.
- Backend: Supabase Auth, PostgreSQL with Row Level Security, Storage, and a JWT-protected moderation Edge Function.
- CI: GitHub Actions runs formatting, analysis, widget tests, and an Android release build.
- Automated tests: currently a small widget-test suite. It is not a comprehensive integration or security test suite.
- Runtime validation: end-to-end seller and moderator workflows still need to be exercised with separate test accounts and a working network.
- Commercial scope: no checkout, payments, order management, refunds, or dispute workflows are implemented.

## Observed repository facts

At the time this checklist was written, the GitHub repository is public, has no declared repository license, and its visible history begins in November 2026. The project has a short development history and a small source tree. These facts may materially affect an evaluator looking for a substantial, private, proprietary engineering corpus.

Do not hide the repository's public history, invent older development activity, inflate line counts, fabricate reviews, or misrepresent who wrote the code. Changes made with AI assistance should be described honestly if an evaluator asks.

## Ownership and licensing checks

Before any code or history is submitted to a third party:

- Confirm who owns the project and has authority to license it.
- Identify every human contributor and obtain any required written permissions.
- Identify AI-assisted or generated contributions honestly.
- Inventory dependencies, templates, copied snippets, fonts, icons, images, and other third-party assets with their licenses.
- Scan the complete Git history, all branches, and tags for credentials, tokens, private keys, personal information, and customer data.
- Rotate any credential that was ever committed; deleting it from the latest version does not invalidate an exposed secret.
- Do not add an open-source license or grant commercial rights until the rights holder has reviewed and approved the terms.

## Engineering work still recommended

- Add a committed, reviewed dependency lockfile so builds are reproducible.
- Expand tests to cover authentication states, seller ownership, listing submission, image upload errors, moderation permissions, and public visibility.
- Add staging-backed integration tests that verify Row Level Security and Storage policies using separate roles.
- Verify migrations can create the backend from an empty staging project.
- Add a release process with versioning, changelog, and reproducible build instructions.
- Add privacy, data-retention, abuse-reporting, and operational documentation before a public marketplace launch.
- Obtain an independent code/security review.

## External evaluation

A clean build and passing tests are positive engineering evidence, but they do not guarantee acceptance or payment. Any external evaluator may apply additional requirements for privacy, provenance, scale, uniqueness, rights, and commercial fit. Review any proposed data-access or licensing agreement with a parent/guardian and an appropriately qualified adult before signing or granting access.
