// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'PDF Reader';

  @override
  String get cancel => 'Huỷ';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xoá';

  @override
  String get edit => 'Sửa';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get splashSubtitle => 'Thư viện sách của bạn';

  @override
  String get library => 'Thư viện sách';

  @override
  String get searchHint => 'Tìm theo tên hoặc tác giả...';

  @override
  String get noBooks => 'Chưa có sách nào.';

  @override
  String get addBookHint => 'Bấm + để thêm sách mới';

  @override
  String get noResults => 'Không tìm thấy sách.';

  @override
  String get sortUpdated => 'Mới cập nhật';

  @override
  String get sortTitle => 'Tên A-Z';

  @override
  String get sortCreated => 'Mới thêm';

  @override
  String get listView => 'Xem danh sách';

  @override
  String get gridView => 'Xem lưới';

  @override
  String get exportLib => 'Xuất thư viện';

  @override
  String get importLib => 'Nhập thư viện';

  @override
  String get exportSuccess => 'Đã xuất thư viện thành công';

  @override
  String importSuccess(int n) {
    return 'Đã nhập $n sách mới';
  }

  @override
  String bookDeleted(String title) {
    return '\"$title\" đã xoá';
  }

  @override
  String get all => 'Tất cả';

  @override
  String get readBook => 'Đọc sách';

  @override
  String get sort => 'Sắp xếp';

  @override
  String error(String msg) {
    return 'Lỗi: $msg';
  }

  @override
  String get addBook => 'Thêm sách';

  @override
  String get editBook => 'Sửa sách';

  @override
  String get bookTitle => 'Tên sách *';

  @override
  String get bookTitleRequired => 'Vui lòng nhập tên sách';

  @override
  String get author => 'Tác giả';

  @override
  String get bookType => 'Loại sách';

  @override
  String get paper => 'Giấy';

  @override
  String get ebook => 'Ebook';

  @override
  String get both => 'Cả hai';

  @override
  String get category => 'Danh mục';

  @override
  String get noCategory => 'Không có';

  @override
  String get selectCategory => 'Chọn danh mục';

  @override
  String get pdfFile => 'File PDF';

  @override
  String get pickFile => 'Chọn file PDF';

  @override
  String get changeFile => 'Đổi file';

  @override
  String get notes => 'Ghi chú';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get discardTitle => 'Huỷ thay đổi?';

  @override
  String get discardMessage => 'Bạn có thay đổi chưa lưu. Muốn huỷ bỏ?';

  @override
  String get continueEditing => 'Tiếp tục sửa';

  @override
  String get discard => 'Huỷ bỏ';

  @override
  String get paperBook => 'Sách giấy';

  @override
  String get ebookLabel => 'Ebook';

  @override
  String get paperAndEbook => 'Giấy + Ebook';

  @override
  String get openingPdf => 'Đang mở file PDF...';

  @override
  String get noBookmarks => 'Chưa có bookmark nào';

  @override
  String get addBookmark => 'Thêm bookmark';

  @override
  String get removeBookmark => 'Bỏ bookmark';

  @override
  String get bookmarkList => 'Danh sách bookmark';

  @override
  String page(int n) {
    return 'Trang $n';
  }

  @override
  String get categories => 'Danh mục';

  @override
  String get manageCategories => 'Quản lý danh mục';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get editCategory => 'Sửa danh mục';

  @override
  String get deleteCategory => 'Xoá danh mục';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get noCategoriesYet => 'Chưa có danh mục nào.\nBấm + để thêm.';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Bạn muốn xoá \"$name\"?\nSách thuộc danh mục này sẽ không bị xoá.';
  }

  @override
  String get settings => 'Cài đặt';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get langVi => 'Tiếng Việt';

  @override
  String get langEn => 'English';

  @override
  String get scrollDirection => 'Hướng cuộn PDF';

  @override
  String get scrollVertical => 'Cuộn dọc';

  @override
  String get scrollHorizontal => 'Cuộn ngang';

  @override
  String get deleteBook => 'Xoá sách';

  @override
  String deleteBookConfirm(String title) {
    return 'Bạn muốn xoá \"$title\"?';
  }

  @override
  String get fileNotFound => 'File không tồn tại';

  @override
  String get fileInvalidMessage =>
      'Đường dẫn ebook không hợp lệ. Chọn lại file?';

  @override
  String get repick => 'Chọn lại';

  @override
  String get recentlyOpened => 'Đọc gần đây';

  @override
  String get continueReading => 'Tiếp tục đọc';

  @override
  String get addNote => 'Thêm ghi chú';

  @override
  String get editNote => 'Sửa ghi chú';

  @override
  String get noteHint => 'Ghi chú cho trang này...';

  @override
  String get readingGoals => 'Mục tiêu đọc';

  @override
  String get dailyGoal => 'Mục tiêu hàng ngày';

  @override
  String get monthlyGoal => 'Mục tiêu hàng tháng';

  @override
  String minutesPerDay(int n) {
    return '$n phút/ngày';
  }

  @override
  String booksPerMonth(int n) {
    return '$n sách/tháng';
  }

  @override
  String get todayReading => 'Hôm nay';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get statistics => 'Thống kê';

  @override
  String get totalReadingTime => 'Tổng thời gian đọc';

  @override
  String get booksRead => 'Sách đã đọc';

  @override
  String get avgPerDay => 'Trung bình/ngày';

  @override
  String get tableOfContents => 'Mục lục';

  @override
  String get noToc => 'File PDF không có mục lục';

  @override
  String get searchInPdf => 'Tìm trong PDF';

  @override
  String get searchHintPdf => 'Nhập từ khoá...';

  @override
  String noSearchResults(String q) {
    return 'Không tìm thấy \"$q\"';
  }

  @override
  String get highlight => 'Đánh dấu';

  @override
  String get highlights => 'Đánh dấu';

  @override
  String get addHighlight => 'Đánh dấu văn bản';

  @override
  String get removeHighlight => 'Bỏ đánh dấu';

  @override
  String get highlightNote => 'Ghi chú cho đánh dấu...';

  @override
  String get noHighlights => 'Chưa có đánh dấu nào';

  @override
  String get selectTextToHighlight => 'Chọn văn bản để đánh dấu';

  @override
  String get noHighlightsFound => 'Không có đánh dấu nào';

  @override
  String get noHighlightsOnPage => 'Trang này chưa có đánh dấu';

  @override
  String get selectHighlightColor => 'Chọn màu đánh dấu';

  @override
  String get changeColor => 'Đổi màu';

  @override
  String get deleteHighlight => 'Xoá đánh dấu';

  @override
  String get deleteHighlightConfirm => 'Xoá đánh dấu này?';

  @override
  String get addNoteOptional => 'Thêm ghi chú (tuỳ chọn)';

  @override
  String highlightsOnPage(int n) {
    return 'Đánh dấu trang $n';
  }

  @override
  String get smartCollections => 'Bộ sưu tập';

  @override
  String get tts => 'Đọc to';

  @override
  String get ttsNotAvailable => 'TTS không khả dụng';

  @override
  String get ttsHowToEnable => 'Cách bật TTS';

  @override
  String get ttsSpeed => 'Tốc độ đọc';

  @override
  String get readingSpeed => 'Tốc độ đọc';

  @override
  String get stopReading => 'Dừng đọc';

  @override
  String get readAloud => 'Đọc to';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get voiceSettings => 'Cài đặt giọng đọc';

  @override
  String get ttsAvailable => 'TTS khả dụng';

  @override
  String get noTtsEngine => 'Không tìm thấy TTS engine';

  @override
  String languagesAvailable(int n) {
    return '$n ngôn ngữ';
  }

  @override
  String get downloadVoice => 'Tải giọng đọc';

  @override
  String get downloadVoiceHint =>
      'Để tải giọng đọc, mở cài đặt TTS trên thiết bị.\n\nCài đặt → Hệ thống → Ngôn ngữ → Chuyển văn bản thành giọng nói';

  @override
  String get openTtsSettings => 'Mở cài đặt TTS';

  @override
  String get iosVoiceHint =>
      'Vào Cài đặt → Trợ năng → Nội dung được đọc → Giọng đọc';

  @override
  String get searching => 'Đang tìm...';

  @override
  String get ocrProcessing => 'Đang nhận dạng văn bản...';

  @override
  String get ocrAlreadyDone => 'Tất cả trang đã được nhận dạng';

  @override
  String get ocrComplete => 'Nhận dạng văn bản hoàn tất';

  @override
  String ocrProgress(int done, int total) {
    return 'OCR: $done/$total trang';
  }

  @override
  String get switchToPdfView => 'Xem PDF';

  @override
  String get switchToTextView => 'Xem văn bản';

  @override
  String get noTextOnPage => 'Trang này không có văn bản (PDF scan?)';

  @override
  String voiceNotInstalled(String lang) {
    return 'Giọng đọc \"$lang\" chưa được cài.';
  }

  @override
  String get androidTtsHint =>
      'Vào Cài đặt → Hệ thống → Ngôn ngữ → Chuyển văn bản thành giọng nói để tải.';

  @override
  String searchResults(int count) {
    return '$count kết quả';
  }

  @override
  String get recentlyAdded => 'Mới thêm gần đây';

  @override
  String get unreadBooks => 'Chưa đọc';

  @override
  String get almostFinished => 'Sắp đọc xong';

  @override
  String get frequentlyRead => 'Đọc thường xuyên';

  @override
  String nBooks(int n) {
    return '$n sách';
  }

  @override
  String get mon => 'T2';

  @override
  String get tue => 'T3';

  @override
  String get wed => 'T4';

  @override
  String get thu => 'T5';

  @override
  String get fri => 'T6';

  @override
  String get sat => 'T7';

  @override
  String get sun => 'CN';

  @override
  String get pdfLoadError => 'Không thể mở file PDF';

  @override
  String get pdfCorruptMessage => 'File PDF bị lỗi hoặc không được hỗ trợ.';

  @override
  String get readingModeNormal => 'Chế độ bình thường';

  @override
  String get readingModeSepia => 'Chế độ sepia';

  @override
  String get readingModeDark => 'Chế độ tối';

  @override
  String get continueBtn => 'Tiếp tục';

  @override
  String progress(int percent) {
    return '$percent%';
  }

  @override
  String get exportAnnotations => 'Xuất ghi chú';

  @override
  String get exportAnnotationsSuccess => 'Đã xuất ghi chú';

  @override
  String get noAnnotations => 'Không có ghi chú để xuất';

  @override
  String get pageThumbnails => 'Trang';

  @override
  String get loadingPdf => 'Đang tải PDF...';

  @override
  String get addToLibraryPrompt => 'Thêm vào thư viện để lưu tiến độ?';

  @override
  String get readOnly => 'Chỉ đọc';

  @override
  String get goToPage => 'Đi đến trang';

  @override
  String get go => 'Đi';

  @override
  String get brightness => 'Độ sáng';

  @override
  String get invalidPage => 'Số trang không hợp lệ';

  @override
  String get cropMargins => 'Cắt lề';

  @override
  String get epubChapter => 'Chương';

  @override
  String get epubLoading => 'Đang tải EPUB...';

  @override
  String get epubError => 'Không thể mở file EPUB';

  @override
  String get readingQueue => 'Hàng đợi đọc';

  @override
  String get addToQueue => 'Thêm vào hàng đợi';

  @override
  String get queueEmpty => 'Chưa có sách trong hàng đợi';

  @override
  String get focusTimer => 'Bộ đếm thời gian';

  @override
  String get readingReminder => 'Nhắc nhở đọc sách';

  @override
  String get reminderTime => 'Thời gian nhắc';

  @override
  String get ttsReadPage => 'Đọc trang';

  @override
  String get ttsPause => 'Tạm dừng';

  @override
  String get pageNote => 'Ghi chú trang';

  @override
  String get moreOptions => 'Tuỳ chọn khác';

  @override
  String get openFromFilesHint => 'Hoặc mở PDF từ trình quản lý tệp';
}
