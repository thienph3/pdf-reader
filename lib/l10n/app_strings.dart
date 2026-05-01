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

  // Delete confirm
  String get deleteBook => _isVi ? 'Xoá sách' : 'Delete book';
  String deleteBookConfirm(String title) => _isVi ? 'Bạn muốn xoá "$title"?' : 'Delete "$title"?';

  // File validation
  String get fileNotFound => _isVi ? 'File không tồn tại' : 'File not found';
  String get fileInvalidMessage => _isVi ? 'Đường dẫn ebook không hợp lệ. Chọn lại file?' : 'Ebook path is invalid. Pick a new file?';
  String get repick => _isVi ? 'Chọn lại' : 'Pick again';
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
