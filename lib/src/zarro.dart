import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration _kDefaultHighlightFadeDuration = Duration(milliseconds: 200);
const Color _kStainColor = Color(0XFFC0C0C0);

class Zarro extends StatefulWidget {
  const Zarro({
    super.key,
    this.child,
  });

  static ZarroStainController of(BuildContext context) {
    final ZarroStainController? controller = maybeOf(context);
    return controller!;
  }

  static ZarroStainController? maybeOf(BuildContext context) {
    return context.findAncestorRenderObjectOfType<_RenderStainFeatures>();
  }

  final Widget? child;

  @override
  State<Zarro> createState() => _ZarroState();
}

class _ZarroState extends State<Zarro> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Widget? contents = widget.child;

    contents = _StainFeatures(
      vsync: this,
      child: contents,
    );

    return contents;
  }
}

class _StainFeatures extends SingleChildRenderObjectWidget {
  const _StainFeatures({
    super.key,
    required this.vsync,
    super.child,
  });

  final TickerProvider vsync;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderStainFeatures(vsync: vsync);
  }
}

abstract class ZarroStainController {
  TickerProvider get vsync;

  void addStainFeature(StainFeature feature);

  void markNeedsPaint();
}

class _RenderStainFeatures extends RenderProxyBox
    implements ZarroStainController {
  _RenderStainFeatures({
    required this.vsync,
  });

  @override
  final TickerProvider vsync;

  List<StainFeature>? _stainFeatures;

  @override
  void addStainFeature(StainFeature feature) {
    _stainFeatures ??= <StainFeature>[];
    _stainFeatures!.add(feature);
    markNeedsPaint();
  }

  void _removeFeature(StainFeature feature) {
    assert(_stainFeatures != null);
    _stainFeatures!.remove(feature);
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final List<StainFeature>? stainFeatures = _stainFeatures;
    if (stainFeatures != null && stainFeatures.isNotEmpty) {
      final Canvas canvas = context.canvas;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.clipRect(Offset.zero & size);
      for (final StainFeature stainFeature in stainFeatures) {
        stainFeature._paint(canvas);
      }
      canvas.restore();
    }
    assert(stainFeatures == _stainFeatures);
    super.paint(context, offset);
  }
}

abstract class StainFeature {
  StainFeature({
    required ZarroStainController controller,
    required this.referenceBox,
    this.onRemoved,
  }) : _controller = controller as _RenderStainFeatures {
    _controller.addStainFeature(this);
  }

  final RenderBox referenceBox;

  ZarroStainController get controller => _controller;
  final _RenderStainFeatures _controller;

  final void Function()? onRemoved;

  @mustCallSuper
  void dispose() {
    _controller._removeFeature(this);
    onRemoved?.call();
  }

  static Matrix4? _getPaintTransform(
    RenderObject fromRenderObject,
    RenderObject toRenderObject,
  ) {
    // The paths to fromRenderObject and toRenderObject's common ancestor.
    final List<RenderObject> fromPath = <RenderObject>[fromRenderObject];
    final List<RenderObject> toPath = <RenderObject>[toRenderObject];

    RenderObject from = fromRenderObject;
    RenderObject to = toRenderObject;

    while (!identical(from, to)) {
      final int fromDepth = from.depth;
      final int toDepth = to.depth;

      if (fromDepth >= toDepth) {
        final RenderObject? fromParent = from.parent;
        // Return early if the 2 render objects are not in the same render tree,
        // or either of them is offscreen and thus won't get painted.
        if (fromParent is! RenderObject || !fromParent.paintsChild(from)) {
          return null;
        }
        fromPath.add(fromParent);
        from = fromParent;
      }

      if (fromDepth <= toDepth) {
        final RenderObject? toParent = to.parent;
        if (toParent is! RenderObject || !toParent.paintsChild(to)) {
          return null;
        }
        toPath.add(toParent);
        to = toParent;
      }
    }
    assert(identical(from, to));

    final Matrix4 transform = Matrix4.identity();
    final Matrix4 inverseTransform = Matrix4.identity();

    for (int index = toPath.length - 1; index > 0; index -= 1) {
      toPath[index].applyPaintTransform(toPath[index - 1], transform);
    }
    for (int index = fromPath.length - 1; index > 0; index -= 1) {
      fromPath[index]
          .applyPaintTransform(fromPath[index - 1], inverseTransform);
    }

    final double det = inverseTransform.invert();
    return det != 0 ? (inverseTransform..multiply(transform)) : null;
  }

  void _paint(Canvas canvas) {
    final Matrix4? transform = _getPaintTransform(_controller, referenceBox);
    if (transform != null) {
      paintFeature(canvas, transform);
    }
  }

  @protected
  void paintFeature(Canvas canvas, Matrix4 transform);
}

abstract class InteractiveStainFeature extends StainFeature {
  InteractiveStainFeature({
    required super.controller,
    required super.referenceBox,
    super.onRemoved,
  });
}

class StainHighlight extends InteractiveStainFeature {
  StainHighlight({
    required super.controller,
    required super.referenceBox,
    super.onRemoved,
  }) {
    _alphaController = AnimationController(
        duration: _kDefaultHighlightFadeDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged)
      ..forward();
    _alpha = _alphaController.drive(
      IntTween(begin: 0, end: _kStainColor.alpha),
    );
    // controller.addStainFeature(this);
  }

  late Animation<int> _alpha;
  late AnimationController _alphaController;

  bool get active => _active;
  bool _active = true;

  void _paintHighlight(Canvas canvas, Rect rect, Paint paint) {
    canvas.drawRect(rect, paint);
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()..color = _kStainColor.withAlpha(_alpha.value);
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    final Rect rect = Offset.zero & referenceBox.size;
    _paintHighlight(canvas, rect.shift(originOffset!), paint);
  }

  void activate() {
    _active = true;
    _alphaController.forward();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !_active) {
      dispose();
    }
  }

  void deactivate() {
    _active = false;
    _alphaController.reverse();
  }

  @override
  void dispose() {
    _alphaController.dispose();
    super.dispose();
  }
}

abstract class StainFeatureFactory {
  const StainFeatureFactory();

  StainFeature create({required ZarroStainController controller});
}

class StainResponse extends StatefulWidget {
  const StainResponse({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  State<StainResponse> createState() => _StainResponseState();
}

enum _HighlightType { hover }

class _StainResponseState extends State<StainResponse> {
  final Map<_HighlightType, StainHighlight?> _highlights =
      <_HighlightType, StainHighlight?>{};
  bool _hovering = false;
  // StainFeature _createStain() {
  //   final ZarroStainController stainController = Zarro.of(context);
  //   //return const StainFeatureFactory().create(controller: stainController);
  // }

  void _handleTap() {
    // _createStain();
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    _hovering = true;
    _handleHoverChange();
  }

  void _handleMouseExit(PointerExitEvent event) {
    _hovering = false;
    _handleHoverChange();
  }

  void _handleHoverChange() {
    _updateHighlight(_HighlightType.hover, value: _hovering);
  }

  void _updateHighlight(_HighlightType type, {required bool value}) {
    final StainHighlight? highlight = _highlights[type];

    if (value == (highlight != null && highlight.active)) {
      return;
    }

    void handleStainRemoval() {
      assert(_highlights[type] != null);
      _highlights[type] = null;
    }

    if (value) {
      if (highlight == null) {
        final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
        _highlights[type] = StainHighlight(
          controller: Zarro.of(context),
          onRemoved: handleStainRemoval,
          referenceBox: referenceBox,
        );
      } else {
        highlight.activate();
      }
    } else {
      highlight!.deactivate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _handleMouseEnter,
      onExit: _handleMouseExit,
      child: GestureDetector(
        onTap: _handleTap,
        child: widget.child,
      ),
    );
  }
}
