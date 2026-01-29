import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final double height;
  final Color barColor;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.height = 200,
    this.barColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          final val = data[index];
          final pct = maxValue > 0 ? val / maxValue : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(val.toStringAsFixed(0), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                width: 12,
                height: (height - 30) * pct, // Leave space for labels
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(labels[index], style: const TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          );
        }),
      ),
    );
  }
}

class SimpleTrendChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final double height;

  const SimpleTrendChart({
    super.key, 
    required this.data, 
    this.lineColor = Colors.green,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(data, lineColor),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _TrendPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxVal = values.reduce((curr, next) => curr > next ? curr : next);
    final minVal = values.reduce((curr, next) => curr < next ? curr : next);
    final range = maxVal - minVal;

    final path = Path();
    final spacing = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
        final val = values[i];
        final constrainedVal = (val - minVal);
        final pct = range == 0 ? 0.5 : constrainedVal / range;
        
        // Invert Y because canvas 0 is top
        final y = size.height - (pct * size.height);
        final x = i * spacing;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        
        // Dot
        canvas.drawCircle(Offset(x, y), 2, Paint()..color = color..style = PaintingStyle.fill);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
