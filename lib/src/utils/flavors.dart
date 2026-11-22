import 'dart:io';

enum Flavor { foss, full }

class BuildFlavor {
  static Flavor flavor = Flavor.full;

  static bool get isFoss => flavor == Flavor.foss;

  /// Automatic face detection needs ML Kit, which only the Android "full"
  /// flavor includes. iOS and desktop builds never ship it.
  static bool get hasFaceDetection => !isFoss && Platform.isAndroid;
}
