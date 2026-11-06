# Rozay Connect

Rozay Connect is a Flutter marketplace starter that helps buyers discover products and connect with sellers.

## Current features
- Responsive green-and-white marketplace home screen.
- Search products by name, category, or seller.
- Filter the catalogue by category.
- Product detail sheet with price, description, category, and seller.
- WhatsApp contact action only when a real seller phone number is configured.
- Clearly labelled demonstration listings; no shared fake seller phone number.

## Run locally
1. Install the Flutter stable SDK.
2. Clone this repository.
3. Run `flutter pub get`.
4. Run `flutter run`.

## Verify
```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Build Android APK
```sh
flutter build apk --release
```
The APK is created at `build/app/outputs/flutter-apk/app-release.apk`.

## Before a public launch
This repository currently uses local demonstration product data. A production launch still needs a secure backend and database, seller registration and verification, authentication, image uploads/storage, real seller contact details, moderation/reporting, privacy policy and terms, and end-to-end testing. Payments and order management are not implemented and must not be advertised as available until built and tested.

## Roadmap
- Connect a secure marketplace API and persistent database.
- Add buyer and seller accounts with role-based access.
- Add seller dashboards, verified listings, and product images.
- Add favourites, cart, orders, and optional payment integration.
- Add moderation, reporting, analytics, and release monitoring.
