import 'dart:async';
import 'dart:math';

import 'package:ffd/ffd.dart';

/// 描述三角的相对位置
/// [start] - 三角在 [FFloat] 上下侧，表示三角和 [FFloat] 左边缘对齐；三角在 [FFloat] 左右侧，表示三角和 [FFloat] 上边缘对齐
/// [center] - 三角在 [FFloat] 上下侧，表示三角水平居中；三角在 [FFloat] 左右侧，表示三角垂直居中
/// [end] - 三角在 [FFloat] 上下侧，表示三角和 [FFloat] 右边缘对齐；三角在 [FFloat] 左右侧，表示三角和 [FFloat] 下边缘对齐
///
/// Describe the relative position of the triangle
/// [start]-The triangle is above and below [FFloat], indicating that the triangle is aligned with the left edge of [FFloat];
///   the triangle is on the left and right of [FFloat], indicating that the triangle is aligned with the top edge of [FFloat]
/// [center] - The triangle is above and below [FFloat], indicating that the triangle is horizontally centered;
///   the triangle is on the left and right sides of [FFloat], indicating that the triangle is vertically centered
/// [end] - The triangle is above and below [FFloat], indicating that the triangle is aligned with the right edge of [FFloat];
///   the triangle is on the left and right of [FFloat], indicating that the triangle is aligned with the bottom edge of [FFloat]
enum TriangleAlignment {
  start,
  center,
  end,
}

/// 描述 [FFloat] 相对于锚点元素的位置。
/// topLeft - 在锚点元素【上方】，且【左边缘】与锚点元素对齐
/// topCenter - 在锚点元素【上方】，且水平居中
/// topRight - 在锚点元素【上方】，且【右边缘】与锚点元素对齐
/// bottomLeft - 在锚点元素【下方】，且【左边缘】与锚点元素对齐
/// bottomCenter -  在锚点元素【下方】，且水平居中
/// bottomRight -  在锚点元素【下方】，且【右边缘】与锚点元素对齐
/// leftTop - 在锚点元素【左侧】，且【上边缘】与锚点元素对齐
/// leftCenter - 在锚点元素【左侧】，且垂直居中
/// leftBottom - 在锚点元素【左侧】，且【下边缘】与锚点元素对齐
/// rightTop - 在锚点元素【右侧】，且【上边缘】与锚点元素对齐
/// rightCenter - 在锚点元素【右侧】，且垂直居中
/// rightBottom - 在锚点元素【右侧】，且【下边缘】与锚点元素对齐
///
/// Description [FFloat] The position relative to the anchor element.
/// topLeft - In the anchor element [above], and the [leftEdge] is aligned with the anchor element
/// topCenter - In the anchor element [above], and horizontally centered
/// topRight - In the anchor element [above], and the [rightEdge] is aligned with the anchor element
/// bottomLeft - In the anchor element [below], and the [leftEdge] is aligned with the anchor element
/// bottomCenter -  In the anchor element [below], and horizontally centered
/// bottomRight -  In the anchor element [below], and the [rightEdge] is aligned with the anchor element
/// leftTop - In the anchor element [left], and the [upperEdge] is aligned with the anchor element
/// leftCenter - In the anchor element [left], and vertically centered
/// leftBottom - In the anchor element [left], and the [bottomEdge] is aligned with the anchor element
/// rightTop - In the anchor element [right], and the [upperEdge] is aligned with the anchor element
/// rightCenter - In the anchor element [right], and vertically centered
/// rightBottom - In the anchor element [right side], and the [bottomEdge] is aligned with the anchor element
enum FFloatAlignment {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  leftTop,
  leftCenter,
  leftBottom,
  rightTop,
  rightCenter,
  rightBottom,
}

/// 用于返回一个 [Widget]，如果只更新内容区域的话，通过 setter((){}) 进行
///
/// Used to return a [Widget], if only the content area is updated, through setter (() {})
typedef FloatBuilder = Widget Function(StateSetter setter);

class FFloatManager {
  static FFloatManager? _instance;

  factory FFloatManager() => _getInstance();

  static FFloatManager get instance => _getInstance();

  static FFloatManager _getInstance() {
    if (_instance == null) {
      _instance = FFloatManager._();
    }
    return _instance!;
  }

  FFloatManager._();

  FFloatController _controller = FFloatController();

  _FFloat? _float;

  FFloatManager createFloat(
    BuildContext context, {
    required FloatBuilder builder,
    GlobalKey? anchorKey,
    Offset? location,
    Size? anchorSize,
    Offset? anchorLocation,
    EdgeInsets margin = EdgeInsets.zero,
    double triangleWidth = 12,
    double triangleHeight = 6,
    TriangleAlignment triangleAlignment = TriangleAlignment.center,
    Offset triangleOffset = Offset.zero,
    FFloatAlignment alignment = FFloatAlignment.topCenter,
    EdgeInsets? padding,
    Color color = _FFloatContent.DefaultColor,
    Color? strokeColor,
    double? strokeWidth,
    FFloatCorner? corner,
    FFloatCornerStyle cornerStyle = FFloatCornerStyle.round,
    Color backgroundColor = Colors.transparent,
    Gradient? gradient,
    bool canTouchOutside = true,
    bool hideTriangle = false,
    Duration? autoDismissDuration,
    Duration? animDuration,
    double shadowBlur = 1.0,
    Color? shadowColor,
    Offset? shadowOffset,
  }) {
    dismiss();
    _float = _FFloat(context, builder,
        location: location,
        childSize: anchorKey == null ? anchorSize : findAnchorSizeByKey(anchorKey),
        childLocation: anchorKey == null ? anchorLocation : findAnchorLocationByKey(anchorKey),
        margin: margin,
        triangleWidth: triangleWidth,
        triangleHeight: triangleHeight,
        triangleAlignment: triangleAlignment,
        triangleOffset: triangleOffset,
        alignment: alignment,
        padding: padding,
        color: color,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        corner: corner,
        cornerStyle: cornerStyle,
        backgroundColor: backgroundColor,
        gradient: gradient,
        canTouchOutside: canTouchOutside,
        hideTriangle: hideTriangle,
        autoDismissDuration: autoDismissDuration,
        animDuration: animDuration,
        shadowBlur: shadowBlur,
        shadowColor: shadowColor,
        shadowOffset: shadowOffset,
        controller: _controller);
    return this;
  }

  bool get isShow {
    if (_float != null) {
      return _float!.isShow;
    }
    return false;
  }

  void show() {
    if (_float != null) {
      if (_float!.isShow) {
        _float!.rebuildShow();
      } else {
        _float!.show();
      }
    }
  }

  void dismiss() {
    if (_float != null) {
      _float!.dismiss();
    }
  }

  void update(Size anchorSize, Offset location) {
    if (_float != null) {
      _float!.update(anchorSize, location);
    }
  }

  void dispose() {
    if (_float != null) {
      _float!.realDismiss();
      _float!.dispose();
      _float = null;
    }
  }

  Offset findAnchorLocationByKey(GlobalKey key) {
    RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    Offset? location = box?.localToGlobal(Offset.zero);
    return location ?? Offset.zero;
  }

  Size findAnchorSizeByKey(GlobalKey key) {
    RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    return box?.size ?? Size.zero;
  }
}

class _FFloat {
  double triangleWidth;
  double triangleHeight;
  TriangleAlignment triangleAlignment;
  Offset triangleOffset;
  Color color;

  FFloatAlignment alignment;
  EdgeInsets margin;
  EdgeInsets? padding;
  Color? strokeColor;
  double? strokeWidth;
  FFloatCorner? corner;
  FFloatCornerStyle cornerStyle;
  FloatBuilder? builder;
  bool canTouchOutside;
  Color backgroundColor;
  Gradient? gradient;
  bool hideTriangle;
  Duration? autoDismissDuration;
  FFloatController? controller;
  Offset? location;
  Duration? animDuration;
  double shadowBlur;
  Color? shadowColor;
  Offset? shadowOffset;

  Offset? childLocation;
  Size? childSize;

  OverlayEntry? _overlayEntry;
  bool _isShow = false;

  bool get isShow => _isShow;

  set isShow(bool value) {
    if (_isShow == value) return;
    _isShow = value;
    controller?.isShow = value;
  }

  Timer? dismissTimer;

  _FFloatContentController? ffloatContentController;

  ValueNotifier<int>? notifier;

  BuildContext context;

  _FFloat(
    this.context,
    this.builder, {
    this.location,
    this.childSize,
    this.childLocation,
    this.margin = EdgeInsets.zero,
    this.triangleWidth = 12,
    this.triangleHeight = 6,
    this.triangleAlignment = TriangleAlignment.center,
    this.triangleOffset = Offset.zero,
    this.alignment = FFloatAlignment.topCenter,
    this.padding,
    this.color = _FFloatContent.DefaultColor,
    this.strokeColor,
    this.strokeWidth,
    this.corner,
    this.cornerStyle = FFloatCornerStyle.round,
    this.backgroundColor = Colors.transparent,
    this.gradient,
    this.canTouchOutside = true,
    this.hideTriangle = false,
    this.autoDismissDuration,
    this.controller,
    this.animDuration,
    this.shadowBlur = 1.0,
    this.shadowColor,
    this.shadowOffset,
  }) {
    init();
  }

  void init() {
    notifier = new ValueNotifier(0);
    notifier!.addListener(() {
      if (notifier!.value == 0) {
        realDismiss();
      }
    });
    controller?._show = () {
      show();
    };
    controller?._dismiss = () {
      dismiss();
    };
    controller?._rebuildShow = () {
      rebuildShow();
    };
    ffloatContentController = new _FFloatContentController();
  }

  void update(Size anchorSize, Offset location) {
    childSize = anchorSize;
    childLocation = location;
    if (ffloatContentController != null && isShow) {
      ffloatContentController!.update(anchorSize, location);
    }
  }

  void dispose() {
    controller?.dispose();
    ffloatContentController?.dispose();
    if (dismissTimer != null && dismissTimer!.isActive) {
      dismissTimer!.cancel();
      dismissTimer = null;
    }
  }

  void show() {
    /// Prevent duplicate display
    if (isShow) return;
    _showFloat();
  }

  void rebuildShow() {
    _showFloat();
  }

  void _showFloat() {
    final bool hasShow = isShow;
    isShow = true;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      Widget floatContent = _FFloatContent(
        (location != null ? location : childLocation) ?? Offset.zero,
        builder,
        anchorSize: childSize ?? Size.zero,
        alignment: alignment,
        triangleWidth: triangleWidth,
        triangleHeight: triangleHeight,
        triangleOffset: triangleOffset,
        triangleAlignment: triangleAlignment,
        margin: margin,
        padding: padding,
        color: color,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        corner: corner,
        cornerStyle: cornerStyle,
        backgroundColor: backgroundColor,
        gradient: gradient,
        onTouchBackground: canTouchOutside ? dismiss : null,
        hideTriangle: hideTriangle,
        controller: ffloatContentController,
        notifier: notifier,
        animDuration: animDuration,
        shadowOffset: shadowOffset,
        shadowColor: shadowColor,
        shadowBlur: shadowBlur,
        initShow: hasShow,
      );
      return floatContent;
    });
    overlayState?.insert(_overlayEntry!);
    if (autoDismissDuration != null && dismissTimer == null) {
      dismissTimer = Timer(autoDismissDuration!, () {
        if (_overlayEntry != null) {
          dismissTimer = null;
          dismiss();
        }
      });
    }
  }

  void dismiss() {
    isShow = false;
    if (dismissTimer != null && dismissTimer!.isActive) {
      dismissTimer!.cancel();
      dismissTimer = null;
    }
    if (notifier != null) {
      notifier!.value = 1;
    }
  }

  void realDismiss() {
    isShow = false;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

// ignore: must_be_immutable
class _FFloatContent extends StatefulWidget {
  static const Color DefaultColor = Color(0x7F000000);

  FloatBuilder? builder;
  Size anchorSize;
  Offset location;
  double triangleWidth;
  double triangleHeight;
  TriangleAlignment triangleAlignment;
  Offset triangleOffset;
  Color? color;
  FFloatAlignment alignment;
  EdgeInsets margin;
  EdgeInsets? padding;
  Color? strokeColor;
  double? strokeWidth;
  FFloatCorner? corner;
  FFloatCornerStyle cornerStyle;
  Color backgroundColor;
  Gradient? gradient;
  VoidCallback? onTouchBackground;
  bool hideTriangle;
  _FFloatContentController? controller;
  ValueNotifier? notifier;
  Duration? animDuration;
  double? shadowBlur;
  Color? shadowColor;
  Offset? shadowOffset;
  bool? initShow;

  _FFloatContent(
    this.location,
    this.builder, {
    this.anchorSize = Size.zero,
    this.triangleWidth = 12,
    this.triangleHeight = 6,
    this.triangleAlignment = TriangleAlignment.center,
    this.triangleOffset = Offset.zero,
    this.alignment = FFloatAlignment.topCenter,
    this.margin = EdgeInsets.zero,
    this.padding,
    this.color = DefaultColor,
    this.strokeColor,
    this.strokeWidth = 0.0,
    this.corner,
    this.cornerStyle = FFloatCornerStyle.round,
    this.backgroundColor = Colors.transparent,
    this.gradient,
    this.onTouchBackground,
    this.hideTriangle = false,
    this.controller,
    this.notifier,
    this.animDuration,
    this.shadowColor,
    this.shadowOffset,
    this.shadowBlur = 1.0,
    this.initShow,
  });

  @override
  _FFloatContentState createState() => _FFloatContentState();
}

class _FFloatContentState extends State<_FFloatContent> with TickerProviderStateMixin {
  GlobalKey key = GlobalKey();
  Size? areaSize;
  late Offset location;
  late Size anchorSize;
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late bool init;

  @override
  void initState() {
    init = true;
    super.initState();
    animationController = new AnimationController(vsync: this, duration: widget.animDuration ?? Duration(milliseconds: 0));
    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    scaleAnimation.addListener(() {
      setState(() {});
    });
    scaleAnimation.addStatusListener((status) {
//      print('scaleAnimation.status = ${status.toString()}');
      if ((status == AnimationStatus.dismissed || status == AnimationStatus.completed) && widget.notifier != null && widget.notifier!.value == 1) {
        widget.notifier!.value = 0;
      }
    });
    animationController.forward();
    if (widget.notifier != null) {
      widget.notifier!.addListener(onNotifier);
    }
    location = widget.location;
    anchorSize = widget.anchorSize;
    if (widget.controller != null) {
      widget.controller!.state = this;
    }
    postUpdateCallback();
  }

  void onNotifier() {
    if (mounted && widget.notifier != null && widget.notifier!.value == 1 && animationController != null) {
      animationController.reverse(from: 1.0);
    }
  }

  void _setState(Function()? func) {
    if (mounted && func != null) {
      setState(() {
        func();
      });
    }
  }

  void postUpdateCallback() {
    WidgetsBinding.instance?.addPostFrameCallback((time) {
      if (!mounted) return;
      RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
      Size? size = box?.size;
      if (size != null && areaSize != size) {
        areaSize = size;
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(_FFloatContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    location = widget.location;
    anchorSize = widget.anchorSize;
//    if (animationController != null) {
//      animationController.forward();
//    }
  }

  @override
  void dispose() {
    if (widget.notifier != null) {
      widget.notifier!.removeListener(onNotifier);
    }
    if (animationController != null) {
      animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideTriangle) {
      widget.triangleWidth = 0;
      widget.triangleHeight = 0;
    }
    List<Widget> children = [];
    Widget background = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      color: widget.backgroundColor,
    );
    if (widget.onTouchBackground != null) {
      background = GestureDetector(
        onPanDown: (detail) {
          widget.onTouchBackground!();
        },
        child: background,
        behavior: HitTestBehavior.translucent,
      );
    } else {
      background = IgnorePointer(
        child: background,
      );
    }
    children.add(background);
    Widget content = buildFloatContent();
    children.add(content);
    return Stack(
      clipBehavior: Clip.none,
      children: children,
    );
  }

  Widget buildFloatContent() {
    List<Widget> children = [];
    Color color = widget.color ?? _FFloatContent.DefaultColor;
    BorderRadius borderRadius = widget.corner == null
        ? BorderRadius.all(Radius.circular(0))
        : BorderRadius.only(
            topLeft: Radius.circular(widget.corner!.leftTopCorner),
            topRight: Radius.circular(widget.corner!.rightTopCorner),
            bottomRight: Radius.circular(widget.corner!.rightBottomCorner),
            bottomLeft: Radius.circular(widget.corner!.leftBottomCorner),
          );
    var sideColor = widget.strokeColor ?? Colors.transparent;
    var borderSide = BorderSide(
      width: widget.strokeWidth ?? 0,
      color: sideColor,
      style: BorderStyle.solid,
    );
    var shape = widget.cornerStyle == FFloatCornerStyle.round
        ? RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: borderSide,
          )
        : BeveledRectangleBorder(
            borderRadius: borderRadius,
            side: borderSide,
          );

    List<BoxShadow>? shadows = null;
    if (widget.shadowColor != null && widget.shadowBlur != 0) {
      shadows = [BoxShadow(color: widget.shadowColor!, offset: widget.shadowOffset ?? Offset(0, 0), blurRadius: widget.shadowBlur!)];
    }

    var decoration = ShapeDecoration(color: widget.gradient == null ? color : null, gradient: widget.gradient, shape: shape, shadows: shadows);
    Widget content = Container(
      decoration: decoration,
      padding: widget.padding,
      key: key,
      child: widget.builder != null ? widget.builder!(setState) : Container(),
    );
    children.add(content);
    if (areaSize != null) {
      double rotate = calculateTriangleRotate();
      EdgeInsets triangleOffset = calculateTriangleOffset();
      Widget triangle = Positioned(
        left: triangleOffset.left == 0 ? null : triangleOffset.left,
        top: triangleOffset.top == 0 ? null : triangleOffset.top,
        right: triangleOffset.right == 0 ? null : triangleOffset.right,
        bottom: triangleOffset.bottom == 0 ? null : triangleOffset.bottom,
        child: Transform.rotate(
          angle: rotate,
          child: CustomPaint(
            size: Size(widget.triangleWidth, widget.triangleHeight),
            painter: _TrianglePainter(gradient: widget.gradient, color: color, strokeColor: widget.strokeColor, strokeWidth: widget.strokeWidth ?? 0),
          ),
        ),
      );

      children.add(triangle);
    }
    Offset areaOffset = calculateAreaOffset();
    Widget floatContent = Positioned(
      left: location.dx + areaOffset.dx,
      top: location.dy + areaOffset.dy,
      child: Offstage(
        offstage: areaSize == null,
        child: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: scaleAnimation.value,
            alignment: matchScaleAnim(widget.anchorSize == Size.zero),
            child: Stack(
              clipBehavior: Clip.none,
              children: children,
            ),
          ),
        ),
      ),
    );
    return floatContent;
  }

  Alignment matchScaleAnim(bool center) {
    if (center) return Alignment.center;
    switch (alignment) {
      case FFloatAlignment.topLeft:
        return Alignment.bottomLeft;
      case FFloatAlignment.topCenter:
        return Alignment.bottomCenter;
      case FFloatAlignment.topRight:
        return Alignment.bottomRight;
      case FFloatAlignment.bottomLeft:
        return Alignment.topLeft;
      case FFloatAlignment.bottomCenter:
        return Alignment.topCenter;
      case FFloatAlignment.bottomRight:
        return Alignment.topRight;
      case FFloatAlignment.leftTop:
        return Alignment.topRight;
      case FFloatAlignment.leftCenter:
        return Alignment.centerRight;
      case FFloatAlignment.leftBottom:
        return Alignment.bottomRight;
      case FFloatAlignment.rightTop:
        return Alignment.topLeft;
      case FFloatAlignment.rightCenter:
        return Alignment.centerLeft;
      case FFloatAlignment.rightBottom:
        return Alignment.bottomLeft;
    }
    return Alignment.center;
  }

  Offset calculateAreaOffset() {
    if (areaSize == null) return Offset.zero;
    Offset offset = Offset(
      widget.margin.left - widget.margin.right,
      widget.margin.top - widget.margin.bottom,
    );
    switch (alignment) {
      case FFloatAlignment.topLeft:
        return Offset(
              0,
              -areaSize!.height - widget.triangleHeight,
            ) +
            offset;
      case FFloatAlignment.topCenter:
        return Offset(
              anchorSize.width / 2.0 - areaSize!.width / 2.0,
              -areaSize!.height - widget.triangleHeight,
            ) +
            offset;
      case FFloatAlignment.topRight:
        return Offset(
              anchorSize.width - areaSize!.width,
              -areaSize!.height - widget.triangleHeight,
            ) +
            offset;
      case FFloatAlignment.bottomLeft:
        return Offset(
              0,
              anchorSize.height + widget.triangleHeight,
            ) +
            offset;
      case FFloatAlignment.bottomCenter:
        return Offset(
              anchorSize.width / 2.0 - areaSize!.width / 2.0,
              anchorSize.height + widget.triangleHeight,
            ) +
            offset;

      case FFloatAlignment.bottomRight:
        return Offset(
              anchorSize.width - areaSize!.width,
              anchorSize.height + widget.triangleHeight,
            ) +
            offset;

      case FFloatAlignment.leftTop:
        return Offset(
              -areaSize!.width - widget.triangleHeight,
              0,
            ) +
            offset;

      case FFloatAlignment.leftCenter:
        return Offset(
              -areaSize!.width - widget.triangleHeight,
              anchorSize.height / 2.0 - areaSize!.height / 2.0,
            ) +
            offset;

      case FFloatAlignment.leftBottom:
        return Offset(
              -areaSize!.width - widget.triangleHeight,
              anchorSize.height - areaSize!.height,
            ) +
            offset;

      case FFloatAlignment.rightTop:
        return Offset(
              anchorSize.width + widget.triangleHeight,
              0,
            ) +
            offset;

      case FFloatAlignment.rightCenter:
        return Offset(
              anchorSize.width + widget.triangleHeight,
              anchorSize.height / 2.0 - areaSize!.height / 2.0,
            ) +
            offset;

      case FFloatAlignment.rightBottom:
        return Offset(
              anchorSize.width + widget.triangleHeight,
              anchorSize.height - areaSize!.height,
            ) +
            offset;
    }
    return Offset.zero;
  }

  double calculateTriangleRotate() {
    switch (alignment) {
      case FFloatAlignment.topLeft:
      case FFloatAlignment.topCenter:
      case FFloatAlignment.topRight:
        return pi;
      case FFloatAlignment.bottomLeft:
      case FFloatAlignment.bottomCenter:
      case FFloatAlignment.bottomRight:
        return 0.0;
      case FFloatAlignment.leftTop:
      case FFloatAlignment.leftCenter:
      case FFloatAlignment.leftBottom:
        return pi / 2.0;
      case FFloatAlignment.rightTop:
      case FFloatAlignment.rightCenter:
      case FFloatAlignment.rightBottom:
        return -pi / 2.0;
    }
    return pi;
  }

  ///计算定位
  FFloatAlignment get alignment {
    if (widget.alignment == FFloatAlignment.topCenter && location != null && areaSize != null) {
      double topY = widget.margin.bottom + location.dy - areaSize!.height;

      if (topY < 40) {
        return FFloatAlignment.bottomCenter;
      }
    }

    return widget.alignment;
  }

  EdgeInsets calculateTriangleOffset() {
    Offset srcOffset = widget.triangleOffset;
    EdgeInsets offset = EdgeInsets.zero;

    /// 三角和内容区域会有一点间距，可能是由于计算精度和绘制像素精度有差异造成的
    double fixOffset = 0.13 + (widget.strokeWidth ?? 0.0) / 2.0;
    switch (alignment) {
      case FFloatAlignment.topLeft:
      case FFloatAlignment.topCenter:
      case FFloatAlignment.topRight:
        double bottom = -widget.triangleHeight + fixOffset;
        switch (widget.triangleAlignment) {
          case TriangleAlignment.start:
            offset = EdgeInsets.only(
              left: srcOffset.dx,
              bottom: bottom,
            );
            break;
          case TriangleAlignment.center:
            offset = EdgeInsets.only(
              left: srcOffset.dx + areaSize!.width / 2.0 - widget.triangleWidth / 2,
              bottom: bottom,
            );
            break;
          case TriangleAlignment.end:
            offset = EdgeInsets.only(
              left: srcOffset.dx + areaSize!.width - widget.triangleWidth,
              bottom: bottom,
            );
            break;
        }
        break;
      case FFloatAlignment.bottomLeft:
      case FFloatAlignment.bottomCenter:
      case FFloatAlignment.bottomRight:
        double top = -widget.triangleHeight + fixOffset;
        switch (widget.triangleAlignment) {
          case TriangleAlignment.start:
            offset = EdgeInsets.only(
              left: srcOffset.dx,
              top: top,
            );
            break;
          case TriangleAlignment.center:
            offset = EdgeInsets.only(
              left: srcOffset.dx + areaSize!.width / 2.0 - widget.triangleWidth / 2,
              top: top,
            );
            break;
          case TriangleAlignment.end:
            offset = EdgeInsets.only(
              left: srcOffset.dx + areaSize!.width - widget.triangleWidth,
              top: top,
            );
            break;
        }
        break;
      case FFloatAlignment.leftTop:
      case FFloatAlignment.leftCenter:
      case FFloatAlignment.leftBottom:
        double startTop = srcOffset.dy + -widget.triangleHeight / 2.0 + widget.triangleWidth / 2.0;
        double right = -widget.triangleWidth / 2.0 - widget.triangleHeight / 2.0 + fixOffset;
        switch (widget.triangleAlignment) {
          case TriangleAlignment.start:
            offset = EdgeInsets.only(
              right: right,
              top: startTop,
            );
            break;
          case TriangleAlignment.center:
            offset = EdgeInsets.only(
              right: right,
              top: startTop + areaSize!.height / 2.0 - widget.triangleWidth / 2.0,
            );
            break;
          case TriangleAlignment.end:
            offset = EdgeInsets.only(
              right: right,
              top: startTop + areaSize!.height - widget.triangleWidth,
            );
            break;
        }
        break;
      case FFloatAlignment.rightTop:
      case FFloatAlignment.rightCenter:
      case FFloatAlignment.rightBottom:
        double startTop = srcOffset.dy + -widget.triangleHeight / 2.0 + widget.triangleWidth / 2.0;
        double left = -widget.triangleWidth / 2.0 - widget.triangleHeight / 2.0 + fixOffset;
        switch (widget.triangleAlignment) {
          case TriangleAlignment.start:
            offset = EdgeInsets.only(
              left: left,
              top: startTop,
            );
            break;
          case TriangleAlignment.center:
            offset = EdgeInsets.only(
              left: left,
              top: startTop + areaSize!.height / 2.0 - widget.triangleWidth / 2.0,
            );
            break;
          case TriangleAlignment.end:
            offset = EdgeInsets.only(
              left: left,
              top: startTop + areaSize!.height - widget.triangleWidth,
            );
            break;
        }
        break;
    }
    return offset;
  }
}

class _FFloatContentController {
  _FFloatContentState? state;

  update(Size anchorSize, Offset location) {
    state?._setState(() {
      state?.anchorSize = anchorSize;
      state?.location = location;
    });
  }

  dispose() {
    state = null;
  }
}

/// 圆角。
///
/// corner
class FFloatCorner {
  final double leftTopCorner;
  final double rightTopCorner;
  final double rightBottomCorner;
  final double leftBottomCorner;

  /// 指定每一个圆角的大小
  ///
  /// Specify the size of each rounded corner
  const FFloatCorner({
    this.leftTopCorner = 0,
    this.rightTopCorner = 0,
    this.rightBottomCorner = 0,
    this.leftBottomCorner = 0,
  });

  /// 设置所有圆角为一个大小
  ///
  /// Set all rounded corners to one size
  const FFloatCorner.all(double radius)
      : leftTopCorner = radius,
        rightTopCorner = radius,
        rightBottomCorner = radius,
        leftBottomCorner = radius;
}

/// 圆角风格。
/// [round] - 圆角
/// [bevel] - 斜角
///
/// Rounded corner style.
/// [round]-rounded corners
/// [bevel]-beveled corners
enum FFloatCornerStyle {
  round,
  bevel,
}

/// 通过 [FFloatController] 可以控制 [FFloat] 的显示、隐藏，以及感知状态变化。
///
/// [FFloatController] can control [FFloat] display, hide, and sense state changes.
class FFloatController {
  VoidCallback? _callback;

  bool _isShow = false;

  /// [FFloat] 是否显示
  ///
  /// [FFloat] Whether to display
  bool get isShow => _isShow;

  set isShow(bool value) {
    if (_isShow == value) return;
    _isShow = value;
    if (_callback != null) {
      _callback!();
    }
  }

//  _FFloatState _state;

  VoidCallback? _show;
  VoidCallback? _dismiss;
  VoidCallback? _rebuildShow;

  /// 隐藏 [FFloat]
  ///
  /// Hide [FFloat]
  void dismiss() {
    if (_dismiss != null) {
      _dismiss!();
    }
  }

  /// 显示 [FFloat]。如果已经显示，将不会再次重建。
  ///
  /// Show [FFloat]。If it is already displayed, it will not be rebuilt again.
  void show() {
    if (_show != null) {
      _show!();
    }
  }

  /// 显示 [FFloat]。会重建。
  ///
  /// [FFloat] is displayed. Will rebuild.
  void rebuildShow() {
    if (_rebuildShow != null) {
      _rebuildShow!();
    }
  }

  /// 销毁
  ///
  /// destroy
  dispose() {
//    _callback = null;
  }

  /// 设置监听。当 [FFloat] 显示状态发生变化的时候会回调。
  ///
  /// Set up monitoring. It will be called back when [FFloat] display status changes.
  setStateChangedListener(VoidCallback listener) {
    _callback = listener;
  }
}

class _TrianglePainter extends CustomPainter {
  Color color;
  double strokeWidth;
  Color? strokeColor;
  Gradient? gradient;

  _TrianglePainter({
    this.color = _FFloatContent.DefaultColor,
    this.strokeWidth = 0,
    this.strokeColor,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    if (gradient != null) {
      paint
        ..isAntiAlias = true
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill
        ..shader = gradient!.createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    } else {
      paint
        ..isAntiAlias = true
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill;
    }
    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    if (strokeColor != null && strokeWidth > 0) {
      paint
        ..shader = null
        ..color = strokeColor!
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) {
    return true;
  }
}
