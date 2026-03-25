create table if not exists public.lotto_tickets_cloud (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  ticket_id text not null,
  ticket jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, ticket_id)
);

create index if not exists lotto_tickets_cloud_user_id_idx
  on public.lotto_tickets_cloud (user_id);

alter table public.lotto_tickets_cloud enable row level security;

create policy "select own tickets"
on public.lotto_tickets_cloud
for select
using (auth.uid() = user_id);

create policy "insert own tickets"
on public.lotto_tickets_cloud
for insert
with check (auth.uid() = user_id);

create policy "update own tickets"
on public.lotto_tickets_cloud
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "delete own tickets"
on public.lotto_tickets_cloud
for delete
using (auth.uid() = user_id);
