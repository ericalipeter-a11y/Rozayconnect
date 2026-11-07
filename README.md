# Rozay Connect

Rozay Connect is a Flutter marketplace starter that helps buyers discover products and connect with sellers.

## Current features
- Seller centre prototype with seller details and product listing form.
- Save seller-created product listings on the current device so they remain after the app is closed.
- Responsive green-and-white marketplace home screen.
- Search products by name, category, or seller.
- Filter the catalogue by category.
- Product detail sheet with price, description, category, and seller.
- WhatsApp contact action only when a real seller phone number is configured.
- Clearly labelled demonstration listings; no shared fake seller phone number.

## Run locally
1. Install the Flutter stable SDK.
2. Clone this repository.
3. Run flutter pub get.
4. Run flutter run.

## Verify
    dart format --output=none --set-exit-if-changed .
    flutter analyze
    flutter test

## Build Android APK
    flutter build apk --release

The APK is created at build/app/outputs/flutter-apk/app-release.apk.

## Important prototype limitations
Seller-created listings are stored only on the device where they were created, using local app storage. They are not uploaded, shared with other users, or synchronised across devices. Clearing app data or uninstalling the app may remove them. Seller details are not registered or verified by a server, and product photos are not uploaded.

The catalogue includes demonstration products. They are not confirmed offers from real sellers. Payments, checkout, orders, buyer accounts, and seller accounts are not implemented.

## Supabase database foundation
An initial PostgreSQL schema with row-level security policies is available at supabase/migrations/20261107010000_initial_marketplace_schema.sql. Setup instructions are in docs/SUPABASE_SETUP.md.

This is a database foundation only. No live Supabase project is configured, and the Flutter app is not connected to it yet. New sellers and products remain pending until a trusted moderation process approves them.

## Before a public launch
- Configure a Supabase project and connect the Flutter app securely.
- Add secure buyer and seller authentication with role-based access.
- Add a trusted seller and listing moderation workflow.
- Add product image upload and secure storage.
- Add product reporting, moderation, and abuse prevention.
- Publish a privacy policy and terms of service that accurately describe data collection and use.
- Add order and payment flows only after secure integration and testing.
- Complete end-to-end testing, accessibility checks, and release monitoring.

## Roadmap
- Connect the Flutter app to the shared Supabase database so listings sync across users and devices.
- Add buyer and seller accounts with role-based access.
- Add seller dashboards, verified listings, and product images.
- Add favourites, cart, orders, and optional payment integration.
- Add moderation, reporting, analytics, and release monitoring.
