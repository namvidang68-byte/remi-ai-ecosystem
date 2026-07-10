# 📘 BOOK 02 — PART III: CORE MODULES (Property) / PART IV: AI

# RFC-008
# PROPERTY MATCH — NGUYÊN TẮC GHÉP NỐI

## Metadata

```text
RFC ID          RFC-008
Status           Approved
Priority         Critical
Dependencies     RFC-004 (Canonical Entities), RFC-006 (AI Memory)
Phạm vi code     Tuần 7–8 (Kế hoạch 90 ngày)
Đọc trước bởi    AI, Backend Developer, Flutter Developer
```

---

## 1. Vì sao RFC này tồn tại

RFC-004 đã định nghĩa Property Match là **entity trung gian**, không phải quan hệ nhiều-nhiều đơn thuần, vì cần lưu ngữ cảnh: ai tạo match, mức độ phù hợp, trạng thái phản hồi.

RFC này trả lời câu hỏi Backend Dev cần trước khi code Tuần 7-8:

> **"Property Match cơ bản" nghĩa là gì? Ghép bằng cơ chế nào, và ghép đến đâu thì dừng lại để không lấn sang phạm vi Smart Match của Giai đoạn 2?**

---

## 2. Ranh giới phạm vi — điều quan trọng nhất của RFC này

Kế hoạch 90 ngày đã khóa: Giai đoạn 1 chỉ làm **"Property Match cơ bản"**, Smart Match (AI matching phức tạp) dời sang Giai đoạn 2.

**Định nghĩa ranh giới cụ thể:**

```text
Property Match cơ bản (Giai đoạn 1)
= Ghép theo luật tường minh (rule-based)
  Ví dụ: cùng khu vực + cùng loại hình + ngân sách trong khoảng ±20%
= Backend Dev viết logic if/query trực tiếp, KHÔNG cần model AI/ML

Smart Match (Giai đoạn 2)
= Ghép có học từ dữ liệu lịch sử (Property Match nào từng dẫn đến Deal thành công)
= Cần dữ liệu feedback tích lũy từ Giai đoạn 1 mới train được
```

**Nguyên tắc bất biến:** dù thuật toán Giai đoạn 1 chỉ là rule-based, **cấu trúc dữ liệu phải đủ để Giai đoạn 2 dùng làm tập huấn luyện**. Đây là lý do RFC này viết kỹ, dù thuật toán bên trong rất đơn giản.

---

## 3. Tiêu chí ghép nối (Giai đoạn 1)

Theo phạm vi beta đã chốt (đất nền & nhà phố thổ cư, Rạch Giá):

```text
Bắt buộc khớp:
- Khu vực (Lead quan tâm khu vực nào ↔ Property ở khu vực đó)
- Loại hình (đất nền / nhà phố)

Khớp có ngưỡng dung sai:
- Ngân sách (Property giá trong khoảng ±20% ngân sách Lead — ngưỡng có thể điều chỉnh, lưu như config, không hard-code)

Không bắt buộc nhưng tăng độ ưu tiên nếu khớp:
- Thông tin từ AI Memory mức Medium/High liên quan (VD: "khách thích hướng Đông Nam")
```

**Nguyên tắc bất biến:** chỉ dùng Memory "Sử dụng được" theo Usability Rule đã định nghĩa ở RFC-006 (Mục 3.5) làm tiêu chí ghép — không tự diễn giải riêng cách kết hợp status/confidence tại đây.

---

## 4. Ai tạo ra một Match — 2 nguồn

```text
Nguồn 1: Hệ thống tự động gợi ý
         (chạy rule-based khi có Property mới hoặc Lead mới)
Nguồn 2: Môi giới tự chọn thủ công
         (môi giới duyệt danh sách Property, tự gắn vào Lead)
```

**Nguyên tắc bất buộc:** bảng `property_matches` phải có trường `created_by` phân biệt rõ 2 nguồn này (`system` hoặc `manual`). Đây là dữ liệu quan trọng cho Giai đoạn 2 — khi train Smart Match, cần biết match nào do AI đề xuất đúng, match nào môi giới phải tự tìm vì hệ thống gợi ý sai/thiếu.

---

## 5. Vòng đời trạng thái của một Match

```text
Suggested   — vừa được tạo (tự động hoặc thủ công), chưa gửi khách
Sent        — đã gửi cho Lead (qua tính năng tổng hợp property, theo RFC-004 mục 3.6)
Viewed      — Lead đã xem/phản hồi quan tâm (ghi nhận thủ công bởi môi giới ở Giai đoạn 1,
              vì chưa có tracking link tự động)
Rejected    — Lead không quan tâm
Archived    — không còn liên quan (VD: Property đã bán cho người khác)
```

**Nguyên tắc bất biến:** không xóa Match dù ở trạng thái `Rejected`. Match bị từ chối là dữ liệu **quý giá ngang bằng** Match thành công cho việc train Smart Match sau này — biết "match sai kiểu gì" quan trọng không kém biết "match đúng kiểu gì".

---

## 6. Liên kết với Task và Timeline

Khi một Match chuyển sang `Sent`, hệ thống nên tự động tạo một `Task` tương ứng (VD: "Follow-up phản hồi Property X") — đây chính là điểm nối vào AI Follow-up sẽ code ở Tuần 9-10 (RFC-007 sau này).

Mọi thay đổi trạng thái Match phải ghi vào Timeline của Lead (đã quy định ở RFC-004) — để môi giới nhìn lại lịch sử tư vấn đầy đủ, không chỉ thấy Property hiện tại.

---

## 7. Việc Backend Dev PHẢI làm khi đọc RFC này

1. Bảng `property_matches` bắt buộc có: `lead_id`, `property_id`, `created_by` (system/manual), `status`, `match_score` (số điểm phù hợp — dù Giai đoạn 1 tính đơn giản bằng rule, vẫn lưu số để so sánh sau này), `matched_criteria` (JSON ghi lại tiêu chí nào đã khớp — quan trọng cho việc phân tích ở Giai đoạn 2).
2. Ngưỡng dung sai (VD: ±20% ngân sách) lưu dưới dạng config, không hard-code trong logic.
3. Logic ghép nối Giai đoạn 1 là query/rule thuần túy — không cần gọi AI model, không cần embedding phức tạp (khác với AI Memory ở RFC-006 vốn cần pgvector).
4. Khi Match chuyển `Sent`, tự động tạo Task liên kết.
5. Không xóa cứng Match ở bất kỳ trạng thái nào.

## 8. Việc AI PHẢI tuân thủ khi sinh code

- Không dùng Memory mức `Low` làm tiêu chí ghép nối.
- Không tự ý gộp logic Smart Match (ML) vào Giai đoạn 1 dù "tiện thể" — giữ đúng ranh giới rule-based đã định nghĩa ở Mục 2.
- Mọi Match sinh ra phải có `matched_criteria` ghi rõ lý do khớp — không tạo Match mà không giải thích được vì sao.

---

## CTO Review

Founder, RFC này giữ đúng kỷ luật đã khóa ở Kế hoạch 90 ngày: thuật toán đơn giản (rule-based), nhưng dữ liệu đủ giàu để không phải làm lại khi Giai đoạn 2 cần Smart Match. Trường `matched_criteria` và `created_by` là hai trường tốn ít công sức nhất để thêm ngay bây giờ, nhưng sẽ là tập dữ liệu huấn luyện quý giá nhất khi bạn có đủ traction để đầu tư vào AI Matching thật sự.

Một điểm cần founder lưu ý: trạng thái `Viewed` ở Giai đoạn 1 phụ thuộc vào **môi giới tự ghi nhận thủ công**, không phải tracking tự động (vì chưa có link theo dõi/landing page riêng cho từng Property gửi khách). Đây là giới hạn thực tế cần chấp nhận ở Beta — nếu môi giới lười cập nhật, dữ liệu Viewed sẽ không đầy đủ. Có thể cân nhắc thêm nhắc nhở nhẹ trong AI Follow-up để môi giới cập nhật trạng thái này.

RFC tiếp theo theo đúng thứ tự code là **RFC-007: AI Follow-up — Cơ chế sinh gợi ý hành động** (Tuần 9-10), giờ đã có đủ nền tảng từ RFC-006 (Memory) và RFC-008 (Match) để định nghĩa AI Follow-up dùng dữ liệu nào để sinh gợi ý.

Bạn muốn tiếp tục RFC-007 không?
