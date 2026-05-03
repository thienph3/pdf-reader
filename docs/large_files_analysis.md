# Analysis of Large Files in PDF Reader Project

## Files with > 300 lines of code

### 1. **pdf_view_screen.dart** (1553 dòng) - **ĐÃ REFACTOR**
- **Status**: Đã refactor thành các module nhỏ
- **New structure**:
  - `pdf_view_screen_refactored.dart` (978 dòng)
  - `pdf_highlight_manager.dart` (306 dòng)
  - `pdf_bookmark_manager.dart` (157 dòng)
  - `pdf_text_selection_manager.dart` (161 dòng)
  - `pdf_ui_controls.dart` (122 dòng)
- **Total after refactor**: 1724 dòng (tăng 171 dòng nhưng modular hơn)

### 2. **book_list_screen.dart** (610 dòng) - **CẦN REFACTOR**
- **Chức năng chính**:
  - Hiển thị danh sách sách (grid/list view)
  - Tìm kiếm và lọc theo category
  - Sắp xếp (updatedDesc, titleAsc, createdDesc)
  - Smart collections (recent, unread, etc.)
  - Xử lý các action (thêm, sửa, xóa, mở sách)
- **Có thể refactor thành**:
  1. **BookListManager**: Logic danh sách, lọc, sắp xếp
  2. **BookListUI**: UI components (grid/list view, empty state)
  3. **BookActionsManager**: Xử lý các action trên sách
  4. **SmartCollectionsManager**: Quản lý smart collections

### 3. **book_form_screen.dart** (350 dòng) - **CÓ THỂ REFACTOR**
- **Chức năng chính**:
  - Form tạo/chỉnh sửa sách
  - Pick file PDF
  - Chọn category và format
  - Validation
- **Có thể refactor thành**:
  1. **BookFormManager**: Logic form và validation
  2. **BookFormUI**: UI components
  3. **FilePickerManager**: Quản lý file picking

### 4. **book_card.dart** (312 dòng) - **WIDGET LỚN**
- **Chức năng**: Widget hiển thị sách dạng card
- **Có thể**: Tách thành các sub-components nếu phức tạp

### 5. **pdf_highlight_manager.dart** (306 dòng) - **ĐÃ TẠO**
- **Status**: Module mới từ refactor
- **Chức năng**: Quản lý highlight trong PDF

### 6. **stats_screen.dart** (242 dòng) - **CHẤP NHẬN ĐƯỢC**
- **Chức năng**: Hiển thị thống kê đọc sách
- **Kích thước**: Chấp nhận được

### 7. **book_service.dart** (229 dòng) - **SERVICE LỚN**
- **Chức năng**: Service quản lý sách (CRUD, highlights, bookmarks)
- **Có thể**: Tách thành các service nhỏ hơn nếu cần

### 8. **category_screen.dart** (215 dòng) - **CHẤP NHẬN ĐƯỢC**
- **Chức năng**: Quản lý categories
- **Kích thước**: Chấp nhận được

### 9. **settings_screen.dart** (209 dòng) - **CHẤP NHẬN ĐƯỢC**
- **Chức năng**: Màn hình cài đặt
- **Kích thước**: Chấp nhận được

## Ưu tiên refactor

### High Priority
1. **book_list_screen.dart** (610 dòng) - Quá lớn, nhiều chức năng
2. **book_form_screen.dart** (350 dòng) - Có thể cải thiện

### Medium Priority
1. **book_card.dart** (312 dòng) - Widget lớn
2. **book_service.dart** (229 dòng) - Service lớn

### Low Priority
1. Các file < 250 dòng có thể chấp nhận được

## Recommendation
1. **Refactor book_list_screen.dart** trước vì nó lớn nhất sau pdf_view_screen
2. **Giữ nguyên các file < 250 dòng** trừ khi có vấn đề cụ thể
3. **Áp dụng pattern tương tự** như pdf_view_screen refactor: tách logic và UI

## Metrics Summary
- **Total Dart files**: 7230 dòng
- **Files > 300 dòng**: 6 files (chiếm phần lớn codebase)
- **Average file size**: ~200 dòng (nếu loại trừ các file lớn)
- **Largest file**: pdf_view_screen.dart (1553 dòng) - đã refactor
- **Second largest**: book_list_screen.dart (610 dòng) - cần refactor