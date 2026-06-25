-- ════════════════════════════════════════════════
--  活动报名表 · Supabase 建表脚本
--  用法：Supabase 项目 → 左侧 SQL Editor → 粘贴 → Run
-- ════════════════════════════════════════════════

create table food_signups (
  id uuid default gen_random_uuid() primary key,
  name text not null,          -- 报名人姓名
  food_item text not null,     -- 带什么
  category text not null,      -- 分类（主食/饮料/零食水果/甜点蛋糕）
  quantity text not null,      -- 数量（自由文本，如"10个""2升"）
  note text,                   -- 备注（可选）
  created_at timestamptz default now()
);

-- 开启行级安全 + 允许任何人读写（活动报名场景够用）
alter table food_signups enable row level security;
create policy "open" on food_signups for all using (true) with check (true);
