import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyblur/resources/localization/keys.dart';
import 'package:privacyblur/src/app_container.dart';
import 'package:privacyblur/src/utils/translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the whole app, so that problems at start-up (for example the
/// localization assets failing to load) fail the build instead of showing up
/// as a blank screen on a device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and shows the translated main screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Desktop window plugin is not available in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('desktop_window'), (call) async => null);

    await tester.runAsync(() async {
      await tester.pumpWidget(await AppContainer().app);
      // Localization files are loaded from the asset bundle.
      await Future<void>.delayed(const Duration(seconds: 1));
      await tester.pump();
    });
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(translate(Keys.Main_Screen_Select_Image)), findsOneWidget);
    // A missing translation would show the raw key instead.
    expect(find.text(Keys.Main_Screen_Select_Image), findsNothing);
    expect(find.text('Select image'), findsWidgets);
  });
}
