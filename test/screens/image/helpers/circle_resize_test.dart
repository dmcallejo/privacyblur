import 'package:flutter_test/flutter_test.dart';
import 'package:privacyblur/src/screens/image/utils/filter_position.dart';

FilterPosition _circle() {
  FilterPosition.resetStoredInfo();
  var f = FilterPosition(100);
  f.posX = 200;
  f.posY = 200;
  return f;
}

void main() {
  test('new shapes are circles by default and have a resize handle', () {
    var f = _circle();
    expect(f.isRounded, isTrue);
    var handle = f.getResizingAreaPosition();
    expect(handle.dx, greaterThan(f.posX));
    expect(handle.dy, greaterThan(f.posY)); // bottom right by default
    expect(f.getResizingAreaClickRect(1).contains(handle), isTrue);
  });

  test('dragging the circle handle changes the radius, not the center', () {
    var f = _circle();
    f.radiusRatio = 0.2; // 20 px
    f.rebuildRadiusFromClick(200 + 40, 200 + 30); // 50 px away
    expect(f.posX, 200);
    expect(f.posY, 200);
    expect(f.getVisibleRadius(), 50);
    var handle = f.getResizingAreaPosition();
    expect(handle.dx, closeTo(240, 1));
    expect(handle.dy, closeTo(230, 1));
  });

  test('dragging the circle handle onto the center is ignored', () {
    var f = _circle();
    f.radiusRatio = 0.2;
    f.rebuildRadiusFromClick(200, 200);
    expect(f.getVisibleRadius(), 20);
    expect(f.getResizingAreaPosition().dx.isNaN, isFalse);
  });
}
