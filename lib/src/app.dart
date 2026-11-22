import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/router.dart';
import 'package:privacyblur/src/utils/translate.dart';

import 'widgets/adaptive_widgets_builder.dart';

class PixelMonsterApp extends StatelessWidget {
  final AppRouter _router;

  const PixelMonsterApp(this._router, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBuilder.build(
      title: translate(Keys.App_Name),
      onGenerateRoute: _router.generateRoutes,
      onGenerateInitialRoutes: (String routeName) {
        return _router.onGenerateInitialRoutes(routeName);
      },
      initialRoute: _router.selectInitialRoute(),
      debugShowCheckedModeBanner: false,
      // Includes the Material, Cupertino and widgets delegates.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
