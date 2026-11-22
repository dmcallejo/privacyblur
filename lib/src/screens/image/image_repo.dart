import 'package:privacyblur/src/data/services/heap_size.dart';

class ImageRepository {
  final HeapSize _heapSize;

  ImageRepository(this._heapSize);

  Future<int> getHeapSize() async {
    var value = await _heapSize.getSize();
    if (value is int) {
      return Future.value(value);
    } else {
      return Future.value(-1);
    }
  }
}
