# 📘 BOOK 02 — PART IV: AI

# RFC-007
# AI FOLLOW-UP — CƠ CHẾ SINH GỢI Ý HÀNH ĐỘNG

## Metadata

```text
RFC ID          RFC-007
Status           Approved
Priority         Critical
Dependencies     RFC-004 (Canonical Entities), RFC-006 (AI Memory), RFC-008 (Property Match)
Phạm vi code     Tuần 9–10 (Kế hoạch 90 ngày)
Đọc trước bởi    AI, Backend Developer, Flutter Developer
```

---

## 1. Vì sao RFC này quan trọng nhất trong 4 module lõi

AI Follow-up không phải một module độc lập — nó là **điểm khép vòng lặp** đã mô tả ở Kế hoạch 90 ngày:

```text
Lead → AI Memory → Property Match → AI Follow-up
```

Và quan trọng hơn: hành động "Đã xác nhận thực hiện" trong module này chính là **nguồn dữ liệu duy nhất cho North Star Metric chính thức của Beta** (RFC-002, đã chốt ở Kế hoạch 90 ngày). Nếu RFC này thiết kế sai, không phải chỉ module này hỏng — toàn bộ thước đo thành công của Beta sẽ vô nghĩa.

---

## 2. Ranh giới phạm vi — tránh nhầm với Automation

Kế hoạch 90 ngày đã loại "Automation phức tạp" khỏi Giai đoạn 1 (dời sang Giai đoạn 3). Cần phân biệt rõ:

```text
AI Follow-up (Giai đoạn 1)
= Gợi ý MỘT hành động cụ thể, tại MỘT thời điểm, cho MỘT Lead
= Con người luôn là người quyết định làm hay không
= Không tự động gửi tin nhắn/email thay môi giới

Automation (Giai đoạn 3, chưa build)
= Chuỗi hành động tự động chạy không cần môi giới bấm xác nhận từng bước
= VD: tự động gửi email nhắc khách sau X ngày không phản hồi
```

**Nguyên tắc bất biến:** AI Follow-up ở Giai đoạn 1 chỉ được phép **đề xuất và nhắc**, không được phép **tự hành động thay môi giới**. Đây là ranh giới cứng, không được AI tự "tiện thể" mở rộng khi sinh code.

---

## 3. Input để sinh gợi ý — 3 nguồn dữ liệu

```text
Nguồn 1: Pipeline Status (RFC-004)
         Lead đang ở trạng thái nào → quyết định LOẠI hành động nên gợi ý

Nguồn 2: AI Memory (RFC-006)
         Chỉ dùng Memory "Sử dụng được" theo Usability Rule (RFC-006, Mục 3.5)
         → quyết định NỘI DUNG gợi ý (nói gì với khách)

Nguồn 3: Property Match Status (RFC-008)
         Match đang ở trạng thái nào (Sent/Viewed/Rejected)
         → quyết định THỜI ĐIỂM nên nhắc
```

**Ví dụ cụ thể để Backend Dev hình dung:**
```text
Điều kiện: Property Match ở trạng thái "Sent" quá 3 ngày, chưa chuyển "Viewed"
AI Memory: khách nhạy cảm về giá (confidence: Medium)
   ↓
Gợi ý sinh ra: "Nhắc gọi hỏi khách về Property đã gửi 3 ngày trước,
                lưu ý khách quan tâm về giá — có thể đề cập chính sách
                thương lượng nếu có"
```

---

## 4. Nguyên tắc tần suất — chống Notification Spam

RFC-002 đã liệt kê "Notification Spam" là **Anti-Metric tường minh** — REMI không được tối ưu theo hướng gây nghiện hay làm phiền. Đây là ràng buộc cứng cho RFC này:

```text
Giới hạn tối thiểu:
- Tối đa 1 gợi ý Follow-up / Lead / ngày
- Không gợi ý lại cùng một hành động nếu môi giới đã bỏ qua (dismiss)
  trong vòng 24 giờ gần nhất
- Ưu tiên gợi ý theo Lead có khả năng tiến bộ cao nhất trước
  (không dàn đều thông báo cho tất cả Lead cùng lúc)
```

**Nguyên tắc bất biến:** số lượng gợi ý sinh ra mỗi ngày cho một môi giới phải có trần cấu hình được (config), không hard-code cứng trong logic — vì ngưỡng phù hợp sẽ cần điều chỉnh sau khi có dữ liệu Beta thực tế.

---

## 5. Cơ chế xác nhận — nguồn North Star Metric

Đây là phần quan trọng nhất kỹ thuật. Mỗi gợi ý AI Follow-up sinh ra một `Task` (theo RFC-004), và Task này bắt buộc có 3 trạng thái phản hồi rõ ràng — không phải chỉ "done/not done":

```text
Confirmed    — môi giới xác nhận ĐÃ thực hiện hành động này
              → đây là sự kiện được đếm vào North Star Metric
Dismissed    — môi giới bỏ qua, không thực hiện
              → không đếm vào Metric, nhưng dùng để tính AI Acceptance Rate (RFC-002)
Snoozed      — môi giới hoãn lại, muốn nhắc lại sau
              → không đếm vào Metric, hệ thống lên lịch nhắc lại
```

**Nguyên tắc bất biến:** trạng thái `Confirmed` phải ghi kèm `confirmed_at` (thời điểm) và không được sửa lại sau khi đã xác nhận — đây là dữ liệu gốc cho báo cáo Beta, không được phép chỉnh sửa hồi tố.

---

## 6. Tín hiệu phản hồi để cải thiện AI (vòng lặp học)

Mỗi khi môi giới `Dismissed` một gợi ý, hệ thống nên ghi nhận lý do nếu có thể (tùy chọn, không bắt buộc nhập ở Beta): gợi ý sai thời điểm, gợi ý không liên quan, đã tự làm cách khác...

**Nguyên tắc bất biến:** tỷ lệ `Dismissed` cao liên tục cho một loại gợi ý cụ thể là tín hiệu **AI đang gợi ý sai**, không phải tín hiệu "môi giới lười". Khi phân tích dữ liệu Beta, không được mặc định quy lỗi cho người dùng trước khi xem xét lại logic gợi ý.

---

## 7. Liên kết Pipeline — dữ liệu song song cho Metric B

Khi Task chuyển `Confirmed` và dẫn đến việc Lead đổi trạng thái Pipeline (VD: từ "Đang chăm sóc" sang "Có nhu cầu rõ"), sự kiện này phải ghi vào Timeline và tính vào Metric B (theo dõi song song, chưa dùng đánh giá Beta chính thức — theo quyết định ở Kế hoạch 90 ngày).

---

## 8. Việc Backend Dev PHẢI làm khi đọc RFC này

1. Bảng `tasks` (đã có ở RFC-004) bổ sung: `status` (Confirmed/Dismissed/Snoozed), `confirmed_at`, `generated_from` (nguồn: Pipeline stage nào, Memory nào, Match nào — để truy vết).
2. Giới hạn tần suất gợi ý lưu dưới dạng config (`max_suggestions_per_lead_per_day`), không hard-code.
3. Logic chống lặp gợi ý đã dismiss trong 24h phải kiểm tra trước khi sinh Task mới.
4. Task đã `Confirmed` không cho phép sửa `confirmed_at` — chỉ đọc, không ghi lại.
5. Event `Confirmed` phải bắn ra event riêng biệt dùng cho báo cáo North Star Metric — tách biệt khỏi log thông thường để dễ truy vấn.

## 9. Việc AI PHẢI tuân thủ khi sinh code hoặc khi vận hành (runtime)

- Không tự động thực hiện hành động thay môi giới (gửi tin nhắn/email tự động) — chỉ được đề xuất.
- Không dùng Memory mức `Low` (RFC-006) làm căn cứ sinh nội dung gợi ý.
- Không sinh quá số lượng gợi ý đã cấu hình cho một Lead/ngày.
- Không gợi ý lại hành động vừa bị dismiss trong vòng 24 giờ.

---

## CTO Review

Founder, RFC này khép vòng lặp 4 module lõi đúng như tinh thần bạn đặt ra ban đầu. Điều mình muốn nhấn mạnh lại: ranh giới giữa "gợi ý" và "tự động hành động" không phải chỉ là giới hạn kỹ thuật của Giai đoạn 1 — nó còn là **nguyên tắc niềm tin**. Một môi giới sẽ rời bỏ REMI ngay nếu AI tự ý làm gì đó thay họ mà họ không kiểm soát được (VD: tự gửi tin nhắn sai ngữ cảnh cho khách). Automation tự động chỉ nên mở ở Giai đoạn 3, sau khi đã có đủ dữ liệu Beta để biết gợi ý nào đáng tin để tự động hóa.

Đến đây, cả 4 module lõi (AI CRM/Pipeline từ RFC-004, AI Memory từ RFC-006, Property/Property Match từ RFC-008, và AI Follow-up từ RFC-007) đã có nền tảng RFC đầy đủ để Backend Dev bắt tay code theo đúng Kế hoạch 90 ngày đã khóa.

**Việc còn thiếu trước khi bắt đầu code Tuần 1:**
- RFC riêng cho phần Ownership/Permission đã có (RFC-005), nhưng chưa có RFC mô tả **Navigation/Theme** (Tuần 1-3 cũng bao gồm phần này) và chưa có RFC cho **Notification tối thiểu** (đã nhắc ở RFC-007 nhưng chưa định nghĩa chi tiết cơ chế gửi thông báo trong app).

Bạn muốn viết tiếp RFC cho phần nào — Notification tối thiểu, hay dừng lại ở đây và chuyển sang review tổng thể toàn bộ 5 RFC đã có trước khi bắt đầu code?
