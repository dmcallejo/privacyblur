import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import 'app.dart';
import 'constants.dart';
import 'di.dart';
import 'router.dart';
import 'utils/layout_config.dart';
import 'widgets/theme/theme_provider.dart';

class AppContainer {
  Widget? _app;

  late DependencyInjection _di;
  late ScreenNavigator _navigator;
  late AppRouter _router;

  static final AppContainer _singleton = AppContainer._internal();

  factory AppContainer() {
    return _singleton;
  }

  AppContainer._internal() {
    _di = DependencyInjection();
    _navigator = ScreenNavigator();
    _router = AppRouter.fromMainScreen(_navigator, _di);
  }

  Future<Widget> get app async {
    if (_app != null) return _app!;
    await EasyLocalization.ensureInitialized();
    if (AppTheme.isDesktop) _setupDesktopConfigs();
    _app = EasyLocalization(
        path: localizationResourcesPath,
        fallbackLocale: defaultLocale,
        supportedLocales: supportedLocales,
        child: PixelMonsterApp(_router));
    return _app!;
  }

  void _setupDesktopConfigs() {
    LayoutConfig.desktop.setupDesktopScreenBoundaries();
    LayoutConfig.desktop.updateMenu(key: UniqueKey());
  }
}
