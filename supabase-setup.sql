-- วางทั้งหมดนี้ใน Supabase → SQL Editor แล้วกด Run ครั้งเดียว
create table if not exists public.app_docs (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  key text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);
alter table public.app_docs enable row level security;
create policy "own rows" on public.app_docs for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public) values ('art', 'art', true)
  on conflict (id) do nothing;
create policy "art insert own" on storage.objects for insert to authenticated
  with check (bucket_id = 'art' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "art update own" on storage.objects for update to authenticated
  using (bucket_id = 'art' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "art delete own" on storage.objects for delete to authenticated
  using (bucket_id = 'art' and (storage.foldername(name))[1] = auth.uid()::text);

-- อนุญาตให้อ่านรายการรูปของตัวเอง (จำเป็นตอนอัปโหลดทับรูปเดิม)
create policy "art select own" on storage.objects for select to authenticated
  using (bucket_id = 'art' and (storage.foldername(name))[1] = auth.uid()::text);
