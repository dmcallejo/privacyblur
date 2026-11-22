import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:privacyblur/src/widgets/theme/theme_provider.dart';

class ImagePicking extends ImagePicker {
  static final ImagePicking _instance = ImagePicking._internal();

  factory ImagePicking() => _instance;

  ImagePicking._internal() {
    permissionsGranted = true;
    settingsHasBeenVisited = false;
  }

  late bool permissionsGranted;
  late bool settingsHasBeenVisited;

  final List<String> allowedExtensions = ['jpg', 'png', 'jpeg', 'webp', 'gif'];

  Future<bool> requestLibraryPermissionStatus() async {
    return AppTheme.isDesktop
        ? true
        : (Platform.isIOS
            ? await _requestPermission(Permission.photos)
            : await _requestPermission(Permission.storage));
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted || await permission.isLimited) {
      return true;
    } else {
      return ((await permission.request()) == PermissionStatus.granted ||
          (await permission.request()) == PermissionStatus.limited);
    }
  }

  Future<File?> pickFile(ImageSource type) async {
    File? resultFile;
    if (AppTheme.isDesktop) {
      PlatformFile? pickResult = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if (pickResult?.path != null) resultFile = File(pickResult!.path!);
    } else {
      XFile? pickResult = await pickImage(source: type);
      if (pickResult != null) resultFile = File(pickResult.path);
    }
    return resultFile;
  }

  Future<String?> saveFile(File file) async {
    String? selectedDirectory = await FilePicker.getDirectoryPath();
    String fileName =
        "blur-" + DateTime.now().millisecondsSinceEpoch.toString();
    if (selectedDirectory != null) {
      try {
        await file.copy('$selectedDirectory/$fileName');
        return '$selectedDirectory/$fileName';
      } catch (err) {
        if (kDebugMode) {
          print(err.toString());
        }
      }
    }
    return null;
  }

  void updatePermissionState() async {
    if (!settingsHasBeenVisited) return;
    bool resultPermission = false;
    if (Platform.isIOS) {
      resultPermission = (await Permission.photos.isGranted ||
          await Permission.photos.isLimited);
    } else {
      resultPermission = (await Permission.storage.isGranted);
    }
    if (permissionsGranted != resultPermission) {
      permissionsGranted = resultPermission;
    }
  }
}
