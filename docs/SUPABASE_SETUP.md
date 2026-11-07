# Supabase setup for Rozay Connect

This repository contains the first database schema for the marketplace. It is a foundation only: the Flutter app is NOT connected to Supabase yet, and the schema has not been applied to a live project.

## 1. Create a Supabase project

1. Open https://supabase.com/ and sign in.
2. Create a new project named Rozay Connect.
3. Choose a strong database password and keep it private.
4. Choose a region suitable for your expected users and wait for provisioning to finish.

## 2. Apply the database migration

1. Open the project's SQL Editor.
2. Open supabase/migrations/20261107010000_initial_marketplace_schema.sql from this repository.
3. Review the SQL, paste it into the SQL Editor, and run it.
4. Confirm that seller_profiles and products exist and row-level security is enabled for both.

The policies keep new sellers and products pending. Public buyers can only read active products from verified sellers. Sellers can manage their own pending listings, but the public app cannot mark sellers or products as verified/active.

## 3. Keep credentials safe

The Flutter app will eventually need the project's Project URL and publishable key (or legacy anon key) as public client configuration. These are not administrator credentials, but database access must still be protected by row-level security.

- Never put the database password, service-role key, or secret API keys in Flutter code, GitHub source files, screenshots, or chat.
- A service-role key bypasses row-level security and must only be used by a trusted server-side environment.
- Do not enable public write access or disable row-level security to make the app work.

## 4. What is still needed

Before live listings can work, the app still needs:
- Supabase Flutter client setup using the project URL and publishable/anon key.
- Email/password or another secure authentication flow.
- Seller profile registration and product create/read/update flows.
- A trusted moderation workflow to verify sellers and approve listings.
- A product image storage bucket and upload policies.
- Tests against a real Supabase project, including attempts to access another seller's records.

## Current status

No Supabase project has been created or connected by this repository change. Do not advertise the marketplace as cloud-enabled until the Flutter integration is implemented and tested against a configured project.
