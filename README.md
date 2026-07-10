# REMI — AI Ecosystem

AI-powered real estate CRM platform dành cho môi giới bất động sản Việt Nam. Beta khởi đầu tại thị trường Rạch Giá, Kiên Giang, tập trung phân khúc đất nền & nhà phố thổ cư.

---

## Mô hình "3 Bộ Não"

```text
Product Brain (Notion "REMI OS")   → Chiến lược, PRD, Roadmap, Sprint, Design System
                                       Chỉ index + link, KHÔNG chứa nội dung kỹ thuật đầy đủ

Code Brain (repo này)               → RFC kỹ thuật, schema, source code
                                       NGUỒN SỰ THẬT DUY NHẤT cho Cursor/Claude Code

Data Runtime (Supabase)             → Dữ liệu chạy thật (Lead, Property, AI Memory...)
                                       Project: remi-ai-ecosystem
```

> **Nguyên tắc bắt buộc:** mọi thay đổi về kiến trúc/business rule phải sửa RFC trong `/docs/rfc` trước, rồi mới code theo RFC đã cập nhật — không code lệch RFC rồi "để đó tính sau". Xem chi tiết ở `docs/ops/SO_DO_3_BO_NAO_THONG_NHAT.md`.

---

## Cấu trúc thư mục

```text
remi-ai-ecosystem/
├── README.md                    ← file này
├── docs/
│   ├── rfc/                     ← RFC kỹ thuật (nguồn sự thật duy nhất)
│   │   ├── README.md            ← chỉ mục + trạng thái từng RFC
│   │   ├── RFC-004_CANONICAL_ENTITIES.md
│   │   ├── RFC-005_OWNERSHIP_PERMISSION_RULES.md
│   │   ├── RFC-006_AI_MEMORY_EXTRACTION.md
│   │   ├── RFC-007_AI_FOLLOWUP.md
│   │   ├── RFC-008_PROPERTY_MATCH.md
│   │   ├── RFC-009_NAVIGATION_THEME.md
│   │   └── RFC-010_NOTIFICATION_TOI_THIEU.md
│   └── ops/                     ← vận hành, kế hoạch, sơ đồ tổ chức tài liệu
│       ├── KE_HOACH_90_NGAY_KHOA.md
│       ├── SO_TAY_VAN_HANH_CHINH_THUC.md
│       └── SO_DO_3_BO_NAO_THONG_NHAT.md
├── supabase/
│   ├── migrations/               ← schema SQL, version control qua Supabase CLI
│   │   └── 20260101000000_init_core_schema.sql
│   └── functions/                 ← Edge Functions (AI Memory extraction, AI Follow-up, Notification)
│       └── (trống — code Tuần 5-10 theo RFC-006/007/010)
└── app/                          ← Flutter project (khởi tạo Tuần 1 theo RFC-009)
    └── (trống — flutter create remi_app --org com.remiai)
```

---

## Phạm vi Giai đoạn 1 (Beta — 90 ngày)

4 module lõi, theo đúng thứ tự phụ thuộc giữa các RFC:

| Tuần | Module | RFC liên quan |
|---|---|---|
| 1–3 | Nền tảng dữ liệu + Navigation/Theme | RFC-004, RFC-005, RFC-009 |
| 4 | AI CRM (Pipeline) | RFC-004 |
| 5–6 | AI Memory | RFC-006 |
| 7–8 | Property + Property Match | RFC-008 |
| 9–10 | AI Follow-up + Notification | RFC-007, RFC-010 |
| 11–12 | Dashboard tối giản + Beta 30–50 môi giới | Toàn bộ |

Chi tiết đầy đủ: [`docs/ops/KE_HOACH_90_NGAY_KHOA.md`](docs/ops/KE_HOACH_90_NGAY_KHOA.md)

**North Star Metric (Beta):** số lần AI Follow-up được môi giới xác nhận đã thực hiện / môi giới / tuần.

---

## Thông số hạ tầng đã chốt

```text
Supabase project     remi-ai-ecosystem
Bundle ID (iOS)       com.remiai.app
Application ID        com.remiai.app  (Android)
Domain Beta           remi-ai.io
Embedding model       Voyage AI voyage-4-lite (1024 chiều)
AI extraction/gợi ý   Claude Haiku 4.5
State management      Riverpod
Routing               go_router
Công cụ code          Cursor (sửa nhanh trong IDE) + Claude Code (tác vụ agentic)
```

Chi tiết đầy đủ + lệnh khởi tạo: [`docs/ops/SO_TAY_VAN_HANH_CHINH_THUC.md`](docs/ops/SO_TAY_VAN_HANH_CHINH_THUC.md)

---

## Bắt đầu nhanh (Quick Start)

```bash
# 1. Clone repo
git clone <repo-url> remi-ai-ecosystem
cd remi-ai-ecosystem

# 2. Khởi tạo Supabase local + link project
supabase init
supabase link --project-ref <ref-của-remi-ai-ecosystem-dev>
supabase db push          # áp dụng migration trong supabase/migrations/

# 3. Khởi tạo Flutter app (nếu chưa có trong /app)
flutter create app --org com.remiai --platforms ios,android
cd app
flutter pub add supabase_flutter flutter_riverpod go_router flutter_dotenv
```

---

## Đọc gì trước khi code

Thứ tự đọc bắt buộc cho AI/Backend Dev/Flutter Dev, theo đúng phụ thuộc giữa các RFC:

1. `docs/rfc/RFC-004_CANONICAL_ENTITIES.md` — đọc trước tiên, mọi RFC khác phụ thuộc vào đây
2. `docs/rfc/RFC-005_OWNERSHIP_PERMISSION_RULES.md`
3. `docs/rfc/RFC-006_AI_MEMORY_EXTRACTION.md`
4. `docs/rfc/RFC-008_PROPERTY_MATCH.md`
5. `docs/rfc/RFC-007_AI_FOLLOWUP.md`
6. `docs/rfc/RFC-009_NAVIGATION_THEME.md`
7. `docs/rfc/RFC-010_NOTIFICATION_TOI_THIEU.md`
8. `supabase/migrations/20260101000000_init_core_schema.sql` — bản triển khai cụ thể của toàn bộ RFC trên
9. `docs/ops/SO_TAY_VAN_HANH_CHINH_THUC.md` — quy trình vận hành hàng ngày

Xem chỉ mục đầy đủ kèm trạng thái từng RFC tại [`docs/rfc/README.md`](docs/rfc/README.md).

---

## Nguyên tắc kiến trúc xuyên suốt (nhắc lại để không quên khi code)

- **Không xóa cứng** — mọi entity chỉ đổi trạng thái (Đóng/Ngừng/Archived), không DELETE.
- **Ownership là quan hệ, không phải thuộc tính** — không có cột `broker_id` trực tiếp trong bảng entity.
- **Quyền hạn là dữ liệu cấu hình** — không hard-code if/else phân quyền trong logic.
- **AI chỉ đề xuất, không tự hành động thay người** — mọi gợi ý AI cần con người xác nhận.
- **Screen xuất hiện cuối cùng** — thiết kế UI đi từ Domain → Capability → Workflow, không từ màn hình.

---

## Liên kết

- Notion "REMI OS" (Product Brain): *thêm link khi tạo xong*
- Supabase Dashboard: *thêm link khi tạo xong*
