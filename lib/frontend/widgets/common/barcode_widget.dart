import 'package:flutter/material.dart';

class BarcodeWidget extends StatelessWidget {
  final String data;
  final double height;
  final double width;
  final Color color;
  final bool showText;
  final double fontSize;

  const BarcodeWidget({
    super.key,
    required this.data,
    this.height = 36.0,
    this.width = double.infinity,
    this.color = Colors.black,
    this.showText = true,
    this.fontSize = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final codeString = data.isEmpty ? 'SKU-000000' : data;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height,
          width: width,
          child: CustomPaint(
            painter: _BarcodePainter(code: codeString, color: color),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 3),
          Text(
            codeString,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: color.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final String code;
  final Color color;

  _BarcodePainter({required this.code, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Deterministic bar widths generated from character codes
    final List<int> barWidths = [];
    for (int i = 0; i < code.length; i++) {
      int charCode = code.codeUnitAt(i);
      barWidths.add((charCode % 3) + 1); // bar width 1, 2, or 3
      barWidths.add(((charCode >> 2) % 2) + 1); // gap 1 or 2
    }

    // Always add start and end guard pattern
    final fullPattern = [2, 1, 1, 2, ...barWidths, 2, 1, 2, 1];

    double totalUnits = 0;
    for (int w in fullPattern) {
      totalUnits += w;
    }

    double unitWidth = size.width / totalUnits;
    if (unitWidth <= 0) unitWidth = 1.0;

    double currentX = 0;
    bool isBar = true;

    for (int w in fullPattern) {
      double barW = w * unitWidth;
      if (isBar) {
        canvas.drawRect(
          Rect.fromLTWH(currentX, 0, barW, size.height),
          paint,
        );
      }
      currentX += barW;
      isBar = !isBar;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.color != color;
  }
}
