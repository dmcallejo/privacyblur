import 'dart:math';

import 'package:flutter/material.dart';
import 'package:privacyblur/src/screens/image/helpers/constants.dart';
import 'package:privacyblur/src/screens/image/utils/filter_position.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ShapePainter extends CustomPainter {
  int _hash = 0;
  final int selectedPosition;
  final List<FilterPosition> positions;
  final double pixelsInDP;

  /// handle that is being dragged right now, drawn bigger
  final bool resizing;
  final bool rotating;

  ShapePainter(this.positions, this.selectedPosition, this.pixelsInDP,
      {this.resizing = false, this.rotating = false}) {
    // with prime numbers to reduce collisions... may be. Not very important
    // from https://primes.utm.edu/lists/small/10000.txt
    _hash = (pixelsInDP * 5623).round() + (resizing ? 3571 : 0) + (rotating ? 6217 : 0);
    for (var p in positions) {
      _hash += (p.isRounded ? 7879 : 9341) +
          selectedPosition * 8467 +
          (p.getVisibleRadius() * 14557).toInt() +
          (p.rotation * 1000).toInt() * 4079 +
          p.posX.toInt() +
          p.posY.toInt() * 12347;
    }
  }

  @override
  bool operator ==(other) {
    return (other is ShapePainter) ? _hash == other._hash : false;
  }

  @override
  int get hashCode => _hash;

  void _drawImageSelection(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
        const Offset(0, 0) & Size(size.width - 2, size.height - 2), paint1);
  }

  void _drawCircle(Canvas canvas, double x, double y, int r, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(x, y), r.toDouble(), paint);
  }

  void _drawRect(
      Canvas canvas, double x, double y, int width, int height, Color color) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(x.toDouble(), y.toDouble()),
            width: width.toDouble(),
            height: height.toDouble()),
        paint);
  }

  void _drawDragRect(Canvas canvas, Rect block, Color color) {
    // pressed handles are inflated by the caller
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            block, Radius.circular(min(block.width, block.height) / 3)),
        paint);
    paint = Paint();
    paint.color = Colors.white54;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            block, Radius.circular(min(block.width, block.height) / 3)),
        paint);

    //additional drawing for resizing rect area is here...
  }

  /// faint fill so it is clear which shape the handles belong to
  void _drawSelectionFill(Canvas canvas, FilterPosition position) {
    var fill = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    if (position.isRounded) {
      canvas.drawCircle(Offset(position.posX, position.posY),
          position.getVisibleRadius().toDouble(), fill);
    } else {
      canvas.save();
      canvas.translate(position.posX, position.posY);
      canvas.rotate(position.rotation);
      canvas.translate(-position.posX, -position.posY);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(position.posX, position.posY),
              width: position.getVisibleWidth().toDouble(),
              height: position.getVisibleHeight().toDouble()),
          fill);
      canvas.restore();
    }
  }

  void _drawRotationHandle(
      Canvas canvas, FilterPosition position, Color color) {
    var dotRadius = (rotating ? 10 : 7) * pixelsInDP;
    var handle = position.getRotationHandlePosition(pixelsInDP);
    var line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(position.getRotationStemStart(), handle, line);
    canvas.drawCircle(handle, dotRadius, Paint()..color = color);
    canvas.drawCircle(
        handle,
        dotRadius,
        Paint()
          ..color = Colors.white54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);
  }

  @override
  void paint(Canvas canvas, Size size) {
    positions.asMap().forEach((index, position) {
      if (position.posX <= ImgConst.undefinedPosValue ||
          position.posY <= ImgConst.undefinedPosValue) {
        return;
      }
      var radius = position.getVisibleRadius();
      var colorBorder =
          index == selectedPosition ? AppTheme.primaryColor : Colors.black;
      var colorBorderInner =
          index == selectedPosition ? AppTheme.primaryColor : Colors.grey;
      if (index == selectedPosition) {
        _drawSelectionFill(canvas, position);
      }
      if (position.isRounded) {
        _drawCircle(canvas, position.posX, position.posY, radius, colorBorder);
        _drawCircle(
            canvas, position.posX, position.posY, radius - 2, colorBorderInner);
      } else {
        canvas.save();
        canvas.translate(position.posX, position.posY);
        canvas.rotate(position.rotation);
        canvas.translate(-position.posX, -position.posY);
        _drawRect(
            canvas,
            position.posX,
            position.posY,
            position.getVisibleWidth(),
            position.getVisibleHeight(),
            colorBorder);
        _drawRect(
            canvas,
            position.posX,
            position.posY,
            position.getVisibleWidth() - 2,
            position.getVisibleHeight() - 2,
            colorBorderInner);
        canvas.restore();
      }
      if (index == selectedPosition) {
        _drawDragRect(
            canvas,
            position.getResizingAreaRect(pixelsInDP * (resizing ? 1.5 : 1)),
            colorBorder);
        // circles have no corners, so rotating them makes no sense
        if (!position.isRounded) {
          _drawRotationHandle(canvas, position, colorBorder);
        }
      }
    });
    if (selectedPosition < 0 || selectedPosition >= positions.length) {
      _drawImageSelection(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    if (_hash != oldDelegate._hash) {
      return true;
    }
    return false;
  }
}
