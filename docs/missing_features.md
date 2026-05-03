# PDF Reader - Tính năng và trạng thái phát triển

## 📊 Tổng quan

Ứng dụng PDF Reader offline với trọng tâm vào trải nghiệm đọc và quản lý thư viện cá nhân.

**Trạng thái hiện tại:** ✅ Các tính năng cốt lõi đã hoạt động
**Ngày cập nhật:** 3/5/2026

---

## ✅ TÍNH NĂNG ĐÃ HOÀN THÀNH

### 📖 Đọc PDF
- **✅ PDF rendering**: pdfrx 2.2.24 engine
- **✅ Cuộn dọc & cuộn ngang**: Toggle trong settings, snap-to-page khi cuộn ngang
- **✅ Velocity-aware scroll**: Tốc độ scroll tăng theo velocity user (ClampingScrollPhysics)
- **✅ Page centering**: Page center đúng khi cuộn ngang (PdfPageAnchor.all)
- **✅ Navigation**: Chuyển trang, table of contents (TOC)
- **✅ Search trong PDF**: Tìm kiếm văn bản, auto-search khi gõ, TextInputAction.search
- **✅ Bookmark**: Đánh dấu trang (thêm/xóa), danh sách bookmarks
- **✅ Text selection**: Chọn văn bản, copy, select all
- **✅ Pinch-to-zoom**: Zoom bằng 2 ngón tay (native pdfrx)

### ✏️ Highlight
- **✅ Tạo highlight**: Select text → context menu "Highlight" → chọn màu + ghi chú → Save
- **✅ 6 màu highlight**: Yellow, green, blue, red, purple, orange
- **✅ Highlight drawing chính xác**: charRects + PdfPageText
- **✅ Tap on highlight**: Tap trực tiếp lên highlight → hiện form edit (màu + ghi chú + Save + Delete)
- **✅ Danh sách highlights theo page**: FAB badge hiển thị số highlights, tap → danh sách
- **✅ Danh sách highlights toàn bộ**: Menu ba chấm → Highlights
- **✅ Edit highlight**: Đổi màu, sửa ghi chú, xóa
- **✅ Persistent**: Lưu vào Hive, giữ qua restart app

### 📚 Quản lý thư viện
- **✅ Book management**: Thêm, xóa, chỉnh sửa sách
- **✅ Category management**: Quản lý danh mục với màu sắc
- **✅ Category badge**: Bookmark ribbon badge trên book card
- **✅ Category filter**: Filter chips theo category (hoạt động đúng)
- **✅ Smart collections**: Recently Added, Unread, Almost Finished, Frequently Read
  - Filter books khi tap vào collection
  - Nút back (←) để clear filter
- **✅ Progress tracking**: Theo dõi tiến độ đọc (trang, thời gian)
- **✅ Reading statistics**: Thống kê đọc
- **✅ Reading goals**: Mục tiêu đọc (cycle toggle)
- **✅ Import/export**: Nhập/xuất sách và dữ liệu
- **✅ Thumbnail**: Hiển thị trang bìa PDF trên book card

### 🔊 Text-to-Speech (TTS)
- **✅ Offline TTS**: flutter_tts + native TTS engine (Google TTS trên Android)
- **✅ Foreground service**: Tiếp tục đọc khi app ở background (flutter_foreground_task)
- **✅ Per-page reading**: Đọc từng page, hết page tự chuyển + đọc tiếp
- **✅ Manual page change**: User vuốt page khi đang đọc → stop cũ, đọc page mới
- **✅ Toggle button**: Nút trên app bar đổi icon (🎙️ idle / ⏹️ đang đọc), tap toggle
- **✅ Speed control**: Menu ba chấm → TTS Speed (0.5x / 1x / 1.5x / 2x), đổi speed khi đang đọc sẽ restart với speed mới
- **✅ Language auto-detect**: Rule-based detect Vietnamese, Chinese, Japanese, Korean, Thai, fallback English
- **✅ Auto language switch**: Tự chuyển TTS language theo nội dung PDF
- **✅ Text cleaning**: Nối dòng bị ngắt do PDF layout, giữ paragraph break
- **✅ Voice install check**: Kiểm tra voice đã cài chưa, hướng dẫn download
- **✅ Settings TTS info**: Hiển thị trạng thái TTS + danh sách language packs (installed/not)
- **✅ Open TTS Settings**: Tap language chưa installed → mở Android TTS Settings (platform channel)
- **✅ Auto refresh**: Tự cập nhật trạng thái installed khi quay lại app
- **✅ Scanned PDF detection**: Hiện thông báo khi page không có text

### ⚙️ Cài đặt
- **✅ Settings toggle UX**: Cycle/toggle thay vì dropdown
- **✅ Theme**: System / Light / Dark (cycle)
- **✅ Language**: Tiếng Việt ↔ English (toggle)
- **✅ Scroll direction**: Cuộn ngang ↔ Cuộn dọc
- **✅ Localization**: Đa ngôn ngữ

---

## 🔧 CẦN HOÀN THIỆN (Ưu tiên cao)

### Annotation tools (mở rộng từ highlight)
- Text annotation (ghi chú văn bản trực tiếp lên PDF)
- Drawing/pen tool (vẽ tự do)
- Shape tools (hình chữ nhật, hình tròn, mũi tên)

### Quản lý sách nâng cao
- **Advanced search**: Tìm theo tag, rating, metadata
- **Ratings**: Đánh giá sách
- **Reading lists**: Danh sách đọc tùy chỉnh
- **Tags/labels**: Tag cho sách (ngoài category)

### Trải nghiệm người dùng
- **Accessibility**: Screen reader, high contrast
- **Custom themes**: Màu sắc, font chữ
- **Gesture customization**: Swipe, tap zones

---

## 📋 ĐỀ XUẤT THÊM (Ưu tiên trung bình)

- **Reading streaks**: Chuỗi ngày đọc liên tiếp
- **Achievements/badges**: Thành tích
- **Local backup/restore**: Sao lưu cục bộ
- **Batch operations**: Thao tác hàng loạt
- **Reading reminders**: Nhắc nhở đọc sách
- **Offline dictionary**: Tra từ trong PDF

---

## 🚀 TƯƠNG LAI (Ưu tiên thấp)

- **App lock**: PIN/biometric
- **PDF manipulation**: Gộp, trích xuất, nén PDF
- **OCR**: Nhận dạng văn bản từ hình ảnh
- **Cloud backup**: Sao lưu cloud (tùy chọn)

---

## 📝 Ghi chú kỹ thuật

- **pdfrx 2.2.24**: PDF rendering, text selection, scrollPhysics, onGeneralTap
- **flutter_tts 4.2.x**: Offline TTS với native engine
- **flutter_foreground_task 8.x**: Foreground service cho TTS background
- **Hive**: Local storage cho books, highlights, bookmarks, settings
- **Material Design 3**: Giao diện
- **Hoàn toàn offline**: Không yêu cầu internet

### Đã xóa (không cần)
- Night mode (chế độ tối riêng cho PDF viewer)
- Zoom controls overlay (pinch-to-zoom đủ dùng)
- Bookmark notes (ghi chú theo bookmark)

---

*Cập nhật: 3/5/2026*
