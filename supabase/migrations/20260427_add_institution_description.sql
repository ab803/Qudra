-- This migration adds a description column to institutions so the portal,
-- user app, and admin dashboard can all read and write institution details.
alter table public.institutions
add column if not exists description text;
