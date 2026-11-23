-- MARKET X 3.1: per-user cloud watchlists
-- Run this once in Supabase Dashboard -> SQL Editor.

create table if not exists public.watchlist (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  symbol text not null check (symbol ~ '^[A-Z0-9._&-]+:[A-Z0-9._&-]{1,40}$'),
  created_at timestamptz not null default now(),
  constraint watchlist_user_symbol_unique unique (user_id, symbol)
);

alter table public.watchlist enable row level security;

-- A signed-in user can only read their own rows.
 drop policy if exists "Users can read their own watchlist" on public.watchlist;
create policy "Users can read their own watchlist"
  on public.watchlist for select
  to authenticated
  using (auth.uid() = user_id);

-- A signed-in user can only add rows owned by their own account.
drop policy if exists "Users can add to their own watchlist" on public.watchlist;
create policy "Users can add to their own watchlist"
  on public.watchlist for insert
  to authenticated
  with check (auth.uid() = user_id);

-- A signed-in user can only remove their own rows.
drop policy if exists "Users can delete from their own watchlist" on public.watchlist;
create policy "Users can delete from their own watchlist"
  on public.watchlist for delete
  to authenticated
  using (auth.uid() = user_id);

grant select, insert, delete on public.watchlist to authenticated;
revoke all on public.watchlist from anon;
