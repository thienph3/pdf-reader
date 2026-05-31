/// Holds UI state for the reader screen (non-service state).
class ReaderUiState {
  int currentPage = 0;
  int totalPages = 0;
  int readingMode = 0;
  int cropMargins = 0;
  double brightness = 0.5;
  bool fullscreen = false;
  bool horizontalScroll = false;
  bool showTimer = false;
  bool pdfLoading = true;
  bool isSearching = false;
  String? pdfError;
}
