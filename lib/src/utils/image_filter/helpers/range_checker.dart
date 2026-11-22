import 'dart:math';

class RangeHelper {
  final int centerX;
  final int centerY;
  final int radius;
  final int imgWidth;
  final int imgHeight;
  final int imgBorder;
  int rangeWidth = 0;
  int rangeHeight = 0;
  int x1 = 0;
  int y1 = 0;
  int x2 = 0;
  int y2 = 0;
  final bool isCircle;
  late bool fail;

  /// rotated rectangle (see [RangeHelper.rotatedSquare]); range is its
  /// bounding box and [checkPointInRange] cuts the corners off
  bool isRotated = false;
  double _rotCenterX = 0;
  double _rotCenterY = 0;
  double _rotHalfWidth = 0;
  double _rotHalfHeight = 0;
  double _rotCos = 1;
  double _rotSin = 0;

  RangeHelper.circle(this.centerX, this.centerY, this.radius, this.imgWidth,
      this.imgHeight, this.imgBorder)
      : isCircle = true {
    fail =
        ((imgBorder + 1) > imgWidth ~/ 2) || ((imgBorder + 1) > imgHeight ~/ 2);
    _calculateRadiusArea();
    if (fail) {
      x1 = 1;
      x2 = 0;
      y1 = 1;
      y2 = 0;
      return;
    }
    rangeWidth = x2 - x1 + 1;
    rangeHeight = y2 - y1 + 1;
  }

  RangeHelper.square(this.x1, this.y1, this.x2, this.y2, this.imgWidth,
      this.imgHeight, this.imgBorder)
      : centerX = 0,
        centerY = 0,
        isCircle = false,
        radius = 0 {
    fail =
        ((imgBorder + 1) > imgWidth ~/ 2) || ((imgBorder + 1) > imgHeight ~/ 2);
    if (x1 > x2) {
      var t = x1;
      x1 = x2;
      x2 = t;
    }
    if (y1 > y2) {
      var t = y1;
      y1 = y2;
      y2 = t;
    }
    _calculateArea();

    if (fail) {
      x1 = 1;
      x2 = 0;
      y1 = 1;
      y2 = 0;
      return;
    }
    rangeWidth = x2 - x1 + 1;
    rangeHeight = y2 - y1 + 1;
  }

  /// Rectangle of [width] x [height] centered in (centerX, centerY), rotated
  /// clockwise by [angle] radians.
  factory RangeHelper.rotatedSquare(int centerX, int centerY, int width,
      int height, double angle, int imgWidth, int imgHeight, int imgBorder) {
    var halfWidth = width.abs() / 2;
    var halfHeight = height.abs() / 2;
    var c = cos(angle);
    var s = sin(angle);
    var boxHalfWidth = (halfWidth * c).abs() + (halfHeight * s).abs();
    var boxHalfHeight = (halfWidth * s).abs() + (halfHeight * c).abs();
    var range = RangeHelper.square(
        (centerX - boxHalfWidth).floor(),
        (centerY - boxHalfHeight).floor(),
        (centerX + boxHalfWidth).ceil(),
        (centerY + boxHalfHeight).ceil(),
        imgWidth,
        imgHeight,
        imgBorder);
    range.isRotated = true;
    range._rotCenterX = centerX.toDouble();
    range._rotCenterY = centerY.toDouble();
    range._rotHalfWidth = halfWidth;
    range._rotHalfHeight = halfHeight;
    range._rotCos = c;
    range._rotSin = s;
    return range;
  }

  bool checkPointInRange(int x, int y) {
    //if(fail) return false;
    if (isRotated) {
      // rotate point back by -angle into the unrotated frame
      var dx = x - _rotCenterX;
      var dy = y - _rotCenterY;
      var lx = dx * _rotCos + dy * _rotSin;
      var ly = -dx * _rotSin + dy * _rotCos;
      return lx.abs() <= _rotHalfWidth && ly.abs() <= _rotHalfHeight;
    }
    if (!isCircle) return true;
    int diffX = (centerX - x).abs();
    int diffY = (centerY - y).abs();
    if (diffY + diffX < radius) return true;
    return sqrt((diffX * diffX) + (diffY * diffY)) <= radius;
  }

  void _calculateRadiusArea() {
    x1 = centerX - radius;
    y1 = centerY - radius;
    x2 = centerX + radius;
    y2 = centerY + radius;
    int border = imgBorder;
    int borderPlus = border + 1;
    if (x1 < border) x1 = border;
    if (x2 < border) x2 = border;
    if (y1 < border) y1 = border;
    if (y2 < border) y2 = border;
    if (x1 > imgWidth - borderPlus) x1 = imgWidth - borderPlus;
    if (x2 > imgWidth - borderPlus) x2 = imgWidth - borderPlus;
    if (y1 > imgHeight - borderPlus) y1 = imgHeight - borderPlus;
    if (y2 > imgHeight - borderPlus) y2 = imgHeight - borderPlus;
    if (x1 > x2) {
      var temp = x1;
      x1 = x2;
      x2 = temp;
    }
    if (y1 > y2) {
      var temp = y1;
      y1 = y2;
      y2 = temp;
    }
  }

  void _calculateArea() {
    int border = imgBorder;
    int borderPlus = border + 1;
    if (x1 < border) x1 = border;
    if (x2 < border) x2 = border;
    if (y1 < border) y1 = border;
    if (y2 < border) y2 = border;
    if (x1 > imgWidth - borderPlus) x1 = imgWidth - borderPlus;
    if (x2 > imgWidth - borderPlus) x2 = imgWidth - borderPlus;
    if (y1 > imgHeight - borderPlus) y1 = imgHeight - borderPlus;
    if (y2 > imgHeight - borderPlus) y2 = imgHeight - borderPlus;
    if (x1 > x2) {
      var temp = x1;
      x1 = x2;
      x2 = temp;
    }
    if (y1 > y2) {
      var temp = y1;
      y1 = y2;
      y2 = temp;
    }
  }
}
