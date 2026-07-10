-- ============================================================================
-- REMI — SUPABASE SCHEMA (DRAFT v1)
-- Dựa trên: RFC-004 (Canonical Entities), RFC-005 (Ownership & Permission),
--           RFC-006 (AI Memory), RFC-007 (AI Follow-up), RFC-008 (Property Match),
--           RFC-009 (Navigation & Theme — không ảnh hưởng schema),
--           RFC-010 (Notification tối thiểu)
-- Phạm vi: 4 module lõi Giai đoạn 1 (AI CRM, AI Memory, Property, AI Follow-up)
-- Trạng thái: NHÁP — cần Backend Dev review trước khi chạy trên production
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. EXTENSIONS
-- ----------------------------------------------------------------------------
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";   -- gen_random_uuid()
create extension if not exists "vector";     -- pgvector, dùng cho RFC-006 (embedding)

-- ----------------------------------------------------------------------------
-- 1. ENUM TYPES
-- ----------------------------------------------------------------------------

-- RFC-004 Mục 4 — Pipeline. Giai đoạn 2 mở rộng thêm 'deposited','deal_closed'
-- nhưng khai báo sẵn ở đây để không phải ALTER TYPE giữa chừng.
create type pipeline_status as enum (
  'new',                -- Mới
  'nurturing',          -- Đang chăm sóc
  'qualified',          -- Có nhu cầu rõ
  'viewing_scheduled',  -- Đã hẹn xem property
  'deposited',          -- (dự trù Giai đoạn 2) Đã cọc
  'deal_closed'         -- (dự trù Giai đoạn 2) Đã giao dịch
);

-- RFC-005 Mục 3 — Role trong quan hệ sở hữu
create type ownership_role as enum ('owner', 'collaborator', 'viewer');

-- RFC-006 Mục 3 & 4 — AI Memory
create type memory_confidence as enum ('low', 'medium', 'high');
create type memory_status as enum ('proposed', 'confirmed', 'conflicting', 'archived');

-- RFC-008 Mục 4 & 5 — Property Match
create type match_created_by as enum ('system', 'manual');
create type match_status as enum ('suggested', 'sent', 'viewed', 'rejected', 'archived');

-- RFC-007 Mục 5 — Task
create type task_source as enum ('ai_follow_up', 'manual');
create type task_status as enum ('pending', 'confirmed', 'dismissed', 'snoozed');

-- RFC-010 Mục 2, 3, 5 — Notification
create type notification_type as enum ('task_due', 'match_needs_attention');
create type notification_channel as enum ('in_app'); -- mở rộng kênh ở Giai đoạn 2
create type notification_status as enum ('unread', 'read', 'actioned');

-- ----------------------------------------------------------------------------
-- 2. BROKERS (hồ sơ môi giới, gắn với Supabase Auth)
-- ----------------------------------------------------------------------------
create table public.brokers (
  id           uuid primary key references auth.users(id) on delete cascade,
  full_name    text not null,
  phone        text,
  segment      text,          -- phân khúc chính, VD: 'đất nền', 'nhà phố thổ cư'
  region       text,          -- khu vực hoạt động, VD: 'Rạch Giá, Kiên Giang'
  created_at   timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 3. LEADS (RFC-004 Mục 3.1)
-- ----------------------------------------------------------------------------
create table public.leads (
  id               uuid primary key default gen_random_uuid(),
  full_name        text not null,
  phone            text,
  source           text not null default 'manual',   -- nhập tay, theo phạm vi 90 ngày
  pipeline_status  pipeline_status not null default 'new',
  segment          text,        -- đất nền / nhà phố
  region           text,        -- khu vực quan tâm
  budget           numeric check (budget is null or budget >= 0),
  is_active        boolean not null default true,    -- "Đóng/Ngừng" thay vì xóa cứng
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- Ownership của Lead — bảng QUAN HỆ riêng (RFC-005 Mục 2), KHÔNG gắn broker_id
-- trực tiếp vào bảng leads.
create table public.lead_ownerships (
  id           uuid primary key default gen_random_uuid(),
  lead_id      uuid not null references public.leads(id) on delete cascade,
  broker_id    uuid not null references public.brokers(id) on delete cascade,
  role         ownership_role not null default 'owner',
  granted_at   timestamptz not null default now(),
  revoked_at   timestamptz    -- NULL = đang hiệu lực; transfer = revoke cũ + tạo dòng mới
);

-- Giai đoạn 1: mỗi Lead chỉ có đúng 1 Owner đang hiệu lực tại một thời điểm
-- (RFC-005 Mục 3). Ràng buộc này KHÔNG cản trở việc thêm Collaborator/Viewer
-- ở Giai đoạn 2 vì chỉ áp dụng cho role = 'owner'.
create unique index uq_lead_single_active_owner
  on public.lead_ownerships (lead_id)
  where role = 'owner' and revoked_at is null;

create index idx_lead_ownerships_broker on public.lead_ownerships (broker_id) where revoked_at is null;

-- ----------------------------------------------------------------------------
-- 4. PROPERTIES (RFC-004 Mục 3.6)
-- ----------------------------------------------------------------------------
create table public.properties (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  property_type  text not null,   -- 'đất nền' / 'nhà phố'
  region         text not null,   -- VD: 'Rạch Giá, Kiên Giang'
  price          numeric not null check (price >= 0),
  legal_status   text,            -- cơ bản, chưa OCR (RFC-004)
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Ownership của Property — cùng mô hình quan hệ như Lead (RFC-005 Mục 2)
create table public.property_ownerships (
  id           uuid primary key default gen_random_uuid(),
  property_id  uuid not null references public.properties(id) on delete cascade,
  broker_id    uuid not null references public.brokers(id) on delete cascade,
  role         ownership_role not null default 'owner',
  granted_at   timestamptz not null default now(),
  revoked_at   timestamptz
);

create unique index uq_property_single_active_owner
  on public.property_ownerships (property_id)
  where role = 'owner' and revoked_at is null;

create index idx_property_ownerships_broker on public.property_ownerships (broker_id) where revoked_at is null;

-- ----------------------------------------------------------------------------
-- 5. ROLE_PERMISSIONS — bảng cấu hình quyền (RFC-005 Mục 4)
-- Quyền là DỮ LIỆU, không hard-code trong logic ứng dụng.
-- ----------------------------------------------------------------------------
create table public.role_permissions (
  role     ownership_role not null,
  action   text not null,   -- 'view','edit','delete','transfer_owner','invite_collaborator','confirm_task'
  allowed  boolean not null default false,
  primary key (role, action)
);

insert into public.role_permissions (role, action, allowed) values
  ('owner',        'view',                true),
  ('owner',        'edit',                true),
  ('owner',        'delete',              true),
  ('owner',        'transfer_owner',      true),
  ('owner',        'invite_collaborator', true),
  ('owner',        'confirm_task',        true),
  ('collaborator', 'view',                true),
  ('collaborator', 'edit',                true),   -- giới hạn chi tiết hơn sẽ tinh chỉnh ở RFC Co-op
  ('collaborator', 'delete',              false),
  ('collaborator', 'transfer_owner',      false),
  ('collaborator', 'invite_collaborator', false),
  ('collaborator', 'confirm_task',        true),
  ('viewer',       'view',                true),
  ('viewer',       'edit',                false),
  ('viewer',       'delete',              false),
  ('viewer',       'transfer_owner',      false),
  ('viewer',       'invite_collaborator', false),
  ('viewer',       'confirm_task',        false);

-- ----------------------------------------------------------------------------
-- 6. CONVERSATIONS (RFC-004 Mục 3.3) — dữ liệu thô
-- ----------------------------------------------------------------------------
create table public.conversations (
  id            uuid primary key default gen_random_uuid(),
  lead_id       uuid not null references public.leads(id) on delete cascade,
  broker_id     uuid references public.brokers(id),   -- người ghi nhận
  raw_content   text not null,
  occurred_at   timestamptz not null default now(),
  created_at    timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 7. AI_MEMORIES (RFC-006) — dữ liệu đã suy luận, truy vết được nguồn
-- ----------------------------------------------------------------------------
create table public.ai_memories (
  id                       uuid primary key default gen_random_uuid(),
  lead_id                  uuid not null references public.leads(id) on delete cascade,
  source_conversation_id   uuid not null references public.conversations(id),
  content                  text not null,
  confidence               memory_confidence not null,
  status                   memory_status not null default 'proposed',
  embedding                vector(1024),   -- Voyage AI voyage-4-lite, output_dimension mặc định = 1024
  extracted_at             timestamptz not null default now(),
  confirmed_at             timestamptz,
  confirmed_by             uuid references public.brokers(id),
  created_at               timestamptz not null default now()
);

create index idx_ai_memories_lead on public.ai_memories (lead_id);
create index idx_ai_memories_embedding on public.ai_memories using ivfflat (embedding vector_cosine_ops);

-- RFC-006 Mục 2 + Mục 8.2: không cho phép sửa nội dung Memory đã Confirmed —
-- mọi thay đổi phải tạo bản ghi mới, bản cũ chuyển Archived. Enforce ở DB layer:
create or replace function public.prevent_confirmed_memory_edit()
returns trigger as $$
begin
  if OLD.status = 'confirmed' and NEW.content is distinct from OLD.content then
    raise exception 'Không được sửa nội dung AI Memory đã Confirmed (RFC-006). Hãy tạo bản ghi mới và chuyển bản cũ sang Archived.';
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger trg_prevent_confirmed_memory_edit
  before update on public.ai_memories
  for each row execute function public.prevent_confirmed_memory_edit();

-- ----------------------------------------------------------------------------
-- 8. TIMELINE_EVENTS (RFC-004 Mục 3.4) — view đã diễn giải, không xóa
-- ----------------------------------------------------------------------------
create table public.timeline_events (
  id           uuid primary key default gen_random_uuid(),
  lead_id      uuid not null references public.leads(id) on delete cascade,
  event_type   text not null,   -- 'pipeline_change' | 'ownership_transfer' | 'match_status_change' | 'memory_confirmed' | 'task_confirmed' | ...
  description  text,
  metadata     jsonb,
  occurred_at  timestamptz not null default now(),
  created_by   uuid references public.brokers(id)
);

create index idx_timeline_events_lead on public.timeline_events (lead_id, occurred_at desc);

-- ----------------------------------------------------------------------------
-- 9. DOCUMENTS (RFC-004 Mục 3.5) — chỉ lưu trữ, chưa OCR
-- ----------------------------------------------------------------------------
create table public.documents (
  id            uuid primary key default gen_random_uuid(),
  lead_id       uuid not null references public.leads(id) on delete cascade,
  file_path     text not null,   -- đường dẫn Supabase Storage
  file_type     text,
  uploaded_by   uuid references public.brokers(id),
  created_at    timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 10. PROPERTY_MATCHES (RFC-008) — entity trung gian giàu ngữ cảnh
-- ----------------------------------------------------------------------------
create table public.property_matches (
  id                uuid primary key default gen_random_uuid(),
  lead_id           uuid not null references public.leads(id) on delete cascade,
  property_id       uuid not null references public.properties(id) on delete cascade,
  created_by        match_created_by not null default 'system',
  status            match_status not null default 'suggested',
  match_score       numeric check (match_score is null or (match_score >= 0 and match_score <= 100)),
  matched_criteria  jsonb,         -- VD: {"region": true, "type": true, "budget_within_pct": 15}
  sent_at           timestamptz,
  viewed_at         timestamptz,   -- ghi nhận thủ công bởi môi giới ở Giai đoạn 1 (RFC-008 Mục 5)
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index idx_property_matches_lead on public.property_matches (lead_id);
create index idx_property_matches_property on public.property_matches (property_id);

-- ----------------------------------------------------------------------------
-- 11. TASKS (RFC-004 Mục 3.8, RFC-007) — nguồn North Star Metric chính thức
-- ----------------------------------------------------------------------------
create table public.tasks (
  id              uuid primary key default gen_random_uuid(),
  lead_id         uuid not null references public.leads(id) on delete cascade,
  title           text not null,
  description     text,
  source          task_source not null default 'manual',
  generated_from  jsonb,     -- VD: {"pipeline_status":"nurturing","memory_id":"...","match_id":"..."}
  status          task_status not null default 'pending',
  confirmed_at    timestamptz,
  confirmed_by    uuid references public.brokers(id),
  due_at          timestamptz,
  created_at      timestamptz not null default now()
);

create index idx_tasks_lead on public.tasks (lead_id);
create index idx_tasks_status_due on public.tasks (status, due_at);

-- RFC-007 Mục 5: trạng thái Confirmed không được sửa lại (dữ liệu gốc cho báo cáo Beta)
create or replace function public.prevent_confirmed_task_edit()
returns trigger as $$
begin
  if OLD.status = 'confirmed' and (NEW.confirmed_at is distinct from OLD.confirmed_at) then
    raise exception 'Không được sửa confirmed_at của Task đã Confirmed (RFC-007).';
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger trg_prevent_confirmed_task_edit
  before update on public.tasks
  for each row execute function public.prevent_confirmed_task_edit();

-- ----------------------------------------------------------------------------
-- 12. NOTIFICATIONS (RFC-010) — tối thiểu, kênh in_app duy nhất
-- ----------------------------------------------------------------------------
create table public.notifications (
  id            uuid primary key default gen_random_uuid(),
  broker_id     uuid not null references public.brokers(id) on delete cascade,  -- người nhận
  lead_id       uuid references public.leads(id) on delete cascade,
  task_id       uuid references public.tasks(id) on delete cascade,
  match_id      uuid references public.property_matches(id) on delete cascade,
  type          notification_type not null,
  channel       notification_channel not null default 'in_app',
  status        notification_status not null default 'unread',
  content       text not null,
  created_at    timestamptz not null default now(),
  read_at       timestamptz,
  actioned_at   timestamptz
);

create index idx_notifications_broker_status on public.notifications (broker_id, status);

-- ----------------------------------------------------------------------------
-- 13. TIỆN ÍCH: updated_at tự động
-- ----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger as $$
begin
  NEW.updated_at = now();
  return NEW;
end;
$$ language plpgsql;

create trigger trg_leads_updated_at before update on public.leads
  for each row execute function public.set_updated_at();
create trigger trg_properties_updated_at before update on public.properties
  for each row execute function public.set_updated_at();
create trigger trg_property_matches_updated_at before update on public.property_matches
  for each row execute function public.set_updated_at();

-- ============================================================================
-- 14. ROW LEVEL SECURITY
-- ============================================================================

alter table public.brokers            enable row level security;
alter table public.leads              enable row level security;
alter table public.lead_ownerships    enable row level security;
alter table public.properties         enable row level security;
alter table public.property_ownerships enable row level security;
alter table public.conversations      enable row level security;
alter table public.ai_memories        enable row level security;
alter table public.timeline_events    enable row level security;
alter table public.documents          enable row level security;
alter table public.property_matches   enable row level security;
alter table public.tasks              enable row level security;
alter table public.notifications      enable row level security;

-- ---- BROKERS: chỉ xem/sửa hồ sơ của chính mình ----
create policy brokers_self_select on public.brokers
  for select using (id = auth.uid());
create policy brokers_self_update on public.brokers
  for update using (id = auth.uid());

-- ---- LEADS ----
-- SELECT: broker phải có ownership đang hiệu lực (bất kỳ role nào)
create policy leads_select on public.leads
  for select using (
    exists (
      select 1 from public.lead_ownerships lo
      where lo.lead_id = leads.id
        and lo.broker_id = auth.uid()
        and lo.revoked_at is null
    )
  );

-- INSERT: broker đã đăng nhập đều tạo được Lead mới
-- (ownership Owner được gán tự động qua trigger bên dưới)
create policy leads_insert on public.leads
  for insert with check (auth.uid() is not null);

-- UPDATE: quyền 'edit' theo role_permissions (RFC-005 Mục 4)
create policy leads_update on public.leads
  for update using (
    exists (
      select 1 from public.lead_ownerships lo
      join public.role_permissions rp on rp.role = lo.role and rp.action = 'edit'
      where lo.lead_id = leads.id
        and lo.broker_id = auth.uid()
        and lo.revoked_at is null
        and rp.allowed = true
    )
  );

-- KHÔNG tạo policy DELETE cho leads → mặc định chặn hoàn toàn.
-- Đây là cách enforce nguyên tắc "Lead không bị xóa cứng" (RFC-004) ngay ở DB layer.

-- Trigger tự động tạo dòng Owner khi tạo Lead mới
create or replace function public.create_owner_on_lead_insert()
returns trigger as $$
begin
  insert into public.lead_ownerships (lead_id, broker_id, role)
  values (NEW.id, auth.uid(), 'owner');
  return NEW;
end;
$$ language plpgsql security definer;

create trigger trg_create_owner_on_lead_insert
  after insert on public.leads
  for each row execute function public.create_owner_on_lead_insert();

-- ---- LEAD_OWNERSHIPS ----
-- Chỉ Owner hiện tại được xem/thêm dòng ownership (mời Collaborator ở Giai đoạn 2,
-- transfer ở mọi giai đoạn). Giữ đơn giản ở Giai đoạn 1: broker chỉ xem dòng của mình.
create policy lead_ownerships_select on public.lead_ownerships
  for select using (broker_id = auth.uid());

create policy lead_ownerships_insert on public.lead_ownerships
  for insert with check (
    exists (
      select 1 from public.lead_ownerships lo
      join public.role_permissions rp on rp.role = lo.role and rp.action = 'invite_collaborator'
      where lo.lead_id = lead_ownerships.lead_id
        and lo.broker_id = auth.uid()
        and lo.revoked_at is null
        and rp.allowed = true
    )
    or lead_ownerships.role = 'owner'  -- cho phép trigger tạo Owner ban đầu
  );

-- ---- PROPERTIES (đối xứng với LEADS) ----
create policy properties_select on public.properties
  for select using (
    exists (
      select 1 from public.property_ownerships po
      where po.property_id = properties.id
        and po.broker_id = auth.uid()
        and po.revoked_at is null
    )
  );

create policy properties_insert on public.properties
  for insert with check (auth.uid() is not null);

create policy properties_update on public.properties
  for update using (
    exists (
      select 1 from public.property_ownerships po
      join public.role_permissions rp on rp.role = po.role and rp.action = 'edit'
      where po.property_id = properties.id
        and po.broker_id = auth.uid()
        and po.revoked_at is null
        and rp.allowed = true
    )
  );

create or replace function public.create_owner_on_property_insert()
returns trigger as $$
begin
  insert into public.property_ownerships (property_id, broker_id, role)
  values (NEW.id, auth.uid(), 'owner');
  return NEW;
end;
$$ language plpgsql security definer;

create trigger trg_create_owner_on_property_insert
  after insert on public.properties
  for each row execute function public.create_owner_on_property_insert();

create policy property_ownerships_select on public.property_ownerships
  for select using (broker_id = auth.uid());

-- ---- CONVERSATIONS / AI_MEMORIES / TIMELINE_EVENTS / DOCUMENTS ----
-- Cùng một khuôn mẫu: truy cập qua lead_ownerships (RFC-006 Mục 5 — dùng chung
-- policy với Lead, không viết logic quyền riêng cho AI Memory).

create policy conversations_select on public.conversations
  for select using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = conversations.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );
create policy conversations_insert on public.conversations
  for insert with check (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = conversations.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );

create policy ai_memories_select on public.ai_memories
  for select using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = ai_memories.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );
-- UPDATE bị chặn thêm bởi trigger prevent_confirmed_memory_edit ở trên
create policy ai_memories_update on public.ai_memories
  for update using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = ai_memories.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );

create policy timeline_events_select on public.timeline_events
  for select using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = timeline_events.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );
-- KHÔNG tạo policy UPDATE/DELETE cho timeline_events → chỉ ghi thêm (append-only),
-- đúng tinh thần "Timeline không xóa" (RFC-004).

create policy documents_select on public.documents
  for select using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = documents.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );
create policy documents_insert on public.documents
  for insert with check (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = documents.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );

-- ---- PROPERTY_MATCHES ----
-- Quyền xem: broker sở hữu Lead HOẶC sở hữu Property trong match đó.
create policy property_matches_select on public.property_matches
  for select using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = property_matches.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
    or exists (select 1 from public.property_ownerships po
               where po.property_id = property_matches.property_id
                 and po.broker_id = auth.uid() and po.revoked_at is null)
  );
create policy property_matches_insert on public.property_matches
  for insert with check (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = property_matches.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );
create policy property_matches_update on public.property_matches
  for update using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = property_matches.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );

-- ---- TASKS ----
create policy tasks_select on public.tasks
  for select using (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = tasks.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );
create policy tasks_insert on public.tasks
  for insert with check (
    exists (select 1 from public.lead_ownerships lo
            where lo.lead_id = tasks.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null)
  );
-- UPDATE cần quyền 'confirm_task' (RFC-005 Mục 4) khi đổi sang Confirmed;
-- đơn giản hóa ở Giai đoạn 1: mọi ownership hợp lệ được sửa Task, trigger đã
-- chặn riêng việc sửa lại confirmed_at sau khi Confirmed.
create policy tasks_update on public.tasks
  for update using (
    exists (select 1 from public.lead_ownerships lo
            join public.role_permissions rp on rp.role = lo.role and rp.action = 'confirm_task'
            where lo.lead_id = tasks.lead_id
              and lo.broker_id = auth.uid() and lo.revoked_at is null
              and rp.allowed = true)
  );

-- ---- NOTIFICATIONS ----
-- Chỉ broker nhận thông báo mới xem/sửa được — không đi qua ownership Lead,
-- vì thông báo là cá nhân của người nhận.
create policy notifications_select on public.notifications
  for select using (broker_id = auth.uid());
create policy notifications_update on public.notifications
  for update using (broker_id = auth.uid());

-- ============================================================================
-- HẾT SCHEMA NHÁP v1 (đã cập nhật: embedding = Voyage AI voyage-4-lite, 1024 chiều)
-- Việc còn lại cho Backend Dev trước khi chạy thật:
--   1. Viết test RLS (đăng nhập broker A, kiểm tra không thấy Lead của broker B)
--      TRƯỚC khi có nhiều người dùng thật — theo cảnh báo đã nêu khi chọn Supabase.
--   2. Cân nhắc Supabase Storage bucket + policy riêng cho bảng `documents`
--      (RLS ở trên chỉ áp dụng bảng metadata, chưa áp dụng file thật trong Storage).
--   3. Hàm transfer ownership (revoke dòng cũ + tạo dòng mới, RFC-005 Mục 5)
--      nên viết thành 1 Postgres function/Edge Function riêng, không thao tác
--      tay 2 bước ở tầng app (tránh race condition).
-- ============================================================================
