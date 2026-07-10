# Decisions Log — REMI

> Nhật ký quyết định quan trọng, đặc biệt các quyết định đổi hướng hoặc suýt đổi hướng. Ghi ngay khi quyết định, không đợi "đủ nội dung".

---

## 2026 — Tuần chuẩn bị (trước Tuần 1 chính thức)

### Quyết định: KHÔNG gộp Giai đoạn 1 + 2, giữ nguyên phạm vi 4 module lõi + density-first tại Rạch Giá

**Bối cảnh:** Founder cân nhắc gộp Giai đoạn 1+2 (thêm Marketplace, Trust Score, mở App Store công khai, chạy quảng cáo đa nền tảng) vì lo đối thủ ra mắt trước, muốn chiếm thị phần/thương hiệu sớm.

**Quyết định cuối:** Giữ nguyên Kế hoạch 90 ngày đã khóa — 4 module lõi, Beta giới hạn 30-50 môi giới tại Rạch Giá, phân khúc đất nền & nhà phố thổ cư.

**Lý do:**
- Marketplace/Trust Score cần mật độ môi giới cùng khu vực mới có giá trị; quảng cáo đa nền tảng tạo người dùng phân tán — phản tác dụng với chính cơ chế các module đó cần.
- Moat thật của REMI (RFC-003: 5 Graph — Relationship/Property/Trust/Knowledge/Workflow) hình thành từ dữ liệu sâu, không phải từ số lượt tải sớm.
- Rating App Store thấp ở tuần đầu (nếu mở rộng khi core loop chưa kiểm chứng) rất khó gỡ về sau.
- Founder solo bootstrap chưa có dữ liệu Beta để biết CAC có đáng chi hay không.

**Giải pháp thay thế cho nỗi lo "bị đối thủ chiếm trước":**
- Giữ chỗ thương hiệu ngay (đăng ký App Store Connect/Google Play, bundle ID `com.remiai.app`, domain `remi-ai.io`) — chi phí gần như 0, làm ngay được.
- Tách riêng nhánh "Brand & Waitlist" (landing page, quảng cáo nhẹ để thu waitlist) khỏi nhánh "Sản phẩm Beta" (giữ nguyên kỷ luật density-first) — chạy song song, không đụng nhau.

**Vấn đề phát sinh liên quan:** Founder chưa có tên tuổi/quan hệ tại Rạch Giá — làm sao thuyết phục 30-50 môi giới đầu tiên?
**Xử lý:** Chiến lược Anchor Partner (tìm 1-2 người/nhóm có uy tín sẵn có trong cộng đồng địa phương, concierge onboarding trực tiếp cho nhóm đầu tiên, mở rộng qua giới thiệu nội bộ — không quảng cáo đại trà). Founder xác nhận đã có cách tiếp cận riêng cho phần này (chi tiết không ghi ở đây, thuộc phạm vi vận hành/kinh doanh, không phải kiến trúc kỹ thuật).

**Điều chỉnh vào Kế hoạch 90 ngày:** việc tìm Anchor Partner nên bắt đầu từ Tuần 1, chạy song song với code — không đợi đến Tuần 12 mới tìm người dùng.

**RFC/tài liệu liên quan:** RFC-002 (North Star — Progress không phải Attention), RFC-003 (Vision — 5 Graph là moat), RFC-008 (Property Match — lý do cần density), `docs/ops/KE_HOACH_90_NGAY_KHOA.md`.

---

*(Thêm entry mới bên dưới theo cùng định dạng: Bối cảnh → Quyết định cuối → Lý do → RFC liên quan)*
