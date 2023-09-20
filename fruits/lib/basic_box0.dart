import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const BasicBox0Demo());
}

/// Intended to demo subclassing RenderBox
class BasicBox0Demo extends StatelessWidget {
  const BasicBox0Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ColoredBox(
        color: Colors.red.withOpacity(0.5),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 100, minHeight: 100, maxHeight: 200, maxWidth: 200),
          child: BasicBox0(
            color: Colors.cyan,
          ),
        ),
      ),
    );
  }
}

class BasicBox0 extends LeafRenderObjectWidget {
  const BasicBox0({super.key, required this.color});

  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderIBasicBox0(color: color);
  }
}

class _RenderIBasicBox0 extends RenderBox {
  _RenderIBasicBox0({required Color color}) : _color = color;

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final paint = Paint()..color = color;
    // final Rect rect = const Rect.fromLTRB(0, 0, 100, 100);
    canvas.drawRect(offset & size, paint);
    super.paint(context, offset);
  }
}
