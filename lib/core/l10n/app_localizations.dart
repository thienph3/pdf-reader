import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PDF Reader'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your book library'**
  String get splashSubtitle;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or author...'**
  String get searchHint;

  /// No description provided for @noBooks.
  ///
  /// In en, this message translates to:
  /// **'No books yet.'**
  String get noBooks;

  /// No description provided for @addBookHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a book'**
  String get addBookHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No books found.'**
  String get noResults;

  /// No description provided for @sortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortUpdated;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title A-Z'**
  String get sortTitle;

  /// No description provided for @sortCreated.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortCreated;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @exportLib.
  ///
  /// In en, this message translates to:
  /// **'Export library'**
  String get exportLib;

  /// No description provided for @importLib.
  ///
  /// In en, this message translates to:
  /// **'Import library'**
  String get importLib;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Library exported successfully'**
  String get exportSuccess;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {n} new books'**
  String importSuccess(int n);

  /// No description provided for @bookDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" deleted'**
  String bookDeleted(String title);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @readBook.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readBook;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String error(String msg);

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBook;

  /// No description provided for @editBook.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get editBook;

  /// No description provided for @bookTitle.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get bookTitle;

  /// No description provided for @bookTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get bookTitleRequired;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @bookType.
  ///
  /// In en, this message translates to:
  /// **'Book type'**
  String get bookType;

  /// No description provided for @paper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get paper;

  /// No description provided for @ebook.
  ///
  /// In en, this message translates to:
  /// **'Ebook'**
  String get ebook;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @pdfFile.
  ///
  /// In en, this message translates to:
  /// **'File PDF'**
  String get pdfFile;

  /// No description provided for @pickFile.
  ///
  /// In en, this message translates to:
  /// **'Pick PDF file'**
  String get pickFile;

  /// No description provided for @changeFile.
  ///
  /// In en, this message translates to:
  /// **'Change file'**
  String get changeFile;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard?'**
  String get discardMessage;

  /// No description provided for @continueEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get continueEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @paperBook.
  ///
  /// In en, this message translates to:
  /// **'Paper book'**
  String get paperBook;

  /// No description provided for @ebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Ebook'**
  String get ebookLabel;

  /// No description provided for @paperAndEbook.
  ///
  /// In en, this message translates to:
  /// **'Paper + Ebook'**
  String get paperAndEbook;

  /// No description provided for @openingPdf.
  ///
  /// In en, this message translates to:
  /// **'Opening PDF...'**
  String get openingPdf;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarks;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get addBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @bookmarkList.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarkList;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page {n}'**
  String page(int n);

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.\nTap + to add.'**
  String get noCategoriesYet;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?\nBooks in this category won\'t be deleted.'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @langVi.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get langVi;

  /// No description provided for @langEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @scrollDirection.
  ///
  /// In en, this message translates to:
  /// **'PDF scroll direction'**
  String get scrollDirection;

  /// No description provided for @scrollVertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get scrollVertical;

  /// No description provided for @scrollHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get scrollHorizontal;

  /// No description provided for @deleteBook.
  ///
  /// In en, this message translates to:
  /// **'Delete book'**
  String get deleteBook;

  /// No description provided for @deleteBookConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteBookConfirm(String title);

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @fileInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'Ebook path is invalid. Pick a new file?'**
  String get fileInvalidMessage;

  /// No description provided for @repick.
  ///
  /// In en, this message translates to:
  /// **'Pick again'**
  String get repick;

  /// No description provided for @recentlyOpened.
  ///
  /// In en, this message translates to:
  /// **'Recently opened'**
  String get recentlyOpened;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Note for this page...'**
  String get noteHint;

  /// No description provided for @readingGoals.
  ///
  /// In en, this message translates to:
  /// **'Reading goals'**
  String get readingGoals;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @monthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly goal'**
  String get monthlyGoal;

  /// No description provided for @minutesPerDay.
  ///
  /// In en, this message translates to:
  /// **'{n} min/day'**
  String minutesPerDay(int n);

  /// No description provided for @booksPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{n} books/month'**
  String booksPerMonth(int n);

  /// No description provided for @todayReading.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayReading;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalReadingTime.
  ///
  /// In en, this message translates to:
  /// **'Total reading time'**
  String get totalReadingTime;

  /// No description provided for @booksRead.
  ///
  /// In en, this message translates to:
  /// **'Books read'**
  String get booksRead;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg/day'**
  String get avgPerDay;

  /// No description provided for @tableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Table of contents'**
  String get tableOfContents;

  /// No description provided for @noToc.
  ///
  /// In en, this message translates to:
  /// **'This PDF has no table of contents'**
  String get noToc;

  /// No description provided for @searchInPdf.
  ///
  /// In en, this message translates to:
  /// **'Search in PDF'**
  String get searchInPdf;

  /// No description provided for @searchHintPdf.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword...'**
  String get searchHintPdf;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{q}\"'**
  String noSearchResults(String q);

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlight;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @addHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight text'**
  String get addHighlight;

  /// No description provided for @removeHighlight.
  ///
  /// In en, this message translates to:
  /// **'Remove highlight'**
  String get removeHighlight;

  /// No description provided for @highlightNote.
  ///
  /// In en, this message translates to:
  /// **'Note for highlight...'**
  String get highlightNote;

  /// No description provided for @noHighlights.
  ///
  /// In en, this message translates to:
  /// **'No highlights yet'**
  String get noHighlights;

  /// No description provided for @selectTextToHighlight.
  ///
  /// In en, this message translates to:
  /// **'Select text to highlight'**
  String get selectTextToHighlight;

  /// No description provided for @noHighlightsFound.
  ///
  /// In en, this message translates to:
  /// **'No highlights found'**
  String get noHighlightsFound;

  /// No description provided for @noHighlightsOnPage.
  ///
  /// In en, this message translates to:
  /// **'No highlights on this page'**
  String get noHighlightsOnPage;

  /// No description provided for @selectHighlightColor.
  ///
  /// In en, this message translates to:
  /// **'Select Highlight Color'**
  String get selectHighlightColor;

  /// No description provided for @changeColor.
  ///
  /// In en, this message translates to:
  /// **'Change Color'**
  String get changeColor;

  /// No description provided for @deleteHighlight.
  ///
  /// In en, this message translates to:
  /// **'Delete Highlight'**
  String get deleteHighlight;

  /// No description provided for @deleteHighlightConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this highlight?'**
  String get deleteHighlightConfirm;

  /// No description provided for @addNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNoteOptional;

  /// No description provided for @highlightsOnPage.
  ///
  /// In en, this message translates to:
  /// **'Highlights on Page {n}'**
  String highlightsOnPage(int n);

  /// No description provided for @smartCollections.
  ///
  /// In en, this message translates to:
  /// **'Smart Collections'**
  String get smartCollections;

  /// No description provided for @tts.
  ///
  /// In en, this message translates to:
  /// **'Text-to-Speech'**
  String get tts;

  /// No description provided for @ttsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'TTS not available'**
  String get ttsNotAvailable;

  /// No description provided for @ttsHowToEnable.
  ///
  /// In en, this message translates to:
  /// **'How to enable TTS'**
  String get ttsHowToEnable;

  /// No description provided for @ttsSpeed.
  ///
  /// In en, this message translates to:
  /// **'TTS Speed'**
  String get ttsSpeed;

  /// No description provided for @readingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Reading Speed'**
  String get readingSpeed;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop Reading'**
  String get stopReading;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read Aloud'**
  String get readAloud;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @voiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// No description provided for @ttsAvailable.
  ///
  /// In en, this message translates to:
  /// **'TTS Available'**
  String get ttsAvailable;

  /// No description provided for @noTtsEngine.
  ///
  /// In en, this message translates to:
  /// **'No TTS engine found'**
  String get noTtsEngine;

  /// No description provided for @languagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{n} languages'**
  String languagesAvailable(int n);

  /// No description provided for @downloadVoice.
  ///
  /// In en, this message translates to:
  /// **'Download Voice'**
  String get downloadVoice;

  /// No description provided for @downloadVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'To download this voice, open your device\'s TTS settings.\n\nSettings → System → Language → Text-to-Speech → Install voice data'**
  String get downloadVoiceHint;

  /// No description provided for @openTtsSettings.
  ///
  /// In en, this message translates to:
  /// **'Open TTS Settings'**
  String get openTtsSettings;

  /// No description provided for @iosVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings → Accessibility → Spoken Content → Voices'**
  String get iosVoiceHint;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @ocrProcessing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing text...'**
  String get ocrProcessing;

  /// No description provided for @ocrAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'All pages already recognized'**
  String get ocrAlreadyDone;

  /// No description provided for @ocrComplete.
  ///
  /// In en, this message translates to:
  /// **'Text recognition complete'**
  String get ocrComplete;

  /// No description provided for @ocrProgress.
  ///
  /// In en, this message translates to:
  /// **'OCR: {done}/{total} pages'**
  String ocrProgress(int done, int total);

  /// No description provided for @switchToPdfView.
  ///
  /// In en, this message translates to:
  /// **'PDF View'**
  String get switchToPdfView;

  /// No description provided for @switchToTextView.
  ///
  /// In en, this message translates to:
  /// **'Text View'**
  String get switchToTextView;

  /// No description provided for @noTextOnPage.
  ///
  /// In en, this message translates to:
  /// **'No text found on this page (scanned PDF?)'**
  String get noTextOnPage;

  /// No description provided for @voiceNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Voice for \"{lang}\" not installed.'**
  String voiceNotInstalled(String lang);

  /// No description provided for @androidTtsHint.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings → System → Language → Text-to-Speech to download.'**
  String get androidTtsHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResults(int count);

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get recentlyAdded;

  /// No description provided for @unreadBooks.
  ///
  /// In en, this message translates to:
  /// **'Unread Books'**
  String get unreadBooks;

  /// No description provided for @almostFinished.
  ///
  /// In en, this message translates to:
  /// **'Almost Finished'**
  String get almostFinished;

  /// No description provided for @frequentlyRead.
  ///
  /// In en, this message translates to:
  /// **'Frequently Read'**
  String get frequentlyRead;

  /// No description provided for @nBooks.
  ///
  /// In en, this message translates to:
  /// **'{n} books'**
  String nBooks(int n);

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @pdfLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open PDF file'**
  String get pdfLoadError;

  /// No description provided for @pdfCorruptMessage.
  ///
  /// In en, this message translates to:
  /// **'The PDF file is corrupted or unsupported.'**
  String get pdfCorruptMessage;

  /// No description provided for @readingModeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal mode'**
  String get readingModeNormal;

  /// No description provided for @readingModeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia mode'**
  String get readingModeSepia;

  /// No description provided for @readingModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get readingModeDark;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String progress(int percent);

  /// No description provided for @exportAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Export annotations'**
  String get exportAnnotations;

  /// No description provided for @exportAnnotationsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Annotations exported'**
  String get exportAnnotationsSuccess;

  /// No description provided for @noAnnotations.
  ///
  /// In en, this message translates to:
  /// **'No annotations to export'**
  String get noAnnotations;

  /// No description provided for @pageThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pageThumbnails;

  /// No description provided for @loadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Loading PDF...'**
  String get loadingPdf;

  /// No description provided for @addToLibraryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add to library to save progress?'**
  String get addToLibraryPrompt;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Just read'**
  String get readOnly;

  /// No description provided for @goToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get goToPage;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @invalidPage.
  ///
  /// In en, this message translates to:
  /// **'Invalid page number'**
  String get invalidPage;

  /// No description provided for @cropMargins.
  ///
  /// In en, this message translates to:
  /// **'Crop Margins'**
  String get cropMargins;

  /// No description provided for @epubChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get epubChapter;

  /// No description provided for @epubLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading EPUB...'**
  String get epubLoading;

  /// No description provided for @epubError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open EPUB file'**
  String get epubError;

  /// No description provided for @readingQueue.
  ///
  /// In en, this message translates to:
  /// **'Reading Queue'**
  String get readingQueue;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to Queue'**
  String get addToQueue;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// No description provided for @focusTimer.
  ///
  /// In en, this message translates to:
  /// **'Focus Timer'**
  String get focusTimer;

  /// No description provided for @readingReminder.
  ///
  /// In en, this message translates to:
  /// **'Reading reminder'**
  String get readingReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
