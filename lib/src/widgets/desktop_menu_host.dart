import 'dart:io';

import 'package:flutter/material.dart';
import 'package:privacyblur/src/utils/desktop_config.dart';
import 'package:privacyblur/src/utils/layout_config.dart';
import 'package:privacyblur/src/utils/translate.dart';

/// Shows the menus set through [DesktopWindowConfig.updateMenu].
///
/// macOS uses the native menu bar. Windows and Linux get an in-window menu bar
/// above [child]. On mobile platforms this is a no-op.
class DesktopMenuHost extends StatelessWidget {
  final Widget child;

  const DesktopMenuHost({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      return child;
    }
    return ValueListenableBuilder<List<DesktopMenu>>(
      valueListenable: LayoutConfig.desktop.menus,
      builder: (context, menus, _) {
        if (Platform.isMacOS) {
          return PlatformMenuBar(
              menus: menus.map(_nativeMenu).toList(), child: child);
        }
        if (menus.isEmpty) return child;
        return Column(children: [
          Row(children: [Expanded(child: MenuBar(children: _barItems(menus)))]),
          Expanded(child: child),
        ]);
      },
    );
  }

  PlatformMenu _nativeMenu(DesktopMenu menu) {
    final groups = <PlatformMenuItemGroup>[];
    var current = <PlatformMenuItem>[];
    for (final entry in menu.entries) {
      if (entry.divider) {
        groups.add(PlatformMenuItemGroup(members: current));
        current = <PlatformMenuItem>[];
      } else {
        current.add(PlatformMenuItem(
            label: translate(entry.label),
            shortcut: entry.shortcut,
            onSelected: entry.onSelected));
      }
    }
    groups.add(PlatformMenuItemGroup(members: current));
    return PlatformMenu(label: translate(menu.label), menus: groups);
  }

  List<Widget> _barItems(List<DesktopMenu> menus) {
    return menus
        .map((menu) => SubmenuButton(
              menuChildren: menu.entries
                  .map<Widget>((entry) => entry.divider
                      ? const Divider(height: 1)
                      : MenuItemButton(
                          shortcut: entry.shortcut,
                          onPressed: entry.onSelected,
                          child: Text(translate(entry.label))))
                  .toList(),
              child: Text(translate(menu.label)),
            ))
        .toList();
  }
}
