import 'package:before_after/src/rect_clipper.dart';
import 'package:flutter/material.dart';

class BeforeAfter extends StatefulWidget {
  final Widget beforeImage;
  final Widget afterImage;
  final double imageHeight;
  final double imageWidth;
  final double imageCornerRadius;
  final Color thumbColor;
  final double thumbRadius;
  final Color overlayColor;
  final bool isVertical;
  final double initClipFactor;
  final StackFit fit;
  final bool thumbOverflow;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onChangeStart, onChangeEnd;

  const BeforeAfter({
    Key? key,
    required this.beforeImage,
    required this.afterImage,
    this.imageHeight = 0,
    this.imageWidth = 0,
    this.imageCornerRadius = 8.0,
    this.thumbColor = Colors.white,
    this.thumbRadius = 16.0,
    this.overlayColor = Colors.black54,
    this.isVertical = false,
    this.initClipFactor = 0.5,
    this.fit = StackFit.loose,
    this.thumbOverflow = false,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  _BeforeAfterState createState() => _BeforeAfterState(initClipFactor);
}

class _BeforeAfterState extends State<BeforeAfter> {
  double _clipFactor;

  _BeforeAfterState(this._clipFactor);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: widget.fit,
      children: <Widget>[
        Padding(
          padding: widget.thumbOverflow
              ? EdgeInsets.zero
              : widget.isVertical
                  ? const EdgeInsets.symmetric(vertical: 24.0)
                  : const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedImage(
            widget.afterImage,
            widget.imageHeight,
            widget.imageWidth,
            widget.imageCornerRadius,
          ),
        ),
        Padding(
          padding: widget.thumbOverflow
              ? EdgeInsets.zero
              : widget.isVertical
                  ? const EdgeInsets.symmetric(vertical: 24.0)
                  : const EdgeInsets.symmetric(horizontal: 24.0),
          child: ClipPath(
            clipper: widget.isVertical ? RectClipperVertical(_clipFactor) : RectClipper(_clipFactor),
            child: SizedImage(
              widget.beforeImage,
              widget.imageHeight,
              widget.imageWidth,
              widget.imageCornerRadius,
            ),
          ),
        ),
        Positioned.fill(
          top: widget.thumbOverflow && widget.isVertical ? -24.0 : 0,
          bottom: widget.thumbOverflow && widget.isVertical ? -24.0 : 0,
          left: widget.thumbOverflow && !widget.isVertical ? -24.0 : 0,
          right: widget.thumbOverflow && !widget.isVertical ? -24.0 : 0,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 0.0,
              overlayColor: widget.overlayColor,
              thumbShape: CustomThumbShape(widget.thumbRadius, widget.thumbColor),
            ),
            child: widget.isVertical ? RotatedBox(quarterTurns: 1, child: _buildSlider()) : _buildSlider(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    return Slider(
      value: _clipFactor,
      onChangeStart: (value) => widget.onChangeStart?.call(),
      onChangeEnd: (value) => widget.onChangeEnd?.call(),
      onChanged: (double factor) {
        setState(() => this._clipFactor = factor);
        widget.onChanged?.call(factor);
      },
    );
  }
}

class SizedImage extends StatelessWidget {
  final Widget _image;
  final double _height, _width, _imageCornerRadius;

  const SizedImage(this._image, this._height, this._width, this._imageCornerRadius, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_imageCornerRadius),
      child: SizedBox(
        height: _height,
        width: _width,
        child: _image,
      ),
    );
  }
}

class CustomThumbShape extends SliderComponentShape {
  final double _thumbRadius;
  final Color _thumbColor;

  CustomThumbShape(this._thumbRadius, this._thumbColor);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(_thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 4.0
      ..color = _thumbColor
      ..style = PaintingStyle.fill;

    final Paint paintStroke = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 4.0
      ..color = _thumbColor
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      center,
      _thumbRadius,
      paintStroke,
    );

    canvas.drawCircle(
      center,
      _thumbRadius - 6,
      paint,
    );

    canvas.drawRect(Rect.fromCenter(center: center, width: 4.0, height: parentBox.size.height), paint);
  }
}
