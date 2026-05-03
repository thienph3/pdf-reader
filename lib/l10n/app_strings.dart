import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        const AppStrings(Locale('vi'));
  }

  bool get _isVi => locale.languageCode == 'vi';

  // General
  String get appName => 'PDF Reader';
  String get cancel => _isVi ? 'Huỷ' : 'Cancel';
  String get save => _isVi ? 'Lưu' : 'Save';
  String get delete => _isVi ? 'Xoá' : 'Delete';
  String get edit => _isVi ? 'Sửa' : 'Edit';
  String get undo => _isVi ? 'Hoàn tác' : 'Undo';

  // Splash
  String get splashSubtitle => _isVi ? 'Thư viện sách của bạn' : 'Your book library';

  // Book list
  String get library => _isVi ? 'Thư viện sách' : 'Library';
  String get searchHint => _isVi ? 'Tìm theo tên hoặc tác giả...' : 'Search by title or author...';
  String get noBooks => _isVi ? 'Chưa có sách nào.' : 'No books yet.';
  String get addBookHint => _isVi ? 'Bấm + để thêm sách mới' : 'Tap + to add a book';
  String get noResults => _isVi ? 'Không tìm thấy sách.' : 'No books found.';
  String get sortUpdated => _isVi ? 'Mới cập nhật' : 'Recently updated';
  String get sortTitle => _isVi ? 'Tên A-Z' : 'Title A-Z';
  String get sortCreated => _isVi ? 'Mới thêm' : 'Recently added';
  String get listView => _isVi ? 'Xem danh sách' : 'List view';
  String get gridView => _isVi ? 'Xem lưới' : 'Grid view';
  String get exportLib => _isVi ? 'Xuất thư viện' : 'Export library';
  String get importLib => _isVi ? 'Nhập thư viện' : 'Import library';
  String get exportSuccess => _isVi ? 'Đã xuất thư viện thành công' : 'Library exported successfully';
  String importSuccess(int n) => _isVi ? 'Đã nhập $n sách mới' : 'Imported $n new books';
  String bookDeleted(String title) => _isVi ? '"$title" đã xoá' : '"$title" deleted';
  String get all => _isVi ? 'Tất cả' : 'All';
  String get readBook => _isVi ? 'Đọc sách' : 'Read';
  String get sort => _isVi ? 'Sắp xếp' : 'Sort';
  String error(String msg) => _isVi ? 'Lỗi: $msg' : 'Error: $msg';

  // Book form
  String get addBook => _isVi ? 'Thêm sách' : 'Add book';
  String get editBook => _isVi ? 'Sửa sách' : 'Edit book';
  String get bookTitle => _isVi ? 'Tên sách *' : 'Title *';
  String get bookTitleRequired => _isVi ? 'Vui lòng nhập tên sách' : 'Please enter a title';
  String get author => _isVi ? 'Tác giả' : 'Author';
  String get bookType => _isVi ? 'Loại sách' : 'Book type';
  String get paper => _isVi ? 'Giấy' : 'Paper';
  String get ebook => 'Ebook';
  String get both => _isVi ? 'Cả hai' : 'Both';
  String get category => _isVi ? 'Danh mục' : 'Category';
  String get noCategory => _isVi ? 'Không có' : 'None';
  String get selectCategory => _isVi ? 'Chọn danh mục' : 'Select category';
  String get pdfFile => 'File PDF';
  String get pickFile => _isVi ? 'Chọn file PDF' : 'Pick PDF file';
  String get changeFile => _isVi ? 'Đổi file' : 'Change file';
  String get notes => _isVi ? 'Ghi chú' : 'Notes';
  String get saveChanges => _isVi ? 'Lưu thay đổi' : 'Save changes';
  String get discardTitle => _isVi ? 'Huỷ thay đổi?' : 'Discard changes?';
  String get discardMessage => _isVi ? 'Bạn có thay đổi chưa lưu. Muốn huỷ bỏ?' : 'You have unsaved changes. Discard?';
  String get continueEditing => _isVi ? 'Tiếp tục sửa' : 'Keep editing';
  String get discard => _isVi ? 'Huỷ bỏ' : 'Discard';

  // Format labels
  String get paperBook => _isVi ? 'Sách giấy' : 'Paper book';
  String get ebookLabel => 'Ebook';
  String get paperAndEbook => _isVi ? 'Giấy + Ebook' : 'Paper + Ebook';

  // PDF viewer
  String get openingPdf => _isVi ? 'Đang mở file PDF...' : 'Opening PDF...';
  String get noBookmarks => _isVi ? 'Chưa có bookmark nào' : 'No bookmarks yet';
  String get addBookmark => _isVi ? 'Thêm bookmark' : 'Add bookmark';
  String get removeBookmark => _isVi ? 'Bỏ bookmark' : 'Remove bookmark';
  String get bookmarkList => _isVi ? 'Danh sách bookmark' : 'Bookmarks';
  String page(int n) => _isVi ? 'Trang $n' : 'Page $n';

  // Categories
  String get categories => _isVi ? 'Danh mục' : 'Categories';
  String get manageCategories => _isVi ? 'Quản lý danh mục' : 'Manage categories';
  String get addCategory => _isVi ? 'Thêm danh mục' : 'Add category';
  String get editCategory => _isVi ? 'Sửa danh mục' : 'Edit category';
  String get deleteCategory => _isVi ? 'Xoá danh mục' : 'Delete category';
  String get categoryName => _isVi ? 'Tên danh mục' : 'Category name';
  String get noCategoriesYet => _isVi ? 'Chưa có danh mục nào.\nBấm + để thêm.' : 'No categories yet.\nTap + to add.';
  String deleteCategoryConfirm(String name) =>
      _isVi ? 'Bạn muốn xoá "$name"?\nSách thuộc danh mục này sẽ không bị xoá.' : 'Delete "$name"?\nBooks in this category won\'t be deleted.';

  // Settings
  String get settings => _isVi ? 'Cài đặt' : 'Settings';
  String get theme => _isVi ? 'Giao diện' : 'Theme';
  String get themeSystem => _isVi ? 'Theo hệ thống' : 'System';
  String get themeLight => _isVi ? 'Sáng' : 'Light';
  String get themeDark => _isVi ? 'Tối' : 'Dark';
  String get language => _isVi ? 'Ngôn ngữ' : 'Language';
  String get langVi => 'Tiếng Việt';
  String get langEn => 'English';
  String get scrollDirection => _isVi ? 'Hướng cuộn PDF' : 'PDF scroll direction';
  String get scrollVertical => _isVi ? 'Cuộn dọc' : 'Vertical';
  String get scrollHorizontal => _isVi ? 'Cuộn ngang' : 'Horizontal';

  // Delete confirm
  String get deleteBook => _isVi ? 'Xoá sách' : 'Delete book';
  String deleteBookConfirm(String title) => _isVi ? 'Bạn muốn xoá "$title"?' : 'Delete "$title"?';

  // File validation
  String get fileNotFound => _isVi ? 'File không tồn tại' : 'File not found';
  String get fileInvalidMessage => _isVi ? 'Đường dẫn ebook không hợp lệ. Chọn lại file?' : 'Ebook path is invalid. Pick a new file?';
  String get repick => _isVi ? 'Chọn lại' : 'Pick again';

  // Recently opened
  String get recentlyOpened => _isVi ? 'Đọc gần đây' : 'Recently opened';
  String get continueReading => _isVi ? 'Tiếp tục đọc' : 'Continue reading';

  // Page notes
  String get addNote => _isVi ? 'Thêm ghi chú' : 'Add note';
  String get editNote => _isVi ? 'Sửa ghi chú' : 'Edit note';
  String get noteHint => _isVi ? 'Ghi chú cho trang này...' : 'Note for this page...';

  // Reading goals
  String get readingGoals => _isVi ? 'Mục tiêu đọc' : 'Reading goals';
  String get dailyGoal => _isVi ? 'Mục tiêu hàng ngày' : 'Daily goal';
  String get monthlyGoal => _isVi ? 'Mục tiêu hàng tháng' : 'Monthly goal';
  String minutesPerDay(int n) => _isVi ? '$n phút/ngày' : '$n min/day';
  String booksPerMonth(int n) => _isVi ? '$n sách/tháng' : '$n books/month';
  String get todayReading => _isVi ? 'Hôm nay' : 'Today';
  String get thisMonth => _isVi ? 'Tháng này' : 'This month';

  // Stats
  String get statistics => _isVi ? 'Thống kê' : 'Statistics';
  String get totalReadingTime => _isVi ? 'Tổng thời gian đọc' : 'Total reading time';
  String get booksRead => _isVi ? 'Sách đã đọc' : 'Books read';
  String get avgPerDay => _isVi ? 'Trung bình/ngày' : 'Avg/day';

  // TOC
  String get tableOfContents => _isVi ? 'Mục lục' : 'Table of contents';
  String get noToc => _isVi ? 'File PDF không có mục lục' : 'This PDF has no table of contents';

  // Text search
  String get searchInPdf => _isVi ? 'Tìm trong PDF' : 'Search in PDF';
  String get searchHintPdf => _isVi ? 'Nhập từ khoá...' : 'Enter keyword...';
  String noSearchResults(String q) => _isVi ? 'Không tìm thấy "$q"' : 'No results for "$q"';

  // Highlights
  String get highlight => _isVi ? 'Đánh dấu' : 'Highlight';
  String get highlights => _isVi ? 'Đánh dấu' : 'Highlights';
  String get addHighlight => _isVi ? 'Đánh dấu văn bản' : 'Highlight text';
  String get removeHighlight => _isVi ? 'Bỏ đánh dấu' : 'Remove highlight';
  String get highlightNote => _isVi ? 'Ghi chú cho đánh dấu...' : 'Note for highlight...';
  String get noHighlights => _isVi ? 'Chưa có đánh dấu nào' : 'No highlights yet';
  String get selectTextToHighlight => _isVi ? 'Chọn văn bản để đánh dấu' : 'Select text to highlight';
  String get noHighlightsFound => _isVi ? 'Không có đánh dấu nào' : 'No highlights found';
  String get noHighlightsOnPage => _isVi ? 'Trang này chưa có đánh dấu' : 'No highlights on this page';
  String get selectHighlightColor => _isVi ? 'Chọn màu đánh dấu' : 'Select Highlight Color';
  String get changeColor => _isVi ? 'Đổi màu' : 'Change Color';
  String get deleteHighlight => _isVi ? 'Xoá đánh dấu' : 'Delete Highlight';
  String get deleteHighlightConfirm => _isVi ? 'Xoá đánh dấu này?' : 'Delete this highlight?';
  String get addNoteOptional => _isVi ? 'Thêm ghi chú (tuỳ chọn)' : 'Add a note (optional)';
  String highlightsOnPage(int n) => _isVi ? 'Đánh dấu trang $n' : 'Highlights on Page $n';

  // Smart collections
  String get smartCollections => _isVi ? 'Bộ sưu tập' : 'Smart Collections';

  // TTS
  String get tts => _isVi ? 'Đọc to' : 'Text-to-Speech';
  String get ttsNotAvailable => _isVi ? 'TTS không khả dụng' : 'TTS not available';
  String get ttsHowToEnable => _isVi ? 'Cách bật TTS' : 'How to enable TTS';
  String get ttsSpeed => _isVi ? 'Tốc độ đọc' : 'TTS Speed';
  String get readingSpeed => _isVi ? 'Tốc độ đọc' : 'Reading Speed';
  String get stopReading => _isVi ? 'Dừng đọc' : 'Stop Reading';
  String get readAloud => _isVi ? 'Đọc to' : 'Read Aloud';
  String get selectLanguage => _isVi ? 'Chọn ngôn ngữ' : 'Select Language';
  String get voiceSettings => _isVi ? 'Cài đặt giọng đọc' : 'Voice Settings';
  String get ttsAvailable => _isVi ? 'TTS khả dụng' : 'TTS Available';
  String get noTtsEngine => _isVi ? 'Không tìm thấy TTS engine' : 'No TTS engine found';
  String languagesAvailable(int n) => _isVi ? '$n ngôn ngữ' : '$n languages';
  String get downloadVoice => _isVi ? 'Tải giọng đọc' : 'Download Voice';
  String get downloadVoiceHint => _isVi
      ? 'Để tải giọng đọc, mở cài đặt TTS trên thiết bị.\n\nCài đặt → Hệ thống → Ngôn ngữ → Chuyển văn bản thành giọng nói'
      : 'To download this voice, open your device\'s TTS settings.\n\nSettings → System → Language → Text-to-Speech → Install voice data';
  String get openTtsSettings => _isVi ? 'Mở cài đặt TTS' : 'Open TTS Settings';
  String get iosVoiceHint => _isVi
      ? 'Vào Cài đặt → Trợ năng → Nội dung được đọc → Giọng đọc'
      : 'Go to Settings → Accessibility → Spoken Content → Voices';
  String get searching => _isVi ? 'Đang tìm...' : 'Searching...';
  String get noTextOnPage => _isVi ? 'Trang này không có văn bản (PDF scan?)' : 'No text found on this page (scanned PDF?)';
  String voiceNotInstalled(String lang) => _isVi ? 'Giọng đọc "$lang" chưa được cài.' : 'Voice for "$lang" not installed.';
  String get androidTtsHint => _isVi
      ? 'Vào Cài đặt → Hệ thống → Ngôn ngữ → Chuyển văn bản thành giọng nói để tải.'
      : 'Go to Settings → System → Language → Text-to-Speech to download.';
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
