import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Manages UI controls for PDF viewer (zoom, night mode, etc.).
class PdfUiControls {
  final PdfViewerController viewerController;
  final ValueChanged<double>? onZoomChanged;
  final ValueChanged<bool>? onZoomControlsVisibilityChanged;

  double zoomLevel = 1.0;
  bool showZoomControls = false;

  PdfUiControls({
    required this.viewerController,
    this.onZoomChanged,
    this.onZoomControlsVisibilityChanged,
  });

  /// Zooms in by 20%.
  void zoomIn() {
    final newZoomLevel = (zoomLevel * 1.2).clamp(0.5, 5.0);
    _setZoom(newZoomLevel);
  }

  /// Zooms out by 20%.
  void zoomOut() {
    final newZoomLevel = (zoomLevel / 1.2).clamp(0.5, 5.0);
    _setZoom(newZoomLevel);
  }

  /// Resets zoom to 100%.
  void resetZoom() {
    _setZoom(1.0);
  }

  /// Sets zoom to a specific level.
  void _setZoom(double level) {
    zoomLevel = level;
    viewerController.setZoom(Offset.zero, zoomLevel);
    onZoomChanged?.call(zoomLevel);
  }

  /// Toggles zoom controls visibility.
  void toggleZoomControls() {
    showZoomControls = !showZoomControls;
    onZoomControlsVisibilityChanged?.call(showZoomControls);
  }

  /// Builds zoom controls widget.
  Widget buildZoomControls(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current zoom level display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                '${(zoomLevel * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom out button
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: zoomOut,
                  tooltip: 'Zoom Out',
                ),
                // Reset zoom button
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: resetZoom,
                  tooltip: 'Reset Zoom',
                ),
                // Zoom in button
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: zoomIn,
                  tooltip: 'Zoom In',
                ),
                // Close zoom controls
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: toggleZoomControls,
                  tooltip: 'Close Zoom Controls',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Handles scale update gesture for pinch-to-zoom.
  void handleScaleUpdate(double scale) {
    if (scale != 1.0) {
      final newScale = zoomLevel * scale;
      final clampedScale = newScale.clamp(0.5, 5.0);
      if (clampedScale != zoomLevel) {
        _setZoom(clampedScale);
      }
    }
  }
}