# Supabase setup and operations

The Flutter app is configured with a Supabase project URL and publishable client key in `lib/main.dart`. A publishable key is designed to be included in a client app, but its presence does **not** prove that the project is reachable, that the database schema is correct, or that the Edge Function and Storage policies are deployed. Those runtime checks must be completed against the intended project.

Do not apply database changes to a live project without reviewing the migration and confirming the target project. Prefer a separate development or staging project.

## Services used

- Supabase Auth: email/password accounts.
- PostgreSQL: `seller_profiles` and `products`.
- Row Level Security: seller ownership and public approved-listing access.
- Storage: `product-images`, public read, authenticated writes restricted to the user's UUID folder.
- Edge Function: `moderate-marketplace`, deployed with JWT verification enabled.

## Important schema prerequisite

The migration files currently in this repository are **incremental hardening/configuration migrations**. They alter privileges and policies on existing tables and configure the image bucket. They do not create the complete base `seller_profiles` and `products` tables, their columns, constraints, indexes, or every original policy.

Therefore, do not run these migrations against an empty project and assume that it creates a working backend. Before provisioning a new development/staging project:

1. Export the current intended project's schema using a trusted Supabase administrative workflow, excluding customer data and secrets.
2. Review the exported schema and confirm it contains the required tables, columns, constraints, indexes, and baseline policies.
3. Store a reviewed, reproducible baseline migration in the repository.
4. Apply the baseline first, then apply the incremental migrations in timestamp order.
5. Test the complete setup against a disposable staging project before touching production.

The baseline schema export has not yet been committed to this repository.

## Configure a development project

1. Create or select a separate development/staging Supabase project.
2. In Project Settings / API, copy the project URL and publishable key.
3. Configure those client-safe values in `lib/main.dart` for the development project. Do not commit secret keys.
4. Review and apply the complete schema baseline, once it has been exported and committed.
5. Apply the SQL migrations in timestamp order.
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

A successful Android build does not prove that live authentication, storage, and moderation work on every network or device. Complete the end-to-end checklist in a separate test environment before any public release.
