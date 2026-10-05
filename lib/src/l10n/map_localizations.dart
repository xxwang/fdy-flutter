import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 手写 Map 文案表 + [LocalizationsDelegate] 的基类，零 codegen。
///
/// 子类只需要三样东西：
/// 1. 一张 `语言码 -> { key: 文案 }` 的 `static const` 表（[strings]）；
/// 2. 兜底语言码（[fallbackLanguage]）；
/// 3. 若干 `String get xxx => tr("xxx");` 具名 getter。
///
/// ```dart
/// class AppLocalization extends MapLocalizations {
///   const AppLocalization(super.locale);
///
///   /// 与 [_strings] 的 key 必须一致。
///   static const Set<String> languageCodes = {"zh"};
///
///   static const Map<String, Map<String, String>> _strings = {
///     "zh": {"home": "首页"},
///   };
///
///   @override
///   String get fallbackLanguage => "zh";
///
///   @override
///   Map<String, Map<String, String>> get strings => _strings;
///
///   static AppLocalization of(BuildContext context) =>
///       Localizations.of<AppLocalization>(context, AppLocalization)!;
///
///   String get home => tr("home");
/// }
/// ```
///
/// 挂进 `MaterialApp` / `CupertinoApp` 用 [MapLocalizationsDelegate]。
///
/// 「加一种语言」= 表里多一条 + 在 [MapLocalizationsDelegate] 的
/// `supportedLanguageCodes` 里补上，getter 与全部调用点都不用动。
abstract class MapLocalizations {
  const MapLocalizations(this.locale);

  /// 当前被解析到的语言。
  final Locale locale;

  /// `语言码 -> { key: 文案 }`。实现里返回一个 `static const` 表即可。
  Map<String, Map<String, String>> get strings;

  /// [strings] 里没有当前语言时退回它。
  /// ⚠️ 必须是 [strings] 里真实存在的 key，否则取值时会空指针。
  String get fallbackLanguage;

  /// 按 key 取文案。
  ///
  /// 取不到时返回 `[KEY]` 而不是空串 —— 缺文案会明晃晃留在界面上，
  /// 不会静默变成一片空白。
  String tr(String key) {
    final Map<String, String> table =
        strings[locale.languageCode] ?? strings[fallbackLanguage]!;
    return table[key] ?? "[${key.toUpperCase()}]";
  }
}

/// 把某个 [MapLocalizations] 子类挂进 `Localizations`。
///
/// [create] 传子类的构造函数 tear-off（`AppLocalization.new`）；
/// [supportedLanguageCodes] 必须与子类文案表的 key 完全一致 ——
/// 列了表里没有的语言，[isSupported] 会放行、[load] 却拿不到文案，
/// 调用方的 `Localizations.of(...)!` 直接打崩界面。
class MapLocalizationsDelegate<T extends MapLocalizations>
    extends LocalizationsDelegate<T> {
  const MapLocalizationsDelegate(this.create, this.supportedLanguageCodes);

  final T Function(Locale locale) create;

  final Set<String> supportedLanguageCodes;

  @override
  bool isSupported(Locale locale) =>
      supportedLanguageCodes.contains(locale.languageCode);

  @override
  Future<T> load(Locale locale) => SynchronousFuture<T>(create(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;
}
