import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../helpers/constants.dart';

class FilterPosition {
  /// static filter storage. to keep last created value in memory
  static double _sGranularityRatio = ImgConst.startGranularityRatio;
  static double _sRadiusRatio = ImgConst.startRadiusRatio;
  static bool _sIsRounded = true;
  static bool _sIsPixelate = true;

  // todo - for tests we need to reset class to inital values
  // todo - but better to use some provider in future and mock it in tests
  static void resetStoredInfo() {
    _sGranularityRatio = ImgConst.startGranularityRatio;
    _sRadiusRatio = ImgConst.startRadiusRatio;
    _sIsRounded = true;
    _sIsPixelate = true;
  }

  /// sets defaults for new areas (e.g. restored from persistent storage).
  /// Size is deliberately not restored. Null values keep the current default.
  static void setDefaults(
      {bool? isRounded, bool? isPixelate, double? granularityRatio}) {
    if (isRounded != null) _sIsRounded = isRounded;
    if (isPixelate != null) _sIsPixelate = isPixelate;
    if (granularityRatio != null) {
      _sGranularityRatio = granularityRatio.clamp(0.0, 1.0).toDouble();
    }
  }

  /// scale area constants
  static const _startAngle = -pi / 4; //bottom right point
  static final double _sSin = sin(_startAngle);
  static final double _sCos = cos(_startAngle);
  static const _resizeBlockSize = 8; //dp//lp
  static const _resizeClickSize = 32; //dp//lp
  static const _rotateStemSize = 20; //dp//lp, distance of handle above top edge
  static const _rotateSnapStep = pi / 4; //snap to 0/45/90... degrees
  static const _rotateSnapTolerance = 3 * pi / 180;

  final int maxRadius;

  FilterPosition(this.maxRadius);

  double _granularity = _sGranularityRatio;
  double _radius = _sRadiusRatio;
  double _cos = _sCos; //45 degree
  double _sin = _sSin;

  bool _rounded = _sIsRounded;
  bool _pixelate = _sIsPixelate;

  double posX = ImgConst.undefinedPosValue.toDouble();
  double posY = ImgConst.undefinedPosValue.toDouble();

  set granularityRatio(double value) {
    _granularity = value;
    _sGranularityRatio = value;
  }

  double get granularityRatio => _granularity;

  set radiusRatio(double value) {
    _radius = value;
    _sRadiusRatio = value;
    if (!_rounded) {
      _sRadiusRatio = ((((_radius * _cos).abs() + (_radius * _sin).abs()) / 2) /
              cos(_startAngle))
          .abs();
      if (_sRadiusRatio > 1.0) _sRadiusRatio = 1.0;
    }
  }

  double get radiusRatio => _radius;

  set isRounded(bool value) {
    _rounded = value;
    _sIsRounded = value;
  }

  bool get isRounded => _rounded;

  set isPixelate(bool value) {
    _pixelate = value;
    _sIsPixelate = value;
  }

  bool get isPixelate => _pixelate;

  /// clockwise rotation (radians) of squared areas around their center
  double rotation = 0;

  bool canceled = true;
  bool forceRedraw = true;

  int getVisibleRadius() => (maxRadius * radiusRatio).toInt();

  int getVisibleWidth() => (maxRadius * radiusRatio * _cos * 2).toInt();

  int getVisibleHeight() => (maxRadius * radiusRatio * _sin * 2).toInt();

  bool isInnerPoint(double x, double y) {
    var radius = getVisibleRadius();
    if (_rounded) {
      return sqrt(pow(posX - x, 2) + pow(posY - y, 2)) <=
          (getVisibleRadius() + 0.51);
    } else {
      var diffX = (radius * _cos).abs() + 0.51;
      var diffY = (radius * _sin).abs() + 0.51;
      var local = _toLocal(x, y);
      return (local.dx <= posX + diffX &&
          local.dx >= posX - diffX &&
          local.dy <= posY + diffY &&
          local.dy >= posY - diffY);
    }
  }

  /// rotates point around area center by [angle] (clockwise on screen)
  Offset _rotateAroundCenter(double x, double y, double angle) {
    var c = cos(angle);
    var s = sin(angle);
    var dx = x - posX;
    var dy = y - posY;
    return Offset(posX + dx * c - dy * s, posY + dx * s + dy * c);
  }

  /// converts screen point to the unrotated coordinate system of the area
  Offset _toLocal(double x, double y) =>
      rotation == 0 ? Offset(x, y) : _rotateAroundCenter(x, y, -rotation);

  Offset getResizingAreaPosition() {
    var radius = getVisibleRadius();
    var eX = posX + (radius * _cos);
    var eY = posY - (radius * _sin);
    return _rotateAroundCenter(eX, eY, rotation);
  }

  /// true when the rotation handle sits below the area instead of above it.
  /// Decided from the unrotated position only, so it can't flip while the
  /// area is being rotated: below the area if there is no room above it.
  bool _handleBelow = false;

  bool get isRotationHandleBelow => _handleBelow;

  /// signed distance (local y axis) of the handle stem start from center
  double get _handleDir => _handleBelow ? 1 : -1;

  /// handle above the top edge of the rotated area (or below the bottom edge
  /// if there is no room above, see [isRotationHandleBelow])
  Offset getRotationHandlePosition(double pixelsInDP) {
    var stem = _rotateStemSize * pixelsInDP;
    var halfHeight = getVisibleHeight().abs() / 2;
    _handleBelow = posY - halfHeight - stem < 0;
    return _rotateAroundCenter(
        posX, posY + _handleDir * (halfHeight + stem), rotation);
  }

  Rect getRotationHandleClickRect(double pixelsInDP) {
    return Rect.fromCenter(
        center: getRotationHandlePosition(pixelsInDP),
        width: _resizeClickSize * pixelsInDP,
        height: _resizeClickSize * pixelsInDP);
  }

  /// point the handle is attached to (middle of the top or bottom edge)
  Offset getRotationStemStart() => _rotateAroundCenter(
      posX, posY + _handleDir * (getVisibleHeight().abs() / 2), rotation);

  /// rotates area so that its rotation handle points towards (x, y)
  void rotateFromClick(double x, double y) {
    if (x == posX && y == posY) return;
    var angle = atan2(y - posY, x - posX) - _handleDir * pi / 2;
    var snapped = (angle / _rotateSnapStep).round() * _rotateSnapStep;
    if ((angle - snapped).abs() <= _rotateSnapTolerance) angle = snapped;
    // normalize to (-pi, pi]
    angle = atan2(sin(angle), cos(angle));
    rotation = angle;
  }

  Rect getResizingAreaRect(double pixelsInDP) {
    return Rect.fromCenter(
        center: getResizingAreaPosition(),
        width: _resizeBlockSize * pixelsInDP,
        height: _resizeBlockSize * pixelsInDP);
  }

  Rect getResizingAreaClickRect(double pixelsInDP) {
    return Rect.fromCenter(
        center: getResizingAreaPosition(),
        width: _resizeClickSize * pixelsInDP,
        height: _resizeClickSize * pixelsInDP);
  }


  void rebuildRadiusFromClick(double x2, double y2) {
    if (_rounded) {
      var diffx = x2 - posX;
      var diffy = posY - y2;
      var dist = sqrt(pow(diffx, 2) + pow(diffy, 2));
      _cos = diffx / dist;
      _sin = diffy / dist;
      /*_sCos = _cos; //we will not save this for new areas always new squares and circles
      _sSin = _sin;*/
      radiusRatio = dist / maxRadius;
      if (radiusRatio > 1.0) radiusRatio = 1.0;
    } else {
      // work in the unrotated frame of the area: the opposite corner stays
      // fixed on screen, so new center is the middle of anchor and click
      var anchor = _rotateAroundCenter(posX - (maxRadius * radiusRatio * _cos),
          posY + (maxRadius * radiusRatio * _sin), rotation);
      var click = Offset(x2, y2);
      var mid = (anchor + click) / 2;
      var delta = click - anchor;
      var c = cos(-rotation);
      var s = sin(-rotation);
      var diffx = delta.dx * c - delta.dy * s;
      var diffy = -(delta.dx * s + delta.dy * c);
      var dist = sqrt(pow(diffx, 2) + pow(diffy, 2));
      posX = mid.dx;
      posY = mid.dy;
      _cos = diffx / dist;
      _sin = diffy / dist;
      radiusRatio = dist / (maxRadius * 2);
      if (radiusRatio > 1.0) radiusRatio = 1.0;
    }
  }

  bool contains(FilterPosition anotherFilter) {
    Rect oneRect = Rect.zero;
    if (isRounded) {
      oneRect = Rect.fromCircle(
          center: Offset(posX, posY),
          radius: getVisibleRadius().toDouble() + 0.51);
    } else {
      oneRect = Rect.fromCenter(
          center: Offset(posX, posY),
          width: getVisibleWidth().toDouble() + 0.51,
          height: getVisibleHeight().toDouble() + 0.51);
    }
    Rect anotherRect = Rect.zero;
    if (anotherFilter.isRounded) {
      anotherRect = Rect.fromCircle(
          center: Offset(anotherFilter.posX, anotherFilter.posY),
          radius: anotherFilter.getVisibleRadius().toDouble() + 0.51);
    } else {
      anotherRect = Rect.fromCenter(
          center: Offset(anotherFilter.posX, anotherFilter.posY),
          width: anotherFilter.getVisibleWidth().toDouble() + 0.51,
          height: anotherFilter.getVisibleHeight().toDouble() + 0.51);
    }
    if (oneRect.contains(anotherRect.center)) return true;
    if (anotherRect.contains(oneRect.center)) return true;

    if (oneRect.contains(anotherRect.topLeft)) return true;
    if (oneRect.contains(anotherRect.topRight)) return true;
    if (oneRect.contains(anotherRect.bottomLeft)) return true;
    if (oneRect.contains(anotherRect.bottomRight)) return true;

    if (anotherRect.contains(oneRect.topLeft)) return true;
    /* --- below not necessary for only squared areas ---
    if (anotherRect.contains(oneRect.topRight)) return true;
    if (anotherRect.contains(oneRect.bottomLeft)) return true;
    if (anotherRect.contains(oneRect.bottomRight)) return true;*/

    return false;
  }
}
