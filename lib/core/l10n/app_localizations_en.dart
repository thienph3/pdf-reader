// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PDF Reader';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get undo => 'Undo';

  @override
  String get splashSubtitle => 'Your book library';

  @override
  String get library => 'Library';

  @override
  String get searchHint => 'Search by title or author...';

  @override
  String get noBooks => 'No books yet.';

  @override
  String get addBookHint => 'Tap + to add a book';

  @override
  String get noResults => 'No books found.';

  @override
  String get sortUpdated => 'Recently updated';

  @override
  String get sortTitle => 'Title A-Z';

  @override
  String get sortCreated => 'Recently added';

  @override
  String get listView => 'List view';

  @override
  String get gridView => 'Grid view';

  @override
  String get exportLib => 'Export library';

  @override
  String get importLib => 'Import library';

  @override
  String get exportSuccess => 'Library exported successfully';

  @override
  String importSuccess(int n) {
    return 'Imported $n new books';
  }

  @override
  String bookDeleted(String title) {
    return '\"$title\" deleted';
  }

  @override
  String get all => 'All';

  @override
  String get readBook => 'Read';

  @override
  String get sort => 'Sort';

  @override
  String error(String msg) {
    return 'Error: $msg';
  }

  @override
  String get addBook => 'Add book';

  @override
  String get editBook => 'Edit book';

  @override
  String get bookTitle => 'Title *';

  @override
  String get bookTitleRequired => 'Please enter a title';

  @override
  String get author => 'Author';

  @override
  String get bookType => 'Book type';

  @override
  String get paper => 'Paper';

  @override
  String get ebook => 'Ebook';

  @override
  String get both => 'Both';

  @override
  String get category => 'Category';

  @override
  String get noCategory => 'None';

  @override
  String get selectCategory => 'Select category';

  @override
  String get pdfFile => 'File PDF';

  @override
  String get pickFile => 'Pick PDF file';

  @override
  String get changeFile => 'Change file';

  @override
  String get notes => 'Notes';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardMessage => 'You have unsaved changes. Discard?';

  @override
  String get continueEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get paperBook => 'Paper book';

  @override
  String get ebookLabel => 'Ebook';

  @override
  String get paperAndEbook => 'Paper + Ebook';

  @override
  String get openingPdf => 'Opening PDF...';

  @override
  String get noBookmarks => 'No bookmarks yet';

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get bookmarkList => 'Bookmarks';

  @override
  String page(int n) {
    return 'Page $n';
  }

  @override
  String get categories => 'Categories';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get categoryName => 'Category name';

  @override
  String get noCategoriesYet => 'No categories yet.\nTap + to add.';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete \"$name\"?\nBooks in this category won\'t be deleted.';
  }

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get langVi => 'Tiếng Việt';

  @override
  String get langEn => 'English';

  @override
  String get scrollDirection => 'PDF scroll direction';

  @override
  String get scrollVertical => 'Vertical';

  @override
  String get scrollHorizontal => 'Horizontal';

  @override
  String get deleteBook => 'Delete book';

  @override
  String deleteBookConfirm(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get fileNotFound => 'File not found';

  @override
  String get fileInvalidMessage => 'Ebook path is invalid. Pick a new file?';

  @override
  String get repick => 'Pick again';

  @override
  String get recentlyOpened => 'Recently opened';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get addNote => 'Add note';

  @override
  String get editNote => 'Edit note';

  @override
  String get noteHint => 'Note for this page...';

  @override
  String get readingGoals => 'Reading goals';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get monthlyGoal => 'Monthly goal';

  @override
  String minutesPerDay(int n) {
    return '$n min/day';
  }

  @override
  String booksPerMonth(int n) {
    return '$n books/month';
  }

  @override
  String get todayReading => 'Today';

  @override
  String get thisMonth => 'This month';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalReadingTime => 'Total reading time';

  @override
  String get booksRead => 'Books read';

  @override
  String get avgPerDay => 'Avg/day';

  @override
  String get tableOfContents => 'Table of contents';

  @override
  String get noToc => 'This PDF has no table of contents';

  @override
  String get searchInPdf => 'Search in PDF';

  @override
  String get searchHintPdf => 'Enter keyword...';

  @override
  String noSearchResults(String q) {
    return 'No results for \"$q\"';
  }

  @override
  String get highlight => 'Highlight';

  @override
  String get highlights => 'Highlights';

  @override
  String get addHighlight => 'Highlight text';

  @override
  String get removeHighlight => 'Remove highlight';

  @override
  String get highlightNote => 'Note for highlight...';

  @override
  String get noHighlights => 'No highlights yet';

  @override
  String get selectTextToHighlight => 'Select text to highlight';

  @override
  String get noHighlightsFound => 'No highlights found';

  @override
  String get noHighlightsOnPage => 'No highlights on this page';

  @override
  String get selectHighlightColor => 'Select Highlight Color';

  @override
  String get changeColor => 'Change Color';

  @override
  String get deleteHighlight => 'Delete Highlight';

  @override
  String get deleteHighlightConfirm => 'Delete this highlight?';

  @override
  String get addNoteOptional => 'Add a note (optional)';

  @override
  String highlightsOnPage(int n) {
    return 'Highlights on Page $n';
  }

  @override
  String get smartCollections => 'Smart Collections';

  @override
  String get tts => 'Text-to-Speech';

  @override
  String get ttsNotAvailable => 'TTS not available';

  @override
  String get ttsHowToEnable => 'How to enable TTS';

  @override
  String get ttsSpeed => 'TTS Speed';

  @override
  String get readingSpeed => 'Reading Speed';

  @override
  String get stopReading => 'Stop Reading';

  @override
  String get readAloud => 'Read Aloud';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get voiceSettings => 'Voice Settings';

  @override
  String get ttsAvailable => 'TTS Available';

  @override
  String get noTtsEngine => 'No TTS engine found';

  @override
  String languagesAvailable(int n) {
    return '$n languages';
  }

  @override
  String get downloadVoice => 'Download Voice';

  @override
  String get downloadVoiceHint =>
      'To download this voice, open your device\'s TTS settings.\n\nSettings → System → Language → Text-to-Speech → Install voice data';

  @override
  String get openTtsSettings => 'Open TTS Settings';

  @override
  String get iosVoiceHint =>
      'Go to Settings → Accessibility → Spoken Content → Voices';

  @override
  String get searching => 'Searching...';

  @override
  String get ocrProcessing => 'Recognizing text...';

  @override
  String get ocrAlreadyDone => 'All pages already recognized';

  @override
  String get ocrComplete => 'Text recognition complete';

  @override
  String ocrProgress(int done, int total) {
    return 'OCR: $done/$total pages';
  }

  @override
  String get switchToPdfView => 'PDF View';

  @override
  String get switchToTextView => 'Text View';

  @override
  String get noTextOnPage => 'No text found on this page (scanned PDF?)';

  @override
  String voiceNotInstalled(String lang) {
    return 'Voice for \"$lang\" not installed.';
  }

  @override
  String get androidTtsHint =>
      'Go to Settings → System → Language → Text-to-Speech to download.';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get unreadBooks => 'Unread Books';

  @override
  String get almostFinished => 'Almost Finished';

  @override
  String get frequentlyRead => 'Frequently Read';

  @override
  String nBooks(int n) {
    return '$n books';
  }

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get pdfLoadError => 'Failed to open PDF file';

  @override
  String get pdfCorruptMessage => 'The PDF file is corrupted or unsupported.';

  @override
  String get readingModeNormal => 'Normal mode';

  @override
  String get readingModeSepia => 'Sepia mode';

  @override
  String get readingModeDark => 'Dark mode';

  @override
  String get continueBtn => 'Continue';

  @override
  String progress(int percent) {
    return '$percent%';
  }

  @override
  String get exportAnnotations => 'Export annotations';

  @override
  String get exportAnnotationsSuccess => 'Annotations exported';

  @override
  String get noAnnotations => 'No annotations to export';

  @override
  String get pageThumbnails => 'Pages';

  @override
  String get loadingPdf => 'Loading PDF...';

  @override
  String get addToLibraryPrompt => 'Add to library to save progress?';

  @override
  String get readOnly => 'Just read';

  @override
  String get goToPage => 'Go to page';

  @override
  String get go => 'Go';

  @override
  String get brightness => 'Brightness';

  @override
  String get invalidPage => 'Invalid page number';

  @override
  String get cropMargins => 'Crop Margins';

  @override
  String get epubChapter => 'Chapter';

  @override
  String get epubLoading => 'Loading EPUB...';

  @override
  String get epubError => 'Failed to open EPUB file';

  @override
  String get readingQueue => 'Reading Queue';

  @override
  String get addToQueue => 'Add to Queue';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get focusTimer => 'Focus Timer';

  @override
  String get readingReminder => 'Reading reminder';

  @override
  String get reminderTime => 'Reminder time';
}
