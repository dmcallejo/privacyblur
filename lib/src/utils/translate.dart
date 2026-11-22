import 'package:easy_localization/easy_localization.dart' as easy;

/// Translates [key] (a value from `Keys`) into the current locale.
///
/// Placeholders such as `{name}` in a translation are replaced with the
/// matching entries of [args].
String translate(String key, {Map<String, dynamic>? args}) {
  return easy.tr(key,
      namedArgs: args?.map((name, value) => MapEntry(name, '$value')));
}
