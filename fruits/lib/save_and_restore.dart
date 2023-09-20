import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Canvas Save and Restore Example'),
        ),
        body: Center(
          child: CustomPaint(
            size: Size(200, 200),
            painter: MyPainter(),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Save the initial canvas state
    canvas.save();

    // Draw a blue rectangle
    Paint paint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromPoints(Offset(50, 50), Offset(150, 150)), paint);

    // Translate the canvas to the right
    canvas.translate(50, 0);

    // Draw a red rectangle
    paint.color = Colors.red;
    canvas.drawRect(Rect.fromPoints(Offset(50, 50), Offset(150, 150)), paint);

    // Restore the initial canvas state
    canvas.restore();

    // Draw a green rectangle (this will be unaffected by previous transformations)
    paint.color = Colors.green;
    canvas.drawRect(Rect.fromPoints(Offset(50, 50), Offset(150, 150)), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
