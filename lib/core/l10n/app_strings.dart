import 'package:flutter/material.dart';
import 'app_localizations.dart';

export 'app_localizations.dart' show AppLocalizations;

/// Compatibility shim — delegates to generated AppLocalizations.
class AppStrings {
  final AppLocalizations _l;
  AppStrings._(this._l);

  /// Create from locale (for tests and delegate).
  factory AppStrings.fromLocale(Locale locale) =>
      AppStrings._(lookupAppLocalizations(locale));

  static AppStrings of(BuildContext context) =>
      AppStrings._(AppLocalizations.of(context));

  // General
  String get appName => _l.appName;
  String get cancel => _l.cancel;
  String get save => _l.save;
  String get delete => _l.delete;
  String get edit => _l.edit;
  String get undo => _l.undo;

  // Splash
  String get splashSubtitle => _l.splashSubtitle;

  // Book list
  String get library => _l.library;
  String get searchHint => _l.searchHint;
  String get noBooks => _l.noBooks;
  String get addBookHint => _l.addBookHint;
  String get noResults => _l.noResults;
  String get sortUpdated => _l.sortUpdated;
  String get sortTitle => _l.sortTitle;
  String get sortCreated => _l.sortCreated;
  String get listView => _l.listView;
  String get gridView => _l.gridView;
  String get exportLib => _l.exportLib;
  String get importLib => _l.importLib;
  String get exportSuccess => _l.exportSuccess;
  String importSuccess(int n) => _l.importSuccess(n);
  String bookDeleted(String title) => _l.bookDeleted(title);
  String get all => _l.all;
  String get readBook => _l.readBook;
  String get sort => _l.sort;
  String error(String msg) => _l.error(msg);

  // Book form
  String get addBook => _l.addBook;
  String get editBook => _l.editBook;
  String get bookTitle => _l.bookTitle;
  String get bookTitleRequired => _l.bookTitleRequired;
  String get author => _l.author;
  String get bookType => _l.bookType;
  String get paper => _l.paper;
  String get ebook => _l.ebook;
  String get both => _l.both;
  String get category => _l.category;
  String get noCategory => _l.noCategory;
  String get selectCategory => _l.selectCategory;
  String get pdfFile => _l.pdfFile;
  String get pickFile => _l.pickFile;
  String get changeFile => _l.changeFile;
  String get notes => _l.notes;
  String get saveChanges => _l.saveChanges;
  String get discardTitle => _l.discardTitle;
  String get discardMessage => _l.discardMessage;
  String get continueEditing => _l.continueEditing;
  String get discard => _l.discard;

  // Format labels
  String get paperBook => _l.paperBook;
  String get ebookLabel => _l.ebookLabel;
  String get paperAndEbook => _l.paperAndEbook;

  // PDF viewer
  String get openingPdf => _l.openingPdf;
  String get noBookmarks => _l.noBookmarks;
  String get addBookmark => _l.addBookmark;
  String get removeBookmark => _l.removeBookmark;
  String get bookmarkList => _l.bookmarkList;
  String page(int n) => _l.page(n);

  // Categories
  String get categories => _l.categories;
  String get manageCategories => _l.manageCategories;
  String get addCategory => _l.addCategory;
  String get editCategory => _l.editCategory;
  String get deleteCategory => _l.deleteCategory;
  String get categoryName => _l.categoryName;
  String get noCategoriesYet => _l.noCategoriesYet;
  String deleteCategoryConfirm(String name) => _l.deleteCategoryConfirm(name);

  // Settings
  String get settings => _l.settings;
  String get theme => _l.theme;
  String get themeSystem => _l.themeSystem;
  String get themeLight => _l.themeLight;
  String get themeDark => _l.themeDark;
  String get language => _l.language;
  String get langVi => _l.langVi;
  String get langEn => _l.langEn;
  String get scrollDirection => _l.scrollDirection;
  String get scrollVertical => _l.scrollVertical;
  String get scrollHorizontal => _l.scrollHorizontal;

  // Delete confirm
  String get deleteBook => _l.deleteBook;
  String deleteBookConfirm(String title) => _l.deleteBookConfirm(title);

  // File validation
  String get fileNotFound => _l.fileNotFound;
  String get fileInvalidMessage => _l.fileInvalidMessage;
  String get repick => _l.repick;

  // Recently opened
  String get recentlyOpened => _l.recentlyOpened;
  String get continueReading => _l.continueReading;

  // Page notes
  String get addNote => _l.addNote;
  String get editNote => _l.editNote;
  String get noteHint => _l.noteHint;

  // Reading goals
  String get readingGoals => _l.readingGoals;
  String get dailyGoal => _l.dailyGoal;
  String get monthlyGoal => _l.monthlyGoal;
  String minutesPerDay(int n) => _l.minutesPerDay(n);
  String booksPerMonth(int n) => _l.booksPerMonth(n);
  String get todayReading => _l.todayReading;
  String get thisMonth => _l.thisMonth;

  // Stats
  String get statistics => _l.statistics;
  String get totalReadingTime => _l.totalReadingTime;
  String get booksRead => _l.booksRead;
  String get avgPerDay => _l.avgPerDay;

  // TOC
  String get tableOfContents => _l.tableOfContents;
  String get noToc => _l.noToc;

  // Text search
  String get searchInPdf => _l.searchInPdf;
  String get searchHintPdf => _l.searchHintPdf;
  String noSearchResults(String q) => _l.noSearchResults(q);

  // Highlights
  String get highlight => _l.highlight;
  String get highlights => _l.highlights;
  String get addHighlight => _l.addHighlight;
  String get removeHighlight => _l.removeHighlight;
  String get highlightNote => _l.highlightNote;
  String get noHighlights => _l.noHighlights;
  String get selectTextToHighlight => _l.selectTextToHighlight;
  String get noHighlightsFound => _l.noHighlightsFound;
  String get noHighlightsOnPage => _l.noHighlightsOnPage;
  String get selectHighlightColor => _l.selectHighlightColor;
  String get changeColor => _l.changeColor;
  String get deleteHighlight => _l.deleteHighlight;
  String get deleteHighlightConfirm => _l.deleteHighlightConfirm;
  String get addNoteOptional => _l.addNoteOptional;
  String highlightsOnPage(int n) => _l.highlightsOnPage(n);

  // Smart collections
  String get smartCollections => _l.smartCollections;

  // TTS
  String get tts => _l.tts;
  String get ttsNotAvailable => _l.ttsNotAvailable;
  String get ttsHowToEnable => _l.ttsHowToEnable;
  String get ttsSpeed => _l.ttsSpeed;
  String get readingSpeed => _l.readingSpeed;
  String get stopReading => _l.stopReading;
  String get readAloud => _l.readAloud;
  String get ttsReadPage => _l.ttsReadPage;
  String get ttsPause => _l.ttsPause;
  String get pageNote => _l.pageNote;
  String get moreOptions => _l.moreOptions;
  String get openFromFilesHint => _l.openFromFilesHint;
  String get selectLanguage => _l.selectLanguage;
  String get voiceSettings => _l.voiceSettings;
  String get ttsAvailable => _l.ttsAvailable;
  String get noTtsEngine => _l.noTtsEngine;
  String languagesAvailable(int n) => _l.languagesAvailable(n);
  String get downloadVoice => _l.downloadVoice;
  String get downloadVoiceHint => _l.downloadVoiceHint;
  String get openTtsSettings => _l.openTtsSettings;
  String get iosVoiceHint => _l.iosVoiceHint;
  String get searching => _l.searching;
  String get ocrProcessing => _l.ocrProcessing;
  String get ocrAlreadyDone => _l.ocrAlreadyDone;
  String get ocrComplete => _l.ocrComplete;
  String ocrProgress(int done, int total) => _l.ocrProgress(done, total);
  String get switchToPdfView => _l.switchToPdfView;
  String get switchToTextView => _l.switchToTextView;
  String get noTextOnPage => _l.noTextOnPage;
  String voiceNotInstalled(String lang) => _l.voiceNotInstalled(lang);
  String get androidTtsHint => _l.androidTtsHint;

  // Search results
  String searchResults(int count) => _l.searchResults(count);

  // Smart collection titles
  String get recentlyAdded => _l.recentlyAdded;
  String get unreadBooks => _l.unreadBooks;
  String get almostFinished => _l.almostFinished;
  String get frequentlyRead => _l.frequentlyRead;
  String nBooks(int n) => _l.nBooks(n);

  // Week days (List<String> not supported in ARB, computed here)
  String get mon => _l.mon;
  String get tue => _l.tue;
  String get wed => _l.wed;
  String get thu => _l.thu;
  String get fri => _l.fri;
  String get sat => _l.sat;
  String get sun => _l.sun;
  List<String> get weekDays => [mon, tue, wed, thu, fri, sat, sun];

  // PDF error
  String get pdfLoadError => _l.pdfLoadError;
  String get pdfCorruptMessage => _l.pdfCorruptMessage;

  // Reading modes
  String get readingModeNormal => _l.readingModeNormal;
  String get readingModeSepia => _l.readingModeSepia;
  String get readingModeDark => _l.readingModeDark;

  // Continue reading card
  String get continueBtn => _l.continueBtn;
  String progress(int percent) => _l.progress(percent);

  // Annotation export
  String get exportAnnotations => _l.exportAnnotations;
  String get exportAnnotationsSuccess => _l.exportAnnotationsSuccess;
  String get noAnnotations => _l.noAnnotations;

  // Page thumbnails
  String get pageThumbnails => _l.pageThumbnails;

  // Loading
  String get loadingPdf => _l.loadingPdf;

  // Open file intent
  String get addToLibraryPrompt => _l.addToLibraryPrompt;
  String get readOnly => _l.readOnly;

  // Power-user features
  String get goToPage => _l.goToPage;
  String get go => _l.go;
  String get brightness => _l.brightness;
  String get invalidPage => _l.invalidPage;
  String get cropMargins => _l.cropMargins;

  // EPUB
  String get epubChapter => _l.epubChapter;
  String get epubLoading => _l.epubLoading;
  String get epubError => _l.epubError;

  // Reading queue
  String get readingQueue => _l.readingQueue;
  String get addToQueue => _l.addToQueue;
  String get queueEmpty => _l.queueEmpty;

  // Focus timer
  String get focusTimer => _l.focusTimer;

  // Reading reminder
  String get readingReminder => _l.readingReminder;
  String get reminderTime => _l.reminderTime;
  String get notificationPermissionDenied => _l.localeName == 'vi' ? 'Quyền thông báo bị từ chối' : 'Notification permission denied';
  String get openSettings => _l.localeName == 'vi' ? 'Mở cài đặt' : 'Open Settings';
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async =>
      AppStrings._(lookupAppLocalizations(locale));

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
