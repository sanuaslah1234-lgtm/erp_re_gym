import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  /// Shows the scanner and returns the scanned barcode string, or null if cancelled.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const BarcodeScannerDialog(),
    );
  }

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _isProcessing = true);

    // Return the scanned barcode
    if (mounted) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 400,
          height: 500,
          child: Stack(
            children: [
              // Camera preview
              if (_controller != null)
                MobileScanner(
                  controller: _controller!,
                  onDetect: _onDetect,
                ),

              // Scanning overlay
              CustomPaint(
                size: const Size(400, 500),
                painter: _ScannerOverlayPainter(),
              ),

              // Top bar with title and close
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Scan Barcode',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            // Toggle torch
                            IconButton(
                              onPressed: () => _controller?.toggleTorch(),
                              icon: ValueListenableBuilder(
                                valueListenable: _controller!,
                                builder: (context, state, _) {
                                  final torchOn = state.torchState == TorchState.on;
                                  return Icon(
                                    torchOn ? Icons.flash_on : Icons.flash_off,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                            // Close
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(null),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom instruction
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Text(
                    'Point camera at barcode',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Loading overlay
              if (_isProcessing)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // Error display
              if (_lastError != null)
                Positioned(
                  bottom: 60,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _lastError!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws the scanning overlay with a transparent window
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    final scanAreaWidth = size.width * 0.7;
    final scanAreaHeight = scanAreaWidth * 0.5;
    final left = (size.width - scanAreaWidth) / 2;
    final top = (size.height - scanAreaHeight) / 2 - 30;

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight),
      const Radius.circular(12),
    );

    // Draw dark overlay
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutPath = Path()
      ..addRRect(scanRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutPath,
    );

    canvas.drawPath(overlayPath, paint);

    // Draw scan area border
    final borderPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(scanRect, borderPaint);

    // Draw corner accents
    final cornerPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 20.0;
    final corners = [
      // Top-left
      [Offset(left, top + cornerLength), Offset(left, top), Offset(left + cornerLength, top)],
      // Top-right
      [Offset(left + scanAreaWidth - cornerLength, top), Offset(left + scanAreaWidth, top), Offset(left + scanAreaWidth, top + cornerLength)],
      // Bottom-left
      [Offset(left, top + scanAreaHeight - cornerLength), Offset(left, top + scanAreaHeight), Offset(left + cornerLength, top + scanAreaHeight)],
      // Bottom-right
      [Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight), Offset(left + scanAreaWidth, top + scanAreaHeight), Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength)],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
