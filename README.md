# Rozay Connect

Rozay Connect is a Flutter marketplace project for discovering products and connecting buyers with sellers through direct WhatsApp contact.

## Implemented

- Flutter marketplace catalogue with product search and category filters.
- Email/password authentication through Supabase Auth.
- Seller profile submission with pending, verified, and rejected states.
- Product submissions with NGN pricing, descriptions, categories, and optional photos.
- Product image uploads to the Supabase Storage `product-images` bucket.
- Public catalogue reads restricted to active products from verified sellers.
- Moderator review queue for seller profiles and product submissions.
- Server-side moderation through the `moderate-marketplace` Supabase Edge Function.
- GitHub Actions checks for Dart formatting, Flutter analysis, tests, and Android release builds.

## Technology

- Flutter / Dart
- Supabase Auth, PostgreSQL, Row Level Security, Storage, and Edge Functions
- GitHub Actions

## Run locally

1. Install the current stable Flutter SDK and Android tooling.
2. Clone this repository and enter the project directory.
3. Run `flutter pub get`.
4. Run `flutter run` on an Android device or emulator.

The app's Supabase project URL and publishable key are configured in `lib/main.dart`. A publishable key is intended for client applications; never add a Supabase secret/service-role key to Flutter code.

## Quality checks

Run these commands before submitting changes:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release
```

GitHub Actions runs formatting, static analysis, automated tests, and an Android release APK build on pull requests.

## Backend and security model

The SQL files in `supabase/migrations/` currently contain incremental table-privilege, Row Level Security policy, and Storage bucket/policy changes. **They are not a complete from-scratch database schema.** The base `seller_profiles` and `products` table definitions and any required constraints must be exported from and reviewed against the intended Supabase project before a new environment can be provisioned. See [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md).

The app uses:

- Supabase Auth for account registration and sign-in.
- Row Level Security to restrict seller records to their owner and public product visibility to approved listings.
- Pending-by-default seller profiles and product submissions.
- A trusted moderator Edge Function. Moderator privileges are read from trusted Auth `app_metadata.role` claims, not user-editable metadata.
- A public-read image bucket with authenticated uploads restricted to the owner's UUID folder.

The deployed moderation function requires a valid JWT. A trusted project administrator must assign `moderator` or `admin` in Auth app metadata to a reviewer account. The mobile app must never be given a service-role or secret key.

## Current scope and limitations

- This is an active development project, not a production-certified marketplace.
- Real-world seller onboarding and moderator approval still require end-to-end testing with separate accounts.
- The Android app's Supabase connection depends on the test environment's DNS and internet access.
- Checkout, payments, order fulfilment, refunds, and dispute handling are not implemented.
- The current automated test suite is a small widget-test suite; comprehensive backend integration, security, and device tests remain outstanding.
- The project has no declared open-source license. Do not assume third parties have permission to reuse or commercially exploit the code.
- Confirm ownership and permissions for all contributors, dependencies, generated code, and third-party assets before any commercial licensing discussion.

## Repository readiness

See [docs/REPOSITORY_READINESS.md](docs/REPOSITORY_READINESS.md) for the current technical, provenance, and submission-readiness checklist. See [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md) for backend configuration and safe testing guidance.
