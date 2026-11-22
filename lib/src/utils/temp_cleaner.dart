import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

/// Removes the working copies of images that the app leaves in its cache.
///
/// The image picker (and the EXIF rotation step) copy the original, unblurred
/// photo into the app's private cache. Nothing else deletes those copies, so
/// they are removed when the editor is closed and when the app starts.
class TempCleaner {
  /// Name of the file the desktop save flow writes into the temp directory.
  static const desktopTempFileName = 'blur.jpg';

  static Future<void> clear() async {
    try {
      final Directory tmp = await getTemporaryDirectory();
      if (AppTheme.isDesktop) {
        // On desktop the temp directory is shared with other programs, only
        // remove what this app wrote itself.
        final File file = File('${tmp.path}/$desktopTempFileName');
        if (await file.exists()) await file.delete();
        return;
      }
      // On Android and iOS the temp directory belongs to this app only.
      if (!await tmp.exists()) return;
      await for (final FileSystemEntity entity in tmp.list()) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {
          // File still in use or already gone: try again next time.
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }
  }
}
