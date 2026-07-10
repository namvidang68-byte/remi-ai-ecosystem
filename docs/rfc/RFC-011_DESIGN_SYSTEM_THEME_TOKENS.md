# 📘 BOOK 02 — PART VI: OPERATING SYSTEM (nền tảng UI — cụ thể hóa RFC-009)

# RFC-011
# DESIGN SYSTEM — THEME TOKENS (GIÁ TRỊ CỤ THỂ)

## Metadata

```text
RFC ID          RFC-011
Status           Approved
Priority         High
Dependencies     RFC-009 (Navigation & Theme — nguyên tắc), RFC-004 (Canonical Entities)
Phạm vi code     Tuần 1–3 (trước khi Flutter Dev code Widget đầu tiên)
Đọc trước bởi    AI, Flutter Developer, UI Designer
```

---

## 1. Vì sao RFC này tồn tại

RFC-009 đã định nghĩa **nguyên tắc**: mọi Widget phải tham chiếu token trung tâm, không hard-code màu/spacing. Nhưng RFC-009 chưa có **giá trị cụ thể** — Flutter Developer không thể viết `AppColors.primary` nếu chưa biết `primary` là mã màu gì.

RFC này cung cấp bộ giá trị đầy đủ, đủ để tạo file `app_theme.dart` ngay hôm nay, không cần chờ UI Designer làm mockup Figma trước (mockup có thể làm song song, dùng đúng token này).

---

## 2. Định hướng thẩm mỹ (Product Designer)

**Cảm nhận thương hiệu REMI cần truyền tải:** đáng tin cậy (trust — quan trọng nhất với môi giới BĐS xử lý giao dịch giá trị lớn), chuyên nghiệp nhưng không lạnh lùng, hiện đại nhưng không "công nghệ phô trương". Tránh thẩm mỹ kiểu fintech lạnh (xanh dương thuần) hoặc mạng xã hội sặc sỡ.

**Màu chủ đạo: Xanh lá đậm (Deep Green)** — lý do:
- Gắn liền với "đất" (bất động sản), tăng trưởng, thịnh vượng — liên tưởng tự nhiên với ngành.
- Khác biệt với đa số CRM/proptech dùng xanh dương — giúp REMI dễ nhận diện trong thị trường Việt Nam.
- Tông trầm, đậm tạo cảm giác đáng tin, không phải màu "trẻ trâu" của app tiêu dùng thông thường.

**Font chữ: Be Vietnam Pro** — lý do:
- Thiết kế riêng cho tiếng Việt, hỗ trợ đầy đủ dấu thanh điệu chuẩn, không lỗi font như nhiều font quốc tế khi hiển thị tiếng Việt.
- Miễn phí (Google Fonts), dễ tích hợp Flutter qua `google_fonts` package.
- Có đủ dải weight (400–700) để phân cấp thông tin rõ ràng mà không cần font phụ.

---

## 3. Color Tokens

### 3.1 Primary Scale (Xanh lá đậm)

```text
primary-900   #0B3D24   — dùng cho text nhấn mạnh trên nền sáng, hiếm dùng
primary-700   #145C36   — Primary chính: nút bấm, active state, icon chính
primary-500   #1E7D4C   — hover/pressed state của primary-700
primary-100   #D7ECE1   — nền nhẹ (badge, highlight), background cho trạng thái active nhạt
primary-50    #F1F8F4   — nền rất nhẹ, dùng cho Card/Section nổi bật nhẹ
```

### 3.2 Neutral Scale (Xám — nền, text phụ, border)

```text
neutral-900   #1A1D1E   — text chính (tiêu đề, nội dung quan trọng)
neutral-700   #4A4F52   — text phụ (mô tả, label)
neutral-500   #8B9194   — text disabled, placeholder
neutral-300   #D8DBDC   — border, divider
neutral-100   #F2F3F3   — nền nền (background chính của app)
neutral-0     #FFFFFF   — nền Card/Surface
```

### 3.3 Semantic Colors (trạng thái)

```text
success        #1E7D4C   — trùng primary-500 (Task Confirmed, Match thành công)
warning         #C97A1E   — Task cần chú ý, Match Sent quá lâu (RFC-007/008/010)
error           #C23B3B   — Lead/Property lỗi, validation, mâu thuẫn Memory (RFC-006 conflicting)
info            #2E6EA6   — thông báo trung tính, gợi ý AI mức Medium/Low confidence
```

**Ánh xạ trực tiếp với các RFC trước** (để Flutter Dev biết dùng màu nào ở đâu):
```text
memory_status.conflicting   → error
memory_confidence.low       → neutral-500 (nhạt, không nổi bật — RFC-006)
task_status.confirmed       → success
task_status.dismissed       → neutral-500
match_status.sent (quá hạn) → warning
```

### 3.4 Kiểm tra độ tương phản (Accessibility)

`primary-700` (#145C36) trên nền `neutral-0` (#FFFFFF) đạt tỷ lệ tương phản ≈ 7.8:1 — vượt chuẩn WCAG AA (4.5:1) cho text thường. `neutral-700` trên `neutral-0` ≈ 8.6:1 — đạt chuẩn. Không cần điều chỉnh thêm ở bản v1.

---

## 4. Typography Scale

```text
Font family: 'Be Vietnam Pro' (qua google_fonts package)

display     32px / weight 700 / line-height 1.25   — hiếm dùng, màn hình chào mừng onboarding
heading-1   24px / weight 700 / line-height 1.3    — tiêu đề màn hình (VD: "Chi tiết Lead")
heading-2   20px / weight 600 / line-height 1.3    — tiêu đề section/tab
heading-3   16px / weight 600 / line-height 1.4    — tiêu đề card, item quan trọng
body-large  16px / weight 400 / line-height 1.5    — nội dung chính, mô tả
body        14px / weight 400 / line-height 1.5    — nội dung phụ, list item
caption     12px / weight 400 / line-height 1.4    — label, timestamp, metadata phụ
button      14px / weight 600 / line-height 1.2    — chữ trên nút bấm
```

**Nguyên tắc bất biến:** không dùng font-size tùy tiện ngoài 8 mức trên. Nếu Flutter Dev/AI thấy cần size khác khi code Widget cụ thể, phải quay lại sửa RFC này trước (theo quy trình RFC Amendment), không tự thêm giá trị mới trực tiếp trong code.

---

## 5. Spacing Scale

Dùng thang bội số của 4px — chuẩn phổ biến, dễ tính nhẩm khi thiết kế:

```text
xs    4px    — khoảng cách rất nhỏ (giữa icon và text sát nhau)
sm    8px    — khoảng cách trong nhóm liên quan (giữa các dòng trong 1 Card)
md    16px   — khoảng cách chuẩn (padding mặc định của Card, Screen)
lg    24px   — khoảng cách giữa các section
xl    32px   — khoảng cách lớn (đầu/cuối màn hình, giữa các nhóm nội dung lớn)
xxl   48px   — hiếm dùng, khoảng trắng lớn (empty state, onboarding)
```

---

## 6. Border Radius & Elevation

```text
radius-sm    6px    — input field, badge nhỏ
radius-md    12px   — Card, Button (mặc định toàn hệ thống)
radius-lg    20px   — Bottom Sheet, Modal

elevation-1  shadow nhẹ — Card thường trên nền neutral-100
elevation-2  shadow rõ hơn — Card đang được kéo/tương tác, Floating Action Button
```

---

## 7. Component Tokens — quy tắc cho 3 thành phần dùng nhiều nhất

### 7.1 Button (Primary)
```text
background: primary-700
text: neutral-0, style button (14px/600)
radius: radius-md
padding: vertical sm(8), horizontal md(16)
pressed state: primary-500
disabled state: neutral-300 background, neutral-500 text
```

### 7.2 Card (dùng cho Lead item, Property item, Task item)
```text
background: neutral-0
radius: radius-md
padding: md(16)
elevation: elevation-1
border: 1px neutral-300 (tùy chọn, dùng khi elevation không đủ phân tách trên nền neutral-100)
```

### 7.3 Input Field
```text
background: neutral-0
border: 1px neutral-300 (default) → 1px primary-700 (focus) → 1px error (validation lỗi)
radius: radius-sm
text: body (14px/400), placeholder màu neutral-500
padding: sm(8) vertical, md(16) horizontal
```

---

## 8. Việc Flutter Developer PHẢI làm khi đọc RFC này

1. Tạo 4 file trong `lib/core/theme/`: `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart` — dùng đúng giá trị ở Mục 3-6 (đã chuẩn bị sẵn code mẫu kèm RFC này trong repo, xem `app/lib/core/theme/`).
2. Thêm `google_fonts` vào `pubspec.yaml`, dùng `GoogleFonts.beVietnamPro()` cho toàn bộ TextTheme.
3. Mọi Widget mới bắt buộc import theme, không viết `Color(0xFF...)` hoặc `TextStyle(fontSize: ...)` trực tiếp — vi phạm nguyên tắc RFC-009 Mục 4.
4. Áp dụng ánh xạ semantic color (Mục 3.3) đúng theo trạng thái entity đã định nghĩa ở RFC-006/007/008/010 — không tự chọn màu khác cho các trạng thái đó.

## 9. Việc AI PHẢI tuân thủ khi sinh code Widget

- Luôn tham chiếu `AppColors`, `AppTypography`, `AppSpacing` — không hard-code giá trị hex hoặc số px trực tiếp.
- Khi sinh Widget hiển thị trạng thái (Task/Match/Memory), phải dùng đúng semantic color đã ánh xạ ở Mục 3.3, không tự chọn màu theo cảm tính.
- Không tự thêm màu/font-size mới ngoài bộ token đã định nghĩa — nếu thấy thiếu, phải dừng lại và đề xuất bổ sung RFC, không tự quyết định trong code.

---

## CTO Review

Founder, đây là RFC cuối cùng cần thiết trước khi Flutter Developer chạm vào Widget đầu tiên — sau RFC này, toàn bộ 8 RFC (004→011) đã đủ để bắt đầu code Tuần 1 mà không phải dừng lại đoán bất kỳ giá trị nào, kể cả màu sắc.

Lựa chọn xanh lá đậm + Be Vietnam Pro là quyết định có thể điều chỉnh sau khi có phản hồi thật từ môi giới Beta — nhưng vì token đã được tách biệt hoàn toàn khỏi Widget (đúng nguyên tắc RFC-009), việc đổi màu thương hiệu sau này chỉ là sửa 1 file `app_colors.dart`, không phải sửa lại hàng trăm dòng code rải rác.

Tôi đã chuẩn bị sẵn 4 file Dart tương ứng trong `app/lib/core/theme/` để bạn/Flutter Dev copy thẳng vào dự án ngay khi chạy `flutter create`.
