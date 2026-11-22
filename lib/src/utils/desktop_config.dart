
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:privacyblur/resources/localization/keys.dart';

enum DESKTOP_LAYOUT_TYPE { small, large, regular }

/// A single entry of a desktop menu. A [divider] has no label or action.
///
/// Labels are translation keys; they are translated when the menu is shown so
/// that they follow the current locale.
class DesktopMenuEntry {
  final String label;
  final VoidCallback? onSelected;
  final SingleActivator? shortcut;
  final bool divider;

  const DesktopMenuEntry(
      {required this.label, required this.onSelected, this.shortcut})
      : divider = false;

  const DesktopMenuEntry.divider()
      : label = '',
        onSelected = null,
        shortcut = null,
        divider = true;
}

class DesktopMenu {
  final String label;
  final List<DesktopMenuEntry> entries;

  const DesktopMenu({required this.label, required this.entries});
}

class DesktopWindowConfig extends DesktopWindow {
  int? currentMenu;

  /// Menus currently shown by [DesktopMenuHost].
  final ValueNotifier<List<DesktopMenu>> menus = ValueNotifier([]);

  DesktopWindowConfig();

  /// ## WINDOW CONFIG ##

  static final Map<DESKTOP_LAYOUT_TYPE, Size> _desktopSizes = {
    DESKTOP_LAYOUT_TYPE.small: const Size(375, 667),
    DESKTOP_LAYOUT_TYPE.large: const Size(1920, 1080),
    DESKTOP_LAYOUT_TYPE.regular: const Size(1366, 768)
  };

  setupDesktopScreenBoundaries() async {
    return await Future.wait([
      DesktopWindow.setMinWindowSize(_desktopSizes[DESKTOP_LAYOUT_TYPE.small]!),
      DesktopWindow.setMaxWindowSize(_desktopSizes[DESKTOP_LAYOUT_TYPE.large]!),
    ]);
  }

  static Future setWindowSize(
      {DESKTOP_LAYOUT_TYPE size = DESKTOP_LAYOUT_TYPE.regular,
      Size? customSize}) async {
    Size sizeToSet = _desktopSizes[size]!;
    if (customSize != null) sizeToSet = customSize;
    return DesktopWindow.setWindowSize(sizeToSet);
  }

  static Future toggleFullScreen() async {
    return DesktopWindow.toggleFullScreen();
  }

  /// ## MENU CONFIG ##

  void updateMenu({required UniqueKey key, List<DesktopMenu>? extraMenus}) {
    if (currentMenu == key.hashCode) return;
    currentMenu = key.hashCode;
    final newMenus = [_layoutMenu(), if (extraMenus != null) ...extraMenus];
    // Menus are usually requested while building, so publish after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentMenu == key.hashCode) menus.value = newMenus;
    });
  }

  DesktopMenu _layoutMenu() =>
      DesktopMenu(label: Keys.Layout_Configs_Layout, entries: [
        DesktopMenuEntry(
          label: Keys.Layout_Configs_Fullscreen,
          onSelected: () => toggleFullScreen(),
          shortcut: const SingleActivator(LogicalKeyboardKey.f11),
        ),
        DesktopMenuEntry(
          label: Keys.Layout_Configs_Large,
          onSelected: () => setWindowSize(size: DESKTOP_LAYOUT_TYPE.large),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyL),
        ),
        DesktopMenuEntry(
          label: Keys.Layout_Configs_Small,
          onSelected: () => setWindowSize(size: DESKTOP_LAYOUT_TYPE.small),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyS),
        ),
        const DesktopMenuEntry.divider(),
        DesktopMenuEntry(
          label: Keys.Layout_Configs_Regular,
          onSelected: () => setWindowSize(size: DESKTOP_LAYOUT_TYPE.regular),
          shortcut: const SingleActivator(LogicalKeyboardKey.keyZ),
        ),
      ]);
}
