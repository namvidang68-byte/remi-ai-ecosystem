# KẾ HOẠCH 90 NGÀY — PHIÊN BẢN KHÓA

**Trạng thái:** Approved — Locked
**Ngày khóa:** (điền ngày triển khai thực tế)
**Phạm vi:** 4 module lõi — AI CRM, AI Memory, Property, AI Follow-up

---

## 1. Thông số đã chốt

| Hạng mục | Quyết định |
|---|---|
| Nguồn Lead đầu vào | Nhập tay (chưa tích hợp nguồn ngoài) |
| Khu vực beta | Rạch Giá, Kiên Giang |
| Phân khúc beta | Đất nền & Nhà phố thổ cư |
| Số lượng môi giới beta | 30–50 |
| North Star Metric (đo chính thức) | Số lần AI Follow-up được môi giới xác nhận đã thực hiện / môi giới / tuần |
| Metric theo dõi song song (chưa đánh giá) | Số Lead chuyển trạng thái tiến bộ trong Pipeline / môi giới / tuần |

**Ghi chú tuyển môi giới beta:** ưu tiên môi giới có phân khúc trùng nhau (đất nền & nhà phố thổ cư tại Rạch Giá), không tuyển đại trà theo phân khúc khác — để chuẩn bị sẵn density cho Marketplace ở Giai đoạn 2.

---

## 2. Timeline chi tiết

### Tháng 1 — Nền tảng + CRM lõi

**Tuần 1–3: Nền tảng dữ liệu**
- Thiết kế Canonical Entities theo mô hình Lead-centric
- Chuẩn hóa Database schema
- Chuẩn hóa Models (backend + Flutter)
- Chuẩn hóa Navigation
- Hoàn thiện Theme

**Tuần 4: AI CRM (khung)**
- Lead capture — nhập tay
- Pipeline/trạng thái Lead — **thiết kế đủ chi tiết để track được Metric B** (Mới → Đang chăm sóc → Có nhu cầu rõ → Đã hẹn xem property → ...)
- Timeline hiển thị lịch sử tương tác

### Tháng 2 — AI Memory + Property

**Tuần 5–6: AI Memory**
- Ghi nhận ngữ cảnh hội thoại/tương tác vào Lead
- Cơ chế AI "nhớ" thông tin khách (nhu cầu, ngân sách, khu vực quan tâm)
- Liên kết Memory ↔ Timeline

**Tuần 7–8: Property**
- Property database (đất nền & nhà phố thổ cư, khu vực Rạch Giá)
- Property Match cơ bản (khớp Lead ↔ Property theo tiêu chí)
- Tính năng tổng hợp property gửi khách (thay "Giỏ hàng")

### Tháng 3 — AI Follow-up + Beta

**Tuần 9–10: AI Follow-up**
- Nhắc việc dựa trên trạng thái Lead và Memory
- Gợi ý thời điểm follow-up
- Nút xác nhận "Đã thực hiện" — **đây là nguồn dữ liệu cho North Star Metric chính thức**
- Đóng vòng lặp: Lead → Memory → Property Match → Follow-up

**Tuần 11: Dashboard tối giản**
- Danh sách Lead + hành động cần làm hôm nay
- Không làm Dashboard AI phức tạp

**Tuần 12: Beta**
- Tuyển 30–50 môi giới tại Rạch Giá, phân khúc đất nền & nhà phố thổ cư
- Event tracking cho cả Metric A (chính thức) và Metric B (song song) chạy từ ngày đầu beta

---

## 3. Loại khỏi phạm vi 90 ngày

| Mục | Dời đến |
|---|---|
| Marketplace | Đầu Giai đoạn 2 |
| Chia sẻ nguồn hàng (mạng lưới) | Giai đoạn 2 |
| Trust Score | Giai đoạn 2 (cần dữ liệu giao dịch thật) |
| Notification Engine đầy đủ | Giai đoạn 2 (chỉ giữ notification tối thiểu cho AI Follow-up) |
| Smart Match (AI matching phức tạp) | Giai đoạn 2 (bản đầu chỉ có Property Match cơ bản) |
| Dashboard AI | Giai đoạn 2 |

---

## 4. Điều kiện chuyển sang Giai đoạn 2

Chỉ mở Marketplace/Trust Score khi đạt **đồng thời**:
- Đủ 30–50 môi giới beta hoạt động tại Rạch Giá, cùng phân khúc đất nền & nhà phố thổ cư
- Metric A đạt ngưỡng ổn định liên tục ≥4 tuần (ngưỡng cụ thể sẽ chốt sau khi có dữ liệu beta 4 tuần đầu, vì hiện chưa có baseline để đặt số)
- Metric B cho thấy Lead thực sự tiến bộ qua Pipeline, không chỉ dừng ở "Mới"

---

## 5. Rủi ro cần giám sát trong quá trình chạy

- **Tuần 1–3 trễ tiến độ**: đây là rủi ro cao nhất vì đổi kiến trúc sang Lead-centric là việc khó ước lượng chính xác cho một founder solo. Nếu trễ, ưu tiên cắt bớt phạm vi Tuần 4 (Pipeline) trước, không cắt nền tảng dữ liệu.
- **Phân khúc đất nền có thể có chu kỳ pháp lý phức tạp** (sổ đỏ, quy hoạch) — nếu AI Follow-up gợi ý không tính đến yếu tố này, độ tin cậy AI với môi giới sẽ giảm. Cần thu thập phản hồi định tính từ môi giới beta ngay từ tuần đầu, không chỉ nhìn số liệu.
