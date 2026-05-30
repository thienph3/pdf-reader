import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';

class PdfOcrOverlay extends StatelessWidget {
  final bool ocrInProgress;
  final bool ocrBatchRunning;
  final int ocrBatchDone;
  final int ocrBatchTotal;
  final VoidCallback onCancelBatch;

  const PdfOcrOverlay({
    super.key,
    required this.ocrInProgress,
    required this.ocrBatchRunning,
    required this.ocrBatchDone,
    required this.ocrBatchTotal,
    required this.onCancelBatch,
  });

  @override
  Widget build(BuildContext context) {
    if (!ocrInProgress && !ocrBatchRunning) return const SizedBox.shrink();
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 8),
                Text(ocrBatchRunning
                    ? AppStrings.of(context).ocrProgress(ocrBatchDone, ocrBatchTotal)
                    : AppStrings.of(context).ocrProcessing),
                if (ocrBatchRunning) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onCancelBatch,
                    child: Icon(Icons.close,
                        size: 18, color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
