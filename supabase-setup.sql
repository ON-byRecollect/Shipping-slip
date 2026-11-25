-- のべるん：クラウド保存用テーブル
-- Supabase ダッシュボード → SQL Editor に貼り付けて「Run」を押してください（1回だけ）。

create table if not exists public.novel_works (
  id          text primary key,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  data        jsonb not null default '{}'::jsonb,
  updated_at  bigint not null,
  deleted     boolean not null default false,
  created_at  timestamptz not null default now()
);

create index if not exists novel_works_user_id_idx on public.novel_works (user_id);

-- ログインした本人の作品だけを読み書きできるようにする（行レベルセキュリティ）
alter table public.novel_works enable row level security;

drop policy if exists "novel_works_select_own" on public.novel_works;
drop policy if exists "novel_works_insert_own" on public.novel_works;
drop policy if exists "novel_works_update_own" on public.novel_works;
drop policy if exists "novel_works_delete_own" on public.novel_works;

create policy "novel_works_select_own" on public.novel_works
  for select to authenticated using (user_id = auth.uid());
create policy "novel_works_insert_own" on public.novel_works
  for insert to authenticated with check (user_id = auth.uid());
create policy "novel_works_update_own" on public.novel_works
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "novel_works_delete_own" on public.novel_works
  for delete to authenticated using (user_id = auth.uid());

-- ログインしていない人（anon）には一切アクセスさせない
revoke all on public.novel_works from anon;
grant select, insert, update, delete on public.novel_works to authenticated;
