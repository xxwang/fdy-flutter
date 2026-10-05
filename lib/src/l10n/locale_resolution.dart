import 'package:flutter/widgets.dart';

/// 「在 `supportedLocales` 里匹配，匹配不到就用 [fallback]」的语言解析回调。
///
/// 给 `MaterialApp.localeResolutionCallback` /
/// `CupertinoApp.localeResolutionCallback` 用：内置算法
/// （`basicLocaleListResolution`）在没有任何匹配时只会退回 `supportedLocales.first`，
/// 想指定别的兜底语言就只能自己写回调。
///
/// 两个必须知道的坑：
/// 1. 这个回调**在 `locale` 被显式指定时同样会被调用**（`localizations.dart` 把
///    `locale` 包成 `[locale]` 再走同一套解析）⇒ 它必须自己完成匹配，不能无脑
///    返回 [fallback]，否则「用户手动选中某种语言」也会被兜底改写。
/// 2. 返回值必须是 `supportedLocales` 里的那一项：`LocalizationsDelegate.isSupported`
///    拿它去筛 delegate，返回表外的 `Locale` 会让调用方的 `Localizations.of(...)!`
///    直接打崩。
///
/// [fallback] 自己也要在 `supportedLocales` 里，否则等于把坑 2 踩一遍（debug 有断言兜着）。
///
/// ```dart
/// MaterialApp(
///   supportedLocales: const [Locale("zh"), Locale("en")],
///   localeResolutionCallback: localeFallbackResolver(const Locale("en")),
/// )
/// ```
LocaleResolutionCallback localeFallbackResolver(Locale fallback) {
  return (Locale? locale, Iterable<Locale> supportedLocales) {
    assert(
      supportedLocales.contains(fallback),
      "兜底语言 $fallback 不在 supportedLocales 里：delegate 的 isSupported 会把它拦掉。",
    );
    if (locale == null) {
      return fallback;
    }
    // 先要求语言码 + 国家码/文字码全等（`zh_Hant_TW` 要拿到同一个 `Locale`），
    // 再放宽到只比语言码 —— 优先级与内置算法一致，只是省掉了多偏好语言列表的推迟匹配。
    for (final Locale supported in supportedLocales) {
      if (supported == locale) {
        return supported;
      }
    }
    for (final Locale supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return fallback;
  };
}
