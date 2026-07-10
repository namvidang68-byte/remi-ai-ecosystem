# Chỉ mục RFC — REMI

Đọc theo đúng thứ tự phụ thuộc (không đọc nhảy cóc lần đầu).

| RFC | Tên | Phụ thuộc | Phạm vi code | Trạng thái |
|---|---|---|---|---|
| [RFC-004](RFC-004_CANONICAL_ENTITIES.md) | Canonical Entities | — (nền tảng) | Tuần 1–3 | Approved |
| [RFC-005](RFC-005_OWNERSHIP_PERMISSION_RULES.md) | Ownership & Permission Rules | RFC-004 | Tuần 1–3 | Approved |
| [RFC-006](RFC-006_AI_MEMORY_EXTRACTION.md) | AI Memory — Trích xuất & Suy luận | RFC-004 | Tuần 5–6 | Approved |
| [RFC-008](RFC-008_PROPERTY_MATCH.md) | Property Match — Nguyên tắc ghép nối | RFC-004, RFC-006 | Tuần 7–8 | Approved |
| [RFC-007](RFC-007_AI_FOLLOWUP.md) | AI Follow-up — Sinh gợi ý hành động | RFC-004, RFC-006, RFC-008 | Tuần 9–10 | Approved |
| [RFC-009](RFC-009_NAVIGATION_THEME.md) | Navigation & Theme | RFC-004 | Tuần 1–3 | Approved |
| [RFC-010](RFC-010_NOTIFICATION_TOI_THIEU.md) | Notification tối thiểu | RFC-007, RFC-008 | Tuần 9–10 | Approved |

**Lưu ý về thứ tự số:** RFC-008 được viết trước RFC-007 dù số nhỏ hơn — vì Property Match code trước AI Follow-up (Tuần 7–8 trước Tuần 9–10) theo Kế hoạch 90 ngày. Số RFC phản ánh **thứ tự viết tài liệu**, cột "Phạm vi code" mới phản ánh **thứ tự triển khai thực tế**.

---

## Quy tắc sửa đổi RFC (RFC Amendment)

1. Khi code phát sinh vấn đề khác với RFC hiện tại → **dừng lại, sửa RFC trước**, không code lệch rồi để đó.
2. Ghi lại lý do thay đổi vào Notion "REMI OS" > `07. AI Ops Brain > Decisions Log`.
3. Nếu thay đổi ảnh hưởng RFC khác (VD: sửa RFC-004 ảnh hưởng RFC-005/006/007/008) → rà lại toàn bộ RFC phụ thuộc trước khi merge, tương tự vòng review đã làm khi hoàn thành RFC-010 (phát hiện 3 mâu thuẫn giữa RFC-004/005 và RFC-006/007/008).

---

## Tài liệu liên quan (không phải RFC nhưng cần đọc)

- `../ops/KE_HOACH_90_NGAY_KHOA.md` — Kế hoạch 90 ngày đã khóa, RFC ở trên phục vụ trực tiếp kế hoạch này.
- `../ops/SO_TAY_VAN_HANH_CHINH_THUC.md` — hướng dẫn vận hành, kiến trúc kỹ thuật, thông số hạ tầng.
- `../ops/SO_DO_3_BO_NAO_THONG_NHAT.md` — nguyên tắc tổ chức tài liệu giữa Notion/GitHub/Supabase.
- `../../supabase/migrations/20260101000000_init_core_schema.sql` — bản triển khai SQL của toàn bộ RFC trên.
