# 📘 BOOK 02 — PART V: BUSINESS RULES (đưa lên sớm theo góp ý kiến trúc)

# RFC-004
# CANONICAL ENTITIES

## Metadata

```text
RFC ID          RFC-004
Status           Approved
Priority         Critical
Dependencies     RFC-002 (North Star), RFC-003 (Vision), Kế hoạch 90 ngày (Locked)
Đọc trước bởi    AI, Backend Developer, Flutter Developer, Product Manager
```

---

## 1. Vì sao RFC này phải đọc trước khi tạo Database

Sai lầm phổ biến nhất khi build CRM bất động sản:

```text
Khách
  ↓
Danh sách khách
```

Đây là tư duy **bảng dữ liệu**, không phải tư duy **đồ thị quan hệ**.

REMI không xây danh sách. REMI xây một đồ thị, nơi mọi thực thể xoay quanh **Lead** như trung tâm — đúng như Founder đã xác định. RFC này định nghĩa chính xác các thực thể đó, quan hệ giữa chúng, và những nguyên tắc bất biến (invariants) mà Backend Dev không được vi phạm khi thiết kế schema.

**Phạm vi RFC này giới hạn trong 4 module lõi đã khóa ở Kế hoạch 90 ngày**: AI CRM, AI Memory, Property, AI Follow-up. Các entity thuộc Marketplace, Trust, Deal, Commission sẽ có RFC riêng khi đến Giai đoạn 2, nhưng được **dự trù chỗ đứng** trong mô hình dưới đây để không phải phá vỡ kiến trúc khi mở rộng.

---

## 2. Sơ đồ Entity trung tâm

```text
Lead
 │
 ├── AI Memory        (context tích lũy về Lead)
 ├── Conversation      (lịch sử trao đổi thô)
 ├── Timeline           (chuỗi sự kiện đã chuẩn hóa)
 ├── Document           (hồ sơ/giấy tờ liên quan)
 ├── Property Match    (liên kết Lead ↔ Property)
 ├── Task               (việc cần làm, sinh ra bởi AI Follow-up hoặc thủ công)
 ├── Deal               (dự trù — chưa build ở Giai đoạn 1)
 ├── Trust              (dự trù — chưa build ở Giai đoạn 1)
 └── Automation         (dự trù — chưa build ở Giai đoạn 1)
```

Nguyên tắc bất biến số 1:

> **Không entity nào trong danh sách trên tồn tại độc lập không gắn với Lead.**
> Nếu một Backend Dev thiết kế bảng `documents` mà không có `lead_id` bắt buộc, đó là vi phạm kiến trúc.

---

## 3. Định nghĩa từng Entity

### 3.1 Lead

**Định nghĩa:** Đơn vị trung tâm của toàn hệ thống — đại diện cho một mối quan hệ đang có tiềm năng trở thành giao dịch (đúng tinh thần North Star ở RFC-002).

**Thuộc tính cốt lõi (khái niệm, không phải schema đầy đủ):**
```text
- Định danh (tên, liên hệ)
- Nguồn gốc (nhập tay — theo phạm vi 90 ngày)
- Trạng thái Pipeline (xem mục 4)
- Phân khúc quan tâm (đất nền / nhà phố / ...)
- Khu vực quan tâm
- Ngân sách (nếu có)
```

> **Lưu ý quan trọng (cập nhật sau khi có RFC-005):** "Người sở hữu Lead" KHÔNG nằm trong danh sách thuộc tính ở trên, dù về mặt khái niệm mỗi Lead vẫn có một môi giới phụ trách. Đây là quyết định có chủ đích: ownership được mô hình hóa như một **quan hệ riêng** (bảng `lead_ownerships`), không phải một cột thuộc tính trong bảng `leads`. Chi tiết đầy đủ xem RFC-005 (Ownership & Permission Rules) — đó là tài liệu thẩm quyền duy nhất cho việc này.

**Nguyên tắc bất biến:**
- Một Lead luôn thuộc về **một** môi giới sở hữu chính tại một thời điểm, thông qua quan hệ ownership (RFC-005), không phải thuộc tính trực tiếp.
- Lead không bị xóa cứng (hard delete) — chỉ chuyển trạng thái "Đóng/Ngừng" để giữ toàn vẹn Timeline và AI Memory.

---

### 3.2 AI Memory

**Định nghĩa:** Lớp ngữ cảnh tích lũy mà AI dùng để hiểu Lead qua thời gian — đây là tài sản cạnh tranh cốt lõi (Relationship Graph, theo RFC-003), **không phải log thô**.

**Khác biệt bắt buộc với Conversation:**
```text
Conversation = dữ liệu thô (câu nói, tin nhắn)
AI Memory     = dữ liệu đã được AI trích xuất/suy luận từ Conversation
                (VD: "khách thích hướng Đông Nam", "khách nhạy cảm về giá")
```

**Nguyên tắc bất biến:**
- AI Memory phải có khả năng **truy vết ngược** về Conversation/Timeline nguồn gốc đã sinh ra nó — không được là "hộp đen". Đây là yêu cầu bắt buộc để môi giới tin tưởng AI (liên quan AI Acceptance Rate ở RFC-002).
- AI Memory là dữ liệu **cộng dồn theo thời gian**, không ghi đè — mỗi lần cập nhật là một bản ghi mới, không xóa bản cũ.

---

### 3.3 Conversation

**Định nghĩa:** Dữ liệu trao đổi thô giữa môi giới và Lead (ghi chú cuộc gọi, tin nhắn, email...).

**Nguyên tắc bất biến:**
- Là nguồn input cho AI Memory, không phải nơi hiển thị chính cho môi giới hàng ngày (đó là vai trò của Timeline).

---

### 3.4 Timeline

**Định nghĩa:** Chuỗi sự kiện đã chuẩn hóa, hiển thị cho môi giới xem "chuyện gì đã xảy ra với Lead này" theo thứ tự thời gian.

**Khác biệt với Conversation:** Timeline là **view đã diễn giải** (VD: "Đã gọi điện — khách hẹn xem nhà cuối tuần"), trong khi Conversation là dữ liệu thô đằng sau nó.

---

### 3.5 Document

**Định nghĩa:** Hồ sơ/giấy tờ gắn với Lead (CMND/CCCD, hợp đồng nháp, giấy tờ property liên quan...).

**Lưu ý phạm vi 90 ngày:** Chưa cần OCR, chỉ cần lưu trữ file gắn với Lead.

---

### 3.6 Property

**Định nghĩa:** Nguồn hàng bất động sản. Đứng độc lập như một entity gốc (không phụ thuộc Lead), nhưng kết nối với Lead qua Property Match.

**Thuộc tính cốt lõi:**
```text
- Loại hình (đất nền / nhà phố — theo phạm vi beta)
- Khu vực (Rạch Giá, Kiên Giang)
- Giá
- Tình trạng pháp lý (cơ bản — chưa OCR)
```

> **Lưu ý quan trọng (cập nhật sau khi có RFC-005):** cũng như Lead, "Người quản lý nguồn" của Property KHÔNG phải một cột thuộc tính — được mô hình hóa qua bảng quan hệ `property_ownerships` (RFC-005), tách biệt khỏi bảng `properties`.

**Nguyên tắc bất biến:**
- Property KHÔNG thuộc về Lead. Một Property có thể match với nhiều Lead. Đây là quan hệ nhiều-nhiều, không phải một-nhiều.

---

### 3.7 Property Match

**Định nghĩa:** Entity trung gian (join entity) thể hiện một Lead được ghép với một Property, kèm mức độ phù hợp và trạng thái.

**Vì sao cần entity riêng, không chỉ là quan hệ đơn giản:**
Vì Match cần lưu thêm ngữ cảnh: ai tạo match (AI hay môi giới tự chọn), mức độ phù hợp, trạng thái đã gửi khách hay chưa, phản hồi của khách. Đây là dữ liệu cần thiết cho Smart Match ở Giai đoạn 2 — nếu không có sẵn từ đầu, việc train/cải thiện AI Match sau này sẽ không có dữ liệu lịch sử.

---

### 3.8 Task

**Định nghĩa:** Việc cần làm, có thể sinh ra tự động bởi AI Follow-up hoặc tạo thủ công bởi môi giới.

**Nguyên tắc bất biến:**
- Task luôn gắn với một Lead cụ thể.
- Task phải có trạng thái "Đã xác nhận thực hiện" — **đây chính là nguồn dữ liệu cho North Star Metric chính thức của bản Beta** (số lần AI Follow-up được xác nhận thực hiện/môi giới/tuần). Nếu Backend Dev thiết kế Task mà thiếu trường trạng thái xác nhận rõ ràng (không phải chỉ "done/not done" mà là ai xác nhận, khi nào), việc đo North Star Metric sẽ không thực hiện được.

---

### 3.9 Deal, Trust, Automation (Dự trù — chưa build)

Ba entity này **không nằm trong phạm vi code của 90 ngày**, nhưng phải được dự trù vị trí trong sơ đồ ngay từ bây giờ để tránh việc Giai đoạn 2 phải đập lại kiến trúc Lead. Backend Dev chỉ cần biết: mọi entity tương lai này đều sẽ gắn về Lead, không được thiết kế Lead-table hiện tại theo kiểu "đóng cứng" khiến việc thêm quan hệ sau này phải ALTER TABLE phá vỡ dữ liệu cũ.

---

## 4. Pipeline — Trạng thái bắt buộc của Lead

Theo quyết định ở Kế hoạch 90 ngày, Pipeline phải đủ chi tiết để đo Metric B (theo dõi song song). Trạng thái tối thiểu:

```text
Mới
  ↓
Đang chăm sóc
  ↓
Có nhu cầu rõ
  ↓
Đã hẹn xem property
  ↓
(Giai đoạn 2 mở rộng: Đã cọc → Đã giao dịch)
```

**Nguyên tắc bất biến:**
- Trạng thái Pipeline là **enum có thứ tự**, không phải free-text. AI Follow-up và Dashboard đều phụ thuộc vào enum này để hoạt động đúng.
- Mỗi lần đổi trạng thái phải ghi vào Timeline — không đổi "âm thầm".

---

## 5. Nguyên tắc Ownership tối thiểu (mở rộng ở RFC riêng sau)

Vì Giai đoạn 1 chưa có Co-op/chia sẻ Lead, nguyên tắc ownership hiện tại đơn giản:

```text
Mỗi Lead → thuộc về đúng 1 môi giới
Mỗi Property → thuộc về đúng 1 môi giới quản lý nguồn
```

**Cảnh báo kiến trúc:** dù đơn giản ở Giai đoạn 1, bảng dữ liệu **không được thiết kế cứng theo kiểu 1-1** (VD: cột `broker_id` duy nhất không mở rộng được). Phải thiết kế sao cho khi Co-op ra mắt ở Giai đoạn 2 (nhiều môi giới cùng truy cập một Lead theo vai trò khác nhau), không cần migrate lại dữ liệu — chỉ cần thêm bảng quan hệ mới.

---

## 6. Việc Backend Dev PHẢI làm khi đọc RFC này

1. Thiết kế bảng `leads` là trung tâm, mọi bảng khác tham chiếu `lead_id`.
2. Tách rõ `conversations` (thô) và `ai_memories` (đã suy luận) — không gộp chung.
3. Thiết kế `pipeline_status` là enum có thứ tự, lưu lịch sử đổi trạng thái vào `timeline_events`.
4. Thiết kế `property_matches` là bảng riêng (không phải many-to-many thuần túy) để chứa metadata (nguồn gốc match, mức phù hợp, phản hồi).
5. Thiết kế `tasks` có trường xác nhận thực hiện rõ ràng (ai, khi nào) — phục vụ trực tiếp North Star Metric.
6. Để ngỏ khả năng mở rộng ownership sang nhiều-nhiều (chuẩn bị cho Co-op), dù chưa cần dùng ngay.

---

## 7. Việc AI PHẢI tuân thủ khi sinh code

- Không được tạo entity mới ngoài danh sách ở Mục 2 mà không có RFC bổ sung.
- Không được để bất kỳ entity nào (trừ Property) tồn tại mà không có `lead_id`.
- Khi sinh logic AI Memory, phải luôn giữ liên kết truy vết về Conversation/Timeline nguồn — không sinh "kết luận" không có nguồn.

---

## CTO Review

Founder, đây là RFC nền tảng — mọi RFC sau (AI Matching, Workflow Engine, Ownership Rules đầy đủ) sẽ tham chiếu ngược về đây. Nguyên tắc xuyên suốt: **thiết kế cho Giai đoạn 4, code cho Giai đoạn 1**. Nghĩa là schema phải đủ mở để không phá vỡ khi mở rộng, nhưng phạm vi code thực tế vẫn giữ đúng kỷ luật đã khóa ở Kế hoạch 90 ngày — không tự ý build thêm vì "tiện thể mở rộng luôn".

RFC tiếp theo nên là gì, mình đề xuất hai lựa chọn:
- **RFC-005: Ownership & Permission Rules đầy đủ** — cần trước khi có Co-op ở Giai đoạn 2, nhưng có thể phác thảo sớm để Backend Dev không thiết kế bí.
- **RFC-006: AI Memory — Cơ chế trích xuất & suy luận** — mô tả chi tiết cách AI sinh ra Memory từ Conversation, cần trước khi code Tuần 5-6.

Bạn muốn RFC tiếp theo là cái nào?
