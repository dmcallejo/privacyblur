import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:privacyblur/src/screens/image/utils/filter_position.dart';
import 'package:privacyblur/src/utils/image_filter/helpers/range_checker.dart';

/// square with corners (160,220) and (240,180): 80 wide, 40 tall at (200,200)
FilterPosition _wideSquare() {
  FilterPosition.resetStoredInfo();
  var f = FilterPosition(100);
  f.isRounded = false;
  f.posX = 0;
  f.posY = 0;
  var d = f.getResizingAreaPosition(); // offset center -> corner handle
  // place center so that the opposite (anchor) corner is at (160, 220)
  f.posX = 160 + d.dx;
  f.posY = 220 + d.dy;
  f.rebuildRadiusFromClick(240, 180);
  return f;
}

void main() {
  test('unrotated square keeps old behaviour', () {
    var f = _wideSquare();
    expect(f.rotation, 0);
    expect(f.isInnerPoint(230, 190), isTrue);
    expect(f.isInnerPoint(260, 200), isFalse);
  });

  test('rotation by 90 degrees swaps hit area', () {
    var f = _wideSquare();
    var halfW = f.getVisibleWidth().abs() / 2;
    var halfH = f.getVisibleHeight().abs() / 2;
    expect(halfW, greaterThan(halfH));
    // point far along x is inside before rotation, outside after
    var px = f.posX + halfW - 1;
    expect(f.isInnerPoint(px, f.posY), isTrue);
    f.rotation = pi / 2;
    expect(f.isInnerPoint(px, f.posY), isFalse);
    expect(f.isInnerPoint(f.posX, f.posY + halfW - 1), isTrue);
  });

  test('resize handle follows rotation', () {
    var f = _wideSquare();
    var before = f.getResizingAreaPosition();
    f.rotation = pi;
    var after = f.getResizingAreaPosition();
    expect(after.dx, closeTo(2 * f.posX - before.dx, 1e-6));
    expect(after.dy, closeTo(2 * f.posY - before.dy, 1e-6));
  });

  test('rotation handle is above the top edge and rotateFromClick aims at it',
      () {
    var f = _wideSquare();
    var h = f.getRotationHandlePosition(1);
    expect(h.dx, closeTo(f.posX, 1e-6));
    expect(h.dy, lessThan(f.posY - f.getVisibleHeight().abs() / 2));
    // drag handle to the right of center -> 90 degrees clockwise
    f.rotateFromClick(f.posX + 100, f.posY);
    expect(f.rotation, closeTo(pi / 2, 1e-6));
    // near 45 degrees snaps
    f.rotateFromClick(f.posX + 100, f.posY - 103);
    expect(f.rotation, closeTo(pi / 4, 1e-9));
    var moved = f.getRotationHandlePosition(1);
    f.rotateFromClick(moved.dx, moved.dy);
    expect(f.rotation, closeTo(pi / 4, 1e-6));
  });

  test('rotation handle flips below the square when there is no room above',
      () {
    var f = _wideSquare();
    f.getRotationHandlePosition(1);
    expect(f.isRotationHandleBelow, isFalse);
    f.posY = 25; // top edge 5px from the image border, stem would not fit
    var h = f.getRotationHandlePosition(1);
    expect(f.isRotationHandleBelow, isTrue);
    expect(h.dx, closeTo(f.posX, 1e-6));
    expect(h.dy, greaterThan(f.posY + f.getVisibleHeight().abs() / 2));
    expect(f.getRotationStemStart().dy,
        closeTo(f.posY + f.getVisibleHeight().abs() / 2, 1e-6));
    // aiming at the handle keeps the rotation unchanged...
    f.rotateFromClick(h.dx, h.dy);
    expect(f.rotation, closeTo(0, 1e-6));
    // ...and dragging it to the right still rotates clockwise by 90 degrees
    f.rotateFromClick(f.posX - 100, f.posY);
    expect(f.rotation, closeTo(pi / 2, 1e-6));
    // handle side doesn't depend on the rotation
    f.getRotationHandlePosition(1);
    expect(f.isRotationHandleBelow, isTrue);
  });

  test('resizing a rotated square keeps the opposite corner fixed', () {
    var f = _wideSquare();
    f.rotation = pi / 6;
    // opposite corner = center mirrored through handle
    var handle = f.getResizingAreaPosition();
    var anchorX = 2 * f.posX - handle.dx;
    var anchorY = 2 * f.posY - handle.dy;
    var target = Offset2(handle.dx + 10, handle.dy - 5);
    f.rebuildRadiusFromClick(target.x, target.y);
    var newHandle = f.getResizingAreaPosition();
    expect(newHandle.dx, closeTo(target.x, 1.5));
    expect(newHandle.dy, closeTo(target.y, 1.5));
    expect(2 * f.posX - newHandle.dx, closeTo(anchorX, 1.5));
    expect(2 * f.posY - newHandle.dy, closeTo(anchorY, 1.5));
    expect(f.rotation, pi / 6);
  });

  test('rotated range cuts corners of bounding box', () {
    // 40x40 square rotated 45deg at (50,50): diamond with half diagonal ~28
    var r = RangeHelper.rotatedSquare(50, 50, 40, 40, pi / 4, 100, 100, 0);
    expect(r.x1, lessThanOrEqualTo(22));
    expect(r.x2, greaterThanOrEqualTo(78));
    expect(r.checkPointInRange(50, 50), isTrue);
    expect(r.checkPointInRange(70, 50), isTrue);
    expect(r.checkPointInRange(75, 50), isTrue);
    expect(r.checkPointInRange(72, 72), isFalse); // bbox corner
    expect(r.checkPointInRange(28, 28), isFalse);
  });

  test('rotated range with angle 90 matches swapped rectangle', () {
    var r = RangeHelper.rotatedSquare(50, 50, 60, 20, pi / 2, 100, 100, 0);
    expect(r.checkPointInRange(50, 78), isTrue);
    expect(r.checkPointInRange(78, 50), isFalse);
  });
}

class Offset2 {
  final double x;
  final double y;
  Offset2(this.x, this.y);
}
