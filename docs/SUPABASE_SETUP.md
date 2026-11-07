# Supabase setup and operations

Rozay Connect is connected to the Supabase project used for development. This guide documents the expected configuration for a separate development or staging environment. Do not apply database changes to a live project without reviewing the migration and confirming the target project.

## Services used

- Supabase Auth: email/password accounts.
- PostgreSQL: `seller_profiles` and `products`.
- Row Level Security: seller ownership and public approved-listing access.
- Storage: `product-images`, public read, authenticated writes restricted to the user's UUID folder.
- Edge Function: `moderate-marketplace`, deployed with JWT verification enabled.

## Configure a development project

1. Create or select a Supabase project in the Supabase dashboard.
2. In Project Settings / API, copy the project URL and publishable key.
3. Configure those client-safe values in `lib/main.dart` for the development project.
4. Never put a database password, service-role key, or Supabase secret key in Flutter code, GitHub files, screenshots, or chat.
5. Apply the SQL migrations in timestamp order to a fresh development database after reviewing them.
6. Deploy the `moderate-marketplace` Edge Function with JWT verification enabled and its server-side secrets configured in the Supabase project.
7. Verify the Storage bucket and policies match the migrations.

## Access model

- New seller profiles must be created for the signed-in user's Auth UUID and start as `pending`.
- Sellers can read and update their own allowed profile fields, but cannot set their verification state to `verified`.
- New products must belong to the signed-in seller and start as `pending`.
- Public catalogue reads expose only `active` products from `verified` sellers.
- Image upload, update, and delete operations are limited to the authenticated user's UUID folder in `product-images`.
- Moderation is performed server-side. The Edge Function checks trusted `app_metadata.role` claims for `moderator` or `admin`; never authorize using user-editable `user_metadata`.

## Moderator setup

A trusted Supabase project administrator must assign the reviewer role through a secure administrative workflow. Set `app_metadata.role` to `moderator` or `admin`, then have the reviewer sign out and sign in again so the JWT contains the updated claim. Do not put role assignment in the public mobile app.

## Verify connectivity

From the environment running the app, open:

`https://<your-project-ref>.supabase.co/auth/v1/health`

A network/DNS lookup failure happens before Supabase Auth can validate an email or password. Check the emulator or host network and DNS before changing application credentials.

## End-to-end test checklist

Use dedicated test accounts and non-sensitive sample listings:

1. Register a seller account and confirm email if confirmation is enabled.
2. Sign in and submit a seller profile.
3. Confirm the profile remains pending and is not publicly listed as verified.
4. Submit a product with and without an image.
5. Confirm uploaded images are stored under the seller's own UUID folder.
6. Confirm pending products are not visible in the public catalogue.
7. Sign in with a separately authorised moderator account.
8. Approve the seller, then approve a product.
9. Confirm the approved product is visible publicly and its image loads.
10. Try seller-to-seller access and unauthorised moderation; both must be denied.

Do not use real customer data or personal information in test listings. Do not share passwords, access tokens, or secret keys.

## Important

The existence of a successful Android build does not prove that live authentication, storage, and moderation work on every network or device. Complete the end-to-end checklist in a separate test environment before any public release.
