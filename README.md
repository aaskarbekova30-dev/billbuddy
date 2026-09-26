# BillBuddy

Flutter expense tracker backed by Supabase.

## Fresh Supabase setup

1. Create a new Supabase project.
2. Open `SQL Editor` and run [`supabase/schema.sql`](supabase/schema.sql).
3. In `Authentication > Providers`, enable Email. Google Provider is not required by the app.
4. In `Authentication > URL Configuration`, add `io.supabase.billbuddy://login-callback/`.
5. In Google Cloud OAuth settings, add `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback` as an authorized redirect URI.
6. Replace the Supabase URL and publishable key in [`lib/main.dart`](lib/main.dart).

The schema creates `profiles`, `groups`, `expenses`, and `subscriptions`, enables row-level security, creates a profile for every new auth user, and enables the account-deletion RPC.

The schema is intended for a fresh database. Do not run it against an existing production database without a backup and migration plan.
