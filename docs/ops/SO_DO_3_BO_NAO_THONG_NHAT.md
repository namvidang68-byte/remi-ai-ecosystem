# SƠ ĐỒ "3 BỘ NÃO" REMI — PHIÊN BẢN THỐNG NHẤT

## Nguyên tắc nền tảng

> **Mỗi loại thông tin chỉ có ĐÚNG MỘT nơi lưu trữ chính thức. Mọi nơi khác chỉ được LINK tới, không COPY nội dung.**

```text
Product Brain (Notion)     → Chiến lược, roadmap, sprint, quyết định kinh doanh
                              KHÔNG chứa full nội dung RFC kỹ thuật, chỉ index + link

Code Brain (GitHub)         → Toàn bộ RFC kỹ thuật (.md), schema migration (.sql),
                              source code Flutter + Edge Functions
                              ĐÂY LÀ NGUỒN SỰ THẬT DUY NHẤT cho Cursor/Claude Code đọc

Data Runtime (Supabase)     → Dữ liệu chạy thật (Lead, Property, AI Memory...)
                              KHÔNG phải "Code Brain" — đây là nơi schema
                              (định nghĩa trong GitHub) được thực thi và chứa dữ liệu sống

AI Ops Brain (nội bộ team)  → Prompt library, quy trình làm việc với Claude/Cursor,
                              log quyết định kiến trúc
                              KHÁC với "AI Memory" (RFC-006) — đó là tính năng SẢN PHẨM
                              cho môi giới, đã sống trong Supabase từ Giai đoạn 1,
                              KHÔNG phải "sau này"
```

## Sơ đồ luồng đã sửa

```text
Notion (REMI OS)
    │  [chỉ index + link, không copy nội dung]
    ▼
GitHub (remi-ai-ecosystem repo)
    │
    ├── /docs/rfc/           → RFC-004 → RFC-010 (.md) — nguồn sự thật kỹ thuật
    ├── /docs/ops/           → Sổ tay Vận hành, Kế hoạch 90 ngày
    ├── /supabase/migrations/→ schema SQL (version control)
    ├── /supabase/functions/ → Edge Functions (AI Memory extraction, Follow-up, Notification)
    └── /app/                → Flutter project (remi_app)
              │
              ▼
       supabase db push  →  Supabase Project "remi-ai-ecosystem"
                             (dữ liệu chạy thật: Lead, Property, AI Memory...)
```

---

## Cấu trúc Notion "REMI OS" — thống nhất, đã gộp 2 danh sách trước

```text
📁 REMI OS
│
├── 🎯 01. Vision & Strategy
│     — North Star (RFC-002), Vision (RFC-003) — tóm tắt, không copy full RFC
│     — Roadmap 4 Giai đoạn (3 năm)
│     — Kế hoạch 90 ngày (link tới file trong GitHub /docs/ops/)
│
├── 📐 02. Architecture (Index — chỉ LINK, không copy)
│     — Link: GitHub /docs/rfc/RFC-004 → RFC-010
│     — Link: supabase_schema_v1.sql
│     — Link: Sổ tay Vận hành chính thức
│     — Bảng tóm tắt 1 dòng/RFC để dễ tra cứu nhanh không cần mở GitHub
│
├── 📄 03. PRD (Product Requirement — do PM viết, KHÁC RFC kỹ thuật)
│     — Đặc tả yêu cầu sản phẩm ở mức người dùng, không mô tả schema/code
│     — Đây là tài liệu THUỘC Notion thật sự (không trùng với GitHub)
│
├── 🎨 04. Design System
│     — Tóm tắt nguyên tắc RFC-009 (Navigation & Theme)
│     — Link Figma/wireframe (khi có — xem Phần D Sổ tay Vận hành: còn thiếu)
│
├── 🗓️ 05. Roadmap & Sprint Board
│     — Board Tuần 1–12 theo Kế hoạch 90 ngày đã khóa
│     — Mỗi Task nên link tới GitHub Issue/PR tương ứng khi bắt đầu code
│
├── 🧪 06. QA & Beta
│     — Checklist test case (Phần C Sổ tay Vận hành)
│     — Danh sách môi giới Beta (Rạch Giá, đất nền & nhà phố thổ cư)
│     — Log phản hồi định tính hàng tuần
│
├── 🧠 07. AI Ops Brain (nội bộ — KHÔNG phải AI Memory sản phẩm)
│     — Prompt library dùng khi làm việc với Claude/Cursor/Claude Code
│     — Quy trình "RFC Amendment" (cách sửa RFC khi code phát sinh vấn đề)
│     — Log quyết định kiến trúc quan trọng (VD: vì sao chọn voyage-4-lite
│       thay vì voyage-3 — để không phải tra cứu lại lý do sau này)
│
└── 📓 08. Decisions Log & Meeting Notes
      — Nhật ký quyết định theo ngày, đặc biệt các quyết định đổi hướng
        (giúp không lặp lại tranh luận cũ)
```

**Khác biệt quan trọng với đề xuất gốc của bạn:** mục **02. Architecture** không chứa "Canonical Data Model", "Database Blueprint", "API Blueprint" như 3 trang nội dung đầy đủ riêng biệt trong Notion — vì chúng đã là RFC-004 (Canonical Entities) và schema SQL, đã sống trong GitHub. Notion chỉ cần 1 trang Index trỏ tới, tránh việc bạn phải cập nhật 2 nơi mỗi khi có thay đổi.

---

## Bước triển khai đã điều chỉnh

### Bước 1 (Hôm nay) — Tạo hạ tầng, không chỉ Notion

```text
1. Tạo Notion Workspace "REMI OS" theo cấu trúc 8 mục ở trên
2. Tạo GitHub repo "remi-ai-ecosystem" (monorepo) với 4 thư mục:
   /docs/rfc, /docs/ops, /supabase, /app
3. Đưa toàn bộ file đã có (7 RFC .md, schema SQL, Sổ tay Vận hành,
   Kế hoạch 90 ngày) vào đúng thư mục /docs tương ứng, commit lần đầu
```

### Bước 2 — Dựng trang Index trong Notion

```text
Chỉ tạo trang 02. Architecture với bảng tóm tắt + link — KHÔNG copy nội dung
RFC vào Notion dưới mọi hình thức, kể cả "để dự phòng"
```

### Bước 3 — Nhịp làm việc hàng ngày

```text
Mỗi ngày hoàn thành 1 Deliverable — đồng ý với đề xuất của bạn, bổ sung
Definition of Done tối thiểu:
  ✓ Code đã commit vào GitHub (không nằm im trên máy)
  ✓ Nếu phát sinh khác biệt so với RFC → sửa RFC trước, ghi vào
    07. AI Ops Brain > Decisions Log, rồi mới code tiếp
  ✓ Cập nhật trạng thái Task trên Sprint Board (05.)
```

---

## Vì sao tách bạch việc này ngay bây giờ quan trọng

Nếu để Notion chứa cả nội dung RFC đầy đủ lẫn PRD/Roadmap, sau 2-3 tháng bạn sẽ đối mặt đúng vấn đề mà toàn bộ 7 RFC đã cố gắng ngăn chặn ở tầng dữ liệu sản phẩm (RFC-004, RFC-005): **hai nguồn sự thật, không biết tin cái nào**. Nguyên tắc "một nơi lưu trữ chính thức, nơi khác chỉ link" áp dụng cho tài liệu công ty y hệt như áp dụng cho schema database — đây thực chất là cùng một bài học, chỉ khác đối tượng.
