import 'package:flutter_test/flutter_test.dart';
import 'package:privacyblur/src/data/services/heap_size.dart';
import 'package:privacyblur/src/data/services/local_storage.dart';
import 'package:privacyblur/src/screens/image/image_repo.dart';
import 'package:privacyblur/src/screens/image/utils/filter_position.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FilterPosition.resetStoredInfo();
  });

  test('nothing stored gives empty defaults', () async {
    var defaults =
        await ImageRepository(LocalStorage(), HeapSize()).getFilterDefaults();
    expect(defaults.isRounded, isNull);
    expect(defaults.isPixelate, isNull);
    expect(defaults.granularityRatio, isNull);
  });

  test('last shape, blur type and strength are persisted', () async {
    var repo = ImageRepository(LocalStorage(), HeapSize());
    await repo.setShapeRounded(false);
    await repo.setFilterPixelate(false);
    await repo.setGranularityRatio(0.25);
    var defaults = await repo.getFilterDefaults();
    expect(defaults.isRounded, false);
    expect(defaults.isPixelate, false);
    expect(defaults.granularityRatio, 0.25);
  });

  test('stored defaults apply to new areas but size is not restored', () {
    var before = FilterPosition(100).radiusRatio;
    FilterPosition.setDefaults(
        isRounded: false, isPixelate: false, granularityRatio: 0.7);
    var filter = FilterPosition(100);
    expect(filter.isRounded, false);
    expect(filter.isPixelate, false);
    expect(filter.granularityRatio, 0.7);
    expect(filter.radiusRatio, before);
  });

  test('null defaults keep current values', () {
    FilterPosition.setDefaults(isRounded: false);
    FilterPosition.setDefaults();
    expect(FilterPosition(100).isRounded, false);
  });
}
