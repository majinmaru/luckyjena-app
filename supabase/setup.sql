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

drop policy if exists "select own tickets" on public.lotto_tickets_cloud;
drop policy if exists "insert own tickets" on public.lotto_tickets_cloud;
drop policy if exists "update own tickets" on public.lotto_tickets_cloud;
drop policy if exists "delete own tickets" on public.lotto_tickets_cloud;

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

create table if not exists public.auth_email_index (
  email text primary key,
  created_at timestamptz not null default now()
);

alter table public.auth_email_index enable row level security;

create or replace function public.sync_auth_email_index()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    if new.email is not null then
      insert into public.auth_email_index(email)
      values (lower(new.email))
      on conflict (email) do nothing;
    end if;
    return new;
  elsif tg_op = 'UPDATE' then
    if old.email is not null and old.email <> new.email then
      delete from public.auth_email_index where email = lower(old.email);
    end if;
    if new.email is not null then
      insert into public.auth_email_index(email)
      values (lower(new.email))
      on conflict (email) do nothing;
    end if;
    return new;
  elsif tg_op = 'DELETE' then
    if old.email is not null then
      delete from public.auth_email_index where email = lower(old.email);
    end if;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists on_auth_user_created_email_index on auth.users;
drop trigger if exists on_auth_user_updated_email_index on auth.users;
drop trigger if exists on_auth_user_deleted_email_index on auth.users;

create trigger on_auth_user_created_email_index
after insert on auth.users
for each row execute function public.sync_auth_email_index();

create trigger on_auth_user_updated_email_index
after update of email on auth.users
for each row execute function public.sync_auth_email_index();

create trigger on_auth_user_deleted_email_index
after delete on auth.users
for each row execute function public.sync_auth_email_index();

insert into public.auth_email_index(email)
select lower(email)
from auth.users
where email is not null
on conflict (email) do nothing;

create or replace function public.email_exists(target_email text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.auth_email_index
    where email = lower(trim(target_email))
  );
$$;

grant execute on function public.email_exists(text) to anon, authenticated;
