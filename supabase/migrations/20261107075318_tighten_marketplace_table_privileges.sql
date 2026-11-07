-- Tighten Data API table privileges and combine public/owner read policies.
-- This migration mirrors the deployed marketplace access model.

revoke all on table public.seller_profiles from anon, authenticated;
revoke all on table public.products from anon, authenticated;

grant select on table public.seller_profiles to anon;
grant select on table public.products to anon;

grant select, insert, update on table public.seller_profiles to authenticated;
grant select, insert, update, delete on table public.products to authenticated;

drop policy if exists "Verified seller profiles are public" on public.seller_profiles;
drop policy if exists "Sellers can read their own profile" on public.seller_profiles;
create policy "Public verified profiles and own seller profile"
  on public.seller_profiles
  for select
  using (
    verification_status = 'verified'
    or (
      (select auth.uid()) is not null
      and id = (select auth.uid())
    )
  );

drop policy if exists "Verified active products are public" on public.products;
drop policy if exists "Sellers can read their own products" on public.products;
create policy "Public active products and own seller products"
  on public.products
  for select
  using (
    (
      status = 'active'
      and exists (
        select 1
        from public.seller_profiles
        where seller_profiles.id = products.seller_id
          and seller_profiles.verification_status = 'verified'
      )
    )
    or (
      (select auth.uid()) is not null
      and seller_id = (select auth.uid())
    )
  );
