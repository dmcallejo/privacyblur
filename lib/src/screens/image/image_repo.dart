import 'package:privacyblur/src/data/services/heap_size.dart';
import 'package:privacyblur/src/data/services/local_storage.dart';

/// last used blur settings (everything except the size), restored on start
class FilterDefaults {
  final bool? isRounded;
  final bool? isPixelate;
  final double? granularityRatio;

  const FilterDefaults({this.isRounded, this.isPixelate, this.granularityRatio});
}

class ImageRepository {
  final LocalStorage _storage;
  final HeapSize _heapSize;

  ImageRepository(this._storage, this._heapSize);

  static const _keyRounded = 'lastShapeRounded';
  static const _keyPixelate = 'lastFilterPixelate';
  static const _keyGranularity = 'lastGranularityRatio';

  Future<FilterDefaults> getFilterDefaults() async {
    return FilterDefaults(
        isRounded: await _storage.getBool(_keyRounded),
        isPixelate: await _storage.getBool(_keyPixelate),
        granularityRatio: await _storage.getDouble(_keyGranularity));
  }

  Future<void> setShapeRounded(bool value) =>
      _storage.putBool(_keyRounded, value);

  Future<void> setFilterPixelate(bool value) =>
      _storage.putBool(_keyPixelate, value);

  Future<void> setGranularityRatio(double value) =>
      _storage.putDouble(_keyGranularity, value);

  Future<int> getHeapSize() async {
    var value = await _heapSize.getSize();
    if (value is int) {
      return Future.value(value);
    } else {
      return Future.value(-1);
    }
  }
}
