-- Enable uuid generator (on managed providers use gen_random_uuid via pgcrypto)
create extension if not exists pgcrypto;

create table if not exists channels (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  allowed_fields text[] not null default '{}',
  max_fields int not null default 8,
  min_write_interval_seconds int not null default 15,
  min_read_interval_seconds int not null default 5,
  created_at timestamptz not null default now()
);

create table if not exists api_keys (
  key text primary key,
  channel_id uuid not null references channels(id) on delete cascade,
  scope text not null check (scope in ('read','write','readwrite')),
  created_at timestamptz not null default now()
);

create table if not exists readings (
  id bigserial primary key,
  channel_id uuid not null references channels(id) on delete cascade,
  ts timestamptz not null default now(),
  fields jsonb not null,
  source text
);

create index if not exists idx_readings_channel_ts on readings(channel_id, ts desc);
create index if not exists idx_readings_fields_gin on readings using gin(fields);

create table if not exists workflows (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid not null references channels(id) on delete cascade,
  name text not null,
  enabled boolean not null default true,
  rule jsonb not null,
  action jsonb not null,
  created_at timestamptz not null default now()
);
