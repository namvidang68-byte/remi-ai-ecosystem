# 📘 BOOK 02 — PART VI: OPERATING SYSTEM

# RFC-010
# NOTIFICATION TỐI THIỂU

## Metadata

```text
RFC ID          RFC-010
Status           Approved
Priority         High
Dependencies     RFC-007 (AI Follow-up), RFC-008 (Property Match)
Phạm vi code     Tuần 9–10 (song song với AI Follow-up)
Đọc trước bởi    AI, Backend Developer, Flutter Developer
```

---

## 1. Vì sao RFC này tách riêng khỏi Notification Engine

Kế hoạch 90 ngày đã loại "Notification Engine đầy đủ" khỏi Giai đoạn 1, dời sang Giai đoạn 2 (Part VI, Article 32 trong khung Book 02 gốc). Nhưng AI Follow-up (RFC-007) vẫn cần MỘT cơ chế báo cho môi giới biết "có việc cần làm" — nếu không, Task sinh ra mà không ai thấy, North Star Metric sẽ không bao giờ được xác nhận.

RFC này định nghĩa phần **tối thiểu sống được**, không phải Notification Engine tổng quát.

---

## 2. Ranh giới phạm vi — điều quan trọng nhất

```text
Notification tối thiểu (Giai đoạn 1 — RFC này)
= Một kênh duy nhất: in-app (danh sách thông báo trong app)
= Nội dung cố định theo 2 loại sự kiện duy nhất (xem Mục 3)
= Không có trung tâm tùy chỉnh (không cho môi giới bật/tắt từng loại)
= Không có multi-channel (chưa cần push notification/SMS/email ở bản đầu)

Notification Engine (Giai đoạn 2 — chưa build)
= Nhiều kênh (push, email, SMS...)
= Trung tâm tùy chỉnh cho người dùng (bật/tắt loại thông báo, quiet hours)
= Rule engine linh hoạt cho nhiều loại sự kiện từ nhiều module (Marketplace, Co-op...)
```

**Nguyên tắc bất biến:** không xây dựng cơ chế cấu hình đa kênh hay trung tâm tùy chỉnh ở Giai đoạn 1, dù "có vẻ không tốn bao nhiêu công". Đây là bẫy scope creep điển hình — nếu không giữ kỷ luật, việc tưởng đơn giản này có thể kéo dài thêm nhiều tuần ngoài kế hoạch.

**Ghi chú kỹ thuật:** dù Giai đoạn 1 chỉ dùng in-app, bảng dữ liệu vẫn nên có cột `channel` (mặc định `in_app`) — để Giai đoạn 2 thêm kênh mới không phải đổi cấu trúc bảng, cùng tinh thần "thiết kế cho Giai đoạn 4, code cho Giai đoạn 1" đã áp dụng xuyên suốt các RFC trước.

---

## 3. Hai loại sự kiện duy nhất cần thông báo (Giai đoạn 1)

```text
Loại 1: Task đến hạn / cần xác nhận
        Nguồn: AI Follow-up (RFC-007)
        Nội dung: "Nhắc: [tên hành động] cho [tên Lead]"

Loại 2: Property Match cần chú ý
        Nguồn: Property Match chuyển trạng thái Sent quá lâu chưa cập nhật (RFC-008)
        Nội dung: "Property đã gửi cho [tên Lead] 3 ngày trước — cập nhật phản hồi?"
```

**Nguyên tắc bất biến:** không thêm loại thông báo thứ 3 trở lên trong Giai đoạn 1 (VD: thông báo hệ thống, thông báo chào mừng, thông báo marketing) — giữ đúng 2 loại phục vụ trực tiếp vòng lặp Core Loop.

---

## 4. Kế thừa nguyên tắc chống Spam từ RFC-007

RFC-007 đã định nghĩa giới hạn tần suất gợi ý AI Follow-up (tối đa 1 gợi ý/Lead/ngày, không lặp lại gợi ý vừa bị dismiss trong 24h). Notification tối thiểu **kế thừa trực tiếp** giới hạn này — không tạo thêm tầng giới hạn riêng, để tránh hai hệ thống tần suất chồng chéo khó kiểm soát.

**Nguyên tắc bổ sung riêng cho Notification:** nếu trong cùng một khoảng thời gian ngắn (VD: trong 1 giờ) có nhiều Task/Match cùng cần thông báo, hệ thống nên **gộp thành một thông báo tổng hợp** (VD: "Bạn có 3 việc cần làm hôm nay") thay vì gửi từng thông báo riêng lẻ. Đây là nguyên tắc chống Notification Spam đã cam kết ở RFC-002 (Anti-Metric).

---

## 5. Trạng thái của một Notification

```text
Unread    — chưa xem
Read      — đã xem (môi giới mở danh sách thông báo)
Actioned  — môi giới đã thực hiện hành động liên quan
            (VD: đã Confirm Task từ RFC-007)
```

**Nguyên tắc bất biến:** trạng thái `Actioned` phải đồng bộ tự động khi Task/Match nguồn thay đổi trạng thái — không yêu cầu môi giới phải tự tay đánh dấu 2 lần (một lần ở Task, một lần ở Notification). Đây là nguyên tắc trải nghiệm: không bắt người dùng làm việc thừa.

---

## 6. Việc Backend Dev PHẢI làm khi đọc RFC này

1. Bảng `notifications` bắt buộc có: `lead_id` hoặc `task_id`/`match_id` liên kết nguồn, `channel` (mặc định `in_app`), `status` (Unread/Read/Actioned), `type` (giới hạn 2 giá trị theo Mục 3).
2. Logic gộp thông báo (Mục 4) chạy trước khi tạo bản ghi mới — kiểm tra có Notification cùng loại trong khung giờ gần đó chưa.
3. Đồng bộ trạng thái `Actioned` tự động khi Task/Match nguồn đổi trạng thái, không cần thao tác thủ công riêng.
4. Không xây dựng bảng cấu hình tùy chọn thông báo (per-user settings) ở Giai đoạn 1.

## 7. Việc AI PHẢI tuân thủ khi sinh code

- Không tự tạo loại thông báo mới ngoài 2 loại đã định nghĩa ở Mục 3.
- Không tự thêm kênh gửi (push/SMS/email) dù có sẵn thư viện dễ tích hợp — giữ đúng in-app.
- Phải áp dụng logic gộp thông báo (Mục 4) trước khi tạo bản ghi mới, không gửi riêng lẻ từng sự kiện nhỏ.

---

## CTO Review

Founder, RFC này là ví dụ tốt về việc "làm đủ để hệ thống sống được, không làm thừa". Notification tối thiểu tồn tại chỉ để phục vụ đúng một mục đích: đảm bảo Task từ AI Follow-up không bị rơi vào im lặng, vì đó là nguồn duy nhất của North Star Metric. Mọi thứ vượt ra ngoài mục đích đó (đa kênh, tùy chỉnh, nhiều loại sự kiện) đều bị hoãn có chủ đích sang Giai đoạn 2.

---

## Tổng kết: Bộ RFC nền tảng cho Kế hoạch 90 ngày đã hoàn chỉnh

```text
RFC-004   Canonical Entities         — nền tảng chung
RFC-005   Ownership & Permission     — quyền hạn, chuẩn bị Co-op
RFC-006   AI Memory                  — cơ chế trích xuất & suy luận
RFC-008   Property Match             — nguyên tắc ghép nối
RFC-007   AI Follow-up               — cơ chế sinh gợi ý hành động
RFC-009   Navigation & Theme         — kiến trúc UI nền tảng
RFC-010   Notification tối thiểu     — đóng vòng lặp thông báo
```

Đến đây, Backend Developer, Flutter Developer, và AI đều có đủ tài liệu để bắt đầu Tuần 1 mà không cần tự đoán kiến trúc. Founder có thể cân nhắc bước tiếp theo:

1. **Review tổng thể** — đọc lại toàn bộ 7 RFC một lượt trước khi bấm nút "bắt đầu code", đảm bảo không có mâu thuẫn giữa các RFC.
2. **Viết RFC riêng cho Supabase Schema cụ thể** — chuyển 7 RFC khái niệm này thành một file schema SQL nháp (bảng, cột, RLS policy) làm tài liệu kỹ thuật cụ thể hơn cho Tuần 1-3.
3. **Bắt đầu code ngay** — nếu bạn đã sẵn sàng, không cần thêm RFC nữa ở giai đoạn này.

Bạn muốn đi hướng nào?
